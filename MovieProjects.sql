USE mavenmovies;
--  PROJECT QUESTIONS PART 1
/*
 1.  We will need a list of all staff members, including their first and last names, 
email addresses, and the store identification number where they work. 
*/
 
 SELECT 
	first_name,
	last_name,
    email,
    store_id
FROM staff;

/*
 2.  We will need separate counts of inventory items held at each of your two stores. 
*/

SELECT 
	store_id,
	COUNT(inventory_id)
FROM inventory
GROUP BY store_id;

/*
3. We will need a count of active customers for each of your stores. Separately, please. 
*/

SELECT 
	store_id,
COUNT(CASE WHEN active = 1 THEN customer_id ELSE NULL END) AS active_customer -- don't use quotation mark with column name 
FROM customer
GROUP BY store_id;

/*
4. In order to assess the liability of a data breach, we will need you to provide a count of all customer email addresses stored in the database. 
*/ 
SELECT  COUNT(DISTINCT email) 
FROM customer;


/*
 5. We are interested in how diverse your film offering is as a means of understanding how likely you are to keep customers engaged in the future. 
 Please provide a count of unique film titles you have in inventory at  each store and then provide a count of the unique categories of films you provide. 
 */ 

SELECT 
     i.store_id,
	 COUNT(DISTINCT title) AS title_count 
FROM film AS f
LEFT JOIN inventory AS i
ON f.film_id = i.film_id
GROUP BY store_id;

-- Correct Answer
SELECT 
     store_id,
	 COUNT(DISTINCT film_id) AS unique_film
FROM  inventory 
GROUP BY store_id;


SELECT COUNT(DISTINCT category_id)
FROM film_category;

/*
 6. We would like to understand the replacement cost of your films. Please provide the replacement cost for the 
 film that is least expensive to replace, the most expensive to replace, and the average of all films you carry. 
 */
 SELECT
	replacement_cost
FROM film
ORDER BY replacement_cost
LIMIT 1;

 SELECT
	replacement_cost
FROM film
ORDER BY replacement_cost DESC
LIMIT 1;

-- Better Answer
 SELECT 
    MAX(replacement_cost) AS max_cost,
    MIN(replacement_cost) AS min_cost,
    AVG(replacement_cost) AS avg_payment
    FROM film;
/*
 7. We are interested in having you put payment monitoring systems and maximum payment processing 
 restrictions in place in order to minimize the future risk of fraud by your staff. Please provide the average 
 payment you process, as well as the maximum payment you have processed. 
*/

SELECT 
	AVG(amount) AS avg_payment,
    MAX(amount) AS max_payment
FROM payment;

/*
8.We would like to better understand what your customer base looks like. Please provide a list of all customer 
identification values, with a count of rentals they have made all-time, with your highest volume customers at 
the top of the list. 
*/

SELECT 
	customer_id,
	COUNT(rental_id) AS count_rental
FROM rental
GROUP BY customer_id
ORDER BY count_rental DESC;



-- PROJECT QUESTIONS PART 2 -- 
/*
1. My partner and I want to come by each of the stores in person and meet the managers. Please send over 
the managers’ names at each store, with the full address of each property (street address, district, city, and 
country please).
*/

SELECT 
	staff.first_name AS manager_first_name,
    staff.last_name AS manager_last_name,
    address.address AS street_address,
    address.district AS district,
    city.city AS city,
    country.country AS county
FROM store
	INNER JOIN staff ON store.manager_staff_id = staff.staff_id
	INNER JOIN address ON store.address_id = address.address_id
	INNER JOIN city ON address.city_id = city.city_id
    INNER JOIN country ON city.country_id = country.country_id;
    

/*
2. I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, the 
inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/

SELECT 
	i.store_id,
    i.inventory_id,
    f.title,
    f.rating,
    f.rental_rate,
    f.replacement_cost
FROM inventory AS i
	LEFT JOIN film AS f
    ON i.film_id = f.film_id;

/*
3. From the same list of films you just pulled, please roll that data up and provide a summary level overview of 
your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/
SELECT 
	COUNT(inventory_id) AS count_inventory,
    i.store_id AS store,
    f.rating
FROM inventory AS i
	INNER JOIN film AS f ON i.film_id = f.film_id
GROUP BY store_id, f.rating
ORDER BY store_id;

/*
4. Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
 We would like to see the number of films, as well as the average replacement cost, and total replacement 
cost, sliced by store and film category. 
*/

SELECT 
	store_id,
    c.name AS category,
    COUNT(f.film_id) AS num_of_film,
    AVG(replacement_cost) AS avg_replacement_cost,
    SUM(replacement_cost) AS sum_replacement_cost
FROM film AS f 
INNER JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id
INNER JOIN inventory AS i ON i.film_id = fc.film_id
GROUP BY store_id, category;

/* 
5. We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active,  and their full 
addresses – street address, city, and country. 
*/
SELECT 
	first_name,
    last_name,
    store_id,
    active,
    address,
    city,
    country
FROM customer
	LEFT JOIN address ON customer.address_id = address.address_id
    LEFT JOIN city ON address.address_id = city.city_id
    LEFT JOIN country ON city.country_id = country.country_id;
    
/*
6. We would like to understand how much your customers are spending with you, and also to know who your 
most valuable customers are. Please pull together a list of customer names, their total lifetime rentals, and the 
sum of all payments you have collected from them. It would be great to see this ordered on total lifetime value, 
with the most valuable customers at the top of the list. 
*/
SELECT 
	first_name,
    last_name,
    COUNT(p.rental_id) AS total_life_rentals,
    SUM(amount) AS sum_of_payments
FROM customer AS c
INNER JOIN payment AS p ON  c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY sum_of_payments DESC;
/*
7. My partner and I would like to get to know your board of advisors and any current investors. Could you 
please provide a list of advisor and investor names in one table? Could you please note whether they are an 
investor or an advisor, and for the investors, it would be good to include which company they work with. 
*/

SELECT 
	'advisor' AS position,
    first_name,
    last_name,
    'null' AS company_name  --  or just use NULL
FROM advisor
UNION
	SELECT 
    'investor' AS position,
       first_name,
		last_name,
		company_name 
	FROM investor;

/*
8. We're interested in how well you have covered the most-awarded actors. Of all the actors with three types of 
awards, for what % of them do we carry a film? And how about for actors with two types of awards? Same 
questions. Finally, how about actors with just one award?
*/

SELECT 
	COUNT(PERCENTAGE(CASE WHEN awards IN ('Emmy' AND 'Oscar'AND 'Tony') THEN actor_award_id END) ) AS percentage_of_three_award,
	COUNT(PERCENTAGE(CASE WHEN awards IN (('Emmy' AND 'Oscar') OR  ('Emmy' AND 'Tony') OR ('Tony' AND 'Oscar')) THEN actor_award_id END) ) AS percentage_of_two_award,
    COUNT(PERCENTAGE(CASE WHEN awards IN ('Emmy' OR 'Oscar'OR 'Tony') THEN actor_award_id END)) AS percentage_of_one_award
FROM actor_award;


SELECT 
	CASE 
		WHEN awards = 'Emmy, Oscar, Tony ' THEN 'three_award'
		WHEN awards IN ('Emmy, Oscar', 'Emmy, Tony', 'Tony, Oscar') THEN  'two_award'
        ELSE 'one_award'
		END 
        AS num_of_awards,
        AVG(CASE WHEN actor_id IS NULL THEN 0 ELSE 1 END) AS percentage_of_award
FROM actor_award
GROUP BY num_of_awards;
