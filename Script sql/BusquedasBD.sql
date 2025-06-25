USE SistemaHoteleria

GO
-- 1. Búsqueda básica de hoteles disponibles
CREATE PROCEDURE sp_BuscarHotelesDisponibles
    @Ubicacion VARCHAR(200),
    @FechaCheckIn DATETIME,
    @FechaCheckOut DATETIME,
    @CantidadPersonas INT
AS
BEGIN
    SELECT 
        HI.CedulaJuridica,
        HI.Nombre,
        HI.TipoHotel,
        HI.UbicacionCompleta,
        HI.CorreoElectronico,
        HI.URLSitioWeb,
        MIN(HD.Precio) AS PrecioMinimo,
        MAX(HD.Precio) AS PrecioMaximo
    FROM HotelesInfo HI
    JOIN HabitacionesDisponibles HD ON HI.CedulaJuridica = HD.CedulaJuridica
    WHERE 
        (HI.UbicacionCompleta LIKE '%' + @Ubicacion + '%')
        AND HD.CapacidadTotal >= @CantidadPersonas
        AND HD.HabitacionID NOT IN (
            SELECT R.HabitacionID 
            FROM Reservacion R
            WHERE (R.FechaIngreso <= @FechaCheckOut AND R.FechaSalida >= @FechaCheckIn)
        )
    GROUP BY 
        HI.CedulaJuridica, HI.Nombre, HI.TipoHotel, 
        HI.UbicacionCompleta, HI.CorreoElectronico, HI.URLSitioWeb
    ORDER BY HI.Nombre;
END;

GO
-- 2. Búsqueda avanzada con filtros adicionales
CREATE PROCEDURE sp_BuscarHotelesAvanzado
    @Ubicacion VARCHAR(200) = '',
    @FechaCheckIn DATETIME,
    @FechaCheckOut DATETIME,
    @CantidadPersonas INT,
    @ServiciosIDs VARCHAR(100) = NULL,
    @ComodidadesIDs VARCHAR(100) = NULL,
    @PrecioMinimo DECIMAL(10,2) = NULL,
    @PrecioMaximo DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tabla temporal para hoteles que cumplen criterios básicos
    CREATE TABLE #HotelesValidos (
        CedulaJuridica VARCHAR(20) PRIMARY KEY,
        Nombre VARCHAR(200),
        TipoHotel VARCHAR(100),
        UbicacionCompleta VARCHAR(500),
        CorreoElectronico VARCHAR(150),
        URLSitioWeb VARCHAR(200)
    );
    
    -- Insertar hoteles que tienen habitaciones disponibles en las fechas (AGREGADO DISTINCT)
    INSERT INTO #HotelesValidos
    SELECT DISTINCT
        HI.CedulaJuridica,
        HI.Nombre,
        HI.TipoHotel,
        HI.UbicacionCompleta,
        HI.CorreoElectronico,
        HI.URLSitioWeb
    FROM HotelesInfo HI
    INNER JOIN HabitacionesDisponibles HD ON HI.CedulaJuridica = HD.CedulaJuridica
    WHERE 
        -- Filtro de ubicación
        (@Ubicacion = '' OR HI.UbicacionCompleta LIKE '%' + @Ubicacion + '%')
        -- Filtro de capacidad
        AND HD.CapacidadTotal >= @CantidadPersonas
        -- Filtro de precios
        AND (@PrecioMinimo IS NULL OR HD.Precio >= @PrecioMinimo)
        AND (@PrecioMaximo IS NULL OR HD.Precio <= @PrecioMaximo)
        -- Verificar disponibilidad (que no haya reservaciones en conflicto)
        AND NOT EXISTS (
            SELECT 1 
            FROM Reservacion R
            WHERE R.HabitacionID = HD.HabitacionID
                AND R.FechaIngreso < @FechaCheckOut 
                AND R.FechaSalida > @FechaCheckIn
        );
    
    -- Aplicar filtro de servicios si se especifica
    IF @ServiciosIDs IS NOT NULL AND @ServiciosIDs != ''
    BEGIN
        DELETE FROM #HotelesValidos
        WHERE CedulaJuridica NOT IN (
            SELECT DISTINCT hs.CedulaJuridica
            FROM HotelServicios hs
            WHERE hs.ServicioID IN (
                SELECT CAST(value AS INT) 
                FROM STRING_SPLIT(@ServiciosIDs, ',')
                WHERE value != '' AND ISNUMERIC(value) = 1
            )
            GROUP BY hs.CedulaJuridica
            HAVING COUNT(DISTINCT hs.ServicioID) = (
                SELECT COUNT(*) 
                FROM STRING_SPLIT(@ServiciosIDs, ',')
                WHERE value != '' AND ISNUMERIC(value) = 1
            )
        );
    END
    
    -- Aplicar filtro de comodidades si se especifica
    IF @ComodidadesIDs IS NOT NULL AND @ComodidadesIDs != ''
    BEGIN
        DELETE FROM #HotelesValidos
        WHERE CedulaJuridica NOT IN (
            SELECT DISTINCT hd.CedulaJuridica
            FROM HabitacionesDisponibles hd
            INNER JOIN TipoHabitacionComodidad thc ON hd.TipoHabitacionID = thc.TipoHabitacionID
            WHERE thc.ComodidadID IN (
                SELECT CAST(value AS INT)
                FROM STRING_SPLIT(@ComodidadesIDs, ',')
                WHERE value != '' AND ISNUMERIC(value) = 1
            )
        );
    END
    
    -- Resultado final con precios
    SELECT 
        hv.CedulaJuridica,
        hv.Nombre,
        hv.TipoHotel,
        hv.UbicacionCompleta,
        hv.CorreoElectronico,
        hv.URLSitioWeb,
        MIN(hd.Precio) AS PrecioMinimo,
        MAX(hd.Precio) AS PrecioMaximo
    FROM #HotelesValidos hv
    INNER JOIN HabitacionesDisponibles hd ON hv.CedulaJuridica = hd.CedulaJuridica
    WHERE hd.CapacidadTotal >= @CantidadPersonas
        AND (@PrecioMinimo IS NULL OR hd.Precio >= @PrecioMinimo)
        AND (@PrecioMaximo IS NULL OR hd.Precio <= @PrecioMaximo)
        AND NOT EXISTS (
            SELECT 1 
            FROM Reservacion R
            WHERE R.HabitacionID = hd.HabitacionID
                AND R.FechaIngreso < @FechaCheckOut 
                AND R.FechaSalida > @FechaCheckIn
        )
    GROUP BY 
        hv.CedulaJuridica, hv.Nombre, hv.TipoHotel, 
        hv.UbicacionCompleta, hv.CorreoElectronico, hv.URLSitioWeb
    ORDER BY hv.Nombre;
    
    DROP TABLE #HotelesValidos;
END;

GO

drop procedure sp_ObtenerDetallesHotel

GO
-- 3. Información completa del hotel para reserva
CREATE PROCEDURE sp_ObtenerDetallesHotel
    @CedulaJuridica VARCHAR(20),
    @FechaCheckIn DATETIME,
    @FechaCheckOut DATETIME,
    @CantidadPersonas INT
AS
BEGIN
    -- Información general del hotel
    SELECT 
        HI.CedulaJuridica,
        HI.Nombre,
        HI.TipoHotel,
        CAST(HI.UbicacionCompleta AS VARCHAR(MAX)) AS UbicacionCompleta,
        --CAST(HI.SeniasExactas AS VARCHAR(MAX)) AS SeniasExactas,
        --HI.ReferenciaGPS,
        HI.CorreoElectronico,
        HI.URLSitioWeb
    FROM HotelesInfo HI
    WHERE HI.CedulaJuridica = @CedulaJuridica;

    -- Teléfonos del hotel
    SELECT Numero 
    FROM TelefonosEmpresa 
    WHERE CedulaJuridica = @CedulaJuridica;

    -- Servicios del hotel (para la sección "Servicios Incluidos")
    SELECT S.ServicioID, S.Nombre AS Servicio
    FROM HotelesServicios HS
    INNER JOIN Servicios S ON HS.ServicioID = S.ServicioID
    WHERE HS.CedulaJuridica = @CedulaJuridica;

    -- Redes sociales
    SELECT RS.Nombre AS RedSocial, RSH.NombreUsuario
    FROM RedSocialHotel RSH
    INNER JOIN RedSocial RS ON RSH.RedSocialID = RS.RedSocialID
    WHERE RSH.CedulaJuridica = @CedulaJuridica;

    -- Habitaciones disponibles con información completa para el precio
    SELECT 
        HD.HabitacionID,
		HD.TipoHabitacionID,
        HD.Numero,
        TH.Nombre AS TipoHabitacion,
        CAST(TH.Descripcion AS VARCHAR(MAX)) AS Descripcion,
        HD.Precio AS PrecioPorNoche,
        HD.CapacidadTotal,
        DATEDIFF(day, @FechaCheckIn, @FechaCheckOut) AS NumeroNoches,
        DATEDIFF(day, @FechaCheckIn, @FechaCheckOut) * HD.Precio AS PrecioTotal,
        -- Campos adicionales para mostrar información detallada
        @FechaCheckIn AS FechaCheckIn,
        @FechaCheckOut AS FechaCheckOut,
        @CantidadPersonas AS CantidadPersonas
    FROM HabitacionesDisponibles HD
    INNER JOIN TipoHabitacion TH ON HD.TipoHabitacionID = TH.TipoHabitacionID
    WHERE 
        HD.CedulaJuridica = @CedulaJuridica
        AND HD.CapacidadTotal >= @CantidadPersonas
        AND HD.HabitacionID NOT IN (
            SELECT R.HabitacionID
            FROM Reservacion R
            WHERE (R.FechaIngreso <= @FechaCheckOut AND R.FechaSalida >= @FechaCheckIn)
        )
	order by HD.CapacidadTotal ASC, HD.Precio ASC;

    -- Tipos de cama por habitación disponible (para mostrar configuración)
    SELECT 
        HD.HabitacionID,
        TC.Nombre AS TipoCama,
        TC.Capacidad AS CapacidadCama,
        TH.Cantidad AS CantidadCamas,
        TH.Cantidad * TC.Capacidad AS CapacidadTotal
    FROM HabitacionesDisponibles HD
    INNER JOIN TipoHabitacion TH ON HD.TipoHabitacionID = TH.TipoHabitacionID
    INNER JOIN TipoCama TC ON TH.TipoCamaID = TC.TipoCamaID
    WHERE 
        HD.CedulaJuridica = @CedulaJuridica
        AND HD.CapacidadTotal >= @CantidadPersonas
        AND HD.HabitacionID NOT IN (
            SELECT R.HabitacionID
            FROM Reservacion R
            WHERE (R.FechaIngreso <= @FechaCheckOut AND R.FechaSalida >= @FechaCheckIn)
        );

    -- Comodidades por habitación disponible (para mostrar servicios incluidos)
    SELECT 
        HD.HabitacionID,
        HC.ComodidadID,
        HC.Comodidad
    FROM HabitacionesDisponibles HD
    INNER JOIN HabitacionesComodidades HC ON HD.TipoHabitacionID = HC.TipoHabitacionID
    INNER JOIN Comodidades C ON HC.ComodidadID = C.ComodidadID
    WHERE 
        HD.CedulaJuridica = @CedulaJuridica
        AND HD.CapacidadTotal >= @CantidadPersonas
        AND HD.HabitacionID NOT IN (
            SELECT R.HabitacionID
            FROM Reservacion R
            WHERE (R.FechaIngreso <= @FechaCheckOut AND R.FechaSalida >= @FechaCheckIn)
        );

    -- Fotos de habitaciones disponibles
    SELECT 
		HD.HabitacionID,
		FH.FotoID, 
		FH.Fotos 
	FROM HabitacionesDisponibles HD
	INNER JOIN FotosHabitacion FH ON HD.TipoHabitacionID = FH.TipoHabitacionID
	WHERE 
		HD.CedulaJuridica = @CedulaJuridica
		AND HD.CapacidadTotal >= @CantidadPersonas
		AND HD.HabitacionID NOT IN (
			SELECT R.HabitacionID
			FROM Reservacion R
			WHERE (R.FechaIngreso <= @FechaCheckOut AND R.FechaSalida >= @FechaCheckIn)
		);
END;


GO


CREATE PROCEDURE sp_BuscarEmpresasActividad
    @Ubicacion VARCHAR(200)
AS
BEGIN
    SELECT 
        EA.CedulaJuridica,
        EA.Nombre,
        EA.UbicacionCompleta,
        EA.Telefono,
        EA.CorreoElectronico,
        EA.NombreContacto,
        EA.Precio
    FROM EmpresasActividad EA
    WHERE EA.UbicacionCompleta LIKE '%' + @Ubicacion + '%'
    ORDER BY EA.Nombre;
END;

GO


CREATE PROCEDURE sp_BuscarActividadesAvanzado
    @Ubicacion VARCHAR(200),
    @TipoActividadIDs VARCHAR(100) = NULL,
    @ServicioActividadIDs VARCHAR(100) = NULL,
    @PrecioMinimo DECIMAL(10,2) = NULL,
    @PrecioMaximo DECIMAL(10,2) = NULL
AS
BEGIN

    SELECT 
        EA.CedulaJuridica,
        EA.Nombre,
        EA.UbicacionCompleta,
        EA.Telefono,
        EA.CorreoElectronico,
        EA.NombreContacto,
        EA.Precio,
        EA.Descripcion
    FROM EmpresasActividad EA
    WHERE 
       
        (ISNULL(@Ubicacion, '') = '' OR EA.UbicacionCompleta LIKE '%' + @Ubicacion + '%')
        AND (ISNULL(@PrecioMinimo, 0) = 0 OR EA.Precio >= @PrecioMinimo)
        AND (ISNULL(@PrecioMaximo, 0) = 0 OR EA.Precio <= @PrecioMaximo)
        AND (
            ISNULL(@TipoActividadIDs, '') = '' 
            OR EA.CedulaJuridica IN (
                SELECT DISTINCT AS1.CedulaJuridica 
                FROM ActividadesServicios AS1 
                WHERE AS1.TipoActividadID IN (
                    SELECT CAST(value AS INT) 
                    FROM STRING_SPLIT(@TipoActividadIDs, ',')
                )
            )
        )
        AND (
            ISNULL(@ServicioActividadIDs, '') = '' 
            OR EA.CedulaJuridica IN (
                SELECT DISTINCT ASA.CedulaJuridica 
                FROM ActividadesServiciosAdicionales ASA 
                WHERE ASA.ServicioActividadID IN (
                    SELECT CAST(value AS INT) 
                    FROM STRING_SPLIT(@ServicioActividadIDs, ',')
                )
            )
        )
    ORDER BY EA.Nombre;
   
END;

drop procedure sp_BuscarActividadesAvanzado
GO

-- Stored procedure mejorado para obtener detalles completos de actividad
CREATE PROCEDURE sp_ObtenerDetallesActividad
    @CedulaJuridica VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- 1. Información general de la empresa
    SELECT 
        EA.CedulaJuridica,
        EA.Nombre,
        EA.UbicacionCompleta,
        EA.Telefono,
        EA.CorreoElectronico,
        EA.NombreContacto,
        EA.Precio,
        EA.Descripcion,
        -- Dirección completa para mostrar
        CONCAT(EA.Provincia, ', ', EA.Canton, ', ', EA.Distrito, ' - ', EA.SeniasExactas) AS DireccionCompleta
    FROM EmpresasActividad EA
    WHERE EA.CedulaJuridica = @CedulaJuridica;
    
    -- 2. Tipos de actividad asociados
    SELECT DISTINCT
        ASV.TipoActividadID,
        ASV.TipoActividad AS TipoActividad,
        ASV.Descripcion AS DescripcionTipo
    FROM ActividadesServicios ASV
    INNER JOIN TipoActividad TA ON ASV.TipoActividadID = TA.TipoActividadID
    WHERE ASV.CedulaJuridica = @CedulaJuridica
    ORDER BY ASV.TipoActividad;
    
    -- 3. Servicios adicionales incluidos
    SELECT DISTINCT
        SA.ServicioActividadID,
        SA.Nombre AS ServicioActividad
    FROM ActividadesServiciosAdicionales ASA
    INNER JOIN ServicioActividad SA ON ASA.ServicioActividadID = SA.ServicioActividadID
    WHERE ASA.CedulaJuridica = @CedulaJuridica
    ORDER BY SA.Nombre;
   
END;

drop procedure sp_ObtenerDetallesActividad
GO

CREATE PROCEDURE sp_ObtenerHotelPorCedulaJuridica
    @CedulaJuridica varchar(20)
AS
BEGIN
    SELECT 
        CedulaJuridica, 
        Nombre, 
        TipoHotelID,
        Provincia,
        Canton,
        Distrito,
        Barrio,
        SeniasExactas,
        ReferenciaGPS,
        CorreoElectronico,
        URLSitioWeb
    FROM 
        EmpresaHotel 
    WHERE 
        CedulaJuridica = @CedulaJuridica
END
GO

CREATE PROCEDURE sp_ObtenerActividadPorCedulaJuridica
    @CedulaJuridica varchar(20)
AS
BEGIN
    SELECT 
        CedulaJuridica, 
        Nombre, 
        CorreoElectronico,
        Telefono,
        NombreContacto,
        Provincia,
        Canton,
        Distrito,
        SeniasExactas,
        Precio,
        Descripcion
    FROM 
        EmpresaActividad 
    WHERE 
        CedulaJuridica = @CedulaJuridica
END
GO

CREATE PROCEDURE sp_GetTiposHabitacionPorHotel
    @CedulaJuridica VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        th.TipoHabitacionID,
        th.Nombre,
        th.Precio,
        tc.Nombre AS TipoCama,
        th.Cantidad as CantidadCamas
    FROM TipoHabitacion th
    INNER JOIN TipoCama tc ON th.TipoCamaID = tc.TipoCamaID
    WHERE th.CedulaJuridica = @CedulaJuridica
    ORDER BY th.Nombre
END

GO

CREATE PROCEDURE sp_ObtenerDetallesReservacion
    @ReservacionID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Información principal de la reserva
    SELECT 
        R.ReservacionID,
        R.FechaIngreso,
        R.FechaSalida,
        R.CantidadPersonas,
        R.PoseeVehiculo,
        R.Estado,
        GETDATE() as FechaReserva, 
        
        -- Hotel
        EH.Nombre as NombreHotel,
        CONCAT(EH.Provincia, ', ', EH.Canton, ', ', EH.Distrito) as UbicacionHotel,
        EH.CorreoElectronico as EmailHotel,
        
        -- Habitación
        TH.Nombre as TipoHabitacion,
        H.Numero as NumeroHabitacion,
        TH.Precio as PrecioPorNoche,
        TH.Precio * DATEDIFF(day, CAST(R.FechaIngreso as DATE), CAST(R.FechaSalida as DATE)) as PrecioTotal,
        
        -- Cliente
        C.Nombre as NombreCliente,
        C.CorreoElectronico as EmailCliente,
        
        -- Teléfono del hotel (primer teléfono encontrado)
        (SELECT TOP 1 Numero FROM TelefonosEmpresa WHERE CedulaJuridica = EH.CedulaJuridica) as TelefonoHotel,
        
        -- Teléfono del cliente (primer teléfono encontrado)
        (SELECT TOP 1 Numero FROM TelefonosCliente WHERE CedulaID = C.CedulaID) as TelefonoCliente
        
    FROM Reservacion R
    INNER JOIN Habitaciones H ON R.HabitacionID = H.HabitacionID
    INNER JOIN TipoHabitacion TH ON H.TipoHabitacionID = TH.TipoHabitacionID
    INNER JOIN EmpresaHotel EH ON TH.CedulaJuridica = EH.CedulaJuridica
    INNER JOIN Cliente C ON R.CedulaID = C.CedulaID
    WHERE R.ReservacionID = @ReservacionID;
    
    -- Imagen del hotel (primera foto disponible)
    SELECT TOP 1 FH.Fotos
    FROM Reservacion R
    INNER JOIN Habitaciones H ON R.HabitacionID = H.HabitacionID
    INNER JOIN TipoHabitacion TH ON H.TipoHabitacionID = TH.TipoHabitacionID
    INNER JOIN FotosHabitacion FH ON TH.TipoHabitacionID = FH.TipoHabitacionID
    WHERE R.ReservacionID = @ReservacionID
    ORDER BY FH.FotoID;
    
    -- Servicios del hotel
    SELECT S.Nombre as Servicio
    FROM Reservacion R
    INNER JOIN Habitaciones H ON R.HabitacionID = H.HabitacionID
    INNER JOIN TipoHabitacion TH ON H.TipoHabitacionID = TH.TipoHabitacionID
    INNER JOIN HotelServicios HS ON TH.CedulaJuridica = HS.CedulaJuridica
    INNER JOIN Servicios S ON HS.ServicioID = S.ServicioID
    WHERE R.ReservacionID = @ReservacionID
    ORDER BY S.Nombre;
END;