/*

AUTORES:
	AYALA HERNÁNDEZ MARÍA FERNANDA
    PORTILLA HERMENEGILDO ELIZABETH
    VALENZUELA ASCENCIO GUSTAVO
    JIMENEZ AYALA YORDI JOSUE

FECHA DE CREACIÓN: 25 DE MAYO DE 2025

ULTIMA ACTUALIZACIÓN: 25 DE MAYO DE 2025 

DESCRIPCIÓN: SCRIPT DQL QUE CONTIENE LAS CONSULTAS REQUERIDAS PARA OBTENER INFORMES DE LA BASE

*/

USE [Equipo09AppSafe] -- Usamos la base de datos

-- A) Viajes diarios por conductor; datos del conductor, número de viajes, monto total. Este informe debe poder obtener por un periodo de tiempo

SELECT * FROM USUARIO.USUARIO
SELECT * FROM USUARIO.CONDUCTOR
SELECT * FROM VIAJE.VIAJE

SELECT 
    U.nombre_usuario, -- Nombre de usuario
    U.ap_paterno,     -- Nombre completo
    U.ap_materno,
    C.num_licencia,   -- Número de licencia
    CAST(V.fecha_inicio AS DATE) AS fecha_viaje,  -- Fecha diaria
    COUNT(*) AS num_viajes, -- Número de viajes
    SUM(V.importe + COALESCE(V.propina, 0)) AS monto_total  -- Suma con propinas
FROM 
    USUARIO.USUARIO U  -- Consultamos la tabla USUARIO
JOIN 
    USUARIO.CONDUCTOR C ON U.id_usuario = C.id_usuario  -- Unimos con su subclase
JOIN 
    CONDUCTOR.[AUTO] A ON C.id_usuario = A.id_usuario  --  Unimos con auto para obtener el ID del auto
JOIN 
    VIAJE.VIAJE V ON A.id_auto = V.id_auto  -- Obtenemos el auto del conductor asociado al viaje
WHERE 
    V.fecha_inicio BETWEEN '2025-05-01' AND '2025-05-31'  -- Periodo de consulta
GROUP BY 
    U.nombre_usuario,  -- Agrupamos por nombre y apellidos
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia,
    CAST(V.fecha_inicio AS DATE)  -- Agrupamos por día
ORDER BY 
    fecha_viaje, U.nombre_usuario;  -- Ordenamos resultados


-- B) Consolidado mensual; día, monto total diario, monto mensual acumulado

SELECT * FROM VIAJE.VIAJE

SELECT 
    CAST(fecha_inicio AS DATE) AS dia,  -- Fecha del día
    SUM(importe) AS monto_total_diario, -- Monto diario
    SUM(SUM(importe)) OVER (PARTITION BY YEAR(fecha_inicio), MONTH(fecha_inicio)) AS monto_mensual -- Usamos partition by para segmentar en meses
FROM 
    VIAJE.VIAJE 
WHERE 
    fecha_inicio BETWEEN '2025-05-01' AND '2025-05-31'  -- Filtro por un mes específico
GROUP BY 
    CAST(fecha_inicio AS DATE),  -- Agrupamos por día
    YEAR(fecha_inicio),  -- Necesario para la función de ventana
    MONTH(fecha_inicio)
ORDER BY 
    dia; -- Ordenamos con base en el día

-- C) Top 5 de conductores por un periodo de tiempo

SELECT TOP 5
    U.id_usuario,
    U.nombre_usuario,
    U.nombre,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia,
    FORMAT(AVG(CAST(V.calificacion AS DECIMAL(3,1))), 'N2') AS calificacion_promedio -- Cast a DECIMAL y redondeo a 2 decimales
FROM 
    USUARIO.USUARIO U
JOIN 
    USUARIO.CONDUCTOR C ON U.id_usuario = C.id_usuario
JOIN 
    CONDUCTOR.[AUTO] A ON C.id_usuario = A.id_usuario
JOIN 
    VIAJE.VIAJE V ON A.id_auto = V.id_auto  -- Unimos directamente con VIAJE
WHERE 
    V.fecha_solicitud BETWEEN '2025-05-01' AND '2025-05-31'  -- Filtro por periodo
GROUP BY 
    U.id_usuario,
    U.nombre_usuario,
    U.nombre,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia
ORDER BY 
    calificacion_promedio DESC; 

-- D) Top 5 de clientes, es decir, los clientes con mayor número de viajes (nombre completo y correo)

SELECT TOP 5
       U.nombre,
       U.ap_paterno,
       U.ap_materno,
       U.correo,
       COUNT(*) AS num_viajes
FROM USUARIO.USUARIO U
JOIN 
    VIAJE.VIAJE V ON U.id_usuario = V.id_usuario
GROUP BY U.nombre,U.ap_paterno,U.ap_materno,U.correo
ORDER BY num_viajes DESC

-- E) Listado de conductores con más quejas y motivo (se maneja un catálogo, ejemplo, irrespetuoso, maneja muy rápido, no respeta las reglas de vialidad, etc.)

SELECT * FROM CLIENTE.QUEJA
SELECT * FROM VIAJE.ETIQUETA

WITH QuejasConductor AS (
    SELECT 
        C.id_usuario,
        E.nombre AS motivo,
        COUNT(*) AS num_quejas,
        ROW_NUMBER() OVER (PARTITION BY C.id_usuario ORDER BY COUNT(*) DESC) AS ranking_motivo
    FROM 
        CLIENTE.QUEJA Q
    JOIN 
        VIAJE.VIAJE V ON Q.id_auto = V.id_auto
    JOIN 
        CONDUCTOR.[AUTO] A ON V.id_auto = A.id_auto
    JOIN 
        USUARIO.CONDUCTOR C ON A.id_usuario = C.id_usuario
    JOIN 
        VIAJE.ETIQUETA E ON V.id_etiqueta = E.id_etiqueta  -- Motivo desde la etiqueta del viaje
    GROUP BY 
        C.id_usuario, E.nombre
)

SELECT 
    U.id_usuario,
    U.nombre_usuario,
    U.nombre,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia,
    QC.num_quejas,
    QC.motivo AS motivo_principal
FROM 
    QuejasConductor QC
JOIN 
    USUARIO.USUARIO U ON QC.id_usuario = U.id_usuario
JOIN 
    USUARIO.CONDUCTOR C ON QC.id_usuario = C.id_usuario
WHERE 
    QC.ranking_motivo = 1  -- Filtra solo el motivo más frecuente por conductor
ORDER BY 
    QC.num_quejas DESC;

-- F) Listado de accidentes; fecha, ubicación, tipo, descripción, 
--heridos sí o no, monto gastado, nombre del conductor y auto, si el conductor fue el 
--responsable o no. Con filtros para poder obtener el listado desde un día 
--o un periodo de tiempo

SELECT * FROM VIAJE.ACCIDENTE
SELECT * FROM VIAJE.TIPO_ACCIDENTE

SELECT 
    A.fecha,
    A.ubicacion,
    T.nombre AS tipo_accidente,
    A.descripcion,
    A.herido AS heridos,  
    A.monto AS monto_gastado,
    U.nombre AS nombre_conductor,
    U.ap_paterno AS apellido_paterno,
    U.ap_materno AS apellido_materno,
    AU.placa AS placa_auto,
    A.culpable AS conductor_responsable 
FROM 
    VIAJE.ACCIDENTE A
JOIN 
    VIAJE.TIPO_ACCIDENTE T ON A.id_tipo = T.id_tipo
JOIN 
    VIAJE.VIAJE V ON A.id_viaje = V.id_viaje
JOIN 
    CONDUCTOR.[AUTO] AU ON V.id_auto = AU.id_auto
JOIN 
    USUARIO.CONDUCTOR C ON AU.id_usuario = C.id_usuario
JOIN 
    USUARIO.USUARIO U ON C.id_usuario = U.id_usuario
WHERE 
    A.fecha BETWEEN '2025-05-01' AND '2025-05-31'  -- Filtro por periodo
ORDER BY 
    A.fecha;

-- G) Listado de los clientes con menos estrellas

SELECT 
    U.id_usuario,
    U.nombre_usuario,
    U.nombre,
    U.ap_paterno,
    U.ap_materno,
    U.correo,
    C.calificacion
FROM USUARIO.USUARIO U
JOIN
     USUARIO.CLIENTE C ON U.id_usuario = C.id_usuario
WHERE C.calificacion <= 3
ORDER BY C.calificacion

-- H) Listado de conductores con el total que les han dado por cada estrella

SELECT 
    U.id_usuario,
    U.nombre_usuario,
    U.nombre,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia,
    COUNT(*) AS total_viajes,
    SUM(CASE WHEN V.calificacion = 1 THEN 1 ELSE 0 END) AS una_estrella,
    SUM(CASE WHEN V.calificacion = 2 THEN 1 ELSE 0 END) AS dos_estrellas,
    SUM(CASE WHEN V.calificacion = 3 THEN 1 ELSE 0 END) AS tres_estrellas,
    SUM(CASE WHEN V.calificacion = 4 THEN 1 ELSE 0 END) AS cuatro_estrellas,
    SUM(CASE WHEN V.calificacion = 5 THEN 1 ELSE 0 END) AS cinco_estrellas
FROM 
    USUARIO.USUARIO U
JOIN 
    USUARIO.CONDUCTOR C ON U.id_usuario = C.id_usuario
JOIN 
    CONDUCTOR.[AUTO] A ON C.id_usuario = A.id_usuario
JOIN 
    VIAJE.VIAJE V ON A.id_auto = V.id_auto
GROUP BY 
    U.id_usuario, U.nombre_usuario, U.nombre, U.ap_paterno, U.ap_materno, C.num_licencia
ORDER BY 
    U.id_usuario;

-- I) Listado de autos, placa, numero de serie, marca, modelo, año, color y su dueño

SELECT * FROM CONDUCTOR.[AUTO]

SELECT 
    AU.id_auto,
    AU.placa,
    MA.nombre,
    MO.nombre,
    AU.año,
    AU.color,
    U.nombre_usuario as usuario_dueño,
    U.nombre as nombre_dueño,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia
FROM CONDUCTOR.AUTO AU
JOIN
    CONDUCTOR.MODELO MO ON AU.id_modelo = MO.id_modelo
JOIN
    CONDUCTOR.MARCA MA ON MO.id_marca = MA.id_marca
JOIN
    USUARIO.CONDUCTOR C ON C.id_usuario = AU.id_usuario
JOIN
    USUARIO.USUARIO U ON C.id_usuario = U.id_usuario

-- J) Listado de quejas incluyendo el conductor y auto, con filtro para obtenerse
-- por un periodo de tiempo o por conductor

SELECT * FROM CLIENTE.QUEJA

-- Por periodo de tiempo

SELECT 
    Q.id_queja,
    Q.titulo,
    Q.descripcion,
    Q.fecha_queja,
    Q.fecha_atencion,
    Q.dias_respuesta,
    U.nombre_usuario as usuario_conductor,
    U.nombre as nombre_conductor,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia,
    AU.id_auto,
    AU.placa,
    AU.color
FROM CLIENTE.QUEJA Q
JOIN
    USUARIO.USUARIO U ON Q.id_conductor = U.id_usuario
JOIN
    USUARIO.CONDUCTOR C ON C.id_usuario = U.id_usuario
JOIN 
    CONDUCTOR.[AUTO] AU ON AU.id_usuario = C.id_usuario
WHERE 
    Q.fecha_queja BETWEEN '2025-05-01' AND '2025-05-31'

-- Por conductor

SELECT 
    Q.id_queja,
    Q.titulo,
    Q.descripcion,
    Q.fecha_queja,
    Q.fecha_atencion,
    Q.dias_respuesta,
    U.nombre_usuario as usuario_conductor,
    U.nombre as nombre_conductor,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia,
    AU.id_auto,
    AU.placa,
    AU.color
FROM CLIENTE.QUEJA Q
JOIN
    USUARIO.USUARIO U ON Q.id_conductor = U.id_usuario
JOIN
    USUARIO.CONDUCTOR C ON C.id_usuario = U.id_usuario
JOIN 
    CONDUCTOR.[AUTO] AU ON AU.id_usuario = C.id_usuario
WHERE 
    U.nombre_usuario = 'cperez_97'


/*

------ CONSULTAS -------

*/

-- Álgebra relacional: Obtener toda la información de los 
-- clientes que tengan una calificación de 5 y al menos un descuento
-- que vence antes de julio del 2025

SELECT * FROM DESCUENTO.DESCUENTO

SELECT * FROM USUARIO.USUARIO U
JOIN DESCUENTO.DESCUENTO D
ON U.id_usuario = D.id_usuario
JOIN USUARIO.CLIENTE C
ON C.id_usuario = U.id_usuario
WHERE D.vigencia < '2025-07-01'

INTERSECT

SELECT * FROM USUARIO.USUARIO U
JOIN DESCUENTO.DESCUENTO D
ON U.id_usuario = D.id_usuario
JOIN USUARIO.CLIENTE C
ON C.id_usuario = U.id_usuario
WHERE C.calificacion = 5


/*
        θ = id_usuario

		R1 <- (σ(D.vigencia < '2025-07-01')) (USUARIO ⨝θ CLIENTE ⨝θ DESCUENTO))

        θ = id_usuario

		R2 <- (σ(C.calificacion = 5)) (USUARIO ⨝θ CLIENTE ⨝θ DESCUENTO))

		R3 = R1 ∩ R2 (Resultado)                                                                                                 

*/

-- Obtener el nombre completo y número de licencia de los conductores cuyos pagos totales están arriba del promedio
-- Subconsulta + Funciones de agregación

SELECT AVG(total_pagos) as promedio_pagos  -- Promedio
        FROM (
            SELECT SUM(monto) AS total_pagos 
            FROM CONDUCTOR.PAGO 
            GROUP BY id_usuario
        ) AS promedios

SELECT 
    C.id_usuario,
    U.nombre,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia,
    SUM(P.monto) AS total_pagos
FROM 
    CONDUCTOR.PAGO P
JOIN 
    USUARIO.CONDUCTOR C ON P.id_usuario = C.id_usuario
JOIN 
    USUARIO.USUARIO U ON C.id_usuario = U.id_usuario
GROUP BY 
    C.id_usuario, U.nombre, U.ap_paterno, U.ap_materno, C.num_licencia
HAVING 
    SUM(P.monto) > (
        SELECT AVG(total_pagos) 
        FROM (
            SELECT SUM(monto) AS total_pagos 
            FROM CONDUCTOR.PAGO 
            GROUP BY id_usuario
        ) AS promedios
    );

-- Porcentaje de pagos con tarjeta vs pagos en efectivo

SELECT 
    FORMAT(
        (COUNT(CASE WHEN V.tipo = 'T' THEN 1 END) * 100.0 / COUNT(*)), 
        'N2'
    ) AS porcentaje_tarjeta,
    
    FORMAT(
        (COUNT(CASE WHEN V.tipo = 'E' THEN 1 END) * 100.0 / COUNT(*)), 
        'N2'
    ) AS porcentaje_efectivo
FROM 
    VIAJE.VIAJE V;

-- Diferencia entre el total pagado y el total facturado de los conductores (INNER JOIN)

SELECT * FROM CONDUCTOR.AUTO
SELECT * FROM VIAJE.FACTURA
SELECT * FROM CONDUCTOR.PAGO
SELECT * FROM USUARIO.CONDUCTOR

SELECT 
    C.id_usuario,
    U.nombre,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia,
    YEAR(F.fecha_factura) AS año_facturacion,
    MONTH(F.fecha_factura) AS mes_facturacion,
    SUM(F.importe) AS total_facturado, 
    SUM(P.monto) AS total_pagado,
    SUM(F.importe) - SUM(P.monto) AS diferencia
FROM 
    USUARIO.CONDUCTOR C
INNER JOIN 
    CONDUCTOR.AUTO A ON C.id_usuario = A.id_usuario  
INNER JOIN 
    VIAJE.VIAJE V ON A.id_auto = V.id_auto  
INNER JOIN 
    VIAJE.FACTURA F ON V.id_factura = F.id_factura  
INNER JOIN 
    CONDUCTOR.PAGO P ON C.id_usuario = P.id_usuario
    AND YEAR(F.fecha_factura) = YEAR(P.fecha)  
    AND MONTH(F.fecha_factura) = MONTH(P.fecha)

INNER JOIN 
    USUARIO.USUARIO U ON C.id_usuario = U.id_usuario
GROUP BY 
    C.id_usuario, 
    U.nombre,
    U.ap_paterno,
    U.ap_materno,
    C.num_licencia,
    YEAR(F.fecha_factura),  -- Agrupamos por año y mes
    MONTH(F.fecha_factura)
ORDER BY 
    año_facturacion DESC, 
    mes_facturacion DESC;


-- Muestra cada usuario y quién lo recomendó (SELF LEFT JOIN)


SELECT 
    U1.id_usuario AS id_usuario,
    U1.nombre AS nombre_usuario,
    U1.ap_paterno AS apellido_usuario,
    U1.correo AS correo_usuario,
    U2.id_usuario AS id_recomendador,
    U2.nombre AS nombre_recomendador,
    U2.ap_paterno AS apellido_recomendador,
    U2.correo AS correo_recomendador
FROM 
    USUARIO.USUARIO U1
LEFT JOIN 
    USUARIO.USUARIO U2 ON U1.id_recomendado = U2.id_usuario  -- Self Join
ORDER BY 
    U1.id_usuario;

-- Usuarios que nunca han recomendado a alguien (SELF LEFT JOIN)

SELECT 
    U.id_usuario,
    U.nombre,
    U.ap_paterno
FROM 
    USUARIO.USUARIO U
LEFT JOIN 
    USUARIO.USUARIO Recomendados ON U.id_usuario = Recomendados.id_recomendado
WHERE 
    Recomendados.id_recomendado IS NULL;

-- ¿Cuántos usuarios ha recomendado cada usuario? (Si es que ha recomendado)

SELECT 
    U2.id_usuario,
    U2.nombre_usuario,
    U2.nombre,
    U2.ap_paterno,
    U2.correo,
    COUNT(U1.id_usuario) AS total_recomendados
FROM 
    USUARIO.USUARIO U1
JOIN 
    USUARIO.USUARIO U2 ON U1.id_recomendado = U2.id_usuario  -- Self Join
GROUP BY 
    U2.id_usuario, U2.nombre_usuario, U2.nombre, U2.ap_paterno, U2.correo
ORDER BY 
    total_recomendados DESC;

