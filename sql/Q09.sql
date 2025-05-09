SELECT 
    vc.Year,
    vc.Performance_Count,
    GROUP_CONCAT(vc.Visitor_Name ORDER BY vc.Visitor_Name SEPARATOR ', ') AS Visitors
FROM (
    SELECT 
        v.Name AS Visitor_Name,
        YEAR(e.Date) AS Year,
        COUNT(DISTINCT p.Performance_id) AS Performance_Count
    FROM 
        Ticket t
    JOIN 
        Visitor v ON t.Visitor_Visitor_id = v.Visitor_id
    JOIN 
        Event e ON t.Event_Event_id = e.Event_id
    JOIN 
        Performance p USE INDEX (idx_performance_performer_event) ON e.Event_id = p.Event_Event_id
    WHERE 
        t.IsActive = TRUE
    GROUP BY 
        t.Visitor_Visitor_id, v.Name, YEAR(e.Date)
    HAVING 
        COUNT(DISTINCT p.Performance_id) > 3
) AS vc
GROUP BY 
    vc.Year, vc.Performance_Count
ORDER BY 
    vc.Performance_Count DESC, vc.Year;
