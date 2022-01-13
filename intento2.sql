USE GD1C2020

-- Elimino todos los objetos para poder actualizarlos --
GO
	-- PROCEDIMIENTOS --
	IF EXISTS (SELECT name FROM sysobjects WHERE name='CREAR_TABLAS')
		DROP PROCEDURE CREAR_TABLAS
	IF EXISTS (SELECT name FROM sysobjects WHERE name='MIGRAR_TABLAS')
		DROP PROCEDURE MIGRAR_TABLAS
	-- FUNCIONES --
	IF EXISTS (SELECT name FROM sysobjects WHERE name='COSTO_OPERACION_ESTADIA')
		DROP FUNCTION COSTO_OPERACION_ESTADIA
	IF EXISTS (SELECT name FROM sysobjects WHERE name='ES_UNA_AEROLINEA')
		DROP FUNCTION ES_UNA_AEROLINEA
	IF EXISTS (SELECT name FROM sysobjects WHERE name='CODIGO_CIUDAD')
		DROP FUNCTION CODIGO_CIUDAD
	-- TRIGGERS --
	IF EXISTS (SELECT name FROM sysobjects WHERE name='TG_INSERTAR_RUTA_AEREA')
		DROP TRIGGER GRUPO2.TG_INSERTAR_RUTA_AEREA
	IF EXISTS (SELECT name FROM sysobjects WHERE name='TG_MODIFICAR_RUTA_AEREA')
		DROP TRIGGER GRUPO2.TG_MODIFICAR_RUTA_AEREA
	-- TABLAS --
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Factura')
		DROP TABLE GRUPO2.Factura
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Operacion_Pasaje')
		DROP TABLE GRUPO2.Operacion_Pasaje
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Operacion_Estadia')
		DROP TABLE GRUPO2.Operacion_Estadia
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Operacion')
		DROP TABLE GRUPO2.Operacion
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Habitacion_Estadia')
		DROP TABLE GRUPO2.Habitacion_Estadia
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Estadia')
		DROP TABLE GRUPO2.Estadia
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Habitacion')
		DROP TABLE GRUPO2.Habitacion
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Tipo_Habitacion')
		DROP TABLE GRUPO2.Tipo_Habitacion
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Hotel')
		DROP TABLE GRUPO2.Hotel
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Pasaje')
		DROP TABLE GRUPO2.Pasaje
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Vuelo')
		DROP TABLE GRUPO2.Vuelo
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Ruta_Aerea')
		DROP TABLE GRUPO2.Ruta_Aerea
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Ciudad')
		DROP TABLE GRUPO2.Ciudad
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Butaca')
		DROP TABLE GRUPO2.Butaca
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Avion')
		DROP TABLE GRUPO2.Avion
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Aerolinea')
		DROP TABLE GRUPO2.Aerolinea
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Usuario')
		DROP TABLE GRUPO2.Usuario
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Sucursal')
		DROP TABLE GRUPO2.Sucursal
	IF EXISTS (SELECT name FROM sysobjects WHERE name='Empresa')
		DROP TABLE GRUPO2.Empresa
	-- SCHEME --
	DROP SCHEMA IF EXISTS GRUPO2;
GO

-- Creación del Esquema --
CREATE SCHEMA GRUPO2

-- Creación de Tablas --
GO
	CREATE PROCEDURE CREAR_TABLAS
	AS
	BEGIN
		-- Empresa
		CREATE TABLE GRUPO2.Empresa(
			empresa_razon_social varchar(255) NOT NULL,	
			PRIMARY KEY(empresa_razon_social)
		)

		-- Sucursal
		CREATE TABLE GRUPO2.Sucursal(
			sucursal_empresa varchar(255) NOT NULL,
			sucursal_mail varchar(255) NOT NULL,
			sucursal_direccion varchar(255) NOT NULL,
			sucursal_telefono decimal(18, 0) NOT NULL,
			PRIMARY KEY(sucursal_empresa, sucursal_direccion),
			FOREIGN KEY(sucursal_empresa) REFERENCES GRUPO2.Empresa(empresa_razon_social)
		);

		-- Usuario
		CREATE TABLE GRUPO2.Usuario(
			usuario_dni decimal(18, 0) NOT NULL,
			usuario_nombre varchar(255) NOT NULL,
			usuario_apellido varchar(255) NOT NULL,
			usuario_mail varchar(255) NOT NULL,
			usuario_telefono decimal(18, 0) NOT NULL,
			PRIMARY KEY(usuario_dni, usuario_nombre, usuario_apellido)
		)

		-- Aerolinea
		CREATE TABLE GRUPO2.Aerolinea(
			aerolinea_nombre varchar(255),
			PRIMARY KEY(aerolinea_nombre),
			FOREIGN KEY(aerolinea_nombre) REFERENCES GRUPO2.Empresa(empresa_razon_social)
		)

		-- Avión
		CREATE TABLE GRUPO2.Avion(
			avion_identificador char(12) NOT NULL,
			avion_aerolinea varchar(255) NOT NULL,
			avion_modelo char(20) NOT NULL,
			PRIMARY KEY(avion_identificador, avion_aerolinea),
			FOREIGN KEY (avion_aerolinea) REFERENCES GRUPO2.Aerolinea(aerolinea_nombre)
		)

		-- Butaca
		CREATE TABLE GRUPO2.Butaca(
			butaca_numero int NOT NULL,
			butaca_avion char(12) NOT NULL,
			butaca_aerolinea varchar(255) NOT NULL,
			butaca_tipo varchar(255) NOT NULL,
			PRIMARY KEY(butaca_numero, butaca_avion, butaca_aerolinea, butaca_tipo),
			FOREIGN KEY (butaca_avion, butaca_aerolinea) REFERENCES GRUPO2.Avion(avion_identificador, avion_aerolinea)
		)

		-- Ciudad
		CREATE TABLE GRUPO2.Ciudad(
			ciudad_id int NOT NULL IDENTITY(1, 1),
			ciudad_nombre varchar(255) NOT NULL UNIQUE,
			PRIMARY KEY(ciudad_id)
		)

		-- Ruta aerea
		CREATE TABLE GRUPO2.Ruta_Aerea(
			ruta_aerea_codigo int NOT NULL,
			ruta_aerea_ciudad_origen int NOT NULL,
			ruta_aerea_ciudad_destino int NOT NULL,
			PRIMARY KEY (ruta_aerea_codigo, ruta_aerea_ciudad_origen, ruta_aerea_ciudad_destino),
			FOREIGN KEY (ruta_aerea_ciudad_origen) REFERENCES GRUPO2.Ciudad(ciudad_id),
			FOREIGN KEY (ruta_aerea_ciudad_destino) REFERENCES GRUPO2.Ciudad(ciudad_id),
			UNIQUE(ruta_aerea_ciudad_origen, ruta_aerea_ciudad_destino)
		)

		-- Vuelo
		CREATE TABLE GRUPO2.Vuelo(
			vuelo_avion char(12) NOT NULL,
			vuelo_aerolinea varchar(255) NOT NULL,
			vuelo_codigo int NOT NULL,
			vuelo_fecha_salida datetime NOT NULL,
			vuelo_fecha_llegada datetime NOT NULL,
			vuelo_ruta_codigo int NOT NULL,
			vuelo_ruta_origen int NOT NULL,
			vuelo_ruta_destino int NOT NULL,
			PRIMARY KEY(vuelo_aerolinea, vuelo_codigo),
			FOREIGN KEY (vuelo_ruta_codigo, vuelo_ruta_origen, vuelo_ruta_destino) REFERENCES GRUPO2.Ruta_Aerea(ruta_aerea_codigo, ruta_aerea_ciudad_origen, ruta_aerea_ciudad_destino),
			FOREIGN KEY (vuelo_avion, vuelo_aerolinea) REFERENCES GRUPO2.Avion(avion_identificador, avion_aerolinea)
		)

		-- Pasaje
		CREATE TABLE GRUPO2.Pasaje(
			pasaje_codigo int NOT NULL,
			pasaje_vuelo int NOT NULL,
			pasaje_avion char(12) NOT NULL,
			pasaje_butaca int NOT NULL,
			pasaje_tipo_butaca varchar(255) NOT NULL,
			pasaje_aerolinea varchar(255) NOT NULL,
			precio decimal(12, 2) NOT NULL,
			PRIMARY KEY(pasaje_codigo, pasaje_vuelo, pasaje_aerolinea),
			FOREIGN KEY (pasaje_aerolinea, pasaje_vuelo) REFERENCES GRUPO2.Vuelo(vuelo_aerolinea, vuelo_codigo),
			FOREIGN KEY (pasaje_butaca, pasaje_avion, pasaje_aerolinea, pasaje_tipo_butaca) REFERENCES GRUPO2.Butaca(butaca_numero, butaca_avion, butaca_aerolinea, butaca_tipo)
		)

		-- Hotel
		CREATE TABLE GRUPO2.Hotel(
			hotel_nombre varchar(255) NOT NULL,
			hotel_calle varchar(255) NOT NULL,
			hotel_numero_calle varchar(255) NOT NULL,
			hotel_estrellas decimal(18, 0) NOT NULL,
			PRIMARY KEY(hotel_nombre, hotel_calle, hotel_numero_calle),
			FOREIGN KEY(hotel_nombre) REFERENCES GRUPO2.Empresa(empresa_razon_social),
		)

		-- Tipo de Habitacion
		CREATE TABLE GRUPO2.Tipo_Habitacion(
			tipo_habitacion_codigo decimal(18, 0) NOT NULL IDENTITY(1, 1),
			tipo_habitacion_descripcion nvarchar(50) NOT NULL UNIQUE,
			PRIMARY KEY(tipo_habitacion_codigo)
		)

		-- Habitacion
		CREATE TABLE GRUPO2.Habitacion(
			habitacion_hotel_nombre varchar(255) NOT NULL,
			habitacion_hotel_calle varchar(255) NOT NULL,
			habitacion_hotel_numero_calle varchar(255) NOT NULL,
			habitacion_numero decimal(18, 0) NOT NULL,
			habitacion_piso decimal(18, 0) NOT NULL,
			habitacion_tipo decimal(18, 0) NOT NULL,
			habitacion_costo decimal(18, 2) NOT NULL,
			PRIMARY KEY(habitacion_hotel_nombre, habitacion_hotel_calle, habitacion_hotel_numero_calle, habitacion_numero, habitacion_piso),
			FOREIGN KEY(habitacion_tipo) REFERENCES GRUPO2.Tipo_Habitacion(tipo_habitacion_codigo),
			FOREIGN KEY(habitacion_hotel_nombre, habitacion_hotel_calle, habitacion_hotel_numero_calle) REFERENCES GRUPO2.Hotel(hotel_nombre, hotel_calle, hotel_numero_calle)
		)

		-- Estadia
		CREATE TABLE GRUPO2.Estadia(
			estadia_codigo decimal(18, 0) NOT NULL IDENTITY(1, 1),
			estadia_hotel_nombre varchar(255) NOT NULL,
			estadia_hotel_calle varchar(255) NOT NULL,
			estadia_hotel_numero_calle varchar(255) NOT NULL,
			estadia_fecha_inicio datetime2(3) NOT NULL,
			estadia_cantidad_noches decimal(18, 0) NOT NULL,
			PRIMARY KEY(estadia_codigo, estadia_hotel_nombre, estadia_hotel_calle, estadia_hotel_numero_calle),
			FOREIGN KEY(estadia_hotel_nombre, estadia_hotel_calle, estadia_hotel_numero_calle) REFERENCES GRUPO2.Hotel(hotel_nombre, hotel_calle, hotel_numero_calle)
		)

		-- Habitacion x Estadia
		CREATE TABLE GRUPO2.Habitacion_Estadia(
			habitacion_estadia_hotel_nombre varchar(255) NOT NULL,
			habitacion_estadia_hotel_calle varchar(255) NOT NULL,
			habitacion_estadia_hotel_numero_calle varchar(255) NOT NULL,
			habitacion_estadia_codigo_estadia decimal(18, 0) NOT NULL,
			habitacion_estadia_piso_habitacion decimal(18, 0) NOT NULL,
			habitacion_estadia_numero_habitacion decimal(18, 0) NOT NULL,
			habitacion_estadia_costo decimal(18, 2) NOT NULL,
			PRIMARY KEY(habitacion_estadia_hotel_nombre, habitacion_estadia_hotel_calle, habitacion_estadia_hotel_numero_calle, habitacion_estadia_codigo_estadia, habitacion_estadia_piso_habitacion, habitacion_estadia_numero_habitacion),
			FOREIGN KEY(habitacion_estadia_codigo_estadia, habitacion_estadia_hotel_nombre, habitacion_estadia_hotel_calle, habitacion_estadia_hotel_numero_calle) REFERENCES GRUPO2.Estadia(estadia_codigo, estadia_hotel_nombre, estadia_hotel_calle, estadia_hotel_numero_calle),
			FOREIGN KEY(habitacion_estadia_hotel_nombre, habitacion_estadia_hotel_calle, habitacion_estadia_hotel_numero_calle, habitacion_estadia_numero_habitacion, habitacion_estadia_piso_habitacion) REFERENCES GRUPO2.Habitacion(habitacion_hotel_nombre, habitacion_hotel_calle, habitacion_hotel_numero_calle, habitacion_numero, habitacion_piso)
		)

		-- Operacion
		CREATE TABLE GRUPO2.Operacion(
			operacion_numero decimal(18, 0) NOT NULL,
			operacion_tipo varchar(6) NOT NULL,
			operacion_fecha datetime NOT NULL
			PRIMARY KEY(operacion_numero, operacion_tipo)
		)

		-- Operacion Estadia
		CREATE TABLE GRUPO2.Operacion_Estadia(
			operacion_estadia_numero decimal(18, 0) NOT NULL,
			operacion_estadia_tipo varchar(6) NOT NULL,
			operacion_estadia_codigo_estadia decimal(18, 0) NOT NULL,
			operacion_estadia_hotel_nombre varchar(255) NOT NULL,
			operacion_estadia_hotel_calle varchar(255) NOT NULL,
			operacion_estadia_hotel_numero_calle varchar(255) NOT NULL,
			PRIMARY KEY(operacion_estadia_numero, operacion_estadia_tipo, operacion_estadia_hotel_nombre, operacion_estadia_hotel_calle, operacion_estadia_hotel_numero_calle, operacion_estadia_codigo_estadia),
			FOREIGN KEY(operacion_estadia_numero, operacion_estadia_tipo) REFERENCES GRUPO2.Operacion(operacion_numero, operacion_tipo),
			FOREIGN KEY(operacion_estadia_codigo_estadia, operacion_estadia_hotel_nombre, operacion_estadia_hotel_calle, operacion_estadia_hotel_numero_calle) REFERENCES GRUPO2.Estadia(estadia_codigo, estadia_hotel_nombre, estadia_hotel_calle, estadia_hotel_numero_calle)
		)

		-- Operacion_Pasaje
		CREATE TABLE GRUPO2.Operacion_Pasaje(
			operacion_pasaje_numero decimal(18, 0) NOT NULL,
			operacion_pasaje_tipo varchar(6) NOT NULL,
			operacion_pasaje_codigo_pasaje int NOT NULL,
			operacion_pasaje_vuelo_pasaje int NOT NULL,
			operacion_pasaje_aerolinea_pasaje varchar(255) NOT NULL,
			PRIMARY KEY(operacion_pasaje_numero, operacion_pasaje_tipo, operacion_pasaje_codigo_pasaje, operacion_pasaje_vuelo_pasaje, operacion_pasaje_aerolinea_pasaje),
			FOREIGN KEY(operacion_pasaje_numero, operacion_pasaje_tipo) REFERENCES GRUPO2.Operacion(operacion_numero, operacion_tipo), 
			FOREIGN KEY(operacion_pasaje_codigo_pasaje, operacion_pasaje_vuelo_pasaje, operacion_pasaje_aerolinea_pasaje) REFERENCES GRUPO2.Pasaje(pasaje_codigo, pasaje_vuelo, pasaje_aerolinea)
		)

		-- Factura
		CREATE TABLE GRUPO2.Factura(
			factura_numero_operacion decimal(18, 0) NOT NULL,
			factura_tipo_operacion varchar(6) NOT NULL,
			factura_sucursal_direccion varchar(255) NOT NULL,
			factura_sucursal_empresa varchar(255) NOT NULL,
			factura_fecha datetime NOT NULL,
			factura_costo_final decimal(18, 2) NOT NULL,
			factura_cliente_dni decimal(18, 0) NOT NULL,
			factura_cliente_nombre varchar(255) NOT NULL,
			factura_cliente_apellido varchar(255) NOT NULL,
			PRIMARY KEY(factura_numero_operacion, factura_tipo_operacion, factura_sucursal_direccion, factura_sucursal_empresa),
			FOREIGN KEY(factura_sucursal_empresa, factura_sucursal_direccion) REFERENCES GRUPO2.Sucursal(sucursal_empresa, sucursal_direccion),
			FOREIGN KEY(factura_cliente_dni, factura_cliente_nombre, factura_cliente_apellido) REFERENCES GRUPO2.Usuario(usuario_dni, usuario_nombre, usuario_apellido)
		)
	END
GO

-- Funciones --
GO
	CREATE FUNCTION COSTO_OPERACION_ESTADIA(@CODIGO_ESTADIA decimal(18, 0), @HOTEL varchar(255), @HOTEL_CALLE varchar(255), @HOTEL_NUMERO_CALLE varchar(255))
	RETURNS decimal(18, 2)
	AS
	BEGIN
		DECLARE @COSTO_FINAL decimal(18, 2)

		SELECT @COSTO_FINAL = SUM(habitacion_estadia_costo) 
		FROM GRUPO2.Habitacion_Estadia
		WHERE habitacion_estadia_codigo_estadia = @CODIGO_ESTADIA
		AND habitacion_estadia_hotel_nombre = @HOTEL
		AND habitacion_estadia_hotel_calle = @HOTEL_CALLE
		AND habitacion_estadia_hotel_numero_calle = @HOTEL_NUMERO_CALLE

		RETURN @COSTO_FINAL
	END
GO

GO
	CREATE FUNCTION ES_UNA_AEROLINEA (@empresa varchar(255))
	RETURNS tinyint
	AS
	BEGIN
		DECLARE @valor_retorno tinyint
		DECLARE @aviones_empresa int
			SELECT @aviones_empresa = COUNT(DISTINCT AVION_IDENTIFICADOR) FROM gd_esquema.Maestra WHERE (EMPRESA_RAZON_SOCIAL = @empresa) AND (AVION_IDENTIFICADOR IS NOT NULL)

		-- Si tiene al menos un avión, podemos decir que esa empresa es una aerolínea --
		IF(@aviones_empresa > 0)
			SET @valor_retorno = 1
		-- De otra forma, no lo es --
		ELSE
			SET @valor_retorno = 0

		RETURN @valor_retorno
	END
GO

GO
	CREATE FUNCTION CODIGO_CIUDAD (@ciudad varchar(255))
	RETURNS INT
	AS
	BEGIN
		DECLARE @codigo int
			SELECT @codigo = ciudad_id FROM GRUPO2.Ciudad WHERE ciudad_nombre = @ciudad
		
		RETURN @codigo
	END
GO

-- Procedures --
GO
	CREATE PROCEDURE MIGRAR_TABLAS
	AS
	BEGIN
		-- Creo variables para tomar todos los valores de la tabla maestra mediante un cursor --
		DECLARE @compra_numero decimal(18,0), @compra_fecha datetime2(3), 
		        @estadia_fecha_inicio datetime2(3), @estadia_cantidad_noches decimal(18,0), @estadia_codigo decimal(18,0),
				@empresa_razon_social nvarchar(255),
				@hotel_calle nvarchar(50), @hotel_nro_calle decimal(18,0), @hotel_cantidad_estrellas decimal(18,0),
				@habitacion_numero decimal(18,0), @habitacion_piso decimal(18,0), @habitacion_frente nvarchar(50), @habitacion_costo decimal(12,2), @habitacion_precio decimal(18,2),
				@tipo_habitacion_codigo decimal(18,0), @tipo_habitacion_desc nvarchar(50),
				@pasaje_codigo decimal(18,0), @pasaje_costo decimal(18,2), @pasaje_precio decimal(18,2), @pasaje_fecha_compra datetime2(3),
				@vuelo_codigo decimal(19,0), @vuelo_fecha_salida datetime2(3), @vuelo_fecha_llegada datetime2(3),
				@ruta_aerea_codigo decimal(18,0), @ruta_aerea_ciudad_origen nvarchar(255), @ruta_aerea_ciudad_destino nvarchar(255),
				@butaca_numero decimal(18,0), @butaca_tipo nvarchar(255),
				@avion_modelo nvarchar(50), @avion_identificador nvarchar(50),
				@factura_fecha datetime2(3), @factura_numero decimal(18,0),
				@cliente_apellido nvarchar(255), @cliente_nombre nvarchar(255), @cliente_dni decimal(18,0), @cliente_fecha_nacimiento datetime2(3), @cliente_mail nvarchar(255), @cliente_telefono int,
				@sucursal_direccion nvarchar(255), @sucursal_mail nvarchar(255), @sucursal_telefono decimal(18,0)
		-- Declaro un cursor para analizar cada uno de los elementos de la tabla maestra por separado --
		DECLARE CURSOR_MAESTRA CURSOR FOR (
											SELECT 
												COMPRA_NUMERO, COMPRA_FECHA, 
												ESTADIA_FECHA_INI, ESTADIA_CANTIDAD_NOCHES, ESTADIA_CODIGO,
												EMPRESA_RAZON_SOCIAL,
												HOTEL_CALLE, HOTEL_NRO_CALLE, HOTEL_CANTIDAD_ESTRELLAS,
												HABITACION_NUMERO, HABITACION_PISO, HABITACION_FRENTE, HABITACION_COSTO, HABITACION_PRECIO,
												TIPO_HABITACION_CODIGO, TIPO_HABITACION_DESC,
												PASAJE_CODIGO, PASAJE_COSTO, PASAJE_PRECIO, PASAJE_FECHA_COMPRA,
												VUELO_CODIGO, VUELO_FECHA_SALUDA, VUELO_FECHA_LLEGADA,
												RUTA_AEREA_CODIGO, RUTA_AEREA_CIU_ORIG, RUTA_AEREA_CIU_DEST,
												BUTACA_NUMERO, BUTACA_TIPO,
												AVION_MODELO, AVION_IDENTIFICADOR,
												FACTURA_FECHA, FACTURA_NRO,
												CLIENTE_APELLIDO, CLIENTE_NOMBRE, CLIENTE_DNI, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_TELEFONO, 
												SUCURSAL_DIR, SUCURSAL_MAIL, SUCURSAL_TELEFONO
											FROM gd_esquema.Maestra
										  )
		-- Abro el cursor --
		OPEN CURSOR_MAESTRA
		-- Recorro el cursor --
		FETCH NEXT FROM CURSOR_MAESTRA INTO
			@compra_numero, @compra_fecha, @estadia_fecha_inicio, @estadia_cantidad_noches, @estadia_codigo, @empresa_razon_social,
			@hotel_calle, @hotel_nro_calle, @hotel_cantidad_estrellas,
			@habitacion_numero, @habitacion_piso, @habitacion_frente, @habitacion_costo, @habitacion_precio,
			@tipo_habitacion_codigo, @tipo_habitacion_desc, @pasaje_codigo, @pasaje_costo, @pasaje_precio, @pasaje_fecha_compra,
			@vuelo_codigo, @vuelo_fecha_salida, @vuelo_fecha_llegada, @ruta_aerea_codigo, @ruta_aerea_ciudad_origen, @ruta_aerea_ciudad_destino,
			@butaca_numero, @butaca_tipo, @avion_modelo, @avion_identificador, @factura_fecha, @factura_numero,
			@cliente_apellido, @cliente_nombre, @cliente_dni, @cliente_fecha_nacimiento, @cliente_mail, @cliente_telefono,
			@sucursal_direccion, @sucursal_mail, @sucursal_telefono
		WHILE(@@FETCH_STATUS = 0)
			BEGIN
				INSERT INTO GRUPO2.Empresa(empresa_razon_social) VALUES(@empresa_razon_social)
				-- Paso al siguiente elemento --
				FETCH NEXT FROM CURSOR_MAESTRA INTO
					@compra_numero, @compra_fecha, @estadia_fecha_inicio, @estadia_cantidad_noches, @estadia_codigo, @empresa_razon_social,
					@hotel_calle, @hotel_nro_calle, @hotel_cantidad_estrellas,
					@habitacion_numero, @habitacion_piso, @habitacion_frente, @habitacion_costo, @habitacion_precio,
					@tipo_habitacion_codigo, @tipo_habitacion_desc, @pasaje_codigo, @pasaje_costo, @pasaje_precio, @pasaje_fecha_compra,
					@vuelo_codigo, @vuelo_fecha_salida, @vuelo_fecha_llegada, @ruta_aerea_codigo, @ruta_aerea_ciudad_origen, @ruta_aerea_ciudad_destino,
					@butaca_numero, @butaca_tipo, @avion_modelo, @avion_identificador, @factura_fecha, @factura_numero,
					@cliente_apellido, @cliente_nombre, @cliente_dni, @cliente_fecha_nacimiento, @cliente_mail, @cliente_telefono,
					@sucursal_direccion, @sucursal_mail, @sucursal_telefono
			END
		-- Cierro el cursor --
		CLOSE CURSOR_MAESTRA
		DEALLOCATE CURSOR_MAESTRA
	END
GO


-- Ejecutamos los procedimientos en el orden correspondiente --
EXECUTE CREAR_TABLAS
EXECUTE MIGRAR_TABLAS
SELECT * FROM GRUPO2.Empresa

-- Triggers --
GO
	CREATE TRIGGER TG_INSERTAR_RUTA_AEREA ON GRUPO2.Ruta_Aerea INSTEAD OF INSERT
	AS
	BEGIN
		INSERT INTO GRUPO2.Ruta_Aerea(ruta_aerea_codigo, ruta_aerea_ciudad_origen, ruta_aerea_ciudad_destino)
			SELECT ruta_aerea_codigo, ruta_aerea_ciudad_origen, ruta_aerea_ciudad_destino FROM inserted WHERE ruta_aerea_ciudad_origen != ruta_aerea_ciudad_destino
	END
GO

GO
	CREATE TRIGGER TG_MODIFICAR_RUTA_AEREA ON GRUPO2.Ruta_Aerea INSTEAD OF UPDATE
	AS
	BEGIN
		DECLARE @codigo_actual int
		DECLARE @origen_actual int 
		DECLARE @destino_actual int

		DECLARE @codigo_nuevo int
		DECLARE @origen_nuevo int 
		DECLARE @destino_nuevo int
		
		DECLARE CURSOR_NUEVOS_DATOS CURSOR FOR
			SELECT ruta_aerea_codigo, ruta_aerea_ciudad_origen, ruta_aerea_ciudad_destino FROM inserted
		DECLARE CURSOR_DATOS_ANTIGUOS CURSOR FOR
			SELECT ruta_aerea_codigo, ruta_aerea_ciudad_origen, ruta_aerea_ciudad_destino FROM deleted
	
		OPEN CURSOR_NUEVOS_DATOS
		OPEN CURSOR_DATOS_ANTIGUOS

		DECLARE @status_nuevos int
		DECLARE @status_viejos int

		FETCH NEXT FROM CURSOR_NUEVOS_DATOS INTO @codigo_nuevo, @origen_nuevo, @destino_nuevo
		SET @status_nuevos = @@FETCH_STATUS
		FETCH NEXT FROM CURSOR_DATOS_ANTIGUOS INTO @codigo_actual, @origen_actual, @destino_actual
		SET @status_viejos = @@FETCH_STATUS
		WHILE((@status_nuevos = 0) AND (@status_viejos = 0))
			BEGIN
				IF(@destino_nuevo != @origen_nuevo)
					BEGIN
						UPDATE GRUPO2.Ruta_Aerea SET ruta_aerea_codigo = @codigo_nuevo, ruta_aerea_ciudad_origen = @origen_nuevo, ruta_aerea_ciudad_destino = @destino_nuevo
						WHERE (ruta_aerea_codigo = @codigo_actual) AND (ruta_aerea_ciudad_origen = @origen_actual) AND (ruta_aerea_ciudad_destino = @destino_actual)
					END

				FETCH NEXT FROM CURSOR_NUEVOS_DATOS INTO @codigo_nuevo, @origen_nuevo, @destino_nuevo
				SET @status_nuevos = @@FETCH_STATUS
				FETCH NEXT FROM CURSOR_DATOS_ANTIGUOS INTO @codigo_actual, @origen_actual, @destino_actual
				SET @status_viejos = @@FETCH_STATUS
			END

		CLOSE CURSOR_NUEVOS_DATOS
		CLOSE CURSOR_DATOS_ANTIGUOS
		DEALLOCATE CURSOR_NUEVOS_DATOS
		DEALLOCATE CURSOR_DATOS_ANTIGUOS
	END
GO
