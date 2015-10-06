﻿DELIMITER $$

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


   DECLARE agencyNameWithDash varchar(1000);
   DECLARE agencyName varchar(1000);
   DECLARE department varchar(1000);
   DECLARE sectionName varchar(1000);
   DECLARE telephoneNo varchar(1000);
   DECLARE email varchar(1000);
   DECLARE address varchar(1000);

   -- Find new message id and use it to filter other data
   SELECT NEW.id INTO access_id;

   -- get access details
   SELECT
     alfresco_access_transaction_uuid,
     alfresco_access_transaction_user,
     `timestamp`,
     alfresco_access_transaction_action

       into document_node_id,
            access_username,
            date_accessed,
            document_accessed_action

       from alfresco_access
       where id = access_id
         and alfresco_access_transaction_type = 'cm:content';

   -- get document details
   SELECT
       IF(cm_title<>'', cm_title, cm_name),
       path

       into document_accessed,
            document_path

       from document
       where sys_node_uuid = document_node_id
         and path like '/Company Home/Sites/rm/documentLibrary/(RM)%';


   -- get agency details
   SELECT armis_agencyName,
          armis_department,
          armis_sectionName,
          armis_telephoneNo,
          armis_email,
          armis_address,
          S.cm_name
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

   -- get person designation
   SELECT siteRole into designation
          from siteperson
          where agencyNameWithDash = UPPER(siteName)
          and userName = access_username;

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
    `date_accessed`
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
    designation,
    date_accessed
   );
   end if;        

END; $$