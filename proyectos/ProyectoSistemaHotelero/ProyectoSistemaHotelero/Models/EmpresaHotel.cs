
using ProyectoSistemaHotelero.Models;

namespace ProyectoSistemaHotelero.Models
{
    public class EmpresaHotel
    {
        public string CedulaJuridica { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public int TipoHotelID { get; set; }
        public string Provincia { get; set; } = string.Empty;
        public string Canton { get; set; } = string.Empty;
        public string Distrito { get; set; } = string.Empty;
        public string Barrio { get; set; } = string.Empty;
        public string SeniasExactas { get; set; } = string.Empty;
        public string ReferenciaGPS { get; set; } = string.Empty;
        public string CorreoElectronico { get; set; } = string.Empty;
        public string? URLSitioWeb { get; set; }
        
        // Propiedades de navegación
        public TipoHotel? TipoHotel { get; set; }
        public ICollection<TelefonoEmpresa>? Telefonos { get; set; }
        public ICollection<RedSocialHotel>? RedesSociales { get; set; }
        public ICollection<HotelServicio>? Servicios { get; set; }
    }
}