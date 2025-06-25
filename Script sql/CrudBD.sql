USE SistemaHoteleria
GO

-- ==========================================
-- CRUD PARA TIPOCAMA
-- ==========================================
CREATE PROCEDURE sp_InsertarTipoCama
    @Nombre varchar(100),
    @Capacidad int
AS
BEGIN
    INSERT INTO TipoCama (Nombre, Capacidad)
    VALUES (@Nombre, @Capacidad)
END
GO

CREATE PROCEDURE sp_ObtenerTipoCamas
AS
BEGIN
    SELECT * FROM TipoCama
END
GO

CREATE PROCEDURE sp_ObtenerTipoCamaPorID
    @TipoCamaID int
AS
BEGIN
    SELECT * FROM TipoCama WHERE TipoCamaID = @TipoCamaID
END
GO

CREATE PROCEDURE sp_ActualizarTipoCama
    @TipoCamaID int,
    @Nombre varchar(100),
    @Capacidad int
AS
BEGIN
    UPDATE TipoCama 
    SET Nombre = @Nombre, Capacidad = @Capacidad
    WHERE TipoCamaID = @TipoCamaID
END
GO


CREATE PROCEDURE sp_EliminarTipoCama
    @TipoCamaID int
AS
BEGIN
    -- Verificar si tiene dependencias
    IF EXISTS (SELECT 1 FROM TipoHabitacionCama WHERE TipoCamaID = @TipoCamaID)
    BEGIN
        RAISERROR('No se puede eliminar: Este tipo de cama está siendo usado en habitaciones', 16, 1)
        RETURN
    END
    
    DELETE FROM TipoCama WHERE TipoCamaID = @TipoCamaID
END
GO

-- ==========================================
-- CRUD PARA TIPOHOTEL
-- ==========================================


CREATE PROCEDURE sp_InsertarTipoHotel
    @Nombre varchar(100)
AS
BEGIN
    INSERT INTO TipoHotel (Nombre)
    VALUES (@Nombre)
END
GO


CREATE PROCEDURE sp_ObtenerTipoHoteles
AS
BEGIN
    SELECT * FROM TipoHotel
END
GO


CREATE PROCEDURE sp_ActualizarTipoHotel
    @TipoHotelID int,
    @Nombre varchar(100)
AS
BEGIN
    UPDATE TipoHotel 
    SET Nombre = @Nombre
    WHERE TipoHotelID = @TipoHotelID
END
GO


CREATE PROCEDURE sp_EliminarTipoHotel
    @TipoHotelID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM EmpresaHotel WHERE TipoHotelID = @TipoHotelID)
    BEGIN
        RAISERROR('No se puede eliminar: Hay hoteles que usan este tipo', 16, 1)
        RETURN
    END
    
    DELETE FROM TipoHotel WHERE TipoHotelID = @TipoHotelID
END
GO

-- ==========================================
-- CRUD PARA SERVICIOS
-- ==========================================


CREATE PROCEDURE sp_InsertarServicio
    @Nombre varchar(100)
AS
BEGIN
    INSERT INTO Servicios (Nombre)
    VALUES (@Nombre)
END
GO


CREATE PROCEDURE sp_ObtenerServicios
AS
BEGIN
    SELECT * FROM Servicios
END
GO


CREATE PROCEDURE sp_ActualizarServicio
    @ServicioID int,
    @Nombre varchar(100)
AS
BEGIN
    UPDATE Servicios 
    SET Nombre = @Nombre
    WHERE ServicioID = @ServicioID
END
GO


CREATE PROCEDURE sp_EliminarServicio
    @ServicioID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM HotelServicios WHERE ServicioID = @ServicioID)
    BEGIN
        RAISERROR('No se puede eliminar: Este servicio está siendo usado por hoteles', 16, 1)
        RETURN
    END
    
    DELETE FROM Servicios WHERE ServicioID = @ServicioID
END
GO

-- ==========================================
-- CRUD PARA PAISRESIDENCIA
-- ==========================================

CREATE PROCEDURE sp_InsertarPaisResidencia
    @NombrePais varchar(50),
	@CodigoPais varchar(5)
AS
BEGIN
    INSERT INTO PaisResidencia (NombrePais, CodigoPais)
    VALUES (@NombrePais, @CodigoPais)
END
GO


CREATE PROCEDURE sp_ObtenerPaisesResidencia
AS
BEGIN
    SELECT * FROM PaisResidencia
END
GO

CREATE PROCEDURE sp_ActualizarPaisResidencia
    @PaisResidenciaID int,
    @NombrePais varchar(50),
	@CodigoPais varchar(5)
AS
BEGIN
    UPDATE PaisResidencia 
    SET NombrePais = @NombrePais, CodigoPais = @CodigoPais
    WHERE PaisResidenciaID = @PaisResidenciaID
END
GO


CREATE PROCEDURE sp_EliminarPaisResidencia
    @PaisResidenciaID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM Cliente WHERE PaisResidenciaID = @PaisResidenciaID)
    BEGIN
        RAISERROR('No se puede eliminar: Hay clientes de este país', 16, 1)
        RETURN
    END
    
    DELETE FROM PaisResidencia WHERE PaisResidenciaID = @PaisResidenciaID
END
GO

-- ==========================================
-- CRUD PARA EMPRESAHOTEL
-- ==========================================


CREATE PROCEDURE sp_InsertarEmpresaHotel
    @CedulaJuridica varchar(20),
    @Nombre varchar(100),
    @TipoHotelID int,
    @Provincia varchar(50),
    @Canton varchar(50),
    @Distrito varchar(50),
    @Barrio varchar(50),
    @SeniasExactas text,
    @ReferenciaGPS varchar(100),
    @CorreoElectronico varchar(100),
    @URLSitioWeb text = NULL
AS
BEGIN
	IF EXISTS (SELECT 1 FROM EmpresaHotel WHERE CedulaJuridica = @CedulaJuridica)
    BEGIN
        RAISERROR('Ya existe una empresa con esta cédula', 16, 1)
        RETURN
    END

	IF EXISTS (SELECT 1 FROM EmpresaHotel WHERE CorreoElectronico = @CorreoElectronico)
    BEGIN
        RAISERROR('Ya existe una empresa con este correo', 16, 1)
        RETURN
    END



    INSERT INTO EmpresaHotel (CedulaJuridica, Nombre, TipoHotelID, Provincia, Canton, 
                             Distrito, Barrio, SeniasExactas, ReferenciaGPS, 
                             CorreoElectronico, URLSitioWeb)
    VALUES (@CedulaJuridica, @Nombre, @TipoHotelID, @Provincia, @Canton, 
            @Distrito, @Barrio, @SeniasExactas, @ReferenciaGPS, 
            @CorreoElectronico, @URLSitioWeb)
END
GO

-- READ
CREATE PROCEDURE sp_ObtenerEmpresasHotel
AS
BEGIN
    SELECT e.*, t.Nombre as TipoHotelNombre
    FROM EmpresaHotel e
    INNER JOIN TipoHotel t ON e.TipoHotelID = t.TipoHotelID
END
GO

-- UPDATE
CREATE PROCEDURE sp_ActualizarEmpresaHotel
    @CedulaJuridica varchar(20),
    @Nombre varchar(100),
    @TipoHotelID int,
    @Provincia varchar(50),
    @Canton varchar(50),
    @Distrito varchar(50),
    @Barrio varchar(50),
    @SeniasExactas text,
    @ReferenciaGPS varchar(100),
    @CorreoElectronico varchar(100),
    @URLSitioWeb text = NULL
AS
BEGIN
    UPDATE EmpresaHotel 
    SET Nombre = @Nombre, 
		TipoHotelID = @TipoHotelID, 
		Provincia = @Provincia,
        Canton = @Canton, 
		Distrito = @Distrito, 
		Barrio = @Barrio,
        SeniasExactas = @SeniasExactas, 
		ReferenciaGPS = @ReferenciaGPS,
        CorreoElectronico = @CorreoElectronico, 
		URLSitioWeb = @URLSitioWeb
    WHERE CedulaJuridica = @CedulaJuridica
END
GO

-- DELETE
CREATE PROCEDURE sp_EliminarEmpresaHotel
    @CedulaJuridica varchar(20)
AS
BEGIN
    -- Verificar reservaciones activas
    IF EXISTS (SELECT 1 FROM Reservacion R 
               INNER JOIN Habitaciones H ON R.HabitacionID = H.HabitacionID
               WHERE H.CedulaJuridica = @CedulaJuridica 
               AND R.FechaSalida >= CAST(GETDATE() as date))
    BEGIN
        RAISERROR('No se puede eliminar: El hotel tiene reservaciones activas', 16, 1)
        RETURN
    END
    
    -- Eliminar en orden correcto
    DELETE TC FROM TipoHabitacionCama TC 
    JOIN TipoHabitacion TH ON TC.TipoHabitacionID = TH.TipoHabitacionID 
    WHERE TH.CedulaJuridica = @CedulaJuridica
    
    DELETE TC FROM TipoHabitacionComodidad TC 
    JOIN TipoHabitacion TH ON TC.TipoHabitacionID = TH.TipoHabitacionID 
    WHERE TH.CedulaJuridica = @CedulaJuridica
    
    DELETE F FROM FotosHabitacion F 
    JOIN TipoHabitacion TH ON F.TipoHabitacionID = TH.TipoHabitacionID 
    WHERE TH.CedulaJuridica = @CedulaJuridica
    
    DELETE FROM TipoHabitacion WHERE CedulaJuridica = @CedulaJuridica
    DELETE FROM Habitaciones WHERE CedulaJuridica = @CedulaJuridica
    DELETE FROM TelefonosEmpresa WHERE CedulaJuridica = @CedulaJuridica
    DELETE FROM RedSocialHotel WHERE CedulaJuridica = @CedulaJuridica
    DELETE FROM HotelServicios WHERE CedulaJuridica = @CedulaJuridica
    DELETE FROM EmpresaHotel WHERE CedulaJuridica = @CedulaJuridica
END
GO



-- ==========================================
-- CRUD PARA CLIENTE
-- ==========================================


CREATE PROCEDURE sp_InsertarCliente
    @CedulaID varchar(20),
    @Nombre varchar(100),
    @PrimerApellido varchar(100),
    @SegundoApellido varchar(100),
    @FechaNacimiento Date,
    @TipoIdentificacion varchar(50),
    @PaisResidenciaID int,
    @Provincia varchar(50) = NULL,
    @Canton varchar(50) = NULL,
    @Distrito varchar(50) = NULL,
    @CorreoElectronico varchar(50),
    @EsCostaRica bit = 0,
	@Contrasenia varchar(15)
AS
BEGIN

	IF EXISTS (SELECT 1 FROM Cliente WHERE CedulaID = @CedulaID)
    BEGIN
        RAISERROR('Ya existe un cliente con esta cédula', 16, 1)
        RETURN
    END
	IF EXISTS (SELECT 1 FROM Cliente WHERE CorreoElectronico = @CorreoElectronico)
    BEGIN
        RAISERROR('Ya existe un cliente con este correo electrónico', 16, 1)
        RETURN
    END

	IF @EsCostaRica = 1 AND (@Provincia IS NULL OR @Canton IS NULL OR @Distrito IS NULL)
    BEGIN
        RAISERROR('Para clientes de Costa Rica se requieren provincia, cantón y distrito', 16, 1)
        RETURN
    END

    INSERT INTO Cliente (CedulaID, Nombre, PrimerApellido, SegundoApellido, FechaNacimiento, TipoIdentificacion, PaisResidenciaID,
                        Provincia, Canton, Distrito, CorreoElectronico, EsCostaRica, Contrasenia)
    VALUES (@CedulaID, @Nombre, @PrimerApellido, @SegundoApellido,
            @FechaNacimiento, @TipoIdentificacion, @PaisResidenciaID,
            @Provincia, @Canton, @Distrito, @CorreoElectronico, @EsCostaRica, @Contrasenia)
END
GO


CREATE PROCEDURE sp_ObtenerClientes
AS
BEGIN
    SELECT c.*, p.NombrePais
    FROM Cliente c
    INNER JOIN PaisResidencia p ON c.PaisResidenciaID = p.PaisResidenciaID
END
GO


CREATE PROCEDURE sp_ActualizarCliente
    @CedulaID varchar(20),
    @Nombre varchar(100),
    @PrimerApellido varchar(100),
    @SegundoApellido varchar(100),
    @FechaNacimiento Date,
    @TipoIdentificacion varchar(50),
    @PaisResidenciaID int,
    @Provincia varchar(50) = NULL,
    @Canton varchar(50) = NULL,
    @Distrito varchar(50) = NULL,
    @CorreoElectronico varchar(50),
    @EsCostaRica bit = 0,
	@Contrasenia varchar(15)
AS
BEGIN
    UPDATE Cliente 
    SET Nombre = @Nombre, PrimerApellido = @PrimerApellido,
        SegundoApellido = @SegundoApellido, FechaNacimiento = @FechaNacimiento,
        TipoIdentificacion = @TipoIdentificacion, PaisResidenciaID = @PaisResidenciaID,
        Provincia = @Provincia, Canton = @Canton, Distrito = @Distrito,
        CorreoElectronico = @CorreoElectronico, EsCostaRica = @EsCostaRica, Contrasenia = @Contrasenia
    WHERE CedulaID = @CedulaID
END
GO


CREATE PROCEDURE sp_EliminarCliente
    @CedulaID varchar(20)
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM Reservacion WHERE CedulaID = @CedulaID)
    BEGIN
        RAISERROR('No se puede eliminar: El cliente tiene reservaciones', 16, 1)
        RETURN
    END
    
    -- Eliminar teléfonos del cliente
    DELETE FROM TelefonosCliente WHERE CedulaID = @CedulaID
    
    -- Eliminar cliente
    DELETE FROM Cliente WHERE CedulaID = @CedulaID
END
GO

CREATE PROCEDURE sp_ValidarLoginCliente
    @CorreoElectronico varchar(50),
    @Contrasenia varchar(15)
AS
BEGIN
    SELECT CedulaID, Nombre, PrimerApellido, SegundoApellido, CorreoElectronico
    FROM Cliente 
    WHERE CorreoElectronico = @CorreoElectronico 
    AND Contrasenia = @Contrasenia
END

GO
CREATE PROCEDURE sp_LoginGeneral
    @Email varchar(100),
    @Contrasenia varchar(255)
AS
BEGIN
    -- Buscar en tabla de clientes
    IF EXISTS (SELECT 1 FROM Cliente WHERE CorreoElectronico = @Email AND Contrasenia = @Contrasenia)
    BEGIN
        SELECT 'CLIENTE' as TipoLogin, CedulaID as ID, Nombre, CorreoElectronico, NULL as CedulaJuridica
        FROM Cliente 
        WHERE CorreoElectronico = @Email AND Contrasenia = @Contrasenia
    END
    -- Buscar en tabla de usuarios de sistema hotel
    ELSE IF EXISTS (SELECT 1 FROM UsuarioSistemaHotel WHERE Email = @Email AND Contrasenia = @Contrasenia AND Activo = 1)
    BEGIN
        SELECT 'ADMIN_HOTEL' as TipoLogin, UsuarioID as ID, Nombre, Email, TipoUsuario, CedulaJuridica
        FROM UsuarioSistemaHotel 
        WHERE Email = @Email AND Contrasenia = @Contrasenia AND Activo = 1
    END
    -- Buscar en tabla de usuarios de sistema recreativo
    ELSE IF EXISTS (SELECT 1 FROM UsuarioSistemaRecreativo WHERE Email = @Email AND Contrasenia = @Contrasenia AND Activo = 1)
    BEGIN
        SELECT 'ADMIN_RECREATIVO' as TipoLogin, UsuarioID as ID, Nombre, Email, TipoUsuario, CedulaJuridica
        FROM UsuarioSistemaRecreativo 
        WHERE Email = @Email AND Contrasenia = @Contrasenia AND Activo = 1
    END
    ELSE
    BEGIN
        SELECT 'INVALID' as TipoLogin
    END
END

-- ==========================================
-- CRUD PARA USUARIOSISTEMAHOTEL
-- ==========================================
GO

CREATE PROCEDURE sp_InsertarUsuarioSistemaHotel
    @Contrasenia varchar(255),
    @Nombre varchar(100),
    @Apellido varchar(100),
    @Email varchar(100),
    @TipoUsuario varchar(20) = 'ADMIN',
    @CedulaJuridica varchar(20),
    @Activo bit = 1
AS
BEGIN
    -- Verificar que no existe otro usuario con el mismo email
    IF EXISTS (SELECT 1 FROM UsuarioSistemaHotel WHERE Email = @Email)
    BEGIN
        RAISERROR('Ya existe un usuario con este email', 16, 1)
        RETURN
    END

    -- Verificar que existe la empresa hotel
    IF NOT EXISTS (SELECT 1 FROM EmpresaHotel WHERE CedulaJuridica = @CedulaJuridica)
    BEGIN
        RAISERROR('No existe una empresa hotel con esta cédula jurídica', 16, 1)
        RETURN
    END

    INSERT INTO UsuarioSistemaHotel (Contrasenia, Nombre, Apellido, Email, TipoUsuario, CedulaJuridica, Activo)
    VALUES (@Contrasenia, @Nombre, @Apellido, @Email, @TipoUsuario, @CedulaJuridica, @Activo)
END
GO

CREATE PROCEDURE sp_ObtenerUsuariosSistemaHotel
AS
BEGIN
    SELECT u.*, e.Nombre as NombreEmpresa
    FROM UsuarioSistemaHotel u
    INNER JOIN EmpresaHotel e ON u.CedulaJuridica = e.CedulaJuridica
END
GO

CREATE PROCEDURE sp_ObtenerUsuarioSistemaHotelPorID
    @UsuarioID int
AS
BEGIN
    SELECT u.*, e.Nombre as NombreEmpresa
    FROM UsuarioSistemaHotel u
    INNER JOIN EmpresaHotel e ON u.CedulaJuridica = e.CedulaJuridica
    WHERE u.UsuarioID = @UsuarioID
END
GO

CREATE PROCEDURE sp_ActualizarUsuarioSistemaHotel
    @UsuarioID int,
    @Contrasenia varchar(255),
    @Nombre varchar(100),
    @Apellido varchar(100),
    @Email varchar(100),
    @TipoUsuario varchar(20) = 'ADMIN',
    @CedulaJuridica varchar(20),
    @Activo bit = 1
AS
BEGIN
    -- Verificar que no existe otro usuario con el mismo email (excluyendo el actual)
    IF EXISTS (SELECT 1 FROM UsuarioSistemaHotel WHERE Email = @Email AND UsuarioID != @UsuarioID)
    BEGIN
        RAISERROR('Ya existe otro usuario con este email', 16, 1)
        RETURN
    END

    UPDATE UsuarioSistemaHotel 
    SET Contrasenia = @Contrasenia,
        Nombre = @Nombre,
        Apellido = @Apellido,
        Email = @Email,
        TipoUsuario = @TipoUsuario,
        CedulaJuridica = @CedulaJuridica,
        Activo = @Activo
    WHERE UsuarioID = @UsuarioID
END
GO

CREATE PROCEDURE sp_EliminarUsuarioSistemaHotel
    @UsuarioID int
AS
BEGIN
    DELETE FROM UsuarioSistemaHotel WHERE UsuarioID = @UsuarioID
END
GO

CREATE PROCEDURE sp_ValidarLoginUsuarioHotel
    @Email varchar(100),
    @Contrasenia varchar(255)
AS
BEGIN
    SELECT u.UsuarioID, u.Nombre, u.Apellido, u.Email, u.TipoUsuario, u.CedulaJuridica, e.Nombre as NombreEmpresa
    FROM UsuarioSistemaHotel u
    INNER JOIN EmpresaHotel e ON u.CedulaJuridica = e.CedulaJuridica
    WHERE u.Email = @Email 
    AND u.Contrasenia = @Contrasenia 
    AND u.Activo = 1
END
GO

-- ==========================================
-- CRUD PARA USUARIOSISTEMARECREATIVO
-- ==========================================

CREATE PROCEDURE sp_InsertarUsuarioSistemaRecreativo
    @Contrasenia varchar(255),
    @Nombre varchar(100),
    @Apellido varchar(100),
    @Email varchar(100),
    @TipoUsuario varchar(20) = 'ADMIN',
    @CedulaJuridica varchar(20),
    @Activo bit = 1
AS
BEGIN
    -- Verificar que no existe otro usuario con el mismo email
    IF EXISTS (SELECT 1 FROM UsuarioSistemaRecreativo WHERE Email = @Email)
    BEGIN
        RAISERROR('Ya existe un usuario con este email', 16, 1)
        RETURN
    END

    -- Verificar que existe la empresa de actividades
    IF NOT EXISTS (SELECT 1 FROM EmpresaActividad WHERE CedulaJuridica = @CedulaJuridica)
    BEGIN
        RAISERROR('No existe una empresa de actividades con esta cédula jurídica', 16, 1)
        RETURN
    END

    INSERT INTO UsuarioSistemaRecreativo (Contrasenia, Nombre, Apellido, Email, TipoUsuario, CedulaJuridica, Activo)
    VALUES (@Contrasenia, @Nombre, @Apellido, @Email, @TipoUsuario, @CedulaJuridica, @Activo)
END
GO

CREATE PROCEDURE sp_ObtenerUsuariosSistemaRecreativo
AS
BEGIN
    SELECT u.*, e.Nombre as NombreEmpresa
    FROM UsuarioSistemaRecreativo u
    INNER JOIN EmpresaActividad e ON u.CedulaJuridica = e.CedulaJuridica
END
GO

CREATE PROCEDURE sp_ObtenerUsuarioSistemaRecreativoPorID
    @UsuarioID int
AS
BEGIN
    SELECT u.*, e.Nombre as NombreEmpresa
    FROM UsuarioSistemaRecreativo u
    INNER JOIN EmpresaActividad e ON u.CedulaJuridica = e.CedulaJuridica
    WHERE u.UsuarioID = @UsuarioID
END
GO

CREATE PROCEDURE sp_ActualizarUsuarioSistemaRecreativo
    @UsuarioID int,
    @Contrasenia varchar(255),
    @Nombre varchar(100),
    @Apellido varchar(100),
    @Email varchar(100),
    @TipoUsuario varchar(20) = 'ADMIN',
    @CedulaJuridica varchar(20),
    @Activo bit = 1
AS
BEGIN
    -- Verificar que no existe otro usuario con el mismo email (excluyendo el actual)
    IF EXISTS (SELECT 1 FROM UsuarioSistemaRecreativo WHERE Email = @Email AND UsuarioID != @UsuarioID)
    BEGIN
        RAISERROR('Ya existe otro usuario con este email', 16, 1)
        RETURN
    END

    UPDATE UsuarioSistemaRecreativo 
    SET Contrasenia = @Contrasenia,
        Nombre = @Nombre,
        Apellido = @Apellido,
        Email = @Email,
        TipoUsuario = @TipoUsuario,
        CedulaJuridica = @CedulaJuridica,
        Activo = @Activo
    WHERE UsuarioID = @UsuarioID
END
GO

CREATE PROCEDURE sp_EliminarUsuarioSistemaRecreativo
    @UsuarioID int
AS
BEGIN
    DELETE FROM UsuarioSistemaRecreativo WHERE UsuarioID = @UsuarioID
END
GO

CREATE PROCEDURE sp_ValidarLoginUsuarioRecreativo
    @Email varchar(100),
    @Contrasenia varchar(255)
AS
BEGIN
    SELECT u.UsuarioID, u.Nombre, u.Apellido, u.Email, u.TipoUsuario, u.CedulaJuridica, e.Nombre as NombreEmpresa
    FROM UsuarioSistemaRecreativo u
    INNER JOIN EmpresaActividad e ON u.CedulaJuridica = e.CedulaJuridica
    WHERE u.Email = @Email 
    AND u.Contrasenia = @Contrasenia 
    AND u.Activo = 1
END
GO

-- ==========================================
-- CRUD PARA TIPOHABITACION
-- ==========================================


CREATE PROCEDURE sp_InsertarTipoHabitacion
    @Nombre varchar(50),
    @Descripcion varchar(MAX) = NULL,
    @Precio decimal(10,2),
	@CedulaJuridica varchar(20),
	@TipoCamaID int,
	@Cantidad int,
	@ID INT OUTPUT
AS
BEGIN
    INSERT INTO TipoHabitacion (Nombre, Descripcion, Precio, CedulaJuridica, TipoCamaID, Cantidad)
    VALUES (@Nombre, @Descripcion, @Precio, @CedulaJuridica, @TipoCamaID, @Cantidad)

	SET @ID = SCOPE_IDENTITY();
END
GO

CREATE PROCEDURE sp_ObtenerTiposHabitacion
AS
BEGIN
    SELECT * FROM TipoHabitacion
END
GO


CREATE PROCEDURE sp_ActualizarTipoHabitacion
    @TipoHabitacionID int,
    @Nombre varchar(50),
    @Descripcion varchar(MAX) = NULL,
    @Precio decimal(10,2),
	@CedulaJuridica varchar(20),
	@TipoCamaID int,
	@Cantidad int
AS
BEGIN
    UPDATE TipoHabitacion 
    SET Nombre = @Nombre, Descripcion = @Descripcion, Precio = @Precio, CedulaJuridica = @CedulaJuridica, TipoCamaID = @TipoCamaID, Cantidad = @Cantidad
    WHERE TipoHabitacionID = @TipoHabitacionID
END
GO


CREATE PROCEDURE sp_EliminarTipoHabitacion
    @TipoHabitacionID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM Habitaciones WHERE TipoHabitacionID = @TipoHabitacionID)
    BEGIN
        RAISERROR('No se puede eliminar: Hay habitaciones de este tipo', 16, 1)
        RETURN
    END
    
    -- Eliminar registros relacionados
    DELETE FROM FotosHabitacion WHERE TipoHabitacionID = @TipoHabitacionID
    DELETE FROM TipoHabitacionCama WHERE TipoHabitacionID = @TipoHabitacionID
    DELETE FROM TipoHabitacionComodidad WHERE TipoHabitacionID = @TipoHabitacionID
    
    -- Eliminar tipo de habitación
    DELETE FROM TipoHabitacion WHERE TipoHabitacionID = @TipoHabitacionID
END
GO

-- ==========================================
-- CRUD PARA HABITACIONES
-- ==========================================


CREATE PROCEDURE sp_InsertarHabitacion
    @Numero INT,
    @CedulaJuridica VARCHAR(20),
    @TipoHabitacionID INT,
    @HabitacionID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Verificar que el número no exista ya
    IF EXISTS (SELECT 1 FROM Habitaciones WHERE Numero = @Numero AND CedulaJuridica = @CedulaJuridica)
    BEGIN
        RAISERROR('Ya existe una habitación con ese número en este hotel', 16, 1)
        RETURN
    END
    
    -- Verificar que el tipo de habitación pertenezca al hotel
    IF NOT EXISTS (SELECT 1 FROM TipoHabitacion WHERE TipoHabitacionID = @TipoHabitacionID AND CedulaJuridica = @CedulaJuridica)
    BEGIN
        RAISERROR('El tipo de habitación no pertenece a este hotel', 16, 1)
        RETURN
    END
    
    -- Insertar la habitación
    INSERT INTO Habitaciones (Numero, CedulaJuridica, TipoHabitacionID)
    VALUES (@Numero, @CedulaJuridica, @TipoHabitacionID)
    
    SET @HabitacionID = SCOPE_IDENTITY()
END

GO

CREATE PROCEDURE sp_ObtenerHabitaciones
AS
BEGIN
    SELECT h.*, e.Nombre as NombreHotel, t.Nombre as TipoHabitacion
    FROM Habitaciones h
    INNER JOIN EmpresaHotel e ON h.CedulaJuridica = e.CedulaJuridica
    INNER JOIN TipoHabitacion t ON h.TipoHabitacionID = t.TipoHabitacionID
END
GO


CREATE PROCEDURE sp_ActualizarHabitacion
    @HabitacionID int,
    @Numero int,
    @CedulaJuridica varchar(20),
    @TipoHabitacionID int
AS
BEGIN
    UPDATE Habitaciones 
    SET Numero = @Numero, CedulaJuridica = @CedulaJuridica, 
        TipoHabitacionID = @TipoHabitacionID
    WHERE HabitacionID = @HabitacionID
END
GO


CREATE PROCEDURE sp_EliminarHabitacion
    @HabitacionID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM Reservacion WHERE HabitacionID = @HabitacionID)
    BEGIN
        RAISERROR('No se puede eliminar: La habitación tiene reservaciones', 16, 1)
        RETURN
    END
    
    DELETE FROM Habitaciones WHERE HabitacionID = @HabitacionID
END
GO

-- ==========================================
-- CRUD PARA RESERVACION
-- ==========================================

CREATE PROCEDURE sp_InsertarReservacion
    @CedulaID varchar(20),
    @HabitacionID int,
    @FechaIngreso Datetime,
    @CantidadPersonas int,
    @PoseeVehiculo bit = 0,
    @FechaSalida Datetime,
    @Estado varchar(20) = 'ACTIVO',
	@ReservacionID int OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Reservacion (CedulaID, HabitacionID, FechaIngreso,
                           CantidadPersonas, PoseeVehiculo, FechaSalida, Estado)
    VALUES (@CedulaID, @HabitacionID, @FechaIngreso,
            @CantidadPersonas, @PoseeVehiculo, @FechaSalida, @Estado)

	SET @ReservacionID = SCOPE_IDENTITY()
END
GO

CREATE PROCEDURE sp_ObtenerReservaciones
AS
BEGIN
    SELECT r.*, c.Nombre + ' ' + c.PrimerApellido as NombreCliente,
           h.Numero as NumeroHabitacion, e.Nombre as NombreHotel
    FROM Reservacion r
    INNER JOIN Cliente c ON r.CedulaID = c.CedulaID
    INNER JOIN Habitaciones h ON r.HabitacionID = h.HabitacionID
    INNER JOIN EmpresaHotel e ON h.CedulaJuridica = e.CedulaJuridica
END
GO


CREATE PROCEDURE sp_ActualizarReservacion
    @ReservacionID int,
    @CedulaID varchar(20),
    @HabitacionID int,
    @FechaIngreso Datetime,
    @CantidadPersonas int,
    @PoseeVehiculo bit = 0,
    @FechaSalida Datetime,
    @Estado varchar(20) = 'ACTIVO', 
    @FechaCheckOut datetime = NULL   
AS
BEGIN
    UPDATE Reservacion 
    SET CedulaID = @CedulaID,
        HabitacionID = @HabitacionID, FechaIngreso = @FechaIngreso,
        CantidadPersonas = @CantidadPersonas, PoseeVehiculo = @PoseeVehiculo,
        FechaSalida = @FechaSalida, Estado = @Estado, FechaCheckOut = @FechaCheckOut
    WHERE ReservacionID = @ReservacionID
END
GO


-- DELETE
CREATE PROCEDURE sp_EliminarReservacion
    @ReservacionID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM Facturacion WHERE ReservacionID = @ReservacionID)
    BEGIN
        RAISERROR('No se puede eliminar: La reservación tiene facturación', 16, 1)
        RETURN
    END
    
    DELETE FROM Reservacion WHERE ReservacionID = @ReservacionID
END
GO

USE SistemaHoteleria
GO

-- ==========================================
-- CRUD PARA REDSOCIAL
-- ==========================================


CREATE PROCEDURE sp_InsertarRedSocial
    @Nombre varchar(50)
AS
BEGIN
    INSERT INTO RedSocial (Nombre)
    VALUES (@Nombre)
END
GO


CREATE PROCEDURE sp_ObtenerRedesSociales
AS
BEGIN
    SELECT * FROM RedSocial
END
GO


CREATE PROCEDURE sp_ActualizarRedSocial
    @RedSocialID int,
    @Nombre varchar(50)
AS
BEGIN
    UPDATE RedSocial 
    SET Nombre = @Nombre
    WHERE RedSocialID = @RedSocialID
END
GO


CREATE PROCEDURE sp_EliminarRedSocial
    @RedSocialID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM RedSocialHotel WHERE RedSocialID = @RedSocialID)
    BEGIN
        RAISERROR('No se puede eliminar: Hay hoteles usando esta red social', 16, 1)
        RETURN
    END
    
    DELETE FROM RedSocial WHERE RedSocialID = @RedSocialID
END
GO

-- ==========================================
-- CRUD PARA COMODIDADES
-- ==========================================


CREATE PROCEDURE sp_InsertarComodidad
    @Nombre varchar(50)
AS
BEGIN
    INSERT INTO Comodidades (Nombre)
    VALUES (@Nombre)
END
GO


CREATE PROCEDURE sp_ObtenerComodidades
AS
BEGIN
    SELECT * FROM Comodidades
END
GO


CREATE PROCEDURE sp_ActualizarComodidad
    @ComodidadID int,
    @Nombre varchar(50)
AS
BEGIN
    UPDATE Comodidades 
    SET Nombre = @Nombre
    WHERE ComodidadID = @ComodidadID
END
GO


CREATE PROCEDURE sp_EliminarComodidad
    @ComodidadID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM TipoHabitacionComodidad WHERE ComodidadID = @ComodidadID)
    BEGIN
        RAISERROR('No se puede eliminar: Esta comodidad está siendo usada en tipos de habitación', 16, 1)
        RETURN
    END
    
    DELETE FROM Comodidades WHERE ComodidadID = @ComodidadID
END
GO

-- ==========================================
-- CRUD PARA METODOPAGO
-- ==========================================


CREATE PROCEDURE sp_InsertarMetodoPago
    @NombreMetodo varchar(50),
    @DetallesAdicionales varchar(255) = NULL
AS
BEGIN
    INSERT INTO MetodoPago (NombreMetodo, DetallesAdicionales)
    VALUES (@NombreMetodo, @DetallesAdicionales)
END
GO


CREATE PROCEDURE sp_ObtenerMetodosPago
AS
BEGIN
    SELECT * FROM MetodoPago
END
GO


CREATE PROCEDURE sp_ActualizarMetodoPago
    @MetodoPagoID int,
    @NombreMetodo varchar(50),
    @DetallesAdicionales varchar(255) = NULL
AS
BEGIN
    UPDATE MetodoPago 
    SET NombreMetodo = @NombreMetodo, DetallesAdicionales = @DetallesAdicionales
    WHERE MetodoPagoID = @MetodoPagoID
END
GO


CREATE PROCEDURE sp_EliminarMetodoPago
    @MetodoPagoID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM Facturacion WHERE MetodoPagoID = @MetodoPagoID)
    BEGIN
        RAISERROR('No se puede eliminar: Este método de pago tiene facturas asociadas', 16, 1)
        RETURN
    END
    
    DELETE FROM MetodoPago WHERE MetodoPagoID = @MetodoPagoID
END
GO

-- ==========================================
-- CRUD PARA FACTURACION
-- ==========================================


CREATE PROCEDURE sp_InsertarFacturacion
    @ReservacionID int,
    @MetodoPagoID int,
    @ImporteTotal decimal(10,2),
    @FechaEmision datetime = NULL,
    @EstadoPago varchar(20) = 'PENDIENTE'  -- Agregar parámetro EstadoPago
AS
BEGIN
    IF @FechaEmision IS NULL
        SET @FechaEmision = GETDATE()
        
    INSERT INTO Facturacion (ReservacionID, MetodoPagoID, FechaEmision, ImporteTotal, EstadoPago)
    VALUES (@ReservacionID, @MetodoPagoID, @FechaEmision, @ImporteTotal, @EstadoPago)
END


GO


CREATE PROCEDURE sp_ObtenerFacturaciones
AS
BEGIN
    SELECT f.*, r.NumeroReserva, mp.NombreMetodo,
           c.Nombre + ' ' + c.PrimerApellido as NombreCliente
    FROM Facturacion f
    INNER JOIN Reservacion r ON f.ReservacionID = r.ReservacionID
    INNER JOIN MetodoPago mp ON f.MetodoPagoID = mp.MetodoPagoID
    INNER JOIN Cliente c ON r.CedulaID = c.CedulaID
END
GO


CREATE PROCEDURE sp_ActualizarFacturacion
    @FacturacionID int,
    @ReservacionID int,
    @MetodoPagoID int,
    @ImporteTotal decimal(10,2),
    @FechaEmision datetime,
    @EstadoPago varchar(20) = 'PENDIENTE'  -- Agregar parámetro EstadoPago
AS
BEGIN
    UPDATE Facturacion 
    SET ReservacionID = @ReservacionID, MetodoPagoID = @MetodoPagoID,
        ImporteTotal = @ImporteTotal, FechaEmision = @FechaEmision, EstadoPago = @EstadoPago
    WHERE FacturacionID = @FacturacionID
END
GO

CREATE PROCEDURE sp_CambiarEstadoReservacion
    @ReservacionID int,
    @NuevoEstado varchar(20)
AS
BEGIN
    IF @NuevoEstado NOT IN ('ACTIVO', 'CERRADO')
    BEGIN
        RAISERROR('Estado inválido. Use: ACTIVO, CERRADO', 16, 1)
        RETURN
    END
    
    UPDATE Reservacion 
    SET Estado = @NuevoEstado
    WHERE ReservacionID = @ReservacionID
    
END
GO

-- Nuevo procedimiento para cambiar estado de pago
CREATE PROCEDURE sp_CambiarEstadoPago
    @FacturacionID int,
    @NuevoEstado varchar(20)
AS
BEGIN
    IF @NuevoEstado NOT IN ('PENDIENTE', 'PAGADO')
    BEGIN
        RAISERROR('Estado de pago inválido. Use: PENDIENTE, PAGADO', 16, 1)
        RETURN
    END
    
    UPDATE Facturacion 
    SET EstadoPago = @NuevoEstado
    WHERE FacturacionID = @FacturacionID
    
    PRINT 'Estado de pago actualizado a: ' + @NuevoEstado
END
GO

CREATE PROCEDURE sp_EliminarFacturacion
    @FacturacionID int
AS
BEGIN
    DELETE FROM Facturacion WHERE FacturacionID = @FacturacionID
END
GO

-- ==========================================
-- CRUD PARA EMPRESAACTIVIDAD
-- ==========================================


CREATE PROCEDURE sp_InsertarEmpresaActividad
    @CedulaJuridica varchar(20),
    @Nombre varchar(50),
    @CorreoElectronico varchar(100),
    @Telefono varchar(20),
    @NombreContacto varchar(100),
    @Provincia varchar(50),
    @Canton varchar(50),
    @Distrito varchar(50),
    @SeniasExactas text,
    @Precio decimal(10,2),
	@Descripcion text
AS
BEGIN

    IF EXISTS (SELECT 1 FROM EmpresaActividad WHERE CedulaJuridica = @CedulaJuridica)
    BEGIN
        RAISERROR('Ya existe una empresa con esta cédula', 16, 1)
        RETURN
    END

	IF EXISTS (SELECT 1 FROM EmpresaActividad WHERE CorreoElectronico = @CorreoElectronico)
    BEGIN
        RAISERROR('Ya existe una empresa con este correo', 16, 1)
        RETURN
    END

    INSERT INTO EmpresaActividad (CedulaJuridica, Nombre, CorreoElectronico, Telefono,
                                NombreContacto, Provincia, Canton, Distrito, 
                                SeniasExactas, Precio, Descripcion)
    VALUES (@CedulaJuridica, @Nombre, @CorreoElectronico, @Telefono,
            @NombreContacto, @Provincia, @Canton, @Distrito, 
            @SeniasExactas, @Precio, @Descripcion)
END
GO



CREATE PROCEDURE sp_ObtenerEmpresasActividad
AS
BEGIN
    SELECT * FROM EmpresaActividad
END
GO


CREATE PROCEDURE sp_ActualizarEmpresaActividad
    @CedulaJuridica varchar(20),
    @Nombre varchar(50),
    @CorreoElectronico varchar(100),
    @Telefono varchar(20),
    @NombreContacto varchar(100),
    @Provincia varchar(50),
    @Canton varchar(50),
    @Distrito varchar(50),
    @SeniasExactas text,
    @Precio decimal(10,2),
	@Descripcion text
AS
BEGIN
    UPDATE EmpresaActividad 
    SET Nombre = @Nombre, CorreoElectronico = @CorreoElectronico,
        Telefono = @Telefono, NombreContacto = @NombreContacto,
        Provincia = @Provincia, Canton = @Canton, Distrito = @Distrito,
        SeniasExactas = @SeniasExactas, Precio = @Precio, Descripcion = @Descripcion
    WHERE CedulaJuridica = @CedulaJuridica
END
GO




CREATE PROCEDURE sp_EliminarEmpresaActividad
    @CedulaJuridica varchar(20)
AS
BEGIN
    -- Verificar dependencias y eliminar registros relacionados
    DELETE FROM EmpresaActividadServicio WHERE CedulaJuridica = @CedulaJuridica
    DELETE FROM EmpresaActividadTipo WHERE CedulaJuridica = @CedulaJuridica
    
    -- Eliminar empresa
    DELETE FROM EmpresaActividad WHERE CedulaJuridica = @CedulaJuridica
END
GO

-- ==========================================
-- CRUD PARA TIPOACTIVIDAD
-- ==========================================


CREATE PROCEDURE sp_InsertarTipoActividad
    @Nombre varchar(50),
    @Descripcion text
AS
BEGIN
    INSERT INTO TipoActividad (Nombre, Descripcion)
    VALUES (@Nombre, @Descripcion)
END
GO


CREATE PROCEDURE sp_ObtenerTiposActividad
AS
BEGIN
    SELECT * FROM TipoActividad
END
GO


CREATE PROCEDURE sp_ActualizarTipoActividad
    @TipoActividadID int,
    @Nombre varchar(50),
    @Descripcion text
AS
BEGIN
    UPDATE TipoActividad 
    SET Nombre = @Nombre, Descripcion = @Descripcion
    WHERE TipoActividadID = @TipoActividadID
END
GO


CREATE PROCEDURE sp_EliminarTipoActividad
    @TipoActividadID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM EmpresaActividadTipo WHERE TipoActividadID = @TipoActividadID)
    BEGIN
        RAISERROR('No se puede eliminar: Hay empresas que ofrecen este tipo de actividad', 16, 1)
        RETURN
    END
    
    DELETE FROM TipoActividad WHERE TipoActividadID = @TipoActividadID
END
GO

-- ==========================================
-- CRUD PARA SERVICIOACTIVIDAD
-- ==========================================

CREATE PROCEDURE sp_InsertarServicioActividad
    @Nombre varchar(50)
AS
BEGIN
    INSERT INTO ServicioActividad (Nombre)
    VALUES (@Nombre)
END
GO


CREATE PROCEDURE sp_ObtenerServiciosActividad
AS
BEGIN
    SELECT * FROM ServicioActividad
END
GO


CREATE PROCEDURE sp_ActualizarServicioActividad
    @ServicioActividadID int,
    @Nombre varchar(50)
AS
BEGIN
    UPDATE ServicioActividad 
    SET Nombre = @Nombre
    WHERE ServicioActividadID = @ServicioActividadID
END
GO


CREATE PROCEDURE sp_EliminarServicioActividad
    @ServicioActividadID int
AS
BEGIN
    -- Verificar dependencias
    IF EXISTS (SELECT 1 FROM EmpresaActividadServicio WHERE ServicioActividadID = @ServicioActividadID)
    BEGIN
        RAISERROR('No se puede eliminar: Hay empresas que ofrecen este servicio', 16, 1)
        RETURN
    END
    
    DELETE FROM ServicioActividad WHERE ServicioActividadID = @ServicioActividadID
END
GO


USE SistemaHoteleria
GO

-- ==========================================
-- CRUDS DE RELACIONES
-- ==========================================


-- ==========================================
-- CRUD PARA HOTELSERVICIOS
-- ==========================================


CREATE PROCEDURE sp_AsignarServicioAHotel
    @CedulaJuridica varchar(20),
    @ServicioID int
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM HotelServicios WHERE CedulaJuridica = @CedulaJuridica AND ServicioID = @ServicioID)
    BEGIN
        INSERT INTO HotelServicios (CedulaJuridica, ServicioID)
        VALUES (@CedulaJuridica, @ServicioID)
    END
    ELSE
    BEGIN
        RAISERROR('Esta relación ya existe', 16, 1)
    END
END
GO


CREATE PROCEDURE sp_ObtenerHotelServicios
AS
BEGIN
    SELECT hs.*, e.Nombre as NombreHotel, s.Nombre as NombreServicio
    FROM HotelServicios hs
    INNER JOIN EmpresaHotel e ON hs.CedulaJuridica = e.CedulaJuridica
    INNER JOIN Servicios s ON hs.ServicioID = s.ServicioID
END
GO

CREATE PROCEDURE sp_ObtenerServiciosDeHotel
    @CedulaJuridica varchar(20)
AS
BEGIN
    SELECT s.ServicioID, s.Nombre
    FROM Servicios s
    INNER JOIN HotelServicios hs ON s.ServicioID = hs.ServicioID
    WHERE hs.CedulaJuridica = @CedulaJuridica
END
GO


CREATE PROCEDURE sp_RemoverServicioDeHotel
    @CedulaJuridica varchar(20),
    @ServicioID int
AS
BEGIN
    DELETE FROM HotelServicios 
    WHERE CedulaJuridica = @CedulaJuridica AND ServicioID = @ServicioID
END
GO

-- ==========================================
-- CRUD PARA FOTOSHABITACION 
-- ==========================================


CREATE PROCEDURE sp_InsertarFotoHabitacion
    @Fotos VARBINARY(MAX),
    @TipoHabitacionID int
AS
BEGIN
    INSERT INTO FotosHabitacion (Fotos, TipoHabitacionID)
    VALUES (@Fotos, @TipoHabitacionID)
END
GO

CREATE PROCEDURE sp_ObtenerFotosHabitacion
AS
BEGIN
    SELECT f.FotoID, f.TipoHabitacionID, t.Nombre as TipoHabitacion
    FROM FotosHabitacion f
    INNER JOIN TipoHabitacion t ON f.TipoHabitacionID = t.TipoHabitacionID
END
GO

CREATE PROCEDURE sp_ObtenerFotosDeHabitacion
    @TipoHabitacionID int
AS
BEGIN
    SELECT * FROM FotosHabitacion 
    WHERE TipoHabitacionID = @TipoHabitacionID
END
GO


CREATE PROCEDURE sp_ActualizarFotoHabitacion
    @FotoID int,
    @Fotos varbinary(max),
    @TipoHabitacionID int
AS
BEGIN
    UPDATE FotosHabitacion 
    SET Fotos = @Fotos, TipoHabitacionID = @TipoHabitacionID
    WHERE FotoID = @FotoID
END
GO


CREATE PROCEDURE sp_EliminarFotoHabitacion
    @FotoID int
AS
BEGIN
    DELETE FROM FotosHabitacion WHERE FotoID = @FotoID
END
GO

-- ==========================================
-- CRUD PARA TELEFONOSCLIENTE 
-- ==========================================


CREATE PROCEDURE sp_InsertarTelefonoCliente
    @CedulaID varchar(20),
    @Numero varchar(20),
    @CodigoPais varchar(5)
AS
BEGIN
    -- Verificar que no se excedan 3 teléfonos por cliente
    IF (SELECT COUNT(*) FROM TelefonosCliente WHERE CedulaID = @CedulaID) >= 3
    BEGIN
        RAISERROR('Un cliente no puede tener más de 3 teléfonos', 16, 1)
        RETURN
    END
    
    INSERT INTO TelefonosCliente (CedulaID, Numero, CodigoPais)
    VALUES (@CedulaID, @Numero, @CodigoPais)
END
GO


CREATE PROCEDURE sp_ObtenerTelefonosCliente
AS
BEGIN
    SELECT tc.*, c.Nombre + ' ' + c.PrimerApellido as NombreCliente
    FROM TelefonosCliente tc
    INNER JOIN Cliente c ON tc.CedulaID = c.CedulaID
END
GO

CREATE PROCEDURE sp_ObtenerTelefonosDeCliente
    @CedulaID varchar(20)
AS
BEGIN
    SELECT * FROM TelefonosCliente WHERE CedulaID = @CedulaID
END
GO


CREATE PROCEDURE sp_ActualizarTelefonoCliente
    @TelefonoCID int,
    @Numero varchar(20),
    @CodigoPais varchar(5)
AS
BEGIN
    UPDATE TelefonosCliente 
    SET Numero = @Numero, CodigoPais = @CodigoPais
    WHERE TelefonoCID = @TelefonoCID
END
GO


CREATE PROCEDURE sp_EliminarTelefonoCliente
    @TelefonoCID int
AS
BEGIN
    DELETE FROM TelefonosCliente WHERE TelefonoCID = @TelefonoCID
END
GO

-- ==========================================
-- CRUD PARA TELEFONOSEMPRESA 
-- ==========================================


CREATE PROCEDURE sp_InsertarTelefonoEmpresa
    @Numero varchar(20),
    @CedulaJuridica varchar(20)
AS
BEGIN
    INSERT INTO TelefonosEmpresa (Numero, CedulaJuridica)
    VALUES (@Numero, @CedulaJuridica)
END
GO


CREATE PROCEDURE sp_ObtenerTelefonosEmpresa
AS
BEGIN
    SELECT te.*, e.Nombre as NombreEmpresa
    FROM TelefonosEmpresa te
    INNER JOIN EmpresaHotel e ON te.CedulaJuridica = e.CedulaJuridica
END
GO

CREATE PROCEDURE sp_ObtenerTelefonosDeEmpresa
    @CedulaJuridica varchar(20)
AS
BEGIN
    SELECT * FROM TelefonosEmpresa WHERE CedulaJuridica = @CedulaJuridica
END
GO


CREATE PROCEDURE sp_ActualizarTelefonoEmpresa
    @TelefonoID int,
    @Numero varchar(20)
AS
BEGIN
    UPDATE TelefonosEmpresa 
    SET Numero = @Numero
    WHERE TelefonoID = @TelefonoID
END
GO


CREATE PROCEDURE sp_EliminarTelefonoEmpresa
    @TelefonoID int
AS
BEGIN
    DELETE FROM TelefonosEmpresa WHERE TelefonoID = @TelefonoID
END
GO

-- ==========================================
-- CRUD PARA REDSOCIALHOTEL 
-- ==========================================


CREATE PROCEDURE sp_AsignarRedSocialAHotel
    @NombreUsuario varchar(150),
    @RedSocialID int,
    @CedulaJuridica varchar(20)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM RedSocialHotel WHERE RedSocialID = @RedSocialID AND CedulaJuridica = @CedulaJuridica)
    BEGIN
        INSERT INTO RedSocialHotel (NombreUsuario, RedSocialID, CedulaJuridica)
        VALUES (@NombreUsuario, @RedSocialID, @CedulaJuridica)
    END
    ELSE
    BEGIN
        RAISERROR('Esta relación ya existe', 16, 1)
    END
END
GO


CREATE PROCEDURE sp_ObtenerRedesSocialesHotel
AS
BEGIN
    SELECT rsh.*, rs.Nombre as NombreRedSocial, e.Nombre as NombreHotel
    FROM RedSocialHotel rsh
    INNER JOIN RedSocial rs ON rsh.RedSocialID = rs.RedSocialID
    INNER JOIN EmpresaHotel e ON rsh.CedulaJuridica = e.CedulaJuridica
END
GO


CREATE PROCEDURE sp_ActualizarRedSocialHotel
    @NombreUsuario varchar(150),
    @RedSocialID int,
    @CedulaJuridica varchar(20)
AS
BEGIN
    UPDATE RedSocialHotel 
    SET NombreUsuario = @NombreUsuario
    WHERE RedSocialID = @RedSocialID AND CedulaJuridica = @CedulaJuridica
END
GO


CREATE PROCEDURE sp_EliminarmoverRedSocialDeHotel
    @RedSocialID int,
    @CedulaJuridica varchar(20)
AS
BEGIN
    DELETE FROM RedSocialHotel 
    WHERE RedSocialID = @RedSocialID AND CedulaJuridica = @CedulaJuridica
END
GO

-- ==========================================
-- CRUD PARA TIPOHABITACIONCOMODIDAD 
-- ==========================================


CREATE PROCEDURE sp_AsignarComodidadATipoHabitacion
    @TipoHabitacionID int,
    @ComodidadID int
AS
BEGIN
    SET NOCOUNT ON;
    
    IF NOT EXISTS (SELECT 1 FROM TipoHabitacionComodidad 
                   WHERE TipoHabitacionID = @TipoHabitacionID 
                   AND ComodidadID = @ComodidadID)
    BEGIN
        INSERT INTO TipoHabitacionComodidad (TipoHabitacionID, ComodidadID)
        VALUES (@TipoHabitacionID, @ComodidadID)
    END
END

GO

CREATE PROCEDURE sp_ObtenerTipoHabitacionComodidades
AS
BEGIN
    SELECT thc.*, th.Nombre as TipoHabitacion, c.Nombre as Comodidad
    FROM TipoHabitacionComodidad thc
    INNER JOIN TipoHabitacion th ON thc.TipoHabitacionID = th.TipoHabitacionID
    INNER JOIN Comodidades c ON thc.ComodidadID = c.ComodidadID
END
GO


CREATE PROCEDURE sp_EliminarComodidadDeTipoHabitacion
    @TipoHabitacionID int,
    @ComodidadID int
AS
BEGIN
    DELETE FROM TipoHabitacionComodidad 
    WHERE TipoHabitacionID = @TipoHabitacionID AND ComodidadID = @ComodidadID
END
GO

-- ==========================================
-- CRUD PARA EMPRESAACTIVIDADTIPO 
-- ==========================================


CREATE PROCEDURE sp_AsignarTipoActividadAEmpresa
    @CedulaJuridica varchar(20),
    @TipoActividadID int
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM EmpresaActividadTipo WHERE CedulaJuridica = @CedulaJuridica AND TipoActividadID = @TipoActividadID)
    BEGIN
        INSERT INTO EmpresaActividadTipo (CedulaJuridica, TipoActividadID)
        VALUES (@CedulaJuridica, @TipoActividadID)
    END
    ELSE
    BEGIN
        RAISERROR('Esta relación ya existe', 16, 1)
    END
END
GO


CREATE PROCEDURE sp_ObtenerEmpresaActividadTipos
AS
BEGIN
    SELECT eat.*, ea.Nombre as NombreEmpresa, ta.Nombre as TipoActividad
    FROM EmpresaActividadTipo eat
    INNER JOIN EmpresaActividad ea ON eat.CedulaJuridica = ea.CedulaJuridica
    INNER JOIN TipoActividad ta ON eat.TipoActividadID = ta.TipoActividadID
END
GO


CREATE PROCEDURE sp_RemoverTipoActividadDeEmpresa
    @CedulaJuridica varchar(20),
    @TipoActividadID int
AS
BEGIN
    DELETE FROM EmpresaActividadTipo 
    WHERE CedulaJuridica = @CedulaJuridica AND TipoActividadID = @TipoActividadID
END
GO

-- ==========================================
-- CRUD PARA EMPRESAACTIVIDADSERVICIO 
-- ==========================================


CREATE PROCEDURE sp_AsignarServicioActividadAEmpresa
    @CedulaJuridica varchar(20),
    @ServicioActividadID int
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM EmpresaActividadServicio WHERE CedulaJuridica = @CedulaJuridica AND ServicioActividadID = @ServicioActividadID)
    BEGIN
        INSERT INTO EmpresaActividadServicio (CedulaJuridica, ServicioActividadID)
        VALUES (@CedulaJuridica, @ServicioActividadID)
    END
    ELSE
    BEGIN
        RAISERROR('Esta relación ya existe', 16, 1)
    END
END
GO


CREATE PROCEDURE sp_ObtenerEmpresaActividadServicios
AS
BEGIN
    SELECT eas.*, ea.Nombre as NombreEmpresa, sa.Nombre as ServicioActividad
    FROM EmpresaActividadServicio eas
    INNER JOIN EmpresaActividad ea ON eas.CedulaJuridica = ea.CedulaJuridica
    INNER JOIN ServicioActividad sa ON eas.ServicioActividadID = sa.ServicioActividadID
END
GO


CREATE PROCEDURE sp_RemoverServicioActividadDeEmpresa
    @CedulaJuridica varchar(20),
    @ServicioActividadID int
AS
BEGIN
    DELETE FROM EmpresaActividadServicio 
    WHERE CedulaJuridica = @CedulaJuridica AND ServicioActividadID = @ServicioActividadID
END
GO


