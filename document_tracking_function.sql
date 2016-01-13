DELIMITER $$

DROP FUNCTION IF EXISTS `alfrescoreporting`.`update_document_tracking_report`$$
CREATE FUNCTION  `alfrescoreporting`.`update_document_tracking_report`(_ID INT) RETURNS varchar(1000) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE wf_Id VARCHAR(100);
   DECLARE wf_documents_count VARCHAR(1000);
   DECLARE wf_proc_inst_id VARCHAR(100);
   DECLARE wf_document_noderef VARCHAR(1000);

   DECLARE tmp_noderef VARCHAR(100);

   DECLARE comma_index int;
   SET comma_index = 1;

   -- USE NEW ID AS WORKFLOW ID
   SELECT _ID INTO wf_Id;

   -- GET CHILD_NODEREF LIST AND INSTANCE ID
   SELECT
       SUBSTRING(bpm_workflowInstanceId, 10), child_noderef
       INTO
           wf_proc_inst_id, wf_document_noderef
       FROM workflowpackage where id = wf_Id;

   WHILE comma_index > 0 DO
       -- check if the wf documents are more than 1
       SELECT LOCATE(',',wf_document_noderef) into comma_index;

       IF(comma_index > 0) THEN
           SELECT SUBSTRING(wf_document_noderef,1,comma_index-1) INTO tmp_noderef;

           INSERT INTO documenttracking_report(`wf_document_node_ref`, `wf_proc_id`)
             VALUES(tmp_noderef, wf_proc_inst_id);

           SELECT SUBSTRING(wf_document_noderef,comma_index+1) into wf_document_noderef;

       ELSE
           INSERT INTO documenttracking_report(`wf_document_node_ref`, `wf_proc_id`)
             VALUES(wf_document_noderef, wf_proc_inst_id);
       END IF;
   END WHILE;
   RETURN 'YEAH';
END;

 $$