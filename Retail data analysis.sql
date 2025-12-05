
create database [Retail data analysis]

use [Retail data analysis]
select * from transactions
select * from Customer
select * from prod_cat_info

--------------------------------------------------------------------------CASESTUDY------------------------------------------------------------------------------

--===========================================================DATA PREPARATION  AND UNDERSTANDING======================================================
--Q1.   What is the total number of rows in each of the 3 tables in the database?

select  ' Product' as [Total Product] ,
count(prod_cat_code) as [No. of rows] 
from prod_cat_info

union

select ' Customer' as [Total Customer] ,
count(Customer_id) as[No. of rows] 
from customer

union

select ' Transaction' as [Total Transaction] ,
count(Transaction_id) as [No. of rows] 
from transactions

--Q2.. What is the total number of transactions that have a return? 

select Count(transaction_id) as Trans_id,total_amt
from Transactions
where total_amt<=0
group by total_amt

--Q3.. As you would have noticed, the dates provided across the datasets are not in a 
--correct format. As first steps, pls convert the date variables into valid date formats 
--before proceeding ahead

select * from Transactions


--Q4. What is the time range of the transaction data available for analysis? Show the 
--output in number of days, months and years simultaneously in different columns. 

select min(tran_date)as Starting_date,
max(tran_date)as Ending_date,
datediff(year,min(tran_date),
max(tran_date) )as Numberofyear,
datediff(month,min(tran_date),max(tran_date)) as Numberofmonths,
datediff(DAY,min(tran_date),max(tran_date)) as Numberofdates
from Transactions

--Q5. Which product category does the sub-category “DIY” belong to? 

select prod_cat,prod_subcat
from prod_cat_info
where prod_subcat= 'DIY'


--===============================================================DATA ANAYLSIS===================================================================


--Q1.. Which channel is most frequently used for transactions? 

--Most repeated Channel is e-shop from All channels
select top 1  Store_type ,count (Store_type) AS Count_storetype from Transactions
group by Store_type 
order by count(Store_type) desc



--Q2. What is the count of Male and Female customers in the database?

Select 'Count_M' as Total_male,
Count(Gender) as [No.of Rows]
from Customer 
where Gender= 'M' 

Union

Select 'Count_F' as Total_female,
Count(Gender)as [No.of Rows]
from Customer 
where Gender= 'F'

--Q3.From which city do we have the maximum number of customers and how many? 

select top 1 city_code , count(customer_Id) as MAX_Cust from Customer
group by city_code
order by Count(customer_Id) desc

--Q4.How many sub-categories are there under the Books category?

select Count(prod_cat) as Tot_Books_Cat
from prod_cat_info
where prod_cat = 'Books'

--Q5. What is the maximum quantity of products ever ordered? 

select *  from Transactions
where Qty = 5

--Q6. What is the net total revenue generated in categories Electronics and Books? 

select prod_cat,sum(total_amt) as Tot_amt 
from Transactions as T
inner join prod_cat_info as P
on P.prod_cat_code= T.prod_cat_code
where prod_cat = 'Electronics'
group by  prod_cat

union all

select  prod_cat,sum(total_amt) as Tot_amt
from Transactions as T
inner join prod_cat_info as P
on P.prod_cat_code= T.prod_cat_code
where prod_cat = 'Books' 
group by  prod_cat

--Q7. How many customers have >10 transactions with us, excluding returns? 

select count(*)  as Count_cust from(

               select   distinct cust_id from Transactions
               group by  cust_id
               having Count(transaction_id)>10

             ) as X

--Q8. What is the combined revenue earned from the “Electronics” & “Clothing” 
--categories, from “Flagship stores”? 

select Sum(total_amt) as[ Revenue_Electronic Clothing]from Transactions as T
inner join prod_cat_info as P
on P.prod_cat_code= T.prod_cat_code
where Store_type = 'Flagship store'
and 
prod_cat in ('Electronics','Clothing')

--Q9.. What is the total revenue generated from “Male” customers in “Electronics” 
--category? Output should display total revenue by prod sub-cat.

select prod_subcat,Tot_revenue from (
                                          Select prod_cat,prod_subcat, Gender,sum(total_amt) as Tot_revenue from  Customer as C
                                          inner join Transactions as T
                                          on C.customer_Id = T.cust_id
                                          inner join prod_cat_info as P
                                          on P.prod_cat_code = T.prod_cat_code
                                          where prod_cat = 'Electronics' 
                                                        and 
                                           Gender = 'M'
                                           group by  prod_cat,prod_subcat, Gender

                                       )as T1 


--Q10.What is percentage of sales and returns by product sub category; display only top 
--5 sub categories in terms of sales?

select top 5 A.prod_subcat,Percentage_of_sales,Percentage_of_returns  from
(select  prod_subcat,
 sum(case 
      when total_amt > 0 
            then total_amt
               else 0
                    end) as Sales,
                    (sum(total_amt)* 100.0)/(select sum(total_amt) from Transactions) as Percentage_of_sales
 from Transactions as T
inner join prod_cat_info as P
on T.prod_subcat_code= P.prod_sub_cat_code
and 
T.prod_cat_code=P.prod_cat_code
where Qty>0
group by prod_subcat) as A 
join 
(
select  prod_subcat,
 sum(case 
      when total_amt < 0 
            then total_amt
               else 0
                    end) as [Returns],
                    (sum(total_amt)* 100.0)/(select sum(total_amt) from Transactions where Qty<0) as Percentage_of_returns
 from Transactions as T
inner join prod_cat_info as P
on T.prod_subcat_code= P.prod_sub_cat_code
and 
T.prod_cat_code=P.prod_cat_code
where Qty<0
group by prod_subcat
) as Y 
on A.prod_subcat=Y.prod_subcat


--Q11. For all customers aged between 25 to 35 years find what is the net total revenue 
--generated by these consumers in last 30 days of transactions from max transaction 
--date available in the data? 
select revenue,tran_date,Age from(

                select Sum(total_amt) as revenue  ,DATEDIFF(year,DOB,max(tran_date)) as Age , dob, tran_date
                from Customer as C
                inner join Transactions as T
                on T.cust_id = C.customer_Id
                group by  DOB,tran_date
                having tran_date >=(select  DATEADD(day,-30,max(convert(date,tran_date,105))) as MAX_date from Transactions)
               ) as X
               where age between 25 and 35
              

--Q12.Which product category has seen the max value of returns in the last 3 months of 
--transactions?


select  top 1 prod_cat, abs(sum(total_amt)) as MAX_TOT
from Transactions as T
inner join prod_cat_info as P
on T.prod_cat_code = P.prod_cat_code
 AND    
 t.prod_subcat_code = p.prod_sub_cat_code
where total_amt<0 
and
 t.tran_date between (select dateadd(MONTH,-3,(select max(tran_date) from Transactions)) )
and
(select max(tran_date)from Transactions)
group by P.prod_cat
order by MAX_TOT desc

--Q13.Which store-type sells the maximum products; by value of sales amount and by 
--quantity sold? 

select top 1 Store_type,sum(Qty) as MAX_Qty, sum(total_amt) as sales  from Transactions
where Qty >0
group by Store_type
order by sales desc

--Q14. What are the categories for which average revenue is above the overall average. 

select prod_cat, avg(total_amt) as AVG_Tot 
from prod_cat_info as P
inner join Transactions as T 
on P.prod_cat_code=T.prod_cat_code
group by prod_cat
having avg(total_amt) >(select avg(total_amt) from Transactions)

--Q15. . Find the average and total revenue by each subcategory for the categories which 
-- are among top 5 categories in terms of quantity sold.

 select  prod_subcat_code,sum(total_amt) as Tot_Revenue, 
 avg(total_amt) as Tot_Avg 
 from Transactions 
 where Qty >0
 and 
          prod_cat_code in (select  top 5prod_cat_code 
                            from Transactions
                            where Qty>0
                            group by prod_cat_code
                            order by sum(Qty) desc)
group by prod_subcat_code
order by prod_subcat_code

    




