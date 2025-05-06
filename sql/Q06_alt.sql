-- Εναλλακτικό query με FORCE INDEX

SELECT 
  V.Visitor_id,
  P.Performance_id,
  ROUND((
    AVG(R.ArtistPerformance) +
    AVG(R.SoundAndLighting) +
    AVG(R.StagePresence) +
    AVG(R.Organization) +
    AVG(R.OverallImpression)
  ) / 5, 2) AS TotalAvgRating
FROM Visitor V
JOIN Rating R FORCE INDEX (fk_Rating_Visitor1_idx) ON V.Visitor_id = R.Visitor_Visitor_id
JOIN Performance P FORCE INDEX (PRIMARY) ON R.Performance_Performance_id = P.Performance_id
WHERE V.Visitor_id = 5
GROUP BY V.Visitor_id, P.Performance_id
ORDER BY P.Performance_id;
