SELECT 
    main.Visitor_Visitor_id,
    main.Visitor_Name,
    main.Year,
    main.Performance_Count,
    (
        SELECT GROUP_CONCAT(other.Visitor_Name)
        FROM (
            SELECT 
                t2.Visitor_Visitor_id,
                v2.Name AS Visitor_Name,
                YEAR(e2.Date) AS Year,
                COUNT(DISTINCT p2.Performance_id) AS Performance_Count
            FROM 
                Ticket t2
            JOIN 
                Visitor v2 ON t2.Visitor_Visitor_id = v2.Visitor_id
            JOIN 
                Event e2 ON t2.Event_Event_id = e2.Event_id
            JOIN 
                Performance p2 ON e2.Event_id = p2.Event_Event_id
            WHERE 
                t2.IsActive = TRUE
            GROUP BY 
                t2.Visitor_Visitor_id, v2.Name, YEAR(e2.Date)
            HAVING 
                COUNT(DISTINCT p2.Performance_id) > 3
        ) AS other
        WHERE 
            other.Performance_Count = main.Performance_Count
            AND other.Year = main.Year
            AND other.Visitor_Visitor_id != main.Visitor_Visitor_id
    ) AS Visitors_With_Same_Count
FROM 
    (
        SELECT 
            t.Visitor_Visitor_id,
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
            Performance p ON e.Event_id = p.Event_Event_id
        WHERE 
            t.IsActive = TRUE
        GROUP BY 
            t.Visitor_Visitor_id, v.Name, YEAR(e.Date)
        HAVING 
            COUNT(DISTINCT p.Performance_id) > 3
    ) AS main
ORDER BY 
    main.Performance_Count DESC, main.Year;