USE SistemaHoteleria

GO
DROP VIEW IF EXISTS HotelesInfo;
GO

CREATE VIEW HotelesInfo AS
SELECT 
    eh.CedulaJuridica,
    eh.Nombre  AS Nombre,
    th.Nombre AS TipoHotel,
    CAST(CONCAT(EH.Provincia, ', ', EH.Canton, ', ', EH.Distrito, ', ', EH.Barrio) AS VARCHAR(500)) AS UbicacionCompleta,
    eh.CorreoElectronico,
    CAST(EH.URLSitioWeb AS VARCHAR(MAX)) as URLSitioWeb
FROM EmpresaHotel eh
INNER JOIN TipoHotel th ON eh.TipoHotelID = th.TipoHotelID;
GO

-- Mejorar la vista de habitaciones disponibles
DROP VIEW IF EXISTS HabitacionesDisponibles;
GO

CREATE VIEW HabitacionesDisponibles AS
SELECT 
    h.HabitacionID,
    h.Numero,
    h.CedulaJuridica,
    th.TipoHabitacionID,
    th.Nombre AS TipoHabitacion,
    th.Descripcion,
    th.Precio,
    th.Cantidad,
    -- Calcular capacidad total basada en el tipo de cama
    ISNULL(tc.Capacidad, 2) * th.Cantidad AS CapacidadTotal
FROM Habitaciones h
INNER JOIN TipoHabitacion th ON h.TipoHabitacionID = th.TipoHabitacionID
LEFT JOIN TipoCama tc ON th.TipoCamaID = tc.TipoCamaID;
GO

GO
-- Vista para servicios de hotel
CREATE VIEW HotelesServicios AS
SELECT 
    HS.CedulaJuridica,
    S.ServicioID,
    S.Nombre AS Servicio
FROM HotelServicios HS
INNER JOIN Servicios S ON HS.ServicioID = S.ServicioID;

GO 

-- Vista para comodidades de habitaciones
CREATE VIEW HabitacionesComodidades AS
SELECT 
    THC.TipoHabitacionID,
    C.ComodidadID,
    C.Nombre AS Comodidad
FROM TipoHabitacionComodidad THC
INNER JOIN Comodidades C ON THC.ComodidadID = C.ComodidadID;

GO 
-- Vista para empresas de actividades
CREATE VIEW EmpresasActividad AS
SELECT 
    EA.CedulaJuridica,
    EA.Nombre,
    EA.CorreoElectronico,
    EA.Telefono,
    EA.NombreContacto,
    EA.Provincia,
    EA.Canton,
    EA.Distrito,
    EA.SeniasExactas,
    EA.Precio,
	CAST(EA.Descripcion as VARCHAR(MAX)) as Descripcion,
    CAST(CONCAT(EA.Provincia, ', ', EA.Canton, ', ', EA.Distrito) AS VARCHAR(500)) AS UbicacionCompleta
FROM EmpresaActividad EA;

GO

-- Vista para actividades y servicios
CREATE VIEW ActividadesServicios AS
SELECT 
    EAT.CedulaJuridica,
    TA.TipoActividadID,
    TA.Nombre AS TipoActividad,
    CAST(TA.Descripcion as varchar(max)) as Descripcion
FROM EmpresaActividadTipo EAT
INNER JOIN TipoActividad TA ON EAT.TipoActividadID = TA.TipoActividadID;

GO

CREATE VIEW ActividadesServiciosAdicionales AS
SELECT 
    EAS.CedulaJuridica,
    SA.ServicioActividadID,
    SA.Nombre AS ServicioActividad
FROM EmpresaActividadServicio EAS
INNER JOIN ServicioActividad SA ON EAS.ServicioActividadID = SA.ServicioActividadID;

GO

-- Ver todas las empresa

CREATE VIEW FacturacionCompleta AS
SELECT 
    F.FacturacionID,
    F.FechaEmision,
    F.ImporteTotal,
    R.ReservacionID,
    R.NumeroReserva,
    R.FechaIngreso,
    R.FechaSalida,
    R.CantidadPersonas,
    H.HabitacionID,
    H.Numero as NumeroHabitacion,
    TH.TipoHabitacionID,
    TH.Nombre as TipoHabitacion,
    TH.Precio as PrecioHabitacion,
    EH.CedulaJuridica,
    EH.Nombre as NombreHotel,
    EH.Provincia,
    EH.Canton,
    EH.Distrito,
    C.CedulaID,
    C.Nombre as NombreCliente,
    C.PrimerApellido,
    C.SegundoApellido,
    C.FechaNacimiento,
    MP.NombreMetodo as MetodoPago
FROM Facturacion F
JOIN Reservacion R ON F.ReservacionID = R.ReservacionID
JOIN Habitaciones H ON R.HabitacionID = H.HabitacionID
JOIN TipoHabitacion TH ON H.TipoHabitacionID = TH.TipoHabitacionID
JOIN EmpresaHotel EH ON H.CedulaJuridica = EH.CedulaJuridica
JOIN Cliente C ON R.CedulaID = C.CedulaID
JOIN MetodoPago MP ON F.MetodoPagoID = MP.MetodoPagoID;

GO
-- Vista para reservas completadas
CREATE VIEW ReservasCompletadas AS
SELECT 
    R.ReservacionID,
    R.NumeroReserva,
    R.FechaIngreso,
    R.FechaSalida,
    R.CantidadPersonas,
    H.HabitacionID,
    H.Numero as NumeroHabitacion,
    TH.TipoHabitacionID,
    TH.Nombre as TipoHabitacion,
    EH.CedulaJuridica,
    EH.Nombre as NombreHotel,
    EH.Provincia,
    EH.Canton,
    EH.Distrito,
    C.CedulaID,
    C.Nombre as NombreCliente,
    C.FechaNacimiento
FROM Reservacion R
JOIN Habitaciones H ON R.HabitacionID = H.HabitacionID
JOIN TipoHabitacion TH ON H.TipoHabitacionID = TH.TipoHabitacionID
JOIN EmpresaHotel EH ON H.CedulaJuridica = EH.CedulaJuridica
JOIN Cliente C ON R.CedulaID = C.CedulaID
WHERE R.FechaSalida < GETDATE(); -- Solo reservas ya finalizadas