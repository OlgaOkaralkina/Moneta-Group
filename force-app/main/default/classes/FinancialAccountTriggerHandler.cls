/* @PURPOSE				: 	THIS IS HELPER APEX CLASS FOR FinancialAccountTrigger APEX TRIGGER 
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	02 JAN 2019
*  @LAST MODIFIED DATE	:	02 JAN 2019
*  @LAST MODIFIED DATE	:	26 AUG 2019 (CODE REMOVED, BECAUSE OF SHARING FUNCTIONALITY IS CONVERTED INTO FinancialAccountSharingBatch BATCH CLASS. LINE 15)
*  @UPDATED BY 			:	DWS
*/
public class FinancialAccountTriggerHandler {

     /**
    @ PURPOSE     : CREATE CONTACT RELATED PhoneNumber SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND FTER THAT ADDED NEW ACCOUNT RELATED CONTACTS).
    @ PARAMETER   : 1. List [ FinServ__FinancialAccount__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    public static void createAccountFinancialAccountSharing(List<FinServ__FinancialAccount__c> FinancialAccounts) {
        
        if(FinancialAccounts != NULL && !FinancialAccounts.isEmpty()) {
            Set<Id> FinancialAccountIds = new Set<Id>();
            List<AccountShare> AccountShares;
            
            for(FinServ__FinancialAccount__c FinancialAccount : FinancialAccounts) {
                
                if(FinancialAccount.FinServ__Household__c != NULL) {
                    FinancialAccountIds.add(FinancialAccount.FinServ__Household__c);
                }
            }
            
            if(!FinancialAccountIds.isEmpty()) {
                accountShares = [SELECT Id, UserOrGroupId, AccountAccessLevel, RowCause, AccountId
                                 FROM AccountShare
                                 WHERE AccountId IN  :FinancialAccountIds];
            }
            
            if(accountShares != NULL && !accountShares.isEmpty()) {
                List<SObject> sobjectList = new List<SObject>();
                
                for(AccountShare accountShare : accountShares) {
                    
                    if(accountShare.RowCause != 'Owner') {
                        for(FinServ__FinancialAccount__c financialAccount : FinancialAccounts) {
                            if(accountShare.AccountId == financialAccount.FinServ__Household__c) {
                                sobjectList.add(AccountSharingHelper.createShareObjectRecord('FinServ__FinancialAccount__c', accountShare.UserOrGroupId, 
                                                                                             financialAccount.Id, accountShare.AccountAccessLevel, NULL));
                            }
                        }
                    }
                }
                
                try{
                    Database.insert(sobjectList, false);
                } catch(Exception ex) {
                    System.debug('Error :: '+ex.getMessage());
                }
            }
            
        }        
    }
    
     /**
    @ PURPOSE     : CREATE CONTACT RELATED PhoneNumber SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND FTER THAT ADDED NEW ACCOUNT RELATED CONTACTS).
    @ PARAMETER   : 1. List [ FinServ__FinancialAccount__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    public static void deleteAccountFinancialAccountSharing(List<FinServ__FinancialAccount__c> FinancialAccounts) {
        
        if(FinancialAccounts != NULL && !FinancialAccounts.isEmpty()) {
            
            List<AccountShare> accountSharesForAllAccount = new List<AccountShare>();
            List<Id> accounts = new List<Id>();
            List<Id> userOrGroupIds = new List<Id>();
            
            for(FinServ__FinancialAccount__c financialAccount : FinancialAccounts) {
                if( financialAccount.FinServ__Household__c != NULL) {
                    accounts.add(financialAccount.FinServ__Household__c);                                    
                }
            }
            
            accountSharesForAllAccount.addAll(getcurrentPermissions(accounts));
            
            if(!accountSharesForAllAccount.isEmpty()) {
                List<SObject> sobjectList = new List<SObject>();
                for(AccountShare accountShare : accountSharesForAllAccount) {
                    if(accountShare.RowCause != 'Owner') {
                        UserOrGroupIds.add(accountShare.UserOrGroupId);
                    }
                }
            }
            
            List<FinServ__FinancialAccount__Share> financialAccountShares = [SELECT Id
                                                                             FROM FinServ__FinancialAccount__Share 
                                                                             Where ParentId IN :accounts AND UserOrGroupId IN :UserOrGroupIds];                        
            try{     
                Database.delete(financialAccountShares, false);                  
            } catch(Exception ex) {
                System.debug('Error :::: '+ex.getMessage());
            }  
        }        
    }
        
    /**
    @ PURPOSE     : FETCHES AND RETURNS ALL PERMISSION FOR CURRENT ACCOUNT RECORD.
    @ PARAMETER   : 1. String [ ACCOUNT ID ].
    @ RETURN TYPE : List<AccountShare>.
    */
    private static List<AccountShare> getcurrentPermissions(List<Id> accountIds) {
        List<AccountShare> accountShares = new List<AccountShare>();
        accountShares = [ SELECT Id, UserOrGroupId, UserOrGroup.Type, UserOrGroup.Name, AccountAccessLevel, ContactAccessLevel, RowCause
                         FROM AccountShare
                         WHERE AccountId IN :accountIds
                         LIMIT 50000 ];
        return accountShares; 
    }
}