-- A log of SQL queries executed as I solve the mystery.

-- Obtain details of the crime scene report from July 28, 2021
SELECT description 
FROM crime_scene_reports
WHERE year = 2021 
AND month = 7 
AND day = 28
AND street = "Humphrey Street";

-- Time: 10:15 am at Humphrey Street bakery
-- 3 witnesses

-- Get the witnesses transcript
SELECT transcript 
FROM interviews
WHERE year = 2021 
AND month = 7 
AND day = 28
AND transcript LIKE '%bakery%';

-- Witness 1: check security footage --> look for cars within 10 minutes of the theft 
-- Witness 2: theft was withdrawing money at an ATM on Leggett Street before the crime scene
-- Withness 3: taking the earliest flight out of Fiftyville on July 29th 
-- Bakery owner: whisper into a phone for half an hour

-- Determine the name of the thief 
SELECT name
FROM people
-- Use the transcript of Witness 1: check for the people's license plate that appears within 10 minute of the theft
WHERE license_plate IN
(
    SELECT license_plate
    FROM bakery_security_logs
    WHERE year = 2021 
    AND month = 7 
    AND day = 28
    AND hour = 10
    AND minute BETWEEN 15 AND 25
    AND activity = 'exit'
)

-- Use the transcript of Withness 2: Check the person whose bank ATM withdraw history on Leggett Street on July 28, 2021
AND id IN 
(
    SELECT person_id 
    FROM bank_accounts 
    JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number
    WHERE year = 2021
    AND month = 7
    AND day = 28
    AND atm_location = 'Leggett Street'
    AND transaction_type = 'withdraw'
)

-- Use the transcript of Withness 3: Check for the people passport number that is in the earliest flight 
AND passport_number IN 
(
    SELECT passport_number 
    FROM passengers 
    WHERE flight_id IN 
    (
        SELECT id 
        FROM flights 
        WHERE year = 2021
        AND month = 7
        AND day = 29
        -- the flight's original location is at Fiftyville
        AND origin_airport_id =
        (
            SELECT id 
            FROM airports
            WHERE city = 'Fiftyville'
        )
        -- to filter only the earliest flight
        ORDER BY hour, minute
        LIMIT 1
    )

-- Use the bakery owner's transcript: check for the person whose phone number appears in the caller 
AND phone_number IN 
(
    SELECT caller
    FROM phone_calls 
    WHERE year = 2021
    AND month = 7
    AND day = 28
    -- the duration is about half an hour but we should expand the duration time frame to 60 minutes because the owner only gives an estimate
    AND duration < 60
)
);

-- Query result: Bruce is the thief


-- Find the destination city of the earliest flight from Fiftyville
SELECT city
From airports
WHERE id IN
(
    SELECT destination_airport_id 
    FROM flights 
    WHERE year = 2021
    AND month = 7
    AND day = 29
    -- Filter only the first/earliest flight from Fiftyville
    AND origin_airport_id =
    (
        SELECT id 
        FROM airports
        WHERE city = 'Fiftyville'
    )
    ORDER BY hour, minute
    LIMIT 1
);

-- Query Result: New York City

-- Determine the name of the accomplice who helped Bruce escape
SELECT name 
FROM people
-- Bruce called the accomplice, so the accomplice phone number should be in the receiver log
JOIN phone_calls ON people.phone_number = phone_calls.receiver
WHERE year = 2021
AND month = 7
AND day = 28
AND duration < 60
-- Bruce is the caller
AND phone_calls.caller = 
(
    SELECT phone_number
    FROM people
    WHERE name = 'Bruce'
);

-- Query Result: Robin
