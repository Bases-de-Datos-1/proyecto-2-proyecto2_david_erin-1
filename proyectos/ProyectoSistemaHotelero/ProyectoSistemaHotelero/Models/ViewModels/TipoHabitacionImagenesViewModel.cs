namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class TipoHabitacionImagenesViewModel
    {
        public TipoHabitacionViewModel TipoHabitacion { get; set; }
        public List<int> ComodidadesSeleccionadas { get; set; } = new();
        public List<string> ImagenesCargadas { get; set; } = new();
    }
}