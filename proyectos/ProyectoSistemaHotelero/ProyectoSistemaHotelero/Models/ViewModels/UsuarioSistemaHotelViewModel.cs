namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class UsuarioSistemaHotelViewModel
    {
        public string Nombre { get; set; } = string.Empty;
        public string Apellido { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string Contrasenia { get; set; } = string.Empty;
        // TipoUsuario será siempre "ADMIN"
    }
}
