DELIMITER $$

DROP FUNCTION IF EXISTS `alfrescoreporting`.`breakLongWord`$$
CREATE DEFINER=`root`@`localhost` FUNCTION  `alfrescoreporting`.`breakLongWord`(_word varchar(1000)) RETURNS varchar(1000) CHARSET latin1
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
END;

 $$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `alfrescoreporting`.`GetNextAgencyNameCertificateOfDisposal`$$
CREATE DEFINER=`root`@`localhost` FUNCTION  `alfrescoreporting`.`GetNextAgencyNameCertificateOfDisposal`(_documentId INT,
                                    _dateFrom date,
                                    _dateTo date) RETURNS varchar(225) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE nextAgency VARCHAR(225);

  IF _dateFrom <> _dateTo THEN

select
a.armis_agencyName into nextAgency
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
AND  d.mimetype is null
AND d.id > _documentId
AND d.rma_declaredAt BETWEEN _dateFrom AND _dateTo
order by d.id,s.cm_title,a.armis_agencyName, d.cm_name;

  ELSE

select
a.armis_agencyName into nextAgency
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
AND  d.mimetype is null
AND d.id > _documentId
AND d.rma_declaredAt = _dateTo
order by d.id,s.cm_title,a.armis_agencyName, d.cm_name;
  END IF;
  
  RETURN nextAgency;
END;

 $$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `alfrescoreporting`.`GetNextAgencyNameCOD`$$
CREATE DEFINER=`root`@`localhost` FUNCTION  `alfrescoreporting`.`GetNextAgencyNameCOD`(_documentId INT,
                                    _dateFrom date,
                                    _dateTo date) RETURNS varchar(225) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE nextAgency VARCHAR(225);

  IF _dateFrom <> _dateTo THEN

select
a.armis_agencyName into nextAgency
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
AND  d.mimetype is null
AND d.rma_cutOffDate BETWEEN _dateFrom AND _dateTo
and d.id > _documentId
order by d.id,  s.cm_title,a.armis_agencyName, CONCAT(d.rma_shelf, ' - ' ,CONCAT(d.rma_box,' - ',d.rma_file)), d.cm_name
LIMIT 1;

  ELSE
select
a.armis_agencyName INTO nextAgency
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
AND  d.mimetype is null
AND d.rma_cutOffDate = _dateTo
and d.id > _documentId
order by d.id, s.cm_title,a.armis_agencyName, CONCAT(d.rma_shelf, ' - ' ,CONCAT(d.rma_box,' - ',d.rma_file)), d.cm_name
LIMIT 1;
  END IF;


  RETURN nextAgency;
END;

 $$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `alfrescoreporting`.`GetNextAgencyNameNRI`$$
CREATE DEFINER=`root`@`localhost` FUNCTION  `alfrescoreporting`.`GetNextAgencyNameNRI`(_documentId INT,
                                    _dateFrom date,
                                    _dateTo date) RETURNS varchar(225) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE nextAgency VARCHAR(225);

  IF _dateFrom <> _dateTo THEN

select
a.armis_agencyName into nextAgency
from document d
inner join site s
ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
AND d.isLatest = 1 and s.isLatest = 1
RIGHT JOIN agency a
ON s.noderef = a.armis_site
AND a.isLatest = 1 and s.isLatest = 1
INNER JOIN folder f
ON d.parent_noderef = f.noderef
AND d.isLatest = 1 and f.isLatest = 1
WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
AND  d.mimetype != ''
AND d.id > _documentId
AND d.rma_declaredAt BETWEEN _dateFrom AND _dateTo
order by d.id,s.cm_title,a.armis_agencyName, d.cm_name
LIMIT 1;

  ELSE

select
a.armis_agencyName into nextAgency
from document d
inner join site s
ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
AND d.isLatest = 1 and s.isLatest = 1
RIGHT JOIN agency a
ON s.noderef = a.armis_site
AND a.isLatest = 1 and s.isLatest = 1
INNER JOIN folder f
ON d.parent_noderef = f.noderef
AND d.isLatest = 1 and f.isLatest = 1
WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
AND  d.mimetype != ''
AND d.id > _documentId
AND d.rma_declaredAt = _dateTo
order by d.id,s.cm_title,a.armis_agencyName, d.cm_name
LIMIT 1;

  END IF;


  RETURN nextAgency;
END;

 $$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `alfrescoreporting`.`GetNextAgencyNameNRI_NE`$$
CREATE DEFINER=`root`@`localhost` FUNCTION  `alfrescoreporting`.`GetNextAgencyNameNRI_NE`(_documentId INT,
                                    _dateFrom date,
                                    _dateTo date) RETURNS varchar(225) CHARSET latin1
    DETERMINISTIC
BEGIN
  DECLARE nextAgency VARCHAR(225);

  IF _dateFrom <> _dateTo THEN

select
a.armis_agencyName into nextAgency
from document d
inner join site s
ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
AND d.isLatest = 1 and s.isLatest = 1
RIGHT JOIN agency a
ON s.noderef = a.armis_site
AND a.isLatest = 1 and s.isLatest = 1
INNER JOIN folder f
ON d.parent_noderef = f.noderef
AND d.isLatest = 1 and f.isLatest = 1
WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
AND  d.mimetype is null
AND d.id > _documentId
AND d.rma_declaredAt BETWEEN _dateFrom AND _dateTo
order by d.id,s.cm_title,a.armis_agencyName, d.cm_name
LIMIT 1;

  ELSE

select
a.armis_agencyName into nextAgency
from document d
inner join site s
ON LTRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(d.path, '/Company Home/Sites/rm/documentLibrary/(RM)', -1),'/',1)) = UPPER(s.cm_name)
AND d.isLatest = 1 and s.isLatest = 1
RIGHT JOIN agency a
ON s.noderef = a.armis_site
AND a.isLatest = 1 and s.isLatest = 1
INNER JOIN folder f
ON d.parent_noderef = f.noderef
AND d.isLatest = 1 and f.isLatest = 1
WHERE d.path like '/Company Home/Sites/rm/documentLibrary/(RM)%'
AND  d.mimetype is null
AND d.id > _documentId
AND d.rma_declaredAt = _dateTo
order by d.id,s.cm_title,a.armis_agencyName, d.cm_name
LIMIT 1;

  END IF;


  RETURN nextAgency;
END;

 $$

DELIMITER ;

DELIMITER $$

DROP FUNCTION IF EXISTS `alfrescoreporting`.`GetNextAgencyNameUM`$$
CREATE DEFINER=`root`@`localhost` FUNCTION  `alfrescoreporting`.`GetNextAgencyNameUM`(_recordNum INT,
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
END;

 $$

DELIMITER ;