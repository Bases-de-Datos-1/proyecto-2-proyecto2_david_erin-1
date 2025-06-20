using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Rendering;


namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class HabitacionViewModel
    {
        [Required(ErrorMessage = "El número de habitación es requerido")]
        [Range(1, int.MaxValue, ErrorMessage = "El número debe ser mayor a 0")]
        [Display(Name = "Número")]
        public int Numero { get; set; }

        [Required(ErrorMessage = "Debe seleccionar un tipo de habitación")]
        [Display(Name = "Tipo de Habitación")]
        public int TipoHabitacionID { get; set; }

        public string CedulaJuridica { get; set; }

        // Para el dropdown
        public List<SelectListItem> TiposHabitacion { get; set; } = new List<SelectListItem>();
    }
    public class TipoHabitacionDropdownDto
    {
        public int TipoHabitacionID { get; set; }
        public string Nombre { get; set; }
        public decimal Precio { get; set; }
        public string TipoCama { get; set; }
        public int CantidadCamas { get; set; }
    }
}
