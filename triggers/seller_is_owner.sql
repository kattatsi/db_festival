DELIMITER //

CREATE TRIGGER check_resale_seller_is_owner
BEFORE INSERT ON ResaleQueue
FOR EACH ROW
BEGIN
  DECLARE owner_id INT;

  SELECT Visitor_Visitor_id INTO owner_id
  FROM Ticket
  WHERE Ticket_id = NEW.Ticket_Ticket_id;

  IF NEW.Seller_Visitor_id != owner_id THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Only the original ticket owner can offer it for resale.';
  END IF;
END;
//

DELIMITER ;