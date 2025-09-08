/*

AUTORES:
	AYALA HERNÁNDEZ MARÍA FERNANDA
    PORTILLA HERMENEGILDO ELIZABETH
    VALENZUELA ASCENCIO GUSTAVO
    JIMENEZ AYALA YORDI JOSUE

FECHA DE CREACION: 24 DE MAYO DE 2025

ULTIMA ACTUALIZACION: 25 DE MAYO DE 2025 

DESCRIPCION: DML QUE VALIDA LOS TRIGGERS Y LOS CONSTRAINTS

*/

-- SELECCIONAMOS NUESTRA BASE PARA TRABAJAR SOBRE ELLA

USE Equipo09AppSafe
GO

-------------------------------------------------------------- TRIGGERS --------------------------------------------------------------


-- VALIDACION (Trigger que valida en la tabla VIAJE que si un viaje es programado el inicio no pase de 2 dias)


BEGIN TRAN

INSERT INTO VIAJE.VIAJE (
    fecha_solicitud, hora_solicitud, latitud_origen, latitud_destino,
    longitud_origen, longitud_destino, fecha_inicio, hora_inicio, propina,
    tipo, programado, comentario, importe, id_auto, id_etiqueta, id_factura,
    id_estatus, id_usuario, id_tarjeta
)
VALUES 
('2025-05-27', '19:00', 19.4326, 19.3900, -99.1332, -99.1500, '2025-05-29', '20:15', 15, 
 'E', 'SI', 'Viaje Programado', 100.50, 12, 1, NULL, 2, 2, NULL)

ROLLBACK TRAN


-- VALIDACION (Trigger que valida que si no es programado la fecha y hora inicio sea la misma que la de solicitud)

BEGIN TRAN

INSERT INTO VIAJE.VIAJE (
    fecha_solicitud, hora_solicitud, latitud_origen, latitud_destino,
    longitud_origen, longitud_destino, fecha_inicio, hora_inicio, propina,
    tipo, programado, comentario, importe, id_auto, id_etiqueta, id_factura,
    id_estatus, id_usuario, id_tarjeta
)
VALUES 
('2025-05-27', '19:00', 19.4326, 19.3900, -99.1332, -99.1500, '2025-05-29', '20:15', 15, 
 'E', 'NO', 'Viaje por iniciar', 100.50, 12, 1, NULL, 2, 2, NULL)

ROLLBACK TRAN

-- VALIDACION (Trigger que valida que no se ponga un id de tarjeta si no se va a pagar con tarjeta (tipo = 'E'))

BEGIN TRAN

INSERT INTO VIAJE.VIAJE (
    fecha_solicitud, hora_solicitud, latitud_origen, latitud_destino,
    longitud_origen, longitud_destino, fecha_inicio, hora_inicio, propina,
    tipo, programado, comentario, importe, id_auto, id_etiqueta, id_factura,
    id_estatus, id_usuario, id_tarjeta
)
VALUES 
('2025-05-27', '19:00', 19.4326, 19.3900, -99.1332, -99.1500, '2025-05-27', '20:15', 15, 
 'E', 'SI', 'Viaje Programado', 100.50, 12, 1, NULL, 2, 2, 1)

ROLLBACK TRAN

-- VALIDACION (Tigger que valida que un cliente tenga maximo 3 tarjetas)

SELECT * FROM CLIENTE.TARJETA -- El cliente 8 ya tiene las 3 tarjetas

BEGIN TRAN

INSERT INTO CLIENTE.TARJETA (numero_tarjeta, vigencia, id_usuario, id_banco) VALUES
('4532123412345690', '2027-12-31', 8 ,1)

ROLLBACK TRAN

-- VALIDACION (Trigger que valida que un conductor tenga maximo 2 autos)

SELECT * FROM CONDUCTOR.[AUTO] -- El conductor 11 ya tiene los 2 autos

BEGIN TRAN

INSERT INTO CONDUCTOR.[AUTO] (año, placa, color, id_modelo, id_usuario) VALUES
(2023, 'ABC12X4Z', 'Verde', 5, 11)

ROLLBACK TRAN

-- VALIDACION (Trigger que valida que los conductores se inserten en conductores y no en cliente)

SELECT * FROM USUARIO.USUARIO

INSERT INTO USUARIO.USUARIO VALUES 
('yordiblue', 'yordi.josueja@gmail.com', 'Cl4v3SegUr4#A1B2C3D8', '2025-05-25', 'Yordi', 'Jimenez', 'Ayala', 1, 0, NULL) -- Insert de prueba, id 36 (VERIFICAR EL ID POR EL IDENTITY)

BEGIN TRAN

INSERT INTO USUARIO.CONDUCTOR (id_usuario, num_licencia, vigencia_lic, foto, descripcion)
SELECT
    36,
    10000036,
    '2028-10-31',
    BulkColumn,
    'Soy Yordi, no soy conductor pero quiero violar el sistema y registrarme como conductor'
FROM
OPENROWSET(
    BULK '1.jpg',
    DATA_SOURCE = 'ConductoresSrc',
    SINGLE_BLOB
) AS img;

ROLLBACK TRAN

DELETE FROM USUARIO.USUARIO -- Borramos el insert de prueba
WHERE id_usuario = 36; -- CAMBIAR POR EL ID GENERADO

-- VALIDACION (Trigger que valida que los clientes se inserten en clientes y no en conductores)

SELECT * FROM USUARIO.USUARIO

INSERT INTO USUARIO.USUARIO VALUES 
('yordiblue', 'yordi.josueja@gmail.com', 'Cl4v3SegUr4#A1B2C3D8', '2025-05-25', 'Yordi', 'Jimenez', 'Ayala', 0, 1, NULL) -- Insert de prueba, id 37 (VERIFICAR EL QUE GENERA POR EL IDENTITY)

BEGIN TRAN

INSERT INTO USUARIO.CLIENTE (id_usuario, rfc, direccion, numero, fecha_registro, calificacion) VALUES
(37, 'JIAY040101AB3', 'Copal 155C, Pedregal de Santo DOmingo, CDMX', 5611655306, '2025-05-25', 5)

ROLLBACK TRAN

DELETE FROM USUARIO.USUARIO -- Borramos el insert de prueba
WHERE id_usuario = 37; -- CAMBIAR POR EL ID GENERADO

-- VALIDACION (Trigger que valida que si un valor bit es 0 o 1 en usuario el otro debe ser el contrario)

BEGIN TRAN

INSERT INTO USUARIO.USUARIO VALUES 
('yordiblue', 'yordi.josueja@gmail.com', 'Cl4v3SegUr4#A1B2C3D8', '2025-05-25', 'Yordi', 'Jimenez', 'Ayala', 0, 0, NULL)

ROLLBACK TRAN

BEGIN TRAN

INSERT INTO USUARIO.USUARIO VALUES 
('yordiblue', 'yordi.josueja@gmail.com', 'Cl4v3SegUr4#A1B2C3D8', '2025-05-25', 'Yordi', 'Jimenez', 'Ayala', 1, 1, NULL)

ROLLBACK TRAN

-- VALIDACION (Trigger que valida que si se pone null en calificacion del cliente no se inserte el dato)

SELECT * FROM USUARIO.USUARIO

INSERT INTO USUARIO.USUARIO VALUES 
('yordiblue', 'yordi.josueja@gmail.com', 'Cl4v3SegUr4#A1B2C3D8', '2025-05-25', 'Yordi', 'Jimenez', 'Ayala', 1, 0, NULL) -- Insert de prueba, id 54 (VERIFICAR EL QUE GENERA POR EL IDENTITY)

BEGIN TRAN

INSERT INTO USUARIO.CLIENTE (id_usuario, rfc, direccion, numero, fecha_registro, calificacion) VALUES
(54, 'JIAY040101AB3', 'Copal 155C, Pedregal de Santo DOmingo, CDMX', 5611655306, '2025-05-25', NULL)

ROLLBACK TRAN

DELETE FROM USUARIO.USUARIO -- Borramos el insert de prueba
WHERE id_usuario = 54; -- CAMBIAR POR EL ID GENERADO

-- VALIDACION (Trigger que valida que la fecha de atencion no sea mayor a 5 días)

BEGIN TRAN

INSERT INTO CLIENTE.QUEJA (descripcion, titulo, fecha_atencion, fecha_queja, id_usuario, id_administrador, id_conductor, id_auto) VALUES
('Queja de prueba', 'Queja', '2025-05-27', '2025-05-21', 2, 1, 5, 4)

ROLLBACK TRAN

-- VALIDACION (Trigger que no inserta si se pone null en la fecha queja)

BEGIN TRAN

INSERT INTO CLIENTE.QUEJA (descripcion, titulo, fecha_atencion, fecha_queja, id_usuario, id_administrador) VALUES
('Queja de prueba', 'Queja', '2025-05-27', NULL, 2, 1)

ROLLBACK TRAN

-- VALIDACION (Trigger que valida que la tarjeta pertenezca al usuario en el viaje)

BEGIN TRAN

INSERT INTO VIAJE.VIAJE (
    fecha_solicitud, hora_solicitud, latitud_origen, latitud_destino,
    longitud_origen, longitud_destino, fecha_inicio, hora_inicio, propina,
    tipo, programado, comentario, importe, id_auto, id_etiqueta, id_factura,
    id_estatus, id_usuario, id_tarjeta
)
VALUES 
('2025-05-27', '19:00', 19.4326, 19.3900, -99.1332, -99.1500, '2025-05-28', '20:15', 15, 
 'T', 'SI', 'Viaje Programado', 100.50, 12, 1, NULL, 2, 2, 15)

ROLLBACK TRAN

-- VALIDACION (Trigger que valida que el auto y el conductor en la queja coincidan)

BEGIN TRAN

INSERT INTO CLIENTE.QUEJA (descripcion, titulo, fecha_atencion, fecha_queja, id_usuario, id_administrador, id_conductor, id_auto) VALUES
('Queja de prueba', 'Queja', '2025-05-22', '2025-05-21', 2, 1, 5, 10)

ROLLBACK TRAN

-------------------------------------------------------------- CONSTRAINTS --------------------------------------------------------------

-- USUARIO 
	SELECT * FROM USUARIO.USUARIO
	-- 1. Validar clave candidata como Unique (nombre_usuario) 

	BEGIN TRAN
	-- Insertamos nombre_usuario 'psan_21', no se inserta ya que este nombre de usuario ya existe
		INSERT INTO USUARIO.USUARIO (nombre_usuario, correo, clave, fecha_ingreso, nombre, ap_paterno, ap_materno, cliente, conductor, id_recomendado)
		VALUES ('psan_21', 'juan@example.com', 'P4sswordSeguro*ABC1', '2021/12/18', 'Juan','Pérez', 'López', 1, 0, NULL);
	ROLLBACK TRAN

	-- 2. Validar que clave tenga una longitud de 20 caracteres, que incluya por lo menos una mayúscula, un número y un carácter (#,* o $)  en cualquier posición 

	-- No cumple con longitud
	BEGIN TRAN
		INSERT INTO USUARIO.USUARIO (nombre_usuario, correo, clave, fecha_ingreso, nombre, ap_paterno, ap_materno, cliente, conductor, id_recomendado)
			VALUES ('juan123', 'juan@example.com', 'ClaveSegura2024#', '2023/12/18', 'Juan','Pérez', 'López', 1, 0, NULL);
	ROLLBACK TRAN

	-- No contiene un caracter
	BEGIN TRAN
		INSERT INTO USUARIO.USUARIO (nombre_usuario, correo, clave, fecha_ingreso, nombre, ap_paterno, ap_materno, cliente, conductor, id_recomendado)
			VALUES ('juan123', 'juan@example.com', 'P4sswordelpguroBABC1', '2021/12/18', 'Juan','Pérez', 'López', 1, 0, NULL);
	ROLLBACK TRAN

	-- No contiene un numero
	BEGIN TRAN
		INSERT INTO USUARIO.USUARIO (nombre_usuario, correo, clave, fecha_ingreso, nombre, ap_paterno, ap_materno, cliente, conductor, id_recomendado)
			VALUES ('juan123', 'juan@example.com', 'Pesswor$elpguroBABCu', '2021/12/18', 'Juan','Pérez', 'López', 1, 0, NULL);
	ROLLBACK TRAN

	-- 3. Validar que id_recomendado sea una fk 
	BEGIN TRAN
		INSERT INTO USUARIO.USUARIO (nombre_usuario, correo, clave, fecha_ingreso, nombre, ap_paterno, ap_materno, cliente, conductor, id_recomendado)
			VALUES ('pancho123', 'pancho@example.com', 'ClaveSegura2024#$%10', '2021/12/18', 'Pancho','Pineda', 'Portilla', 0, 1, 40);
	ROLLBACK TRAN

	-- 4. Validar que correo tenga como default SIN CORREO 
	
	BEGIN TRAN
		INSERT INTO USUARIO.USUARIO (nombre_usuario, correo, clave, fecha_ingreso, nombre, ap_paterno, ap_materno, cliente, conductor, id_recomendado)
				VALUES ('el123', default, 'P4sswordelpguro*ABC1', '2021/12/18', 'Elsa','Pérez', 'López', 1, 0, NULL);
		SELECT * FROM USUARIO.USUARIO
	ROLLBACK TRAN



--CONDUCTOR
	SELECT * FROM USUARIO.CONDUCTOR
	--1. Validar que id_usuario si sea una pk 
		BEGIN TRAN
			INSERT INTO USUARIO.CONDUCTOR (id_usuario, num_licencia, vigencia_lic, foto, descripcion)
			SELECT 	1,10000001,'2028-12-31',BulkColumn,'Soy Carlos, tengo 35 años y cuento con más de 10 años de experiencia al volante en rutas urbanas y de larga distancia. Me caracterizo por un manejo defensivo, puntualidad y excelente trato al cliente. Poseo licencias vigentes y un historial impecable de seguridad vial. Siempre estoy comprometido con la eficiencia, el cuidado de la carga y el cumplimiento de horarios.'
			FROM OPENROWSET(BULK '3.jpg',DATA_SOURCE = 'ConductoresSrc', SINGLE_BLOB) AS img;
			SELECT * FROM USUARIO.CONDUCTOR
		ROLLBACK TRAN

	--2. Validar que id_usuario sea una fk (fkUsuarioConductor), 
		BEGIN TRAN
			INSERT INTO USUARIO.CONDUCTOR (id_usuario, num_licencia, vigencia_lic, foto, descripcion)
			SELECT 	261,10000010,'2028-12-31',BulkColumn,'Soy Carlos, tengo 35 años y cuento con más de 10 años de experiencia al volante en rutas urbanas y de larga distancia. Me caracterizo por un manejo defensivo, puntualidad y excelente trato al cliente. Poseo licencias vigentes y un historial impecable de seguridad vial. Siempre estoy comprometido con la eficiencia, el cuidado de la carga y el cumplimiento de horarios.'
			FROM OPENROWSET(BULK '3.jpg',DATA_SOURCE = 'ConductoresSrc', SINGLE_BLOB) AS img;
			SELECT * FROM USUARIO.CONDUCTOR
		ROLLBACK TRAN

	--3. Validar que clave candidata num_licencia sea UNIQUE
		BEGIN TRAN
		UPDATE USUARIO.CONDUCTOR
			SET num_licencia=10000001
			WHERE id_usuario=3;
			SELECT * FROM USUARIO.CONDUCTOR
		ROLLBACK TRAN

	--4. Validar que descripción tenga una longitud de max 600 caracteres 
		BEGIN TRAN
		UPDATE USUARIO.CONDUCTOR
			SET descripcion='Vivo en un surrealismo puro de algun comic total,
		Sin argumento y sin final

		Donde a la orilla de la luna he encontrado mi hogar,
		Y ya no puedo regresar.
		A los 15 la vida es un sueño fugaz,
		Siempre en una corniza sin poder parar.

		No soy Alicia y nunca fui Peter Pan,
		No estoy perdida y no lo paso tan mal.
		MI corazon no es Wonderland.
		No soy Alicia y nunca fui Peter Pan,
		Este es mi mundo y no lo quiero cambiar.
		MI corazon no es Wonderland.

		En este juego tan intenso el es amor fugaz,
		Y un beso siempre es opcional.
		Por eso voy sin equipaje haci el nunca jamas,
		Sin importarme el que diran.
		A los 15 la vida es un sueño fugaz,
		Siempre en una corniza sin poder parar.

		Aunque de vez en cuando caigo,
		Siempre me puedo reinventar.

		MI Corazon no es Wonderland.

		MI Corazon no es Wonderland.

		No soy Alicia y nunca fui Peter Pan,
		No estoy perdida y no paso tan mal.
		MI Corazon no es Wonderland.'
			WHERE id_usuario=3;
			SELECT * FROM USUARIO.CONDUCTOR
		ROLLBACK TRAN




--CLIENTE
	SELECT * FROM USUARIO.CLIENTE
	--1. Validar que id_usuario sea una pk
		BEGIN TRAN
			INSERT INTO USUARIO.CLIENTE (id_usuario, direccion, numero, fecha_registro, calificacion, rfc)
			VALUES 	(2,'Xola 714,Del Valle, CDMX',5576983411, '2024-08-08', 2,'MLOA111519BD2')
			SELECT * FROM USUARIO.CLIENTE
		ROLLBACK TRAN

	--2. Validar que id_usuario sea una fk (fkUsuarioCliente), 
		BEGIN TRAN
			INSERT INTO USUARIO.CLIENTE (id_usuario, direccion, numero, fecha_registro, calificacion, rfc)
			VALUES 	(37,'Xola 714,Del Valle, CDMX',5576983411, '2024-08-08', 2,'MLOA111519BD2')
			SELECT * FROM USUARIO.CLIENTE
		ROLLBACK TRAN

	--3. Validar que calificación sea un valor en (1, 2, 3, 4, 5)
		BEGIN TRAN
		UPDATE USUARIO.CLIENTE
			SET calificacion=8
			WHERE id_usuario=35;
			SELECT * FROM USUARIO.CLIENTE
		ROLLBACK TRAN

	--4. Validar que la longitud de rfc sea de 13 caracteres
		BEGIN TRAN
		UPDATE USUARIO.CLIENTE
			SET rfc= 'MLOA111519BD222'
			WHERE id_usuario=35;
			SELECT * FROM USUARIO.CLIENTE
		ROLLBACK TRAN

	-- 5. Validar ak (indice) del rfc
		BEGIN TRAN
			UPDATE USUARIO.CLIENTE
			SET rfc = 'GARC990708GH9'
			WHERE rfc = 'JUAC850101AB3';
			SELECT * FROM USUARIO.CLIENTE
		ROLLBACK TRAN

	--6. Validar que calificacion tenga como default (5)   (VALIDADO EN INSERT)



--PAGO
	SELECT * FROM CONDUCTOR.PAGO
	--1. Validar que id_usuario y folio sean la pk compuesta, y que vayan en orden ascendente ambas
		BEGIN TRAN
			INSERT INTO CONDUCTOR.PAGO (id_usuario, folio, fecha, monto)
			VALUES 	(1,16273859,'2024-01-22',1590.00)
			SELECT * FROM CONDUCTOR.PAGO
		ROLLBACK TRAN

	--2. Validar que id_usuario es una fk (fkIdUsuarioPago2), agregando ON DELETE CASCADE
		BEGIN TRAN
		UPDATE CONDUCTOR.PAGO
			SET id_usuario=261
			WHERE folio=16273859;
			SELECT * FROM CONDUCTOR.PAGO
		ROLLBACK TRAN

	--3. Validar que folio inicie con 1
		BEGIN TRAN
		UPDATE CONDUCTOR.PAGO
			SET folio=96273859
			WHERE id_usuario=1;
			SELECT * FROM CONDUCTOR.PAGO
		ROLLBACK TRAN



--TIPO
	SELECT * FROM DESCUENTO.TIPO
	--1.Validar que al insertar un nombre que ya está marque el error
		BEGIN TRAN
		UPDATE DESCUENTO.TIPO
			SET nombre='Descuento por cancelación anterior'
			WHERE id_tipo=13;
			SELECT * FROM DESCUENTO.TIPO
		ROLLBACK TRAN



 --DESCUENTO
	 SELECT * FROM DESCUENTO.DESCUENTO
	--1. Validar que id_usuario sea fk (fkIdUsuario)
		BEGIN TRAN
		UPDATE DESCUENTO.DESCUENTO
			SET id_usuario = 54
			WHERE id_descuento = 61;
			SELECT * FROM DESCUENTO.DESCUENTO
		ROLLBACK TRAN

	--2. Validar que id_tipo sea fk (fkIdTipo)
		BEGIN TRAN
		UPDATE DESCUENTO.DESCUENTO
			SET id_tipo = 78
			WHERE id_descuento = 61;
			SELECT * FROM DESCUENTO.DESCUENTO
		ROLLBACK TRAN

--MARCA
	SELECT * FROM CONDUCTOR.MARCA
	--1. Validar que en el catalogo no se repita nombre 
		BEGIN TRAN
			UPDATE CONDUCTOR.MARCA
			SET nombre = 'Acura'
			WHERE id_marca = 27;
			SELECT * FROM CONDUCTOR.MARCA
		ROLLBACK TRAN

--MODELO
	SELECT * FROM CONDUCTOR.MODELO
	--1. Validar que id_marca sea fk (fkMarcaModelo)
		BEGIN TRAN
		UPDATE CONDUCTOR.MODELO
			SET id_marca= 261
			WHERE id_modelo = 1;
			SELECT * FROM CONDUCTOR.MODELO
		ROLLBACK TRAN

	--2. Validar que clave candidata nombre sea UNIQUE
		BEGIN TRAN
			UPDATE CONDUCTOR.MODELO
			SET nombre = 'Camry'
			WHERE id_modelo = 1;
			SELECT * FROM CONDUCTOR.MODELO
		ROLLBACK TRAN

--AUTO
	SELECT * FROM  CONDUCTOR.[AUTO]
	--1. Validar que la diferencia entre el año actual y el valor de la columna año sea de 5 años o menos
		BEGIN TRAN
			UPDATE CONDUCTOR.[AUTO]
			SET año = 2019
			WHERE id_auto = 20;
			SELECT * FROM CONDUCTOR.[AUTO]
		ROLLBACK TRAN

	--2. Validar que id_modelo es fk (fkIdModelo)
		BEGIN TRAN
			UPDATE CONDUCTOR.[AUTO]
			SET id_modelo = 261
			WHERE id_auto = 2;
			SELECT * FROM CONDUCTOR.[AUTO]
		ROLLBACK TRAN

	--3. Validar que id_usuario es fk (fkIdUsuarioAuto)
		BEGIN TRAN
			UPDATE CONDUCTOR.[AUTO]
			SET id_usuario = 261
			WHERE id_auto = 2;
			SELECT * FROM CONDUCTOR.[AUTO]
		ROLLBACK TRAN

--ADMINISTRADOR
	SELECT * FROM USUARIO.ADMINISTRADOR
	--1. Validar que id_recomendado es fk (fkAdministradorRecomendado)
		BEGIN TRAN
			UPDATE USUARIO.ADMINISTRADOR
			SET id_recomendado = 261
			WHERE id_administrador = 2;
			SELECT * FROM USUARIO.ADMINISTRADOR
		ROLLBACK TRAN

	--2. Validar que clave candidata nombre_usuario es UNIQUE
		BEGIN TRAN
			UPDATE USUARIO.ADMINISTRADOR
			SET nombre_usuario = 'admin01'
			WHERE id_administrador = 2;
			SELECT * FROM USUARIO.ADMINISTRADOR
		ROLLBACK TRAN

	--3. Validar que clave tenga longitud de 20 caracteres, y contenga al menos una letra mayúscula, un número, y un carácter (#, * o $)

		BEGIN TRAN
			UPDATE USUARIO.ADMINISTRADOR
			SET clave = 'Clave#A1B2C3D4E5F6G77'
			WHERE id_administrador = 2;
			SELECT * FROM USUARIO.ADMINISTRADOR
		ROLLBACK TRAN

		BEGIN TRAN
			UPDATE USUARIO.ADMINISTRADOR
			SET clave = 'ClaveAA1B2C3D4E5F6G7'
			WHERE id_administrador = 2;
			SELECT * FROM USUARIO.ADMINISTRADOR
		ROLLBACK TRAN

--QUEJA
	SELECT * FROM CLIENTE.QUEJA
	--1. Validar que id_usuario es fk (fkIdUsuarioQueja),  
		BEGIN TRAN
			UPDATE CLIENTE.QUEJA
			SET id_usuario = 261
			WHERE id_queja = 2;
			SELECT * FROM CLIENTE.QUEJA
		ROLLBACK TRAN

	--2. Validar que id_administrador es fk (fkIdAdministradorQueja),  
		BEGIN TRAN
			UPDATE CLIENTE.QUEJA
			SET id_administrador = 261
			WHERE id_queja = 2;
			SELECT * FROM CLIENTE.QUEJA
		ROLLBACK TRAN

	--3. Validar que fecha_queja tenga como default la fecha actual en el servidor (VALIDADO EN INSERT)

--BANCO
	SELECT * FROM CLIENTE.BANCO
	--1. Validar que en el catalogo no se repita nombre 
		BEGIN TRAN
			UPDATE CLIENTE.BANCO
			SET nombre = 'Inbursa'
			WHERE id_banco = 2;
			SELECT * FROM CLIENTE.BANCO
		ROLLBACK TRAN

--TARJETA
	SELECT * FROM CLIENTE.TARJETA
	--1. Validar que numero_Tarjeta tiene longitud de 16 caracteres
		BEGIN TRAN
			UPDATE CLIENTE.TARJETA
			SET numero_Tarjeta = 453212341234567811
			WHERE id_tarjeta = 1;
			SELECT * FROM CLIENTE.TARJETA
		ROLLBACK TRAN

	--2. Validar que id_banco es fk (fkBancoTarjeta), 
		BEGIN TRAN
			UPDATE CLIENTE.TARJETA
			SET id_banco = 261
			WHERE id_tarjeta = 1;
			SELECT * FROM CLIENTE.TARJETA
		ROLLBACK TRAN

	--3. Validar que id_usuario es fk (fkClienteTarjeta),  
		BEGIN TRAN
			UPDATE CLIENTE.TARJETA
			SET id_usuario = 261
			WHERE id_tarjeta = 1;
			SELECT * FROM CLIENTE.TARJETA
		ROLLBACK TRAN

	-- 4. Validar ak del número de tarjeta
		BEGIN TRAN
			UPDATE CLIENTE.TARJETA
			SET numero_tarjeta = '5244334455667788'
			WHERE numero_tarjeta = '4532015112830366';
			SELECT * FROM CLIENTE.TARJETA
		ROLLBACK TRAN

--DESCUENTO_ADMIN
	SELECT * FROM DESCUENTO.DESCUENTO_ADMIN
	--1. Validar que id_tipo es fk (fkTipoDescuentoAdmin),  
		BEGIN TRAN
			UPDATE DESCUENTO.DESCUENTO_ADMIN
			SET id_tipo = 261
			WHERE id_descuento = 1;
			SELECT * FROM DESCUENTO.DESCUENTO_ADMIN
		ROLLBACK TRAN

	--2. Validar que id_administrador es fk (fkAdministradorDescuentoAdmin),  
		BEGIN TRAN
			UPDATE DESCUENTO.DESCUENTO_ADMIN
			SET id_administrador = 261
			WHERE id_descuento = 1;
			SELECT * FROM DESCUENTO.DESCUENTO_ADMIN
		ROLLBACK TRAN

--TELEFONO
	SELECT * FROM DBO.TELEFONO
	--1. Validar que id_administrador y numero son pk compuesta, y que van en orden ascendente
		BEGIN TRAN
			INSERT INTO DBO.TELEFONO (id_administrador, numero)
			VALUES 	(1,5512345678)
			SELECT * FROM DBO.TELEFONO
		ROLLBACK TRAN

	--2. Validar que id_administrador es fk (fkAdministradorTelefono), 
		BEGIN TRAN
			UPDATE DBO.TELEFONO
			SET id_administrador = 261
			WHERE numero = 5512345678;
			SELECT * FROM DBO.TELEFONO
		ROLLBACK TRAN

	--3. Validar que numero tiene longitud de 10 
		BEGIN TRAN
			UPDATE DBO.TELEFONO
			SET numero= 551234567812
			WHERE id_administrador = 1;
			SELECT * FROM DBO.TELEFONO
		ROLLBACK TRAN

--ETIQUETA
	SELECT * FROM VIAJE.ETIQUETA
	--1. Validar que en el catalogo no se repita nombre 
		BEGIN TRAN
			UPDATE VIAJE.ETIQUETA
			SET nombre= 'Conducción segura'
			WHERE id_etiqueta = 4;
			SELECT * FROM VIAJE.ETIQUETA
		ROLLBACK TRAN


--FACTURA
	-- No hay constraint que validar  

--ESTATUS
	SELECT * FROM VIAJE.ESTATUS
	--1. Validar que solo se pueda insertar en nombre: Solicitado, Programado, Confirmado, En curso, Terminado, Por cobrar, Pagado, Con adeudo o Cancelado
		BEGIN TRAN
			UPDATE VIAJE.ESTATUS
			SET nombre= 'Palabra'
			WHERE id_estatus = 5;
			SELECT * FROM VIAJE.ESTATUS
		ROLLBACK TRAN

	--2. Validar que no se repitan los nombres con el UNIQUE
		BEGIN TRAN
			UPDATE VIAJE.ESTATUS
			SET nombre= 'Confirmado'
			WHERE id_estatus = 5;
			SELECT * FROM VIAJE.ESTATUS
		ROLLBACK TRAN



--VIAJE ESTATUS
	SELECT * FROM VIAJE.VIAJE_ESTATUS
	--1. Validar que id_estatus y id_viaje sean pk compuesta y que vayan en orden ascendente
		BEGIN TRAN
			INSERT INTO VIAJE.VIAJE_ESTATUS (id_estatus,id_viaje, fecha_estatus, hora_estatus)
			VALUES 	(1,1,'2025-05-01','09:45:00.0000000')
			SELECT * FROM VIAJE.VIAJE_ESTATUS
		ROLLBACK TRAN

--VIAJE
	SELECT * FROM VIAJE.VIAJE
	--1. Validar que id_auto sea fk (fkAutoViaje),  agregando ON DELETE CASCADE y ON UPDATE CASCADE
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET id_auto = 261
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--2. Validar que id_etiqueta sea fk (fkEtiquetaViaje),  agregando ON DELETE CASCADE y ON UPDATE CASCADE
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET id_etiqueta = 261
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--3. Validar que id_factura sea fk (fkFacturaViaje),  agregando ON DELETE CASCADE y ON UPDATE CASCADE
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET id_factura = 261
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--4. Validar que id_estatus sea fk (fkEstatusViaje),  agregando ON DELETE CASCADE y ON UPDATE CASCADE
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET id_estatus = 222
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--5. Validar que id_usuario sea fk
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET id_usuario = 261
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--6. Validar que id_tarjeta sea fk
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET id_tarjeta = 261
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--7. Validar que calificacion sea un valor de 1, 2, 3, 4 o 5
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET calificacion = 6
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--8. Validar que propina sea un valor de 10, 15 o 20
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET propina = 11
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--9. Validar que tipo sea un caracter T o E
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET tipo = 'A'
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--10. Validar que programado sea SI o NO
		BEGIN TRAN
			UPDATE VIAJE.VIAJE
			SET programado = 'AA'
			WHERE id_viaje = 1;
			SELECT * FROM VIAJE.VIAJE
		ROLLBACK TRAN

	--11. Validar que calificacion tenga como default el valor de 5 (SE HIZO EN INSERT)




--UBICACION
	SELECT * FROM VIAJE.UBICACION
	--1. Validar que id_viaje sea fk (fkViajeUbicacion),  agregando ON DELETE CASCADE 
		BEGIN TRAN
			UPDATE VIAJE.UBICACION
			SET id_viaje = 261
			WHERE id_ubicacion = 1;
			SELECT * FROM VIAJE.UBICACION
		ROLLBACK TRAN

--TIPO ACCIDENTE
	SELECT * FROM VIAJE.TIPO_ACCIDENTE
	--1. Validar que clave candidata nombre sea UNIQUE
	BEGIN TRAN
		UPDATE VIAJE.TIPO_ACCIDENTE
		SET nombre = 'Accidente mecánico'
		WHERE id_tipo = 1;
		SELECT * FROM VIAJE.TIPO_ACCIDENTE
	ROLLBACK TRAN

--ACCIDENTE
	SELECT *FROM VIAJE.ACCIDENTE
	--1. Validar que id_tipo sea fk (fkTipoAccidente)
		BEGIN TRAN
			UPDATE VIAJE.ACCIDENTE
			SET id_tipo = 261
			WHERE id_accidente = 1;
			SELECT * FROM VIAJE.ACCIDENTE
		ROLLBACK TRAN

	--2. Validar que id_viaje sea fk (fkViajeAccidente),  agregando ON DELETE CASCADE y ON UPDATE CASCADE
		BEGIN TRAN
			UPDATE VIAJE.ACCIDENTE
			SET id_viaje = 261
			WHERE id_accidente = 1;
			SELECT * FROM VIAJE.ACCIDENTE
		ROLLBACK TRAN


		BEGIN TRAN -- Validando el delete on cascade
			DELETE FROM VIAJE.VIAJE
			WHERE id_viaje = 1
			SELECT * FROM VIAJE.ACCIDENTE
		ROLLBACK TRAN

	--3. Validar que herido sea SI o NO
		BEGIN TRAN
			UPDATE VIAJE.ACCIDENTE
			SET herido= 'AA'
			WHERE id_accidente = 1;
			SELECT * FROM VIAJE.ACCIDENTE
		ROLLBACK TRAN

	--3. Validar que culpable sea SI o NO
		BEGIN TRAN
			UPDATE VIAJE.ACCIDENTE
			SET culpable = 'AA'
			WHERE id_accidente = 1;
			SELECT * FROM VIAJE.ACCIDENTE
		ROLLBACK TRAN