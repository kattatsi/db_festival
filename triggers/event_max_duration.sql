-- Κάθε event ≤ 12 ώρες

DELIMITER //

CREATE TRIGGER trg_Check_Event_Duration
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE total_duration INT;

    SELECT IFNULL(SUM(Duration), 0) INTO total_duration
    FROM Performance
    WHERE Event_id = NEW.Event_id;

    IF total_duration + NEW.Duration > 720 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Total performance duration in this event exceeds 12 hours (720 minutes)';
    END IF;
END;
//

DELIMITER ;