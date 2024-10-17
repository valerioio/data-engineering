DROP TABLE IF EXISTS booking_service;
DROP TABLE IF EXISTS booking;
DROP TABLE IF EXISTS service;
DROP TABLE IF EXISTS shift;
DROP TABLE IF EXISTS staff;
DROP TABLE IF EXISTS guest;
DROP TABLE IF EXISTS room;
DROP TABLE IF EXISTS hotel;

CREATE TABLE hotel(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	location VARCHAR(255) UNIQUE NOT NULL,
	rating DECIMAL(4, 2),
	contact VARCHAR(255) UNIQUE NOT NULL,
	CHECK (rating >= 0 AND rating <= 10 OR rating IS NULL)
);

CREATE TABLE room(
	id SERIAL PRIMARY KEY,
	hotel_id INT NOT NULL,
	type VARCHAR(127) NOT NULL,
	price DECIMAL(8, 2) NOT NULL CHECK (price >= 0),
	capacity SMALLINT NOT NULL CHECK (capacity >= 0),
	FOREIGN KEY (hotel_id) REFERENCES hotel(id) ON DELETE CASCADE
);

CREATE TABLE guest(
	id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	email VARCHAR(255) UNIQUE NOT NULL,
	phone VARCHAR(255) UNIQUE NOT NULL,
	preference VARCHAR(511)
);

CREATE TABLE staff(
	id SERIAL PRIMARY KEY,
	hotel_id INT NOT NULL,
	name VARCHAR(255) NOT NULL,
	role VARCHAR(127) NOT NULL,
	salary DECIMAL(12, 2) NOT NULL CHECK (salary >= 0),
	FOREIGN KEY (hotel_id) REFERENCES hotel(id) ON DELETE CASCADE
);

CREATE TABLE shift(
	id SERIAL PRIMARY KEY,
	staff_id INT NOT NULL,
	start_time TIMESTAMP NOT NULL,
	end_time TIMESTAMP NOT NULL CHECK (end_time > start_time),
	FOREIGN KEY (staff_id) REFERENCES staff(id) ON DELETE CASCADE
);

CREATE TABLE service(
	id SERIAL PRIMARY KEY,
	hotel_id INT NOT NULL,
	type VARCHAR(127) NOT NULL,
	price DECIMAL(8, 2) NOT NULL CHECK (price >= 0),
	FOREIGN KEY (hotel_id) REFERENCES hotel(id) ON DELETE CASCADE
);

CREATE TABLE booking(
	id SERIAL PRIMARY KEY,
	guest_id INT NOT NULL,
	room_id INT NOT NULL,
	check_in TIMESTAMP NOT NULL,
	check_out TIMESTAMP NOT NULL CHECK (check_out > check_in),
	cost DECIMAL(12, 2) NOT NULL CHECK (cost >= 0),
	FOREIGN KEY (guest_id) REFERENCES guest(id) ON DELETE CASCADE,
	FOREIGN KEY (room_id) REFERENCES room(id) ON DELETE CASCADE
);

CREATE TABLE booking_service(
	booking_id INT NOT NULL,
	service_id INT NOT NULL,
	PRIMARY KEY (booking_id, service_id),
	FOREIGN KEY (booking_id) REFERENCES booking(id) ON DELETE CASCADE,
	FOREIGN KEY (service_id) REFERENCES service(id) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION
	service_same_hotel()
RETURNS TRIGGER LANGUAGE PLPGSQL AS
$$
BEGIN
	IF (
			(SELECT s.hotel_id
			FROM service s
			WHERE NEW.service_id = s.id
			) != (
			SELECT r.hotel_id
			FROM booking b INNER JOIN room r ON b.room_id = r.id
			WHERE NEW.booking_id = b.id)
		) THEN RAISE EXCEPTION 'room and service must be in the same hotel';
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER
	service_same_hotel
BEFORE INSERT OR UPDATE ON
	booking_service
FOR EACH ROW
EXECUTE FUNCTION service_same_hotel();
