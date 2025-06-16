namespace ProyectoSistemaHotelero.Models
{
    public class HotelServicio
    {
        public string CedulaJuridica { get; set; } = string.Empty;
        public int ServicioID { get; set; }
        
        // Propiedades de navegaci�n
        public EmpresaHotel? EmpresaHotel { get; set; }
        public Servicio? Servicio { get; set; }
    }
}