using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using ProyectoSistemaHotelero.Models;
using ProyectoSistemaHotelero.Models.ViewModels;
using ProyectoSistemaHotelero.Services;
using System.Security.Claims;
using System.Text.Json;

namespace ProyectoSistemaHotelero.Controllers
{
    public class AccountController : Controller
    {
        private readonly ClienteService _clienteService;
        private readonly AuthService _authService;
        
        public AccountController(ClienteService clienteService, AuthService authService)
        {
            _clienteService = clienteService;
            _authService = authService;
        }
        
        [HttpGet]
        public async Task<IActionResult> Registro()
        {
            var paises = await _clienteService.GetPaisesResidenciaAsync();
            ViewBag.Paises = paises;
            return View();
        }
        
        [HttpGet]
        public IActionResult CompletarRegistro()
        {
            return View();
        }
        
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RegistrarCliente([FromBody] JsonElement data)
        {
            try
            {
                // Deserializar los datos del formulario
                var informacionPersonal = JsonSerializer.Deserialize<Dictionary<string, object>>(
                    data.GetProperty("informacionPersonal").ToString(),
                    new JsonSerializerOptions { PropertyNameCaseInsensitive = true });
                
                // Extraer los datos del cliente
                var nombreCompleto = informacionPersonal["nombreCompleto"].ToString();
                var partes = nombreCompleto.Split(' ');
                
                var viewModel = new RegistroClienteViewModel
                {
                    Cliente = new Cliente
                    {
                        CedulaID = informacionPersonal["numeroIdentificacion"].ToString(),
                        Nombre = partes.Length > 0 ? partes[0] : "",
                        PrimerApellido = partes.Length > 1 ? partes[1] : "",
                        SegundoApellido = partes.Length > 2 ? partes[2] : "",
                        FechaNacimiento = DateTime.Parse(informacionPersonal["fechaNacimiento"].ToString()),
                        TipoIdentificacion = informacionPersonal["tipoIdentificacion"].ToString(),
                        PaisResidenciaID = int.Parse(informacionPersonal["paisResidencia"].ToString()),
                        CorreoElectronico = informacionPersonal["correoElectronico"].ToString(),
                        Contrasenia = informacionPersonal["contrasena"].ToString()
                    },
                    Telefonos = new List<TelefonoClienteViewModel>()
                };
                
                // Determinar si es de Costa Rica por el país seleccionado y el valor del ID
                var paisId = int.Parse(informacionPersonal["paisResidencia"].ToString());
                viewModel.Cliente.EsCostaRica = paisId == 1; // Asumiendo que Costa Rica es ID 1
                
                if (viewModel.Cliente.EsCostaRica && informacionPersonal.ContainsKey("direccion"))
                {
                    var direccion = informacionPersonal["direccion"].ToString().Split(',');
                    viewModel.Cliente.Provincia = direccion.Length > 0 ? direccion[0].Trim() : "";
                    viewModel.Cliente.Canton = direccion.Length > 1 ? direccion[1].Trim() : "";
                    viewModel.Cliente.Distrito = direccion.Length > 2 ? direccion[2].Trim() : "";
                }
                
                // Añadir teléfonos
                if (informacionPersonal.ContainsKey("telefono1") && !string.IsNullOrEmpty(informacionPersonal["telefono1"].ToString()))
                {
                    viewModel.Telefonos.Add(new TelefonoClienteViewModel 
                    { 
                        CodigoPais = informacionPersonal["codigoTelefono1"].ToString(),
                        Numero = informacionPersonal["telefono1"].ToString() 
                    });
                }
                
                if (informacionPersonal.ContainsKey("telefono2") && !string.IsNullOrEmpty(informacionPersonal["telefono2"].ToString()))
                {
                    viewModel.Telefonos.Add(new TelefonoClienteViewModel 
                    { 
                        CodigoPais = informacionPersonal["codigoTelefono2"].ToString(),
                        Numero = informacionPersonal["telefono2"].ToString() 
                    });
                }
                
                if (informacionPersonal.ContainsKey("telefono3") && !string.IsNullOrEmpty(informacionPersonal["telefono3"].ToString()))
                {
                    viewModel.Telefonos.Add(new TelefonoClienteViewModel 
                    { 
                        CodigoPais = informacionPersonal["codigoTelefono3"].ToString(),
                        Numero = informacionPersonal["telefono3"].ToString() 
                    });
                }
                
                // Registrar el cliente
                var result = await _clienteService.RegisterClienteAsync(viewModel);
                if (result)
                {
                    // NUEVO: Iniciar sesión automáticamente después del registro
                    var claims = new List<Claim>
                    {
                        new Claim(ClaimTypes.Name, viewModel.Cliente.Nombre + " " + viewModel.Cliente.PrimerApellido),
                        new Claim(ClaimTypes.NameIdentifier, viewModel.Cliente.CedulaID),
                        new Claim(ClaimTypes.Email, viewModel.Cliente.CorreoElectronico)
                    };

                    var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                    var principal = new ClaimsPrincipal(identity);

                    await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, principal);

                    return Json(new { success = true, message = "Cliente registrado e iniciada sesión exitosamente" });
                }
                else
                {
                    return Json(new { success = false, message = "Error al registrar el cliente" });
                }
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error: {ex.Message}" });
            }
        }

        [HttpGet]
        public IActionResult Login(string returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Login(LoginViewModel model, string returnUrl = null)
        {
            ViewData["ReturnUrl"] = returnUrl;
            
            if (ModelState.IsValid)
            {
                var result = await _authService.AuthenticateUserAsync(model.Email, model.Password);
                
                if (result.IsSuccess)
                {
                    var claims = new List<Claim>
                    {
                        new Claim(ClaimTypes.Name, result.Nombre),
                        new Claim(ClaimTypes.NameIdentifier, result.ID),
                        new Claim(ClaimTypes.Email, result.Email),
                        new Claim("UserType", result.TipoLogin)
                    };
                    
                    if (!string.IsNullOrEmpty(result.TipoUsuario))
                    {
                        claims.Add(new Claim("Role", result.TipoUsuario));
                    }
                    
                    if (!string.IsNullOrEmpty(result.CedulaJuridica))
                    {
                        claims.Add(new Claim("CedulaJuridica", result.CedulaJuridica));
                    }
                    
                    var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                    var principal = new ClaimsPrincipal(identity);
                    
                    var authProperties = new AuthenticationProperties
                    {
                        IsPersistent = model.RememberMe, // Usa la selección del usuario
                        ExpiresUtc = model.RememberMe ? DateTimeOffset.UtcNow.AddDays(7) : null // Solo expira si es persistente
                    };
                    
                    await HttpContext.SignInAsync(
                        CookieAuthenticationDefaults.AuthenticationScheme, 
                        principal,
                        authProperties);
                    
                    // Redirigir después del login
                    if (!string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl))
                    {
                        return Redirect(returnUrl);
                    }
                    else
                    {
                        return RedirectToAction("Index", "Home");
                    }
                }
                else
                {
                    ModelState.AddModelError(string.Empty, result.ErrorMessage ?? "Credenciales incorrectas");
                    ViewBag.ErrorMessage = result.ErrorMessage;
                }
            }
            
            return View(model);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToAction("Index", "Home");
        }
    }
}