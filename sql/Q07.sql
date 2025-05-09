SELECT 
    f.Festival_id,
    ROUND(AVG(s.Experience_Level), 2) AS 'Average Technician Experience Level'
FROM 
    Festival f
JOIN 
    Event e ON f.Festival_id = e.Festival_Festival_id
JOIN 
    Event_has_Staff ehs ON e.Event_id = ehs.Event_Event_id
JOIN 
    Staff s ON ehs.Staff_Staff_id = s.Staff_id
JOIN 
    Role r ON s.Role_Name = r.Name
WHERE 
    r.Name IN ('Sound Engineer', 'Lighting Technician', 'Stage Manager')
GROUP BY 
    f.Festival_id, f.Year
ORDER BY 
    AVG(s.Experience_Level) ASC
LIMIT 1;  