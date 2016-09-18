USE qrdb;
CREATE TABLE `dage` (
    `id` int (11) NOT NULL auto_increment,
    `name` varchar (32) default '',
    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

CREATE TABLE `xiaodi` (
    `id` int (11) NOT NULL auto_increment,
    `dage_id` int (11) default NULL,
    `name` varchar (32) default '',
     PRIMARY KEY (`id`),
     KEY `dage_id` (`dage_id`),
     CONSTRAINT `xiaodi_ibfk_1` FOREIGN KEY (`dage_id`) REFERENCES `dage` (`id`)
) ENGINE = InnoDB;

insert into dage(name) values ('tongLuoWan');
insert into xiaodi(dage_id, name) values (1, 'tongLuoWan_A');

delete from dage where id = 1;
insert into xiaodi(dage_id, name) values (2, 'wangJiao_A');
