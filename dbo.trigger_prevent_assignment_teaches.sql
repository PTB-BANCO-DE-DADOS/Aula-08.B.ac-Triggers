--Questão 01. Crie uma Trigger denominada dbo.trigger_prevent_assignment_teaches para impedir que aulas sejam atribuidas a um instrutor que já possui 2 ou mais atribuições no ano.
CREATE OR ALTER TRIGGER dbo.trigger_prevent_assignment_teaches
ON teaches
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN (
            SELECT ID, year, COUNT(*) AS qtd
            FROM teaches
            GROUP BY ID, year
        ) t ON i.ID = t.ID AND i.year = t.year
        WHERE t.qtd >= 2
    )
    BEGIN
        RAISERROR(N'Este instrutor já possui 2 ou mais aulas atribuídas neste ano.', 16, 1);
        RETURN;
    END;

    INSERT INTO teaches (ID, course_id, sec_id, semester, year)
    SELECT ID, course_id, sec_id, semester, year
    FROM inserted;
END;
