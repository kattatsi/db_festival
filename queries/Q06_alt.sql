-- Εναλλακτικό query με FORCE INDEX
SELECT 
  V.Visitor_id,
  E.Event_id,
  ROUND(AVG(R.ArtistPerformance), 2) AS AvgArtistPerformance,
  ROUND(AVG(R.OverallImpression), 2) AS AvgOverallImpression
FROM Visitor V
JOIN Rating R FORCE INDEX (fk_Rating_Visitor1_idx) ON V.Visitor_id = R.Visitor_Visitor_id
JOIN Performance P FORCE INDEX (fk_Performance_Event1_idx) ON R.Performance_Performance_id = P.Performance_id
JOIN Event E FORCE INDEX (PRIMARY) ON P.Event_Event_id = E.Event_id
WHERE V.Visitor_id = 7
GROUP BY V.Visitor_id, E.Event_id;