SELECT 
  V.Visitor_id,
  E.Event_id,
  ROUND(AVG(R.ArtistPerformance), 2) AS AvgArtistPerformance,
  ROUND(AVG(R.OverallImpression), 2) AS AvgOverallImpression
FROM Visitor V
JOIN Rating R ON V.Visitor_id = R.Visitor_Visitor_id
JOIN Performance P ON R.Performance_Performance_id = P.Performance_id
JOIN Event E ON P.Event_Event_id = E.Event_id
WHERE V.Visitor_id = 7
GROUP BY V.Visitor_id, E.Event_id;