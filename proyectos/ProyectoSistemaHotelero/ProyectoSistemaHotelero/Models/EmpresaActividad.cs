namespace ProyectoSistemaHotelero.Models
{
    public class EmpresaActividad
    {
        public string CedulaJuridica { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string CorreoElectronico { get; set; } = string.Empty;
        public string Telefono { get; set; } = string.Empty;
        public string NombreContacto { get; set; } = string.Empty;
        public string Provincia { get; set; } = string.Empty;
        public string Canton { get; set; } = string.Empty;
        public string Distrito { get; set; } = string.Empty;
        public string SeniasExactas { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        
        // Propiedades de navegación
        public ICollection<EmpresaActividadTipo>? TiposActividad { get; set; }
        public ICollection<EmpresaActividadServicio>? Servicios { get; set; }
    }
}