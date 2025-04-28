-- === INTEGRATED RULES ===

-- === FULL DDL INCLUDING ALL 21 RULES ===
-- Generated automatically

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';


-- === check_stage_capacity.sql ===
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

-- === check_vip_limit.sql ===
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
  IF NEW.Ticket_type_Type = 'VIP' THEN
    CALL check_vip_limit(
      (SELECT Stage_Stage_id FROM Event WHERE Event_id = NEW.Event_Event_id)
    );
  END IF;
END;
//

DELIMITER ;

-- === event_max_duration.sql ===
-- Κάθε event ≤ 12 ώρες

DELIMITER //

CREATE TRIGGER trg_Check_Event_Duration
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE total_duration INT;

    SELECT IFNULL(SUM(Duration), 0) INTO total_duration
    FROM Performance
    WHERE Event_Event_id = NEW.Event_Event_id;

    IF total_duration + NEW.Duration > 720 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Total performance duration in this event exceeds 12 hours (720 minutes)';
    END IF;
END;
//

DELIMITER ;

-- === festival_day_max_duration.sql ===
-- Κάθε festival ≤ 13 ώρες/ημέρα

DELIMITER //

CREATE TRIGGER trg_Check_Festival_Day_Duration
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE total_day_duration INT;
    DECLARE event_date DATE;

    SELECT Date INTO event_date
    FROM Event
    WHERE Event_Event_id = NEW.Event_Event_id;

    SELECT IFNULL(SUM(p.Duration), 0) INTO total_day_duration
    FROM Performance p
    JOIN Event e ON e.Event_id = p.Event_id
    WHERE e.Date = event_date;

    IF total_day_duration + NEW.Duration > 780 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Total performance time on this day exceeds 13 hours (780 minutes)';
    END IF;
END;
//

DELIMITER ;

-- === performance_break_duration.sql ===
-- Διάλειμμα 5–30 λεπτών μεταξύ εμφανίσεων

DELIMITER //

CREATE TRIGGER trg_Check_Performance_Break
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
  DECLARE prev_end DATETIME;
  DECLARE break_minutes INT;
  DECLARE stage_id INT;

  -- Βρες τη σκηνή του event
  SELECT Stage_Stage_id INTO stage_id
  FROM Event
  WHERE Event_id = NEW.Event_Event_id;

  -- Βρες την ώρα λήξης της προηγούμενης εμφάνισης στη σκηνή
  SELECT MAX(ADDTIME(StartTime, SEC_TO_TIME(Duration * 60))) INTO prev_end
  FROM Performance
  WHERE Event_Event_id IN (
    SELECT Event_id FROM Event WHERE Stage_Stage_id = stage_id
  )
  AND StartTime < NEW.StartTime;

  -- Υπολόγισε το διάστημα από τη λήξη της προηγούμενης
  IF prev_end IS NOT NULL THEN
    SET break_minutes = TIMESTAMPDIFF(MINUTE, prev_end, NEW.StartTime);

    IF break_minutes < 5 OR break_minutes > 30 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Break between performances must be between 5 and 30 minutes.';
    END IF;
  END IF;
END;
//

DELIMITER ;


-- === performance_max_duration.sql ===
-- Περιορισμός 1: Κάθε performance ≤ 3 ώρες 

ALTER TABLE Performance
ADD CONSTRAINT chk_Performance_MaxDuration
CHECK (Duration <= 180);

-- === performer_overlap.sql ===
-- Ένας performer δεν εμφανίζεται σε 2 σκηνές ταυτόχρονα

DELIMITER //

CREATE TRIGGER trg_Check_Performer_Overlap
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT;

    SELECT COUNT(*) INTO overlap_count
    FROM Performance
    WHERE Performer_id = NEW.Performer_id
      AND (
        -- Ελέγχει αν η νέα εμφάνιση ξεκινά μέσα σε υπάρχουσα
        (NEW.StartTime BETWEEN StartTime AND ADDTIME(StartTime, SEC_TO_TIME(Duration * 60)))
        -- Ή αν η υπάρχουσα ξεκινά μέσα στη νέα
        OR
        (StartTime BETWEEN NEW.StartTime AND ADDTIME(NEW.StartTime, SEC_TO_TIME(NEW.Duration * 60)))
      );

    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Performer cannot perform in two places at the same time.';
    END IF;
END;
//

DELIMITER ;

-- === performer_years_limit.sql ===
-- Ένας performer δεν συμμετέχει για >3 συνεχόμενα έτη

DELIMITER //

CREATE TRIGGER trg_Check_Performer_3_Years
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
    DECLARE participation_years INT;

    -- Μετράμε σε πόσα ΔΙΑΦΟΡΕΤΙΚΑ έτη έχει ήδη συμμετάσχει ο Performer τα τελευταία 3 χρόνια
    SELECT COUNT(DISTINCT YEAR(e.Date)) INTO participation_years
    FROM Performance p
    JOIN Event e ON e.Event_id = p.Event_Event_id
    WHERE p.Performer_id = NEW.Performer_id
      AND YEAR(e.Date) >= YEAR(CURDATE()) - 2  -- τα τελευταία 3 έτη (τρέχον + 2 πίσω)

    ;

    -- Αν έχει συμμετάσχει ήδη σε 3, δεν επιτρέπεται άλλη εμφάνιση φέτος
    IF participation_years >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Performer cannot participate more than 3 consecutive years.';
    END IF;
END;
//

DELIMITER ;

-- === prevent_double_activation.sql ===
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

-- === visitor_one_ticket_per_event.sql ===
-- Αποτρέπει αγοραστή να πάρει δεύτερο εισιτήριο για το ίδιο event

DELIMITER //

CREATE TRIGGER trg_Visitor_One_Ticket_Per_Event
BEFORE INSERT ON Visitor_wants_Ticket
FOR EACH ROW
BEGIN
  -- Αν ο επισκέπτης έχει ήδη εισιτήριο για το συγκεκριμένο event, μπλοκάρουμε
  IF EXISTS (
    SELECT 1
    FROM Ticket
    WHERE Visitor_Visitor_id = NEW.Visitor_id
      AND Event_Event_id = NEW.Event_id
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Visitor already owns a ticket for this event.';
  END IF;
END;
//

DELIMITER ;


-- === rating_only_with_active_ticket.sql ===
-- Trigger για να επιτρέπει αξιολόγηση μόνο σε επισκέπτες με ενεργοποιημένο εισιτήριο

DROP TRIGGER IF EXISTS trg_Rating_OnlyWithActiveTicket;

DELIMITER //

CREATE TRIGGER trg_Rating_OnlyWithActiveTicket
BEFORE INSERT ON Rating
FOR EACH ROW
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM Ticket
    WHERE Visitor_Visitor_id = NEW.Visitor_Visitor_id AND IsActive = TRUE
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Only visitors with an active ticket can rate a performance.';
  END IF;
END;
//

DELIMITER ;

-- === resale_fifo.sql ===
ALTER TABLE ResaleQueue
MODIFY COLUMN timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- === resale_only_inactive_tickets.sql ===
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

-- === security_min_5percent_audience.sql ===
-- Το προσωπικό ασφαλείας πρέπει να καλύπτει τουλάχιστον το 5% του συνολικού αριθμού θεατών σε κάθε σκηνή

DELIMITER //

CREATE TRIGGER check_security_staff_insert
BEFORE INSERT ON Event_has_Staff
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
    AND S.Role_Name = 'Security';

  IF current_security < required_security THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient security staff for this event';
  END IF;
END;
//
DELIMITER ;

DELIMITER //

CREATE TRIGGER check_security_staff_update
BEFORE UPDATE ON Event_has_Staff
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
    AND S.Role_Name = 'Security';

  IF current_security < required_security THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient security staff for this event';
  END IF;
END;
//
DELIMITER ;



-- === seller_is_owner.sql ===
DELIMITER //

CREATE TRIGGER check_resale_seller_is_owner
BEFORE INSERT ON ResaleQueue
FOR EACH ROW
BEGIN
  DECLARE original_owner_id INT;

  -- Βρες τον αρχικό κάτοχο (visitor) αυτού του ticket μέσω Seller
  SELECT V.Visitor_id INTO original_owner_id
  FROM Ticket T
  JOIN Seller S ON T.Seller_Seller_id = S.Seller_id
  JOIN Visitor V ON S.Visitor_Visitor_id = V.Visitor_id
  WHERE T.Ticket_id = NEW.Ticket_Ticket_id;

  -- Εφόσον δεν έχεις Visitor στην ResaleQueue, το μπλοκάρεις μόνο αν δεν υπάρχει αυτό το mapping
  IF original_owner_id IS NULL THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot determine original owner of ticket.';
  END IF;
END;
//

DELIMITER ;



-- === support_min_2percent_audience.sql ===
-- Το βοηθητικό προσωπικό πρέπει να καλύπτει τουλάχιστον το 2% του συνολικού αριθμού θεατών σε κάθε σκηνή

DELIMITER //

CREATE TRIGGER check_support_staff_insert
BEFORE INSERT ON Event_has_Staff
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
    AND S.Role_Name = 'Support';

  IF current_support < required_support THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient support staff for this event';
  END IF;
END;
//
DELIMITER ;

DELIMITER //

CREATE TRIGGER check_support_staff_update
BEFORE UPDATE ON Event_has_Staff
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
    AND S.Role_Name = 'Support';

  IF current_support < required_support THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Insufficient support staff for this event';
  END IF;
END;
//
DELIMITER ;


-- === unique_eancode.sql ===
ALTER TABLE Ticket
ADD CONSTRAINT unique_eancode UNIQUE (EANCode);

-- === unique_rating_per_visitor_performance.sql ===
-- Περιορισμός μοναδικότητας αξιολόγησης ανά επισκέπτη και εμφάνιση

ALTER TABLE Rating
ADD CONSTRAINT unique_visitor_performance
UNIQUE (Visitor_Visitor_id, Performance_Performance_id);

-- === unique_visitor_event.sql ===
-- Ένας επισκέπτης δεν μπορεί να έχει 2 εισιτήρια για το ίδιο event

ALTER TABLE Ticket
ADD CONSTRAINT unique_visitor_event UNIQUE (Visitor_Visitor_id, Event_Event_id);

-- === valid_equipment_quantity.sql ===
-- Περιορισμός: Quantity ≥ 0

ALTER TABLE Stage_has_Equipment
ADD CONSTRAINT chk_equipment_quantity
CHECK (Quantity >= 0);

-- === techn_max_2_performances_per_day.sql ===
-- Κάθε τεχνικός μπορεί να υποστηρίζει έως 2 εμφανίσεις την ίδια ημέρα

DELIMITER //

CREATE TRIGGER trg_Limit_Technician_Performances
BEFORE INSERT ON Event_has_Staff
FOR EACH ROW
BEGIN
  DECLARE performance_date DATE;
  DECLARE staff_role VARCHAR(45);
  DECLARE appearances_on_day INT;

  -- Βρες το ρόλο του προσωπικού
  SELECT Role_Name INTO staff_role
  FROM Staff
  WHERE Staff_id = NEW.Staff_Staff_id;

  -- Μόνο για τεχνικούς εφαρμόζεται αυτός ο περιορισμός
  IF staff_role = 'Technician' THEN

    -- Βρες την ημερομηνία του event που πάει να ανατεθεί
    SELECT Date INTO performance_date
    FROM Event
    WHERE Event_id = NEW.Event_Event_id;

    -- Μέτρα πόσες performances την ίδια μέρα υποστηρίζει ήδη
    SELECT COUNT(*) INTO appearances_on_day
    FROM Event_has_Staff es
    JOIN Event e ON es.Event_Event_id = e.Event_id
    JOIN Staff s ON es.Staff_Staff_id = s.Staff_id
    WHERE s.Role_Name = 'Technician'
      AND es.Staff_Staff_id = NEW.Staff_Staff_id
      AND e.Date = performance_date;

    -- Αν είναι ήδη 2, μπλοκάρουμε
    IF appearances_on_day >= 2 THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'A technician cannot support more than 2 performances per day.';
    END IF;

  END IF;

END;
//

DELIMITER ;

-- === unique_festival_year.sql ===
-- Το φεστιβάλ διεξάγεται ετησίως

ALTER TABLE Festival
ADD CONSTRAINT unique_festival_year
UNIQUE (Year);


-- === consecutive_days.sql ===
-- Το φεστιβάλ διεξάγεται ετησίως, σε μία ή περισσότερες συνεχόμενες ημέρες

ALTER TABLE Festival
ADD CONSTRAINT chk_consecutive_days
CHECK (Days = DATEDIFF(EndDate, StartDate) + 1);


-- === unique_location_per_year.sql ===
-- Το φεστιβάλ διεξάγεται ετησίως, σε διαφορετική τοποθεσία ανά έτος

DELIMITER //

CREATE TRIGGER trg_Unique_Location_Per_Year
BEFORE INSERT ON Festival
FOR EACH ROW
BEGIN
  DECLARE existing_location INT;

  SELECT COUNT(*) INTO existing_location
  FROM Festival
  WHERE Year = NEW.Year AND Location_Location_id = NEW.Location_Location_id;

  IF existing_location > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'A festival cannot be held in the same location more than once per year.';
  END IF;
END;
//

DELIMITER ;

-- === stage_event_overlap.sql ===
-- Κάθε σκηνή μπορεί να φιλοξενεί μόνο μία παράσταση (event) την ίδια στιγμή

DELIMITER //

CREATE TRIGGER trg_OnlyOneEventAtTime_PerStage
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
  DECLARE stage_id INT;
  DECLARE overlap_count INT;

  -- Βρες τη σκηνή στην οποία θα γίνει η νέα εμφάνιση
  SELECT Stage_Stage_id INTO stage_id
  FROM Event
  WHERE Event_id = NEW.Event_Event_id;

  -- Έλεγξε αν υπάρχουν άλλες performances την ίδια στιγμή στη σκηνή
  SELECT COUNT(*) INTO overlap_count
  FROM Performance p
  JOIN Event e ON p.Event_Event_id = e.Event_id
  WHERE e.Stage_Stage_id = stage_id
    AND (
      -- Η νέα performance ξεκινά μέσα σε υπάρχουσα
      (NEW.StartTime BETWEEN p.StartTime AND ADDTIME(p.StartTime, SEC_TO_TIME(p.Duration * 60)))
      OR
      -- Ή υπάρχουσα ξεκινά μέσα στη νέα
      (p.StartTime BETWEEN NEW.StartTime AND ADDTIME(NEW.StartTime, SEC_TO_TIME(NEW.Duration * 60)))
    );

  IF overlap_count > 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Only one event (via its performances) can be active on a stage at a time.';
  END IF;
END;
//

DELIMITER ;


-- === sequential_performances_per_event.sql ===
-- Σε κάθε event, οι performances πρέπει να είναι σειριακές

DELIMITER //

CREATE TRIGGER trg_Sequential_Performances_Per_Event
BEFORE INSERT ON Performance
FOR EACH ROW
BEGIN
  DECLARE last_end DATETIME;

  -- Βρες τη λήξη της τελευταίας performance του event (αν υπάρχει)
  SELECT MAX(ADDTIME(StartTime, SEC_TO_TIME(Duration * 60))) INTO last_end
  FROM Performance
  WHERE Event_Event_id = NEW.Event_Event_id;

  -- Αν υπάρχει προηγούμενη performance, έλεγξε αν η νέα ξεκινά ακριβώς μόλις τελειώσει
  IF last_end IS NOT NULL AND NEW.StartTime != last_end THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Performances in an event must be sequential without time gaps.';
  END IF;
END;
//

DELIMITER ;


-- === fifo_only_when_sold_out.sql ===
-- Όταν εξαντλούνται τα εισιτήρια ενεργοποιείται η ουρά fifo

DELIMITER //

CREATE TRIGGER trg_FIFO_Only_When_SoldOut
BEFORE INSERT ON Visitor_wants_Ticket
FOR EACH ROW
BEGIN
  DECLARE issued_tickets INT;
  DECLARE max_capacity INT;

  -- Βρες πόσα εισιτήρια έχουν εκδοθεί για το event
  SELECT COUNT(*) INTO issued_tickets
  FROM Ticket
  WHERE Event_Event_id = NEW.Event_id;

  -- Βρες τη μέγιστη χωρητικότητα της σκηνής
  SELECT s.MaxCapacity INTO max_capacity
  FROM Event e
  JOIN Stage s ON e.Stage_Stage_id = s.Stage_id
  WHERE e.Event_id = NEW.Event_id;

  -- Αν δεν έχει εξαντληθεί η χωρητικότητα, δεν επιτρέπεται είσοδος στην FIFO ουρά
  IF issued_tickets < max_capacity THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Tickets are still available for this event. You cannot join the FIFO queue yet.';
  END IF;
END;
//

DELIMITER ;


-- === resale_only_if_soldout.sql ===
-- Επιτρέπεται να εμφανιστεί ένας Seller_id στο Ticket μόνο όταν έχουν εξαντληθεί τα εισιτήρια του αντίστοιχου Event

DELIMITER //

CREATE TRIGGER trg_Only_Allow_Resale_When_SoldOut
BEFORE UPDATE ON Ticket
FOR EACH ROW
BEGIN
  DECLARE issued_tickets INT;
  DECLARE max_capacity INT;

  -- Αν προστίθεται seller (άρα είναι resale)
  IF NEW.Seller_id IS NOT NULL AND OLD.Seller_id IS NULL THEN

    -- Βρες πόσα εισιτήρια έχουν εκδοθεί για αυτό το event
    SELECT COUNT(*) INTO issued_tickets
    FROM Ticket
    WHERE Event_Event_id = NEW.Event_Event_id;

    -- Βρες τη μέγιστη χωρητικότητα της σκηνής
    SELECT s.MaxCapacity INTO max_capacity
    FROM Event e
    JOIN Stage s ON e.Stage_Stage_id = s.Stage_id
    WHERE e.Event_id = NEW.Event_Event_id;

    -- Αν δεν έχουν εξαντληθεί, μπλόκαρε το resale
    IF issued_tickets < max_capacity THEN
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'You cannot resell a ticket unless the event is sold out.';
    END IF;
  END IF;
END;
//

DELIMITER ;


-- όταν πάει να γίνει insert στη resalequeue ελέγχεται αν το θέλει κάποιος βάση event & type και δίνεται αυτόματα με fifo αλλιώς καταχωρείται

DELIMITER $$

CREATE TRIGGER before_resale_queue_insert
BEFORE INSERT ON ResaleQueue
FOR EACH ROW
BEGIN
    DECLARE v_event_id INT;
    DECLARE v_ticket_type VARCHAR(45);
    DECLARE v_current_visitor_id INT;
    DECLARE v_waiting_visitor_id INT;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_event_id = NULL;
    
    -- Get ticket details
    SELECT t.Event_Event_id, t.Ticket_Type_Type, t.Visitor_Visitor_id
    INTO v_event_id, v_ticket_type, v_current_visitor_id
    FROM Ticket t
    WHERE t.Ticket_id = NEW.Ticket_Ticket_id;
    
    -- Αν δεν βρεθεί το εισιτήριο, πετάμε σφάλμα
    IF v_event_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Ticket not found.';
    END IF;

    -- Find the earliest waiting visitor for this event and ticket type
    SELECT v.Visitor_id
    INTO v_waiting_visitor_id
    FROM Visitor_wants_Ticket v
    WHERE v.Event_id = v_event_id 
      AND v.Ticket_Type_Type = v_ticket_type
      AND v.Ticket_id IS NULL
    ORDER BY v.Timestamp ASC
    LIMIT 1;
    
    -- Αν υπάρχει κάποιος που περιμένει
    IF v_waiting_visitor_id IS NOT NULL THEN
        -- Case 1: Assign ticket to waiting visitor
        UPDATE Ticket
        SET Visitor_Visitor_id = v_waiting_visitor_id, 
            Seller_id = NULL
        WHERE Ticket_id = NEW.Ticket_Ticket_id;
        
        -- Remove all waitlist entries for this visitor/event/type
        DELETE FROM Visitor_wants_Ticket
        WHERE Visitor_id = v_waiting_visitor_id
          AND Event_id = v_event_id
          AND Ticket_Type_Type = v_ticket_type;
        
        -- Cancel the resale_queue insertion with SIGNAL
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Ticket assigned directly to waiting visitor. Resale canceled.';
    ELSE
        -- Case 2: No one is waiting, proceed with resale queue
        -- Update the seller info
        UPDATE Ticket
        SET Seller_id = v_current_visitor_id
        WHERE Ticket_id = NEW.Ticket_Ticket_id;
        
        -- Ensure entry timestamp is set
        SET NEW.Timestamp = IFNULL(NEW.Timestamp, NOW());
    END IF;
END $$

DELIMITER ;

-- όταν πάει να γίνει insert στο visitor_wants_ticket αν θέλει συγκεκριμένο διαθέσιμο εισητήριο πωλείται, αν θέλει event&type που υπάρχει διαθέσιμο πωλείται αλλιώς καταχωρείται 

DELIMITER //
CREATE TRIGGER before_visitor_wants_ticket_insert
BEFORE INSERT ON Visitor_wants_Ticket
FOR EACH ROW
BEGIN
    DECLARE v_ticket_exists INT;
    DECLARE v_oldest_resale_ticket_id INT;
    DECLARE v_event_id INT;
    DECLARE v_ticket_type VARCHAR(50);
    
    -- Περίπτωση 1: Θέλει συγκεκριμένο εισιτήριο
    IF NEW.Ticket_id IS NOT NULL THEN
        -- Ελέγχουμε αν υπάρχει αυτό το εισιτήριο στη resale_queue
        SELECT COUNT(*) INTO v_ticket_exists
        FROM ResaleQueue
        WHERE Ticket_Ticket_id = NEW.Ticket_id;
        
        IF v_ticket_exists = 0 THEN
            -- Το εισιτήριο δεν είναι διαθέσιμο
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Ticket not available in resale queue';
        ELSE
            -- Ενημέρωση εισιτηρίου - δίνουμε στον επισκέπτη
            UPDATE Ticket
            SET Visitor_Visitor_id = NEW.Visitor_id,
                Seller_id = NULL
            WHERE Ticket_id = NEW.Ticket_id;
            
            -- Διαγραφή από resale_queue
            DELETE FROM ResaleQueue
            WHERE Ticket_Ticket_id = NEW.Ticket_id;
            
            -- Ακύρωση Insert με SIGNAL
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Ticket assigned directly. Insert canceled.';
        END IF;
        
    -- Περίπτωση 2: Ζητάει οποιοδήποτε εισιτήριο για event και type
    ELSE
        -- Ψάχνουμε το πιο παλιό εισιτήριο
        SELECT r.Ticket_Ticket_id INTO v_oldest_resale_ticket_id
        FROM ResaleQueue r
        JOIN Ticket t ON r.Ticket_Ticket_id = t.Ticket_id
        WHERE t.Event_Event_id = NEW.Event_id
          AND t.Ticket_Type_Type = NEW.Ticket_Type
        ORDER BY r.Timestamp ASC
        LIMIT 1;
        
        IF v_oldest_resale_ticket_id IS NOT NULL THEN
            -- Ενημέρωση εισιτηρίου
            UPDATE Ticket
            SET Visitor_Visitor_id = NEW.Visitor_id,
                Seller_id = NULL
            WHERE Ticket_id = v_oldest_resale_ticket_id;
            
            -- Διαγραφή από resale_queue
            DELETE FROM ResaleQueue
            WHERE Ticket_Ticket_id = v_oldest_resale_ticket_id;
            
            -- Ακύρωση Insert με SIGNAL
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Ticket assigned directly from resale queue. Insert canceled.';
        ELSE
            -- Δεν βρέθηκε εισιτήριο, συμπληρώνουμε timestamp αν δεν υπάρχει
            SET NEW.timestamp = IFNULL(NEW.timestamp, NOW());
        END IF;
    END IF;
END//
DELIMITER ;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;


