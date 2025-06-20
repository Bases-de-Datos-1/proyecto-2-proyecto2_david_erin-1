using Microsoft.Data.SqlClient;
using System.Data;
using ProyectoSistemaHotelero.Models;
using ProyectoSistemaHotelero.Models.ViewModels;
using Microsoft.EntityFrameworkCore.Query;

namespace ProyectoSistemaHotelero.Services
{
    public class HotelService
    {
        private readonly string _connectionString;

        public HotelService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public async Task<List<TipoHotel>> GetTiposHotelAsync()
        {
            var tiposHotel = new List<TipoHotel>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand("SELECT TipoHotelID, Nombre FROM TipoHotel", connection);
                using var reader = await command.ExecuteReaderAsync();
                
                while (await reader.ReadAsync())
                {
                    tiposHotel.Add(new TipoHotel
                    {
                        TipoHotelID = reader.GetInt32(0),
                        Nombre = reader.GetString(1)
                    });
                }
            }
            System.Console.WriteLine(tiposHotel);
            return tiposHotel;
        }

        public async Task<List<Servicio>> GetServiciosAsync()
        {
            var servicios = new List<Servicio>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand("SELECT ServicioID, Nombre FROM Servicios", connection);
                using var reader = await command.ExecuteReaderAsync();
                
                while (await reader.ReadAsync())
                {
                    servicios.Add(new Servicio
                    {
                        ServicioID = reader.GetInt32(0),
                        Nombre = reader.GetString(1)
                    });
                }
            }
            
            return servicios;
        }

        public async Task<List<RedSocial>> GetRedesSocialesAsync()
        {
            var redesSociales = new List<RedSocial>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand("SELECT RedSocialID, Nombre FROM RedSocial", connection);
                using var reader = await command.ExecuteReaderAsync();
                
                while (await reader.ReadAsync())
                {
                    redesSociales.Add(new RedSocial
                    {
                        RedSocialID = reader.GetInt32(0),
                        Nombre = reader.GetString(1)
                    });
                }
            }
            
            return redesSociales;
        }

        public async Task<List<TipoCama>> GetTiposCamaAsync()
        {
            var tiposCama = new List<TipoCama>();

            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand("SELECT TipoCamaID, Nombre FROM TipoCama", connection);
                using var reader = await command.ExecuteReaderAsync();

                while (await reader.ReadAsync())
                {
                    tiposCama.Add(new TipoCama
                    {
                        TipoCamaID = reader.GetInt32(0),
                        Nombre = reader.GetString(1)
                    });
                }
            }

            return tiposCama;
        }

        public async Task<List<Comodidad>> GetComodidadesAsync()
        {
            var comodidades = new List<Comodidad>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand("SELECT ComodidadID, Nombre FROM Comodidades", connection);
                using var reader = await command.ExecuteReaderAsync();
                
                while (await reader.ReadAsync())
                {
                    comodidades.Add(new Comodidad
                    {
                        ComodidadID = reader.GetInt32(0),
                        Nombre = reader.GetString(1)
                    });
                }
            }
            
            return comodidades;
        }

        public async Task<List<TipoHabitacionDropdownDto>> GetTiposHabitacionPorHotelAsync(string cedulaJuridica)
        {
            var tiposHabitacion = new List<TipoHabitacionDropdownDto>();

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();

            using var command = new SqlCommand("sp_GetTiposHabitacionPorHotel", connection);
            command.CommandType = CommandType.StoredProcedure;
            command.Parameters.AddWithValue("@CedulaJuridica", cedulaJuridica);

            using var reader = await command.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                tiposHabitacion.Add(new TipoHabitacionDropdownDto
                {
                    TipoHabitacionID = reader.GetInt32("TipoHabitacionID"),
                    Nombre = reader.GetString("Nombre"),
                    Precio = reader.GetDecimal("Precio"),
                    TipoCama = reader.GetString("TipoCama"),
                    CantidadCamas = reader.GetInt32("CantidadCamas")
                });
            }

            return tiposHabitacion;
        }

        public async Task<bool> RegisterHotelAsync(RegistroHotelViewModel model)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            
            // Comenzar una transacci�n
            using var transaction = connection.BeginTransaction();
            
            try
            {
                // Registrar el hotel
                using (var command = new SqlCommand("sp_InsertarEmpresaHotel", connection, transaction))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Hotel.CedulaJuridica);
                    command.Parameters.AddWithValue("@Nombre", model.Hotel.Nombre);
                    command.Parameters.AddWithValue("@TipoHotelID", model.Hotel.TipoHotelID);
                    command.Parameters.AddWithValue("@Provincia", model.Hotel.Provincia);
                    command.Parameters.AddWithValue("@Canton", model.Hotel.Canton);
                    command.Parameters.AddWithValue("@Distrito", model.Hotel.Distrito);
                    command.Parameters.AddWithValue("@Barrio", model.Hotel.Barrio);
                    command.Parameters.AddWithValue("@SeniasExactas", model.Hotel.SeniasExactas);
                    command.Parameters.AddWithValue("@ReferenciaGPS", model.Hotel.ReferenciaGPS ?? string.Empty);
                    command.Parameters.AddWithValue("@CorreoElectronico", model.Hotel.CorreoElectronico);
                    command.Parameters.AddWithValue("@URLSitioWeb", (object)model.Hotel.URLSitioWeb ?? DBNull.Value);
                    
                    await command.ExecuteNonQueryAsync();
                }
                
                // Registrar tel�fonos
                foreach (var telefono in model.Telefonos.Where(t => !string.IsNullOrEmpty(t.Numero)))
                {
                    using var command = new SqlCommand("sp_InsertarTelefonoEmpresa", connection, transaction);
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@Numero", $"{telefono.CodigoPais}{telefono.Numero}");
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Hotel.CedulaJuridica);
                    
                    await command.ExecuteNonQueryAsync();
                }
                
                // Registrar servicios
                foreach (var servicioId in model.ServiciosSeleccionados)
                {
                    using var command = new SqlCommand("sp_AsignarServicioAHotel", connection, transaction);
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Hotel.CedulaJuridica);
                    command.Parameters.AddWithValue("@ServicioID", servicioId);
                    
                    await command.ExecuteNonQueryAsync();
                }
                
                // Registrar redes sociales
                foreach (var redSocial in model.RedesSociales.Where(r => !string.IsNullOrEmpty(r.NombreUsuario)))
                {
                    using var command = new SqlCommand("sp_AsignarRedSocialAHotel", connection, transaction);
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@NombreUsuario", redSocial.NombreUsuario);
                    command.Parameters.AddWithValue("@RedSocialID", redSocial.RedSocialID);
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Hotel.CedulaJuridica);
                    
                    await command.ExecuteNonQueryAsync();
                }

                // Registrar usuario administrador
                if (model.Usuario != null && !string.IsNullOrEmpty(model.Usuario.Email))
                {
                    using var command = new SqlCommand("sp_InsertarUsuarioSistemaHotel", connection, transaction);
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@Nombre", model.Usuario.Nombre);
                    command.Parameters.AddWithValue("@Apellido", model.Usuario.Apellido);
                    command.Parameters.AddWithValue("@Email", model.Usuario.Email);
                    command.Parameters.AddWithValue("@Contrasenia", model.Usuario.Contrasenia); // Idealmente deber�a cifrarse
                    command.Parameters.AddWithValue("@TipoUsuario", "ADMIN");
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Hotel.CedulaJuridica);
                    
                    await command.ExecuteNonQueryAsync();
                }
                
                // Confirmar la transacci�n
                transaction.Commit();
                return true;
            }
            catch (Exception)
            {
                // Revertir la transacci�n en caso de error
                transaction.Rollback();
                throw;
            }
        }

        public EmpresaHotel GetHotelByCedulaJuridica(string cedulaJuridica)
        {
            EmpresaHotel hotel = null;
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    using var command = new SqlCommand("sp_ObtenerHotelPorCedulaJuridica", connection);
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@CedulaJuridica", cedulaJuridica);
                    
                    using var reader = command.ExecuteReader();
                    
                    if (reader.Read())
                    {
                        hotel = new EmpresaHotel
                        {
                            CedulaJuridica = reader["CedulaJuridica"].ToString(),
                            Nombre = reader["Nombre"].ToString(),
                            TipoHotelID = Convert.ToInt32(reader["TipoHotelID"]),
                            CorreoElectronico = reader["CorreoElectronico"].ToString(),
                            // A�adir m�s campos seg�n sea necesario
                        };
                    }
                }
            }
            catch (Exception ex)
            {
                // Log del error
                Console.WriteLine($"Error al obtener hotel: {ex.Message}");
            }
            
            return hotel;
        }

        public async Task<bool> AddTipoHabitacionCompleto(TipoHabitacionViewModel tipoHabitacion,
                                        List<int> comodidadesSeleccionadas,
                                        List<IFormFile> imagenes)
        {
            Console.WriteLine($"Iniciando AddTipoHabitacionCompleto...");
            Console.WriteLine($"Tipo: {tipoHabitacion?.Nombre}, Comodidades: {comodidadesSeleccionadas?.Count}, Im�genes: {imagenes?.Count}");

            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            Console.WriteLine("Conexi�n abierta");

            // Comenzar una transacci�n
            using var transaction = connection.BeginTransaction();
            try
            {
                // 1. Insertar el tipo de habitaci�n
                int tipoHabitacionID;
                Console.WriteLine("Insertando tipo de habitaci�n...");

                using (var command = new SqlCommand("sp_InsertarTipoHabitacion", connection, transaction))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Nombre", tipoHabitacion.Nombre);
                    command.Parameters.AddWithValue("@Descripcion", tipoHabitacion.Descripcion);
                    command.Parameters.AddWithValue("@Precio", tipoHabitacion.Precio);
                    command.Parameters.AddWithValue("@CedulaJuridica", tipoHabitacion.CedulaJuridica);
                    command.Parameters.AddWithValue("@TipoCamaID", tipoHabitacion.TipoCamaID);
                    command.Parameters.AddWithValue("@Cantidad", tipoHabitacion.CantidadCamas);

                    // Par�metro de salida para obtener el ID generado
                    var outputParameter = command.Parameters.Add("@ID", SqlDbType.Int);
                    outputParameter.Direction = ParameterDirection.Output;

                    await command.ExecuteNonQueryAsync();
                    tipoHabitacionID = (int)outputParameter.Value;
                    Console.WriteLine($"Tipo habitaci�n insertado con ID: {tipoHabitacionID}");
                }

                // 2. Asignar comodidades
                Console.WriteLine($"Asignando {comodidadesSeleccionadas.Count} comodidades...");
                foreach (var comodidadID in comodidadesSeleccionadas)
                {
                    using var command = new SqlCommand("sp_AsignarComodidadATipoHabitacion", connection, transaction);
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TipoHabitacionID", tipoHabitacionID);
                    command.Parameters.AddWithValue("@ComodidadID", comodidadID);
                    await command.ExecuteNonQueryAsync();
                    Console.WriteLine($"Comodidad {comodidadID} asignada");
                }

                // 3. Guardar im�genes
                Console.WriteLine($"Guardando {imagenes.Count} im�genes...");
                int imagenesGuardadas = 0;

                foreach (var imagen in imagenes)
                {
                    if (imagen.Length > 0)
                    {
                        Console.WriteLine($"Procesando imagen: {imagen.FileName}, Tama�o: {imagen.Length} bytes");

                        using var memoryStream = new MemoryStream();
                        await imagen.CopyToAsync(memoryStream);
                        byte[] imageData = memoryStream.ToArray();

                        using var command = new SqlCommand("sp_InsertarFotoHabitacion", connection, transaction);
                        command.CommandType = CommandType.StoredProcedure;
                        command.Parameters.AddWithValue("@Fotos", imageData);
                        command.Parameters.AddWithValue("@TipoHabitacionID", tipoHabitacionID);
                        await command.ExecuteNonQueryAsync();

                        imagenesGuardadas++;
                        Console.WriteLine($"Imagen {imagenesGuardadas} guardada exitosamente");
                    }
                }

                // Confirmar la transacci�n
                transaction.Commit();
                Console.WriteLine($"Transacci�n confirmada. Total im�genes guardadas: {imagenesGuardadas}");
                return true;
            }
            catch (Exception ex)
            {
                // Registrar el error
                Console.WriteLine($"Error al guardar el tipo de habitaci�n: {ex.Message}");
                Console.WriteLine($"StackTrace: {ex.StackTrace}");

                // Revertir la transacci�n en caso de error
                transaction.Rollback();
                Console.WriteLine("Transacci�n revertida");
                return false;
            }
        }

        public async Task<(bool Success, string ErrorMessage)> AgregarHabitacionAsync(HabitacionViewModel model)
        {
            try
            {
                using var connection = new SqlConnection(_connectionString);
                await connection.OpenAsync();

                using var command = new SqlCommand("sp_InsertarHabitacion", connection);
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@Numero", model.Numero);
                command.Parameters.AddWithValue("@CedulaJuridica", model.CedulaJuridica);
                command.Parameters.AddWithValue("@TipoHabitacionID", model.TipoHabitacionID);

                var outputParameter = command.Parameters.Add("@HabitacionID", SqlDbType.Int);
                outputParameter.Direction = ParameterDirection.Output;

                await command.ExecuteNonQueryAsync();

                var habitacionID = (int)outputParameter.Value;
                Console.WriteLine($"Habitaci�n creada con ID: {habitacionID}");

                return (true, null);
            }
            catch (SqlException ex)
            {
                Console.WriteLine($"Error SQL al agregar habitaci�n: {ex.Message}");
                return (false, ex.Message);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al agregar habitaci�n: {ex.Message}");
                return (false, "Ha ocurrido un error inesperado al agregar la habitaci�n.");
            }
        }
    }
}
