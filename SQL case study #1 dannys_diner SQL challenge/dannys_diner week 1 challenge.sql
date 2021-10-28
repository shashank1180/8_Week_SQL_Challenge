--Q1.What is the total amount each customer spent at the restaurant?

select	s.customer_id,
		sum(n.price) [total spent amount]
from dannys_diner.sales s 
left join dannys_diner.menu n on s.product_id=n.product_id
group by s.customer_id

--Q2.How many days has each customer visited the restaurant?

select	s.customer_id,
		count(distinct s.order_date) [customer visit]
from dannys_diner.sales s
group by s.customer_id

--Q3.What was the first item from the menu purchased by each customer?

select distinct customer_id,product_name
from(
select	s.customer_id,
		n.product_name,
		s.order_date,
		DENSE_RANK() over(partition by s.customer_id order by s.order_date asc) rownum1
from dannys_diner.sales s 
left join dannys_diner.menu n on s.product_id=n.product_id)z
where rownum1=1

--Q4.What is the most purchased item on the menu and how many times was it purchased by all customers?

select top 1 product_name [most purchased item] 
from(
select	n.product_name,
		count(s.product_id) [how many times it was purchased]
from dannys_diner.sales s 
left join dannys_diner.menu n on s.product_id=n.product_id
group by n.product_name)z
order by [how many times it was purchased] desc

--Q5.Which item was the most popular for each customer?

select customer_id,product_name 
from(
	select customer_id,product_name,cnt,DENSE_RANK() over(partition by customer_id order by cnt desc) rownum1
	from
		(select	s.customer_id,
				n.product_name,
				count(s.product_id) cnt
		from dannys_diner.sales s 
		left join dannys_diner.menu n on s.product_id=n.product_id
		group by s.customer_id,
				n.product_name)z
	)y
where rownum1=1

--Q6.Which item was purchased first by the customer after they became a member?

select customer_id,product_name,order_date
from
	(select	m.customer_id,
			n.product_name,
			s.order_date,
			ROW_NUMBER() over(partition by m.customer_id order by s.order_date asc) rownum1
	from dannys_diner.members m
	left join dannys_diner.sales s on m.customer_id=s.customer_id
	left join dannys_diner.menu n on s.product_id=n.product_id
	where s.order_date>=m.join_date)z
where rownum1=1

--Q7.Which item was purchased just before the customer became a member?

select customer_id,product_name,order_date
from
	(select	m.customer_id,
			n.product_name,
			n.product_id,
			s.order_date,
			DENSE_RANK() over(partition by m.customer_id order by s.order_date desc) rownum1
	from dannys_diner.members m
	left join dannys_diner.sales s on m.customer_id=s.customer_id
	left join dannys_diner.menu n on s.product_id=n.product_id
	where s.order_date<m.join_date)z
where rownum1=1

--Q8.What is the total items and amount spent for each member before they became a member?

 select s.customer_id,count(s.product_id) as total_purchased_items, sum(n.price) as total_spent_amount
 from dannys_diner.sales s
 left join dannys_diner.members m on s.customer_id=m.customer_id
 left join dannys_diner.menu n on s.product_id=n.product_id
 where s.order_date<m.join_date
 group by s.customer_id

 --Q9.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

  select s.customer_id,
		sum(case when m.product_name='sushi' then m.price*20
		else m.price*10 end) as points
 from dannys_diner.sales s
 left join dannys_diner.menu m on s.product_id=m.product_id
 group by s.customer_id

--Q10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
 
select s.customer_id, SUM(
case 
    when s.order_date between m.join_date and DATEADD(day,6,m.join_date) then n.price*20
	when n.product_name='sushi' then n.price*20
    else n.price*10
    end ) AS total_points 
FROM dannys_diner.sales s
 inner join dannys_diner.members m on s.customer_id=m.customer_id
 left join dannys_diner.menu n on s.product_id=n.product_id
 where month(s.order_date)=1
 group by s.customer_id