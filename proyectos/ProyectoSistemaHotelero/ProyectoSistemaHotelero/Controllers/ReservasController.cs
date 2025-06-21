using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using ProyectoSistemaHotelero.Models.ViewModels;
using System.Data;
using System.Security.Claims;

namespace ProyectoSistemaHotelero.Controllers
{
    public class ReservasController : Controller
    {
        private readonly string _connectionString;

        public ReservasController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        [HttpGet]
        public IActionResult Checkout()
        {
            // Verificar autenticación
            if (!User.Identity.IsAuthenticated)
            {
                // Guardar la URL actual para redirigir después del login
                var returnUrl = Url.Action("Checkout", "Reservas");
                return RedirectToAction("Login", "Account", new { returnUrl = returnUrl });
            }

            // Crear ViewModel con horas disponibles
            var viewModel = new CheckoutViewModel();

            // Llenar información del usuario autenticado
            viewModel.NombreCliente = User.FindFirst(ClaimTypes.Name)?.Value ?? "";
            viewModel.EmailCliente = User.FindFirst(ClaimTypes.Email)?.Value ?? "";
            viewModel.CedulaCliente = User.FindFirst("Cedula")?.Value ?? "";

            // Generar horas disponibles
            viewModel.HorasDisponibles = GenerarHorasDisponibles();

            return View(viewModel);
        }

        [HttpPost]
        [Authorize]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> FinalizarReserva(CheckoutViewModel modelo)
        {
            if (!ModelState.IsValid)
            {
                modelo.HorasDisponibles = GenerarHorasDisponibles();
                return View("Checkout", modelo);
            }

            try
            {
                // Verificar que tenemos todos los datos necesarios
                if (modelo.HabitacionId <= 0)
                {
                    ModelState.AddModelError("", "Error: No se encontró información de la habitación.");
                    modelo.HorasDisponibles = GenerarHorasDisponibles();
                    return View("Checkout", modelo);
                }

                // Crear la reserva en la base de datos
                var reservacionId = await CrearReserva(modelo);

                if (reservacionId > 0)
                {
                    // Limpiar datos de sesión
                    TempData["ReservacionExitosa"] = "¡Reserva creada exitosamente!";
                    TempData["ReservacionId"] = reservacionId;

                    // Redirigir a confirmación
                    return RedirectToAction("Confirmacion", new { reservacionId = reservacionId });
                }
                else
                {
                    ModelState.AddModelError("", "Error al crear la reserva. No se pudo obtener el ID de la reservación.");
                    modelo.HorasDisponibles = GenerarHorasDisponibles();
                    return View("Checkout", modelo);
                }
            }
            catch (SqlException sqlEx)
            {
                // Manejar errores específicos de SQL
                string errorMessage = sqlEx.Message.Contains("disponible")
                    ? "La habitación ya no está disponible para las fechas seleccionadas."
                    : "Error en la base de datos al procesar la reserva.";

                ModelState.AddModelError("", errorMessage);
                modelo.HorasDisponibles = GenerarHorasDisponibles();
                return View("Checkout", modelo);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "Ocurrió un error inesperado al procesar la reserva: " + ex.Message);
                modelo.HorasDisponibles = GenerarHorasDisponibles();
                return View("Checkout", modelo);
            }
        }

        private async Task<int> CrearReserva(CheckoutViewModel modelo)
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("sp_InsertarReservacion", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            // Obtener cédula del cliente autenticado
            var cedulaCliente = User.FindFirst("Cedula")?.Value ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

            // Parámetros según tu stored procedure
            command.Parameters.AddWithValue("@CedulaID", cedulaCliente);
            command.Parameters.AddWithValue("@HabitacionID", modelo.HabitacionId);
            command.Parameters.AddWithValue("@FechaIngreso", modelo.FechaCheckIn.Date.Add(modelo.HoraIngreso));
            command.Parameters.AddWithValue("@CantidadPersonas", modelo.CantidadPersonas);
            command.Parameters.AddWithValue("@PoseeVehiculo", modelo.PoseeVehiculo);
            command.Parameters.AddWithValue("@FechaSalida", modelo.FechaCheckOut.Date.Add(modelo.HoraSalida));
            command.Parameters.AddWithValue("@Estado", "ACTIVO");

            // Parámetro de salida para obtener el ID de la reservación
            var outputParam = new SqlParameter("@ReservacionID", SqlDbType.Int)
            {
                Direction = ParameterDirection.Output
            };
            command.Parameters.Add(outputParam);

            await connection.OpenAsync();
            await command.ExecuteNonQueryAsync();

            // Retornar el ID de la reservación creada
            return outputParam.Value != DBNull.Value ? (int)outputParam.Value : 0;
        }

        private List<TimeOption> GenerarHorasDisponibles()
        {
            var horas = new List<TimeOption>();

            // Horas de ingreso (desde 12:00 PM hasta 11:00 PM)
            for (int hora = 12; hora <= 23; hora++)
            {
                for (int minuto = 0; minuto < 60; minuto += 30)
                {
                    var time = new TimeSpan(hora, minuto, 0);
                    var displayTime = DateTime.Today.Add(time).ToString("h:mm tt");

                    horas.Add(new TimeOption
                    {
                        Value = time.ToString(@"hh\:mm"),
                        Text = displayTime
                    });
                }
            }

            return horas;
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> Confirmacion(int reservacionId)
        {
            try
            {
                var viewModel = await ObtenerDetallesReservacion(reservacionId);

                if (viewModel == null)
                {
                    TempData["Error"] = "No se encontró la reservación especificada.";
                    return RedirectToAction("Index", "Home");
                }

                return View(viewModel);
            }
            catch (Exception ex)
            {
                TempData["Error"] = "Error al obtener los detalles de la reservación.";
                return RedirectToAction("Index", "Home");
            }
        }

        private async Task<ConfirmacionReservaViewModel?> ObtenerDetallesReservacion(int reservacionId)
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("sp_ObtenerDetallesReservacion", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@ReservacionID", reservacionId);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            ConfirmacionReservaViewModel? viewModel = null;

            // Información principal de la reserva
            if (await reader.ReadAsync())
            {
                viewModel = new ConfirmacionReservaViewModel
                {
                    ReservacionId = Convert.ToInt32(reader["ReservacionID"]),
                    NumeroReservacion = $"#{reader["ReservacionID"]}",
                    FechaReserva = Convert.ToDateTime(reader["FechaReserva"]),
                    Estado = reader["Estado"]?.ToString() ?? "",

                    // Hotel
                    NombreHotel = reader["NombreHotel"]?.ToString() ?? "",
                    UbicacionHotel = reader["UbicacionHotel"]?.ToString() ?? "",
                    TelefonoHotel = reader["TelefonoHotel"]?.ToString() ?? "",
                    EmailHotel = reader["EmailHotel"]?.ToString() ?? "",

                    // Habitación
                    TipoHabitacion = reader["TipoHabitacion"]?.ToString() ?? "",
                    NumeroHabitacion = reader["NumeroHabitacion"]?.ToString() ?? "",
                    PrecioPorNoche = Convert.ToDecimal(reader["PrecioPorNoche"]),
                    PrecioTotal = Convert.ToDecimal(reader["PrecioTotal"]),

                    // Fechas
                    FechaCheckIn = Convert.ToDateTime(reader["FechaIngreso"]),
                    FechaCheckOut = Convert.ToDateTime(reader["FechaSalida"]),
                    CantidadPersonas = Convert.ToInt32(reader["CantidadPersonas"]),
                    PoseeVehiculo = Convert.ToBoolean(reader["PoseeVehiculo"]),

                    // Cliente
                    NombreCliente = reader["NombreCliente"]?.ToString() ?? "",
                    EmailCliente = reader["EmailCliente"]?.ToString() ?? "",
                    TelefonoCliente = reader["TelefonoCliente"]?.ToString() ?? ""
                };

                // Calcular horas y noches
                viewModel.HoraIngreso = viewModel.FechaCheckIn.TimeOfDay;
                viewModel.HoraSalida = viewModel.FechaCheckOut.TimeOfDay;
                viewModel.NochesEstadia = (int)(viewModel.FechaCheckOut.Date - viewModel.FechaCheckIn.Date).TotalDays;
            }

            // Obtener imagen del hotel
            await reader.NextResultAsync();
            if (await reader.ReadAsync())
            {
                var imagenBytes = reader["Fotos"] as byte[];
                if (imagenBytes != null && imagenBytes.Length > 0 && viewModel != null)
                {
                    var base64String = Convert.ToBase64String(imagenBytes);
                    viewModel.ImagenHotel = $"data:image/jpeg;base64,{base64String}";
                }
            }

            // Obtener servicios
            await reader.NextResultAsync();
            if (viewModel != null)
            {
                while (await reader.ReadAsync())
                {
                    viewModel.ServiciosIncluidos.Add(reader["Servicio"]?.ToString() ?? "");
                }
            }

            return viewModel;
        }
    }
}