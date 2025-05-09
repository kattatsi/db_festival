WITH Performance_Counts AS (
    SELECT 
        p.Performer_id,
        pf.Name AS Performer_Name,
        COUNT(*) AS Total_Performances
    FROM 
        Performance p USE INDEX (idx_performance_performer_event)
    JOIN 
        Performer pf ON p.Performer_id = pf.Performer_id
    GROUP BY 
        p.Performer_id, pf.Name
),

Top_Performer AS (
    SELECT 
        Performer_id,
        Performer_Name,
        Total_Performances
    FROM 
        Performance_Counts
    ORDER BY 
        Total_Performances DESC
    LIMIT 1
)

SELECT 
    pc.Performer_id,
    pc.Performer_Name,
    pc.Total_Performances
FROM 
    Performance_Counts pc
CROSS JOIN 
    Top_Performer tp
WHERE 
    (tp.Total_Performances - pc.Total_Performances) >= 5
    AND pc.Performer_id != tp.Performer_id  -- Εξαιρεί τον ίδιο τον top καλλιτέχνη
ORDER BY 
    pc.Total_Performances DESC;