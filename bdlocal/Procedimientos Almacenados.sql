
CREATE PROCEDURE CrearRolUsuario
    @Email VARCHAR(100),
    @IdRol INT
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRANSACTION;

        -- Validar existencia del usuario
        IF NOT EXISTS (SELECT 1 FROM usuario WHERE email = @Email)
        BEGIN
            SELECT 0 AS 'estado', 'El usuario proporcionado no existe.' AS 'mensaje';
            ROLLBACK TRANSACTION;
            RETURN;
        END

		-- Validar existencia del rol
        IF NOT EXISTS (SELECT 1 FROM rol WHERE id = @IdRol)
        BEGIN
            SELECT 0 AS 'estado', 'El rol proporcionado no existe.' AS 'resultado';
            ROLLBACK;
            RETURN;
        END

		-- Validar que la combinaci�n email - idRol no exista ya
        IF EXISTS (SELECT 1 FROM rol_usuario WHERE fkemail = @Email AND fkidrol = @IdRol)
        BEGIN
             SELECT 0 AS 'estado', 'Este usuario ya tiene este rol.' AS 'resultado';
            ROLLBACK;
            RETURN;
        END

		INSERT INTO rol_usuario (fkemail, fkidrol) VALUES (@Email, @IdRol);
		SELECT 1 AS 'estado', 'Registro insertado exitosamente.' AS 'resultado';
        COMMIT;

END
GO

CREATE PROCEDURE BorrarRolUsuario
    @Email VARCHAR(100),
    @IdRol INT
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRANSACTION;

		-- Validar que la combinaci�n email - idRol exista
        IF NOT EXISTS (SELECT 1 FROM rol_usuario WHERE fkemail = @Email AND fkidrol = @IdRol)
        BEGIN
			SELECT 0 AS 'estado', 'Este usuario no cuenta con este rol.' AS 'resultado';
            ROLLBACK;
            RETURN;
        END

	    DELETE FROM rol_usuario WHERE fkemail = @Email AND fkidrol = @IdRol
		SELECT 1 AS 'estado', 'Registro eliminado exitosamente.' AS 'resultado';

	COMMIT;
END
GO

CREATE PROCEDURE RolPorUsuario
    @Email VARCHAR(100)
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRANSACTION;

	    -- Validar existencia del usuario
        IF NOT EXISTS (SELECT 1 FROM usuario WHERE email = @Email)
        BEGIN
            SELECT 'El usuario proporcionado no existe.' AS 'mensaje';
            ROLLBACK TRANSACTION;
            RETURN;
        END

		SELECT dbo.rol.nombre AS nombreRol, dbo.rol.id AS idRol
		FROM     dbo.rol_usuario INNER JOIN
                  dbo.rol ON dbo.rol_usuario.fkidrol = dbo.rol.id INNER JOIN
                  dbo.usuario ON dbo.rol_usuario.fkemail = dbo.usuario.email
		WHERE dbo.rol_usuario.fkemail = @Email

	COMMIT;
END
GO

CREATE PROCEDURE insertar_indicador_intermedias
	@codigo VARCHAR(50),
	@nombre VARCHAR(100),
	@objetivo VARCHAR(MAX),
	@alcance VARCHAR(1000),
	@formula VARCHAR(1000),
	@meta VARCHAR(1000),
    @fkidtipoindicador INT,
    @fkidunidadmedicion INT,
    @fkidsentido INT,
    @fkidfrecuencia INT,
	@fkidarticulo VARCHAR(20) = NULL,
	@fkidliteral VARCHAR(20)= NULL,
	@fkidnumeral VARCHAR(20) = NULL,
	@fkidparagrafo VARCHAR(20) = NULL,
    @represenvisualporindicador NVARCHAR(MAX) = NULL,
    @responsablesporindicador NVARCHAR(MAX) = NULL,
    @fuentesporindicador NVARCHAR(MAX) = NULL,
    @variablesporindicador NVARCHAR(MAX) = NULL
AS

BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
		BEGIN TRANSACTION;
	
		INSERT INTO indicador (codigo,nombre,objetivo,alcance,formula,meta,fkidtipoindicador,fkidunidadmedicion,fkidsentido,fkidfrecuencia,fkidarticulo,fkidliteral,fkidnumeral,fkidparagrafo)
		VALUES (@codigo,@nombre,@objetivo,@alcance,@formula,@meta,@fkidtipoindicador,@fkidunidadmedicion,@fkidsentido,@fkidfrecuencia,@fkidarticulo,@fkidliteral,@fkidnumeral,@fkidparagrafo)
		DECLARE @nuevoNumeroIndicador INT = SCOPE_IDENTITY();

		INSERT INTO represenvisualporindicador (fkidindicador, fkidrepresenvisual)
		SELECT @nuevoNumeroIndicador, fkidrepresenvisual
		FROM OPENJSON(@represenvisualporindicador)
		WITH (
			fkidrepresenvisual INT '$.fkidrepresenvisual'
		);

		INSERT INTO responsablesporindicador (fkidindicador, fkidresponsable)
		SELECT @nuevoNumeroIndicador, fkidresponsable
		FROM OPENJSON(@responsablesporindicador)
		WITH (
			fkidresponsable VARCHAR(50) '$.fkidresponsable'
		);

		INSERT INTO fuentesporindicador (fkidindicador, fkidfuente)
		SELECT @nuevoNumeroIndicador, fkidfuente
		FROM OPENJSON(@fuentesporindicador)
		WITH (
			fkidfuente INT '$.fkidfuente'
		);

		INSERT INTO variablesporindicador (fkidindicador, fkidvariable, dato, fkemailusuario, fechadato)
		SELECT @nuevoNumeroIndicador, fkidvariable, dato,fkemailusuario, GETDATE()
		FROM OPENJSON(@variablesporindicador)
		WITH (
			fkidvariable INT '$.fkidvariable',
			dato FLOAT '$.dato',
			fkemailusuario VARCHAR(100) '$.fkemailusuario'
		);

		COMMIT TRANSACTION;

		SELECT 
            @nuevoNumeroIndicador AS NumeroIndicador, 
            'Indicador creado exitosamente' AS Mensaje,
            GETDATE() AS FechaCreacion;

	END TRY
	BEGIN CATCH
        ROLLBACK TRANSACTION;
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        
        -- En caso de error, devolver información sobre el error
        SELECT 
            0 AS NumeroIndicador,
            @ErrorMessage AS Mensaje,
            GETDATE() AS FechaCreacion,
            ERROR_NUMBER() AS ErrorNumero,
            ERROR_STATE() AS ErrorEstado,
            ERROR_SEVERITY() AS ErrorSeveridad,
            ERROR_LINE() AS ErrorLinea;
            
        RAISERROR('Error al insertar indicador: %s', 16, 1, @ErrorMessage);
    END CATCH
END;
GO
