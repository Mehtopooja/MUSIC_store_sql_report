select * from album
// q1.--- who is the senior most employee based on job title?
select * from employee
ORDER BY levels desc
 limit 1
 
 //q2.---which countries have the most Invoices?
 
 select * from invoice
 select COUNT(*) as c ,billing_country 
 from invoice
 group by billing_country
 order by c desc
 
 //q3.-- what are top 3 values of total invoice?
 select * from invoice
 order by total desc
 limit 3 
 
  select * from invoice


--q4 which country has the best customers? we wouldn like to throw a promotional music
 festival in the city we made the most money.write a query that returns one city that has 
 the highest sum of invoice totals. return both the city name & sum of all invoice totals  
  
  select SUM (total) as invoice_total,billing_city
  from invoice
  group by billing_city
  order by invoice_total desc
  limit 5
 
 
 ---q5 who is the best customer ? the customer who has spent the most money will be decleared
  the best customer.write a query that returns the persons who has spent the most money?
 
  select * from customer
  
  select customer.customer_id,customer.first_name,customer.last_name, SUM(invoice.total) as total
  from customer
  join invoice ON customer.customer_id = invoice.customer_id
  GROUP BY customer.customer_id
  ORDER BY total DESC
  limit 1
  
  --q6 write query to return the email,first name ,last name & Genre of all rock music
  listeners.returns your list ordered alphabetically by email starting with A?
  
  SELECT DISTINCT email,first_name,last_name
  FROM customer
  JOIN invoice ON customer.customer_id = invoice.customer_id
  JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
  WHERE track_id IN(
	  SELECT track_id FROM track
	  JOIN genre ON track.genre_id=genre.genre_id
	  where genre.name LIKE 'Rock'
  )
  ORDER BY  email;
  
  -- q6 lets invite the artist who have written the most rock music in our dataset
  . write a query that returns the artist name and total track count of the top 10 rock bandsz?
  
  
  
  SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
  FROM track
  JOIN album ON album.album_id = track.album_id
  JOIN artist ON artist.artist_id =album.artist_id
  JOIN genre ON genre.genre_id =track.genre_id
  WHERE genre.name LIKE 'Rock'
  GROUP BY artist.artist_id
  ORDER BY number_of_songs DESC
  LIMIT 10;
  select * from track
  
  -- Return all the track names that have a song length longer than the average song length
  --return the name and milliseconds for each track.order by the song length with the longest 
  songs?
  --listed first?
  
  
  SELECT name,milliseconds
  FROM track 
  WHERE milliseconds > (
	  SELECT AVG(milliseconds) AS avg_track_length
	  FROM track)
	  ORDER BY milliseconds DESC;
	  
	  
-- q7 find how much amount spent by each customer on artist? write a query to return 
customer name, artist name and total spent?
	  
	  WITH best_selling_artist AS (
		  SELECT artist.artist_id AS artist_id,artist.name AS artist_name,
          SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
		  FROM invoice_line
		  JOIN track ON track.track_id= invoice_line.track_id
		  JOIN album ON album.album_id = track.album_id
		  JOIN artist ON artist.artist_id = album.artist_id
		  GROUP BY 1
		  ORDER BY 3 DESC
		  LIMIT 1
)
SELECT c.customer_id,c.first_name,c.last_name,bsa.artist_name,
SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id =t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;
		  
---q5 we want to find out the most popular music Genre for each country.
-- ( we determine the most popular genre as the genre with the highst amount of purchases
)
WITH popular_genre AS 
( 
	SELECT COUNT(invoice_line.quantity)AS purchases,customer.country,genre.name,genre.genre_id,
    ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity)DESC)AS RowNo
	FROM invoice_line
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice_line.track_id
	JOIN track ON track.track_id =invoice_line.track_id
	JOIN genre ON genre.genre_id =track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 

) ,

--METHOD 2
------------------------------------------------------------------------------------

  
 WITH sales_per_country AS (
    SELECT COUNT(*) AS purchases_per_genre, customer.country, genre.name, genre.genre_id
    FROM invoice_line
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY 2, 3, 4
),
max_genre_per_country AS (
    SELECT MAX(purchases_per_genre) AS max_genre_number, country
    FROM sales_per_country
    GROUP BY 2
)
SELECT sales_per_country.*
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number; 



--q8 write a query that determine the customer that has spent the most on music for each
country. write a query that returns the country along with the top customer and how 
much they spent .for countries where the top customer and how much they spent for
countries where the top amount spent is shared, provide all customer  who spent this amount?


  WITH Customer_with_country AS (
       SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	  ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM (total)DESC) AS RowNo
	  FROM invoice 
	  JOIN customer ON customer.customer_id= invoice.customer_id
	  GROUP BY 1,2,3,4
	  ORDER BY 4 ASC,5 DESC )
SELECT * FROM Customer_with_country where RowNo <= 1  
  
  
  