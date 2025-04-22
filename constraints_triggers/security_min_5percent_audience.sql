-- Το προσωπικό ασφαλείας πρέπει να καλύπτει τουλάχιστον το 5% του συνολικού αριθμού θεατών σε κάθε σκηνή

DELIMITER //

CREATE TRIGGER check_security_staff
BEFORE INSERT OR UPDATE ON Event_has_Staff
FOR EACH ROW
BEGIN
  DECLARE total_audience INT;
  DECLARE required_security INT;
  DECLARE current_security INT;

  SELECT COUNT(*) INTO total_audience
  FROM Ticket
  WHERE Event_Event_id = NEW.Event_Event_id;

  SET required_security = CEIL(total_audience * 0.05);

  SELECT COUNT(*) INTO current_security
  FROM Event_has_Staff EHS
  JOIN Staff S ON EHS.Staff_Staff_id = S.Staff_id
  WHERE EHS.Event_Event_id = NEW.Event_Event_id
    AND S.Role_Role_Name = 'Security';

  IF current_security < required_security THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient security staff for this event';
  END IF;
END;
//

DELIMITER ;