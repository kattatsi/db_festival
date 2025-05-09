SELECT 
  R.Visitor_Visitor_id AS Visitor_id,
  V.Name AS 'Visitor Name',
  R.Performance_Performance_id AS Performance_id,
  ROUND((
    AVG(R.ArtistPerformance) +
    AVG(R.SoundAndLighting) +
    AVG(R.StagePresence) +
    AVG(R.Organization) +
    AVG(R.OverallImpression)
  ) / 5, 2) AS 'Average Rating'
FROM Rating R FORCE INDEX (idx_rating_visitor_perf)
JOIN Visitor V ON R.Visitor_Visitor_id = V.Visitor_id
WHERE R.Visitor_Visitor_id = 120
GROUP BY R.Visitor_Visitor_id, V.Name, R.Performance_Performance_id;
