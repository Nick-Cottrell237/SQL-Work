#Lab 11: Triggers
#1
#Create an audit table that stores changes to a productCode’s MSRP value from the products
#table (1pt). Include the following fields:productCode, productName, productLine ,MSRP value
#lastUpdate (timestamp), rowValue (i.e., ‘before update’ or ‘after update’).
use _nico6919_salesshort;
##First create the audit tabe

drop table if exists msrpaudit;
create table if not exists `msrpaudit`(
	`productCode` varchar(15),
    `productName` varchar(70),
    `productLine` varchar(50),
    `MSRP` dec(10,2),
    `lastUpdate` timestamp,
    `rowValue` char(20)
);

#2 Now we can create the trigger
#Write a trigger that records the old value of a MSRP while also recording the new value of a
#MSRP into the ‘audit table’ created above after an update to a MSRP value has occurred. For
#the column lastUpdate, you can use the function current_timestamp() or any other function that
#will record date and/or time with your specified datatype

delimiter //
create trigger msrpaudit_update
after update on products
for each row
begin
	## We have to insert the old values first (values we just added into the table we created) ##
    insert into msrpaudit(productCode, productName, productLine, MSRP, lastUpdate, rowValue)
    values (old.productCode, old.productName, old.productLine, old.MSRP, current_timestamp(), 'Before Update');
    
    # Now wer can update to the new values #
     insert into msrpaudit(productCode, productName, productLine, MSRP, lastUpdate, rowValue)
    values (new.productCode, new.productName, new.productLine, new.MSRP, current_timestamp(), 'After Update');
end //
delimiter ;

#3
### Now we can test the trigger
#Test the trigger by changing 2 - 3 MSRP values in your products table. Then, take a screenshot
#of the ‘audit table’ created in step 1 to show any updates to MSRP values being recorded/logged

### Keep in mind that the trigger sits on the table where we are doing the update, not the msrpaudit but PRODUCTS table
#because we are changing data in the products table

select * from products;
## TEST:
update products
set MSRP = '272.27'
where productCode = 's10_1678';

update products
set MSRP = '111.11'
where productcode = 'S10_4757';

select * from msrpaudit;

#4
#Create an audit table that stores changes to a customer’s phone number and/or credit limit
#values from the customers table (1pt). Include the following fields: customerNumber, customerName
#phone, creditLimit, lastUpdate (timestamp), user (i.e., ‘system or current user’ who made the update)
#rowValue (i.e., ‘before update’ or ‘after update’), fields that were changed (i.e., ‘phone number’, ‘credit limit’, ‘both’).

create table `custInfo_audit`(
	`customerNumber` int(11),
    `customerName` varchar(50),
    `phone` varchar(50),
    `creditLimit` dec(10,2),
    `lastUpdate` timestamp,
    `userID` varchar(70),
    `rowValue` char(20),
    `fieldChanged` varchar(20)
);

#5
#Write a trigger that records the old values of a phone number and credit limit of a customer while
#also recording the new values of a phone number and credit limit into the ‘audit table’ created
#above, after an update to either the phone number and/or credit limit values has occurred. For
#the column lastUpdate, you can use the function current_timestamp() or any other function that
#will record date and/or time with your specified datatype
drop trigger if exists custInfo_audit_update;

delimiter //

create trigger custInfo_audit_update
after update on customers
for each row 
begin
	        #Change in phone OR credit limit
	if old.phone <> new.phone and old.creditLimit <> new.creditLimit then
		insert into custInfo_audit(customerNumber, customerName, phone, creditLimit, lastUpdate, userID, rowvalue, fieldChanged)
        values (old.customerNumber, old.customerName, old.phone, old.creditLimit, current_timestamp(), 'System user', 'Before updtae', 'Both');
        
        insert into custInfo_audit(customerNumber, customerName, phone, creditLimit, lastUpdate, userID, rowvalue, fieldChanged)
        values (new.customerNumber, new.customerName, new.phone, new.creditLimit, current_timestamp(), 'System user', 'After updtae', 'Both');
    
    ## Credit limit
    elseif new.creditLimit <> old.creditLimit then
		insert into custInfo_audit(customerNumber, customerName, phone, creditLimit, lastUpdate, userID, rowvalue, fieldChanged)
        values (old.customerNumber, old.customerName, old.phone, old.creditLimit, current_timestamp(), 'System user', 'Before updtae', 'Credit limit');
	
		insert into custInfo_audit(customerNumber, customerName, phone, creditLimit, lastUpdate, userID, rowvalue, fieldChanged)
        values (new.customerNumber, new.customerName, new.phone, new.creditLimit, current_timestamp(), 'System user', 'After updtae', 'Credit limit');
    
    ## Change in phone
	elseif old.phone <> new.phone then
		insert into custInfo_audit(customerNumber, customerName, phone, creditLimit, lastUpdate, userID, rowvalue, fieldChanged)
        values (old.customerNumber, old.customerName, old.phone, old.creditLimit, current_timestamp(), 'System user', 'Before updtae', 'Phone Number');
        
        insert into custInfo_audit(customerNumber, customerName, phone, creditLimit, lastUpdate, userID, rowvalue, fieldChanged)
        values (new.customerNumber, new.customerName, new.phone, new.creditLimit, current_timestamp(), 'System user', 'After updtae', 'Phone Number');
	end if;
end //
delimiter ;

#6
#Test the trigger by changing 3 - 4 phone number and/or credit limit values in your customers
#table. Then, take a screenshot of the ‘audit table’ created in step 1 to show any updates to
#phone numbers and credit limits being recorded/logged
select * from customers;

update customers
set phone = 9702746939
where customerNumber = '103';

update customers
set phone = 1122334455 and creditLimit = 11111.11
where customerNumber = 124;

update customers
set creditLimit = 27270.27
where customerNumber = 125;

select * from custinfo_audit;