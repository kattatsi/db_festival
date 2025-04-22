-- Κάθε festival ≤ 13 ώρες/ημέρα

DELIMITER //

CREATE TRIGGER trg_Check_Festival_Day_Duration
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE total_day_duration INT;
    DECLARE event_date DATE;

    SELECT Date INTO event_date
    FROM Event
    WHERE Event_id = NEW.Event_id;

    SELECT IFNULL(SUM(p.Duration), 0) INTO total_day_duration
    FROM Performance p
    JOIN Event e ON e.Event_id = p.Event_id
    WHERE e.Date = event_date;

    IF total_day_duration + NEW.Duration > 780 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Total performance time on this day exceeds 13 hours (780 minutes)';
    END IF;
END;
//

DELIMITER ;