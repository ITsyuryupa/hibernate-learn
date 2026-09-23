--Кто летел позавчера рейсом Минск (MNK) - Лондон (LDN) на месте B1?

SELECT t.passenger_name
FROM flight f
JOIN airport a
ON f.arrival_airport_code = a.code
JOIN ticket t ON f.id = t.flight_id
WHERE f.departure_airport_code = 'MNK'          -- вылет из Минска
  AND f.arrival_airport_code   = 'LDN'          -- прилёт в Лондон
  AND f.departure_date >= CURRENT_DATE - INTERVAL '2 day'
  AND f.departure_date <  CURRENT_DATE - INTERVAL '1 day'   -- «позавчера»
  AND t.seat_no = 'B1';


SELECT f.flight_no,
       s.seat_no,
       COUNT(s.seat_no)
FROM flight f
    JOIN ticket t ON f.id = t.flight_id
    LEFT JOIN aircraft ar ON ar.id = f.aircraft_id
    JOIN seat s ON ar.id = s.aircraft_id
WHERE f.arrival_date::date = '2020-06-14'
and f.flight_no = 'MN3002'
GROUP BY f.flight_no, s.seat_no;



