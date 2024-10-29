create database HotelSystem
use HotelSystem

--hotel
create table hotel 
(
   hid INT IDENTITY PRIMARY KEY,
    hname VARCHAR(100) NOT NULL UNIQUE,
    hloc VARCHAR(100) NOT NULL,
    hphone VARCHAR(20) NOT NULL,
    rate_hotel DECIMAL(2, 1),
    CONSTRAINT chk_rating CHECK (rate_hotel BETWEEN 1 AND 5)

)
--room
create table room
(
     Rid INT IDENTITY PRIMARY KEY,
    hid INT NOT NULL,
    rnum VARCHAR(10) NOT NULL,
    room_type VARCHAR(20) NOT NULL,
    room_price DECIMAL(10, 2) NOT NULL,
    is_available BIT NOT NULL DEFAULT 1,
    CONSTRAINT uq_room_number UNIQUE (hid, rnum),
    CONSTRAINT chk_room_type CHECK (room_type IN ('Single', 'Double', 'Suite')),
    CONSTRAINT chk_price CHECK (room_price > 0),
    FOREIGN KEY (hid) REFERENCES Hotel(hid) 
         ON DELETE CASCADE 
        ON UPDATE CASCADE
)

--Guest
CREATE TABLE Guest (
    Gid INT IDENTITY PRIMARY KEY,
    Gname VARCHAR(100) NOT NULL,
    Gcontact VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    Gtype VARCHAR(50) NOT NULL,
    id_proof VARCHAR(50) NOT NULL,
    CONSTRAINT uq_id_proof UNIQUE (Gtype, id_proof)
)

--Booking
CREATE TABLE Booking (
    bid INT IDENTITY PRIMARY KEY,
    guest_id INT NOT NULL,
    room_id INT NOT NULL,
    booking_date DATE NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    Bstatus VARCHAR(20) NOT NULL DEFAULT 'Pending',
    total_cost DECIMAL(10, 2) NOT NULL,
    CONSTRAINT chk_status CHECK (bstatus IN ('Pending', 'Confirmed', 'Canceled', 'Check-in', 'Check-out')),
    CONSTRAINT chk_check_dates CHECK (check_in <= check_out),
    FOREIGN KEY (guest_id) REFERENCES Guest(gid) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Room(rid) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
)

--payment
CREATE TABLE Payment (
    pid INT IDENTITY PRIMARY KEY,
    booking_id INT NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    method VARCHAR(20) NOT NULL,
    CONSTRAINT chk_payment_amount CHECK (amount > 0),
    FOREIGN KEY (booking_id) REFERENCES Booking(bid) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
)

--staff
CREATE TABLE Staff (
    staff_id INT IDENTITY PRIMARY KEY,
    hotel_id INT NOT NULL,
    sname VARCHAR(100) NOT NULL,
    position VARCHAR(50) NOT NULL,
    contact_number VARCHAR(20) NOT NULL,
    FOREIGN KEY (hotel_id) REFERENCES Hotel(hid) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
)

--review
CREATE TABLE Review (
    review_id INT IDENTITY PRIMARY KEY,
    hotel_id INT NOT NULL,
    guest_id INT NOT NULL,
    rating INT NOT NULL,
    comments VARCHAR(500) NOT NULL DEFAULT 'No comments',
    review_date DATE NOT NULL,
    CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5),
    FOREIGN KEY (hotel_id) REFERENCES Hotel(hid) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    FOREIGN KEY (guest_id) REFERENCES Guest(gid) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
)