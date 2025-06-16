namespace ProyectoSistemaHotelero.Models
{
    public class EmpresaActividadTipo
    {
        public string CedulaJuridica { get; set; } = string.Empty;
        public int TipoActividadID { get; set; }
        
        // Propiedades de navegación
        public EmpresaActividad? EmpresaActividad { get; set; }
        public TipoActividad? TipoActividad { get; set; }
    }
}