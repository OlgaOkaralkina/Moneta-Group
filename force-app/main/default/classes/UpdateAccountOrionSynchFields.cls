/***********************************************************************************************************************
@purpose : To update account synch field when house hold account is updated this class is called from process builder
@created Date : 7 jun 2019
************************************************************************************************************************/
public with sharing class UpdateAccountOrionSynchFields {
    
    /**
     *@purpose :
     *@param   :
     *@return  :
    **/
    @InvocableMethod
    public static void UpdateAccountOrionSynchFields(List<Contact> houseHoldContacts){
        
        List<Account> accountsToUpdate = new List<Account>();
        Map<String, String> accountFieldToContactFieldMap = getAccountFieldToContactFieldMap();
        Map<Id, Contact> contactMap = new Map<Id, Contact>(houseHoldContacts);
        List<Account> houseHoldAccounts = getHouseHoldAccounts(contactMap);
        
        Profile currentUserProfile = [SELECT Id, Name, PermissionsEnableNotifications FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];

        //check if current user's profile has the permission to send outbound messages.
        if(currentUserProfile.PermissionsEnableNotifications == true){
            
            for(Account accountRec :houseHoldAccounts){
                
                Account accountToUpdate;
                
                if(contactMap.containsKey(accountRec.Head_of_Household__c)){
                    
                    Contact householdContact = contactMap.get(accountRec.Head_of_Household__c);
                    accountToUpdate = new Account();
                    
                    for(String accountField :accountFieldToContactFieldMap.keySet()){
                        
                        String contactField = accountFieldToContactFieldMap.get(accountField);
                        
                        if(accountRec.get(accountField) != householdContact.get(contactField) 
                           && householdContact.get(contactField) != null){ //Last condition is added
                               accountToUpdate.put(accountField, householdContact.get(contactField));
                               if(accountToUpdate.Id == null){
                                   accountToUpdate.Id = accountRec.Id;
                               }
                           }
                    }
                }
                
                if(accountToUpdate.Id != null){
                    accountsToUpdate.add(accountToUpdate);
                }
            }
            
            UPDATE accountsToUpdate;
            
        }else{
            //send the email notification when any user is not having permission to send outbound messages while 
            //updating the account information.
            List<string> toAddress = new List<string>();
            for(OutbondMessage_Notification_Emails__c email: OutbondMessage_Notification_Emails__c.getall().values())
            {
                toAddress.add(email.Name);
            }
            
            if(!toAddress.isEmpty()){
                // get an email template
                EmailTemplate template = [SELECT Id 
                                          FROM EmailTemplate 
                                          WHERE DeveloperName = 'Account_Update_Notification_Mail'
                                          LIMIT 1];
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTemplateId(template.Id);
                mail.setToAddresses(toAddress);
                //mail.setTargetObjectId(UserInfo.getUserId());
                mail.saveAsActivity = false;
                
                //send the email
                List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                
                if (results[0].success) {
                    system.debug('Success');
                } else {
                    system.debug('Fail');
                } 
            }
        }
    }

    /**
     *@purpose :
     *@param   :
     *@return  :
    **/
    private static Map<String, String> getAccountFieldToContactFieldMap(){

        Map<String, String> accountFieldToContactFieldMap;

         accountFieldToContactFieldMap =  new Map<String, String>{
                                                    'OASP_FSC__First_Name__c' => 'FirstName',
                                                    'OASP_FSC__Last_Name__c' => 'LastName',
                                                    'OASP_FSC__Salutation__c' => 'Salutation',
                                                    'OASP_FSC__SSN__c' => 'SSN_TIN__c',
                                                    'OASP_FSC__Email__c' => 'Email',
                                                    'Phone' => 'Phone',
                                                    'OASP_FSC__Birthdate__c' => 'Birthdate',
                                                    'BillingStreet' => 'MailingStreet',
                                                    'BillingCity' => 'MailingCity',
                                                    'BillingState' => 'MailingState',
                                                    'BillingPostalCode' => 'MailingPostalCode',
                                                    'BillingCountry' => 'MailingCountry'
                                            };

        return accountFieldToContactFieldMap;
    }

    private static List<Account> getHouseHoldAccounts (Map<Id, Contact> contactMap) {

        List<Account> houseHoldAccounts;
        
        if(contactMap == null){
            return new List<Account>();
        }

        Map<String, Schema.RecordTypeInfo> recordTypeInfo = Schema.SObjectType.Account.getRecordTypeInfosByName();

        Id houseHoldRecTypeId = recordTypeInfo.get('Household').getRecordTypeId();

        houseHoldAccounts = [SELECT Id, Name, OASP_FSC__First_Name__c, OASP_FSC__Last_Name__c, OASP_FSC__Salutation__c, 
                                    OASP_FSC__SSN__c, OASP_FSC__Email__c, BillingCountry, BillingCity, Head_of_Household__c,
                                    Phone, OASP_FSC__Birthdate__c, BillingStreet, BillingState, BillingPostalCode
                             FROM Account 
                             WHERE Head_of_Household__c IN : contactMap.keySet() AND 
                                   RecordTypeId  =: houseHoldRecTypeId];
    
        return houseHoldAccounts;
    }
}