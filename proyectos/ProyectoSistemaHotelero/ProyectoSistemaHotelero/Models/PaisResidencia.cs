namespace ProyectoSistemaHotelero.Models
{
    public class PaisResidencia
    {
        public int PaisResidenciaID { get; set; }
        public string NombrePais { get; set; } = string.Empty;
        
        // Propiedad de navegación
        public ICollection<Cliente>? Clientes { get; set; }
    }
}