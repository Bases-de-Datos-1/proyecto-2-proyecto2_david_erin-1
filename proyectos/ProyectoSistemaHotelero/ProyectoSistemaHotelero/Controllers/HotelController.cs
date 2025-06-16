using Microsoft.AspNetCore.Mvc;
using ProyectoSistemaHotelero.Models;
using ProyectoSistemaHotelero.Models.ViewModels;
using ProyectoSistemaHotelero.Services;
using System.Text.Json;

namespace ProyectoSistemaHotelero.Controllers
{
    public class HotelController : Controller
    {
        private readonly HotelService _hotelService;

        public HotelController(HotelService hotelService)
        {
            _hotelService = hotelService;
        }

        [HttpGet]
        public async Task<IActionResult> RegistroHospedaje()
        {
            var tiposHotel = await _hotelService.GetTiposHotelAsync();
            return View(tiposHotel);
        }

        [HttpPost]
        public IActionResult GuardarTipoHotel(int tipoHotelId)
        {
            // Guardar en TempData para recuperarlo después
            TempData["TipoHotelID"] = tipoHotelId;
            return RedirectToAction("FormularioHospedaje");
        }

        [HttpGet]
        public async Task<IActionResult> FormularioHospedaje()
        {
            ViewBag.TipoHotelID = TempData["TipoHotelID"];
            return View();
        }

        [HttpGet]
        public async Task<IActionResult> DetallesHospedaje()
        {
            var redesSociales = await _hotelService.GetRedesSocialesAsync();
            return View(redesSociales);
        }   


        [HttpGet]
        public async Task<IActionResult> DireccionEstablecimiento()
        {
            return View();
        }

        [HttpGet]
        public async Task<IActionResult> ServiciosEstablecimiento()
        {
            var servicios = await _hotelService.GetServiciosAsync();
            return View(servicios);
        }

        [HttpGet]
        public async Task<IActionResult> ConfirmacionRegistro()
        {
            // Aquí podrías cargar información adicional si es necesario
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RegistrarHotel([FromBody] JsonElement data)
        {
            try
            {
                // Obtener todos los datos del sessionStorage que se enviaron desde el cliente
                var informacionEspecifica = JsonSerializer.Deserialize<Dictionary<string, object>>(
                    data.GetProperty("informacionEspecifica").ToString(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                
                var redesSociales = JsonSerializer.Deserialize<Dictionary<string, string>>(
                    data.GetProperty("redesSociales").ToString(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                
                var direccion = JsonSerializer.Deserialize<Dictionary<string, string>>(
                    data.GetProperty("direccion").ToString(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                
                var serviciosIds = JsonSerializer.Deserialize<List<int>>(
                    data.GetProperty("servicios").ToString(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

                // Mapear los datos a nuestro ViewModel
                var viewModel = new RegistroHotelViewModel
                {
                    Hotel = new EmpresaHotel
                    {
                        CedulaJuridica = informacionEspecifica["cedulaJuridica"].ToString(),
                        Nombre = informacionEspecifica["nombreEstablecimiento"].ToString(),
                        TipoHotelID = int.Parse(informacionEspecifica["tipoHotelID"].ToString()),
                        Provincia = direccion["provincia"],
                        Canton = direccion["canton"],
                        Distrito = direccion["distrito"],
                        Barrio = direccion["barrio"],
                        SeniasExactas = direccion["senasExactas"],
                        ReferenciaGPS = direccion.ContainsKey("referenciaGps") ? direccion["referenciaGps"] : null,
                        CorreoElectronico = informacionEspecifica["correoElectronico"].ToString(),
                        URLSitioWeb = informacionEspecifica.ContainsKey("urlSitioWeb") ?
                                 informacionEspecifica["urlSitioWeb"].ToString() : null
                    },
                    ServiciosSeleccionados = serviciosIds,
                    Telefonos = new List<TelefonoViewModel>()
                };

                // Agregar teléfonos
                if (informacionEspecifica.ContainsKey("telefono1"))
                {
                    viewModel.Telefonos.Add(new TelefonoViewModel 
                    { 
                        CodigoPais = informacionEspecifica["codigoTelefono1"].ToString(),
                        Numero = informacionEspecifica["telefono1"].ToString() 
                    });
                }

                if (informacionEspecifica.ContainsKey("telefono2") && !string.IsNullOrEmpty(informacionEspecifica["telefono2"].ToString()))
                {
                    viewModel.Telefonos.Add(new TelefonoViewModel 
                    { 
                        CodigoPais = informacionEspecifica["codigoTelefono2"].ToString(),
                        Numero = informacionEspecifica["telefono2"].ToString() 
                    });
                }

                if (informacionEspecifica.ContainsKey("telefono3") && !string.IsNullOrEmpty(informacionEspecifica["telefono3"].ToString()))
                {
                    viewModel.Telefonos.Add(new TelefonoViewModel 
                    { 
                        CodigoPais = informacionEspecifica["codigoTelefono3"].ToString(),
                        Numero = informacionEspecifica["telefono3"].ToString() 
                    });
                }

                // Agregar redes sociales
                var listaRedesSociales = await _hotelService.GetRedesSocialesAsync();
                foreach (var redSocial in listaRedesSociales)
                {
                    var keyName = redSocial.Nombre.ToLower().Replace(" ", "");
                    if (redesSociales.ContainsKey(keyName) && !string.IsNullOrEmpty(redesSociales[keyName]))
                    {
                        viewModel.RedesSociales.Add(new RedSocialViewModel
                        {
                            RedSocialID = redSocial.RedSocialID,
                            NombreUsuario = redesSociales[keyName]
                        });
                    }
                }

                // Registrar en la base de datos
                var result = await _hotelService.RegisterHotelAsync(viewModel);
                
                if (result)
                {
                    return Json(new { success = true, message = "Hotel registrado exitosamente" });
                }
                else
                {
                    return Json(new { success = false, message = "Error al registrar el hotel" });
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }
    }
}