SELECT 
  S.Staff_id,
  S.Name
FROM Staff S
WHERE S.Role_Name IN (
    'Artist Liaison',
    'Cleanup Crew',
    'Ticket Scanner',
    'Vendor Coordinator'
)
  AND S.Staff_id NOT IN (
    SELECT EHS.Staff_Staff_id
    FROM Event_has_Staff EHS
    JOIN Event E ON E.Event_id = EHS.Event_Event_id
    WHERE DATE(E.Date) = '2025-06-20'
  );
