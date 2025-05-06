LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Image.csv' INTO TABLE Image FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Image_id, Description, ImageURL);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Artist.csv' INTO TABLE Artist FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Artist_id, Name, StageName, BirthDate, Website, Image_Image_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Continent.csv' INTO TABLE Continent FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Name);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Equipment.csv' INTO TABLE Equipment FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Name, Description, Image_Image_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Experience.csv' INTO TABLE Experience FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Level, Level_name);

-- Δημιουργία προσωρινού πίνακα
CREATE TABLE Location_temp (
    Location_id INT NOT NULL,
    Address VARCHAR(45) NOT NULL,
    Coordinates VARCHAR(100) NOT NULL,
    City VARCHAR(45) NOT NULL,
    Country VARCHAR(45) NOT NULL,
    Continent_Name VARCHAR(45) NOT NULL
);

-- Φόρτωσε το CSV στον προσωρινό πίνακα
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Location.csv'
INTO TABLE Location_temp
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Location_id, Address, Coordinates, City, Country, Continent_Name);

-- Κάνε insert στον κανονικό Location μετατρέποντας σε GEOMETRY
INSERT INTO Location (Location_id, Address, Coordinates, City, Country, Continent_Name)
SELECT 
    Location_id, 
    Address, 
    ST_GeomFromText(Coordinates),
    City, 
    Country, 
    Continent_Name
FROM Location_temp;

-- Καθάρισε τον προσωρινό πίνακα
DROP TABLE Location_temp;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Festival.csv' INTO TABLE Festival FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Festival_id, Year, StartDate, EndDate, Days, Image_Image_id, Location_Location_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Performance_type.csv' INTO TABLE Performance_type FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Type);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Role.csv' INTO TABLE Role FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Name);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Staff.csv' INTO TABLE Staff FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Staff_id, Name, Age, Role_Name, Experience_Level);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Stage.csv' INTO TABLE Stage FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Stage_id, Name, Description, MaxCapacity);

-- LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Ticket_type.csv' INTO TABLE Ticket_type FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Type);
INSERT IGNORE INTO Ticket_type (Type)
VALUES 
  ('Backstage'),
  ('Early Bird'),
  ('Group'),
  ('Regular'),
  ('VIP');


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Visitor.csv' INTO TABLE Visitor FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Visitor_id, Name, Age, ContactInfo);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\genre.csv' INTO TABLE Genre FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Genre_id);

-- LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\payment_method.csv' INTO TABLE Payment_method FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Method);
INSERT IGNORE INTO Payment_method (Method)
VALUES 
  ('Cash'),
  ('Credit Card'),
  ('Debit Card'),
  ('Bank Account'),
  ('No Cash'),
  ('');


LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Subgenre.csv' INTO TABLE Subgenre FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Subgenre_id, Genre_Genre_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Likert.csv' INTO TABLE Likert FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (id, name);


-- generated folder αρχεία

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\Stage_has_Equipment.csv' INTO TABLE Stage_has_Equipment FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Stage_Stage_id, Equipment_Name, Quantity);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\performer.csv' INTO TABLE Performer FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Performer_id, Name, FormationDate, Website, InstagramProfile);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\performer_has_subgenre.csv' INTO TABLE Performer_has_Subgenre FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Performer_Performer_id, Subgenre_Subgenre_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\resalequeue.csv' INTO TABLE ResaleQueue FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (timestamp, Ticket_Ticket_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\event.csv' INTO TABLE Event FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Event_id, Date, Festival_Festival_id, Stage_Stage_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\event_has_staff.csv' INTO TABLE Event_has_Staff FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Event_Event_id, Staff_Staff_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\artist_has_performer.csv' INTO TABLE Artist_has_Performer FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Artist_Artist_id, Performer_Performer_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\performance.csv' INTO TABLE Performance FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Performance_id, StartTime, Duration, BreakDuration, Performer_id, Event_Event_id, Performance_type_Type);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\ticket_only5000.csv' INTO TABLE Ticket FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Ticket_id, PurchaseDate, Price, EANCode, IsActive, Event_Event_id, @Visitor_Visitor_id, Ticket_type_Type, Payment_method_Method, @Seller_id);
/*SET 
  Visitor_Visitor_id = NULLIF(@Visitor_Visitor_id, ''),
  Seller_id = NULLIF(@Seller_id, '');*/
  
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\Rating.csv' INTO TABLE Rating FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Rating_id, ArtistPerformance, SoundAndLighting, StagePresence, Organization, OverallImpression, Performance_Performance_id, Visitor_Visitor_id);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\generated\\buyer_has_ticket.csv' INTO TABLE Buyer_has_Ticket FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 LINES (Buyer_BuyerVisitor_id, Ticket_Ticket_id, datetime);
