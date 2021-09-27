/*
* @purpose : This is trigger helper class for accountcontactrelationship
* @createdDate : 19 Nov 2018
* @createdBy	: Navin (Dreamwares)
*/ 
public class AccConRelationshipDeleteHelper {
    public static void updateAccount(List<AccountContactRelation> accountContactList) {
        Set<Id> accountIdsSecondary = new Set<Id>();
        Set<Id> accountIdsPrimary = new Set<Id>();
        for(AccountContactRelation accountContactRecord : accountContactList) {
            // PANKAJ - CHECKED NULL.
            if(String.isNotBlank(accountContactRecord.Roles)) {
                if((accountContactRecord.Roles).contains('Secondary')) {
                    accountIdsSecondary.add(accountContactRecord.AccountId);
                } else if((accountContactRecord.Roles).contains('Primary')) {
                    accountIdsPrimary.add(accountContactRecord.AccountId);
                }
            }
        }
        List<Account> accountRecordsList = new List<Account>();
        for(Account accountRecord : [SELECT Id, Name, Secondary_Contact__c, Existing_Secondary__c
                                     FROM Account
                                     WHERE Id IN: accountIdsSecondary]){
                                         accountRecord.Secondary_Contact__c = null;
                                         accountRecord.Existing_Secondary__c = false;
                                         accountRecordsList.add(accountRecord);
                                     }
        if(!accountRecordsList.isEmpty()) {
            UPDATE accountRecordsList;    
        }
        List<Account> accountRecordsPrimaryList = new List<Account>();
        for(Account accountRecord : [SELECT Id, Name,Head_of_Household__c , Existing_Primary__c, Head_of_Household_Account__c
                                     FROM Account
                                     WHERE Id IN: accountIdsPrimary]){
                                         /* replaced SkienceFinSln__Head_of_Household_Account__c with Head_of_Household__c
                                         And SkienceFinSln__Head_of_Household__c with Head_of_Household__c
                                         //accountRecord.SkienceFinSln__Head_of_Household__c = null;
                                         //accountRecord.SkienceFinSln__Head_of_Household_Account__c = NULL;*/
                                         //
                                         accountRecord.Head_of_Household__c = null;
                                         accountRecord.Head_of_Household_Account__c = NULL;
                                         accountRecord.Existing_Primary__c = false;
                                         // PANKAJ - REVISION TO REMOVE VALUE FROM HEAD OF HH ACCOUNT.                                         
                                         accountRecordsPrimaryList.add(accountRecord);
                                     }
        if(!accountRecordsPrimaryList.isEmpty()) {
            UPDATE accountRecordsPrimaryList;    
        }
        
    }
}