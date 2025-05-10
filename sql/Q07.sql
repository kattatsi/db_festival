SELECT 
    f.Festival_id,
    AVG(s.Experience_Level) AS 'Average Technician Experience Level'
FROM 
    Festival f
JOIN 
    Event e ON f.Festival_id = e.Festival_Festival_id
JOIN 
    Event_has_Staff ehs ON e.Event_id = ehs.Event_Event_id
JOIN 
    Staff s ON ehs.Staff_Staff_id = s.Staff_id
WHERE s.Role_Name IN ('Sound Engineer', 'Lighting Technician', 'Stage Manager')
GROUP BY 
    f.Festival_id
ORDER BY 
    AVG(s.Experience_Level) ASC
LIMIT 1;  