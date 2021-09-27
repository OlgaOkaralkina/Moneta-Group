/**
*@purpose       : To copy the Orian Sync Fields of Household Account From related Houshold Contact.
*@Created Date  : 07 June 2019
**/
public class AccountTriggerHandler {
    
    /**
        *@purpose : To Handle Insert of New Household Account.
        *@param   : List<Account> accountList
        *@return  :
    **/
    public static void onBeforeInsert(List<Account> accountList){
        updateOrionSynchFields(accountList);
    }
    
    /**
        *@purpose : To Handle Update of Houshold Account
        *@param   : Map<Id, Account> oldMap, List<Account> newAccounts
        *@return  :
    **/
    public static void onBeforeUpdate(Map<Id, Account> oldMap, List<Account> newAccounts){
        updateOrionSynchFields(getHouseHoldUpdatedAccounts(oldMap, newAccounts));
    }
    
    /**
        *@purpose : Method to update the houshold account fields with related household contact fields. 
        *@param   : List<Account> accountList
        *@return  :
    **/
    public static void updateOrionSynchFields (List<Account> accountList) {
        
        if(accountList != null && !accountList.isEmpty()){
            
            Map<String, String> accountFieldToContactFieldMap = getAccountFieldToContactFieldMap();
            Map<Id, Contact> contactMap = getHouseHoldContactMap(accountList);
            Profile currentUserProfile = [SELECT Id, Name, PermissionsEnableNotifications FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            
            //check if current user's profile has the permission to send outbound messages.
            if(currentUserProfile.PermissionsEnableNotifications == true){
                for(Account accountRec : accountList){
                    
                    if(accountRec.Head_of_Household__c != null){
                        if(contactMap.containsKey(accountRec.Head_of_Household__c)){
                            
                            Contact houseHoldContact = contactMap.get(accountRec.Head_of_Household__c);
                            
                            for(String accountField : accountFieldToContactFieldMap.keyset()){
                                
                                String contactField = accountFieldToContactFieldMap.get(accountField);
                                
                                if(accountRec.get(accountField) != houseHoldContact.get(contactField) 
                                   && houseHoldContact.get(contactField) != null ){
                                       accountRec.put(accountField, houseHoldContact.get(contactField));
                                   }
                            }
                        }
                    }else{
                        /*Commented By Neha N */
                        /* for(String accountField : accountFieldToContactFieldMap.keyset()){
                            accountRec.put(accountField, null);
                        }*/
                    }
                } 
                
            }else{
                //send the email notification when any user is not having permission to send outbound messages while updating the account information.
                List<string> toAddress = new List<string>();
                for(OutbondMessage_Notification_Emails__c mailSetting : OutbondMessage_Notification_Emails__c.getall().values())
                {
                    toAddress.add(mailSetting.Name);
                }
                
                if(!toAddress.isEmpty()){
                    // get an email template
                    EmailTemplate template = [select Id FROM EmailTemplate WHERE DeveloperName = 'Account_Update_Notification_Mail' limit 1];
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(template.Id);
                    mail.setToAddresses(toAddress);
                    //mail.setTargetObjectId(UserInfo.getUserId());
                    mail.saveAsActivity = false;
                    
                    //send the email
                    List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    
                    // we can then check for success
                    if (results[0].success) {
                        system.debug('Success');
                    } else {
                        system.debug('Fail');
                    } 
                }
            }
        }
    } 
    
    /**
        *@purpose : Get the list of Account which values of Orian Sync fields are updated or household contact is changed.
        *@param   : Map<Id, Account> oldAccountMap, List<Account> newAccounts
        *@return  : List<Account> FilteredList
    **/
    private static List<Account> getHouseHoldUpdatedAccounts (Map<Id, Account> oldAccountMap, List<Account> newAccounts){
        
        List<Account> FilteredList = new List<Account>();
        List<Account> accountListwithBlankContact = new List<Account>();
        Map<String, String> accountFieldToContactFieldMap = getAccountFieldToContactFieldMap();
        
        for(Account accountRec : newAccounts){
            
            if(accountRec.Head_of_Household__c != oldAccountMap.get(accountRec.Id).Head_of_Household__c){
                FilteredList.add(accountRec);
                continue;
            }
            
            for(string accountField : accountFieldToContactFieldMap.keySet()){
                
                if(accountRec.get(accountField) != oldAccountMap.get(accountRec.Id).get(accountField) 
                   && oldAccountMap.get(accountRec.Id).get(accountField) != null ){ //added last condition 
                       
                       FilteredList.add(accountRec);
                       break;
                       
                   }
                
            }
        }
        
        return FilteredList;
    }
    
    /**
        *@purpose : Method to create the map of contact id to contact
        *@param   : Map<Id, Account> oldAccountMap, List<Account> newAccounts
        *@return  : List<Account> FilteredList
    **/   
    private static Map<Id, Contact> getHouseHoldContactMap (List<Account> accountList){
        
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        
        for (Account accountRec : accountList) {
            
            if(accountRec.RecordTypeId == householdRecordTypeId && account.Head_of_Household__c != null){
                contactIdSet.add(accountRec.Head_of_Household__c);
            }
        }
        
        contactMap = new Map<Id, Contact>([SELECT Id, Name, FirstName, LastName, Salutation, Phone, Birthdate, 
                                           MailingStreet, MailingCountry, MailingState, MailingPostalCode,
                                           MailingCity, FinServ__TaxId__c, Email
                                           FROM Contact 
                                           WHERE Id IN : contactIdSet]);
        return contactMap;
    }
    
    /**
        *@purpose : Method to create the map Account fields to Contact fields which are updated by Orian on Account
        *@param   : 
        *@return  : Map<String, String> AccountFieldToContactFieldMap
    **/
    private static Map<String, String> getAccountFieldToContactFieldMap () {
        
        return new Map<String, String>{
            'OASP_FSC__First_Name__c' => 'FirstName',
                'OASP_FSC__Last_Name__c' => 'LastName',
                'OASP_FSC__Salutation__c' => 'Salutation',
                'OASP_FSC__SSN__c' => 'FinServ__TaxId__c',
                'OASP_FSC__Email__c' => 'Email',
                'Phone' => 'Phone',
                'OASP_FSC__Birthdate__c' => 'Birthdate',
                'BillingStreet' => 'MailingStreet',
                'BillingCity' => 'MailingCity',
                'BillingState' => 'MailingState',
                'BillingPostalCode' => 'MailingPostalCode',
                'BillingCountry' => 'MailingCountry'
                };
                    }
}