SELECT 
    f.Year AS 'Year',
    pm.Method AS 'Payment Method',
    SUM(t.Price) AS 'Total Revenue'
FROM 
    Ticket t
JOIN 
    Event e ON t.Event_Event_id = e.Event_id
JOIN 
    Festival f ON e.Festival_Festival_id = f.Festival_id
JOIN 
    Payment_method pm ON t.Payment_method_Method = pm.Method
WHERE 
    t.Visitor_Visitor_id IS NOT NULL
GROUP BY 
    f.Year, pm.Method
ORDER BY 
    f.Year DESC, SUM(t.Price) DESC;