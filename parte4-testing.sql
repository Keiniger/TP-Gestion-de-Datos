USE GD1C2020

-- Tablas a testear --
/*
	GRUPO2.Vuelo
    GRUPO2.Pasaje
	GRUPO2.Operacion_Pasaje
*/

-- Elimino los objetos creados anteriormente para evitar el error de que ya existen --
IF EXISTS (SELECT name FROM sysobjects WHERE name='MIGRAR_VUELOS')
	DROP PROCEDURE MIGRAR_VUELOS
IF EXISTS (SELECT name FROM sysobjects WHERE name='MIGRAR_PASAJES')
	DROP PROCEDURE MIGRAR_PASAJES
IF EXISTS (SELECT name FROM sysobjects WHERE name='MIGRAR_OPERACIONES_PASAJE')
	DROP PROCEDURE MIGRAR_OPERACIONES_PASAJE

-- Aca van las funciones --

-- Aca van los procedures --
GO
	CREATE PROCEDURE MIGRAR_VUELOS
	AS
	BEGIN
		INSERT INTO GRUPO2.Vuelo(vuelo_avion, vuelo_aerolinea, vuelo_codigo, vuelo_fecha_salida, vuelo_fecha_llegada, vuelo_ruta_codigo, vuelo_ruta_origen, vuelo_ruta_destino)
			SELECT AVION_IDENTIFICADOR, EMPRESA_RAZON_SOCIAL, VUELO_CODIGO, VUELO_FECHA_SALUDA, VUELO_FECHA_LLEGADA, RUTA_AEREA_CODIGO, dbo.CODIGO_CIUDAD(RUTA_AEREA_CIU_ORIG), dbo.CODIGO_CIUDAD(RUTA_AEREA_CIU_DEST) FROM gd_esquema.Maestra WHERE VUELO_CODIGO IS NOT NULL GROUP BY AVION_IDENTIFICADOR, EMPRESA_RAZON_SOCIAL, VUELO_CODIGO, VUELO_FECHA_SALUDA, VUELO_FECHA_LLEGADA, RUTA_AEREA_CODIGO, RUTA_AEREA_CIU_ORIG, RUTA_AEREA_CIU_DEST
	END
GO

GO
	CREATE PROCEDURE MIGRAR_PASAJES
	AS
	BEGIN
		INSERT INTO GRUPO2.Pasaje(pasaje_codigo, pasaje_vuelo, pasaje_avion, pasaje_butaca, pasaje_tipo_butaca, pasaje_aerolinea, precio)
			SELECT PASAJE_CODIGO, VUELO_CODIGO, AVION_IDENTIFICADOR, BUTACA_NUMERO, BUTACA_TIPO, EMPRESA_RAZON_SOCIAL, PASAJE_PRECIO FROM gd_esquema.Maestra WHERE PASAJE_CODIGO IS NOT NULL GROUP BY PASAJE_CODIGO, VUELO_CODIGO, AVION_IDENTIFICADOR, BUTACA_NUMERO, BUTACA_TIPO, EMPRESA_RAZON_SOCIAL, PASAJE_PRECIO
	END
GO

GO
	CREATE PROCEDURE MIGRAR_OPERACIONES_PASAJE
	AS
	BEGIN
		INSERT INTO GRUPO2.Operacion_Pasaje(operacion_pasaje_numero, operacion_pasaje_tipo, operacion_pasaje_codigo_pasaje, operacion_pasaje_vuelo_pasaje, operacion_pasaje_aerolinea_pasaje)
			SELECT
				COMPRA_NUMERO,
				(CASE WHEN FACTURA_NRO IS NOT NULL THEN 'VENTA' ELSE 'COMPRA' END),
				PASAJE_CODIGO,
				VUELO_CODIGO,
				EMPRESA_RAZON_SOCIAL
			FROM gd_esquema.Maestra
			WHERE PASAJE_CODIGO IS NOT NULL
	END
GO

-- Aca van los testeos de la tabla (ejecución de los procedures para ver que funcione bien) --
SELECT * FROM gd_esquema.Maestra

--EXECUTE dbo.MIGRAR_VUELOS
--EXECUTE dbo.MIGRAR_PASAJES

SELECT * FROM GRUPO2.Vuelo
SELECT * FROM GRUPO2.Pasaje