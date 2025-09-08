/*

AUTORES:
	AYALA HERNÁNDEZ MARÍA FERNANDA
    PORTILLA HERMENEGILDO ELIZABETH
    VALENZUELA ASCENCIO GUSTAVO
    JIMENEZ AYALA YORDI JOSUE

FECHA DE CREACION: 24 DE MAYO DE 2025

ULTIMA ACTUALIZACION: 25 DE MAYO DE 2025 

DESCRIPCION: DML QUE CONTIENE LA CREACION DE TRIGGERS

*/

-- SELECCIONAMOS NUESTRA BASE PARA TRABAJAR SOBRE ELLA

USE Equipo09AppSafe
GO


-- Trigger que valida en la tabla VIAJE que si un viaje es programado el inicio no pase de 2 dias

CREATE TRIGGER trgValidaFechaProgramado ON VIAJE.VIAJE
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE programado = 'SI'
          AND DATEADD(DAY, 2, CAST(fecha_solicitud AS DATETIME) + CAST(hora_solicitud AS DATETIME))
              < (CAST(fecha_inicio AS DATETIME) + CAST(hora_inicio AS DATETIME))
    )
    BEGIN
        RAISERROR('CUIDADO, LA FECHA DE INICIO EXCEDE LA FECHA LÍMITE PERMITIDA', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que si no es programado la fecha y hora inicio sea la misma que la de solicitud

CREATE TRIGGER trgValidaFechaNoProgramado ON VIAJE.VIAJE
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE programado = 'NO'
          AND (CAST(fecha_inicio AS DATETIME) + CAST(hora_inicio AS DATETIME))
              <> (CAST(fecha_solicitud AS DATETIME) + CAST(hora_solicitud AS DATETIME))
    )
    BEGIN
        RAISERROR('EL VIAJE NO ES PROGRAMADO, LA FECHA Y HORA DE INICIO NO PUEDEN SER DIFERENTES A LAS DE SOLICITUD', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que no se ponga un id de tarjeta si no se va a pagar con tarjeta (tipo = 'E')

CREATE TRIGGER trgValidaPagoEfectivo ON VIAJE.VIAJE
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE tipo = 'E' AND id_tarjeta IS NOT NULL
    )
    BEGIN
        RAISERROR('EL VIAJE SE VA A PAGAR CON EFECTIVO, NO SE PUEDE INSERTAR UNA TARJETA', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Tigger que validar que un cliente tenga maximo 3 tarjetas

CREATE TRIGGER trgMaxTarjetas ON CLIENTE.TARJETA
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        GROUP BY i.id_usuario
        HAVING (
            SELECT COUNT(*) 
            FROM CLIENTE.TARJETA t
            WHERE t.id_usuario = i.id_usuario
        ) > 3
    )
    BEGIN
        RAISERROR('NO SE PUEDEN INSERTAR MAS TARJETAS, LIMITE ALCANZADO', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que un conductor tenga maximo 2 autos

CREATE TRIGGER trgMaxAutos ON CONDUCTOR.[AUTO] 
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        GROUP BY i.id_usuario
        HAVING (
            SELECT COUNT(*)
            FROM CONDUCTOR.[AUTO] a
            WHERE a.id_usuario = i.id_usuario
        ) > 2
    )
    BEGIN
        RAISERROR('NO SE PUEDEN REGISTRAR MAS AUTOS, LIMITE ALCANZADO', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que los conductores se inserten en conductores y no en cliente

CREATE TRIGGER trgValidaConductor ON USUARIO.CONDUCTOR
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN USUARIO.USUARIO u ON i.id_usuario = u.id_usuario
        WHERE u.cliente = 1 AND u.conductor = 0
    )
    BEGIN
        RAISERROR('ERROR: EL USUARIO CORRESPONDE A LA CATEGORIA CLIENTE', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que los clientes se inserten en clientes y no en conductores

CREATE TRIGGER trgValidaCliente ON USUARIO.CLIENTE
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN USUARIO.USUARIO u ON i.id_usuario = u.id_usuario
        WHERE u.cliente = 0 AND u.conductor = 1
    )
    BEGIN
        RAISERROR('ERROR: EL USUARIO CORRESPONDE A LA CATEGORIA CONDUCTOR', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que si un valor bit es 0 o 1 en usuario el otro debe ser el contrario

CREATE TRIGGER trgClienteConductor ON USUARIO.USUARIO
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE (cliente = 1 AND conductor = 1)
           OR (cliente = 0 AND conductor = 0)
    )
    BEGIN
        RAISERROR('ERROR: EL ROL INGRESADO NO ES VALIDO', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que si se pone null en calificacion del cliente no se inserte el dato

CREATE TRIGGER trgCalNull ON USUARIO.CLIENTE
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE calificacion IS NULL
    )
    BEGIN
        RAISERROR('ERROR: LA CALIFICACION NO PUEDE SER NULL, DEJA EL VALOR DEFAULT', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que la fecha de atencion no sea mayor a 5 días

CREATE TRIGGER trgFechaAtencion ON CLIENTE.QUEJA
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DATEDIFF(DAY, fecha_queja, fecha_atencion) > 5
    )
    BEGIN
        RAISERROR('LA FECHA DE ATENCION NO PUEDE SER MAYOR A 5 DIAS', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que no inserta si se pone null en la fecha queja

CREATE TRIGGER trgFechaNull ON CLIENTE.QUEJA
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE fecha_queja IS NULL
    )
    BEGIN
        RAISERROR('ERROR: LA FECHA DE LA QUEJA NO DEBE SER NULA, DEJA EL DEFAULT', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que la tarjeta pertenezca al usuario en el viaje

CREATE TRIGGER trgPropietarioTarjeta ON VIAJE.VIAJE
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN CLIENTE.TARJETA t ON i.id_tarjeta = t.id_tarjeta
        WHERE i.id_tarjeta IS NOT NULL
          AND t.id_usuario <> i.id_usuario
    )
    BEGIN
        RAISERROR('EL PROPIETARIO DE LA TARJETA NO COINCIDE CON EL SELECCIONADO', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Trigger que valida que el auto y el conductor en la queja coincidan

CREATE TRIGGER trgAutoQueja ON CLIENTE.QUEJA
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        LEFT JOIN CONDUCTOR.AUTO a ON i.id_auto = a.id_auto
        WHERE a.id_usuario <> i.id_conductor
    )
    BEGIN
        RAISERROR('EL PROPIETARIO DEL AUTO NO COINCIDE CON EL CONDUCTOR SELECCIONADO', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


