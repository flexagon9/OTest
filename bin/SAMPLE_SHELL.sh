APPS_USER="$1"
APPS_PWD="$2"
sqlplus $APPS_USER/$APPS_PWD << _END2_ 
        Set serveroutput on size 999999		
         @$XBOL_TOP/install/sql/rwb_import.sql $XBOL_TOP/SAMPLE_ctl.ctl   ADMIN >> $LOG  
	@$XBOL_TOP/install/sql/sample_import.sql $XBOL_TOP/admin 
        sample_ctl.ctl  SEEDED >> $LOG 
	exit
_END2_	
