SET @year := 2024;

SET @sql := CONCAT("
  SELECT 
    P.Performer_id,
    P.Name AS 'Performer Name',
    G.Genre_id AS Genre,
    CASE 
      WHEN EXISTS (
        SELECT 1
        FROM Performance Perf
        JOIN Event E ON Perf.Event_Event_id = E.Event_id
        JOIN Festival F ON E.Festival_Festival_id = F.Festival_id
        WHERE Perf.Performer_id = P.Performer_id
          AND F.Year = ", @year, "
      )
      THEN 'Yes'
      ELSE 'No'
    END AS 'Participated In Festival ", @year, "'
  FROM Performer P
  JOIN Performer_has_Subgenre PS ON P.Performer_id = PS.Performer_Performer_id
  JOIN Subgenre S ON PS.Subgenre_Subgenre_id = S.Subgenre_id
  JOIN Genre G ON S.Genre_Genre_id = G.Genre_id
  WHERE G.Genre_id = 'Rock'
  GROUP BY P.Performer_id
  ORDER BY P.Performer_id ASC;
");

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
