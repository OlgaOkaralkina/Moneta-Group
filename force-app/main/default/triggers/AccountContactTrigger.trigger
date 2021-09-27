/* @PURPOSE				: 	THIS IS APEX TRIGGER ON AccountContactRelation OBJECT USED FOR CREATE OR DELETE ACCOUNT RELATED CONTACTS SHARING RECORDS 
 * 							(IF ACCOUNT IS ALREADY SHARED AND ANY MODIFICATION IS DONE ON THIS ACCOUNT)
 *  @CREATED BY			:	DWS
 * @CREATED DATE		:	24 DEC 2018
 *  @LAST MODIFIED DATE	:	24 DES 2018 
 *  @UPDATED BY 			:	DWS
*/
trigger AccountContactTrigger on AccountContactRelation (after insert,  after delete) {
    
     /**
    @ PURPOSE     : CREATE ACCOUNT RELATED CONTACTS SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND FTER THAT ADDED NEW ACCOUNT RELATED CONTACTS).
    @ PARAMETER   : 1. List [ AccountContactRelation RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    if (Trigger.isInsert) {
        if (Trigger.isAfter) { 
            //System.debug('Test :::: '+JSON.serialize(Trigger.New));
            AccountContactTriggerHandler.createAccountContactSharing(Trigger.New);
        }
     /**
    @ PURPOSE     : DELETE ACCOUNT RELATED CONTACTS SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND AFTER THAT DELETED ACCOUNT RELATED CONTACTS ).
    @ PARAMETER   : 1. List [ AccountContactRelation RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    } else if (Trigger.isDelete) {
        AccountContactTriggerHandler.deleteAccountContactSharing(Trigger.Old); 
    } 
}