SELECT 
    a.Artist_id,
    a.Name AS 'Artist Name',
    TIMESTAMPDIFF(YEAR, a.BirthDate, CURDATE()) AS 'Age',
    COUNT(p.Performance_id) AS 'Performance Count',
FROM 
    Artist a
JOIN 
    Artist_has_Performer ahp ON a.Artist_id = ahp.Artist_Artist_id
JOIN 
    Performance p ON ahp.Performer_Performer_id = p.Performer_id
WHERE 
    TIMESTAMPDIFF(YEAR, a.BirthDate, CURDATE()) < 30
GROUP BY 
    a.Artist_id, a.Name, a.StageName, a.BirthDate
ORDER BY 
    COUNT(p.Performance_id) DESC
LIMIT 10;  