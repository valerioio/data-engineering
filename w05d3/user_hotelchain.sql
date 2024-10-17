DROP OWNED BY manager;
DROP OWNED BY receptionist;

DROP ROLE manager;
DROP ROLE receptionist;

CREATE ROLE manager WITH LOGIN PASSWORD 'manager_password';
CREATE ROLE receptionist WITH LOGIN PASSWORD 'receptionist_password';

GRANT ALL PRIVILEGES ON DATABASE hotelchain TO manager;
GRANT SELECT ON hotel, room, guest, staff, service, booking, booking_service TO receptionist;
