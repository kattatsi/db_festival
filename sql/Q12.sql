SELECT 
  DATE(e.Date) AS 'Festival Date',
  COUNT(DISTINCT s.Staff_id) AS 'Staff Count',
  GROUP_CONCAT(DISTINCT s.Name ORDER BY s.Name SEPARATOR ', ') AS 'Staff Members',
  CASE 
    WHEN s.Role_Name IN ('Lighting Technician', 'Sound Engineer', 'Stage Manager') THEN 'Technical'
    WHEN s.Role_Name IN ('Security', 'First Aid Responder') THEN 'Security'
    WHEN s.Role_Name IN ('Artist Liaison', 'Cleanup Crew', 'Parking Attendant', 'Ticket Scanner', 'Vendor Coordinator') THEN 'Support'
    ELSE 'Other'
  END AS 'Staff Role'
FROM Event e
JOIN Event_has_Staff es ON es.Event_Event_id = e.Event_id
JOIN Staff s ON s.Staff_id = es.Staff_Staff_id
GROUP BY `Festival Date`, `Staff Role`
ORDER BY `Festival Date`, `Staff Role`;
