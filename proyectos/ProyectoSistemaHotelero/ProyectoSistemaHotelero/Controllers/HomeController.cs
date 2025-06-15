using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ProyectoSistemaHotelero.Models;

namespace ProyectoSistemaHotelero.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
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

        public IActionResult RegistroHospedaje()
        {
            return View();
        }

        public IActionResult RegistroActividades()
        {
            return View();
        }

        public IActionResult FormularioHospedaje(string tipo)
        {
            ViewBag.TipoHospedaje = tipo;
            return View();
        }

        public IActionResult DetallesHospedaje()
        {
            return View();
        }
        public IActionResult DireccionEstablecimiento()
        {
            return View();
        }
        public IActionResult ConfirmacionRegistro()
        {
            return View();
        }
        public IActionResult ServiciosEstablecimiento()
        {
            return View();
        }

        public IActionResult FormularioActividades(string tipo)
        {
            ViewBag.TipoHospedaje = tipo;
            return View();
        }

        public IActionResult DireccionActividad()
        {
            return View();
        }
        public IActionResult ServiciosActividad()
        {
            return View();
        }
        public IActionResult AcercaActividad()
        {
            return View();
        }
        public IActionResult ConfirmacionRegistro2()
        {
            return View();
        }


        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
