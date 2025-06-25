use SistemaHoteleria

GO

-- ==========================================
-- CREACIÓN DE ROLES Y USUARIOS
-- ==========================================

-- 1. Crear roles
CREATE ROLE AdminHotel;
CREATE ROLE ClienteHotel;


-- 2. Permisos para ADMINISTRADORES (CRUD completo)
-- Pueden hacer todo en todas las tablas del sistema
GRANT SELECT, INSERT, UPDATE, DELETE ON TipoHotel TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON EmpresaHotel TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON Servicios TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON HotelServicios TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON TelefonosEmpresa TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON RedSocial TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON RedSocialHotel TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON TipoCama TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON TipoHabitacion TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON TipoHabitacionCama TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON FotosHabitacion TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON Comodidades TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON TipoHabitacionComodidad TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON Habitaciones TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON PaisResidencia TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON Cliente TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON TelefonosCliente TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reservacion TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON MetodoPago TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON Facturacion TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON EmpresaActividad TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON TipoActividad TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON EmpresaActividadTipo TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON ServicioActividad TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON EmpresaActividadServicio TO AdminHotel;

-- 3. Permisos para CLIENTES (Solo consulta y reservas)
-- Pueden consultar información pública
GRANT SELECT ON TipoHotel TO ClienteHotel;
GRANT SELECT ON EmpresaHotel TO ClienteHotel;
GRANT SELECT ON Servicios TO ClienteHotel;
GRANT SELECT ON HotelServicios TO ClienteHotel;
GRANT SELECT ON TipoCama TO ClienteHotel;
GRANT SELECT ON TipoHabitacion TO ClienteHotel;
GRANT SELECT ON TipoHabitacionCama TO ClienteHotel;
GRANT SELECT ON FotosHabitacion TO ClienteHotel;
GRANT SELECT ON Comodidades TO ClienteHotel;
GRANT SELECT ON TipoHabitacionComodidad TO ClienteHotel;
GRANT SELECT ON Habitaciones TO ClienteHotel;
GRANT SELECT ON PaisResidencia TO ClienteHotel;
GRANT SELECT ON EmpresaActividad TO ClienteHotel;
GRANT SELECT ON TipoActividad TO ClienteHotel;
GRANT SELECT ON EmpresaActividadTipo TO ClienteHotel;
GRANT SELECT ON ServicioActividad TO ClienteHotel;
GRANT SELECT ON EmpresaActividadServicio TO ClienteHotel;

-- Pueden gestionar sus propios datos
GRANT SELECT, INSERT, UPDATE ON Cliente TO ClienteHotel;
GRANT SELECT, INSERT, UPDATE ON TelefonosCliente TO ClienteHotel;
GRANT SELECT, INSERT ON Reservacion TO ClienteHotel;
GRANT SELECT ON Facturacion TO ClienteHotel;
GRANT SELECT ON MetodoPago TO ClienteHotel;

-- 4. Crear usuarios de ejemplo
CREATE LOGIN admin_hotel WITH PASSWORD = 'hoteleriaadmin123!';
CREATE LOGIN cliente_hotel WITH PASSWORD = 'clientesweb123!';


CREATE USER admin_hotel FOR LOGIN admin_hotel;
CREATE USER cliente_hotel FOR LOGIN cliente_hotel;

-- Asignar roles
ALTER ROLE AdminHotel ADD MEMBER admin_hotel;
ALTER ROLE ClienteHotel ADD MEMBER cliente_hotel;


-- Tabla para usuarios del sistema (administradores)
CREATE TABLE UsuarioSistemaHotel (
    UsuarioID int identity(1,1) primary key,
    Contrasenia varchar(255) not null, 
    Nombre varchar(100) not null,
    Apellido varchar(100) not null,
    Email varchar(100) unique not null,
    TipoUsuario varchar(20) not null CHECK (TipoUsuario IN ('ADMIN')),
    CedulaJuridica varchar(20) not null, -- Hotel al que pertenece
    FechaCreacion datetime default GetDate(),
    Activo bit default 1,
    
    CONSTRAINT FK_UsuarioSistema_EmpresaHotel 
        FOREIGN KEY (CedulaJuridica) REFERENCES EmpresaHotel (CedulaJuridica)
);

CREATE TABLE UsuarioSistemaRecreativo (
    UsuarioID int identity(1,1) primary key,
    Contrasenia varchar(255) not null, 
    Nombre varchar(100) not null,
    Apellido varchar(100) not null,
    Email varchar(100) unique not null,
    TipoUsuario varchar(20) not null CHECK (TipoUsuario IN ('ADMIN')),
    CedulaJuridica varchar(20) not null, -- Hotel al que pertenece
    FechaCreacion datetime default GetDate(),
    Activo bit default 1,
    
    CONSTRAINT FK_UsuarioSistema_EmpresaActividad
        FOREIGN KEY (CedulaJuridica) REFERENCES EmpresaActividad (CedulaJuridica)
);

-- Permisos para esta tabla
GRANT SELECT, INSERT, UPDATE, DELETE ON UsuarioSistemaHotel TO AdminHotel;
GRANT SELECT, INSERT, UPDATE, DELETE ON UsuarioSistemaRecreativo TO AdminHotel;