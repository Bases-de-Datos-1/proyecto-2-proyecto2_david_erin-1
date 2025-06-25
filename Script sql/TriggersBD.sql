use SistemaHoteleria

GO

CREATE TRIGGER TR_CerrarReservacion
ON Reservacion
AFTER UPDATE
AS
BEGIN
    -- Variables para almacenar datos
    DECLARE @ReservacionID int
    DECLARE @EstadoAnterior varchar(20)
    DECLARE @EstadoNuevo varchar(20)
    DECLARE @HabitacionID int
    DECLARE @FechaIngreso datetime
    DECLARE @FechaSalida datetime
    DECLARE @CantidadPersonas int
    DECLARE @PrecioHabitacion decimal(10,2)
    DECLARE @ImporteTotal decimal(10,2)
    DECLARE @MetodoPagoDefecto int
    
    
    SELECT 
        @ReservacionID = I.ReservacionID,
        @EstadoNuevo = I.Estado,
        @EstadoAnterior = D.Estado,
        @HabitacionID = I.HabitacionID,
        @FechaIngreso = I.FechaIngreso,
        @FechaSalida = I.FechaSalida,
        @CantidadPersonas = I.CantidadPersonas
    FROM inserted I
    INNER JOIN deleted D ON I.ReservacionID = D.ReservacionID
    WHERE I.ReservacionID = @ReservacionID


    -- Solo proceder si el estado cambió de 'ACTIVO' a 'CERRADO'
    IF @EstadoAnterior = 'ACTIVO' AND @EstadoNuevo = 'CERRADO'
    BEGIN

        IF NOT EXISTS (SELECT 1 FROM inserted WHERE FechaCheckOut IS NOT NULL)
        BEGIN
            UPDATE Reservacion 
            SET FechaCheckOut = GETDATE() 
            WHERE ReservacionID = @ReservacionID
        END
        
        
        SELECT @PrecioHabitacion = th.Precio
        FROM Habitaciones h
        INNER JOIN TipoHabitacion th ON h.TipoHabitacionID = th.TipoHabitacionID
        WHERE h.HabitacionID = @HabitacionID
        

        DECLARE @DiasEstadia int
        SET @DiasEstadia = DATEDIFF(day, @FechaIngreso, @FechaSalida)
        IF @DiasEstadia <= 0 SET @DiasEstadia = 1 -- Mínimo 1 día
        
        
        SET @ImporteTotal = @PrecioHabitacion * @DiasEstadia
    
        SELECT TOP 1 @MetodoPagoDefecto = MetodoPagoID 
        FROM MetodoPago 
        WHERE NombreMetodo = 'Efectivo'
        
        -- Si no existe método de pago por defecto, crearlo
        IF @MetodoPagoDefecto IS NULL
        BEGIN
            INSERT INTO MetodoPago (NombreMetodo, DetallesAdicionales)
            VALUES ('Efectivo', 'Pago en efectivo por defecto')
            SET @MetodoPagoDefecto = SCOPE_IDENTITY()
        END
        
        -- Generar la factura automáticamente
        INSERT INTO Facturacion (ReservacionID, MetodoPagoID, FechaEmision, ImporteTotal, EstadoPago)
        VALUES (@ReservacionID, @MetodoPagoDefecto, GETDATE(), @ImporteTotal, 'PENDIENTE')
        
        PRINT 'Reserva cerrada y factura generada automáticamente para ReservacionID: ' + CAST(@ReservacionID AS varchar(10))
    END
END

GO
-- Procedimiento para realizar check-out de una reserva
CREATE PROCEDURE SP_RealizarCheckOut
    @ReservacionID int,
    @MetodoPagoID int = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
        
        -- Verificar que la reserva existe y está activa
        IF NOT EXISTS (SELECT 1 FROM Reservacion WHERE ReservacionID = @ReservacionID AND Estado = 'ACTIVO')
        BEGIN
            RAISERROR('La reserva no existe o no está activa', 16, 1)
            RETURN
        END
        
        -- Actualizar el estado de la reserva a CERRADO
        -- El trigger se encargará de generar la factura automáticamente
        UPDATE Reservacion 
        SET Estado = 'CERRADO',
            FechaCheckOut = GETDATE()
        WHERE ReservacionID = @ReservacionID
        
        -- Si se especificó un método de pago específico, actualizar la factura
        IF @MetodoPagoID IS NOT NULL
        BEGIN
            UPDATE Facturacion 
            SET MetodoPagoID = @MetodoPagoID
            WHERE ReservacionID = @ReservacionID
        END
        
        COMMIT TRANSACTION
        PRINT 'Check-out realizado exitosamente para la reserva: ' + CAST(@ReservacionID AS varchar(10))
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        PRINT 'Error al realizar check-out: ' + ERROR_MESSAGE()
    END CATCH
END