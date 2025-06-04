--Questão 01. Crie uma Trigger denominada dbo.trigger_prevent_assignment_teaches para impedir que aulas sejam atribuidas a um instrutor que já possui 2 ou mais atribuições no ano.
CREATE TRIGGER dbo.trigger_prevent_assignment_teaches
ON dbo.teaches
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar cada linha que está sendo inserida
    IF EXISTS (
        SELECT i.ID, i.year
        FROM inserted i
        JOIN teaches t
            ON i.ID = t.ID AND i.year = t.year
        GROUP BY i.ID, i.year
        HAVING COUNT(t.course_id) + COUNT(i.course_id) > 2
    )
    BEGIN
        -- Gerar erro e impedir inserção
        RAISERROR ('Este instrutor já possui 2 ou mais atribuições neste ano.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Se não violar, então faz o insert normalmente
    INSERT INTO teaches (ID, course_id, sec_id, semester, year)
    SELECT ID, course_id, sec_id, semester, year
    FROM inserted;
END;
