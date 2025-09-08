/*

AUTORES:
	AYALA HERNÁNDEZ MARÍA FERNANDA
    PORTILLA HERMENEGILDO ELIZABETH
    VALENZUELA ASCENCIO GUSTAVO
    JIMENEZ AYALA YORDI JOSUE

FECHA DE CREACION: 28 DE ABRIL DE 2025

ULTIMA ACTUALIZACION: 25 DE MAYO DE 2025 

DESCRIPCION: DDL QUE CONTIENE LA CREACION DE TODAS LAS TABLAS DE LA BASE, INCLUYENDO LOS CONSTRAINTS QUE REQUIEREN

*/

-- CREAMOS LA BASE

CREATE DATABASE Equipo09AppSafe

-- SELECCIONAMOS LA BASE PARA EMPEZAR CON EL DDL

USE Equipo09AppSafe
GO

-- CREAMOS LOS ESQUEMAS

CREATE SCHEMA USUARIO
GO

CREATE SCHEMA CONDUCTOR
GO

CREATE SCHEMA CLIENTE
GO

CREATE SCHEMA VIAJE
GO

CREATE SCHEMA DESCUENTO
GO

-- TABLA USUARIO

CREATE TABLE USUARIO.USUARIO(
	id_usuario  INTEGER NOT NULL IDENTITY(1,1),
	nombre_usuario VARCHAR(40) NOT NULL,
	correo VARCHAR(80) NULL CONSTRAINT dfCorreoUsuario DEFAULT 'SIN CORREO',
	clave CHAR(20) NOT NULL, 
	fecha_ingreso DATE NOT NULL,
	nombre VARCHAR(60) NOT NULL,
	ap_paterno VARCHAR(60) NOT NULL,
	ap_materno VARCHAR(60) NULL, 
	cliente BIT NOT NULL,
	conductor BIT NOT NULL,
	id_recomendado INTEGER NULL,
	
	CONSTRAINT pkUsuario PRIMARY KEY (id_usuario),
	CONSTRAINT akNombreUsuario UNIQUE (nombre_usuario),
	CONSTRAINT ckClave CHECK (
		LEN(clave) = 20
		AND clave LIKE '%[A-Z]%'
		AND clave LIKE '%[0-9]%'
		AND (clave LIKE '%#%' OR clave LIKE '%*%' OR clave LIKE '%$%')),
    CONSTRAINT fkUsuarioRecomendado FOREIGN KEY (id_recomendado) REFERENCES USUARIO.USUARIO(id_usuario),

);

-- TABLA CONDUCTOR

CREATE TABLE USUARIO.CONDUCTOR(
	id_usuario  INTEGER NOT NULL,
	num_licencia INTEGER NOT NULL,
	vigencia_lic DATE NOT NULL,
	foto IMAGE NOT NULL,
	descripcion VARCHAR(600) NOT NULL,

	CONSTRAINT pkConductor PRIMARY KEY (id_usuario),
	CONSTRAINT fkUsuarioConductor FOREIGN KEY (id_usuario) REFERENCES USUARIO.USUARIO(id_usuario)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT akNumLicencia UNIQUE(num_licencia),
	CONSTRAINT ckDescripcion CHECK(LEN (descripcion) <= 600)
);


-- TABLA CLIENTE 

CREATE TABLE USUARIO.CLIENTE(
	id_usuario  INTEGER NOT NULL,
	rfc varchar(13) NOT NULL,
	direccion VARCHAR(300) NOT NULL,
	numero BIGINT NOT NULL, 
	fecha_registro DATE NOT NULL, 
	calificacion TINYINT NULL CONSTRAINT dfCalificacionCliente DEFAULT (5),

	CONSTRAINT pkCliente PRIMARY KEY (id_usuario),
	CONSTRAINT fkUsuarioCliente FOREIGN KEY (id_usuario) REFERENCES USUARIO.USUARIO(id_usuario)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT ckCalificacion CHECK(calificacion IN (1,2,3,4,5)),
	CONSTRAINT ckRfc CHECK (LEN(rfc) = 13)
);


-- TABLA PAGO

CREATE TABLE CONDUCTOR.PAGO(
    id_usuario INT NOT NULL,
    folio CHAR(8) NOT NULL,
    fecha DATE NOT NULL,
    monto MONEY NOT NULL,
    CONSTRAINT pkPago PRIMARY KEY (id_usuario ASC, folio ASC),
    CONSTRAINT fkIdUsuarioPago FOREIGN KEY (id_usuario) REFERENCES USUARIO.CONDUCTOR (id_usuario)
    on DELETE CASCADE,
    CONSTRAINT ckFolio CHECK (folio LIKE '1%')
);


-- TABLA TIPO

CREATE TABLE DESCUENTO.TIPO (
    id_tipo INT NOT NULL IDENTITY(1,1),
    nombre VARCHAR(60) NOT NULL,
    CONSTRAINT pkTipo PRIMARY KEY (id_tipo),
    CONSTRAINT akNombre UNIQUE (nombre)
);


-- TABLA DESCUENTO

CREATE TABLE DESCUENTO.DESCUENTO(
    id_descuento INT NOT NULL IDENTITY(1,1),
    importe MONEY NOT NULL,
    vigencia DATE NOT NULL,
    id_usuario INT NOT NULL,
    id_tipo INT NOT NULL,
    CONSTRAINT pkDescuento PRIMARY KEY (id_descuento),
    CONSTRAINT fkIdUsuario FOREIGN KEY (id_usuario) REFERENCES USUARIO.USUARIO(id_usuario)
    	ON DELETE CASCADE
      ON UPDATE CASCADE,
    CONSTRAINT fkIdTipo FOREIGN KEY (id_tipo) REFERENCES DESCUENTO.TIPO(id_tipo)
    	ON DELETE CASCADE
      ON UPDATE CASCADE
);


-- TABLA MARCA

CREATE TABLE CONDUCTOR.MARCA(
    id_marca SMALLINT IDENTITY(1,1),
    nombre VARCHAR(80) NOT NULL,
    CONSTRAINT pkMarca PRIMARY KEY (id_marca),
    CONSTRAINT akNombreMarca UNIQUE (nombre)
);


-- TABLA MODELO

CREATE TABLE CONDUCTOR.MODELO(
    id_modelo INT NOT NULL IDENTITY(1,1),
    nombre VARCHAR(50) NOT NULL,
    id_marca SMALLINT NOT NULL,
    CONSTRAINT pkModelo PRIMARY KEY (id_modelo),
    CONSTRAINT fkMarcaModelo FOREIGN KEY (id_marca) REFERENCES CONDUCTOR.MARCA(id_marca) 
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT akNombreModelo UNIQUE (nombre)
);


-- TABLA AUTO

CREATE TABLE CONDUCTOR.[AUTO](
    id_auto INT NOT NULL IDENTITY(1,1),
    año SMALLINT NOT NULL,
    placa VARCHAR(8) NOT NULL,
    color VARCHAR(25) NOT NULL,
    id_modelo INT NOT NULL,
    id_usuario INT NOT NULL,
    CONSTRAINT pkAuto PRIMARY KEY (id_auto),
    CONSTRAINT ckAño CHECK (YEAR(GETDATE())-año <=5),
    CONSTRAINT fkIdModelo FOREIGN KEY (id_modelo) REFERENCES CONDUCTOR.MODELO(id_modelo)
    	ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fkIdUsuarioAuto FOREIGN KEY (id_usuario) REFERENCES USUARIO.CONDUCTOR(id_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


--TABLA  ADMINISTRADOR

CREATE TABLE USUARIO.ADMINISTRADOR(
	id_administrador  INTEGER NOT NULL IDENTITY(1,1),
	nombre_usuario VARCHAR(40) NOT NULL,
	correo VARCHAR(80) NULL CONSTRAINT dfCorreoAdmin DEFAULT 'SIN CORREO' ,
	clave CHAR(20) NOT NULL, 
	fecha_ingreso DATE NOT NULL,
	nombre VARCHAR(60) NOT NULL,
	ap_paterno VARCHAR(60) NOT NULL,
	ap_materno VARCHAR(60) NULL, 
	id_recomendado INTEGER NULL,
	
	CONSTRAINT pkAdministrador PRIMARY KEY (id_administrador),
	CONSTRAINT fkAdministradorRecomendado FOREIGN KEY (id_recomendado) REFERENCES USUARIO.ADMINISTRADOR(id_administrador),
	CONSTRAINT akNombreUsuarioAdmin UNIQUE (nombre_usuario),
	CONSTRAINT ckClaveAdmin CHECK (
		LEN(clave) = 20
		AND clave LIKE '%[A-Z]%'
		AND clave LIKE '%[0-9]%'
		AND (clave LIKE '%#%' OR clave LIKE '%*%' OR clave LIKE '%$%'))
);

-- TABLA QUEJA 

CREATE TABLE CLIENTE.QUEJA(
    id_queja INTEGER NOT NULL IDENTITY (1,1),
    descripcion VARCHAR(300) NOT NULL,
    titulo VARCHAR(40) NOT NULL,
    fecha_atencion DATE NOT NULL,
    fecha_queja DATE NULL CONSTRAINT dfFechaQueja DEFAULT GETDATE(),
    dias_respuesta AS (DATEDIFF(DAY, fecha_queja, fecha_atencion)),
    id_usuario INT NOT NULL,
    id_administrador INT NOT NULL,
    id_conductor INT NOT NULL,
    id_auto INT NOT NULL,
    CONSTRAINT pkQueja PRIMARY KEY (id_queja),
    CONSTRAINT fkIdUsuarioQueja FOREIGN KEY (id_usuario) REFERENCES USUARIO.CLIENTE(id_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fkIdConductorQueja FOREIGN KEY (id_conductor) REFERENCES USUARIO.CONDUCTOR(id_usuario),
    CONSTRAINT fkIdAutoQueja FOREIGN KEY (id_auto) REFERENCES CONDUCTOR.[AUTO](id_auto),
    CONSTRAINT fkIdAdministradorQueja FOREIGN KEY (id_administrador) REFERENCES USUARIO.ADMINISTRADOR(id_administrador)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

);


-- TABLA BANCO

CREATE TABLE CLIENTE.BANCO(
    id_banco SMALLINT NOT NULL IDENTITY(1,1),
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT pkBanco PRIMARY KEY (id_banco),
    CONSTRAINT akNombreBanco UNIQUE (nombre)
);


-- TABLA TARJETA

CREATE TABLE CLIENTE.TARJETA(
	id_tarjeta INTEGER NOT NULL IDENTITY(1,1),
	numero_tarjeta VARCHAR(24) NOT NULL,
	vigencia DATE NOT NULL,
	id_usuario INTEGER NOT NULL,
	id_banco SMALLINT NOT NULL,

	CONSTRAINT pkTarjeta PRIMARY KEY (id_tarjeta),
	CONSTRAINT ckNumeroTarjeta CHECK (LEN(numero_Tarjeta) = 16),
    CONSTRAINT akNumeroTarjeta UNIQUE (numero_Tarjeta),
	CONSTRAINT fkBancoTarjeta FOREIGN KEY (id_banco) REFERENCES CLIENTE.BANCO(id_banco) 
  	ON DELETE CASCADE
    ON UPDATE CASCADE,
	CONSTRAINT fkClienteTarjeta FOREIGN KEY (id_usuario) REFERENCES USUARIO.CLIENTE(id_usuario) 
  	ON DELETE CASCADE 
    ON UPDATE CASCADE
);


-- TABLA DESCUENTO_ADMIN

CREATE TABLE DESCUENTO.DESCUENTO_ADMIN(
	id_descuento INTEGER NOT NULL IDENTITY(1,1),
	importe MONEY NOT NULL, 
	vigencia DATE NOT NULL, 
	id_tipo INTEGER NOT NULL,
	id_administrador  INTEGER NOT NULL,

	CONSTRAINT pkDescuentoAdmin PRIMARY KEY (id_descuento),
	CONSTRAINT fkTipoDescuentoAdmin FOREIGN KEY (id_tipo) REFERENCES DESCUENTO.TIPO(id_tipo)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	CONSTRAINT fkAdministradorDescuentoAdmin FOREIGN KEY (id_administrador) REFERENCES USUARIO.ADMINISTRADOR (id_administrador)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);


-- TABLA TELEFONO

CREATE TABLE TELEFONO (
    id_administrador INT NOT NULL,
    numero BIGINT NOT NULL,
    CONSTRAINT pkTelefono PRIMARY KEY CLUSTERED (id_administrador ASC, numero ASC),
    CONSTRAINT fkAdministradorTelefono FOREIGN KEY (id_administrador) REFERENCES USUARIO.ADMINISTRADOR(id_administrador) 
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT lonNumero CHECK (LEN(numero) = 10)
);


-- TABLA ETIQUETA

CREATE TABLE VIAJE.ETIQUETA(
    id_etiqueta SMALLINT NOT NULL IDENTITY(1,1),
    nombre VARCHAR(80) NOT NULL,
    CONSTRAINT pkEtiqueta PRIMARY KEY (id_etiqueta),
    CONSTRAINT akNombreEtiqueta UNIQUE (nombre)
);


-- TABLA FACTURA

CREATE TABLE VIAJE.FACTURA(
	id_factura INTEGER NOT NULL IDENTITY(1,1),
	fecha_factura DATE NOT NULL, 
	importe MONEY NOT NULL,
	CONSTRAINT pkFactura PRIMARY KEY (id_factura)
);


-- TABLA ESTATUS

CREATE TABLE VIAJE.ESTATUS(
    id_estatus TINYINT NOT NULL IDENTITY(1,1),
    nombre VARCHAR(20) NOT NULL,
    CONSTRAINT pkEstatus PRIMARY KEY (id_estatus),
    CONSTRAINT ckNombreEstatus CHECK (nombre in ('Solicitado','Programado', 'Confirmado', 
                                                'En curso', 'Terminado', 'Por cobrar', 
                                                'Pagado', 'Con adeudo','Cancelado')),
    CONSTRAINT akNombreEstatus UNIQUE (nombre)
);


-- TABLA VIAJE ESTATUS

CREATE TABLE VIAJE.VIAJE_ESTATUS(
    id_estatus TINYINT NOT NULL,
    id_viaje INT NOT NULL,
    fecha_estatus DATE NOT NULL,
    hora_estatus TIME NOT NULL
    CONSTRAINT pkViajeEstatus PRIMARY KEY CLUSTERED (id_estatus ASC, id_viaje ASC)
);


-- TABLA VIAJE

CREATE TABLE VIAJE.VIAJE (
    id_viaje INTEGER NOT NULL IDENTITY(1,1),
    fecha_solicitud DATE NOT NULL,
    hora_solicitud TIME NOT NULL,
    latitud_origen FLOAT NOT NULL,
    latitud_destino FLOAT NOT NULL,
    longitud_origen FLOAT NOT NULL,
    longitud_destino FLOAT NOT NULL,
    fecha_inicio DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    calificacion TINYINT NULL  CONSTRAINT dfCalificacionViaje DEFAULT 5,
    propina MONEY NULL,
    tipo CHAR(1) NOT NULL,
    programado CHAR(2) NOT NULL,
    comentario VARCHAR(200) NOT NULL,
    importe MONEY NOT NULL,
	id_auto INT NOT NULL,
    id_etiqueta SMALLINT NULL,
    id_factura INT NULL,
    id_estatus TINYINT NOT NULL,
    id_usuario INT NOT NULL,
    id_tarjeta INT NULL,
  
  CONSTRAINT pkViaje PRIMARY KEY (id_viaje),
  CONSTRAINT fkAutoViaje FOREIGN KEY (id_auto) REFERENCES CONDUCTOR.[AUTO] (id_auto)
  	ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fkEtiquetaViaje FOREIGN KEY (id_etiqueta) REFERENCES VIAJE.ETIQUETA (id_etiqueta)
  	ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fkFacturaViaje FOREIGN KEY (id_factura) REFERENCES VIAJE.FACTURA (id_factura)
  	ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fkEstatusViaje FOREIGN KEY (id_estatus) REFERENCES VIAJE.ESTATUS (id_estatus)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fkUsuarioViaje FOREIGN KEY (id_usuario) REFERENCES USUARIO.CLIENTE (id_usuario),
  CONSTRAINT fkTarjetaViaje FOREIGN KEY (id_tarjeta) REFERENCES CLIENTE.TARJETA (id_tarjeta),
  CONSTRAINT ckCalificacionViaje CHECK(calificacion IN (1,2,3,4,5)),
  CONSTRAINT ckPropina CHECK(propina IN (10, 15, 20)),
  CONSTRAINT ckTipo CHECK(tipo IN ('T', 'E')),
  CONSTRAINT ckProgramado CHECK (programado IN ('SI', 'NO')),
);


-- TABLA UBICACION

CREATE TABLE VIAJE.UBICACION(
	id_ubicacion INTEGER NOT NULL IDENTITY(1,1),
	latitud FLOAT NOT NULL,
	longitud FLOAT NOT NULL,
    id_viaje INTEGER NOT NULL,
	CONSTRAINT pkUbicacion PRIMARY KEY (id_ubicacion),
    CONSTRAINT fkViajeUbicacion FOREIGN KEY (id_viaje) REFERENCES VIAJE.VIAJE(id_viaje)
        ON DELETE CASCADE
);


-- TABLA TIPO_ACCIDENTE

CREATE TABLE VIAJE.TIPO_ACCIDENTE(
	id_tipo SMALLINT NOT NULL IDENTITY(1,1),
	nombre VARCHAR(60) NOT NULL,
	CONSTRAINT pkTipoAccidente PRIMARY KEY (id_tipo),
    CONSTRAINT akNombreTipoAccidente UNIQUE (nombre)
);


-- TABLA ACCIDENTE

CREATE TABLE VIAJE.ACCIDENTE(
	id_accidente INTEGER NOT NULL IDENTITY(1,1),
	ubicacion VARCHAR(100) NOT NULL,
	monto MONEY NOT NULL,
	herido CHAR(2) NOT NULL,
	fecha DATE NOT NULL,
	hora TIME NOT NULL,
    culpable CHAR(1) NOT NULL,
	descripcion VARCHAR(300) NOT NULL,
	id_viaje INTEGER NOT NULL,
	id_tipo SMALLINT NOT NULL,

	CONSTRAINT pkAccidente PRIMARY KEY (id_accidente), 
	CONSTRAINT fkTipoAccidente FOREIGN KEY (id_tipo) REFERENCES VIAJE.TIPO_ACCIDENTE(id_tipo)
  	ON DELETE CASCADE
    ON UPDATE CASCADE,
	CONSTRAINT fkViajeAccidente FOREIGN KEY (id_viaje) REFERENCES VIAJE.VIAJE(id_viaje) 
    ON DELETE CASCADE
    ON UPDATE CASCADE,
	CONSTRAINT chkHerido CHECK (herido IN ('SI', 'NO')),
    CONSTRAINT ckCulpable CHECK (culpable IN ('SI', 'NO'))

);

-- CREACION DE INIDICES

CREATE UNIQUE NONCLUSTERED INDEX idxRFC ON USUARIO.CLIENTE (rfc)
GO
