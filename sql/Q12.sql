SELECT 
  DATE(E.Date) AS FestivalDate,
  S.Role_Name AS StaffRole,
  COUNT(DISTINCT S.Staff_id) AS StaffCount
FROM Event_has_Staff EHS
JOIN Staff S ON EHS.Staff_Staff_id = S.Staff_id
JOIN Event E ON EHS.Event_Event_id = E.Event_id
GROUP BY FestivalDate, StaffRole
ORDER BY FestivalDate, StaffRole;
