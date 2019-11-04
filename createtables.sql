

CREATE USER 'web'@'localhost' IDENTIFIED BY 'la34trdfg';
grant select, update, insert, delete on PULTUS.* to 'web@localhost' identified by 'la34trdfg';	   


use PULTUS;

CREATE TABLE License (
  id int(11) NOT NULL auto_increment,
  CompanyName varchar(100) default NULL,
  Comment varchar(255) default NULL,
  WelcomingText varchar(255) default NULL,
  DeviceLimit tinyint(4) default 3,
  uuid varchar(60) UNIQUE KEY,
  PRIMARY KEY  (id)
) ;
	   
	   
	   ALTER TABLE License ADD `psw1` varchar(6); 
	   ALTER TABLE License ADD `psw2` varchar(6); 
	   ALTER TABLE License ADD `psw3` varchar(6); 
	   
	   ALTER TABLE License ADD `LicStatus` INT ; 
	   ALTER TABLE License ADD `LicNUM` INT UNSIGNED; 
	   
	   ALTER TABLE License ADD `DeviceInfo`  varchar(255) ; 
	   
	