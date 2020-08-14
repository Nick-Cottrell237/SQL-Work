#Copy salesshort to _nico6919_salesshort table by table
use _nico6919_salesshort;
drop table orders;
 create table orders 
 select * from salesshort.orders;

drop table productlines;
create table productlines 
select * from salesshort.productlines;

drop table products;
create table products
select * from salesshort.products;

drop table customers;
create table customers
select * from salesshort.customers;

drop table orderdetails;
create table orderdetails
select* from salesshort.orderdetails;

drop table msrpaudit;
create table msrpaudit
select * from salesshort.msrpaudit;

select * from msrpaudit;

### 1. create a funcation showing the days between the order date
#and the shipped date for all shipped orders in the salesshort daaabase.
drop function if exists daysToShip;

delimiter //                #### has to be a space between delimiter and //
create function daysToShip (status varchar(20), dateOrdered date, dateShipped date) returns varchar(20)
deterministic
begin
declare noDays varchar(20);
   
    If status = 'Shipped' then set noDays = dateShipped - dateOrdered;
    else set noDays = 'Status != "Shipped"' ;
    end if;
   
    return (noDays);
end //
delimiter ;                 #########Has to be a space between delimiter and ; ########
## Check to make sure the function worked#
select *, daystoship(status, orderdate, shippeddate) as 'No. Days To Ship' from orders;

#Create a function showing the total revenue (qty * priceeach) for each line item in the salesshort database
drop function if exists totalRev;

delimiter //
create function toatlRev (qty integer,  priceeach decimal(10,2)) returns decimal(10,2)
deterministic
begin
	declare rev decimal(10,2);
    set rev = qty * priceeach;
    return (rev);
end//
delimiter ;  
#Make sure the function works (qty is quantityOrdered in the orderdetails table) 
select *, totalrev(quantityOrdered, priceeach) as 'Total Revenue' from orderdetails;

#Create a function that returns:‘we are loosing money’ if the actual profit for a line item 
#((qty * priceeach) - (qty * buyprice)) is lower than or equal to zero.
#‘bad sale’ if the difference between potential profit and actual profit is greater than $1000, and
#‘good sale’ if the difference between potential profit and actual profit is $1000 or lower
		#Potential Profit: quantityordered * MSRP - quantityordered * buyprice.
		#Actual Profit: quantityordered * priceeach - quantityordered * buyprice.
# 		### return longtext, eg: 'We are losing money', 'bad sale', 'good sale' 

drop function if exists moneyStatus;
delimiter // 
create function moneyStatus (FNqty integer, FNpriceEach decimal(10,2), FNbuyPrice decimal(10,2), FNmsrp decimal(10,2)) returns longtext
deterministic
begin
	declare potprofit decimal(14,2); 
    declare actprofit decimal(14,2);
    declare saletype longtext;
    
    set potprofit = (FNqty * FNmsrp) - (FNqty * FNbuyPrice);
    set actprofit = (FNqty * FNpriceEach) - (FNqty * FNbuyPrice);
    
    case
    when actprofit <= 0 then set saletype = 'We are losing money';
    when potprofit - actprofit > 1000 then set saletype = 'Bad sale'; 
    when  potprofit - actprofit <= 1000 then set saletype = 'Good sale';
    end case;
    
return(saletype);
end //
delimiter ; 

#Write a SELECT statement with the function from step 3 that shows the number and percentage of:
#‘good sale’ sales
#‘bad sale’ sales
#‘we are loosing money’ sales

#show potential profit, actual profit, and type of sale...
select ordernumber,p.productcode, quantityordered, priceEach, buyPrice, MSRP,
quantityOrdered* MSRP - quantityOrdered * buyPrice as 'potential Profit',
quantityOrdered* priceeach -quantityordered * buyPrice as 'actual Profit',
moneyStatus(quantityOrdered,priceeach,buyPrice, MSRP) as 'type of sale' from orderdetails od
join products p on od.productcode =p.productcode ;

#now find the percentage of each: Going to need to sub-queery with the above code
select typeOfSale, count(*) as'Line items',
	(select count(*) from orderdetails) as 'Total line items',
    count(*)/(select count(*) from orderdetails)*100 as 'percent' from
		## Sub-queery with the code above ##
        (select ordernumber, p.productcode, quantityordered, priceEach, buyPrice, MSRP,
			(quantityOrdered * MSRP) - (quantityOrdered *buyPrice) as 'Potential Profit',
			(quantityOrdered * priceEach) - (quantityOrdered * buyPrice) as 'Actual profit',
			moneyStatus(quantityOrdered, priceeach, buyPrice, MSRP) as 'typeOfSale' from orderdetails od
			join products p on od.productcode = p.productcode) sq #Every derived table must have alias (sq = subqueery)
		### End sub-queery and group by typeOfSale
	group by typeOfSale; 
