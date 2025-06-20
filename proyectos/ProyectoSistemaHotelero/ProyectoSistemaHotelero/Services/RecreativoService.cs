using Microsoft.Data.SqlClient;
using System.Data;
using ProyectoSistemaHotelero.Models;
using ProyectoSistemaHotelero.Models.ViewModels;

namespace ProyectoSistemaHotelero.Services
{
    public class RecreativoService
    {
        private readonly string _connectionString;

        public RecreativoService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public async Task<List<TipoActividad>> GetTiposActividadAsync()
        {
            var tiposActividad = new List<TipoActividad>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand("SELECT TipoActividadID, Nombre, Descripcion FROM TipoActividad", connection);
                using var reader = await command.ExecuteReaderAsync();
                
                while (await reader.ReadAsync())
                {
                    tiposActividad.Add(new TipoActividad
                    {
                        TipoActividadID = reader.GetInt32(0),
                        Nombre = reader.GetString(1),
                        Descripcion = reader.GetString(2)
                    });
                }
            }
            
            return tiposActividad;
        }

        public async Task<List<ServicioActividad>> GetServiciosActividadAsync()
        {
            var serviciosActividad = new List<ServicioActividad>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand("SELECT ServicioActividadID, Nombre FROM ServicioActividad", connection);
                using var reader = await command.ExecuteReaderAsync();
                
                while (await reader.ReadAsync())
                {
                    serviciosActividad.Add(new ServicioActividad
                    {
                        ServicioActividadID = reader.GetInt32(0),
                        Nombre = reader.GetString(1)
                    });
                }
            }
            
            return serviciosActividad;
        }

        public async Task<bool> RegisterActividadAsync(RegistroActividadViewModel model)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            
            // Comenzar una transacción
            using var transaction = connection.BeginTransaction();
            
            try
            {
                // Registrar la empresa de actividad
                using (var command = new SqlCommand("sp_InsertarEmpresaActividad", connection, transaction))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Actividad.CedulaJuridica);
                    command.Parameters.AddWithValue("@Nombre", model.Actividad.Nombre);
                    command.Parameters.AddWithValue("@CorreoElectronico", model.Actividad.CorreoElectronico);
                    command.Parameters.AddWithValue("@Telefono", model.Actividad.Telefono);
                    command.Parameters.AddWithValue("@NombreContacto", model.Actividad.NombreContacto);
                    command.Parameters.AddWithValue("@Provincia", model.Actividad.Provincia);
                    command.Parameters.AddWithValue("@Canton", model.Actividad.Canton);
                    command.Parameters.AddWithValue("@Distrito", model.Actividad.Distrito);
                    command.Parameters.AddWithValue("@SeniasExactas", model.Actividad.SeniasExactas);
                    command.Parameters.AddWithValue("@Precio", model.Actividad.Precio);
                    command.Parameters.AddWithValue("@Descripcion", model.Actividad.Descripcion);
                    
                    await command.ExecuteNonQueryAsync();
                }
                
                // Registrar tipos de actividad
                foreach (var tipoActividadId in model.TiposActividadSeleccionados)
                {
                    using var command = new SqlCommand("sp_AsignarTipoActividadAEmpresa", connection, transaction);
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Actividad.CedulaJuridica);
                    command.Parameters.AddWithValue("@TipoActividadID", tipoActividadId);
                    
                    await command.ExecuteNonQueryAsync();
                }
                
                // Registrar servicios
                foreach (var servicioId in model.ServiciosSeleccionados)
                {
                    using var command = new SqlCommand("sp_AsignarServicioActividadAEmpresa", connection, transaction);
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Actividad.CedulaJuridica);
                    command.Parameters.AddWithValue("@ServicioActividadID", servicioId);
                    
                    await command.ExecuteNonQueryAsync();
                }
                
                // Registrar usuario administrador
                if (model.Usuario != null && !string.IsNullOrEmpty(model.Usuario.Email))
                {
                    using var command = new SqlCommand("sp_InsertarUsuarioSistemaRecreativo", connection, transaction);
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@Nombre", model.Usuario.Nombre);
                    command.Parameters.AddWithValue("@Apellido", model.Usuario.Apellido);
                    command.Parameters.AddWithValue("@Email", model.Usuario.Email);
                    command.Parameters.AddWithValue("@Contrasenia", model.Usuario.Contrasenia);
                    command.Parameters.AddWithValue("@TipoUsuario", "ADMIN");
                    command.Parameters.AddWithValue("@CedulaJuridica", model.Actividad.CedulaJuridica);
                    
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

        public EmpresaActividad GetActividadByCedulaJuridica(string cedulaJuridica)
        {
            EmpresaActividad actividad = null;
            
            try
            {
                using (var connection = new SqlConnection(_connectionString))
                {
                    connection.Open();
                    using var command = new SqlCommand("sp_ObtenerActividadPorCedulaJuridica", connection);
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@CedulaJuridica", cedulaJuridica);
                    
                    using var reader = command.ExecuteReader();
                    
                    if (reader.Read())
                    {
                        actividad = new EmpresaActividad
                        {
                            CedulaJuridica = reader["CedulaJuridica"].ToString(),
                            Nombre = reader["Nombre"].ToString(),
                            CorreoElectronico = reader["CorreoElectronico"].ToString(),
                            // Añadir más campos según sea necesario
                        };
                    }
                }
            }
            catch (Exception ex)
            {
                // Log del error
                Console.WriteLine($"Error al obtener actividad: {ex.Message}");
            }
            
            return actividad;
        }
    }
}