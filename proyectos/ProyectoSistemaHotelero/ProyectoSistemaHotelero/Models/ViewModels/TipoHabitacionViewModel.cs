namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class TipoHabitacionViewModel
    {
        public int? TipoHabitacionID { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public int TipoCamaID { get; set; }
        public int CantidadCamas { get; set; } = 1;
        public decimal Precio { get; set; }
        
        // Para el dropdown
        public List<TipoCama> TiposCama { get; set; } = new();
        
        // ID del hotel asociado a este tipo de habitación
        public string CedulaJuridica { get; set; } = string.Empty;
    }
}