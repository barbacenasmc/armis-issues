DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `breakLongWord`(_word varchar(1000)) RETURNS varchar(1000) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE brokenWord VARCHAR(1000);
  DECLARE wordLen int;
  DECLARE counter int;
  DECLARE location int;

  SET counter = 0;
  SET location = 21;

  SELECT LENGTH(_word) into wordLen;

  WHILE counter < wordLen DO
      -- SELECT INSERT(_word, location, 1, ' ') into _word;
      SELECT SUBSTRING(_word,1,location) into brokenWord;

      SELECT INSERT(brokenWord,(location+1),1,' ') into brokenWord;

      SELECT CONCAT(brokenWord, SUBSTRING(_word,(location+1),LENGTH(_word))) into _word;

      SET counter = counter + 21;
      SET location = location + 22;
  END WHILE;

  RETURN _word;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNextAgencyNameCertificateOfDisposal`(_documentId INT,
                                    _dateFrom date,
                                    _dateTo date) RETURNS varchar(225) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE nextAgency VARCHAR(225);
  DECLARE nextAgencyDocId int;
  DECLARE currAgencyDocId int;
  DECLARE doc_id int;
  DECLARE totalCount int;
  DECLARE counter int;
  DECLARE nextFlag int;
  DECLARE off int;
  DECLARE file_list VARCHAR(1000);

  SET off = 0;
  SET nextFlag = 0;
  SET counter = 0;
  SET nextAgencyDocId = 0;
  SET currAgencyDocId = _documentId;

  -- get total count for all records
  SELECT count(d.id) into totalCount
		from document d
		inner join site s
		ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
		AND d.isLatest = 1 and s.isLatest = 1
		inner JOIN agency a
		ON s.noderef = a.armis_site
		AND a.isLatest = 1 and s.isLatest = 1
		INNER JOIN folder f
		ON d.parent_noderef = f.noderef
		AND d.isLatest = 1 and f.isLatest = 1
		WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
		AND  d.mimetype is null
		AND DATE_FORMAT(d.rma_declaredAt,'%Y-%m-%d') BETWEEN _dateFrom AND _dateTo;

    myloop: WHILE counter <= totalCount DO
        SELECT d.id into doc_id
			from document d
			inner join site s
			ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
			AND d.isLatest = 1 and s.isLatest = 1
			inner JOIN agency a
			ON s.noderef = a.armis_site
			AND a.isLatest = 1 and s.isLatest = 1
			INNER JOIN folder f
			ON d.parent_noderef = f.noderef
			AND d.isLatest = 1 and f.isLatest = 1
			WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
      AND  d.mimetype is null
			AND DATE_FORMAT(d.rma_declaredAt,'%Y-%m-%d') BETWEEN _dateFrom AND _dateTo  
			order by a.armis_agencyName, CONCAT(d.rma_shelf, ' - ' ,CONCAT(d.rma_box,' - ',d.rma_file)), d.rma_declaredAt
			LIMIT 1 offset counter;
		
        if nextFlag > 0 then
            SET nextAgencyDocId = doc_id;
            SET nextFlag = 0;
            -- LEAVE myloop;
        end if;
        
        if doc_id = _documentId then
            SET nextFlag = 1;
            set currAgencyDocId = doc_id;
            set off = counter;
		end if;
        
        SET counter = counter + 1;
    END WHILE;
    
    /* Perform Search */	  
	select
	a.armis_agencyName into nextAgency
	from document d
	inner join site s
	ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
	AND d.isLatest = 1 and s.isLatest = 1
	inner JOIN agency a
	ON s.noderef = a.armis_site
	AND a.isLatest = 1 and s.isLatest = 1
	INNER JOIN folder f
	ON d.parent_noderef = f.noderef
	AND d.isLatest = 1 and f.isLatest = 1
	WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
  AND  d.mimetype is null
	AND d.id = nextAgencyDocId
	AND DATE_FORMAT(d.rma_declaredAt,'%Y-%m-%d') between _dateFrom AND _dateTo
	order by a.armis_agencyName, CONCAT(d.rma_shelf, ' - ' ,CONCAT(d.rma_box,' - ',d.rma_file)), d.rma_declaredAt asc
	LIMIT 1;
  -- return CONCAT(nextAgency,'OFFSET:',off,'<> Curr:',currAgencyDocId,'<>','Next:',nextAgencyDocId);
	
  RETURN nextAgency;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNextAgencyNameCOD`(_documentId INT,
                                    _dateFrom date,
                                    _dateTo date) RETURNS varchar(225) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE nextAgency VARCHAR(225);
  DECLARE nextAgencyDocId int;
  DECLARE currAgencyDocId int;
  DECLARE doc_id int;
  DECLARE totalCount int;
  DECLARE counter int;
  DECLARE nextFlag int;
  DECLARE off int;
  SET off = 0;
  SET nextFlag = 0;
  SET counter = 0;
  SET nextAgencyDocId = 0;
  SET currAgencyDocId = _documentId;
  -- get total count for all records
  SELECT count(d.id) into totalCount
	 from document d
       inner join site s
       ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
       AND d.isLatest = 1 and s.isLatest = 1
       INNER JOIN agency a
       ON s.noderef = a.armis_site
       AND a.isLatest = 1 and s.isLatest = 1
       INNER JOIN folder f
       ON d.parent_noderef = f.noderef
       AND d.isLatest = 1 and f.isLatest = 1

              WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
                     and (d.rma_recordSearchDispositionActionName='transfer' OR d.rma_recordSearchDispositionActionName='destroy')
                     AND DATE_FORMAT(d.rma_cutOffDate,'%Y-%m-%d') BETWEEN _dateFrom AND _dateTo;


    myloop: WHILE counter <= totalCount DO
    SELECT d.id into doc_id

       from document d
       inner join site s
       ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
       AND d.isLatest = 1 and s.isLatest = 1
       INNER JOIN agency a
       ON s.noderef = a.armis_site
       AND a.isLatest = 1 and s.isLatest = 1
       INNER JOIN folder f
       ON d.parent_noderef = f.noderef
       AND d.isLatest = 1 and f.isLatest = 1

              WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
                     and (d.rma_recordSearchDispositionActionName='transfer' OR d.rma_recordSearchDispositionActionName='destroy')
                     AND DATE_FORMAT(d.rma_cutOffDate,'%Y-%m-%d') BETWEEN _dateFrom AND _dateTo
			                       order by a.armis_agencyName,
                                      SUBSTRING(SUBSTRING(d.path, 1, ((LENGTH(d.path) - LENGTH(d.cm_name) - 1))), 40),
                                      d.rma_cutOffDate LIMIT 1 offset counter;
		
        if nextFlag > 0 then
            SET nextAgencyDocId = doc_id;
            SET nextFlag = 0;
            -- LEAVE myloop;
        end if;
        
        if doc_id = _documentId then
            SET nextFlag = 1;
            set currAgencyDocId = doc_id;
            set off = counter;
		end if;
        
        SET counter = counter + 1;
    END WHILE;
    
    /* Perform Search */	  
	select
	concat(a.armis_agencyName,'#',SUBSTRING(SUBSTRING(d.path, 1, ((LENGTH(d.path) - LENGTH(d.cm_name) - 1))), 40)) into nextAgency
	from document d
	inner join site s
	ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
	AND d.isLatest = 1 and s.isLatest = 1
	inner JOIN agency a
	ON s.noderef = a.armis_site
	AND a.isLatest = 1 and s.isLatest = 1
	INNER JOIN folder f
	ON d.parent_noderef = f.noderef
	AND d.isLatest = 1 and f.isLatest = 1

	WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
  and (d.rma_recordSearchDispositionActionName='transfer' OR d.rma_recordSearchDispositionActionName='destroy')
	AND d.id = nextAgencyDocId
	AND DATE_FORMAT(d.rma_cutOffDate,'%Y-%m-%d') between _dateFrom AND _dateTo
	order by a.armis_agencyName,  SUBSTRING(SUBSTRING(d.path, 1, ((LENGTH(d.path) - LENGTH(d.cm_name) - 1))), 40), d.rma_cutOffDate
	LIMIT 1;
	
  RETURN nextAgency;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNextAgencyNameNRI`(_documentId INT,
                                    _dateFrom date,
                                    _dateTo date) RETURNS varchar(225) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE nextAgency VARCHAR(225);
  DECLARE nextAgencyDocId int;
  DECLARE currAgencyDocId int;
  DECLARE doc_id int;
  DECLARE totalCount int;
  DECLARE counter int;
  DECLARE nextFlag int;
  DECLARE off int;
  SET off = 0;
  SET nextFlag = 0;
  SET counter = 0;
  SET nextAgencyDocId = 0;
  SET currAgencyDocId = _documentId;
  -- get total count for all records
  SELECT count(d.id) into totalCount
		from document d
		inner join site s
		ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
		AND d.isLatest = 1 and s.isLatest = 1
		inner JOIN agency a
		ON s.noderef = a.armis_site
		AND a.isLatest = 1 and s.isLatest = 1
		INNER JOIN folder f
		ON d.parent_noderef = f.noderef
		AND d.isLatest = 1 and f.isLatest = 1
		WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
		AND  d.mimetype != '' 
		AND DATE_FORMAT(d.rma_declaredAt,'%Y-%m-%d') BETWEEN _dateFrom AND _dateTo
		order by a.armis_agencyName, SUBSTRING(d.path, 1, LOCATE(IF(d.cm_name<>'', d.cm_name, d.cm_title), d.path) - 1), d.rma_declaredAt asc;
        
    myloop: WHILE counter <= totalCount DO
        SELECT d.id into doc_id
			from document d
			inner join site s
			ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
			AND d.isLatest = 1 and s.isLatest = 1
			inner JOIN agency a
			ON s.noderef = a.armis_site
			AND a.isLatest = 1 and s.isLatest = 1
			INNER JOIN folder f
			ON d.parent_noderef = f.noderef
			AND d.isLatest = 1 and f.isLatest = 1
			WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
			AND  d.mimetype != '' 
			AND DATE_FORMAT(d.rma_declaredAt,'%Y-%m-%d') BETWEEN _dateFrom AND _dateTo
			order by a.armis_agencyName, SUBSTRING(d.path, 1, LOCATE(IF(d.cm_name<>'', d.cm_name, d.cm_title), d.path) - 1), d.rma_declaredAt asc
			LIMIT 1 offset counter;
		
        if nextFlag > 0 then
            SET nextAgencyDocId = doc_id;
            SET nextFlag = 0;
            -- LEAVE myloop;
        end if;
        
        if doc_id = _documentId then
            SET nextFlag = 1;
            set currAgencyDocId = doc_id;
            set off = counter;
		end if;
        
        SET counter = counter + 1;
    END WHILE;
    
    /* Perform Search */	  
	select
	a.armis_agencyName into nextAgency
	from document d
	inner join site s
	ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
	AND d.isLatest = 1 and s.isLatest = 1
	inner JOIN agency a
	ON s.noderef = a.armis_site
	AND a.isLatest = 1 and s.isLatest = 1
	INNER JOIN folder f
	ON d.parent_noderef = f.noderef
	AND d.isLatest = 1 and f.isLatest = 1
	WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
	AND  d.mimetype != '' 
	AND d.id = nextAgencyDocId
	AND DATE_FORMAT(d.rma_declaredAt,'%Y-%m-%d') between _dateFrom AND _dateTo
	order by a.armis_agencyName, SUBSTRING(d.path, 1, LOCATE(IF(d.cm_name<>'', d.cm_name, d.cm_title), d.path) - 1), d.rma_declaredAt asc
	LIMIT 1;
  -- return CONCAT(nextAgency,'OFFSET:',off,'<> Curr:',currAgencyDocId,'<>','Next:',nextAgencyDocId);
	
  RETURN nextAgency;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNextAgencyNameNRI_NE`(_documentId INT,
                                    _dateFrom date,
                                    _dateTo date) RETURNS varchar(225) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE nextAgency VARCHAR(225);
  DECLARE nextAgencyDocId int;
  DECLARE currAgencyDocId int;
  DECLARE doc_id int;
  DECLARE totalCount int;
  DECLARE counter int;
  DECLARE nextFlag int;
  DECLARE off int;
  SET off = 0;
  SET nextFlag = 0;
  SET counter = 0;
  SET nextAgencyDocId = 0;
  SET currAgencyDocId = _documentId;
  -- get total count for all records
  SELECT count(d.id) into totalCount
		from document d
		inner join site s
		ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
		AND d.isLatest = 1 and s.isLatest = 1
		inner JOIN agency a
		ON s.noderef = a.armis_site
		AND a.isLatest = 1 and s.isLatest = 1
		INNER JOIN folder f
		ON d.parent_noderef = f.noderef
		AND d.isLatest = 1 and f.isLatest = 1
		WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
		AND  d.mimetype is null
		AND DATE_FORMAT(d.rma_declaredAt,'%Y-%m-%d') BETWEEN _dateFrom AND _dateTo
		order by a.armis_agencyName, SUBSTRING(d.path, 1, LOCATE(IF(d.cm_name<>'', d.cm_name, d.cm_title), d.path) - 1), d.rma_declaredAt asc;
        
    myloop: WHILE counter <= totalCount DO
        SELECT d.id into doc_id
			from document d
			inner join site s
			ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
			AND d.isLatest = 1 and s.isLatest = 1
			inner JOIN agency a
			ON s.noderef = a.armis_site
			AND a.isLatest = 1 and s.isLatest = 1
			INNER JOIN folder f
			ON d.parent_noderef = f.noderef
			AND d.isLatest = 1 and f.isLatest = 1
			WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
      AND  d.mimetype is null
			AND DATE_FORMAT(d.rma_declaredAt,'%Y-%m-%d') BETWEEN _dateFrom AND _dateTo
			order by a.armis_agencyName, SUBSTRING(d.path, 1, LOCATE(IF(d.cm_name<>'', d.cm_name, d.cm_title), d.path) - 1), d.rma_declaredAt asc
			LIMIT 1 offset counter;
		
        if nextFlag > 0 then
            SET nextAgencyDocId = doc_id;
            SET nextFlag = 0;
            -- LEAVE myloop;
        end if;
        
        if doc_id = _documentId then
            SET nextFlag = 1;
            set currAgencyDocId = doc_id;
            set off = counter;
		end if;
        
        SET counter = counter + 1;
    END WHILE;
    
    /* Perform Search */	  
	select
	a.armis_agencyName into nextAgency
	from document d
	inner join site s
	ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
	AND d.isLatest = 1 and s.isLatest = 1
	inner JOIN agency a
	ON s.noderef = a.armis_site
	AND a.isLatest = 1 and s.isLatest = 1
	INNER JOIN folder f
	ON d.parent_noderef = f.noderef
	AND d.isLatest = 1 and f.isLatest = 1
	WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
  AND  d.mimetype is null
	AND d.id = nextAgencyDocId
	AND DATE_FORMAT(d.rma_declaredAt,'%Y-%m-%d') between _dateFrom AND _dateTo
	order by a.armis_agencyName, SUBSTRING(d.path, 1, LOCATE(IF(d.cm_name<>'', d.cm_name, d.cm_title), d.path) - 1), d.rma_declaredAt asc
	LIMIT 1;
	
  RETURN nextAgency;
END$$
DELIMITER ;

DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `GetNextAgencyNameUM`(_recordNum INT,
                                    _dateFrom date,
                                    _dateTo date) RETURNS varchar(225) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE nextAgency VARCHAR(225);
  SET _recordNum = _recordNum + 1;
  IF _dateFrom <> _dateTo THEN

SELECT

 IFNULL(g.armis_agencyName,'N/A') as `armis_agencyName` into nextAgency


FROM alfrescoreporting.document a

LEFT OUTER JOIN alfresco_access b
  ON a.sys_node_uuid = b.alfresco_access_transaction_uuid

LEFT OUTER JOIN alfrescoreporting.person d
 ON b.alfresco_access_transaction_user = d.cm_userName
 AND d.isLatest = 1

LEFT OUTER JOIN alfrescoreporting.site f
 ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(a.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(f.cm_name)
 AND f.isLatest = 1

LEFT JOIN groups h
 ON h.userName = d.cm_userName
 AND h.designationTag = 1

LEFT JOIN agency g
 ON f.noderef = g.armis_site
 AND g.isLatest = 1

cross join (select @rownum := 0) r

WHERE a.rma_declaredAt BETWEEN _dateFrom AND _dateTo
AND a.path like '/Company Home/Sites/rm/documentLibrary/%'

AND a.mimetype != ''
ORDER BY b.id, IFNULL(g.armis_agencyName,'zzzN/A'),IF(a.cm_title<>'', a.cm_title, a.cm_name),b.`timestamp`,d.cm_userName ASC
LIMIT 1 OFFSET _recordNum;

  ELSE

SELECT

IFNULL(g.armis_agencyName,'N/A') as `armis_agencyName`  into nextAgency

FROM alfrescoreporting.document a

LEFT OUTER JOIN alfresco_access b
  ON a.sys_node_uuid = b.alfresco_access_transaction_uuid

LEFT OUTER JOIN alfrescoreporting.person d
 ON b.alfresco_access_transaction_user = d.cm_userName
 AND d.isLatest = 1

LEFT OUTER JOIN alfrescoreporting.site f
 ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(a.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(f.cm_name)
 AND f.isLatest = 1

LEFT JOIN groups h
 ON h.userName = d.cm_userName
 AND h.designationTag = 1

LEFT JOIN agency g
 ON f.noderef = g.armis_site
 AND g.isLatest = 1

cross join (select @rownum := 0) r

WHERE a.rma_declaredAt = _dateFrom
AND a.path like '/Company Home/Sites/rm/documentLibrary/%'

AND a.mimetype != ''
ORDER BY b.id, IFNULL(g.armis_agencyName,'zzzN/A'),IF(a.cm_title<>'', a.cm_title, a.cm_name),b.`timestamp`,d.cm_userName ASC
LIMIT 1 OFFSET _recordNum;

  END IF;


  RETURN nextAgency;
END$$
DELIMITER ;
