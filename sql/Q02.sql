SELECT 
  P.Performer_id,
  P.Name,
  G.Genre_id AS Genre,
  CASE 
    WHEN EXISTS (
      SELECT 1
      FROM Performance Perf USE INDEX (idx_performance_performer_event)
      JOIN Event E ON Perf.Event_Event_id = E.Event_id
      JOIN Festival F ON E.Festival_Festival_id = F.Festival_id
      WHERE Perf.Performer_id = P.Performer_id
        AND F.Year = 2024
    )
    THEN 'Yes'
    ELSE 'No'
  END AS ParticipatedInFestival2024
FROM Performer P
JOIN Performer_has_Subgenre PS FORCE INDEX (idx_phs_performer_subgenre)
  ON P.Performer_id = PS.Performer_Performer_id
JOIN Subgenre S FORCE INDEX (idx_subgenre_genre_sub)
  ON PS.Subgenre_Subgenre_id = S.Subgenre_id
JOIN Genre G ON S.Genre_Genre_id = G.Genre_id
WHERE G.Genre_id = 'Rock'
GROUP BY P.Performer_id
ORDER BY P.Performer_id ASC;
