-- Ένας performer δεν εμφανίζεται σε 2 σκηνές ταυτόχρονα

DELIMITER //

CREATE TRIGGER trg_Check_Performer_Overlap
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT;

    SELECT COUNT(*) INTO overlap_count
    FROM Performance
    WHERE Performer_id = NEW.Performer_id
      AND (
        -- Ελέγχει αν η νέα εμφάνιση ξεκινά μέσα σε υπάρχουσα
        (NEW.StartTime BETWEEN StartTime AND ADDTIME(StartTime, SEC_TO_TIME(Duration * 60)))
        -- Ή αν η υπάρχουσα ξεκινά μέσα στη νέα
        OR
        (StartTime BETWEEN NEW.StartTime AND ADDTIME(NEW.StartTime, SEC_TO_TIME(NEW.Duration * 60)))
      );

    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Performer cannot perform in two places at the same time.';
    END IF;
END;
//

DELIMITER ;