-- Διάλειμμα 5–30 λεπτών μεταξύ εμφανίσεων

DELIMITER //

CREATE TRIGGER trg_Check_Performance_Break
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE prev_end DATETIME;
    DECLARE break_minutes INT;

    -- Βρες την ώρα λήξης της προηγούμενης εμφάνισης στη σκηνή
    SELECT MAX(ADDTIME(StartTime, SEC_TO_TIME(Duration * 60))) INTO prev_end
    FROM Performance
    WHERE Event_id = NEW.Event_id AND Stage_id = NEW.Stage_id
    AND StartTime < NEW.StartTime;

    -- Υπολόγισε το διάστημα από τη λήξη της προηγούμενης
    IF prev_end IS NOT NULL THEN
        SET break_minutes = TIMESTAMPDIFF(MINUTE, prev_end, NEW.StartTime);

        IF break_minutes < 5 OR break_minutes > 30 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Break between performances must be between 5 and 30 minutes.';
        END IF;
    END IF;
END;
//

DELIMITER ;