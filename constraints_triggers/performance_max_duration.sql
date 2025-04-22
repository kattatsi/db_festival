-- Περιορισμός 1: Κάθε performance ≤ 3 ώρες 

ALTER TABLE Performance
ADD CONSTRAINT chk_Performance_MaxDuration
CHECK (Duration <= 180);