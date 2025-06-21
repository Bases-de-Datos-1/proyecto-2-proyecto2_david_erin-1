using Microsoft.AspNetCore.Mvc;
using ProyectoSistemaHotelero.Models;
using ProyectoSistemaHotelero.Services;
using System.Diagnostics;
using System.Security.Claims;

namespace ProyectoSistemaHotelero.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly HotelService _hotelService;
        private readonly RecreativoService _recreativoService;

        public HomeController(
            ILogger<HomeController> logger, 
            HotelService hotelService, 
            RecreativoService recreativoService)
        {
            _logger = logger;
            _hotelService = hotelService;
            _recreativoService = recreativoService;
        }

        public IActionResult Index()
        {
            // Verificamos si el usuario está autenticado y es admin
            if (User.Identity.IsAuthenticated &&
                (User.IsInRole("ADMIN_HOTEL") || User.IsInRole("ADMIN_RECREATIVO")))
            {
                // Obtenemos la cédula jurídica del claim
                string cedulaJuridica = User.FindFirstValue("CedulaJuridica");

                if (!string.IsNullOrEmpty(cedulaJuridica))
                {
                    // Si es admin_hotel, consultamos el nombre del hotel
                    if (User.IsInRole("ADMIN_HOTEL"))
                    {
                        var hotel = _hotelService.GetHotelByCedulaJuridica(cedulaJuridica);
                        if (hotel != null)
                        {
                            ViewBag.NombreServicio = hotel.Nombre;
                        }
                    }
                    // Si es admin_recreativo, consultamos el nombre del servicio recreativo
                    else if (User.IsInRole("ADMIN_RECREATIVO"))
                    {
                        var actividad = _recreativoService.GetActividadByCedulaJuridica(cedulaJuridica);
                        if (actividad != null)
                        {
                            ViewBag.NombreServicio = actividad.Nombre;
                        }
                    }
                }
            }

            return View();
        }

        public IActionResult Privacy()
        {
            return View();
        }

        public IActionResult SeleccionServicios()
        {
            return View();
        }

        [HttpGet]
        public IActionResult BuscarHoteles(string ubicacion, DateTime? checkIn, DateTime? checkOut, int personas = 1)
        {
            // Redirigir al controlador de búsqueda con los parámetros
            return RedirectToAction("Hoteles", "Busqueda", new
            {
                ubicacion = ubicacion,
                checkIn = checkIn,
                checkOut = checkOut,
                personas = personas
            });
        }

        [HttpGet]
        public IActionResult BuscarActividades(string ubicacion)
        {
            // Redirigir al controlador de búsqueda de actividades (cuando lo implementes)
            return RedirectToAction("Actividades", "Busqueda", new
            {
                ubicacion = ubicacion
            });
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
