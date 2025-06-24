using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using ProyectoSistemaHotelero.Models;
using ProyectoSistemaHotelero.Models.ViewModels;
using System.Data;
using System.Data.SqlClient;

namespace ProyectoSistemaHotelero.Controllers
{
    public class BusquedasController : Controller
    {
        private readonly string _connectionString;

        public BusquedasController(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        [HttpGet]
        public async Task<IActionResult> Hoteles(string ubicacion = "",
            DateTime? checkIn = null, DateTime? checkOut = null,
            int personas = 1, int pagina = 1)
        {
            var viewModel = new BusquedaHotelesViewModel
            {
                Ubicacion = ubicacion,
                FechaCheckIn = checkIn ?? DateTime.Now.AddDays(1),
                FechaCheckOut = checkOut ?? DateTime.Now.AddDays(2),
                CantidadPersonas = personas,
                PaginaActual = pagina
            };

            // Cargar servicios y comodidades para filtros
            viewModel.ServiciosDisponibles = await ObtenerServicios();
            viewModel.ComodidadesDisponibles = await ObtenerComodidades();

            // Realizar búsqueda si hay criterios
            if (!string.IsNullOrEmpty(ubicacion))
            {
                await RealizarBusqueda(viewModel);
            }

            return View(viewModel);
        }

        [HttpPost]
        public async Task<IActionResult> BuscarHoteles(BusquedaHotelesViewModel modelo)
        {
            if (modelo == null)
            {
                return RedirectToAction("Hoteles");
            }

            // Log para debug
            Console.WriteLine($"Búsqueda recibida - Ubicación: {modelo.Ubicacion}, CheckIn: {modelo.FechaCheckIn}, CheckOut: {modelo.FechaCheckOut}, Personas: {modelo.CantidadPersonas}");

            modelo.ServiciosDisponibles = await ObtenerServicios();
            modelo.ComodidadesDisponibles = await ObtenerComodidades();

            await RealizarBusqueda(modelo);

            return View("Hoteles", modelo);
        }

        [HttpPost]
        public async Task<IActionResult> AplicarFiltros(BusquedaHotelesViewModel modelo)
        {
            if (modelo == null)
            {
                return RedirectToAction("Hoteles");
            }

            // Log para debug  
            Console.WriteLine($"Filtros aplicados - Ubicación: {modelo.Ubicacion}, Precio Min: {modelo.PrecioMinimo}, Precio Max: {modelo.PrecioMaximo}");
            Console.WriteLine($"Servicios seleccionados: {(modelo.ServiciosSeleccionados?.Count ?? 0)} items");
            Console.WriteLine($"Comodidades seleccionadas: {(modelo.ComodidadesSeleccionadas?.Count ?? 0)} items");

            modelo.ServiciosDisponibles = await ObtenerServicios();
            modelo.ComodidadesDisponibles = await ObtenerComodidades();
            modelo.PaginaActual = 1; // Resetear a primera página

            await RealizarBusqueda(modelo);

            return View("Hoteles", modelo);
        }

        private async Task RealizarBusqueda(BusquedaHotelesViewModel viewModel)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("sp_BuscarHotelesAvanzado", connection)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 60 // 60 segundos timeout
                };

                // Parámetros del stored procedure
                command.Parameters.AddWithValue("@Ubicacion", viewModel.Ubicacion ?? "");
                command.Parameters.AddWithValue("@FechaCheckIn", viewModel.FechaCheckIn);
                command.Parameters.AddWithValue("@FechaCheckOut", viewModel.FechaCheckOut);
                command.Parameters.AddWithValue("@CantidadPersonas", viewModel.CantidadPersonas);

                command.Parameters.AddWithValue("@PrecioMinimo",
                    viewModel.PrecioMinimo.HasValue ? viewModel.PrecioMinimo.Value : DBNull.Value);
                command.Parameters.AddWithValue("@PrecioMaximo",
                    viewModel.PrecioMaximo.HasValue ? viewModel.PrecioMaximo.Value : DBNull.Value);

                // Convertir listas a strings separados por comas
                var serviciosIds = viewModel.ServiciosSeleccionados?.Any() == true
                    ? string.Join(",", viewModel.ServiciosSeleccionados)
                    : null;
                var comodidadesIds = viewModel.ComodidadesSeleccionadas?.Any() == true
                    ? string.Join(",", viewModel.ComodidadesSeleccionadas)
                    : null;

                command.Parameters.AddWithValue("@ServiciosIDs", serviciosIds ?? (object)DBNull.Value);
                command.Parameters.AddWithValue("@ComodidadesIDs", comodidadesIds ?? (object)DBNull.Value);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                var resultados = new List<HotelResultado>();

                while (await reader.ReadAsync())
                {
                    var hotel = new HotelResultado
                    {
                        CedulaJuridica = reader["CedulaJuridica"]?.ToString() ?? "",
                        Nombre = reader["Nombre"]?.ToString() ?? "",
                        TipoHotel = reader["TipoHotel"]?.ToString() ?? "",
                        UbicacionCompleta = reader["UbicacionCompleta"]?.ToString() ?? "",
                        CorreoElectronico = reader["CorreoElectronico"]?.ToString() ?? "",
                        URLSitioWeb = reader["URLSitioWeb"]?.ToString(),
                        PrecioMinimo = reader["PrecioMinimo"] != DBNull.Value ? Convert.ToDecimal(reader["PrecioMinimo"]) : 0,
                        PrecioMaximo = reader["PrecioMaximo"] != DBNull.Value ? Convert.ToDecimal(reader["PrecioMaximo"]) : 0
                    };

                    resultados.Add(hotel);
                }

                // Cerrar el reader antes de hacer otras consultas
                reader.Close();

                // Enriquecer datos de hoteles
                foreach (var hotel in resultados)
                {
                    await EnriquecerDatosHotel(hotel);
                }

                // Aplicar paginación
                viewModel.TotalResultados = resultados.Count;
                var inicio = (viewModel.PaginaActual - 1) * viewModel.ResultadosPorPagina;
                viewModel.Resultados = resultados.Skip(inicio)
                                                .Take(viewModel.ResultadosPorPagina)
                                                .ToList();
            }
            catch (Exception ex)
            {
                // Log del error (implementar logging según tu sistema)
                Console.WriteLine($"Error en búsqueda: {ex.Message}");
                viewModel.Resultados = new List<HotelResultado>();
                viewModel.TotalResultados = 0;
            }
        }


        private async Task EnriquecerDatosHotel(HotelResultado hotel)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                var imgQuery = @"
                    SELECT TOP 1 FH.Fotos 
                    FROM FotosHabitacion FH
                    INNER JOIN TipoHabitacion TH ON FH.TipoHabitacionID = TH.TipoHabitacionID
                    WHERE TH.CedulaJuridica = @CedulaJuridica
                    ORDER BY FH.FotoID";

                using var imgCommand = new SqlCommand(imgQuery, connection);
                imgCommand.Parameters.AddWithValue("@CedulaJuridica", hotel.CedulaJuridica);

                var resultado = await imgCommand.ExecuteScalarAsync();

                // LOGS DE DEBUG
                Console.WriteLine($"=== DEBUG IMAGEN HOTEL {hotel.CedulaJuridica} ===");
                Console.WriteLine($"Resultado query: {(resultado == null ? "NULL" : "Tiene datos")}");
                Console.WriteLine($"Tipo de resultado: {resultado?.GetType().Name}");

                if (resultado is byte[] imagenBytes)
                {
                    Console.WriteLine($"Tamaño de imagen: {imagenBytes.Length} bytes");

                    if (imagenBytes.Length > 0)
                    {
                        var base64String = Convert.ToBase64String(imagenBytes);
                        hotel.ImagenPrincipal = $"data:image/jpeg;base64,{base64String}";
                        Console.WriteLine($"Base64 generado (primeros 50 chars): {base64String.Substring(0, Math.Min(50, base64String.Length))}...");
                        Console.WriteLine($"ImagenPrincipal asignada: {hotel.ImagenPrincipal.Substring(0, Math.Min(100, hotel.ImagenPrincipal.Length))}...");
                    }
                    else
                    {
                        Console.WriteLine("Array de bytes está vacío");
                    }
                }
                else
                {
                    Console.WriteLine($"El resultado no es byte[], es: {resultado?.GetType().Name}");
                }

                // Resto del código para servicios...
                var serviciosQuery = @"
                    SELECT S.Nombre 
                    FROM HotelServicios HS
                    INNER JOIN Servicios S ON HS.ServicioID = S.ServicioID
                    WHERE HS.CedulaJuridica = @CedulaJuridica";

                using var serviciosCommand = new SqlCommand(serviciosQuery, connection);
                serviciosCommand.Parameters.AddWithValue("@CedulaJuridica", hotel.CedulaJuridica);

                using var serviciosReader = await serviciosCommand.ExecuteReaderAsync();
                while (await serviciosReader.ReadAsync())
                {
                    hotel.Servicios.Add(serviciosReader["Nombre"]?.ToString() ?? "");
                }

                Console.WriteLine($"Servicios encontrados: {hotel.Servicios.Count}");
                Console.WriteLine("=== FIN DEBUG ===");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR en EnriquecerDatosHotel: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
            }
        }

        private async Task<List<Servicio>> ObtenerServicios()
        {
            var servicios = new List<Servicio>();

            using var connection = new SqlConnection(_connectionString);
            var query = "SELECT ServicioID, Nombre FROM Servicios ORDER BY Nombre";
            using var command = new SqlCommand(query, connection);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                servicios.Add(new Servicio
                {
                    ServicioID = Convert.ToInt32(reader["ServicioID"]),
                    Nombre = reader["Nombre"].ToString()
                });
            }

            return servicios;
        }

        private async Task<List<Comodidad>> ObtenerComodidades()
        {
            var comodidades = new List<Comodidad>();

            using var connection = new SqlConnection(_connectionString);
            var query = "SELECT ComodidadID, Nombre FROM Comodidades ORDER BY Nombre";
            using var command = new SqlCommand(query, connection);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                comodidades.Add(new Comodidad
                {
                    ComodidadID = Convert.ToInt32(reader["ComodidadID"]),
                    Nombre = reader["Nombre"].ToString()
                });
            }

            return comodidades;
        }

        [HttpGet]
        public async Task<IActionResult> DetalleHotel(string cedulaJuridica,
                DateTime? checkIn = null, DateTime? checkOut = null, int personas = 1)
        {
            if (string.IsNullOrEmpty(cedulaJuridica))
            {
                return RedirectToAction("Hoteles");
            }

            try
            {
                var viewModel = new DetalleHotelViewModel
                {
                    FechaCheckIn = checkIn ?? DateTime.Now.AddDays(1),
                    FechaCheckOut = checkOut ?? DateTime.Now.AddDays(2),
                    CantidadPersonas = personas
                };

                viewModel.NochesEstadia = (int)(viewModel.FechaCheckOut - viewModel.FechaCheckIn).TotalDays;

                // Usar el stored procedure para obtener todos los datos
                await ObtenerDetallesCompletos(cedulaJuridica, viewModel);

                return View(viewModel);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error obteniendo detalles del hotel: {ex.Message}");
                return RedirectToAction("Hoteles");
            }
        }

        private async Task ObtenerDetallesCompletos(string cedulaJuridica, DetalleHotelViewModel viewModel)
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("sp_ObtenerDetallesHotel", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@CedulaJuridica", cedulaJuridica);
            command.Parameters.AddWithValue("@FechaCheckIn", viewModel.FechaCheckIn);
            command.Parameters.AddWithValue("@FechaCheckOut", viewModel.FechaCheckOut);
            command.Parameters.AddWithValue("@CantidadPersonas", viewModel.CantidadPersonas);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            // 1. Información general del hotel
            if (await reader.ReadAsync())
            {
                viewModel.CedulaJuridica = reader["CedulaJuridica"]?.ToString() ?? "";
                viewModel.NombreHotel = reader["Nombre"]?.ToString() ?? "";
                viewModel.TipoHotel = reader["TipoHotel"]?.ToString() ?? "";
                viewModel.UbicacionCompleta = reader["UbicacionCompleta"]?.ToString() ?? "";
                viewModel.CorreoElectronico = reader["CorreoElectronico"]?.ToString() ?? "";
                viewModel.URLSitioWeb = reader["URLSitioWeb"]?.ToString();
            }

            // 2. Teléfonos del hotel
            await reader.NextResultAsync();
            var telefonos = new List<string>();
            while (await reader.ReadAsync())
            {
                telefonos.Add(reader["Numero"]?.ToString() ?? "");
            }

            // 3. Servicios del hotel
            await reader.NextResultAsync();
            while (await reader.ReadAsync())
            {
                viewModel.ServiciosHotel.Add(reader["Servicio"]?.ToString() ?? "");
            }

            // 4. Redes sociales (opcional)
            await reader.NextResultAsync();
            while (await reader.ReadAsync())
            {
                // Puedes usar esto si quieres mostrar redes sociales
            }

            // 5. Habitaciones disponibles - tomamos la primera como recomendada
            await reader.NextResultAsync();
            if (await reader.ReadAsync())
            {
                var habitacionID = Convert.ToInt32(reader["HabitacionID"]);
                var tipoHabitacionID = Convert.ToInt32(reader["TipoHabitacionID"]); // Necesitas agregar este campo al SP

                viewModel.HabitacionRecomendada = new HabitacionDisponible
                {
                    TipoHabitacionID = tipoHabitacionID,
                    HabitacionID = habitacionID, // Agregar esta propiedad al ViewModel
                    NombreHabitacion = reader["TipoHabitacion"]?.ToString() ?? "",
                    DescripcionHabitacion = reader["Descripcion"]?.ToString() ?? "",
                    CapacidadPersonas = Convert.ToInt32(reader["CapacidadTotal"]),
                    PrecioPorNoche = Convert.ToDecimal(reader["PrecioPorNoche"]),
                    NumeroHabitacion = reader["Numero"]?.ToString() ?? ""
                };

                viewModel.PrecioPorNoche = viewModel.HabitacionRecomendada.PrecioPorNoche;
                viewModel.PrecioTotal = Convert.ToDecimal(reader["PrecioTotal"]);
            }

            // 6. Tipos de cama por habitación
            await reader.NextResultAsync();
            if (viewModel.HabitacionRecomendada != null)
            {
                while (await reader.ReadAsync())
                {
                    var habitacionId = Convert.ToInt32(reader["HabitacionID"]);
                    if (habitacionId == viewModel.HabitacionRecomendada.HabitacionID)
                    {
                        viewModel.HabitacionRecomendada.CantidadCamas = Convert.ToInt32(reader["CantidadCamas"]);
                        viewModel.HabitacionRecomendada.TipoCamas = reader["TipoCama"]?.ToString() ?? "";
                        break;
                    }
                }
            }

            // 7. Comodidades por habitación
            await reader.NextResultAsync();
            if (viewModel.HabitacionRecomendada != null)
            {
                while (await reader.ReadAsync())
                {
                    var habitacionId = Convert.ToInt32(reader["HabitacionID"]);
                    if (habitacionId == viewModel.HabitacionRecomendada.HabitacionID)
                    {
                        viewModel.HabitacionRecomendada.ComodidadesHabitacion.Add(reader["Comodidad"]?.ToString() ?? "");
                    }
                }
            }

            // 8. Fotos de habitaciones
            await reader.NextResultAsync();
            var fotosGenerales = new List<string>();

            while (await reader.ReadAsync())
            {
                var habitacionId = Convert.ToInt32(reader["HabitacionID"]);
                var imagenBytes = reader["Fotos"] as byte[];

                if (imagenBytes != null && imagenBytes.Length > 0)
                {
                    var base64String = Convert.ToBase64String(imagenBytes);
                    var imagenUrl = $"data:image/jpeg;base64,{base64String}";

                    // Agregar a fotos generales del hotel
                    if (fotosGenerales.Count < 6)
                    {
                        fotosGenerales.Add(imagenUrl);
                    }

                    // Si es de la habitación recomendada, agregar a sus fotos
                    if (viewModel.HabitacionRecomendada != null &&
                        habitacionId == viewModel.HabitacionRecomendada.HabitacionID &&
                        viewModel.HabitacionRecomendada.FotosHabitacion.Count < 3)
                    {
                        viewModel.HabitacionRecomendada.FotosHabitacion.Add(imagenUrl);
                    }
                }
            }

            viewModel.FotosHotel = fotosGenerales;
        }

        [HttpGet]
        public async Task<IActionResult> Actividades(string ubicacion = "", int pagina = 1)
        {
            var viewModel = new BusquedaActividadesViewModel
            {
                Ubicacion = ubicacion,
                PaginaActual = pagina
            };

            // Cargar tipos de actividad y servicios para filtros
            viewModel.TiposActividadDisponibles = await ObtenerTiposActividad();
            viewModel.ServiciosActividadDisponibles = await ObtenerServiciosActividad();

            // Realizar búsqueda si hay criterios
            if (!string.IsNullOrEmpty(ubicacion))
            {
                await RealizarBusquedaActividades(viewModel);
            }

            return View(viewModel);
        }

        [HttpPost]
        public async Task<IActionResult> BuscarActividades(BusquedaActividadesViewModel modelo)
        {
            if (modelo == null)
            {
                return RedirectToAction("Actividades");
            }

            Console.WriteLine($"Búsqueda de actividades recibida - Ubicación: {modelo.Ubicacion}");

            modelo.TiposActividadDisponibles = await ObtenerTiposActividad();
            modelo.ServiciosActividadDisponibles = await ObtenerServiciosActividad();

            await RealizarBusquedaActividades(modelo);

            return View("Actividades", modelo);
        }

        [HttpPost]
        public async Task<IActionResult> AplicarFiltrosActividades(BusquedaActividadesViewModel modelo)
        {
            if (modelo == null)
            {
                return RedirectToAction("Actividades");
            }

            modelo.TiposActividadDisponibles = await ObtenerTiposActividad();
            modelo.ServiciosActividadDisponibles = await ObtenerServiciosActividad();
            modelo.PaginaActual = 1; // Resetear a primera página

            await RealizarBusquedaActividades(modelo);

            return View("Actividades", modelo);
        }

        private async Task RealizarBusquedaActividades(BusquedaActividadesViewModel viewModel)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                using var command = new SqlCommand("sp_BuscarActividadesAvanzado", connection)
                {
                    CommandType = CommandType.StoredProcedure,
                    CommandTimeout = 60
                };

                // Parámetros del stored procedure
                command.Parameters.AddWithValue("@Ubicacion", viewModel.Ubicacion ?? "");

                command.Parameters.AddWithValue("@PrecioMinimo",
                    viewModel.PrecioMinimo.HasValue ? viewModel.PrecioMinimo.Value : DBNull.Value);
                command.Parameters.AddWithValue("@PrecioMaximo",
                    viewModel.PrecioMaximo.HasValue ? viewModel.PrecioMaximo.Value : DBNull.Value);

                // Convertir listas a strings separados por comas
                var tiposActividadIds = viewModel.TiposActividadSeleccionados?.Any() == true
                    ? string.Join(",", viewModel.TiposActividadSeleccionados)
                    : null;
                var serviciosIds = viewModel.ServiciosActividadSeleccionados?.Any() == true
                    ? string.Join(",", viewModel.ServiciosActividadSeleccionados)
                    : null;

                command.Parameters.AddWithValue("@TipoActividadIDs", tiposActividadIds ?? (object)DBNull.Value);
                command.Parameters.AddWithValue("@ServicioActividadIDs", serviciosIds ?? (object)DBNull.Value);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                var resultados = new List<ActividadResultado>();

                while (await reader.ReadAsync())
                {
                    var actividad = new ActividadResultado
                    {
                        CedulaJuridica = reader["CedulaJuridica"]?.ToString() ?? "",
                        Nombre = reader["Nombre"]?.ToString() ?? "",
                        UbicacionCompleta = reader["UbicacionCompleta"]?.ToString() ?? "",
                        Telefono = reader["Telefono"]?.ToString() ?? "",
                        CorreoElectronico = reader["CorreoElectronico"]?.ToString() ?? "",
                        NombreContacto = reader["NombreContacto"]?.ToString() ?? "",
                        Precio = reader["Precio"] != DBNull.Value ? Convert.ToDecimal(reader["Precio"]) : 0,
                        Descripcion = reader["Descripcion"]?.ToString() ?? ""
                    };

                    resultados.Add(actividad);
                }

                // Cerrar el reader antes de hacer otras consultas
                reader.Close();

                // Enriquecer datos de actividades
                foreach (var actividad in resultados)
                {
                    await EnriquecerDatosActividad(actividad);
                }

                // Aplicar paginación
                viewModel.TotalResultados = resultados.Count;
                var inicio = (viewModel.PaginaActual - 1) * viewModel.ResultadosPorPagina;
                viewModel.Resultados = resultados.Skip(inicio)
                                                .Take(viewModel.ResultadosPorPagina)
                                                .ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error en búsqueda de actividades: {ex.Message}");
                viewModel.Resultados = new List<ActividadResultado>();
                viewModel.TotalResultados = 0;
            }
        }

        private async Task EnriquecerDatosActividad(ActividadResultado actividad)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                // Obtener tipos de actividad
                var tiposQuery = @"
            SELECT TipoActividad
            FROM ActividadesServicios AS_VIEW
            WHERE AS_VIEW.CedulaJuridica = @CedulaJuridica";

                using var tiposCommand = new SqlCommand(tiposQuery, connection);
                tiposCommand.Parameters.AddWithValue("@CedulaJuridica", actividad.CedulaJuridica);

                using var tiposReader = await tiposCommand.ExecuteReaderAsync();
                while (await tiposReader.ReadAsync())
                {
                    actividad.TiposActividad.Add(tiposReader["Nombre"]?.ToString() ?? "");
                }
                tiposReader.Close();

                // Obtener servicios adicionales
                var serviciosQuery = @"
            SELECT ServicioActividad
            FROM ActividadesServiciosAdicionales ASA_VIEW
            WHERE ASA_VIEW.CedulaJuridica = @CedulaJuridica";

                using var serviciosCommand = new SqlCommand(serviciosQuery, connection);
                serviciosCommand.Parameters.AddWithValue("@CedulaJuridica", actividad.CedulaJuridica);

                using var serviciosReader = await serviciosCommand.ExecuteReaderAsync();
                while (await serviciosReader.ReadAsync())
                {
                    actividad.ServiciosActividad.Add(serviciosReader["Nombre"]?.ToString() ?? "");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"ERROR en EnriquecerDatosActividad: {ex.Message}");
            }
        }

        private async Task<List<TipoActividad>> ObtenerTiposActividad()
        {
            var tipos = new List<TipoActividad>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                var query = "SELECT TipoActividadID, Nombre FROM TipoActividad ORDER BY Nombre";
                using var command = new SqlCommand(query, connection);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    tipos.Add(new TipoActividad
                    {
                        TipoActividadID = Convert.ToInt32(reader["TipoActividadID"]),
                        Nombre = reader["Nombre"].ToString()
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error obteniendo tipos de actividad: {ex.Message}");
            }

            return tipos;
        }

        private async Task<List<ServicioActividad>> ObtenerServiciosActividad()
        {
            var servicios = new List<ServicioActividad>();

            try
            {
                using var connection = new SqlConnection(_connectionString);
                var query = "SELECT ServicioActividadID, Nombre FROM ServicioActividad ORDER BY Nombre";
                using var command = new SqlCommand(query, connection);

                await connection.OpenAsync();
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    servicios.Add(new ServicioActividad
                    {
                        ServicioActividadID = Convert.ToInt32(reader["ServicioActividadID"]),
                        Nombre = reader["Nombre"].ToString()
                    });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error obteniendo servicios de actividad: {ex.Message}");
            }

            return servicios;
        }

        [HttpGet]
        public async Task<IActionResult> DetalleActividad(string cedulaJuridica)
        {
            if (string.IsNullOrEmpty(cedulaJuridica))
            {
                return RedirectToAction("Actividades");
            }

            try
            {
                var viewModel = await ObtenerDetallesCompletosActividad(cedulaJuridica);

                if (viewModel == null)
                {
                    TempData["Error"] = "No se encontró la actividad especificada.";
                    return RedirectToAction("Actividades");
                }

                return View(viewModel);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error obteniendo detalles de actividad: {ex.Message}");
                return RedirectToAction("Actividades");
            }
        }

        private async Task<DetalleActividadViewModel?> ObtenerDetallesCompletosActividad(string cedulaJuridica)
        {
            using var connection = new SqlConnection(_connectionString);
            using var command = new SqlCommand("sp_ObtenerDetallesActividad", connection)
            {
                CommandType = CommandType.StoredProcedure
            };

            command.Parameters.AddWithValue("@CedulaJuridica", cedulaJuridica);

            await connection.OpenAsync();
            using var reader = await command.ExecuteReaderAsync();

            DetalleActividadViewModel? viewModel = null;

            // 1. Información general de la empresa
            if (await reader.ReadAsync())
            {
                viewModel = new DetalleActividadViewModel
                {
                    CedulaJuridica = reader["CedulaJuridica"]?.ToString() ?? "",
                    NombreEmpresa = reader["Nombre"]?.ToString() ?? "",
                    UbicacionCompleta = reader["UbicacionCompleta"]?.ToString() ?? "",
                    DireccionCompleta = reader["DireccionCompleta"]?.ToString() ?? "",
                    Telefono = reader["Telefono"]?.ToString() ?? "",
                    CorreoElectronico = reader["CorreoElectronico"]?.ToString() ?? "",
                    NombreContacto = reader["NombreContacto"]?.ToString() ?? "",
                    Precio = Convert.ToDecimal(reader["Precio"]),
                    Descripcion = reader["Descripcion"]?.ToString() ?? ""
                };

                // Crear galería con la imagen por defecto repetida 5 veces
                for (int i = 0; i < 5; i++)
                {
                    viewModel.FotosActividad.Add("/ImagenesBG/bghomepage.png");
                }
            }

            // 2. Tipos de actividad
            await reader.NextResultAsync();
            if (viewModel != null)
            {
                while (await reader.ReadAsync())
                {
                    viewModel.TiposActividad.Add(new TipoActividadDetalle
                    {
                        TipoActividadID = Convert.ToInt32(reader["TipoActividadID"]),
                        Nombre = reader["TipoActividad"]?.ToString() ?? "",
                        Descripcion = reader["DescripcionTipo"]?.ToString() ?? ""
                    });
                }
            }

            // 3. Servicios incluidos
            await reader.NextResultAsync();
            if (viewModel != null)
            {
                while (await reader.ReadAsync())
                {
                    viewModel.ServiciosIncluidos.Add(reader["ServicioActividad"]?.ToString() ?? "");
                }
            }

            return viewModel;
        }
    }
}