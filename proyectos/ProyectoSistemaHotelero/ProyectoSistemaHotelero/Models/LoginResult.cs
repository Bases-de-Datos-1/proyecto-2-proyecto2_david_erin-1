namespace ProyectoSistemaHotelero.Models
{
    public class LoginResult
    {
        public bool IsSuccess { get; set; }
        public string TipoLogin { get; set; } = string.Empty;
        public string ID { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? TipoUsuario { get; set; }
        public string? CedulaJuridica { get; set; }
        public string? ErrorMessage { get; set; }
    }
}