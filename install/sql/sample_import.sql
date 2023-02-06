DECLARE
   ln_request_id         NUMBER;
   user_id               NUMBER;
   resp_id               NUMBER;
   app_resp_id           NUMBER;
   l_req_return_status   BOOLEAN;

   lc_phase              VARCHAR2 (50);
   lc_status             VARCHAR2 (50);
   lc_dev_phase          VARCHAR2 (50);
   lc_dev_status         VARCHAR2 (50);
   lc_message            VARCHAR2 (50);
   f                     UTL_FILE.FILE_TYPE;
   file_location         VARCHAR2 (200);
   file_name             VARCHAR2 (200);
   s                     VARCHAR2 (200);
BEGIN
   SELECT user_id
     INTO user_id
     FROM fnd_user
    WHERE user_name LIKE '%SAMPLE%';

   SELECT RESPONSIBILITY_ID, APPLICATION_ID
     INTO resp_id, app_resp_id
     FROM fnd_responsibility
    WHERE RESPONSIBILITY_KEY = 'SAMPLE_ADMINISTRATOR';

   ln_request_id := NULL;
   apps.fnd_global.apps_initialize (user_id, resp_id, app_resp_id);
   ln_request_id :=
      FND_REQUEST.submit_request (application   => 'SAMPLE',
                                  program       => 'SAMPLE_IMP_EXP_RWB_REPORTS',
                                  argument1     => 'I'        -- p_employee_id
                                                      ,
                                  argument2     => '&1/&2',
                                  argument3     => NULL,
                                  argument4     => '&3');

   DBMS_OUTPUT.put_line ('ln_request_id-->' || ln_request_id);
   COMMIT;

   l_req_return_status :=
      fnd_concurrent.wait_for_request (request_id   => ln_request_id,
                                       INTERVAL     => 5,
                                       max_wait     => 0,
                                       phase        => lc_phase,
                                       STATUS       => lc_status,
                                       dev_phase    => lc_dev_phase,
                                       dev_status   => lc_dev_status,
                                       MESSAGE      => lc_message);
   COMMIT;

   IF l_req_return_status = TRUE
   THEN
      DBMS_OUTPUT.put_line ('Import Successfull Completed-->');
      --DBMS_OUTPUT.put_line ('Import Successfull Completed-->');

      SELECT SUBSTR (logfile_name, 1, INSTR (logfile_name, '/', -1) - 1),
             SUBSTR (logfile_name, INSTR (logfile_name, '/', -1) + 1)
        INTO file_location, file_name
        FROM fnd_concurrent_requests
       WHERE ln_request_id = request_id;

      DBMS_OUTPUT.put_line ('file_location-->' || file_location);
      DBMS_OUTPUT.put_line ('file_name-->' || file_name);


      f := UTL_FILE.FOPEN (file_location, file_name, 'R');

      IF UTL_FILE.IS_OPEN (f)
      THEN
         LOOP
            BEGIN
               UTL_FILE.GET_LINE (f, s);
               DBMS_OUTPUT.put_line (s);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  EXIT;
            END;
         END LOOP;

         COMMIT;
         UTL_FILE.fclose (f);
      END IF;
   ELSE
      DBMS_OUTPUT.put_line ('Import failed --Please check the log-->');
   END IF;
END;
/
