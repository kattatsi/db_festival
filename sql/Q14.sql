WITH GenreYearCounts AS (
  SELECT 
    G.Genre_id,
    F.Year,
    COUNT(*) AS AppearanceCount
  FROM Performance P
  JOIN Performer PR ON P.Performer_id = PR.Performer_id
  JOIN Performer_has_Subgenre PS ON PR.Performer_id = PS.Performer_Performer_id
  JOIN Subgenre S ON PS.Subgenre_Subgenre_id = S.Subgenre_id
  JOIN Genre G ON S.Genre_Genre_id = G.Genre_id
  JOIN Event E ON P.Event_Event_id = E.Event_id
  JOIN Festival F ON E.Festival_Festival_id = F.Festival_id
  GROUP BY G.Genre_id, F.Year
)

SELECT 
  g1.Genre_id,
  g1.Year AS Year1,
  g2.Year AS Year2,
  g1.AppearanceCount
FROM GenreYearCounts g1
JOIN GenreYearCounts g2 ON g1.Genre_id = g2.Genre_id AND g2.Year = g1.Year + 1
WHERE g1.AppearanceCount = g2.AppearanceCount AND g1.AppearanceCount >= 3;
