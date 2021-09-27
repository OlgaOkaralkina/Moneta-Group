/* @PURPOSE				: 	THIS IS BATCH APEX CLASS FOR FinancialAccount WHICH IS USED TO SHARE THE NEW CREATED FINANCIAL ACCOUNTS  WITH THE ROOT ACCOUNTS USER
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	26 AUG 2019
*  @LAST MODIFIED DATE	:	26 AUG 2019 (INITIAL DEVELOPMENT)
*  @UPDATED BY 			:	DWS
*/
public class FinancialAccountSharingBatch implements Database.Batchable<sObject>{
	
    // TO GET OR SET LAST FIRED TIME
    public DateTime LAST_FIRED_TIME {get; set;}
    
    // CONSTRUCTOR
    public FinancialAccountSharingBatch(DateTime lastFiredTime) {
        this.LAST_FIRED_TIME = lastFiredTime;
    }
    
    // SCHEDULER START
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query;
        if(LAST_FIRED_TIME != NULL) {
        	query = 'SELECT Id, FinServ__Household__c FROM FinServ__FinancialAccount__c WHERE CreatedDate >= :LAST_FIRED_TIME ORDER BY CreatedDate DESC';    
        } else {
            query = 'SELECT Id, FinServ__Household__c FROM FinServ__FinancialAccount__c ORDER BY CreatedDate DESC';    
        }
        
        return Database.getQueryLocator(query);
    }
	
    // EXICUTE METHOD IS USED TO SHARE THE FINANCIAL_ACCOUNTS WITH THE ROOT ACCOUNTS USER
    public void execute(Database.BatchableContext bc, List<FinServ__FinancialAccount__c> FinancialAccounts){
        
        Set<Id> FinancialAccountIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        List<AccountShare> AccountShares;
        
        for(FinServ__FinancialAccount__c FinancialAccount : FinancialAccounts) {            
            if(FinancialAccount.FinServ__Household__c != NULL) {
                FinancialAccountIds.add(FinancialAccount.Id);
                accountIds.add(FinancialAccount.FinServ__Household__c);
            }
        } 
        
        // DELETING OLD SHARING AS PER COMMENT https://basecamp.com/2583453/projects/15985327/todos/396798982#comment_723298889 DATE: 24-09-2019
        if(!FinancialAccountIds.isEmpty()) {
            DELETE [SELECT Id
                    FROM FinServ__FinancialAccount__Share
                    WHERE ParentId IN :FinancialAccountIds AND RowCause = 'Manual'];
        }
        
        if(!accountIds.isEmpty()) {
            accountShares = [SELECT Id, UserOrGroupId, AccountAccessLevel, RowCause, AccountId
                             FROM AccountShare
                             WHERE AccountId IN  :accountIds];
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
                System.debug('sobjectList :: '+sobjectList);
                Database.insert(sobjectList, false);
            } catch(Exception ex) {
                System.debug('Error :: '+ex.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        // execute any post-processing operations
    }  
}