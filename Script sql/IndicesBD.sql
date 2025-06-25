USE SistemaHoteleria
GO

-- 1. Búsquedas por ubicación (muy frecuente)
CREATE NONCLUSTERED INDEX IX_EmpresaHotel_Ubicacion
ON EmpresaHotel (Provincia, Canton, Distrito);
GO

-- 2. Verificación de disponibilidad de habitaciones (consulta más crítica)
CREATE NONCLUSTERED INDEX IX_Reservacion_Disponibilidad
ON Reservacion (HabitacionID, FechaIngreso, FechaSalida);
GO

-- 3. Relación habitaciones-hotel
CREATE NONCLUSTERED INDEX IX_Habitaciones_Hotel_Tipo
ON Habitaciones (CedulaJuridica, TipoHabitacionID);
GO

-- 4. Filtros por precio
CREATE NONCLUSTERED INDEX IX_TipoHabitacion_Precio
ON TipoHabitacion (Precio);
GO

-- 5. Relación tipo habitación con hotel
CREATE NONCLUSTERED INDEX IX_TipoHabitacion_Hotel
ON TipoHabitacion (CedulaJuridica);
GO

-- 6. Servicios del hotel
CREATE NONCLUSTERED INDEX IX_HotelServicios_Hotel
ON HotelServicios (CedulaJuridica);
GO

-- 7. Comodidades por tipo de habitación
CREATE NONCLUSTERED INDEX IX_TipoHabitacionComodidad_Tipo
ON TipoHabitacionComodidad (TipoHabitacionID);
GO

-- 9. Login de clientes
CREATE NONCLUSTERED INDEX IX_Cliente_Email
ON Cliente (CorreoElectronico);
GO

-- 10. Reservas por cliente
CREATE NONCLUSTERED INDEX IX_Reservacion_Cliente
ON Reservacion (CedulaID);
GO

-- 11. Búsqueda por número de reserva
CREATE NONCLUSTERED INDEX IX_Reservacion_NumeroReserva
ON Reservacion (ReservacionID);
GO


-- 12. Facturación por reserva
CREATE NONCLUSTERED INDEX IX_Facturacion_Reservacion
ON Facturacion (ReservacionID);
GO

-- 13. Facturación por fecha
CREATE NONCLUSTERED INDEX IX_Facturacion_Fecha
ON Facturacion (FechaEmision);
GO

-- 14. Búsquedas de actividades por ubicación
CREATE NONCLUSTERED INDEX IX_EmpresaActividad_Ubicacion
ON EmpresaActividad (Provincia, Canton, Distrito);
GO

-- 15. Filtros por precio de actividades
CREATE NONCLUSTERED INDEX IX_EmpresaActividad_Precio
ON EmpresaActividad (Precio);
GO

-- 16. Tipos de actividad por empresa
CREATE NONCLUSTERED INDEX IX_EmpresaActividadTipo_Empresa
ON EmpresaActividadTipo (CedulaJuridica);
GO

-- 17. Servicios adicionales de actividades
CREATE NONCLUSTERED INDEX IX_EmpresaActividadServicio_Empresa
ON EmpresaActividadServicio (CedulaJuridica);
GO

-- 18. Teléfonos del hotel
CREATE NONCLUSTERED INDEX IX_TelefonosEmpresa_Hotel
ON TelefonosEmpresa (CedulaJuridica);
GO

-- 19. Fotos de habitaciones
CREATE NONCLUSTERED INDEX IX_FotosHabitacion_Tipo
ON FotosHabitacion (TipoHabitacionID);
GO

-- 20. Redes sociales del hotel
CREATE NONCLUSTERED INDEX IX_RedSocialHotel_Hotel
ON RedSocialHotel (CedulaJuridica);
GO