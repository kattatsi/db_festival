-- Φόρτωση βασικών πινάκων
LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Image.csv' 
INTO TABLE Image 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Image_id, Description, ImageURL);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Artist.csv' 
INTO TABLE Artist 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Artist_id, Name, StageName, BirthDate, Website, Image_Image_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Continent.csv' 
INTO TABLE Continent 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Name);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Equipment.csv' 
INTO TABLE Equipment 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Name, Description, Image_Image_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Experience.csv' 
INTO TABLE Experience 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Level, Level_name);

-- Προσωρινός πίνακας για Location (λόγω GEOMETRY)
CREATE TABLE Location_temp (
    Location_id INT NOT NULL,
    Address VARCHAR(45) NOT NULL,
    Coordinates VARCHAR(100) NOT NULL,
    City VARCHAR(45) NOT NULL,
    Country VARCHAR(45) NOT NULL,
    Continent_Name VARCHAR(45) NOT NULL
);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Location.csv' 
INTO TABLE Location_temp 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Location_id, Address, Coordinates, City, Country, Continent_Name);

INSERT INTO Location (Location_id, Address, Coordinates, City, Country, Continent_Name)
SELECT 
    Location_id, 
    Address, 
    ST_GeomFromText(Coordinates),
    City, 
    Country, 
    Continent_Name 
FROM Location_temp;

DROP TABLE Location_temp;

-- Φόρτωση υπολοίπων πινάκων
LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Festival.csv' 
INTO TABLE Festival 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Festival_id, Year, StartDate, EndDate, Days, Image_Image_id, Location_Location_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Performance_type.csv' 
INTO TABLE Performance_type 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Type);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Role.csv' 
INTO TABLE Role 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Name);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Staff.csv' 
INTO TABLE Staff 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Staff_id, Name, Age, Role_Name, Experience_Level);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Stage.csv' 
INTO TABLE Stage 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Stage_id, Name, Description, MaxCapacity);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Ticket_type.csv' 
INTO TABLE Ticket_type 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Type);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Visitor.csv' 
INTO TABLE Visitor 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Visitor_id, Name, Age, ContactInfo);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Genre.csv' 
INTO TABLE Genre 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Genre_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Payment_method.csv' 
INTO TABLE Payment_method 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Method);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Subgenre.csv' 
INTO TABLE Subgenre 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Subgenre_id, Genre_Genre_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Likert.csv' 
INTO TABLE Likert 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(id, name);

-- Φόρτωση πινάκων από τον φάκελο 'generated'
LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Stage_has_Equipment.csv' 
INTO TABLE Stage_has_Equipment 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Stage_Stage_id, Equipment_Name, Quantity);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Performer.csv' 
INTO TABLE Performer 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Performer_id, Name, FormationDate, Website, InstagramProfile);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Performer_has_Subgenre.csv' 
INTO TABLE Performer_has_Subgenre 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Performer_Performer_id, Subgenre_Subgenre_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/ResaleQueue.csv' 
INTO TABLE ResaleQueue 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(timestamp, Ticket_Ticket_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Event.csv' 
INTO TABLE Event 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Event_id, Date, Festival_Festival_id, Stage_Stage_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Event_has_Staff.csv' 
INTO TABLE Event_has_Staff 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Event_Event_id, Staff_Staff_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Artist_has_Performer.csv' 
INTO TABLE Artist_has_Performer 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Artist_Artist_id, Performer_Performer_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Performance.csv' 
INTO TABLE Performance 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Performance_id, StartTime, Duration, BreakDuration, Performer_id, Event_Event_id, Performance_type_Type);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Ticket.csv' 
INTO TABLE Ticket 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Ticket_id, PurchaseDate, Price, EANCode, IsActive, Event_Event_id, Visitor_Visitor_id, Ticket_type_Type, Payment_method_Method, @Seller_id)
SET Seller_id = CASE 
    WHEN @Seller_id = '' THEN NULL 
    WHEN @Seller_id REGEXP '^[0-9]+$' THEN CAST(@Seller_id AS UNSIGNED) 
    ELSE NULL 
END;

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Rating.csv' 
INTO TABLE Rating 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Rating_id, ArtistPerformance, SoundAndLighting, StagePresence, Organization, OverallImpression, Performance_Performance_id, Visitor_Visitor_id);

LOAD DATA INFILE '/Users/katerinadanaitatsi/Documents/uni/8sem/db/db_festival/festival_data_new/Visitor_wants_Ticket.csv' 
INTO TABLE Visitor_wants_Ticket
FIELDS TERMINATED BY ',' ENCLOSED BY '"' 
LINES TERMINATED BY '\n' 
IGNORE 1 LINES 
(Visitor_id, Ticket_id, Event_id, Ticket_type, timestamp);