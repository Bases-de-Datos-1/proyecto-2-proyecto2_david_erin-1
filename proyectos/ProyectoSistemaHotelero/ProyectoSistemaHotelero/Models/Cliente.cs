namespace ProyectoSistemaHotelero.Models
{
    public class Cliente
    {
        public string CedulaID { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public string PrimerApellido { get; set; } = string.Empty;
        public string SegundoApellido { get; set; } = string.Empty;
        public DateTime FechaNacimiento { get; set; }
        public string TipoIdentificacion { get; set; } = string.Empty;
        public int PaisResidenciaID { get; set; }
        public string? Provincia { get; set; }
        public string? Canton { get; set; }
        public string? Distrito { get; set; }
        public string CorreoElectronico { get; set; } = string.Empty;
        public bool EsCostaRica { get; set; }
        public string Contrasenia { get; set; } = string.Empty;

        // Propiedades de navegación
        public PaisResidencia? PaisResidencia { get; set; }
        public ICollection<TelefonoCliente>? Telefonos { get; set; }
    }
}