use SistemaHoteleria

GO

CREATE PROCEDURE SP_VerFacturacion
    @ModoConsulta VARCHAR(10), -- 'DIA', 'MES', 'ANIO', 'RANGO'
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL,
    @CedulaJuridica VARCHAR(20) = NULL -- Filtro opcional por hotel
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @ModoConsulta = 'DIA'
    BEGIN
        SELECT 
            CAST(FechaEmision AS DATE) AS Fecha,
            NombreHotel,
            COUNT(*) AS TotalFacturas,
            SUM(ImporteTotal) AS TotalFacturado,
            AVG(ImporteTotal) AS PromedioFacturado,
            SUM(CantidadPersonas) AS TotalHuespedes
        FROM FacturacionDetallada
        WHERE (@CedulaJuridica IS NULL OR CedulaJuridica = @CedulaJuridica)
        GROUP BY CAST(FechaEmision AS DATE), NombreHotel, CedulaJuridica
        ORDER BY Fecha DESC, TotalFacturado DESC;
    END
    
    ELSE IF @ModoConsulta = 'MES'
    BEGIN
        SELECT 
            FORMAT(FechaEmision, 'yyyy-MM') AS Mes,
            NombreHotel,
            COUNT(*) AS TotalFacturas,
            SUM(ImporteTotal) AS TotalFacturado,
            AVG(ImporteTotal) AS PromedioFacturado,
            SUM(CantidadPersonas) AS TotalHuespedes
        FROM FacturacionDetallada
        WHERE (@CedulaJuridica IS NULL OR CedulaJuridica = @CedulaJuridica)
        GROUP BY FORMAT(FechaEmision, 'yyyy-MM'), NombreHotel, CedulaJuridica
        ORDER BY Mes DESC, TotalFacturado DESC;
    END
    
    ELSE IF @ModoConsulta = 'ANIO'
    BEGIN
        SELECT 
            YEAR(FechaEmision) AS Anio,
            NombreHotel,
            COUNT(*) AS TotalFacturas,
            SUM(ImporteTotal) AS TotalFacturado,
            AVG(ImporteTotal) AS PromedioFacturado,
            SUM(CantidadPersonas) AS TotalHuespedes
        FROM FacturacionDetallada
        WHERE (@CedulaJuridica IS NULL OR CedulaJuridica = @CedulaJuridica)
        GROUP BY YEAR(FechaEmision), NombreHotel, CedulaJuridica
        ORDER BY Anio DESC, TotalFacturado DESC;
    END
    
    ELSE IF @ModoConsulta = 'RANGO' AND @FechaInicio IS NOT NULL AND @FechaFin IS NOT NULL
    BEGIN
        SELECT 
            CAST(FechaEmision AS DATE) AS Fecha,
            NombreHotel,
            COUNT(*) AS TotalFacturas,
            SUM(ImporteTotal) AS TotalFacturado,
            AVG(ImporteTotal) AS PromedioFacturado,
            SUM(CantidadPersonas) AS TotalHuespedes
        FROM FacturacionDetallada
        WHERE FechaEmision BETWEEN @FechaInicio AND @FechaFin
            AND (@CedulaJuridica IS NULL OR CedulaJuridica = @CedulaJuridica)
        GROUP BY CAST(FechaEmision AS DATE), NombreHotel, CedulaJuridica
        ORDER BY Fecha DESC, TotalFacturado DESC;
    END
    ELSE
    BEGIN
        PRINT 'Error: Modo de consulta no válido o faltan parámetros para RANGO';
    END
END;

GO
-- 2. Procedimiento mejorado para facturación por tipo de habitación
CREATE PROCEDURE SP_FacturacionPorTipoHabitacion
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL,
    @CedulaJuridica VARCHAR(20) = NULL,
    @TipoHabitacionID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        NombreHotel,
        TipoHabitacion,
        TipoHabitacionID,
        COUNT(*) AS TotalFacturas,
        SUM(ImporteTotal) AS TotalFacturado,
        AVG(ImporteTotal) AS PromedioFacturado,
        SUM(CantidadPersonas) AS TotalHuespedes,
        AVG(CAST(DiasEstadia AS FLOAT)) AS PromedioEstadia,
        MIN(FechaEmision) AS PrimeraFactura,
        MAX(FechaEmision) AS UltimaFactura
    FROM FacturacionDetallada
    WHERE (@FechaInicio IS NULL OR FechaEmision >= @FechaInicio)
        AND (@FechaFin IS NULL OR FechaEmision <= @FechaFin)
        AND (@CedulaJuridica IS NULL OR CedulaJuridica = @CedulaJuridica)
        AND (@TipoHabitacionID IS NULL OR TipoHabitacionID = @TipoHabitacionID)
    GROUP BY NombreHotel, TipoHabitacion, TipoHabitacionID, CedulaJuridica
    ORDER BY TotalFacturado DESC;
END;

GO

-- 3. Procedimiento mejorado para facturación por habitación específica
CREATE PROCEDURE SP_FacturacionPorHabitacion
    @HabitacionID INT = NULL,
    @NumeroHabitacion INT = NULL,
    @CedulaJuridica VARCHAR(20) = NULL,
    @FechaInicio DATETIME = NULL,
    @FechaFin DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        NombreHotel,
        NumeroHabitacion,
        HabitacionID,
        TipoHabitacion,
        COUNT(*) AS TotalFacturas,
        SUM(ImporteTotal) AS TotalFacturado,
        AVG(ImporteTotal) AS PromedioFacturado,
        SUM(CantidadPersonas) AS TotalHuespedes,
        AVG(CAST(DiasEstadia AS FLOAT)) AS PromedioEstadia,
        MIN(FechaEmision) AS PrimeraFactura,
        MAX(FechaEmision) AS UltimaFactura,
        COUNT(DISTINCT CedulaID) AS ClientesUnicos
    FROM VFacturacionDetallada
    WHERE (@HabitacionID IS NULL OR HabitacionID = @HabitacionID)
        AND (@NumeroHabitacion IS NULL OR NumeroHabitacion = @NumeroHabitacion)
        AND (@CedulaJuridica IS NULL OR CedulaJuridica = @CedulaJuridica)
        AND (@FechaInicio IS NULL OR FechaEmision >= @FechaInicio)
        AND (@FechaFin IS NULL OR FechaEmision <= @FechaFin)
    GROUP BY NombreHotel, NumeroHabitacion, HabitacionID, TipoHabitacion, CedulaJuridica
    ORDER BY TotalFacturado DESC;
END;

GO
CREATE PROCEDURE SP_ReporteReservasPorTipoHabitacion
    @FechaInicio DATE,
    @FechaFin DATE,
    @TipoHabitacionIDs VARCHAR(MAX) = NULL -- Lista separada por comas: '1,2,3'
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        NombreHotel,
        TipoHabitacion,
        COUNT(*) as TotalReservas,
        SUM(CantidadPersonas) as TotalPersonas,
        AVG(CAST(CantidadPersonas AS FLOAT)) as PromedioPersonasPorReserva,
        MIN(FechaIngreso) as PrimeraReserva,
        MAX(FechaSalida) as UltimaReserva
    FROM VW_ReservasCompletadas
    WHERE FechaIngreso >= @FechaInicio 
        AND FechaSalida <= @FechaFin
        AND (@TipoHabitacionIDs IS NULL OR 
             TipoHabitacionID IN (SELECT VALUE FROM STRING_SPLIT(@TipoHabitacionIDs, ',')))
    GROUP BY NombreHotel, TipoHabitacion, TipoHabitacionID
    ORDER BY TotalReservas DESC;
END;

GO
-- 3. Reporte de rango de edades de clientes
CREATE PROCEDURE SP_ReporteEdadesClientes
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        NombreHotel,
        COUNT(*) AS TotalClientes,
        AVG(DATEDIFF(YEAR, FechaNacimiento, GETDATE())) AS EdadPromedio,
        MIN(DATEDIFF(YEAR, FechaNacimiento, GETDATE())) AS EdadMinima,
        MAX(DATEDIFF(YEAR, FechaNacimiento, GETDATE())) AS EdadMaxima
    FROM ReservasCompletadas
    GROUP BY NombreHotel
    ORDER BY TotalClientes DESC;
END;

GO
-- 4. Reporte de hoteles con mayor demanda
CREATE PROCEDURE SP_ReporteHotelesMayorDemanda
    @Fecha DATE,
    @Provincia VARCHAR(50) = NULL,
    @Canton VARCHAR(50) = NULL,
    @Distrito VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        NombreHotel,
        COUNT(*) AS TotalReservas,
        SUM(CantidadPersonas) AS TotalHuespedes,
        AVG(CAST(CantidadPersonas AS FLOAT)) AS PromedioHuespedesPorReserva,
        MIN(FechaIngreso) AS PrimeraReserva,
        MAX(FechaSalida) AS UltimaReserva
    FROM ReservasCompletadas
    WHERE FechaIngreso >= @Fecha
        AND (@Provincia IS NULL OR Provincia = @Provincia)
        AND (@Canton IS NULL OR Canton = @Canton)
        AND (@Distrito IS NULL OR Distrito = @Distrito)
    GROUP BY NombreHotel, CedulaJuridica
    ORDER BY TotalReservas DESC;
END;