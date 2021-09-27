/*  @PURPOSE            :   THIS IS APEX TRIGGER ON Account OBJECT USED FOR KEEP EXISTING SHARING RECORDS IF OWNER OF RECORD WILL CHANGE
 *  @CREATED BY         :   DWS
 *  @CREATED DATE       :   17 JAN 2019
 *  @LAST MODIFIED DATE :   17 JAN 2019
 *  @UPDATED BY         :   DWS
*/
trigger CopyAccountShare on Account (before update, after update) {
    if(Trigger.isBefore) {
        if(Trigger.IsUpdate) {
            CopyAccountShareHandler.keepOldSharing(Trigger.new, Trigger.oldMap);
        }
    }
     
    if(Trigger.isAfter) {
        if(Trigger.IsUpdate) {
            CopyAccountShareHandler.deleteDuplicateAccountShareRec(Trigger.new, Trigger.oldMap);
        }
    }
}