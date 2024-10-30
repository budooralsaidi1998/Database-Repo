use HotelSystem 

-- Add a non-clustered index on the 'name' column to optimize searches by hotel name
CREATE NONCLUSTERED INDEX index_hotel_name ON Hotel (hname);

-- Add a non-clustered index on the 'rating' column to speed up queries that filter by hotel rating
CREATE NONCLUSTERED INDEX index_hotel_rating ON Hotel (rate_hotel);

-- Add a clustered index on the 'room_number' columns to optimize room lookups within a hotel

CREATE CLUSTERED INDEX index_room_num ON Room (rnum)

-- Add a non-clustered index on the 'type' column to improve searches that filter by room type
CREATE NONCLUSTERED INDEX index_room_type ON Room (room_type);

-- Add a non-clustered index on the 'guest_id' column to optimize guest-related booking searches
CREATE NONCLUSTERED INDEX idx_booking_guest_id ON Booking (guest_id);

-- Add a non-clustered index on the 'status' column to improve filtering of bookings by status
CREATE NONCLUSTERED INDEX index_booking_status ON Booking (Bstatus);

-- Add a composite index on numroom, check_in_date, and check_out_date for efficient booking schedule queries
CREATE NONCLUSTERED INDEX index_booking_room_schedule ON Booking (room_number, check_in, check_out);


-- Create a view that displays the top-rated hotels (rating above 4.5) along with the total number of 
--rooms and average room price for each hotel.
CREATE VIEW ViewTopRatedHotels AS
SELECT 
    hid,
    hname AS hotel_name,
    hloc,
    hphone,
    rate_hotel,
    -- Subquery to calculate total rooms  hotel
    (SELECT COUNT(*) FROM Room WHERE hid = h.hid) AS total_rooms,
    -- Subquery to calculate average room price  hotel
    (SELECT AVG(room_price) FROM Room WHERE hid = h.hid) AS avg_price
FROM 
    Hotel h
WHERE 
    h.rate_hotel > 4.5;

	select * from ViewTopRatedHotels


	--Create a view that lists each guest along with 
	--their total number of bookings and the total amount 
--spent on all bookings. 

	CREATE VIEW ViewGuestBookings AS
SELECT 
    g.Gid AS guest_id,
    g.Gname AS guest_name,
    -- Subquery to count total bookings per guest
    (SELECT COUNT(*) FROM Booking b WHERE b.guest_id = g.Gid) AS total_bookings,
    -- Subquery to calculate total amount spent per guest
    (SELECT COALESCE(SUM(b.total_cost), 0) FROM Booking b WHERE b.guest_id = g.Gid) AS total_amount_spent
FROM 
    Guest g;

	select * from ViewGuestBookings

	--COALESCE(SUM(b.total_cost), 0):

--COALESCE is a SQL function that returns the first non-NULL value in a list of arguments.
--If SUM(b.total_cost) returns NULL (meaning the guest has no bookings), COALESCE will substitute 0 instead.


--view 3


	create VIEW VAvailableRooms AS
SELECT
    h.HID,
    H.HName,
    r.rnum,
    R.room_type,
    R.room_price,
    R.is_available as [available rooms]
FROM
    Hotel H
JOIN
    Room R ON H.HID = R.HID
WHERE
    R.is_available = 1  -- Only available rooms
GROUP BY
   R.room_type
 SELECT *
FROM VAvailableRooms
ORDER BY  room_price ASC


--view 4
	--Create a view that summarizes bookings by hotel, showing the total number of bookings, confirmed 
--bookings, pending bookings, and canceled bookings.
	CREATE VIEW ViewBookingSummary AS
SELECT 
    h.hid AS hotel_id,
    h.hname AS hotel_name,
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.room_number IN (SELECT r.rnum 
                             FROM Room r 
                             WHERE r.hid = h.hid)
    ) AS total_bookings,
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.room_number IN (SELECT r.rnum 
                             FROM Room r 
                             WHERE r.hid = h.hid)
     AND b.BStatus = 'Confirmed'
    ) AS confirmed_bookings,
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.room_number IN (SELECT r.rnum 
                             FROM Room r 
                             WHERE r.hid = h.hid)
     AND b.BStatus = 'Pending'
    ) AS pending_bookings,
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.room_number IN (SELECT r.rnum 
                             FROM Room r 
                             WHERE r.hid = h.hid)
     AND b.BStatus = 'Canceled'
    ) AS canceled_bookings
FROM 
    Hotel h;

	select * from ViewBookingSummary

	--view5
	CREATE VIEW ViewPaymentHistory AS
SELECT 
    g.gid AS guest_id,
    g.gname AS guest_name,
    h.hid AS hotel_id,
    h.hname AS hotel_name,
    b.BStatus AS booking_status,
    b.booking_date,
    (SELECT SUM(p.amount)
     FROM Payment p
     WHERE p.booking_id = b.bid
    ) AS total_payment
FROM 
    Guest g
JOIN 
    Booking b ON g.gid = b.guest_id
JOIN 
    Room r ON b.room_number = r.rnum 
JOIN 
    Hotel h ON r.hid = h.hid;

	select * from ViewPaymentHistory


	--functions 
	-- f1
	CREATE FUNCTION GetHotelAverageRating
(
    @HotelID INT
)
RETURNS DECIMAL(3, 2)
AS
BEGIN
    DECLARE @AverageRating DECIMAL(3, 2);

    SELECT @AverageRating = AVG(r.rating)
    FROM Review r
    WHERE r.hotel_id = @HotelID;

    RETURN COALESCE(@AverageRating, 0);
END;
SELECT dbo.GetHotelAverageRating(1) AS AverageRating; 

--f2
CREATE FUNCTION GetNextAvailableRoom
(
    @HotelID INT,
    @RoomType VARCHAR(20)
)
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @RoomNumber VARCHAR(10);

    SELECT TOP 1 @RoomNumber = r.rnum
    FROM Room r
    WHERE r.hid = @HotelID
      AND r.room_type = @RoomType
      AND r.is_available = 1
    ORDER BY r.room_price; 

    RETURN COALESCE(@RoomNumber, 'No available rooms');
END;

SELECT dbo.GetNextAvailableRoom(1, 'Double') AS NextAvailableRoom;  

-- f3

CREATE FUNCTION CalculateOccupancyRate
(
    @HotelID INT
)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    DECLARE @TotalRooms INT;
    DECLARE @OccupiedRooms INT;
    DECLARE @OccupancyRate DECIMAL(5, 2);

    -- Get the total number of rooms in the hotel
    SELECT @TotalRooms = COUNT(*)
    FROM Room
    WHERE hid = @HotelID;

    -- Get the number of occupied rooms based on bookings in the last 30 days
    SELECT @OccupiedRooms = COUNT(DISTINCT b.room_number)
    FROM Booking b
    JOIN Room r ON b.room_number = r.rnum
    WHERE r.hid = @HotelID
      AND b.check_in >= DATEADD(DAY, -30, GETDATE())
      AND b.BStatus IN ('Confirmed', 'Check-in'); -- Consider only confirmed and checked-in bookings

    -- Calculate the occupancy rate
    SET @OccupancyRate = CASE 
        WHEN @TotalRooms = 0 THEN 0 -- Avoid division by zero
        ELSE (@OccupiedRooms * 100.0 / @TotalRooms) 
    END

    RETURN @OccupancyRate;
END;
SELECT dbo.CalculateOccupancyRate(1) AS OccupancyRate;  

--procedure 
--p1
CREATE PROCEDURE sp_calacualt
(
    @HotelID INT,
    @RoomNumber int
)
AS
BEGIN
   

    -- Update the room's availability status to unavailable
    UPDATE Room
    SET is_available = 0
    WHERE hid = @HotelID
      AND rnum = @RoomNumber;

    -- Optionally check if the update was successful
    IF @@ROWCOUNT = 0
    BEGIN
        SELECT'Room not found or already unavailable.', 16, 1;
    END
END;

EXEC sp_calacualt @HotelID = 1, @RoomNumber = 10; 

--p2
CREATE PROCEDURE sp_UpdateBookingStatus
(
    @BookingID INT
)
AS
BEGIN
 

    DECLARE @CheckInDate DATE;
    DECLARE @CheckOutDate DATE;
    DECLARE @CurrentStatus VARCHAR(20);
    
 
    SELECT 
        @CheckInDate = check_in, 
        @CheckOutDate = check_out,
        @CurrentStatus = BStatus
    FROM 
        Booking
    WHERE 
        bid = @BookingID;

    -- Check if booking exists
    IF @CheckInDate IS NULL OR @CheckOutDate IS NULL
    BEGIN
        SELECT'Booking not found.', 16, 1;
        RETURN;
    END

    -- Update the booking status based on the current date
    IF @CurrentStatus <> 'Check-out' -- Prevent changing status if already checked out
    BEGIN
        IF GETDATE() < @CheckInDate
        BEGIN
            SELECT'-----'
        END
        ELSE IF GETDATE() >= @CheckInDate AND GETDATE() < @CheckOutDate
        BEGIN
            -- Update to 'Check-in'
            UPDATE Booking
            SET BStatus = 'Check-in'
            WHERE bid = @BookingID;
        END
        ELSE IF GETDATE() >= @CheckOutDate
        BEGIN
            -- Update to 'Check-out'
            UPDATE Booking
            SET BStatus = 'Check-out'
            WHERE bid = @BookingID;
			
        END
    END
END;

EXEC sp_UpdateBookingStatus @BookingID = 1; 


--p3

CREATE PROCEDURE sp_RankGuestsBySpending
AS
BEGIN
   

    SELECT 
        g.gid AS GuestID,
        g.gname AS GuestName,
        COALESCE(
            (SELECT SUM(b.total_cost) 
             FROM Booking b 
             WHERE b.guest_id = g.gid), 
            0
        ) AS TotalSpending,
        RANK() OVER (ORDER BY 
            COALESCE((SELECT SUM(b.total_cost) 
                      FROM Booking b 
                      WHERE b.guest_id = g.gid), 
            0) DESC
        ) AS SpendingRank
    FROM 
        Guest g
    ORDER BY 
        SpendingRank;
END;


EXEC sp_RankGuestsBySpending;


--trigger 
--t1`
CREATE TRIGGER trg_UpdateRoomAvailability
ON Booking
AFTER INSERT
AS
BEGIN
  

    -- Update room availability to 'Unavailable' for each new booking added
    UPDATE Room
    SET is_available = 0
    WHERE rnum IN (SELECT room_number FROM inserted);
END;

--will automatically execute each time a new booking is added to the Booking table. 
--When a booking is added,
--the associated room’s availability status is updated to "Unavailable."


--t2
CREATE TRIGGER TTotalRevenue
ON Payment
AFTER INSERT
AS
Select Sum(amount) AS Revenue
From Payment
Select *
From Payment
INSERT INTO Payment (booking_id, Payment_Date, amount, method)
VALUES
(3, '2024-10-02', 250, 'Credit')

--t3
CREATE TRIGGER trg_PreventInvalidBookingDates
ON Booking
INSTEAD OF INSERT
AS
BEGIN
  

    -- Check if any inserted rows have a check-in date later than the check-out date
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE check_in > check_out
    )
    BEGIN
       
        SELECT 'Check-in date cannot be later than the check-out date.', 16, 1;
    END
    ELSE
    BEGIN
       
        INSERT INTO Booking (guest_id, room_number, booking_date, check_in, check_out, BStatus, total_cost)
        SELECT guest_id, room_number, booking_date, check_in, check_out, BStatus, total_cost
        FROM inserted;
    END
END;
