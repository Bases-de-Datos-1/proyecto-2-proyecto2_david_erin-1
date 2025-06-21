using System;
using System.Collections.Generic;

namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class DetalleHotelViewModel
    {
        // Información básica del hotel
        public string CedulaJuridica { get; set; } = string.Empty;
        public string NombreHotel { get; set; } = string.Empty;
        public string TipoHotel { get; set; } = string.Empty;
        public string UbicacionCompleta { get; set; } = string.Empty;
        public string CorreoElectronico { get; set; } = string.Empty;
        public string? URLSitioWeb { get; set; }

        // Galería de fotos del hotel
        public List<string> FotosHotel { get; set; } = new List<string>();

        // Habitación recomendada/disponible
        public HabitacionDisponible? HabitacionRecomendada { get; set; }

        // Servicios del hotel
        public List<string> ServiciosHotel { get; set; } = new List<string>();

        // Datos de búsqueda (para mantener contexto)
        public DateTime FechaCheckIn { get; set; }
        public DateTime FechaCheckOut { get; set; }
        public int CantidadPersonas { get; set; }
        public int NochesEstadia { get; set; }

        // Cálculos de precios
        public decimal PrecioTotal { get; set; }
        public decimal PrecioPorNoche { get; set; }
    }

    public class HabitacionDisponible
    {
        public int HabitacionID { get; set; } // ID específico de la habitación física
        public int TipoHabitacionID { get; set; } // ID del tipo de habitación
        public string NombreHabitacion { get; set; } = string.Empty;
        public string DescripcionHabitacion { get; set; } = string.Empty;
        public int CapacidadPersonas { get; set; }
        public int CantidadCamas { get; set; }
        public string TipoCamas { get; set; } = string.Empty;
        public decimal PrecioPorNoche { get; set; }
        public List<string> FotosHabitacion { get; set; } = new List<string>();
        public List<string> ComodidadesHabitacion { get; set; } = new List<string>();
        public string NumeroHabitacion { get; set; } = string.Empty;
    }
}
