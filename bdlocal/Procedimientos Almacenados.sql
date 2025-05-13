
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

		-- Validar que la combinación email - idRol no exista ya
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

		-- Validar que la combinación email - idRol exista
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
