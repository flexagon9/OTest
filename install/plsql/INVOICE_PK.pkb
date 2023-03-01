CREATE OR REPLACE PACKAGE BODY APPS.INVOICE_PK
IS
   /******************************************************************************
   RCS HEADER
   ==========
   Id           : $Id: INVOICE_PK.pkb,v 1.10 2023/01/25 04:14:12 xyc Exp $
   Author       : $Name: XYC $
   Date         : $Date: 2023/01/25 04:14:12 $
   Locker       : $Locker:  $   
   History      :
   History      : Initial revision
   ******************************************************************************/

   gn_org_id             NUMBER := FND_GLOBAL.ORG_ID;
   gn_request_id         NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
   gn_user_id                 NUMBER := FND_GLOBAL.user_id;
   gn_login_id                NUMBER := FND_GLOBAL.login_id;   
   gk_user_id            NUMBER;
   gk_resp_appl_id       NUMBER;
   gk_resp_id            NUMBER;
   gk_enable_vpd         VARCHAR2 (3);
   g_loaded              VARCHAR2 (25) := 'LOADED';
   g_errored             VARCHAR2 (25) := 'ERRORED';
   g_ready               VARCHAR2 (25) := 'READY';
   g_pending             VARCHAR2 (25) := 'PENDING';
   g_interfaced          VARCHAR2 (25) := 'INTERFACED';
   g_interface_error     VARCHAR2 (25) := 'INTERFACE_ERR';
   --g_validated        VARCHAR2 (25) := 'VALIDATED';
   g_processed           VARCHAR2 (25) := 'PROCESSED';
   g_imported            VARCHAR2 (25) := 'IMPORTED';
   g_source              VARCHAR2 (90) := 'BASWARE';
   g_batch_name          VARCHAR2 (90);
   g_group_id            NUMBER;
   g_trx_id              NUMBER;
   g_payload_id          VARCHAR2 (100);
   gc_get_pay_group      VARCHAR2 (30) := NULL;
   gc_pymt_method_code   VARCHAR2 (30) := NULL;
   gn_legal_entity_id    NUMBER := NULL;


   PROCEDURE IMPORT_MAIN (x_errbuf      IN OUT VARCHAR2,
                          x_retcode     IN OUT NUMBER,
                          p_data_file   IN     VARCHAR2)
   IS
      l_ap_request_id      NUMBER;
      l_ap_batch_cnt       NUMBER;


      CURSOR lcu_intf_error (
         p_parent_id    NUMBER)
      IS
           SELECT air.reject_lookup_code || ' - ' || LKP.DESCRIPTION
                     reject_lookup_code,
                  NULL line_number,
                  aii.invoice_num,
                  NULL invoice_line_id,
                  aii.INVOICE_ID
             FROM ap_interface_rejections air,
                  FND_LOOKUP_VALUES_VL LKP,
                  ap_invoices_interface aii
            WHERE     air.parent_id = p_parent_id
                  AND aii.invoice_id = air.parent_id
                  AND LKP.LOOKUP_TYPE(+) = 'REJECT CODE'
                  AND AIR.REJECT_LOOKUP_CODE = LKP.LOOKUP_CODE(+)
         ORDER BY 5, 4;

      lv_intf_error_msgl   VARCHAR2 (2000) := NULL;

      l_invoice_Id         NUMBER;
   BEGIN
      IF p_data_file IS NULL
      THEN
         Null;
      END IF;
      EXCEPTION WHEN no_data_gound THEN
         x_retcode := -1;
         x_errbuf  := 'Error in reading files from Basware SFTP.';
   END IMPORT_MAIN;



   PROCEDURE SUBMIT_INVOICE_IMPORT (p_data_file IN VARCHAR2)
   IS
      l_ap_request_id   NUMBER;
      l_ap_batch_cnt    NUMBER;
      l_errbuf          VARCHAR2 (1000);
      l_retcode         NUMBER;
   BEGIN
              
      
      IF (l_ap_request_id = 0)
      THEN
         l_ap_batch_cnt := 1;
      ELSE
         l_ap_batch_cnt := 0;
      END IF;
   END SUBMIT_INVOICE_IMPORT;
END INVOICE_PK;
/