SELECT 
  DATE(E.Date) AS FestivalDate,
  S.Role_Name AS StaffRole,
  COUNT(DISTINCT S.Staff_id) AS StaffCount
FROM Event_has_Staff EHS
JOIN Staff S USE INDEX (idx_staff_role_staffid) ON EHS.Staff_Staff_id = S.Staff_id
JOIN Event E USE INDEX (fk_Event_Festival1_idx) ON EHS.Event_Event_id = E.Event_id
GROUP BY FestivalDate, StaffRole
ORDER BY FestivalDate, StaffRole;
