/******************************************************************************
RCS HEADER
==========
Id           : $Id: SAMPLE_REPORT.sql,v 1.2 2020/02/26 15:30:01 userx Exp $
Author       : $Author: userx $
Date         : $Date: 2020/02/26 15:30:01 $
History      : Revision 
History      : Initial revision
History      :
History      :
******************************************************************************/
WHENEVER SQLERROR CONTINUE
PROMPT
PROMPT DROP VIEW APPS.SAMPLE if EXISTS
PROMPT
DROP VIEW APPS.SAMPLE;

PROMPT
PROMPT Creating VIEW APPS.SAMPLE
PROMPT
/* Formatted on 2/19/2020 4:51:51 PM (QP5 v5.256.13226.35510) */
CREATE OR REPLACE FORCE VIEW APPS.SAMPLE
(
 "SAMPLE"
)
 BEQUEATH DEFINER
AS
 SELECT SAMPLE
      
   FROM DUAL
;
/


   
