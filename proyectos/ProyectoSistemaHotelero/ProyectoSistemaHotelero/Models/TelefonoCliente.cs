namespace ProyectoSistemaHotelero.Models
{
    public class TelefonoCliente
    {
        public int TelefonoCID { get; set; }
        public string CedulaID { get; set; } = string.Empty;
        public string Numero { get; set; } = string.Empty;
        public string CodigoPais { get; set; } = string.Empty;

        // Propiedad de navegaci�n
        public Cliente? Cliente { get; set; }
    }
}