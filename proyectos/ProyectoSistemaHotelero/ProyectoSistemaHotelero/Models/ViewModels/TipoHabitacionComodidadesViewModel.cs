namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class TipoHabitacionComodidadesViewModel
    {
        public TipoHabitacionViewModel TipoHabitacion { get; set; }
        public List<Comodidad> Comodidades { get; set; } = new();
        public List<int> ComodidadesSeleccionadas { get; set; } = new();
    }
}