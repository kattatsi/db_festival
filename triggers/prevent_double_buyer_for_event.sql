-- Αποτρέπει αγοραστή να πάρει δεύτερο εισιτήριο για το ίδιο event



DELIMITER //

CREATE TRIGGER prevent_duplicate_buyer_for_event
BEFORE INSERT ON Buyer_has_Ticket
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM Ticket
    WHERE Visitor_Visitor_id = NEW.Buyer_BuyerVisitor_id
      AND Event_Event_id = NEW.Ticket_Event_Event_id
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Buyer already has a ticket for this event.';
  END IF;
END;
//

DELIMITER ;