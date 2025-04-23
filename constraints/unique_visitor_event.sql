
-- Ένας επισκέπτης δεν μπορεί να έχει 2 εισιτήρια για το ίδιο event

ALTER TABLE Ticket
ADD CONSTRAINT unique_visitor_event UNIQUE (Visitor_Visitor_id, Event_Event_id);
