-- CTE για solo καλλιτέχνες (όσοι Performer εμφανίζονται μόνο μία φορά στον πίνακα Artist_has_Performer)
WITH Solo_Artists AS (
    SELECT 
        ahp.Performer_Performer_id AS Performer_id,
        a.BirthDate
    FROM 
        Artist_has_Performer ahp
    JOIN 
        Artist a ON ahp.Artist_Artist_id = a.Artist_id
    WHERE 
        ahp.Performer_Performer_id IN (
            SELECT Performer_Performer_id
            FROM Artist_has_Performer
            GROUP BY Performer_Performer_id
            HAVING COUNT(*) = 1
        )
),

-- CTE για performers κάτω των 30 ετών, με σωστό υπολογισμό ηλικίας ανάλογα αν είναι solo ή συγκρότημα
Young_Performers AS (
    SELECT 
        p.Performer_id,
        p.Name,
        CASE
            WHEN sa.BirthDate IS NOT NULL THEN TIMESTAMPDIFF(YEAR, sa.BirthDate, CURDATE())
            ELSE TIMESTAMPDIFF(YEAR, p.FormationDate, CURDATE())
        END AS Age
    FROM 
        Performer p
    LEFT JOIN 
        Solo_Artists sa ON p.Performer_id = sa.Performer_id
    WHERE 
        (
            (sa.BirthDate IS NOT NULL AND TIMESTAMPDIFF(YEAR, sa.BirthDate, CURDATE()) < 30)
            OR
            (sa.BirthDate IS NULL AND TIMESTAMPDIFF(YEAR, p.FormationDate, CURDATE()) < 30)
        )
),

-- Τελικός πίνακας με καταμέτρηση συμμετοχών
Performer_Counts AS (
    SELECT 
        yp.Performer_id,
        yp.Name AS 'Performer Name',
        yp.Age AS 'Age',
        COUNT(perf.Performance_id) AS 'Performance Count'
    FROM 
        Young_Performers yp
    JOIN 
        Performance perf ON yp.Performer_id = perf.Performer_id
    GROUP BY 
        yp.Performer_id, yp.Name, yp.Age
)

-- Προβολή σε μορφή leaderboard με ranking
SELECT 
    RANK() OVER (ORDER BY `Performance Count` DESC) AS `Rank`,
    `Performer Name`,
    `Age`,
    `Performance Count`
FROM 
    Performer_Counts;
