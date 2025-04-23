-- Μπλοκάρει resale αν το εισιτήριο είναι ενεργό


DELIMITER //

CREATE TRIGGER prevent_resale_of_active_ticket
BEFORE INSERT ON ResaleQueue
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM Ticket
    WHERE Ticket_id = NEW.Ticket_Ticket_id AND IsActive = TRUE
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot resell an active ticket.';
  END IF;
END;
//

DELIMITER ;