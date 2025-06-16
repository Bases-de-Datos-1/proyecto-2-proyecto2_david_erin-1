namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class RegistroActividadViewModel
    {
        public EmpresaActividad Actividad { get; set; } = new();
        public List<int> TiposActividadSeleccionados { get; set; } = new();
        public List<int> ServiciosSeleccionados { get; set; } = new();
        
        // Listas para los dropdowns
        public List<TipoActividad> TiposActividad { get; set; } = new();
        public List<ServicioActividad> ServiciosActividad { get; set; } = new();
    }
}