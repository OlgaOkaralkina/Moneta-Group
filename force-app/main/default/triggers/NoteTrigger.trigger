/*  @PURPOSE            :   THIS IS APEX TRIGGER ON Notes__c OBJECT USED FOR CREATE OR DELETE CONTACT RELATED EMAIL SHARING RECORDS 
 *                          (IF ACCOUNT IS ALREADY SHARED AND ANY MODIFICATION IS DONE ON THIS ACCOUNT)
 *  @CREATED BY         :   DWS
 *  @CREATED DATE       :   02 JAN 2019
 *  @LAST MODIFIED DATE :   02 JAN 2019
 *  @UPDATED BY         :   DWS
*/
trigger NoteTrigger on Notes__c (after insert,  after delete) {

    /**
    @ PURPOSE     : CREATE CONTACT RELATED NOTES SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND FTER THAT ADDED NEW CONTACT RELATED CONTACTS).
    @ PARAMETER   : 1. List [ Additional_Email__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    if (Trigger.isInsert) {
        if (Trigger.isAfter) { 
            NoteTriggerHandler.createContactNoteSharing(Trigger.New);
        }
     /**
    @ PURPOSE     : DELETE CONTACT RELATED NOTES SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND AFTER THAT DELETED CONTACT RELATED CONTACTS ).
    @ PARAMETER   : 1. List [ Additional_Email__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    } else if (Trigger.isDelete) {
        NoteTriggerHandler.deleteContactNoteSharing(Trigger.Old); 
    }
}