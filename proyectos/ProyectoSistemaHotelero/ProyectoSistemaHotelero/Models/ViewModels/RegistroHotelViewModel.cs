using System.Collections.Generic;

namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class RegistroHotelViewModel
    {
        public EmpresaHotel Hotel { get; set; } = new();
        public List<int> ServiciosSeleccionados { get; set; } = new();
        public List<TelefonoViewModel> Telefonos { get; set; } = new();
        public List<RedSocialViewModel> RedesSociales { get; set; } = new();
        public UsuarioSistemaHotelViewModel Usuario { get; set; } = new();
        
        // Listas para los dropdowns
        public List<TipoHotel> TiposHotel { get; set; } = new();
        public List<Servicio> Servicios { get; set; } = new();
        public List<RedSocial> RedesSocialesDisponibles { get; set; } = new();
    }
    
    public class TelefonoViewModel
    {
        public string Numero { get; set; } = string.Empty;
        public string CodigoPais { get; set; } = string.Empty;
    }
    
    public class RedSocialViewModel
    {
        public int RedSocialID { get; set; }
        public string NombreUsuario { get; set; } = string.Empty;
    }
}