using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc;

public class AccountController : Controller
{
    public IActionResult Login() => View();
    public IActionResult Registro() => View();
    public IActionResult MiCuenta() => View();
    public IActionResult MisNegocios() => View();
    public IActionResult Configuracion() => View();

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Logout()
    {
        // Lógica de logout
        await HttpContext.SignOutAsync();
        return RedirectToAction("Index", "Home");
    }
}
