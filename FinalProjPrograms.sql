use _padu7542_woodypaigedb;
###Trigger Caps names
drop trigger if exists nameCap;

delimiter //

create trigger nameCap
before insert on employees
for each row
begin
	set new.firstName = concat(upper(substring(new.firstName,1,1)),lower(substring(new.firstName from 2)));
    set new.lastName = concat(upper(substring(new.lastName,1,1)),lower(substring(new.lastName from 2)));
end// 

delimiter ;


insert into employees
values ('Manager', 404, 'joe', 'DIRT');

select * from employees;


######## pct function


drop function if exists uniquePct;
DELIMITER //

create function uniquePct (upv int, pv int) returns decimal(10,2)
deterministic
begin
	declare pct decimal(10,2);
    set pct = upv/pv;
    return (pct);
END//

DELIMITER ;

select *, uniquePct(uniquePageViews,pageViews) as 'Unique Page View %' from content;

### function better or worse than average

drop function if exists contentCompare;

DELIMITER //

create function contentCompare (contentNo int(10)) 
returns varchar(45)
deterministic
begin
	declare avgPR dec(10,2);
    declare contentPR dec(10,2);
    declare writerId int;
    declare diff varchar(45);
        
    set writerId = (select employeeId from content
    where contentNo = contentId);
   
    set avgPR = (select (sum(publisherRevenue)/ count(*)) from content
    group by writerId);
    
    set contentPR = (select publisherRevenue from content
    where contentNo = contentId);
    
    case
    when contentPR < avgPR then set diff  = 'Less than Average';
    when contentPR > avgPR then set diff = 'Better Than Average';
    when contentPR = avgPR then set diff = 'Average';
    else set diff = 'Something is Wrong';
    end case;
return (diff);

end //

delimiter ; 

select *, contentCompare(contentId) as 'Performance' from content;


####### PROCEDURE

drop procedure if exists writerInfo;

delimiter //

create procedure writerInfo (in pemployeeId int, out pname varchar(100), out pubNo int, out income decimal, out sumPR decimal(10,2))
begin
    set pubNo = (select count(*) from content where pemployeeId = employeeId);
    
	set sumPR = (select sum(publisherRevenue) from content where pemployeeId = employeeId);
    
    set pname = (select (concat(firstName, lastName)) from employees e
    join content c on e.employeeId = c.employeeId
    where e.employeeId = pemployeeId
    group by pname);

    SET income = (SELECT sum(salary) as 'Salary' FROM salary s
	JOIN content c on s.employeeId = c.employeeId
    WHERE s.employeeId = pemployeeId);
    
end // 

delimiter ;

call writerInfo(301,@pname, @pubNo,@income,@sumPR);

select @pname as 'Name', @pubNo as 'Number of Publications',@income as 'Salary' ,@sumPR as 'Revenue from Posts';
 
# select statements

#group by statement, what is the average salary for each job position?
select e.role, avg(s.salary) as 'average salary for position'
from employees e
join salary s on e.employeeid = s.employeeid
group by e.role;


###salary pageviews
select e.employeeId as 'Writer ID', concat(e.firstName, e.lastName) as 'Name',s.salary as 'Salary' , c.pageViews as 'Page Views'
from employees e
join content c on e.employeeId = c.employeeId
join salary s on s.employeeId = e.employeeId
group by e.employeeId;


#pay per article 
select e.employeeId as 'Writer ID', concat(e.firstName, e.lastName) as 'Name', s.salary/count(*) as 'Pay per Article', sum(c.publisherRevenue) as 'Revenue from Articles'
from employees e
join content c on e.employeeId = c.employeeId
join salary s on s.employeeId = e.employeeId
group by e.employeeId;


#Overpaid (earn more than 5x revenue per article)
select e.employeeId as 'Writer ID', concat(e.firstName, e.lastName) as 'Name'
from employees e
join content c on e.employeeId = c.employeeId
join salary s on s.employeeId = e.employeeId
where (select (s.salary/count(*)) > (sum(c.publisherRevenue)*5))
group by e.employeeId;



#sub query top performing writers in terms of revenue 
select c.employeeid, w.firstname,w.lastname, sum(c.publisherRevenue) as 'revenue',
(select avg(c.publisherRevenue) * 1.3
    from content c) as '30% over avg revenue'
from content c
join writers w on w. employeeid= c.employeeid
group by c.employeeid having sum(publisherRevenue) >
(select avg(publisherRevenue)  * 1.3 from content)
order by sum(publisherRevenue);

#Article title and contact information
select c.title, w.firstName, w.lastName, ci.email
from content c
join writers w on c.employeeid= w.employeeid
join contactinfo ci on w.employeeid= ci.employeeid
group by c.title, w.lastName desc;

#descending publisher revenue
select contentId, employeeId, title, PublisherClicks, publisherRevenue  from content
where publisherClicks > 0
group by publisherRevenue desc;

#max clicks
select c.title,w.firstname,w.lastname, c.publisherclicks as Clicks from content c
join writers w on c.employeeId = w.employeeid
group by c.employeeid having c.publisherclicks >
(select avg(clicks) from
(select c.publisherclicks as clicks from content c
        join writers w on c.employeeId = w.employeeid
group by c.employeeid) clicks);


#Names by position
select role, firstname, lastname
from employees
group by role,firstname,lastname;


