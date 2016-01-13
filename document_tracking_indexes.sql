ALTER TABLE `alfrescoreporting`.`document` ADD INDEX `document_tracking`(`noderef`,`isLatest`);

ALTER TABLE `alfrescoreporting`.`person` ADD INDEX `document_tracking_person`(`isLatest`, `cm_userName`);

ALTER TABLE `alfrescoreporting`.`documenttracking_report` ADD INDEX `document_tracking_temp`(`wf_document_node_ref`, `wf_proc_id`);
