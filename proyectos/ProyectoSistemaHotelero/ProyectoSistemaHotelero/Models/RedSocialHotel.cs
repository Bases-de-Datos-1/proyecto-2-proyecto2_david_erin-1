namespace ProyectoSistemaHotelero.Models
{
    public class RedSocialHotel
    {
        public string NombreUsuario { get; set; } = string.Empty;
        public int RedSocialID { get; set; }
        public string CedulaJuridica { get; set; } = string.Empty;
        
        // Propiedades de navegación
        public EmpresaHotel? EmpresaHotel { get; set; }
        public RedSocial? RedSocial { get; set; }
    }
}