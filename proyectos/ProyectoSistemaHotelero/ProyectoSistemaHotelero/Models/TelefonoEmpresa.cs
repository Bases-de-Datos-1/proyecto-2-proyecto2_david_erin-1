namespace ProyectoSistemaHotelero.Models
{
    public class TelefonoEmpresa
    {
        public int TelefonoID { get; set; }
        public string Numero { get; set; } = string.Empty;
        public string CedulaJuridica { get; set; } = string.Empty;
        
        // Propiedad de navegaci�n
        public EmpresaHotel? EmpresaHotel { get; set; }
    }
}