SELECT 
  LEAST(G1.Genre_id, G2.Genre_id) AS Genre1,
  GREATEST(G1.Genre_id, G2.Genre_id) AS Genre2,
  COUNT(DISTINCT F.Festival_id) AS FestivalAppearances
FROM Artist A
JOIN Artist_has_Performer AP ON A.Artist_id = AP.Artist_Artist_id
JOIN Performer P ON AP.Performer_Performer_id = P.Performer_id
JOIN Performer_has_Subgenre PS1 ON P.Performer_id = PS1.Performer_Performer_id
JOIN Subgenre S1 ON PS1.Subgenre_Subgenre_id = S1.Subgenre_id
JOIN Genre G1 ON S1.Genre_Genre_id = G1.Genre_id
JOIN Performer_has_Subgenre PS2 ON P.Performer_id = PS2.Performer_Performer_id
JOIN Subgenre S2 ON PS2.Subgenre_Subgenre_id = S2.Subgenre_id
JOIN Genre G2 ON S2.Genre_Genre_id = G2.Genre_id
-- εμφάνιση σε φεστιβάλ
JOIN Performance PR ON PR.Performer_id = P.Performer_id
JOIN Event E ON PR.Event_Event_id = E.Event_id
JOIN Festival F ON E.Festival_Festival_id = F.Festival_id
WHERE G1.Genre_id < G2.Genre_id
GROUP BY Genre1, Genre2
ORDER BY FestivalAppearances DESC
LIMIT 3;
