namespace ProyectoSistemaHotelero.Models
{
    public class EmpresaActividadServicio
    {
        public string CedulaJuridica { get; set; } = string.Empty;
        public int ServicioActividadID { get; set; }
        
        // Propiedades de navegaci�n
        public EmpresaActividad? EmpresaActividad { get; set; }
        public ServicioActividad? ServicioActividad { get; set; }
    }
}