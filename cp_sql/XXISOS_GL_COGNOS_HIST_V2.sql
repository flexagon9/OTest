SET DEFINE OFF
/*

+==========================================================================+
|                                                                          |
| File Name             :    XXISOS_GL_COGNOS_HIST_V2.sql                   |
|                                                                          |
|                                                                          |
|Change Record:                                                            |
|===============                                                           |
|Version   Date        Author           Remarks                            |
|=======   ==========  =============    ============================       |
|Draft 1   13-Oct-2015 Sabapathy        Initial draft version              |
|1.1       22-Jan-2016 Dinesh           #HPQC115126 To add new columns     |
|1.2       01-Mar-2016 Dinesh           #HPQC116967 added new functions for|
|                                       BDM also to improve  performance   |
|1.3       12-Apr-2016 Sabapathy        #HPQC115348 add trx_number,        |
|                                       trx_line_number & description      |
|                                       for certain lines                  |
|1.4       30-May-2018 Dinesh           RITM0023089 adding who colunns     |
|                                       project_id and transaction_date    |
|1.5       31-May-2018 Dinesh           HPQC143214 adding package columns  |
|1.6       02-Jul-2018 Dinesh           IM0041273 Taking out UDA table to remove duplicates |
|1.6       20-Jul-2018 Dinesh           IM0041273 Taking values from history table |
+==========================================================================+
*/
CREATE OR REPLACE FORCE VIEW APPS.XXISOS_GL_COGNOS_HIST_V
(
   ORGANIZATION_ID,
   ACTUAL_PERIOD,
   LEGAL_ENTITY,
   BALANCE_TYPE,
   COA_COMPANY,
   COA_ACCOUNT,
   COA_ACCOUNT_DESC,
   COA_COST_CENTER,
   COA_COST_CENTER_DESC,
   COA_INTERCOMPANY,
   COA_PRODUCT,
   COA_PRODUCT_DESC,
   FUNCTIONAL_COMPANY,
   AMOUNT,
   PROJECT_NUMBER,
   PROJECT_NAME,
   PROJECT_TASK,
   CC_PC,
   CONTRACT_STATUS,
   TRX_NUMBER,
   TRX_LINE_NUMBER,
   DESCRIPTION,
   CUSTOMER_SUPPLIER,
   REQUEST_ID,
   FILE_NAME,
   JOURNAL_SOURCE,
   COGNOS_INT_LOGIC,
   JOURNAL_CATEGORY,
   STATUS,
   ERROR_MSG,
   STATISTICAL_CURR,
   AE_HEADER_ID,
   AE_LINE_NUM,
   ORIGINAL_PERIOD,
   PROGRAM_CUSTOMER_NUMBER,
   PROGRAM_CUSTOMER,
   CONVERSION_RATE_USD,
   PRODUCT_PARENTS,
   COA_PRODUCT_PARENT0,
   COA_PRODUCT_PARENT1,
   COA_PRODUCT_PARENT2,
   COA_PRODUCT_PARENT3,
   PROGRAM_OWNER,
   TRX_DATE,                                                     --RITM0023089
   PROJECT_ID,                                                  -- RITM0023089
   CREATION_DATE,                                               -- RITM0023089
   CREATED_BY,                                                  -- RITM0023089
   LAST_UPDATE_DATE,                                            -- RITM0023089
   LAST_UPDATED_BY,                                             -- RITM0023089
   PACKAGE_ID,                                                          --HPQC143214
   PACKAGE_NAME,                                                        --HPQC143214
   PACKAGE_GROUP                                                        --HPQC143214
)
AS
   SELECT hou.organization_id,
          gcth.actual_period,
          gcth.legal_entity,
          NVL (gcth.budget_type, gcth.account_type) balance_type,
          gcth.segment1 coa_company,
          gcth.segment2 coa_account,
          (SELECT v.description
             FROM fnd_flex_values_vl v, fnd_flex_value_sets s
            WHERE v.flex_value_set_id = s.flex_value_set_id
                  AND s.flex_value_set_name = 'XXISOS_COA_ACCOUNT'
                  AND v.flex_value =
                         DECODE (
                            INSTR (gcth.segment2, '.'),
                            0, gcth.segment2,
                            SUBSTR (gcth.segment2,
                                    1,
                                    INSTR (gcth.segment2, '.') - 1)))
             coa_account_desc,
          gcth.segment3 coa_cost_center,
          (SELECT v.description
             FROM fnd_flex_values_vl v, fnd_flex_value_sets s
            WHERE     v.flex_value_set_id = s.flex_value_set_id
                  AND s.flex_value_set_name = 'XXISOS_COA_COST_CENTRE'
                  AND v.flex_value = gcth.segment3)
             coa_cost_center_desc,
          gcth.segment4 coa_intercompany,
          gcth.segment5 coa_product,
          (SELECT v.description
             FROM fnd_flex_values_vl v, fnd_flex_value_sets s
            WHERE     v.flex_value_set_id = s.flex_value_set_id
                  AND s.flex_value_set_name = 'XXISOS_COA_PRODUCT'
                  AND v.flex_value = gcth.segment5)
             coa_product_desc,
          gcth.currency_code functional_company,
          gcth.amount,
          gcth.project_number,
          --          (SELECT long_name
          --             FROM apps.pa_projects_all
          --            WHERE segment1 = gcth.project_number) --HPQC116967
          pa.long_name project_name,                              --HPQC116967
          gcth.project_task,
          gcth.cost_center cc_pc,
          gcth.contract_status,
          ----          xxisos_gl_cognos_pkg.get_trx_number (gcth.user_je_source_name,                   -- HPQC#115348 - Sabapathy
          ----                                               gcth.distribution_id,
          ----                                               gcth.ae_header_id,
          ----                                               gcth.ae_line_num)
          ----             trx_number,
          CASE
             WHEN UPPER (gcth.user_je_source_name) = 'PROJECTS'
                  AND UPPER (gcth.user_je_category_name) =
                         'MISCELLANEOUS TRANSACTION'
             THEN
                TO_CHAR (gcth.distribution_id)      -- #HPQC115348 - Sabapathy
             ELSE
                xxisos_gl_cognos_pkg.
                 get_trx_number (gcth.user_je_source_name,
                                 gcth.distribution_id,
                                 gcth.ae_header_id,
                                 gcth.ae_line_num)
          END
             trx_number,
          ----          xxisos_gl_cognos_pkg.get_trx_line_number (gcth.user_je_source_name,
          ----                                                    gcth.distribution_id,
          ----                                                    gcth.ae_header_id,
          ----                                                    gcth.ae_line_num)
          ----             trx_line_number,
          DECODE (UPPER (gcth.user_je_source_name),
                  'PAYROLL UPLOAD', TO_CHAR (gcth.ae_line_num), -- #HPQC115348 - Sabapathy
                  'SPREADSHEET', TO_CHAR (gcth.ae_line_num), -- #HPQC115348 - Sabapathy
                  xxisos_gl_cognos_pkg.
                   get_trx_line_number (gcth.user_je_source_name,
                                        gcth.distribution_id,
                                        gcth.ae_header_id,
                                        gcth.ae_line_num))
             trx_line_number,                -- End of HPQC#115348 - Sabapathy
          gcth.description,
          xxisos_gl_cognos_pkg.get_party_name (gcth.user_je_source_name,
                                               gcth.distribution_id,
                                               gcth.ae_header_id,
                                               gcth.ae_line_num,
                                               gcth.project_number)
             customer_supplier,
          gcth.request_id,
          gcth.file_name,
          gcth.user_je_source_name journal_source,
          gcth.group_extract cognos_int_logic,
          gcth.user_je_category_name journal_category,
          gcth.status,
          gcth.error_msg,
          DECODE (gcth.stat_curr, 'STAT', 'Yes', 'No') statistical_curr,
          gcth.ae_header_id,
          gcth.ae_line_num,
          gcth.original_period,
          NVL (h.account_number,          --             xxisos_gl_cognos_pkg.
                                 --              get_program_party_number (gcth.project_number))
                                 gcth.program_customer_number)
             program_customer_number,                             --HPQC116967
          --#HPQC115126
          NVL (p.party_name,              --             xxisos_gl_cognos_pkg.
                             --              get_program_party_name (gcth.project_number))
                             gcth.program_customer_name) program_customer, --HPQC116967
          NVL (
             (SELECT conversion_rate
                FROM apps.gl_daily_rates
               WHERE     from_currency = gcth.currency_code
                     AND to_currency = 'USD'
                     AND conversion_type = 'Corporate'
                     AND conversion_date =
                            TRUNC (TO_DATE (gcth.original_period, 'YYMM'),
                                   'MM')),
             0)
             conversion_rate_usd,
          gcth.product_parents,
          --          xxisos_gl_cognos_pkg.get_product_parents
          --                                               (gcth.segment5) ,--HPQC116967
          gcth.coa_product_parent0,                               --HPQC116967
          gcth.coa_product_parent1,                               --HPQC116967
          gcth.coa_product_parent2,                               --HPQC116967
          gcth.coa_product_parent3,                               --HPQC116967
          NVL (pa.attribute1,                                          --NVL (
                             gcth.program_owner) --  xxisos_gl_cognos_pkg.get_program_owner (gcth.project_number)))
                                                program_owner,   --HPQC116967,
          NVL (gcth.trx_date, TO_DATE (gcth.original_period, 'YYMM'))
             trx_date,                                           --RITM0023089
          gcth.project_id,                                      -- RITM0023089
          gcth.CREATION_DATE,                                   -- RITM0023089
          gcth.CREATED_BY,                                      -- RITM0023089
          gcth.LAST_UPDATE_DATE,                                -- RITM0023089
          gcth.LAST_UPDATED_BY,                                 -- RITM0023089
          /*uda.c_ext_attr6 PACKAGE_ID,                                   --HPQC143214
          uda.c_ext_attr7 PACKAGE_NAME,                                 --HPQC143214
          uda.c_ext_attr8 PACKAGE_GROUP                                 --HPQC143214*/           -- Taking out UDA join for IM0041273  on 2-Jul-2018
          gcth.PACKAGE_ID,                                   --HPQC143214 -- IM0041273 taking from history table instead of null
          gcth.PACKAGE_NAME,                                 --HPQC143214 -- IM0041273 taking from history table instead of null
          gcth.PACKAGE_GROUP                                 --HPQC143214 --       -- IM0041273 taking from history table instead of null
     FROM xxisos.xxisos_gl_cognos_tbl_hist gcth,
          apps.hr_operating_units hou,
          pa_projects_all pa,
          pa_project_customers cust,
          hz_cust_accounts h,
          hz_parties p
         /* ,(SELECT ppeeb.*
             FROM ego_attr_groups_v eagv, pa_projects_erp_ext_b ppeeb
            WHERE     eagv.application_id = 275
                  AND eagv.ATTR_GROUP_TYPE = 'PA_PROJ_ATTR_GROUP_TYPE'
                  AND eagv.attr_group_name = 'ISOS_CONTRACT_STATUS_SUMMARY'
                  AND eagv.attr_group_id = ppeeb.attr_group_id) uda --HPQC143214
                  */ -- Taking out UDA join for IM0041273  on 2-Jul-2018
    WHERE     1 = 1
          AND gcth.ledger_id = hou.set_of_books_id(+)
          AND gcth.project_id = pa.project_id(+)
          AND cust.project_id(+) = pa.project_id
          AND h.cust_account_id(+) = cust.customer_id
          AND p.party_id(+) = h.party_id
            /* AND gcth.project_id = uda.project_id(+)
          AND gcth.PROJECT_TASK = uda.c_ext_attr1(+)
          AND NVL (gcth.trx_date, TO_DATE (gcth.original_period, 'YYMM')) BETWEEN uda.
                                                                                   d_ext_attr1(+)
                                                                              AND uda.
                                                                                   d_ext_attr2(+)*/ -- Taking out UDA join for IM0041273  on 2-Jul-2018
/