namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class BusquedaHotelesViewModel
    {
        public string Ubicacion { get; set; } = string.Empty;
        public DateTime FechaCheckIn { get; set; } = DateTime.Now.AddDays(1);
        public DateTime FechaCheckOut { get; set; } = DateTime.Now.AddDays(2);
        public int CantidadPersonas { get; set; } = 1;

        // Filtros adicionales
        public decimal? PrecioMinimo { get; set; }
        public decimal? PrecioMaximo { get; set; }
        public List<int>? ServiciosSeleccionados { get; set; } = new();
        public List<int>? ComodidadesSeleccionadas { get; set; } = new();

        // Para mostrar opciones en filtros
        public List<Servicio>? ServiciosDisponibles { get; set; } = new();
        public List<Comodidad>? ComodidadesDisponibles { get; set; } = new();

        // Resultados
        public List<HotelResultado>? Resultados { get; set; } = new();
        public int TotalResultados { get; set; }
        public int PaginaActual { get; set; } = 1;
        public int ResultadosPorPagina { get; set; } = 9;
    }

    public class HotelResultado
    {
        public string CedulaJuridica { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string TipoHotel { get; set; } = string.Empty;
        public string UbicacionCompleta { get; set; } = string.Empty;
        public string CorreoElectronico { get; set; } = string.Empty;
        public string? URLSitioWeb { get; set; }
        public decimal PrecioMinimo { get; set; }
        public decimal PrecioMaximo { get; set; }
        public string? ImagenPrincipal { get; set; }
        public List<string> Servicios { get; set; } = new();
        public double? Calificacion { get; set; }
        public int NumeroReviews { get; set; }
    }

    public class FiltrosBusquedaViewModel
    {
        public decimal? PrecioMinimo { get; set; }
        public decimal? PrecioMaximo { get; set; }
        public List<int> ServiciosSeleccionados { get; set; } = new();
        public List<int> ComodidadesSeleccionadas { get; set; } = new();
        public List<Servicio> ServiciosDisponibles { get; set; } = new();
        public List<Comodidad> ComodidadesDisponibles { get; set; } = new();
    }

}
