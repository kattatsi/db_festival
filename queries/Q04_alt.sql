-- Υποθέτουμε Artist_id = 12 (αλλαγή αν θέλουμε)

SELECT 
  A.Artist_id,
  A.Name,
  ROUND(AVG(R.ArtistPerformance), 2) AS AvgArtistPerformance,
  ROUND(AVG(R.OverallImpression), 2) AS AvgOverallImpression
FROM Artist A
JOIN Artist_has_Performer AP FORCE INDEX (PRIMARY) ON A.Artist_id = AP.Artist_Artist_id
JOIN Performance P FORCE INDEX (fk_Performance_Band1_idx) ON AP.Performer_Performer_id = P.Performer_id
JOIN Rating R FORCE INDEX (fk_Rating_Performance1_idx) ON R.Performance_Performance_id = P.Performance_id
WHERE A.Artist_id = 12
GROUP BY A.Artist_id;
