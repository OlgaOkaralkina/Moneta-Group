/* @PURPOSE				: 	THIS IS APEX TRIGGER ON ContactContactRelation OBJECT USED FOR CREATE OR DELETE CONTACT RELATED CONTACTS SHARING RECORDS 
 * 							(IF ACCOUNT IS ALREADY SHARED AND ANY MODIFICATION IS DONE ON THIS ACCOUNT)
 *  @CREATED BY			:	DWS
 * @CREATED DATE		:	01 JAN 2019
 *  @LAST MODIFIED DATE	:	01 JAN 2019
 *  @UPDATED BY 		:	DWS
*/
trigger ContactContactTrigger on FinServ__ContactContactRelation__c (after insert,  after delete) {

    /**
    @ PURPOSE     : CREATE CONTACT RELATED CONTACTS SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND FTER THAT ADDED NEW CONTACT RELATED CONTACTS).
    @ PARAMETER   : 1. List [ FinServ__ContactContactRelation__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    if (Trigger.isInsert) {
        if (Trigger.isAfter) { 
            ContactContactTriggerHandler.createContactContactSharing(Trigger.New);
        }
     /**
    @ PURPOSE     : DELETE CONTACT RELATED CONTACTS SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND AFTER THAT DELETED CONTACT RELATED CONTACTS ).
    @ PARAMETER   : 1. List [ FinServ__ContactContactRelation__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    } else if (Trigger.isDelete) {
        ContactContactTriggerHandler.deleteContactContactSharing(Trigger.Old); 
    } 
}