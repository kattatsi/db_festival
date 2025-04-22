-- Περιορισμός μοναδικότητας αξιολόγησης ανά επισκέπτη και εμφάνιση

ALTER TABLE Rating
ADD CONSTRAINT unique_visitor_performance
UNIQUE (Visitor_Visitor_id, Performance_Performance_id);