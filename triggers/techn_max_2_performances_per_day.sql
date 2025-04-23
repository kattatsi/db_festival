-- Κάθε τεχνικός μπορεί να υποστηρίζει έως 2 εμφανίσεις την ίδια ημέρα

DELIMITER //

CREATE TRIGGER trg_Limit_Staff_Performances
BEFORE INSERT ON Staff_has_Performance
FOR EACH ROW
BEGIN
  DECLARE num_performances INT;
  SELECT COUNT(*) INTO num_performances 
  FROM Staff_has_Performance
  WHERE Staff_Staff_id = NEW.Staff_Staff_id AND Date = NEW.Date;

  IF num_performances >= 2 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'A technician cannot support more than 2 performances per day.';
  END IF;
END;
//

DELIMITER ;