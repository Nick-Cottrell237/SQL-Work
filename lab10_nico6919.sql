### Use the same coppied _nico6919_salesshort database
use _nico6919_salesshort; 
#1
##Create a stored procedure orderTotal that has the order number
#as input and returns the order total 
#Order total: quantityOrdered * priceEach.

drop procedure if exists orderTotal;
## Creating the Stored Procedure
delimiter //
create procedure orderTotal(IN ordernum varchar(11), OUT totalOrder dec(10,2))
begin
	set totalOrder = 
		(select sum(quantityOrdered * priceEach)
        from orderdetails
        where orderNumber = ordernum 
        group by orderNumber);
end //
delimiter ;

#Write a query that calls on this stored procedure to show what’s the order
#total for order 10100
Call ordertotal('10100', @totalOrder);
select @totalOrder as 'Total for order 10100';

#2
#Create a stored procedure gbSaleP that returns
#"we are loosing money" if the actual profit of the total order is lower than or
#equal to zero.
#"good sale" if the difference between potential profit and actual profit is
#$2500 or lower.
#"bad sale" if the difference between potential profit and actual profit is greater
#than $2500 (6pts).
#Potential Profit: quantityordered * MSRP - quantityordered * buyprice.
#Actual Profit: quantityordered * priceeach - quantityordered * buyprice.
#Write a query that calls on this stored procedure to show what’s the "sales
#type" for orders 10408, 10421 and 10212
drop procedure if exists gbSalep;

delimiter //

create procedure gbSalep(IN orderNO varchar(10), OUT goodbadsell varchar(20))
Begin
	declare actprofit dec(10,2);
    declare potprofit dec(10,2);
    
    set actprofit = 
		(select sum(o.quantityOrdered * (o.priceEach - p.buyPrice))
		from orderdetails o 
		join products p 
		on o.productCode = p.productCode
		where o.orderNumber = orderNO
		group by orderNumber
		);
	set potprofit = 
		(select sum(o.quantityOrdered * (p.MSRP - p.buyPrice))
		from orderdetails o 
		join products p 
		on o.productCode = p.productCode
		where orderNumber = orderNo
		group by orderNumber
		);
	if actprofit <=0 then set goodbadsell = 'We are losing money';
    elseif potprofit - actprofit < 2500 then set goodbadsell = ' Good sale';
    elseif potprofit - actprofit >= 2500 then set goodbadsell = 'Bad sale';
    else set goodbadsell = 'none'; 
    end if;
end //
delimiter ;

call gbSalep(10408, @goodbadsell1);   #Have to call on the functions (run in backround)
call gbSalep(10421, @goodbadsell2);
call gbSalep(10212, @goodbadsell3);
#Then you can use them in a select statement
select @goodbadsell1 as 'order 10480', @goodbadsell2 as 'order 10421', @goodbadsell3 as 'order 10212';
