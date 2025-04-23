-- Το εισιτήριο ενεργοποιείται όταν σκαναριστεί και δεν μπορεί να ενεργοποιηθεί ξανά

DELIMITER //

CREATE TRIGGER prevent_double_activation
BEFORE UPDATE ON Ticket
FOR EACH ROW
BEGIN
  IF OLD.IsActive = TRUE AND NEW.IsActive = TRUE THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Ticket is already active and cannot be activated again.';
  END IF;
END;
//

DELIMITER ;
