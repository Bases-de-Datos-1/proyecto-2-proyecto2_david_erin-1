namespace ProyectoSistemaHotelero.Models
{
    public class TipoActividad
    {
        public int TipoActividadID { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        
        // Propiedades de navegación
        public ICollection<EmpresaActividadTipo>? EmpresasActividad { get; set; }
    }
}