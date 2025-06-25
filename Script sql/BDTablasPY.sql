create database SistemaHoteleria

use SistemaHoteleria


create table TipoHotel
(
	TipoHotelID int identity (1,1) primary key,
	Nombre varchar(100) not null,
)

create table EmpresaHotel
( 
	CedulaJuridica varchar(20) primary key,
	Nombre varchar(100) not null,
	TipoHotelID int not null,
	Provincia varchar(50) not null,
	Canton varchar(50) not null,
	Distrito varchar(50) not null,
	Barrio varchar(50) not null,
	SeniasExactas text not null, 
	ReferenciaGPS varchar(100) not null,
	CorreoElectronico varchar(100) unique not null,
	URLSitioWeb text null,

	constraint FK_EmpresaHotel_TipoHotel foreign key (TipoHotelID) references TipoHotel (TipoHotelID),
	constraint chk_CedulaJuridica CHECK (CedulaJuridica LIKE '[1-8]%' AND LEN(CedulaJuridica) BETWEEN 10 AND 11)
)


create table Servicios 
(
	ServicioID int identity (1,1) primary key,
	Nombre varchar(100) not null,
)

create table HotelServicios
(
	CedulaJuridica varchar(20) not null,
	ServicioID int not null,
	constraint FK_HotelServicios_EmpresaHotel foreign key (CedulaJuridica) references EmpresaHotel (CedulaJuridica),
	constraint FK_HotelServicios_Servicios foreign key (ServicioID) references Servicios (ServicioID)
)

create table TelefonosEmpresa 
(
	TelefonoID int identity (1,1) primary key,
	Numero varchar(20) not null,
	CedulaJuridica varchar(20) not null,
	constraint FK_TelefonosEmpresa_EmpresaHotel foreign key (CedulaJuridica) references EmpresaHotel (CedulaJuridica),
)

create table RedSocial 
(
	RedSocialID int identity (1,1) primary key,
	Nombre varchar(50) not null
)

create table RedSocialHotel
(
	NombreUsuario varchar(150) not null,
	RedSocialID int not null,
	CedulaJuridica varchar(20) not null,
	constraint FK_RedSocialHotel_EmpresaHotel foreign key (CedulaJuridica) references EmpresaHotel (CedulaJuridica),
	constraint FK_RedSocialHotel_RedSocil foreign key (RedSocialID) references RedSocial (RedSocialID)
)

create table TipoCama
(
	TipoCamaID int identity (1,1) primary key,
	Nombre varchar (100) not null,
	Capacidad int not null
)


create table TipoHabitacion
(
	TipoHabitacionID int identity (1,1) primary key,
	Nombre varchar(50) not null,
	Descripcion varchar(MAX),
	Precio decimal (10,2) not null check (Precio > 0.00),
)

ALTER TABLE TipoHabitacion ADD TipoCamaID int NOT NULL;
ALTER TABLE TipoHabitacion ADD Cantidad int NOT NULL;
ALTER TABLE TipoHabitacion 
ADD CONSTRAINT CHK_Cantidad CHECK (Cantidad > 0);
ALTER TABLE TipoHabitacion
ADD CONSTRAINT FK_TipoHabitacion_TipoCama 
FOREIGN KEY (TipoCamaID) REFERENCES TipoCama (TipoCamaID);



create table FotosHabitacion
(
	FotoID int identity (1,1) primary key,
	Fotos VARBINARY(MAX) not null,
	TipoHabitacionID int not null,
	constraint FK_FotosHabitacion_TipoHabitacion foreign key (TipoHabitacionID) references TipoHabitacion(TipoHabitacionID)
)


create table Comodidades
(
	ComodidadID int identity (1,1) primary key,
	Nombre varchar(50) not null
)

create table TipoHabitacionComodidad
(
	TipoHabitacionID int not null,
	ComodidadID int not null,
	constraint Fk_TipoHabitacionComodidad_TipoHabitacion foreign key (TipoHabitacionID) references TipoHabitacion (TipoHabitacionID),
	constraint FK_TipoHabitacionComodidad_Comodidades foreign key (ComodidadID) references Comodidades (ComodidadID),
)


create table Habitaciones 
(
	HabitacionID int identity (1,1) primary key,
	Numero int not null check(Numero > 0),
	CedulaJuridica varchar(20) not null,
	TipoHabitacionID int not null,
	constraint FK_Habitaciones_EmpresaHotel foreign key (CedulaJuridica) references EmpresaHotel (CedulaJuridica),
	constraint FK_Habitaciones_TipoHabitacion foreign key (TipoHabitacionID) references TipoHabitacion (TipoHabitacionID),
)


CREATE TABLE PaisResidencia (
    PaisResidenciaID int identity(1,1) primary key,
    NombrePais varchar(50) not null
)


CREATE TABLE Cliente (
    CedulaID varchar(20) primary key,
    Nombre varchar(100) not null,
    PrimerApellido varchar(100) not null,
    SegundoApellido varchar(100) not null,
    FechaNacimiento Date not null,
    TipoIdentificacion varchar(50) not null,
    PaisResidenciaID int not null,
    Provincia varchar(50) not null,
    Canton varchar(50) not null,
    Distrito varchar(50) not null,
    CorreoElectronico varchar(50) unique not null,
	EsCostaRica bit not null default 0,

	CONSTRAINT CHK_Direccion_CostaRica CHECK (
		(EsCostaRica = 1 AND Provincia IS NOT NULL AND Canton IS NOT NULL AND Distrito IS NOT NULL) OR
		(EsCostaRica = 0 AND Provincia IS NULL AND Canton IS NULL AND Distrito IS NULL)
	), 
  
    constraint FK_Cliente_PaisResidencia foreign key (PaisResidenciaID) references PaisResidencia(PaisResidenciaID),

)

create table TelefonosCliente
(
	TelefonoCID int identity (1,1) primary key,
	CedulaID varchar(20) not null,
	Numero varchar(20) not null,
	CodigoPais varchar(5) not null,
	constraint CHK_ID check (TelefonoCID >= 1 and TelefonoCID <=3),
	constraint FK_TelefonosCliente_ClienteID foreign key (CedulaID) references Cliente (CedulaID),
)

create table Reservacion 
(
	ReservacionID int identity (1,1) primary key,
	CedulaID varchar(20) not null,
	HabitacionID int not null,
	FechaIngreso Datetime not null,
	CantidadPersonas int not null,
	PoseeVehiculo bit not null default 0,
	FechaSalida Datetime not null check(cast(FechaSalida as TIME) <= '12:00:00'),
	constraint FK_Reservacion_Cliente foreign key (CedulaID) references Cliente (CedulaID),
	constraint FK_Reservacion_Habitaciones foreign key (HabitacionID) references Habitaciones(HabitacionID)
)

create table MetodoPago (
    MetodoPagoID int identity(1,1) primary key,
    NombreMetodo varchar(50) not null, 
    DetallesAdicionales varchar(255) null 
);

create table Facturacion (
    FacturacionID int identity(1,1) primary key,
    ReservacionID int not null,
    MetodoPagoID int not null,
    FechaEmision datetime default GetDate(),
    ImporteTotal decimal(10,2) not null check (ImporteTotal >= 0.00),
    constraint FK_Facturacion_Reservacion foreign key (ReservacionID) references Reservacion(ReservacionID),
    constraint FK_Facturacion_MetodoPago foreign key (MetodoPagoID) references MetodoPago(MetodoPagoID)
);

create table EmpresaActividad
(
	CedulaJuridica varchar(20) primary key,
	Nombre varchar(50) not null, 
	CorreoElectronico varchar(100) unique not null,
	Telefono varchar(20) not null,
	NombreContacto varchar(100) not null,
	Provincia varchar(50) not null,
	Canton varchar(50) not null,
	Distrito varchar(50) not null,
	SeniasExactas text not null,
	Precio decimal (10,2) not null check(Precio >= 0.00)
)

create table TipoActividad
(
	TipoActividadID int identity (1,1) primary key,
	Nombre varchar(50) not null,	
	Descripcion text not null
)

create table EmpresaActividadTipo
(
	CedulaJuridica varchar(20) not null,
	TipoActividadID int not null,
	constraint FK_EmpresaActividadTipo_EmpresaActividad foreign key (CedulaJuridica) references EmpresaActividad (CedulaJuridica),
	constraint FK_EmpresaActividadTipo_TipoActividad foreign key (TipoActividadID) references TipoActividad (TipoActividadID),
)

create table ServicioActividad
(
	ServicioActividadID int identity(1,1) primary key,
	Nombre varchar(50) not null
)

create table EmpresaActividadServicio
(
	CedulaJuridica varchar(20) not null,
	ServicioActividadID int not null,
	constraint FK_EmpresaActividadServicio_EmpresaActividad foreign key (CedulaJuridica) references EmpresaActividad (CedulaJuridica),
	constraint FK_EmpresaActividadServicio_ServicioActividad foreign key (ServicioActividadID) references ServicioActividad (ServicioActividadID) 
)

Alter table PaisResidencia add CodigoPais varchar(5) not null;
Alter table TipoHabitacion add CedulaJuridica varchar(20) not null;
Alter table TipoHabitacion add constraint FK_TipoHabitacion_EmpresaHotel foreign key (CedulaJuridica) references EmpresaHotel (CedulaJuridica);
Alter table Cliente add Contrasenia varchar(15) not null;
Alter table EmpresaActividad add Descripcion text not null;

ALTER TABLE Reservacion ADD Estado varchar(20) NOT NULL DEFAULT 'ACTIVO';
ALTER TABLE Reservacion ADD CONSTRAINT CHK_Estado_Reservacion CHECK (Estado IN ('ACTIVO', 'CERRADO'));
ALTER TABLE Facturacion ADD EstadoPago varchar(20) NOT NULL DEFAULT 'PENDIENTE';
ALTER TABLE Facturacion ADD CONSTRAINT CHK_Estado_Pago CHECK (EstadoPago IN ('PENDIENTE', 'PAGADO'));
ALTER TABLE Reservacion ADD FechaCheckOut datetime NULL;

ALTER TABLE HotelServicios ADD CONSTRAINT PK_HotelServicios PRIMARY KEY (CedulaJuridica, ServicioID);
ALTER TABLE RedSocialHotel ADD CONSTRAINT PK_RedSocialHotel PRIMARY KEY (RedSocialID, CedulaJuridica);
ALTER TABLE TipoHabitacionCama ADD CONSTRAINT PK_TipoHabitacionCama PRIMARY KEY (TipoHabitacionID, TipoCamaID);
ALTER TABLE TipoHabitacionComodidad ADD CONSTRAINT PK_TipoHabitacionComodidad PRIMARY KEY (TipoHabitacionID, ComodidadID);
ALTER TABLE EmpresaActividadTipo ADD CONSTRAINT PK_EmpresaActividadTipo PRIMARY KEY (CedulaJuridica, TipoActividadID);
ALTER TABLE EmpresaActividadServicio ADD CONSTRAINT PK_EmpresaActividadServicio PRIMARY KEY (CedulaJuridica, ServicioActividadID);



