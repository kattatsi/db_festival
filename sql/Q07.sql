SELECT 
    f.Festival_id,
    ROUND(AVG(s.Experience_Level), 2) AS 'Average Technician Experience Level'
FROM 
    Festival f
JOIN 
    Event e ON f.Festival_id = e.Festival_Festival_id
JOIN 
    Event_has_Staff ehs USE INDEX (idx_event_staff) ON e.Event_id = ehs.Event_Event_id
JOIN 
    Staff s USE INDEX (idx_staff_role_staffid) ON ehs.Staff_Staff_id = s.Staff_id
JOIN 
    Role r ON s.Role_Name = r.Name
WHERE 
    r.Name IN ('Sound Engineer', 'Lighting Technician')
GROUP BY 
    f.Festival_id, f.Year
ORDER BY 
    AVG(s.Experience_Level) ASC
LIMIT 1;  