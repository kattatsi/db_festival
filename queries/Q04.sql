-- Υποθέτουμε Performer_id = 9

SELECT 
  P.Performer_id,
  P.Name,
  ROUND(AVG(R.ArtistPerformance), 2) AS AvgArtistPerformance,
  ROUND(AVG(R.OverallImpression), 2) AS AvgOverallImpression
FROM Performer P
JOIN Performance PF ON P.Performer_id = PF.Performer_id
JOIN Rating R ON R.Performance_Performance_id = PF.Performance_id
WHERE P.Performer_id = 9
GROUP BY P.Performer_id;
