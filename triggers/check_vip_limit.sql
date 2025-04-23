-- VIP ≤ 10% χωρητικότητας σκηνής

DELIMITER //

CREATE PROCEDURE check_vip_limit(IN stage_id INT)
BEGIN
  DECLARE vip_count INT DEFAULT 0;
  DECLARE total_capacity INT DEFAULT 0;

  SELECT MaxCapacity INTO total_capacity
  FROM Stage
  WHERE Stage_id = stage_id;

  SELECT COUNT(*) INTO vip_count
  FROM Ticket
  WHERE Ticket_type = 'VIP' AND Event_Event_id IN (
    SELECT Event_id FROM Event WHERE Stage_Stage_id = stage_id
  );

  IF vip_count + 1 > total_capacity * 0.1 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'VIP limit exceeded for this stage!';
  END IF;
END;
//

CREATE TRIGGER vip_check_before_insert
BEFORE INSERT ON Ticket
FOR EACH ROW
BEGIN
  IF NEW.Ticket_type = 'VIP' THEN
    CALL check_vip_limit(
      (SELECT Stage_Stage_id FROM Event WHERE Event_id = NEW.Event_Event_id)
    );
  END IF;
END;
//

DELIMITER ;