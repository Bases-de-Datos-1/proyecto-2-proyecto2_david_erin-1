using Microsoft.AspNetCore.Mvc;
using ProyectoSistemaHotelero.Models;
using ProyectoSistemaHotelero.Models.ViewModels;
using ProyectoSistemaHotelero.Services;
using System.Text.Json;

namespace ProyectoSistemaHotelero.Controllers
{
    public class RecreativoController : Controller
    {
        private readonly RecreativoService _recreativoService;

        public RecreativoController(RecreativoService recreativoService)
        {
            _recreativoService = recreativoService;
        }

        [HttpGet]
        public async Task<IActionResult> RegistroActividades()
        {
            var tiposActividad = await _recreativoService.GetTiposActividadAsync();
            return View(tiposActividad);
        }

        [HttpGet]
        public async Task<IActionResult> FormularioActividades()
        {
            return View();
        }

        [HttpGet]
        public async Task<IActionResult> DireccionActividad()
        {
            return View();
        }

        [HttpGet]
        public async Task<IActionResult> ServiciosActividad()
        {
            var servicios = await _recreativoService.GetServiciosActividadAsync();
            return View(servicios);
        }

        [HttpGet]
        public async Task<IActionResult> AcercaActividad()
        {
            return View();
        }

        [HttpGet]
        public async Task<IActionResult> ConfirmacionRegistro2()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RegistrarActividad([FromBody] JsonElement data)
        {
            try
            {
                // Obtener todos los datos del sessionStorage que se enviaron desde el cliente
                var informacionEspecifica = JsonSerializer.Deserialize<Dictionary<string, object>>(
                    data.GetProperty("informacionEspecifica").ToString(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                
                var direccion = JsonSerializer.Deserialize<Dictionary<string, string>>(
                    data.GetProperty("direccion").ToString(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                
                var tiposActividadIds = JsonSerializer.Deserialize<List<int>>(
                    data.GetProperty("tiposActividad").ToString(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                
                var serviciosIds = JsonSerializer.Deserialize<List<int>>(
                    data.GetProperty("servicios").ToString(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
             

                // Mapear los datos a nuestro ViewModel
                var viewModel = new RegistroActividadViewModel
                {
                    Actividad = new EmpresaActividad
                    {
                        CedulaJuridica = informacionEspecifica["cedulaJuridica"].ToString(),
                        Nombre = informacionEspecifica["nombreEmpresa"].ToString(),
                        CorreoElectronico = informacionEspecifica["correoElectronico"].ToString(),
                        Telefono = informacionEspecifica["telefono"].ToString(),
                        NombreContacto = informacionEspecifica["nombreContacto"].ToString(),
                        Provincia = direccion["provincia"],
                        Canton = direccion["canton"],
                        Distrito = direccion["distrito"],
                        SeniasExactas = direccion["senasExactas"],
                        Precio = decimal.Parse(informacionEspecifica["precio"].ToString()), // Obtener precio de informacionEspecifica
                        Descripcion = informacionEspecifica["descripcion"].ToString(), // Obtener descripción de informacionEspecifica
                    },
                    TiposActividadSeleccionados = tiposActividadIds,
                    ServiciosSeleccionados = serviciosIds
                };

                // Registrar en la base de datos
                var result = await _recreativoService.RegisterActividadAsync(viewModel);
                
                if (result)
                {
                    return Json(new { success = true, message = "Actividad registrada exitosamente" });
                }
                else
                {
                    return Json(new { success = false, message = "Error al registrar la actividad" });
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }
    }
}