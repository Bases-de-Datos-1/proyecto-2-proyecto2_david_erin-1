using System;
using System.Collections.Generic;

namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class ConfirmacionReservaViewModel
    {
        // Información de la reserva
        public int ReservacionId { get; set; }
        public string NumeroReservacion { get; set; } = string.Empty; // Formato: #1542
        public DateTime FechaReserva { get; set; }
        public string Estado { get; set; } = string.Empty;

        // Información del hotel
        public string NombreHotel { get; set; } = string.Empty;
        public string UbicacionHotel { get; set; } = string.Empty;
        public string ImagenHotel { get; set; } = string.Empty;

        // Información de la habitación
        public string TipoHabitacion { get; set; } = string.Empty;
        public string NumeroHabitacion { get; set; } = string.Empty;
        public decimal PrecioPorNoche { get; set; }
        public decimal PrecioTotal { get; set; }

        // Fechas de estadía
        public DateTime FechaCheckIn { get; set; }
        public DateTime FechaCheckOut { get; set; }
        public TimeSpan HoraIngreso { get; set; }
        public TimeSpan HoraSalida { get; set; }
        public int NochesEstadia { get; set; }
        public int CantidadPersonas { get; set; }

        // Servicios incluidos
        public List<string> ServiciosIncluidos { get; set; } = new List<string>();

        // Información adicional
        public bool PoseeVehiculo { get; set; }

        // Información del cliente
        public string NombreCliente { get; set; } = string.Empty;
        public string EmailCliente { get; set; } = string.Empty;
        public string TelefonoCliente { get; set; } = string.Empty;

        // Información de contacto del hotel
        public string TelefonoHotel { get; set; } = string.Empty;
        public string EmailHotel { get; set; } = string.Empty;
    }
}
