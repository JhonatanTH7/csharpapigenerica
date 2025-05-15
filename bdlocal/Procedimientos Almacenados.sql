
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

--Procedimiento almacenado para BORRAR la tabla intermedia represenvisualporindicador
CREATE PROCEDURE BorrarRepresentacionVisualPorIndicador
    @fkidindicador INT,
    @fkrepresentacionvisual INT
AS
	BEGIN TRANSACTION
		BEGIN TRY
			DELETE FROM represenvisualporindicador
			WHERE fkidindicador = @fkidindicador AND fkidrepresenvisual = @fkrepresentacionvisual;
			SELECT 1 AS 'Status','Se borro en tabla: RepresentacionVisualPorIndicador' AS 'Respuesta'
	COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);
			SET @ErrorMessage = ERROR_MESSAGE();
			SELECT 0 AS 'Status', @ErrorMessage AS 'Respuesta'
	ROLLBACK TRANSACTION
	END CATCH

GO 
--Procedimiento almacenado para AGREGAR la tabla intermedia represenvisualporindicador
CREATE PROCEDURE AgregarRepresentacionVisualPorIndicador
    @fkidindicador INT,
    @fkrepresentacionvisual INT
AS
	BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO represenvisualporindicador
			VALUES (@fkidindicador,@fkrepresentacionvisual);
			SELECT 1 AS 'Status','Ingreso el dato' AS 'Respuesta'
	COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);
			SET @ErrorMessage = ERROR_MESSAGE();
			SELECT 0 AS 'Status', @ErrorMessage AS 'Respuesta'
	ROLLBACK TRANSACTION
	END CATCH
GO
--Procedimiento almacenado para BORRAR la tabla intermedia ResponsablesPorIndicador
CREATE PROCEDURE BorrarResponsablesPorIndicador
    @fkidresponsable VARCHAR(50),
    @fkidindicador INT
AS
	BEGIN TRANSACTION
		BEGIN TRY
			DELETE FROM responsablesporindicador
			WHERE fkidresponsable = @fkidresponsable AND fkidindicador = @fkidindicador;
			SELECT 1 AS 'Status','Se borro en tabla: ResponsablesPorIndicador' AS 'Respuesta'
	COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);
			SET @ErrorMessage = ERROR_MESSAGE();
			SELECT 0 AS 'Status', @ErrorMessage AS 'Respuesta'
	ROLLBACK TRANSACTION
	END CATCH
GO
--Procedimiento almacenado para AGREGAR la tabla intermedia ResponsablesPorIndicador
CREATE PROCEDURE AgregarResponsablesPorIndicador
    @fkidresponsable VARCHAR(50),
    @fkidindicador INT
AS
	BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO responsablesporindicador
			VALUES (@fkidresponsable,@fkidindicador,GETDATE());
			SELECT 1 AS 'Status','Se Ingreso en tabla ResponsablesPorIndicador' AS 'Respuesta'
	COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);
			SET @ErrorMessage = ERROR_MESSAGE();
			SELECT 0 AS 'Status', @ErrorMessage AS 'Respuesta'
	ROLLBACK TRANSACTION
	END CATCH
GO
--Procedimiento almacenado para BORRAR la tabla intermedia ACTOR
CREATE PROCEDURE Borraractor
    @id VARCHAR(50)
AS
	BEGIN TRANSACTION
		BEGIN TRY
			DELETE FROM actor
			WHERE id = @id;
			SELECT 1 AS 'Status','Se borro en tabla: ACTOR' AS 'Respuesta'
	COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);
			SET @ErrorMessage = ERROR_MESSAGE();
			SELECT 0 AS 'Status', @ErrorMessage AS 'Respuesta'
	ROLLBACK TRANSACTION
	END CATCH
GO
--Procedimiento almacenado para AGREGAR la tabla intermedia ResponsablesPorIndicador
CREATE PROCEDURE AgregarActor
    @id VARCHAR(50),
	@nombre varchar(200),
	@fkidtipoactor int
AS
	BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO responsablesporindicador
			VALUES (@id,@nombre,@fkidtipoactor);
			SELECT 1 AS 'Status','Se Ingresaron los datos en la tabla: ACTOR exitosamente' AS 'Respuesta'
	COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);
			SET @ErrorMessage = ERROR_MESSAGE();
			SELECT 0 AS 'Status', @ErrorMessage AS 'Respuesta'
	ROLLBACK TRANSACTION
	END CATCH
GO
--Procedimiento almacenado para AGREGAR la tabla intermedia ResponsablesPorIndicador
CREATE PROCEDURE AgregarVariablesporIndicador
	@id INT,
	@fkidvariable int,
	@fkidindicador int,
	@dato float,
	@fkemailusuario varchar(100),
	@fechadato datetime

AS
	BEGIN TRANSACTION
		BEGIN TRY
			INSERT INTO VariablesporIndicador
			VALUES (@fkidvariable,@fkidindicador,@dato,@fkemailusuario,@fechadato);
			SELECT 1 AS 'Status','Se Ingreso en tabla:  FuentesPorIndicador' AS 'Respuesta'
	COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);
			SET @ErrorMessage = ERROR_MESSAGE();
			SELECT 0 AS 'Status', @ErrorMessage AS 'Respuesta'
	ROLLBACK TRANSACTION
	END CATCH