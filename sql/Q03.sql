SELECT 
    p.Performer_id,
    p.Name AS 'Performer Name',
    f.Festival_id,
    COUNT(*) AS 'Warm Up Performances Count'
FROM 
    Performance pf USE INDEX (idx_performance_performer_event)
    JOIN Event e USE INDEX (fk_Event_Festival1_idx) ON pf.Event_Event_id = e.Event_id
    JOIN Festival f ON e.Festival_Festival_id = f.Festival_id
    JOIN Performer p ON pf.Performer_id = p.Performer_id
WHERE 
    pf.Performance_type_Type = 'warm up'
GROUP BY 
    p.Performer_id, f.Festival_id
HAVING 
    COUNT(*) > 2
ORDER BY 
    COUNT(*) DESC;
