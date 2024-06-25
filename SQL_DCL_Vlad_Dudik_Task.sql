-- Create a new user with the username "rentaluser" and the password "rentalpassword".
-- Give the user the ability to connect to the database but no other permissions.
DO $$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rentaluser') THEN
            CREATE ROLE rentaluser LOGIN PASSWORD 'rentalpassword';
        END IF;
END $$;

-- Grant "rentaluser" SELECT permission for the "customer" table.
-- Сheck to make sure this permission works correctly—write a SQL query to select all customers.
GRANT SELECT ON TABLE customer TO rentaluser;

SET ROLE rentaluser;

SELECT *
FROM customer;

RESET ROLE;

-- Create a new user group called "rental" and add "rentaluser" to the group. 
DO $$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rental') THEN
            CREATE ROLE rental;
        END IF;
END $$;

-- Grant the "rental" group INSERT and UPDATE permissions for the "rental" table.
-- Insert a new row and update one existing row in the "rental" table under that role. 
GRANT rental TO rentaluser;
GRANT INSERT, UPDATE, SELECT ON TABLE rental TO rental;
GRANT USAGE ON SEQUENCE rental_rental_id_seq TO rental;

SET ROLE rentaluser;

UPDATE rental
SET return_date = '2024-06-22'
WHERE rental_id = 6;

RESET ROLE;

ALTER TABLE payment DISABLE ROW LEVEL SECURITY;
ALTER TABLE rental DISABLE ROW LEVEL SECURITY;

SET ROLE rentaluser;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES ('2030-06-22', 2, 3, NULL, 2);

RESET ROLE;

-- Revoke the "rental" group's INSERT permission for the "rental" table.
-- Try to insert new rows into the "rental" table make sure this action is denied.
REVOKE INSERT ON rental FROM rental;

SET ROLE rentaluser;

INSERT INTO rental (rental_date, inventory_id, customer_id, return_date, staff_id)
VALUES ('1999-06-22', 2, 3, NULL, 2);

RESET ROLE;

-- Create a personalized role for any customer already existing in the dvd_rental database.
-- The name of the role name must be client_{first_name}_{last_name} (omit curly brackets).
-- The customer's payment and rental history must not be empty.
-- Configure that role so that the customer can only access their own data in the "rental" and "payment" tables.
-- Write a query to make sure this user sees only their own data.

-- id=15 Helen Harris
DO $$
    BEGIN
        IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'client_helen_harris') THEN
            CREATE ROLE client_helen_harris LOGIN PASSWORD 'bread';
        END IF;
END $$;

GRANT SELECT ON payment, rental TO client_helen_harris;

ALTER TABLE payment ENABLE ROW LEVEL SECURITY;
ALTER TABLE rental ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS clients_payment ON payment;
DROP POLICY IF EXISTS clients_rental ON rental;

CREATE POLICY clients_payment ON payment
	FOR SELECT
	TO client_helen_harris
	USING (customer_id = 15);

CREATE POLICY clients_rental ON rental
	FOR SELECT
	TO client_helen_harris
	USING (customer_id = 15);

SET ROLE client_helen_harris;

SELECT *
FROM rental;
SELECT *
FROM payment;
	
RESET ROLE;

