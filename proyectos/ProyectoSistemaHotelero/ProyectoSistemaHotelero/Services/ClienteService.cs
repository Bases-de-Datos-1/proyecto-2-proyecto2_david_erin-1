using Microsoft.Data.SqlClient;
using System.Data;
using ProyectoSistemaHotelero.Models;
using ProyectoSistemaHotelero.Models.ViewModels;

namespace ProyectoSistemaHotelero.Services
{
    public class ClienteService
    {
        private readonly string _connectionString;

        public ClienteService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public async Task<List<PaisResidencia>> GetPaisesResidenciaAsync()
        {
            var paises = new List<PaisResidencia>();
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using var command = new SqlCommand("SELECT PaisResidenciaID, NombrePais FROM PaisResidencia", connection);
                using var reader = await command.ExecuteReaderAsync();
                
                while (await reader.ReadAsync())
                {
                    paises.Add(new PaisResidencia
                    {
                        PaisResidenciaID = reader.GetInt32(0),
                        NombrePais = reader.GetString(1)
                    });
                }
            }
            
            return paises;
        }

        public async Task<bool> RegisterClienteAsync(RegistroClienteViewModel model)
        {
            using var connection = new SqlConnection(_connectionString);
            await connection.OpenAsync();
            
            // Comenzar una transacción
            using var transaction = connection.BeginTransaction();
            
            try
            {
                // Registrar el cliente
                using (var command = new SqlCommand("sp_InsertarCliente", connection, transaction))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@CedulaID", model.Cliente.CedulaID);
                    command.Parameters.AddWithValue("@Nombre", model.Cliente.Nombre);
                    command.Parameters.AddWithValue("@PrimerApellido", model.Cliente.PrimerApellido);
                    command.Parameters.AddWithValue("@SegundoApellido", model.Cliente.SegundoApellido);
                    command.Parameters.AddWithValue("@FechaNacimiento", model.Cliente.FechaNacimiento);
                    command.Parameters.AddWithValue("@TipoIdentificacion", model.Cliente.TipoIdentificacion);
                    command.Parameters.AddWithValue("@PaisResidenciaID", model.Cliente.PaisResidenciaID);
                    command.Parameters.AddWithValue("@Provincia", model.Cliente.Provincia ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@Canton", model.Cliente.Canton ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@Distrito", model.Cliente.Distrito ?? (object)DBNull.Value);
                    command.Parameters.AddWithValue("@CorreoElectronico", model.Cliente.CorreoElectronico);
                    command.Parameters.AddWithValue("@EsCostaRica", model.Cliente.EsCostaRica);
                    command.Parameters.AddWithValue("@Contrasenia", model.Cliente.Contrasenia);
                    
                    await command.ExecuteNonQueryAsync();
                }
                
                // Registrar teléfonos
                foreach (var telefono in model.Telefonos.Where(t => !string.IsNullOrEmpty(t.Numero)))
                {
                    using var command = new SqlCommand("sp_InsertarTelefonoCliente", connection, transaction);
                    command.CommandType = CommandType.StoredProcedure;
                    
                    command.Parameters.AddWithValue("@CedulaID", model.Cliente.CedulaID);
                    command.Parameters.AddWithValue("@Numero", telefono.Numero);
                    command.Parameters.AddWithValue("@CodigoPais", telefono.CodigoPais);
                    
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