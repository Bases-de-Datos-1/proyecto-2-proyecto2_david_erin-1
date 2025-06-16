namespace ProyectoSistemaHotelero.Models
{
    public class EmpresaActividadTipo
    {
        public string CedulaJuridica { get; set; } = string.Empty;
        public int TipoActividadID { get; set; }
        
        // Propiedades de navegaci�n
        public EmpresaActividad? EmpresaActividad { get; set; }
        public TipoActividad? TipoActividad { get; set; }
    }
}