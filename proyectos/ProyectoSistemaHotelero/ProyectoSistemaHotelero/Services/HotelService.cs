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

        public async Task<bool> RegisterHotelAsync(RegistroHotelViewModel model)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            
            // Comenzar una transacción
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
                
                // Registrar teléfonos
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
                    command.Parameters.AddWithValue("@Contrasenia", model.Usuario.Contrasenia); // Idealmente debería cifrarse
                    command.Parameters.AddWithValue("@TipoUsuario", "ADMIN");
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Hotel.CedulaJuridica);
                    
                    await command.ExecuteNonQueryAsync();
                }
                
                // Confirmar la transacción
                transaction.Commit();
                return true;
            }
            catch (Exception)
            {
                // Revertir la transacción en caso de error
                transaction.Rollback();
                throw;
            }
        }
    }
}