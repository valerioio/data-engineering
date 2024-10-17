-- 1. List all available rooms at a specific hotel.
WITH var(hotel) AS (-- Hotel to query
	VALUES (1)
)
SELECT DISTINCT
	r.*
FROM
	room r
	INNER JOIN
		booking b ON r.id = b.room_id,
	var v
WHERE
	r.hotel_id = v.hotel AND NOT(b.check_in <= NOW() AND NOW() <= b.check_out);

-- 2. Retrieve guest details and preferences for all guests who stayed in the last month.
SELECT DISTINCT
	g.name, g.email, g.phone, g.preference
FROM
	guest g
	INNER JOIN booking b ON g.id = b.guest_id
WHERE
	(b.check_in >= NOW() - INTERVAL '1 month' AND b.check_in <= NOW() OR
	b.check_out >= NOW() - INTERVAL '1 month' AND b.check_out <= NOW());

-- 3. Calculate total revenue generated by each hotel property in a specific time period.
WITH var(start_period, end_period) AS (-- Start and end of the period to query
	VALUES (NOW() - INTERVAL '1 month', NOW())
)
SELECT
	SUM(b.cost) revenue
FROM
	booking b,
	var v
WHERE
	b.check_out >= v.start_period AND b.check_out <= v.end_period;

-- 4. Determine which room types generate the most revenue across the chain.
SELECT
	r.type
FROM
	booking b
	INNER JOIN room r ON b.room_id = r.id
GROUP BY
	r.type
ORDER BY
	SUM(b.cost) DESC
LIMIT
	1;

-- 5. Identify guests who have stayed in more than two hotels within the chain.
SELECT
	g.id,
	g.name
FROM
	booking b
	INNER JOIN guest g ON b.guest_id = g.id
GROUP BY
	g.id,
	g.name
HAVING
	COUNT(*) > 2;

-- 6. Calculate the average occupancy rate for each hotel over the past six months.
WITH var(start_date, end_date, six_months_days) AS(
	VALUES (
		CURRENT_DATE - INTERVAL '6 months' + INTERVAL '11 hours',
		CURRENT_DATE + INTERVAL '15 hours',
		EXTRACT(DAY FROM((CURRENT_DATE + INTERVAL '15 hours') -
			(CURRENT_DATE - INTERVAL '6 months' + INTERVAL '11 hours')))
	)
)
SELECT
	h.id,
	h.name,
	SUM(
		EXTRACT(DAY FROM(
			GREATEST(LEAST(b.check_out, v.end_date), v.start_date) -
			LEAST(GREATEST(b.check_in, v.start_date), v.end_date)
		))) / (COUNT(r.id) * v.six_months_days) occupancy_rate
FROM
	booking b
	INNER JOIN room r ON b.room_id = r.id
	INNER JOIN hotel h ON r.hotel_id = h.id,
	var v
GROUP BY
	h.id,
	h.name,
	v.six_months_days;

-- 7. Perform analysis on the most requested services and their revenue contribution.
SELECT
	s.type,
	COUNT(s.type) booking_count,
	SUM((EXTRACT(DAY FROM(b.check_out - b.check_in)) + 1) * s.price) revenue
FROM
	booking b
	INNER JOIN booking_service bs on b.id = bs.booking_id
	INNER JOIN service s on bs.service_id = s.id
GROUP BY
	s.type
ORDER BY
	booking_count DESC,
	revenue DESC;

-- 8. Identify peak booking periods and recommend staff scheduling optimizations.
WITH next_year AS(
	SELECT
		generate_series(CURRENT_DATE, CURRENT_DATE + INTERVAL '1 year', INTERVAL '1 day') date
)
SELECT
	ny.date,
	COUNT(b.id) FILTER (WHERE r.hotel_id = 1) booking_hotel1,
	COUNT(b.id) FILTER (WHERE r.hotel_id = 2) booking_hotel2,
	COUNT(b.id) FILTER (WHERE r.hotel_id = 3) booking_hotel3,
	COUNT(b.id) FILTER (WHERE r.hotel_id = 4) booking_hotel4,
	COUNT(b.id) FILTER (WHERE r.hotel_id = 5) booking_hotel5
FROM
	booking b
	INNER JOIN room r ON b.room_id = r.id
	INNER JOIN next_year ny ON b.check_in <= ny.date AND ny.date < b.check_out
GROUP BY
	ny.date;
