DROP TABLE IF EXISTS `alfrescoreporting`.`documenttracking_report`;
CREATE TABLE  `alfrescoreporting`.`documenttracking_report` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `wf_document_node_ref` varchar(700) DEFAULT NULL,
  `wf_proc_id` varchar(700) DEFAULT NULL,
  PRIMARY KEY (`id`)
);