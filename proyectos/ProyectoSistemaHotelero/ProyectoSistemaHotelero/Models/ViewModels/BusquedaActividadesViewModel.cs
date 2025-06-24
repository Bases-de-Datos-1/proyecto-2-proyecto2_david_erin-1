namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class BusquedaActividadesViewModel
    {
        public string Ubicacion { get; set; } = string.Empty;

        // Filtros específicos para actividades
        public decimal? PrecioMinimo { get; set; }
        public decimal? PrecioMaximo { get; set; }
        public List<int>? TiposActividadSeleccionados { get; set; } = new();
        public List<int>? ServiciosActividadSeleccionados { get; set; } = new();

        // Para mostrar opciones en filtros
        public List<TipoActividad>? TiposActividadDisponibles { get; set; } = new();
        public List<ServicioActividad>? ServiciosActividadDisponibles { get; set; } = new();

        // Resultados
        public List<ActividadResultado>? Resultados { get; set; } = new();
        public int TotalResultados { get; set; }
        public int PaginaActual { get; set; } = 1;
        public int ResultadosPorPagina { get; set; } = 9;
    }

    public class ActividadResultado
    {
        public string CedulaJuridica { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string UbicacionCompleta { get; set; } = string.Empty;
        public string Telefono { get; set; } = string.Empty;
        public string CorreoElectronico { get; set; } = string.Empty;
        public string NombreContacto { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string ImagenPrincipal { get; set; } = "/ImagenesBG/bghomepage.png"; // Imagen por defecto
        public List<string> TiposActividad { get; set; } = new();
        public List<string> ServiciosActividad { get; set; } = new();
    }

    public class FiltrosActividadesViewModel
    {
        public decimal? PrecioMinimo { get; set; }
        public decimal? PrecioMaximo { get; set; }
        public List<int> TiposActividadSeleccionados { get; set; } = new();
        public List<int> ServiciosActividadSeleccionados { get; set; } = new();
        public List<TipoActividad> TiposActividadDisponibles { get; set; } = new();
        public List<ServicioActividad> ServiciosActividadDisponibles { get; set; } = new();
    }
}
