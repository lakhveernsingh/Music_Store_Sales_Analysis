/* Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Q2: Which countries have the most Invoices? */

SELECT billing_country, COUNT(*)
FROM invoice
GROUP BY billing_country
ORDER BY 2 DESC;


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY 2 DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT c.first_name, c.last_name, i.customer_id, SUM(i.total)
FROM invoice i
INNER JOIN customer c ON c.customer_id = i.customer_id
GROUP BY c.first_name, c.last_name, i.customer_id
ORDER BY 4 DESC
LIMIT 1;




/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
INNER JOIN invoice ON c.customer_id = i.customer_id
INNER JOIN invoiceline l ON i.invoice_id = l.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track t
	JOIN genre g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
)
ORDER BY email ASC;



/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT a.artist_id, a.name, COUNT(a.artist_id) AS total_track_count
FROM artist a
INNER JOIN album ab ON a.artist_id = ab.artist_id
INNER JOIN track t ON ab.album_id = t.album_id
INNER JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, a.name
ORDER BY total_track_count DESC
LIMIT 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,miliseconds FROM track
WHERE miliseconds > ( SELECT AVG(miliseconds) AS avg_track_length
	FROM track )
ORDER BY miliseconds DESC;




/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
	SELECT a.artist_id, a.name, SUM(il.unit_price*il.quantity) AS total_sales
	FROM artist a
  INNER JOIN album al ON a.artist_id = al.artist_id
	INNER JOIN track t ON al.album_id = t.album_id
	INNER JOIN invoice_line il ON t.track_id = il.track_id
	GROUP BY 1,2
	ORDER BY total_sales DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN album al ON t.album_id = al.album_id
INNER JOIN best_selling_artist bsa ON al.artist_id = bsa.artist_id
GROUP BY  c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */


WITH popular_genre AS 
(
    SELECT COUNT(il.quantity) AS purchases, c.country, g.name, g.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS row_no
    FROM customer c 
	INNER JOIN invoice i ON c.customer_id = i.customer_id
	INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
  INNER JOIN track t ON il.track_id = t.track_id
	INNER JOIN genre g ON t.genre_id = g..genre_id
	GROUP BY c.country, g.name, g.genre_id
	ORDER BY c.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE row_no <= 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */


WITH Customter_with_country AS (
		SELECT c.customer_id, c.first_name, c.last_name, i.billing_country, SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY i.billing_country ORDER BY SUM(total) DESC) AS row_no 
		FROM customer c
		INNER JOIN invoice i ON c.customer_id = i.customer_id
		GROUP BY c.customer_id, c.first_name, c.last_name, i.billing_country
		ORDER BY i.billing_country ASC, total_spending DESC)
SELECT * FROM customter_with_country WHERE row_no <= 1;

----------------------------------------------------------------------****************************----------------------------------------------------------------------------------------
