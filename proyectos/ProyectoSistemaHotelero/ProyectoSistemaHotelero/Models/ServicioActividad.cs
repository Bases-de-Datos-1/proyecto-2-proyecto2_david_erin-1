namespace ProyectoSistemaHotelero.Models
{
    public class ServicioActividad
    {
        public int ServicioActividadID { get; set; }
        public string Nombre { get; set; } = string.Empty;
        
        // Propiedades de navegación
        public ICollection<EmpresaActividadServicio>? EmpresasActividad { get; set; }
    }
}