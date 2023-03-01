CREATE OR REPLACE PACKAGE APPS.INVOICE_PK
   AUTHID CURRENT_USER
/******************************************************************************
RCS HEADER
==========
Id           : $Id: INVOICE_PK.pks,v 1.4 2022/12/13 19:29:18 xyc Exp $
Author       : $Name: XYV $
Date         : $Date: 2022/12/13 19:29:18 $
Locker       : $Locker:  $
History      :
History      : Initial revision
******************************************************************************/
IS
   PROCEDURE IMPORT_MAIN (x_errbuf      IN OUT VARCHAR2,
                          x_retcode     IN OUT NUMBER,
                          p_data_file   IN     VARCHAR2);

   PROCEDURE SUBMIT_INVOICE_IMPORT (p_data_file IN VARCHAR2);
END TKE_TP_INO_AP_01_INVOICE_PK;
/