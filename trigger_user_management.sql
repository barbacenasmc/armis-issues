DELIMITER $$

drop trigger IF EXISTS alfresco_access_after_insert$$

CREATE TRIGGER alfresco_access_after_insert
AFTER INSERT
   ON alfresco_access FOR EACH ROW

BEGIN

   DECLARE access_id varchar(50);
   DECLARE document_node_id varchar(100);
   DECLARE document_accessed varchar(1000);
   DECLARE date_accessed varchar(1000);
   DECLARE access_username varchar(1000);
   DECLARE document_path varchar(1000);
   DECLARE access_username_person varchar(1000);
   DECLARE designation varchar(1000);
   DECLARE document_accessed_action varchar(1000);
   DECLARE designationCount int;
   DECLARE counter int;
   DECLARE designationTemp varchar(1000);
   DECLARE agencyNameWithDash varchar(1000);
   DECLARE agencyName varchar(1000);
   DECLARE department varchar(1000);
   DECLARE sectionName varchar(1000);
   DECLARE telephoneNo varchar(1000);
   DECLARE email varchar(1000);
   DECLARE address varchar(1000);
   DECLARE deleteTimeStamp varchar(100);
   DECLARE deleteUser varchar(100);
   DECLARE transactionType varchar(100);

   -- Find new message id and use it to filter other data
   SELECT NEW.id INTO access_id;

  -- get access details
   SELECT
     alfresco_access_transaction_uuid,
     alfresco_access_transaction_user,
     `timestamp`,
     `timestamp`,
     alfresco_access_transaction_action,
     username,
     alfresco_access_transaction_type

       into document_node_id,
            access_username,
            date_accessed,
            deleteTimeStamp,
            document_accessed_action,
            deleteUser,
            transactionType

       from alfresco_access
       where id = access_id;
   -- if transaction is delete
   IF document_accessed_action = 'DELETE' then
   SELECT
     alfresco_access_transaction_uuid, username

       into document_node_id, access_username

       from alfresco_access
       where id < access_id
         and `timestamp` < deleteTimeStamp
         and  username = deleteUser
         and alfresco_access_transaction_path like  '/app:company_home/st:sites/%'
         order by `timestamp` desc
         limit 1;

   end if;
   
   -- get document details
   SELECT
       cm_name,
       path

       into document_accessed,
            document_path

       from document
       where sys_node_uuid = document_node_id and path like '/Company Home/Sites%';


   -- get agency details
   SELECT armis_agencyName,
          armis_department,
          armis_sectionName,
          armis_telephoneNo,
          armis_email,
          armis_address,
          s.cm_name
            into agencyName,
                 department,
                 sectionName,
                 telephoneNo,
                 email,
                 address,
                 agencyNameWithDash
          FROM agency a inner join site s
            on a.armis_site = s.noderef
          WHERE LOCATE(UPPER(s.cm_name),document_path) > 0
          LIMIT 1;

   -- get person details
   SELECT IF(cm_lastName<>'', CONCAT(cm_lastName, ', ', cm_firstName), cm_firstName)
          into access_username_person
          from person
          where cm_userName = access_username
          LIMIT 1;
		  
   -- get count of person designation
   SELECT count(groupDisplayName) into designationCount
          FROM groups g where userName = access_username
		  AND designationTag =1;

   if designationCount > 0 then
     SET counter = 0;
     WHILE designationCount > 0 DO
       if counter > 0 then
          SELECT groupDisplayName into designationTemp
          FROM groups g where userName = access_username
	    	  AND designationTag =1
          limit 1 offset counter;
          SELECT CONCAT(designationTemp,', ',designation) into designation;
       else
          SELECT groupDisplayName into designation
          FROM groups g where userName = access_username
	    	  AND designationTag =1
          limit 1;
       end if;

       SET counter = counter + 1;
       SET designationCount = designationCount - 1;
     END WHILE;
   else
      SET designation = 'N/A';
   end if;

   IF document_accessed is not null then
   -- Insert access details
   INSERT into usermanagement_report
   (
    `armis_agencyName`,
    `armis_department`,
    `armis_sectionName`,
    `armis_telephoneNo`,
    `armis_email`,
    `armis_address`,
    `document_accessed`,
    `action`,
    `username`,
    `designation`,
    `date_accessed`,
    `doc_uuid`
   )VALUES
   (
    agencyName,
    department,
    sectionName,
    telephoneNo,
    email,
    address,
    document_accessed,
    document_accessed_action,
    access_username_person,
    UPPER(designation),
    date_accessed,
    document_node_id
   );
   end if;
END $$
