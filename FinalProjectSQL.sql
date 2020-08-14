drop database if exists _padu7542_woodyPaige;
create database if not exists _padu7542_woodyPaige;
use _padu7542_woodyPaige;

drop table if exists management;
create table if not exists management(
	managerId int(10),
    employeeId int(10) unique,
    firstName varchar(45),
    lastName varchar(45),
    title varchar(45),
    primary key (managerId)
    );
    
drop table if exists interns;
create table if not exists interns(
	employeeId int(10) unique,
    managerId int(10),
	firstName varchar(45),
    lastName varchar(45),
    primary key (employeeId),
    foreign key (managerId) references management (managerId),
    foreign key (employeeId) references management (employeeId)
    );
    
drop table if exists writers;    
create table if not exists writers(
	employeeId int(10) unique,
    managerId int(10),
    firstName varchar(45),
	lastName varchar(45),
    primary key (employeeId),
    foreign key (managerId) references management(managerID)
    );
    
    
drop table if exists contactInfo;
create table if not exists contactInfo(
	employeeId int (10) unique,
    email varchar(45),
    phoneNo varchar(10) not null check (phoneNo like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    primary key (employeeId),
    foreign key (employeeId) references management (employeeId),
    foreign key (employeeId) references interns (employeeId),
    foreign key (employeeId) references writers (employeeId)
    );
    
drop table if exists content;
create table if not exists content(   
	contentId int(10) unique,
    employeeId int(10) unique,
    title varchar(100),
    uniquePageViews int,
    pageViews int,
    publisherImpressions int,
    publisherClicks int,
    publisherCTR decimal(10,2),
    publisherCPM decimal(10,2),
    publisherRevenue decimal(10,2),
    primary key(contentId),
    foreign key (employeeId) references writers (employeeId)
    );
    
drop table if exists salary;
create table if not exists salary(
	employeeId int(10) unique,
    firstName varchar(45),
	lastName varchar(45),
    salary decimal(10,2),
	primary key(employeeId),
	foreign key (employeeId) references management (employeeId),
    foreign key (employeeId) references interns (employeeId),
    foreign key (employeeId) references writers (employeeId)
    );

