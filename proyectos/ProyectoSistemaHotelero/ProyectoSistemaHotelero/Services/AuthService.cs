using Microsoft.Data.SqlClient;
using System.Data;
using ProyectoSistemaHotelero.Models;

namespace ProyectoSistemaHotelero.Services
{
    public class AuthService
    {
        private readonly string _connectionString;

        public AuthService(IConfiguration configuration)
        {
            _connectionString = configuration.GetConnectionString("DefaultConnection");
        }

        public async Task<LoginResult> AuthenticateUserAsync(string email, string password)
        {
            var result = new LoginResult { IsSuccess = false };
            
            using (var connection = new SqlConnection(_connectionString))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("sp_LoginGeneral", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@Email", email);
                    command.Parameters.AddWithValue("@Contrasenia", password);

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        if (await reader.ReadAsync())
                        {
                            string tipoLogin = reader.GetString(reader.GetOrdinal("TipoLogin"));
                            
                            if (tipoLogin != "INVALID")
                            {
                                result.IsSuccess = true;
                                result.TipoLogin = tipoLogin;
                                
                                // Detectar el tipo de la columna ID y convertir según corresponda
                                var idOrdinal = reader.GetOrdinal("ID");
                                if (!reader.IsDBNull(idOrdinal))
                                {
                                    // Si es un entero, convertirlo a string
                                    if (reader.GetFieldType(idOrdinal) == typeof(int) || 
                                        reader.GetFieldType(idOrdinal) == typeof(Int32))
                                    {
                                        result.ID = reader.GetInt32(idOrdinal).ToString();
                                    }
                                    else
                                    {
                                        // Si ya es un string, obtenerlo directamente
                                        result.ID = reader.GetString(idOrdinal);
                                    }
                                }
                                
                                result.Nombre = reader.GetString(reader.GetOrdinal("Nombre"));
                                
                                // Comprobar qué campo de correo electrónico existe
                                int emailColumnIndex;
                                try 
                                {
                                    emailColumnIndex = reader.GetOrdinal("CorreoElectronico");
                                }
                                catch 
                                {
                                    try 
                                    {
                                        emailColumnIndex = reader.GetOrdinal("Email");  
                                    }
                                    catch
                                    {
                                        // Si no existe ninguno de los dos, usar el email proporcionado en el login
                                        emailColumnIndex = -1;
                                    }
                                }

                                result.Email = emailColumnIndex >= 0 ? reader.GetString(emailColumnIndex) : email;
                                
                                if (tipoLogin != "CLIENTE" && !reader.IsDBNull(reader.GetOrdinal("TipoUsuario")))
                                {
                                    result.TipoUsuario = reader.GetString(reader.GetOrdinal("TipoUsuario"));
                                }
                                
                                try 
                                {
                                    var cedulaIndex = reader.GetOrdinal("CedulaJuridica");
                                    if (!reader.IsDBNull(cedulaIndex))
                                    {
                                        result.CedulaJuridica = reader.GetString(cedulaIndex);
                                    }
                                }
                                catch 
                                {
                                    // Si no existe el campo, no hacemos nada
                                }
                            }
                            else
                            {
                                result.ErrorMessage = "Credenciales incorrectas. Por favor intente de nuevo.";
                            }
                        }
                        else
                        {
                            result.ErrorMessage = "No se encontró información de usuario.";
                        }
                    }
                }
            }
            
            return result;
        }
    }
}