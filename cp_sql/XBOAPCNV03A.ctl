-------------------------------------------------------------------------------------------------
--Copyright Information: (C) Copyright 2009 IBM Corporation All Rights Reserved.   
--This software is the confidential and proprietary information of IBM Corporation.
--("Confidential Information"). Redistribution of source code or binary form of the source code
--is prohibited without prior authorization from IBM Corporation.
-------------------------------------------------------------------------------------------------

--  ======================================================================================
-- File Name         : xxapcnv03a.ctl
-- File Type         : SQL*Loader Control file.
-- RICEW Object id   : XXAPCNV03
-- Description       : This SQL*Loader file is used to load  data
--                     from flat file to the staging table XX_AP_OPEN_INVOICE_STG
-- Maintenance History:
-- 
-- Date         Version          Name             Remarks
-- -----------  ---------   -----------------     ---------------------------------------
-- 27-Dec-2006  1.0         Satyajit Biswas       Draft Version.
-- 25-May-2010  1.1         Aboothahir M          Modified according to the staging table structure
-- 23-JAN-2019  1.2         Muru                  Modified 
--  =====================================================================================
OPTIONS (SKIP=1)
LOAD DATA CHARACTERSET WE8ISO8859P1
TRUNCATE
INTO TABLE BOLINF.XX_AP_OPEN_INVOICE_STG
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"' 
TRAILING NULLCOLS
(
RECORD_ID                                                              "XX_AP_CNV_03_STG_S.NEXTVAL"
,TRANSACTION_CODE           "TRIM(:TRANSACTION_CODE)"
,STATUS                                                                         "TRIM(:STATUS)"
,LAST_UPDATE_DATE                                "to_date(SYSDATE)"
,LAST_UPDATED_BY                                   "FND_GLOBAL.USER_ID"
,LAST_UPDATE_LOGIN                               "FND_GLOBAL.USER_ID"
,CREATION_DATE                                                     "to_date(SYSDATE)"
,CREATED_BY                                                  "FND_GLOBAL.USER_ID"
)