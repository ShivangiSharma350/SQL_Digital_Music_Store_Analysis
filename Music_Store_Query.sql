/*1.Who is the senior most employee based on job title?*/
select * from employee order by levels desc limit 1;

/*2.Which countries have the most Invoices?*/
select * from invoice;
select billing_country, count(billing_country) from invoice 
group by 1 
order by 2 desc
limit 1;

/*3.What are top 3 values of total invoice?*/
select total from invoice
order by 1 desc 
limit 3;

/*4.Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals?*/
select billing_city, sum(total) as total_invoice from invoice
group by 1
order by 2 desc
limit 1;

/*Who is the best customer? 
The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money*/
select customer.customer_id,first_name,last_name, sum(total) as total_spending 
from customer
join invoice on invoice.customer_id = customer.customer_id
group by 1
order by 4 desc
limit 1;

/*Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A*/
select distinct first_name, last_name, email from customer
join invoice on invoice.customer_id = customer.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by email;

/*Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands*/
select artist.name, count(artist.artist_id) from artist
join album on album.artist_id = artist.artist_id
join track on track.album_id = album.album_id
join genre on genre.genre_id = track.genre_id 
where genre.name like 'Rock'
group by artist.artist_id
order by 2 desc
limit 10;

/*8.Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. 
Order by the song length with the longest songs listed first */
select name as song_name, milliseconds as song_length_in_milliseconds from track
where milliseconds >
(select avg(milliseconds) from track)
order by 2 desc;

/*9.Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent*/
select customer.customer_id,first_name||' '||last_name as customer_name, 
artist.name as artist_name,
sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
from invoice
join customer on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by 1,2,3
order by 4 desc;


/*10.We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres */
With popular_genre as
(
	select billing_country, genre.name,genre.genre_id, 
	count(invoice_line.quantity) as purchase, 
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
	from invoice
	join invoice_line on invoice.invoice_id = invoice_line.invoice_id
	join track on invoice_line.track_id = track.track_id
	join genre on genre.genre_id = track.genre_id
	group by 1,2,3
	order by 1
	)
select * from popular_genre where RowNo<=1;


/*11.Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount*/
with top_cutomer_per_country as(
	select billing_country,customer.first_name||' '||customer.last_name as customer_name, sum(total) as total_spending,
	row_number() over (partition by billing_country order by sum(total) desc) as row_no from invoice
join customer on customer.customer_id = invoice.customer_id
group by 1,2
order by 1
)

select * from top_cutomer_per_country where row_no<=1;