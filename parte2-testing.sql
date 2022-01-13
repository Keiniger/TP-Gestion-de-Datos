USE GD1C2020


-- Tablas a testear --
/*
	GRUPO2.Operacion_Estadia
	GRUPO2.Estadia
	GRUPO2.Hotel
	GRUPO2.Habitacion
	GRUPO2.Tipo_Habitacion
	GRUPO2.Habitacion_Estadia
*/

-- Elimino los objetos creados anteriormente para evitar el error de que ya existen --
IF EXISTS (SELECT name FROM sysobjects WHERE name='MIGRAR_HOTEL')
	DROP PROCEDURE MIGRAR_HOTEL
IF EXISTS (SELECT name FROM sysobjects WHERE name='MIGRAR_HABITACION') 
	DROP PROCEDURE MIGRAR_HABITACION
IF EXISTS (SELECT name FROM sysobjects WHERE name='MIGRAR_ESTADIA') 
	DROP PROCEDURE MIGRAR_ESTADIA
	IF EXISTS (SELECT name FROM sysobjects WHERE name='MIGRAR_HABITACION_X_ESTADIA') 
	DROP PROCEDURE MIGRAR_HABITACION_X_ESTADIA
IF EXISTS (SELECT name FROM sysobjects WHERE name='MIGRAR_OPERACION_ESTADIA') 
	DROP PROCEDURE MIGRAR_OPERACION_ESTADIA

-- Aca van los procedures --
GO
CREATE PROCEDURE MIGRAR_HOTEL 
AS
BEGIN 
	INSERT INTO GRUPO2.Hotel(hotel_nombre,hotel_calle, hotel_numero_calle, hotel_estrellas)
		SELECT DISTINCT EMPRESA_RAZON_SOCIAL, HOTEL_CALLE, HOTEL_NRO_CALLE, HOTEL_CANTIDAD_ESTRELLAS
		FROM gd_esquema.Maestra
		WHERE EMPRESA_RAZON_SOCIAL IS NOT NULL 
		AND HOTEL_CALLE IS NOT NULL
		AND HOTEL_NRO_CALLE IS NOT NULL
		AND HOTEL_CANTIDAD_ESTRELLAS IS NOT NULL
END
GO

GO
CREATE PROCEDURE MIGRAR_HABITACION
AS
BEGIN
	--Primero migro a la tabla de tipo habitacion.
	--Ademas, como el codigo de tipo_habitacion es generado automaticamente, tengo que permitir la 
	--identity insert para poder seguir teniendo los codigos viejos
	SET IDENTITY_INSERT GRUPO2.Tipo_Habitacion ON;
	INSERT INTO GRUPO2.Tipo_Habitacion(tipo_habitacion_codigo, tipo_habitacion_descripcion)
		SELECT DISTINCT TIPO_HABITACION_CODIGO, TIPO_HABITACION_DESC FROM gd_esquema.Maestra WHERE TIPO_HABITACION_CODIGO IS NOT NULL
	--Una vez que migre los datos, desactivo el identity insert
	SET IDENTITY_INSERT GRUPO2.Tipo_Habitacion OFF;

	INSERT INTO GRUPO2.Habitacion(habitacion_hotel_nombre, habitacion_hotel_calle, habitacion_hotel_numero_calle, habitacion_numero, habitacion_piso, habitacion_tipo, habitacion_costo)
		SELECT DISTINCT EMPRESA_RAZON_SOCIAL, HOTEL_CALLE, HOTEL_NRO_CALLE, HABITACION_NUMERO, HABITACION_PISO, TIPO_HABITACION_CODIGO, HABITACION_PRECIO
		FROM gd_esquema.Maestra 
		WHERE EMPRESA_RAZON_SOCIAL IS NOT NULL
		AND HOTEL_CALLE IS NOT NULL
		AND HOTEL_NRO_CALLE IS NOT NULL
		AND HABITACION_NUMERO IS NOT NULL
		AND HABITACION_PISO IS NOT NULL
		AND TIPO_HABITACION_CODIGO IS NOT NULL
		AND HABITACION_PRECIO IS NOT NULL
END
GO

GO
CREATE PROCEDURE MIGRAR_ESTADIA
AS
BEGIN
	--Aca tambien activo identity insert para poder insertar los codigos viejos, y que no se 
	--me generen automaticamente
	SET IDENTITY_INSERT GRUPO2.Estadia ON;
	INSERT INTO GRUPO2.Estadia(estadia_hotel_nombre, estadia_hotel_calle, estadia_hotel_numero_calle, estadia_codigo, estadia_fecha_inicio, estadia_cantidad_noches)
		SELECT DISTINCT EMPRESA_RAZON_SOCIAL, HOTEL_CALLE, HOTEL_NRO_CALLE, ESTADIA_CODIGO, ESTADIA_FECHA_INI, ESTADIA_CANTIDAD_NOCHES
		FROM gd_esquema.Maestra
		WHERE EMPRESA_RAZON_SOCIAL IS NOT NULL
		and HOTEL_CALLE IS NOT NULL
		and HOTEL_NRO_CALLE IS NOT NULL
		and ESTADIA_CODIGO IS NOT NULL
		and ESTADIA_FECHA_INI IS NOT NULL
		and ESTADIA_CANTIDAD_NOCHES IS NOT NULL
	SET IDENTITY_INSERT GRUPO2.Estadia OFF;
END
GO

GO
CREATE PROCEDURE MIGRAR_HABITACION_X_ESTADIA
AS
BEGIN
	INSERT INTO GRUPO2.Habitacion_Estadia(habitacion_estadia_hotel_nombre, habitacion_estadia_hotel_calle, habitacion_estadia_hotel_numero_calle, habitacion_estadia_codigo_estadia, habitacion_estadia_piso_habitacion, habitacion_estadia_numero_habitacion, habitacion_estadia_costo)
		SELECT DISTINCT EMPRESA_RAZON_SOCIAL, HOTEL_CALLE, HOTEL_NRO_CALLE, ESTADIA_CODIGO, HABITACION_PISO, HABITACION_NUMERO, HABITACION_COSTO
		FROM gd_esquema.Maestra
		WHERE EMPRESA_RAZON_SOCIAL IS NOT NULL
		and HOTEL_CALLE IS NOT NULL
		and HOTEL_NRO_CALLE IS NOT NULL
		and HABITACION_PISO IS NOT NULL
		and HABITACION_NUMERO IS NOT NULL
		and HABITACION_COSTO IS NOT NULL
END
GO



GO
CREATE PROCEDURE MIGRAR_OPERACION_ESTADIA
AS
BEGIN
	INSERT INTO GRUPO2.Operacion_Estadia(operacion_estadia_numero, operacion_estadia_codigo_estadia, operacion_estadia_hotel_nombre, operacion_estadia_hotel_calle, operacion_estadia_hotel_numero_calle, operacion_estadia_tipo)
		SELECT DISTINCT COMPRA_NUMERO, ESTADIA_CODIGO, EMPRESA_RAZON_SOCIAL, HOTEL_CALLE, HOTEL_NRO_CALLE, CASE WHEN FACTURA_NRO IS NOT NULL THEN 'VENTA' ELSE 'COMPRA' END
		FROM gd_esquema.Maestra
		WHERE COMPRA_NUMERO IS NOT NULL
		and ESTADIA_CODIGO IS NOT NULL
		and EMPRESA_RAZON_SOCIAL IS NOT NULL
		and HOTEL_CALLE IS NOT NULL
		and HOTEL_NRO_CALLE IS NOT NULL
END
GO


-- Aca van los testeos de la tabla (ejecución de los procedures para ver que funcione bien) --


EXECUTE MIGRAR_HOTEL
EXECUTE MIGRAR_HABITACION
EXECUTE MIGRAR_ESTADIA
EXECUTE MIGRAR_HABITACION_X_ESTADIA
--No puedo probar hasta que este creada Operacion
EXECUTE MIGRAR_OPERACION_ESTADIA

SELECT * FROM gd_esquema.Maestra

SELECT * FROM GRUPO2.Empresa	--22 Empresas migradas
SELECT * FROM GRUPO2.Hotel		--20 Hoteles migrados
SELECT * FROM GRUPO2.Habitacion	--424 Habitaciones
SELECT * FROM GRUPO2.Tipo_Habitacion	--5 Tipos de Habitaciones
SELECT * FROM GRUPO2.Estadia	--15688 Estadias Migradas
SELECT * FROM GRUPO2.Habitacion_Estadia

DELETE FROM GRUPO2.Hotel
DELETE FROM GRUPO2.Habitacion_Estadia
DELETE FROM GRUPO2.Habitacion
DELETE FROM GRUPO2.Tipo_Habitacion
DELETE FROM GRUPO2.Estadia