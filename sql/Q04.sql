-- Υποθέτουμε Performer_id = 9

SELECT 
  P.Performer_id,
  P.Name AS 'Performer Name',
  ROUND((
    SELECT AVG(R1.ArtistPerformance)
    FROM Rating R1
    JOIN Performance PF1 ON PF1.Performance_id = R1.Performance_Performance_id
    WHERE PF1.Performer_id = P.Performer_id
  ), 2) AS 'Average Artist Performance',
  ROUND((
    SELECT AVG(R2.OverallImpression)
    FROM Rating R2
    JOIN Performance PF2 ON PF2.Performance_id = R2.Performance_Performance_id
    WHERE PF2.Performer_id = P.Performer_id
  ), 2) AS 'Average Overall Impression'
FROM Performer P
WHERE P.Performer_id = 9;
