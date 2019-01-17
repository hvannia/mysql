USE sakila;
--  1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name FROM actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT(UPPER(first_name),' ', UPPER(last_name)) AS `Actor Name` FROM actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name  FROM actor
WHERE first_name='Joe';

-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name  FROM actor
WHERE last_name LIKE '%GEN%'; 

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name  FROM actor
WHERE last_name LIKE '%LI%' 
ORDER BY last_name, first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan','Bangladesh','China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so 
-- create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`,
--  as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor 
ADD COLUMN description BLOB;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

--  * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*) AS 'count' FROM actor
GROUP BY (last_name);

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name , COUNT(*) AS `count`
FROM actor
GROUP BY last_name
HAVING `count`>1;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
UPDATE actor SET first_name='HARPO' WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name = 'GROUCHO' 
WHERE first_name='HARPO' AND actor_id <> 0;

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
CREATE TABLE address (
	address_Id INT NOT NULL AUTO_INCREMENT,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20) NOT NULL,
    city_Id SMALLINT NOT NULL,
    postal_code VARCHAR(10),
    phone VARCHAR(10) NOT NULL,
    PRIMARY KEY(address_Id),
    CONSTRAINT `fk_cityId` FOREIGN KEY (city_Id) REFERENCES city(city_Id));
    
-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, a.address
FROM staff AS s 
JOIN address AS a ON s.address_id = a.address_id;

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT CONCAT(s.first_name,' ', s.last_name), sum(p.amount) 
FROM payment as p
JOIN staff AS s ON p.staff_id=s.staff_id
WHERE MONTH(payment_date)=8  AND YEAR(payment_date)=2005
GROUP BY s.staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title , COUNT(fa.actor_id)
FROM film as f
INNER JOIN film_actor as fa ON fa.film_id = f.film_id
GROUP BY f.film_id;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT COUNT(*) FROM inventory WHERE film_id in (SELECT film_id FROM film WHERE title = 'Hunchback Impossible');

-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
SELECT c.customer_id, CONCAT( c.last_name,', ',c.first_name) AS customer ,SUM(p.amount) 
FROM payment p 
JOIN customer as c ON p.customer_id=c.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` 
-- have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT f.title, 
(SELECT name from language WHERE language_id = f.language_Id AND name='English' )
FROM film AS f
	WHERE title LIKE 'K%' OR title LIKE 'Q%';

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT CONCAT(last_name,', ',first_name) FROM actor	
WHERE actor_id  IN (SELECT actor_id FROM film_actor
WHERE film_id = (SELECT film_id FROM film WHERE title='Alone Trip'));

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
SELECT CONCAT(c.last_name,', ',c.first_name)  AS `customer`, c.email,  CONCAT(a.address,' ,', co.country) AS address
FROM customer AS c
JOIN address AS a ON a.address_id = c.address_id
JOIN city AS ci ON ci.city_id=a.city_id
JOIN country AS co ON co.country_id= ci.country_id
WHERE co.country='Canada';

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title, cat.name  
FROM film AS f
JOIN film_category AS fc ON f.film_id = fc.film_id
JOIN category AS cat ON cat.category_id = fc.category_id
WHERE cat.name='Family';

-- * 7e. Display the most frequently rented movies in descending order.
-- rental - inventory- film
SELECT f.title, count(r.rental_id)	AS rentals
FROM film f 
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY rentals desc;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT  st.store_id AS store, SUM(p.amount) AS sales
FROM payment p 
JOIN staff AS s ON p.staff_id = s.staff_id
JOIN store AS st ON st.store_id = s.store_id
GROUP BY st.store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id AS store, ci.city ,co.country
FROM store AS s
JOIN address AS a ON a.address_id = s.address_id
JOIN city AS ci ON ci.city_id = a.address_id
JOIN country AS co ON co.country_id = ci.country_id;

-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: 
-- category, film_category, inventory, payment, and rental.)
 SELECT cat.name, CONCAT('$', FORMAT(SUM(p.amount), 2)) AS sales
 FROM category as cat
 JOIN film_category AS fc ON fc.category_id= cat.category_id
 JOIN film AS f ON f.film_id = fc.film_id
 JOIN inventory AS i ON i.film_id = f.film_id
 JOIN rental AS r ON r.inventory_id = i.inventory_id
 JOIN payment AS p ON p.rental_id  = r.rental_id
 GROUP BY cat.name
 ORDER BY sales desc;
 
-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
--  Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_genres AS 
SELECT cat.name, CONCAT('$', FORMAT(SUM(p.amount), 2)) AS sales
 FROM category as cat
 JOIN film_category AS fc ON fc.category_id= cat.category_id
 JOIN film AS f ON f.film_id = fc.film_id
 JOIN inventory AS i ON i.film_id = f.film_id
 JOIN rental AS r ON r.inventory_id = i.inventory_id
 JOIN payment AS p ON p.rental_id  = r.rental_id
 GROUP BY cat.name
 ORDER BY sales desc ;
 

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_genres;
-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_genres;

/*## Uploading Homework

* To submit this homework using BootCampSpot:

  * Create a GitHub repository.
  * Upload your .sql file with the completed queries.
  * Submit a link to your GitHub repo through BootCampSpot. */
 