using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class HabitacionListViewModel
    {
        public int HabitacionID { get; set; }
        public int Numero { get; set; }
        public string TipoHabitacion { get; set; } = string.Empty;
        public int PrecioPorNoche { get; set; }
        public int TotalReservas { get; set; }
        public int ReservasActivas { get; set; }
        public bool PuedeEliminar { get; set; }
    }

    public class HabitacionEditViewModel
    {
        public int HabitacionID { get; set; }

        [Required(ErrorMessage = "El número de habitación es requerido")]
        [Range(1, int.MaxValue, ErrorMessage = "El número debe ser mayor a 0")]
        [Display(Name = "Número")]
        public int Numero { get; set; }

        [Required(ErrorMessage = "Debe seleccionar un tipo de habitación")]
        [Display(Name = "Tipo de Habitación")]
        public int TipoHabitacionID { get; set; }

        public string CedulaJuridica { get; set; } = string.Empty;

        // Para el dropdown
        public List<SelectListItem> TiposHabitacion { get; set; } = new List<SelectListItem>();
    }

    public class TipoHabitacionListViewModel
    {
        public int TipoHabitacionID { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public int PrecioPorNoche { get; set; }
        public int TotalHabitaciones { get; set; }
        public int TotalReservas { get; set; }
        public bool PuedeEliminar { get; set; }
    }

    public class TipoHabitacionEditViewModel
    {
        public int TipoHabitacionID { get; set; }

        [Required(ErrorMessage = "El nombre es requerido")]
        [StringLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
        [Display(Name = "Nombre")]
        public string Nombre { get; set; } = string.Empty;

        [Required(ErrorMessage = "La descripción es requerida")]
        [StringLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
        [Display(Name = "Descripción")]
        public string Descripcion { get; set; } = string.Empty;

        [Required(ErrorMessage = "El precio por noche es requerido")]
        [Range(0.01, 999999.99, ErrorMessage = "El precio debe ser mayor a 0")]
        [Display(Name = "Precio por Noche")]
        public decimal PrecioPorNoche { get; set; }

        [Required(ErrorMessage = "La capacidad máxima es requerida")]
        [Range(1, 20, ErrorMessage = "La capacidad debe estar entre 1 y 20 personas")]
        [Display(Name = "Capacidad Máxima")]
        public int CapacidadMaxima { get; set; }

        public string CedulaJuridica { get; set; } = string.Empty;
    }
}
