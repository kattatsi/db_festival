-- Το βοηθητικό προσωπικό πρέπει να καλύπτει τουλάχιστον το 2% του συνολικού αριθμού θεατών σε κάθε σκηνή

DELIMITER //

CREATE TRIGGER check_support_staff
BEFORE INSERT OR UPDATE ON Event_has_Staff
FOR EACH ROW
BEGIN
  DECLARE total_audience INT;
  DECLARE required_support INT;
  DECLARE current_support INT;

  SELECT COUNT(*) INTO total_audience
  FROM Ticket
  WHERE Event_Event_id = NEW.Event_Event_id;

  SET required_support = CEIL(total_audience * 0.02);

  SELECT COUNT(*) INTO current_support
  FROM Event_has_Staff EHS
  JOIN Staff S ON EHS.Staff_Staff_id = S.Staff_id
  WHERE EHS.Event_Event_id = NEW.Event_Event_id
    AND S.Role_Role_Name = 'Support';

  IF current_support < required_support THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient support staff for this event';
  END IF;
END;
//

DELIMITER ;