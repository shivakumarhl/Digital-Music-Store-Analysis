/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city 
       we made the most money. Write a query that returns one city that has the highest sum of invoice 
	   totals. Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best 
       customer. Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;



/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
       Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


/* Method 2 */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
     Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/*Q8: Return all the track names that have a song length longer than the average song length. Return the 
      Name and Milliseconds for each track. Order by the song length with the longest songs listed first.*/

select * from track;

SELECT name, milliseconds 
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) AS avg_track_length
					 FROM track)
ORDER BY milliseconds DESC;



/* Q9. Find how much amount spent by each customer on artists? Write a query to return customer name, 
       artist name and total spent. */

select * from customer;
select * from album;
select * from artist;
select * from invoice;
select * from invoice_line;
select * from track;

with best_selling_artist as (
					select ar.artist_id, ar.name as artist_name, 
					sum(il.unit_price * il.quantity) as total_sales
					from invoice_line il
					join track t on il.track_id = t.track_id
					join album al on al.album_id = t.album_id
					join artist ar on ar.artist_id = al.artist_id
					join invoice i on i.invoice_id = il.invoice_id
					group by ar.artist_id
					order by total_sales desc limit 1) 

select c.customer_id, c.first_name, c.last_name, bsa.artist_name, 
sum(incl.unit_price * incl.quantity) as amount_spent
from customer c
join invoice inc on inc.customer_id = c.customer_id
join invoice_line incl on incl.invoice_id = inc.invoice_id
join track tk on tk.track_id = incl.track_id
join album alb on alb.album_id = tk.album_id
join best_selling_artist bsa on alb.artist_id = bsa.artist_id
group by 1,2,3,4
order by 5 desc;


/* Q10. We want to find out the most popular music Genre for each country. We determine the most popular 
      genre as the genre with the highest amount of purchases. Write a query that returns each country 
      along with the top Genre. For countries where the maximum number of purchases is shared return 
      all Genres. */
	  
select * from customer;

with popular_genre as (
				select c.country, g.genre_id, g.name as genre_name, count(il.quantity) as purchases,
				row_number() over(partition by c.country order by count(il.quantity) desc) as Row_No
				from customer c 
				join invoice i on c.customer_id = i.customer_id
				join invoice_line il on il.invoice_id = i.invoice_id
				join track t on t.track_id = il.track_id
				join genre g on g.genre_id = t.genre_id
				group by 1,2,3
				order by 1 asc, 4 desc)
select * from popular_genre
where Row_No <= 1;



/* Q11. Write a query that determines the customer that has spent the most on music for each country. 
      Write a query that returns the country along with the top customer and how much they spent. For 
      countries where the top amount spent is shared, provide all customers who spent this amount. */
	  
select * from customer;
select * from invoice_line;
select * from invoice;

with cust_with_country as (
				SELECT c.country, c.first_name, c.last_name, c.customer_id,
				sum(i.total) as amount_spent,
				row_number() over(partition by c.country order by sum(i.total) desc) as Row_No
				from customer c
				join invoice i on c.customer_id = i.customer_id
				group by 1,2,3,4
				order by 1 asc, 5 desc)
select *
from cust_with_country
where Row_No <= 1;

-- OR

with cust_with_country as (
				SELECT c.country, c.first_name, c.last_name, c.customer_id, 
				sum(il.unit_price * il.quantity) as amount_spent,
				row_number() over(partition by c.country order by sum(il.unit_price * il.quantity) desc) as Row_No
				from customer c
				join invoice i on c.customer_id = i.customer_id
				join invoice_line il on il.invoice_id = i.invoice_id
				group by 1,2,3,4
				order by 1 asc, 5 desc)
select *
from cust_with_country
where Row_No <= 1;











































































