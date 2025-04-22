-- Η χωρητικότητα της σκηνής δεν μπορεί να ξεπεραστεί κατά την πώληση εισιτηρίων

DELIMITER //

CREATE TRIGGER check_stage_capacity
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
  DECLARE max_capacity INT;
  DECLARE current_tickets INT;

  SELECT MaxCapacity INTO max_capacity
  FROM Stage
  WHERE Stage_id = (
    SELECT Stage_Stage_id
    FROM Event
    WHERE Event_id = NEW.Event_Event_id
  );

  SELECT COUNT(*) INTO current_tickets
  FROM Ticket
  WHERE Event_Event_id = NEW.Event_Event_id;

  IF current_tickets >= max_capacity THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Stage capacity exceeded for this event.';
  END IF;
END;
//

DELIMITER ;