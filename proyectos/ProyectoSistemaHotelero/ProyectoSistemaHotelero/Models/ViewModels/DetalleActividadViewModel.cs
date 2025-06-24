using System;
using System.Collections.Generic;

namespace ProyectoSistemaHotelero.Models.ViewModels
{
    public class DetalleActividadViewModel
    {
        // Información básica de la empresa
        public string CedulaJuridica { get; set; } = string.Empty;
        public string NombreEmpresa { get; set; } = string.Empty;
        public string UbicacionCompleta { get; set; } = string.Empty;
        public string DireccionCompleta { get; set; } = string.Empty;
        public string Telefono { get; set; } = string.Empty;
        public string CorreoElectronico { get; set; } = string.Empty;
        public string NombreContacto { get; set; } = string.Empty;
        public decimal Precio { get; set; }
        public string Descripcion { get; set; } = string.Empty;

       
        public List<string> FotosActividad { get; set; } = new List<string>();

        // Tipos de actividad que ofrece
        public List<TipoActividadDetalle> TiposActividad { get; set; } = new List<TipoActividadDetalle>();

        // Servicios incluidos
        public List<string> ServiciosIncluidos { get; set; } = new List<string>();

    }

    public class TipoActividadDetalle
    {
        public int TipoActividadID { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
    }
}