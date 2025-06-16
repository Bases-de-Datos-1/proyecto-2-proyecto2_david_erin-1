namespace ProyectoSistemaHotelero.Models
{
    public class PaisResidencia
    {
        public int PaisResidenciaID { get; set; }
        public string NombrePais { get; set; } = string.Empty;
        
        // Propiedad de navegaci�n
        public ICollection<Cliente>? Clientes { get; set; }
    }
}