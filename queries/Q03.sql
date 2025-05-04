SELECT 
    p.Performer_id,
    p.Name AS 'Performer Name',
    f.Festival_id,
    COUNT(*) AS 'Warm Up Performances Count'
FROM 
    Performance pf
JOIN 
    Performance_type pt ON pf.Performance_type_Type = pt.Type
JOIN 
    Event e ON pf.Event_Event_id = e.Event_id
JOIN 
    Festival f ON e.Festival_Festival_id = f.Festival_id
JOIN 
    Performer p ON pf.Performer_id = p.Performer_id
WHERE 
    pt.Type = 'warm up'
GROUP BY 
    p.Performer_id, f.Festival_id
HAVING 
    COUNT(*) > 2
ORDER BY 
    COUNT(*) DESC;
