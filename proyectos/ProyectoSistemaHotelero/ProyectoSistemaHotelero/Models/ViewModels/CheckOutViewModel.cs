using System;
using System.ComponentModel.DataAnnotations;

namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class CheckoutViewModel
    {
        // Datos de la reserva (desde sessionStorage)
        public string CedulaJuridica { get; set; } = string.Empty;
        public int HabitacionId { get; set; }
        public int TipoHabitacionId { get; set; }
        public string NumeroHabitacion { get; set; } = string.Empty;
        public DateTime FechaCheckIn { get; set; }
        public DateTime FechaCheckOut { get; set; }
        public int CantidadPersonas { get; set; }
        public decimal PrecioTotal { get; set; }
        public decimal PrecioPorNoche { get; set; }
        public string NombreHotel { get; set; } = string.Empty;
        public string NombreHabitacion { get; set; } = string.Empty;
        public string UbicacionHotel { get; set; } = string.Empty;
        public int NochesEstadia { get; set; }

        // Datos adicionales para la reserva
        [Required(ErrorMessage = "La hora de ingreso es requerida")]
        public TimeSpan HoraIngreso { get; set; } = new TimeSpan(15, 00, 0); // 3:30 PM por defecto

        [Required(ErrorMessage = "La hora de salida es requerida")]
        public TimeSpan HoraSalida { get; set; } = new TimeSpan(12, 0, 0); // 9:00 AM por defecto

        [Required(ErrorMessage = "Debe especificar si posee vehículo")]
        public bool PoseeVehiculo { get; set; } = false;

        // Información del usuario (se llena automáticamente si está autenticado)
        public string NombreCliente { get; set; } = string.Empty;
        public string EmailCliente { get; set; } = string.Empty;
        public string CedulaCliente { get; set; } = string.Empty;

        // Lista de horas disponibles para los dropdowns
        public List<TimeOption> HorasDisponibles { get; set; } = new List<TimeOption>();
    }

    public class TimeOption
    {
        public string Value { get; set; } = string.Empty; // "15:30"
        public string Text { get; set; } = string.Empty;  // "3:30 PM"
    }
}