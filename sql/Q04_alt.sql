-- Εναλλακτικό query με FORCE INDEX
-- Υποθέτουμε Performer_id = 9

SELECT 
  P.Performer_id,
  P.Name,
  ROUND(AVG(R.ArtistPerformance), 2) AS AvgArtistPerformance,
  ROUND(AVG(R.OverallImpression), 2) AS AvgOverallImpression
FROM Performer P
JOIN Performance PF FORCE INDEX (fk_Performance_Band1_idx) 
  ON P.Performer_id = PF.Performer_id
JOIN Rating R FORCE INDEX (fk_Rating_Performance1_idx) 
  ON R.Performance_Performance_id = PF.Performance_id
WHERE P.Performer_id = 9
GROUP BY P.Performer_id;
