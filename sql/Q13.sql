SELECT 
    p.Performer_id,
    pf.Name AS Performer_Name,
    COUNT(DISTINCT loc.Continent_Name) AS Continent_Count
FROM 
    Performance p
JOIN 
    Performer pf ON p.Performer_id = pf.Performer_id
JOIN 
    Event e USE INDEX (fk_Event_Festival1_idx) ON p.Event_Event_id = e.Event_id
JOIN 
    Festival f ON e.Festival_Festival_id = f.Festival_id
JOIN 
    Location loc ON f.Location_Location_id = loc.Location_id
GROUP BY 
    p.Performer_id, pf.Name
HAVING 
    COUNT(DISTINCT loc.Continent_Name) >= 3
ORDER BY 
    Continent_Count DESC, Performer_Name;