INSERT INTO TipoHotel (Nombre) VALUES 
('Hotel'),
('Hostal'),
('Casa'),
('Departamento'),
('Cuarto Compartido'),
('Cabaña');

-- Servicios para Hoteles
INSERT INTO Servicios (Nombre) VALUES 
('WiFi Gratuito'),
('Piscina'),
('Gimnasio'),
('Spa'),
('Restaurante'),
('Bar'),
('Servicio a la Habitación'),
('Lavandería'),
('Estacionamiento'),
('Aire Acondicionado'),
('Desayuno Incluido'),
('Centro de Negocios'),
('Sala de Conferencias'),
('Transporte al Aeropuerto'),
('Recepción 24 Horas');

-- Redes Sociales
INSERT INTO RedSocial (Nombre) VALUES 
('Facebook'),
('Instagram'),
('X'),
('TikTok'),
('YouTube'),
('Airbnb'),
('Threads');


-- Tipos de Cama
INSERT INTO TipoCama (Nombre, Capacidad) VALUES 
('Individual', 1),
('Matrimonial', 2),
('Queen Size', 2),
('King Size', 2),
('Cama Doble', 2),
('Litera', 2),
('Sofá Cama', 1);

-- Comodidades para Habitaciones
INSERT INTO Comodidades (Nombre) VALUES 
('Televisión'),
('Aire Acondicionado'),
('Minibar'),
('Caja Fuerte'),
('Escritorio'),
('Silla'),
('Armario'),
('Baño Privado'),
('Secador de Cabello'),
('Plancha'),
('Cafetera'),
('Balcón'),
('Vista al Mar'),
('Vista a la Montaña'),
('Jacuzzi');

-- Países de Residencia (principales)
INSERT INTO PaisResidencia (NombrePais, CodigoPais) VALUES 
('Costa Rica', '+506'),
('Estados Unidos', '+1'),
('Canadá', '+1'),
('México', '+52'),
('Guatemala', '+502'),
('Nicaragua', '+505'),
('Panamá', '+507'),
('España', '+34'),
('Francia', '+33'),
('Alemania', '+49'),
('Reino Unido', '+44'),
('Italia', '+39'),
('Argentina', '+54'),
('Brasil', '+55'),
('Chile', '+56'),
('Colombia', '+57'),
('Perú', '+51'),
('Ecuador', '+593'),
('Venezuela', '+58'),
('Uruguay', '+598');

-- Métodos de Pago
INSERT INTO MetodoPago (NombreMetodo, DetallesAdicionales) VALUES 
('Efectivo', 'Pago en colones o dólares'),
('Tarjeta de Crédito', 'Visa, MasterCard, American Express'),
('Tarjeta de Débito', 'Todas las tarjetas de débito'),
('Transferencia Bancaria', 'SINPE Móvil o transferencia tradicional');


-- Tipos de Actividad
INSERT INTO TipoActividad (Nombre, Descripcion) VALUES 
('Tour en Yate', 'Paseos en yate por la costa con diferentes duraciones'),
('Kayak', 'Recorridos en kayak por ríos, lagos o mar'),
('Canopy', 'Tirolinas a través del bosque tropical'),
('Rafting', 'Descenso de ríos en balsas inflables'),
('Buceo', 'Inmersiones submarinas con equipo completo'),
('Snorkeling', 'Exploración marina con máscara y tubo'),
('Senderismo', 'Caminatas por senderos naturales'),
('Observación de Aves', 'Tours especializados para avistar aves exóticas'),
('Tour de Café', 'Visita a plantaciones y proceso del café'),
('Pesca Deportiva', 'Excursiones de pesca en mar o ríos'),
('Tour Nocturno', 'Expediciones nocturnas para observar vida silvestre'),
('Escalada en Roca', 'Ascenso en formaciones rocosas naturales'),
('Surf', 'Clases y tours de surf en diferentes playas'),
('Stand Up Paddle', 'Actividad de remo en tabla sobre agua'),
('Tour en ATV', 'Recorridos en vehículos todo terreno'),
('Cabalgata', 'Paseos a caballo por diferentes terrenos'),
('Tour Gastronómico', 'Degustación de comida típica y especialidades'),
('Visita a Volcanes', 'Excursiones a cráteres y zonas volcánicas'),
('Tour Cultural', 'Visitas a sitios históricos y comunidades locales'),
('Yoga al Aire Libre', 'Sesiones de yoga en espacios naturales');

-- Servicios para Actividades
INSERT INTO ServicioActividad (Nombre) VALUES 
('Transporte Incluido'),
('Guía Especializado'),
('Equipo Incluido'),
('Seguro de Accidentes'),
('Almuerzo Incluido'),
('Fotografía Profesional'),
('Certificación'),
('Grupos Pequeños'),
('Acceso VIP'),
('Souvenir Incluido');



select * from EmpresaHotel
select * from RedSocialHotel
select * from HotelServicios
select * from TelefonosEmpresa
select * from UsuarioSistemaHotel

select * from EmpresaActividad
select * from EmpresaActividadTipo
select * from EmpresaActividadServicio
select * from UsuarioSistemaRecreativo

select * from TipoHabitacion
select * from TipoHabitacionComodidad
select * from FotosHabitacion
select * from Habitaciones

select * from Reservacion

INSERT INTO EmpresaHotel (CedulaJuridica, Nombre, TipoHotelID, Provincia, Canton, Distrito, Barrio, SeniasExactas, ReferenciaGPS, CorreoElectronico, URLSitioWeb) VALUES
('3101234567890', 'Hotel Costa Brava', 1, 'San José', 'San José', 'Carmen', 'Centro', '100 metros sur del Teatro Nacional', '9.9326, -84.0795', 'info@hotelcostabrava.com', 'www.hotelcostabrava.com'),
('3101234567891', 'Hostal Pura Vida', 2, 'Cartago', 'Cartago', 'Oriental', 'San Nicolás', 'Frente a la Basílica de los Ángeles', '9.8644, -83.9192', 'reservas@hostalpuravida.com', 'www.hostalpuravida.com'),
('3101234567892', 'Casa Verde Eco Lodge', 3, 'Alajuela', 'San Carlos', 'Florencia', 'Centro', 'Entrada principal de La Fortuna, 200m norte', '10.4756, -84.6431', 'contacto@casaverde.com', 'www.casaverdecostarica.com'),
('3101234567893', 'Departamentos El Roble', 4, 'Heredia', 'Heredia', 'Mercedes', 'Los Targuás', 'Contiguo al Parque Central', '9.9981, -84.1164', 'gerencia@departamentoselroble.com', NULL),
('3101234567894', 'Backpackers Paradise', 5, 'Puntarenas', 'Puntarenas', 'Puntarenas', 'El Carmen', '50 metros del muelle', '9.9748, -84.8353', 'hello@backpackersparadise.com', 'www.backpackersparadise.com'),
('3101234567895', 'Cabaña Tropical', 6, 'Guanacaste', 'Liberia', 'Liberia', 'Centro', 'Aeropuerto Internacional Daniel Oduber, 5km sur', '10.5930, -85.5444', 'info@cabanatropical.com', 'www.cabanatropical.com'),
('3101234567896', 'Hotel Montaña Azul', 1, 'Limón', 'Pococí', 'Guápiles', 'Centro', 'Terminal de buses, 300m oeste', '10.2178, -83.7881', 'reservaciones@montanaazul.com', 'www.montanaazul.com'),
('3101234567897', 'Villa del Mar', 3, 'Puntarenas', 'Garabito', 'Jacó', 'Centro', 'Playa de Jacó, primera línea', '9.6147, -84.6286', 'contact@villadelmar.com', 'www.villadelmarjaco.com');

-- SERVICIOS DE HOTELES
INSERT INTO HotelServicios (CedulaJuridica, ServicioID) VALUES
-- Hotel Costa Brava (servicios de lujo)
('3101234567890', 1), ('3101234567890', 2), ('3101234567890', 4), ('3101234567890', 5), ('3101234567890', 6), ('3101234567890', 9), ('3101234567890', 10), ('3101234567890', 11), ('3101234567890', 15),
-- Hostal Pura Vida (servicios básicos)
('3101234567891', 1), ('3101234567891', 8), ('3101234567891', 11), ('3101234567891', 15),
-- Casa Verde Eco Lodge (servicios ecológicos)
('3101234567892', 1), ('3101234567892', 5), ('3101234567892', 8), ('3101234567892', 11), ('3101234567892', 14),
-- Departamentos El Roble (servicios apartamento)
('3101234567893', 1), ('3101234567893', 8), ('3101234567893', 9), ('3101234567893', 10),
-- Backpackers Paradise (servicios mochileros)
('3101234567894', 1), ('3101234567894', 8), ('3101234567894', 11),
-- Cabaña Tropical (servicios cabaña)
('3101234567895', 1), ('3101234567895', 2), ('3101234567895', 5), ('3101234567895', 9), ('3101234567895', 14),
-- Hotel Montaña Azul (servicios completos)
('3101234567896', 1), ('3101234567896', 2), ('3101234567896', 3), ('3101234567896', 5), ('3101234567896', 6), ('3101234567896', 9), ('3101234567896', 10), ('3101234567896', 11), ('3101234567896', 15),
-- Villa del Mar (servicios playa)
('3101234567897', 1), ('3101234567897', 2), ('3101234567897', 5), ('3101234567897', 6), ('3101234567897', 9), ('3101234567897', 13);

-- TELÉFONOS DE EMPRESAS
INSERT INTO TelefonosEmpresa (Numero, CedulaJuridica) VALUES
('2234-5678', '3101234567890'), ('8765-4321', '3101234567890'),
('2591-3456', '3101234567891'), ('7123-9876', '3101234567891'),
('2479-1234', '3101234567892'), ('6234-5678', '3101234567892'),
('2237-8901', '3101234567893'), ('8456-7890', '3101234567893'),
('2661-2345', '3101234567894'), ('7890-1234', '3101234567894'),
('2666-5678', '3101234567895'), ('8123-4567', '3101234567895'),
('2758-9012', '3101234567896'), ('6789-0123', '3101234567896'),
('2643-3456', '3101234567897'), ('7456-7890', '3101234567897');

-- REDES SOCIALES DE HOTELES
INSERT INTO RedSocialHotel (NombreUsuario, RedSocialID, CedulaJuridica) VALUES
('hotelcostabrava', 1, '3101234567890'), ('hotelcostabrava_cr', 2, '3101234567890'),
('hostalpuravida', 1, '3101234567891'), ('hostalpuravida', 2, '3101234567891'), ('hostalpuravida', 6, '3101234567891'),
('casaverdeecolodge', 1, '3101234567892'), ('casaverde_cr', 2, '3101234567892'),
('departamentoselroble', 1, '3101234567893'),
('backpackersparadise', 1, '3101234567894'), ('backpackersparadise_cr', 2, '3101234567894'), ('backpackersparadise', 4, '3101234567894'),
('cabanatropical', 1, '3101234567895'), ('cabanatropical_cr', 2, '3101234567895'),
('montanaazulhotel', 1, '3101234567896'), ('montanaazul_cr', 2, '3101234567896'),
('villadelmarjaco', 1, '3101234567897'), ('villadelmar_jaco', 2, '3101234567897'), ('villadelmarjaco', 6, '3101234567897');

-- TIPOS DE HABITACIÓN
INSERT INTO TipoHabitacion (Nombre, Descripcion, Precio, CedulaJuridica) VALUES
-- Hotel Costa Brava
('Suite Presidencial', 'Habitación de lujo con vista panorámica, sala de estar y jacuzzi', 250000.00, '3101234567890'),
('Habitación Deluxe', 'Habitación amplia con cama king size y balcón', 150000.00, '3101234567890'),
('Habitación Estándar', 'Habitación cómoda con todas las comodidades básicas', 85000.00, '3101234567890'),
-- Hostal Pura Vida
('Habitación Privada', 'Habitación privada con baño compartido', 25000.00, '3101234567891'),
('Dormitorio Compartido', 'Cama en dormitorio de 6 personas', 12000.00, '3101234567891'),
-- Casa Verde Eco Lodge
('Cabaña Familiar', 'Cabaña ecológica para hasta 4 personas', 95000.00, '3101234567892'),
('Habitación Doble Eco', 'Habitación doble con materiales sostenibles', 65000.00, '3101234567892'),
-- Departamentos El Roble
('Apartamento 1 Dormitorio', 'Apartamento completo con cocina y sala', 55000.00, '3101234567893'),
('Apartamento 2 Dormitorios', 'Apartamento familiar con 2 habitaciones', 85000.00, '3101234567893'),
-- Backpackers Paradise
('Cama en Dormitorio Mixto', 'Cama en dormitorio compartido mixto', 8000.00, '3101234567894'),
('Habitación Privada Básica', 'Habitación privada económica', 20000.00, '3101234567894'),
-- Cabaña Tropical
('Cabaña Rústica', 'Cabaña de madera con aire acondicionado', 70000.00, '3101234567895'),
('Cabaña Premium', 'Cabaña con piscina privada', 120000.00, '3101234567895'),
-- Hotel Montaña Azul
('Habitación Superior', 'Habitación con vista a la montaña', 110000.00, '3101234567896'),
('Suite Junior', 'Suite con sala de estar separada', 180000.00, '3101234567896'),
-- Villa del Mar
('Habitación Vista Mar', 'Habitación con vista directa al océano', 195000.00, '3101234567897'),
('Habitación Vista Jardín', 'Habitación con vista a los jardines tropicales', 135000.00, '3101234567897');

-- CAMAS POR TIPO DE HABITACIÓN
INSERT INTO TipoHabitacionCama (TipoHabitacionID, TipoCamaID, Cantidad) VALUES
-- Suite Presidencial - King Size
(1, 4, 1),
-- Habitación Deluxe - King Size
(2, 4, 1),
-- Habitación Estándar - Queen Size
(3, 3, 1),
-- Habitación Privada - Matrimonial
(4, 2, 1),
-- Dormitorio Compartido - Literas
(5, 6, 3),
-- Cabaña Familiar - Queen + Individual
(6, 3, 1), (6, 1, 2),
-- Habitación Doble Eco - Matrimonial
(7, 2, 1),
-- Apartamento 1 Dormitorio - Queen
(8, 3, 1),
-- Apartamento 2 Dormitorios - Queen + Individual
(9, 3, 1), (9, 1, 2),
-- Dormitorio Mixto - Literas
(10, 6, 4),
-- Habitación Privada Básica - Individual
(11, 1, 2),
-- Cabaña Rústica - Matrimonial
(12, 2, 1),
-- Cabaña Premium - King Size
(13, 4, 1),
-- Habitación Superior - Queen Size
(14, 3, 1),
-- Suite Junior - King Size
(15, 4, 1),
-- Habitación Vista Mar - King Size
(16, 4, 1),
-- Habitación Vista Jardín - Queen Size
(17, 3, 1);

-- COMODIDADES POR TIPO DE HABITACIÓN
INSERT INTO TipoHabitacionComodidad (TipoHabitacionID, ComodidadID, Cantidad) VALUES
-- Suite Presidencial (1) - Todas las comodidades
(1, 1, 1), (1, 2, 1), (1, 3, 1), (1, 4, 1), (1, 5, 1), (1, 6, 2), (1, 7, 1), (1, 8, 1), (1, 9, 1), (1, 10, 1), (1, 11, 1), (1, 12, 1), (1, 13, 1), (1, 15, 1),
-- Habitación Deluxe (2)
(2, 1, 1), (2, 2, 1), (2, 3, 1), (2, 4, 1), (2, 5, 1), (2, 6, 1), (2, 7, 1), (2, 8, 1), (2, 9, 1), (2, 12, 1), (2, 13, 1),
-- Habitación Estándar (3)
(3, 1, 1), (3, 2, 1), (3, 5, 1), (3, 6, 1), (3, 7, 1), (3, 8, 1), (3, 9, 1),
-- Habitación Privada (4)
(4, 1, 1), (4, 6, 1), (4, 7, 1),
-- Dormitorio Compartido (5)
(5, 7, 1),
-- Cabaña Familiar (6)
(6, 1, 1), (6, 2, 1), (6, 5, 1), (6, 6, 2), (6, 7, 1), (6, 8, 2), (6, 12, 1), (6, 14, 1),
-- Habitación Doble Eco (7)
(7, 1, 1), (7, 6, 1), (7, 7, 1), (7, 8, 1), (7, 12, 1), (7, 14, 1),
-- Apartamento 1 Dormitorio (8)
(8, 1, 1), (8, 2, 1), (8, 5, 1), (8, 6, 1), (8, 7, 1), (8, 8, 1), (8, 11, 1),
-- Apartamento 2 Dormitorios (9)
(9, 1, 2), (9, 2, 1), (9, 5, 1), (9, 6, 3), (9, 7, 1), (9, 8, 2), (9, 11, 1),
-- Dormitorio Mixto (10)
(10, 7, 1),
-- Habitación Privada Básica (11)
(11, 1, 1), (11, 6, 1), (11, 8, 1),
-- Cabaña Rústica (12)
(12, 1, 1), (12, 2, 1), (12, 6, 1), (12, 7, 1), (12, 8, 1), (12, 12, 1),
-- Cabaña Premium (13)
(13, 1, 1), (13, 2, 1), (13, 3, 1), (13, 5, 1), (13, 6, 1), (13, 7, 1), (13, 8, 1), (13, 12, 1), (13, 13, 1),
-- Habitación Superior (14)
(14, 1, 1), (14, 2, 1), (14, 5, 1), (14, 6, 1), (14, 7, 1), (14, 8, 1), (14, 9, 1), (14, 14, 1),
-- Suite Junior (15)
(15, 1, 1), (15, 2, 1), (15, 3, 1), (15, 4, 1), (15, 5, 1), (15, 6, 2), (15, 7, 1), (15, 8, 1), (15, 9, 1), (15, 10, 1), (15, 14, 1),
-- Habitación Vista Mar (16)
(16, 1, 1), (16, 2, 1), (16, 3, 1), (16, 4, 1), (16, 5, 1), (16, 6, 1), (16, 7, 1), (16, 8, 1), (16, 9, 1), (16, 12, 1), (16, 13, 1),
-- Habitación Vista Jardín (17)
(17, 1, 1), (17, 2, 1), (17, 5, 1), (17, 6, 1), (17, 7, 1), (17, 8, 1), (17, 12, 1), (17, 14, 1);

-- HABITACIONES FÍSICAS
INSERT INTO Habitaciones (Numero, CedulaJuridica, TipoHabitacionID) VALUES
-- Hotel Costa Brava
(101, '3101234567890', 3), (102, '3101234567890', 3), (103, '3101234567890', 2), (104, '3101234567890', 2), (201, '3101234567890', 1),
-- Hostal Pura Vida
(1, '3101234567891', 4), (2, '3101234567891', 4), (3, '3101234567891', 5), (4, '3101234567891', 5),
-- Casa Verde Eco Lodge
(1, '3101234567892', 6), (2, '3101234567892', 6), (3, '3101234567892', 7), (4, '3101234567892', 7),
-- Departamentos El Roble
(101, '3101234567893', 8), (102, '3101234567893', 8), (201, '3101234567893', 9), (202, '3101234567893', 9),
-- Backpackers Paradise
(1, '3101234567894', 10), (2, '3101234567894', 10), (3, '3101234567894', 11), (4, '3101234567894', 11),
-- Cabaña Tropical
(1, '3101234567895', 12), (2, '3101234567895', 12), (3, '3101234567895', 13),
-- Hotel Montaña Azul
(101, '3101234567896', 14), (102, '3101234567896', 14), (103, '3101234567896', 14), (201, '3101234567896', 15), (202, '3101234567896', 15),
-- Villa del Mar
(101, '3101234567897', 16), (102, '3101234567897', 16), (103, '3101234567897', 17), (104, '3101234567897', 17);

-- FOTOS DE HABITACIONES (usando NULL ya que image requiere datos binarios)
INSERT INTO FotosHabitacion (Fotos, TipoHabitacionID) VALUES
-- Nota: Las fotos se insertan como NULL, en la aplicación real deberías cargar imágenes reales
(NULL, 1), (NULL, 1), (NULL, 1),
(NULL, 2), (NULL, 2),
(NULL, 3), (NULL, 3),
(NULL, 4), (NULL, 5),
(NULL, 6), (NULL, 6),
(NULL, 7), (NULL, 8),
(NULL, 9), (NULL, 10),
(NULL, 11), (NULL, 12),
(NULL, 13), (NULL, 13),
(NULL, 14), (NULL, 15),
(NULL, 16), (NULL, 16),
(NULL, 17);

