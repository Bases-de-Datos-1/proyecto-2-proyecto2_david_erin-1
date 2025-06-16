using System.ComponentModel.DataAnnotations;

namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class LoginViewModel
    {
        [Required(ErrorMessage = "El correo electr�nico es obligatorio")]
        [EmailAddress(ErrorMessage = "Por favor ingrese un correo electr�nico v�lido")]
        [Display(Name = "Correo electr�nico")]
        public string Email { get; set; } = string.Empty;

        [Required(ErrorMessage = "La contrase�a es obligatoria")]
        [Display(Name = "Contrase�a")]
        public string Password { get; set; } = string.Empty;

        [Display(Name = "Recordarme")]
        public bool RememberMe { get; set; } = false;  // False por defecto
    }
}