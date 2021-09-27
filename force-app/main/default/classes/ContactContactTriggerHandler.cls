/* @PURPOSE				: 	THIS IS HELPER APEX CLASS FOR ContactContactTrigger APEX TRIGGER 
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	01 JAN 2019
*  @LAST MODIFIED DATE	:	01 JAN 2019
*  @UPDATED BY 			:	DWS
*/
public class ContactContactTriggerHandler {

     /**
    @ PURPOSE     : CREATE ACCOUNT RELATED CONTACTS SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND FTER THAT ADDED NEW ACCOUNT RELATED CONTACTS).
    @ PARAMETER   : 1. List [ FinServ__ContactContactRelation__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    public static void createContactContactSharing(List<FinServ__ContactContactRelation__c> contactContactsRelations) {
        
        if(contactContactsRelations != NULL && !contactContactsRelations.isEmpty()) {
            List<AccountShare> accountSharesForSingleAccount;
            List<AccountShare> accountSharesForAllAccount = new List<AccountShare>();
            Map<String, String> contactIdToContactName = new Map<String, String>();
            List<AccountContactRelation> accountContactRelations;
            List<Id> contacts = new List<Id>();
            List<Id> accounts = new List<Id>();
            List<Id> contctIdsForShare = new List<Id>();
            List<Additional_Addresses__c> relatedContactAddresses;
            List<Additional_Email__c> relatedContactEmails;
            List<Notes__c> relatedContactNotes;
            List<Additional_Phone_Number__c> relatedContactPhoneNumbers;
            
            for(FinServ__ContactContactRelation__c contactContactRelation : contactContactsRelations) {
                if(contactContactRelation.FinServ__RelatedContact__c != NULL && contactContactRelation.FinServ__Contact__c != NULL) {
                    contacts.add(contactContactRelation.FinServ__RelatedContact__c);
                    contctIdsForShare.add(contactContactRelation.FinServ__Contact__c);
                    contactIdToContactName.put(contactContactRelation.FinServ__Contact__c, contactContactRelation.FinServ__Contact__r.Name);
                }
            }
            
            List<Contact> contactList = new List<Contact>();
            if(!contacts.isEmpty()) {
                contactList = [SELECT Id, AccountId 
                               FROM Contact 
                               WHERE AccountId != NULL AND Id IN :contacts];
            }
            
            for(Contact contactRec : contactList) {
                if(contactRec.Id != NULL && contactRec.AccountId != NULL) {
                    accounts.add(contactRec.AccountId);                                       
                }
            }
            
            if(!contactIdToContactName.isEmpty()) {
                accountContactRelations = [SELECT  Id, AccountId,Account.Name, ContactId, Contact.Name
                                           FROM AccountContactRelation 
                                           WHERE ContactId IN : contactIdToContactName.keySet() AND  Account.Name IN : contactIdToContactName.values()];
                
                relatedContactAddresses = [SELECT Id, Contact__c  
                                           FROM Additional_Addresses__c
                                           WHERE Contact__c IN :contactIdToContactName.keySet()];
                
                relatedContactEmails = [SELECT Id, Contact__c 
                                        FROM Additional_Email__c
                                        WHERE Contact__c IN :contactIdToContactName.keySet()];
                
                relatedContactNotes = [SELECT Id, Associated_Contact__c 
                                       FROM Notes__c
                                       WHERE Associated_Contact__c IN :contactIdToContactName.keySet()];
                
                relatedContactPhoneNumbers = [SELECT Id, Contact__c 
                                              FROM Additional_Phone_Number__c
                                              WHERE Contact__c IN :contactIdToContactName.keySet()];
                
            }
            
            accountSharesForSingleAccount = getcurrentPermissions(accounts);
            if(accountSharesForSingleAccount != NULL && !accountSharesForSingleAccount.isEmpty()) {
                accountSharesForAllAccount.addAll(accountSharesForSingleAccount);
            } 
            
            if(!accountSharesForAllAccount.isEmpty()) {
                List<SObject> sobjectList = new List<SObject>();
                for(Id contactId : contctIdsForShare) {
                    for(AccountShare accountShare : accountSharesForAllAccount) {
                        if(accountShare.RowCause != 'Owner') {
                            sobjectList.add(createShareObjectRecord('Contact', accountShare.UserOrGroupId, 
                                                                    contactId, accountShare.AccountAccessLevel, NULL));
                        }
                    }
                } 
                
                for(AccountContactRelation accountContactRelationRec : accountContactRelations) {
                    for(AccountShare accountShare : accountSharesForAllAccount) {
                        if(accountShare.RowCause != 'Owner') {
                            sobjectList.add(createShareObjectRecord('Account', accountShare.UserOrGroupId, accountContactRelationRec.Id, 
                                                                    accountShare.AccountAccessLevel, NULL));
                        }
                    }
                }
                /*if(relatedContactAddresses != NULL && !relatedContactAddresses.isEmpty()) {
                    for(Id contactIdRec : contacts) {
                        for(AccountShare accountShare : accountSharesForAllAccount) {
                            if(accountShare.RowCause != 'Owner') {
                                for(Additional_Addresses__c additionalAddress : relatedContactAddresses) {
                                    if(contactIdRec == additionalAddress.Contact__c ) {
                                        sobjectList.add(createShareObjectRecord('Additional_Addresses__c', accountShare.UserOrGroupId, additionalAddress.Id, 
                                                                                accountShare.AccountAccessLevel, NULL));
                                    }
                                }
                            }
                        }                        
                    }                    
                }
                if(relatedContactEmails != NULL && !relatedContactEmails.isEmpty()) {
                    for(Id contactIdRec : contacts) {
                        for(AccountShare accountShare : accountSharesForAllAccount) {
                            if(accountShare.RowCause != 'Owner') {
                                for(Additional_Email__c additionalEmail : relatedContactEmails) {
                                    if(contactIdRec == additionalEmail.Contact__c ) {
                                        sobjectList.add(createShareObjectRecord('Additional_Email__c', accountShare.UserOrGroupId, additionalEmail.Id, 
                                                                                accountShare.AccountAccessLevel, NULL));
                                    }                                
                                }
                            }   
                        }
                    }                    
                }*/
                if(relatedContactNotes != NULL && !relatedContactNotes.isEmpty()) {
                    for(Id contactIdRec : contacts) {
                        for(AccountShare accountShare : accountSharesForAllAccount) {
                            if(accountShare.RowCause != 'Owner') {
                                for(Notes__c note : relatedContactNotes) {
                                    if(contactIdRec == note.Associated_Contact__c ) {
                                        sobjectList.add(createShareObjectRecord('Notes__c', accountShare.UserOrGroupId, note.Id, 
                                                                                accountShare.AccountAccessLevel, NULL));
                                    }                                
                                }
                            }                   
                        }
                    }                    
                }
                /*if(relatedContactPhoneNumbers != NULL && !relatedContactPhoneNumbers.isEmpty()) {
                    for(Id contactIdRec : contacts) {
                        for(AccountShare accountShare : accountSharesForAllAccount) {
                            if(accountShare.RowCause != 'Owner') {
                                for(Additional_Phone_Number__c additionalPhoneNumber : relatedContactPhoneNumbers) {
                                    if(contactIdRec == additionalPhoneNumber.Contact__c ) {
                                        sobjectList.add(createShareObjectRecord('Additional_Phone_Number__c', accountShare.UserOrGroupId, additionalPhoneNumber.Id, 
                                                                                accountShare.AccountAccessLevel, NULL));
                                    }                                
                                }
                            }
                        }                        
                    }                    
                }*/
                
                if(!sobjectList.isEmpty()) {
                    try{
                        Database.insert(sobjectList, false);    
                    } catch(Exception ex) {
                        System.debug('Error :::: '+ex.getMessage());
                    } 
                }
            }
        }
    }
    
    /**
    @ PURPOSE     : DELETE ACCOUNT RELATED CONTACTS SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND AFTER THAT DELETED ACCOUNT RELATED CONTACTS ).
    @ PARAMETER   : 1. List [ FinServ__ContactContactRelation__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    public static void deleteContactContactSharing(List<FinServ__ContactContactRelation__c> contactContactsRelations) {
        if(contactContactsRelations != NULL && !contactContactsRelations.isEmpty()) {
            List<AccountShare> accountSharesForSingleAccount;
            List<AccountContactRelation> accountContactRelations;
            Map<String, String> contactIdToContactName = new Map<String, String>();
            List<AccountShare> accountSharesForAllAccount = new List<AccountShare>();
            List<Id> contacts = new List<Id>();
            List<Id> accounts = new List<Id>();
            List<Id> accountContactRelationIds = new List<Id>();
            List<Id> userOrGroupIds = new List<Id>();
            List<Id> mainAccountIds = new List<Id>();
            List<Id> contctIdsForDelete = new List<Id>();
            
            /*for(FinServ__ContactContactRelation__c contactContactRelation : contactContactsRelations) {
                if( accountContactRelation.ContactId != NULL) {
                    contacts.add(accountContactRelation.ContactId);
                    if(accountContactRelation.AccountId != NULL) {
                        accounts.add(accountContactRelation.AccountId);    
                    }      
                    contactIdToContactName.put(accountContactRelation.ContactId,accountContactRelation.Contact.Name);
                    accountContactRelationIds.add(accountContactRelation.Id);                                       
                }
            }*/
            
            for(FinServ__ContactContactRelation__c contactContactRelation : contactContactsRelations) {
                if(contactContactRelation.FinServ__RelatedContact__c != NULL && contactContactRelation.FinServ__Contact__c != NULL) {
                    contacts.add(contactContactRelation.FinServ__RelatedContact__c);
                    contctIdsForDelete.add(contactContactRelation.FinServ__Contact__c);
                    contactIdToContactName.put(contactContactRelation.FinServ__Contact__c, contactContactRelation.FinServ__Contact__r.Name);
                }
            }
            
            List<Contact> contactList = new List<Contact>();
            if(!contacts.isEmpty()) {
                contactList = [SELECT Id, AccountId 
                               FROM Contact 
                               WHERE AccountId != NULL AND Id IN :contacts
                               LIMIT 50000];
            }
            
            for(Contact contactRec : contactList) {
                if(contactRec.Id != NULL && contactRec.AccountId != NULL) {
                    accounts.add(contactRec.AccountId);                                       
                }
            }
            
            if(!contactIdToContactName.isEmpty()) {
                accountContactRelations = [SELECT  Id, AccountId,Account.Name, ContactId, Contact.Name
                                           FROM AccountContactRelation 
                                           WHERE ContactId IN : contactIdToContactName.keySet() AND  Account.Name IN : contactIdToContactName.values()];
            }
            
            accountSharesForSingleAccount = getcurrentPermissions(accounts);
            if(accountSharesForSingleAccount != NULL && !accountSharesForSingleAccount.isEmpty()) {
                accountSharesForAllAccount.addAll(accountSharesForSingleAccount);
            } 
            
            if(!accountSharesForAllAccount.isEmpty()) {
                List<SObject> sobjectList = new List<SObject>();
                for(AccountShare accountShare : accountSharesForAllAccount) {
                    if(accountShare.RowCause != 'Owner') {
                        UserOrGroupIds.add(accountShare.UserOrGroupId);
                    }
                }
            }
            
            if(!contactIdToContactName.isEmpty()) {
                for(AccountContactRelation  accountContactRelation : [SELECT  Id, AccountId,Account.Name, ContactId, Contact.Name
                                                                      FROM AccountContactRelation 
                                                                      WHERE ContactId IN : contactIdToContactName.keySet() AND  Account.Name IN : contactIdToContactName.values()]) {
                                                                          mainAccountIds.add(accountContactRelation.AccountId);
                                                                      }
            }
            
            List<ContactShare> ContactShares = [SELECT Id
                                                FROM ContactShare 
                                                Where ContactId IN :contctIdsForDelete AND UserOrGroupId IN :UserOrGroupIds
                                                LIMIT 50000];
            
            try{ 
                Database.delete(mainAccountIds, false);    
                Database.delete(ContactShares, false);                  
            } catch(Exception ex) {
                System.debug('Error :::: '+ex.getMessage());
            }
        }
    }
    
    /**
    @ PURPOSE     : METHOD FOR CREATING SHARE OBJECT RECORD  
    @ PARAMETER   : 1. String [ USER OR GROUP ID's ],
                    2. Id [ USER OR GROUP ID ],
                    3. String [ PARENT RECORD ID ],
                    4. String [ RECORD ACCESS LAVEL ],
                    5. String [ RECORD ID ]
    @ RETURN TYPE : SObject [ SOBJECT RECORD ].
    */
    private static SObject createShareObjectRecord(String strObjectApiName, Id userOrGroupId, String strRecordId, String strAccessLevel, String strShareRecordId) {
        SObject objRecord;
        if(String.isNotBlank(strObjectApiName)) {
            if(strObjectApiName.contains('__c')) {
                objRecord = initializeSobjRecord(strObjectApiName.substring(0, strObjectApiName.length() - 3) + '__Share');
            } else {
                objRecord = initializeSobjRecord(strObjectApiName + 'Share');
            }
            
            if(String.isNotBlank(strShareRecordId)) {
                objRecord.put('Id', ID.valueOf(strShareRecordId));
            } else {
                objRecord.put('RowCause', 'Manual');
            }
            
            if(strObjectApiName.contains('__c')) {
                objRecord.put('ParentId', strRecordId);
                objRecord.put('AccessLevel', strAccessLevel);
            } else {
                if(strObjectApiName.equalsIgnoreCase('account')) {
                    objRecord.put('AccountAccessLevel', strAccessLevel);
                    objRecord.put('ContactAccessLevel', strAccessLevel);
                    objRecord.put('OpportunityAccessLevel', strAccessLevel);
                } else {
                    objRecord.put(strObjectApiName + 'AccessLevel', strAccessLevel);
                }
                if(String.isNotBlank(strRecordId)) {
                    objRecord.put(strObjectApiName + 'Id', strRecordId);
                }
            }
            if(userOrGroupId != NULL) {
                objRecord.put('UserOrGroupId', userOrGroupId);
            }
        }
        return objRecord;
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
    
    /**
    @ PURPOSE     : METHOD FOR GETTING OBJECT TYPE 
    @ PARAMETER   : 1. String [ OBJECT API NAME ]
    @ RETURN TYPE : SObject [ OBJECT RECORD ].
    */
    private static SObject initializeSobjRecord(String strObjectApiName) {
        SObject sobjectRecord;
        if(String.isNotBlank(strObjectApiName)) {
            Map<String, SobjectType> objectNameToType = Schema.getGlobalDescribe();
            if(objectNameToType.containsKey(strObjectApiName)) {
                try {
                    sobjectRecord = objectNameToType.get(strObjectApiName).newSobject();
                }
                catch(Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
        }
        return sobjectRecord;
    }
}