-- Trigger για να επιτρέπει αξιολόγηση μόνο σε επισκέπτες με ενεργοποιημένο εισιτήριο

DROP TRIGGER IF EXISTS trg_Rating_OnlyWithActiveTicket;

DELIMITER //

CREATE TRIGGER trg_Rating_OnlyWithActiveTicket
BEFORE INSERT ON Rating
FOR EACH ROW
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Ticket
    WHERE Visitor_id = NEW.Visitor_id AND IsActive = TRUE
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Only visitors with an active ticket can rate a performance.';
  END IF;
END;
//

DELIMITER ;