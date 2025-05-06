SELECT 
    v.Name AS Visitor_Name,
    p.Name AS Performer_Name,
    SUM(r.ArtistPerformance + r.OverallImpression) AS Total_Score
FROM 
    Rating r
JOIN 
    Visitor v ON r.Visitor_Visitor_id = v.Visitor_id
JOIN 
    Performance pf ON r.Performance_Performance_id = pf.Performance_id
JOIN 
    Performer p ON pf.Performer_id = p.Performer_id
GROUP BY 
    v.Name, p.Name
ORDER BY 
    Total_Score DESC
LIMIT 5;
