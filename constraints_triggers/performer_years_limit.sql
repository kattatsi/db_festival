-- Ένας performer δεν συμμετέχει για >3 συνεχόμενα έτη

DELIMITER //

CREATE TRIGGER trg_Check_Performer_3_Years
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE participation_years INT;

    -- Μετράμε σε πόσα ΔΙΑΦΟΡΕΤΙΚΑ έτη έχει ήδη συμμετάσχει ο Performer τα τελευταία 3 χρόνια
    SELECT COUNT(DISTINCT YEAR(e.Date)) INTO participation_years
    FROM Performance p
    JOIN Event e ON e.Event_id = p.Event_Event_id
    WHERE p.Performer_id = NEW.Performer_id
      AND YEAR(e.Date) >= YEAR(CURDATE()) - 2  -- τα τελευταία 3 έτη (τρέχον + 2 πίσω)

    ;

    -- Αν έχει συμμετάσχει ήδη σε 3, δεν επιτρέπεται άλλη εμφάνιση φέτος
    IF participation_years >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Performer cannot participate more than 3 consecutive years.';
    END IF;
END;
//

DELIMITER ;