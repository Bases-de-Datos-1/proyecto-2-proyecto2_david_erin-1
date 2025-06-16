using System.ComponentModel.DataAnnotations;

namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class LoginViewModel
    {
        [Required(ErrorMessage = "El correo electrónico es obligatorio")]
        [EmailAddress(ErrorMessage = "Por favor ingrese un correo electrónico válido")]
        [Display(Name = "Correo electrónico")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contraseña es obligatoria")]
        [Display(Name = "Contraseña")]
        public string Password { get; set; } = string.Empty;

        [Display(Name = "Recordarme")]
        public bool RememberMe { get; set; } = false;  // False por defecto
    }
}