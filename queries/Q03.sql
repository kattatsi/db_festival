SELECT 
    a.Artist_id,
    a.Name AS 'Artist Name',
    f.Festival_id AS 'Festival ID',
    COUNT(*) AS 'Warm Up Performances',
FROM 
    Performance pf
JOIN 
    Performance_type pt ON pf.Performance_type_Type = pt.Type
JOIN 
    Performer p ON pf.Performer_id = p.Performer_id
JOIN 
    Artist_has_Performer ahp ON p.Performer_id = ahp.Performer_Performer_id
JOIN 
    Artist a ON ahp.Artist_Artist_id = a.Artist_id
JOIN 
    Event e ON pf.Event_Event_id = e.Event_id
JOIN 
    Festival f ON e.Festival_Festival_id = f.Festival_id
WHERE 
    pt.Type = 'warm up'
GROUP BY 
    a.Artist_id, f.Year
HAVING 
    COUNT(*) > 2
ORDER BY 
    COUNT(*) DESC, f.Year DESC;