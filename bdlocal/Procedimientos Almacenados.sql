
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
--Procedimiento almacenado para llenar la tabla intermedia represenvisualporindicador
CREATE PROCEDURE ModificarRepresentacionVisualPorIndicador
    @fkidindicador INT,
    @fkrepresentacionvisual INT,
	@newIdIndicador INT = Null,
	@newIdRepresentacionVisual INT = Null
AS
	BEGIN TRANSACTION
		BEGIN TRY
			UPDATE represenvisualporindicador
			SET fkidindicador = @newIdIndicador, fkidrepresenvisual = @newIdRepresentacionVisual
			WHERE fkidindicador = @fkidindicador AND fkidrepresenvisual = @fkrepresentacionvisual;
			SELECT 1 AS 'Status','Se actualizo la tabla' AS 'Respuesta'
	COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);
			SET @ErrorMessage = ERROR_MESSAGE();
			SELECT 0 AS 'Status', @ErrorMessage AS 'Respuesta'
	ROLLBACK TRANSACTION
	END CATCH