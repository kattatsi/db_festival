-- Περιορισμός: Quantity ≥ 0

ALTER TABLE Equipment_has_Stage
ADD CONSTRAINT chk_equipment_quantity
CHECK (Quantity >= 0);