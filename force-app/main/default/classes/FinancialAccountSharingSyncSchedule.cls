/* @PURPOSE				: 	THIS IS SCHEDULE APEX CLASS FOR SCHEDULE THE FinancialAccountSharingBatch APEX CLASS
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	26 AUG 2019
*  @LAST MODIFIED DATE	:	26 AUG 2019 (INITIAL DEVELOPMENT)
*  @UPDATED BY 			:	DWS
*/
global class FinancialAccountSharingSyncSchedule implements Schedulable {
	
    // TO GET OR SET LAST FIRED TIME
    global DateTime LAST_FIRED_TIME {get; set;}
    
    // CONSTRUCTOR
    global FinancialAccountSharingSyncSchedule(DateTime lastFiredTime) {
        if(lastFiredTime != NULL) {
            LAST_FIRED_TIME = lastFiredTime;
        } else {
            LAST_FIRED_TIME = NULL;
        }
    }
    
    // TO EXICUTE SCHEDULER
    global void execute(SchedulableContext ctx) {
        processSynchronization(LAST_FIRED_TIME, ctx.getTriggerId());
    }    
    
    /**
    @ PURPOSE     : USED TO ACTUAL SCHEDULE THE BATCH CLASS
    @ PARAMETER   : DateTime lastFireTime, String strScheduleId
    @ RETURN TYPE : NOT RETURN.
    */
    public static void processSynchronization(DateTime lastFireTime, String strScheduleId) {
        
        try {
            if(lastFireTime != NULL) {
                Database.executeBatch(new FinancialAccountSharingBatch(lastFireTime), 200);
            } else {
                Database.executeBatch(new FinancialAccountSharingBatch(NULL), 200);
            }            
            
            System.abortJob(strScheduleId);
            Datetime sysTime = System.now();
            sysTime = sysTime.addMinutes(30);
            String chron_exp = ' ' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + 
                ' ' + sysTime.month() + ' ? ' + sysTime.year();
            System.schedule('Financial Account Sharing Batch', chron_exp, new FinancialAccountSharingSyncSchedule(System.now()));
            
        } catch(Exception e) {
            System.debug('Exception : ' + e.getMessage() + ', Stack Trace : ' + e.getStackTraceString());
        }
    }
}