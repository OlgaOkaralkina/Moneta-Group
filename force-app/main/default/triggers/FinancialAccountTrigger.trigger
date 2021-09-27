/*  @PURPOSE			: 	THIS IS APEX TRIGGER ON FinServ__FinancialAccount__c OBJECT USED FOR CREATE OR DELETE ACCOUNT RELATED FinancialAccount SHARING RECORDS 
 * 							(IF ACCOUNT IS ALREADY SHARED AND ANY MODIFICATION IS DONE ON THIS ACCOUNT)
 *  @CREATED BY			:	DWS
 *  @CREATED DATE		:	03 JAN 2019
 *  @LAST MODIFIED DATE	:	26 AUG 2019 (LINE NUMBER 12 TO 20) 
 *  @UPDATED BY 		:	DWS
*/
trigger FinancialAccountTrigger on FinServ__FinancialAccount__c (after insert,  after delete) {

    List<Trigger_Configuration__mdt> triggerConfiList = [SELECT Id, IsActive__c
                                                         FROM Trigger_Configuration__mdt
                                                         WHERE IsActive__c = TRUE AND
                                                         MasterLabel = 'FinancialAccountTrigger'
                                                         LIMIT 1];
    /**
    @ PURPOSE     : CREATE ACCOUNT RELATED FinancialAccount SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND FTER THAT ADDED NEW CONTACT RELATED CONTACTS).
    @ PARAMETER   : 1. List [ Additional_Email__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            // CODE REMOVED, BECAUSE OF SHARING FUNCTIONALITY IS CONVERTED INTO FinancialAccountSharingBatch BATCH CLASS.
            // DATE: 26 AUG 2019
            if(!triggerConfiList.isEmpty() && triggerConfiList[0].IsActive__c) {                
                FinancialAccountTriggerHandler.createAccountFinancialAccountSharing(Trigger.New);
            }            
        }
        
     /**
    @ PURPOSE     : DELETE ACCOUNT RELATED FinancialAccount SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND AFTER THAT DELETED CONTACT RELATED CONTACTS ).
    @ PARAMETER   : 1. List [ Additional_Email__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    } else if (Trigger.isDelete) {
        if(!triggerConfiList.isEmpty() && triggerConfiList[0].IsActive__c) {                
            FinancialAccountTriggerHandler.deleteAccountFinancialAccountSharing(Trigger.Old); 
        } 
    }    
}