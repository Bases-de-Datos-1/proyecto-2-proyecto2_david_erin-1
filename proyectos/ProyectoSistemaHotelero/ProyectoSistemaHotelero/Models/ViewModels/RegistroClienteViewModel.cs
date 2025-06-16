namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class RegistroClienteViewModel
    {
        public Cliente Cliente { get; set; } = new Cliente();
        public List<TelefonoClienteViewModel> Telefonos { get; set; } = new List<TelefonoClienteViewModel>();
        public List<PaisResidencia> PaisesDisponibles { get; set; } = new List<PaisResidencia>();
    }

    public class TelefonoClienteViewModel
    {
        public string Numero { get; set; } = string.Empty;
        public string CodigoPais { get; set; } = string.Empty;
    }
}