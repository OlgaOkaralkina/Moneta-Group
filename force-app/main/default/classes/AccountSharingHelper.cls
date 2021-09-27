/* @PURPOSE				: 	THIS IS HANDLER APEX CLASS FOR AccountSharingController APEX CLASS 
*  @CREATED BY			:	DWS
*  @CREATED DATE		:	08 DEC 2018
*  @LAST MODIFIED DATE	:	25 DES 2018 
*  @MODIFIED BY 		:	DWS
*/ 
public class AccountSharingHelper {
    
    // USED TO MAINTAIN CONTACTS ACCOUNT RECORD ID
    public static Set<Id> mainAccountIds = new Set<Id>();
    public static Set<Id> contactRelatedNoteIds = new Set<Id>();
    public static Set<Id> accountRelatedFinancialAccountIds = new Set<Id>();
    public static Set<Id> accountRelatedNotesIds = new Set<Id>();
    
     /**
      @ PURPOSE     : CHECK CURRENT LOGGED IN USER IS System Administrator OR NOT.
      @ RETURN TYPE : BOOLEAN [ IF CURRENT USER IS SYSTEM ADMINISTRATOR RETURN TRUE ELSE FALSE].
   */
    public static Boolean checkCurrentUserProfile() {
        Profile userProfile = [SELECT Id, Name 
                               FROM Profile 
                               WHERE Id = :userinfo.getProfileId() AND Name = 'System Administrator' 
                               LIMIT 1];        
        if(userProfile != NULL) {
            return TRUE;
        } else {
            return FALSE;
        }        
    }
    
    /**
      @ PURPOSE     : FETCHES AND RETURNS ALL PERMISSION FOR CURRENT ACCOUNT RECORD.
      @ PARAMETER   : 1. String [ ACCOUNT ID ].
      @ RETURN TYPE : List<AccountShare>.
   */
    public static List<AccountShare> getcurrentPermissions(String accountId) {
        List<AccountShare> accountShares = new List<AccountShare>();
        accountShares = [ SELECT Id, UserOrGroupId, UserOrGroup.Type, UserOrGroup.Name, AccountAccessLevel, ContactAccessLevel, RowCause
                         FROM AccountShare
                         WHERE AccountId = :accountId AND RowCause != 'ImplicitChild'
                         ORDER BY UserOrGroup.Name
                         LIMIT 50000 ];
        return accountShares; 
    }
    
    /**
      @ PURPOSE     : FETCHES AND RETURNS ALL USERS OR PUBLIC GROUP
      @ PARAMETER   : 1. String [ OBJECT API NAME ],
					  2. List<sObject> [ TO SKIP CURRENT USER PERMISSION ID's ]
      @ RETURN TYPE : List<SObject> [ DEPEND's ON OBJECT API NAME ].
   */
    public static List<SObject> getRecords(String strObjectApiName, List<sObject> toSkipCurrentPermissionUsers) {
        List<SObject> records = new List<SObject>();       
        try {
            Set<Id> userPermissions = new Set<Id>();
            if(toSkipCurrentPermissionUsers != NULL && !toSkipCurrentPermissionUsers.isEmpty()) {
                for(sObject objectRecord : toSkipCurrentPermissionUsers) {                 
                    userPermissions.add((Id)objectRecord.get('UserOrGroupId'));
                } 
            }
            
            if(String.isNotBlank(strObjectApiName)) {
                String strQuery = 'SELECT Id, Name FROM ' + strObjectApiName ;
                String strOrderByClause = 'ORDER BY Name ASC';
                String strLimitClause = 'LIMIT 50000';

                if(strObjectApiName.equalsIgnoreCase('user')) {
                    String profileName = 'chatter external user';
                    strQuery = strQuery + ' WHERE IsActive = TRUE AND ID != \'' + UserInfo.getUserId() + '\' AND Profile.Name != :profileName AND ID NOT IN :userPermissions AND Profile.Name != null';
                } else {
                    strQuery = strQuery + ' WHERE ID != \'' + UserInfo.getUserId() + '\' AND ID NOT IN: userPermissions ';
                }
                strQuery = strQuery + ' ' + strOrderByClause + ' ' + strLimitClause;
                records = Database.query(strQuery);
            }
        } catch(Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return records;
    }
    
    /**
      @ PURPOSE     : CREATING SHARING RECORD FOR CURRENT ACCOUNT, RELATED CONTACTS, RELATED ACCOUNTS, AND RELATED ACCOUNTS CONTACTS
      @ PARAMETER   : 1. String [ ACCOUNT ID ],
					  2. String [ USER TYPE (USER, PUBLIC GROUP. OR USER ROLE) ],
					  3. List<String> [ CREATE SHARING RECORDS FOR THIS USER ],
					  4. String [ RECORD ACCESS LAVEL ]
      @ RETURN TYPE : String [ SUCCESS OR ERROR MESSAGE ].
   */
    public static String createSharingRecord(String accountId, String userType, List<String> userIds, String accessType) {        
        String strMessage;
        
        try {
            Map<String, Set<Id>> objectApiNameToIds = getRelatedAccountsAndContacts(accountId);
            List<SObject> records = new List<SObject>();            
            
            if(String.isNotBlank(userType) && userType.equalsIgnoreCase('userrole')) {
               /* for(Group groupRecord : getGroups(userIds)) {
                    for(String sObjectName : objectApiNameToIds.keySet()) {
                        for(Id sObjectId : objectApiNameToIds.get(sObjectName)) {
                            records.add(createShareObjectRecord(sObjectName, groupRecord.Id, sObjectId, accessType, NULL));
                        }
                    }
                    for(Id accountRecId : mainAccountIds) {
                        records.add(createShareObjectRecord('Account', groupRecord.Id, accountRecId, accessType, NULL));
                    }
                }*/
            } else {
                for(String userId : userIds) {
                    for(String sObjectName : objectApiNameToIds.keySet()) {
                        for(Id sObjectId : objectApiNameToIds.get(sObjectName)) {
                            records.add(createShareObjectRecord(sObjectName, userId, sObjectId, accessType, NULL));
                        }
                    }
                }
                for(String userId : userIds) {
                    for(Id accountRecId : mainAccountIds) {
                        records.add(createShareObjectRecord('Account', userId, accountRecId, accessType, NULL));
                    }
                }
                for(String userId : userIds) {                   
                    for(Id financialAccountId : accountRelatedFinancialAccountIds) {
                        records.add(createShareObjectRecord('FinServ__FinancialAccount__c', userId, financialAccountId, accessType, NULL));
                    }
                }
                for(String userId : userIds) {                   
                    for(Id accountNoteId : accountRelatedNotesIds) {
                        records.add(createShareObjectRecord('Notes__c', userId, accountNoteId, accessType, NULL));
                    }
                }
                for(String userId : userIds) {                   
                    for(Id contactNoteId : contactRelatedNoteIds) {
                        records.add(createShareObjectRecord('Notes__c', userId, contactNoteId, accessType, NULL));
                    }
                }
            }
            
            if(!records.isEmpty()) {             
                Database.SaveResult[] srList = Database.insert(records, false);
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        strMessage =  'SUCCESS';
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {                
                            strMessage =  err.getMessage();
                        }
                    }
                }
            } else {
                strMessage =  'No record to shared';
            }
        } catch(Exception ex) {
            strMessage = getPageErrorMessage(ex);
            throw new AuraHandledException(ex.getMessage());
        }        
        return strMessage;
    }
    
    /**
      @ PURPOSE     : UPDATING SHARING RECORD FOR CURRENT ACCOUNT, RELATED CONTACTS, RELATED ACCOUNTS, AND RELATED ACCOUNTS CONTACTS
      @ PARAMETER   : 1. String [ ACCOUNT ID ],
					  2. String [ SHARE RECORD ID ],
					  3. String [ RECORD ACCESS LAVEL ],
					  4. String [ USER ID ]
      @ RETURN TYPE : String [ SUCCESS OR ERROR MESSAGE ].
   */
    public static String updateShareRecord(String strAccountId,  String strRecordId, String strAccessLevel, String strUserId) {
        String strMessage;
        try {
            Set<Id> sobjects = new Set<Id>();
            Map<String, Set<Id>> objectApiNameToIds = getRelatedAccountsAndContacts(strAccountId);            
            for(String sObjectName : objectApiNameToIds.keySet()) {
                for(Id sObjectId : objectApiNameToIds.get(sObjectName)) {
                    sobjects.add(sObjectId);
                }
            }
            
            sobjects.addAll(mainAccountIds);
            sobjects.addAll(contactRelatedNoteIds);
            sobjects.addAll(accountRelatedFinancialAccountIds);
            sobjects.addAll(accountRelatedNotesIds);
            
            List<AccountShare> accountShares = [SELECT Id, AccountId
                                                FROM AccountShare 
                                                WHERE AccountId IN :sobjects AND UserOrGroupId = :strUserId];
            
            List<ContactShare> ContactShares = [SELECT Id
                                                FROM ContactShare 
                                                Where ContactId IN :sobjects AND UserOrGroupId = :strUserId AND RowCause != 'ImplicitChild'];
            
            List<FinServ__FinancialAccount__Share> finServFinancialAccountShares = [SELECT Id
                                                                                    FROM FinServ__FinancialAccount__Share 
                                                                                    WHERE ParentId IN :sobjects AND UserOrGroupId = :strUserId];
            
            List<Notes__Share> finServNoteShares = [SELECT Id
                                                    FROM Notes__Share 
                                                    WHERE ParentId IN :sobjects AND UserOrGroupId = :strUserId];
           
            /*List<Notes__Share> notesShares = [SELECT Id
                                              FROM Notes__Share 
                                              Where UserOrGroupId = :strUserId AND RowCause != 'ImplicitChild'];*/
            
            List<SObject> sobjectList = new List<SObject>();
            for(AccountShare accountShare : accountShares) {
                sobjectList.add(createShareObjectRecord('Account', NULL,  NULL,  strAccessLevel, accountShare.Id));
            }
            
            for(ContactShare contactShare : ContactShares) {
                sobjectList.add(createShareObjectRecord('Contact', NULL,  NULL,  strAccessLevel, contactShare.Id));
            }
            
            for(FinServ__FinancialAccount__Share finServFinancialAccountShare : finServFinancialAccountShares) {
                sobjectList.add(createShareObjectRecord('FinServ__FinancialAccount__c', NULL,  NULL,  strAccessLevel, finServFinancialAccountShare.Id));
            }   
            
            for(Notes__Share finServNoteShare : finServNoteShares) {
                sobjectList.add(createShareObjectRecord('Notes__c', NULL,  NULL,  strAccessLevel, finServNoteShare.Id));
            }
                        
           /* for(Notes__Share notesShare : notesShares) {
                sobjectList.add(createShareObjectRecord('Notes__c', NULL,  NULL,  strAccessLevel, notesShare.Id));
            }*/

            if(!sobjectList.isEmpty()) {
                Database.update(sobjectList, false);
                strMessage =  'SUCCESS';
            }
        } catch(Exception ex) {
            System.debug('Error ::: '+ex.getMessage());
            strMessage = getPageErrorMessage(ex);
        }    
        
        return strMessage;
    }
    
    /**
      @ PURPOSE     : DELETING SHARING RECORD FOR CURRENT ACCOUNT, RELATED CONTACTS, RELATED ACCOUNTS, AND RELATED ACCOUNTS CONTACTS
      @ PARAMETER   : 1. String [ ACCOUNT ID ],
					  2. String [ SHARE RECORD ID ],
					  4. String [ USER ID ]
      @ RETURN TYPE : String [ SUCCESS OR ERROR MESSAGE ].
   */
    public static String deleteShareRecord(String accountId, String strRecordId, String strUserdId) {
        String strMessage;
        try {       
            Map<String, Set<Id>> objectApiNameToIds = getRelatedAccountsAndContacts(accountId);
            Set<Id> sobjects = new Set<Id>();
            List<sobject> todeleteSobjects = new List<sobject>();
            sobjects.add(accountId);
            
            for(String sObjectName : objectApiNameToIds.keySet()) {
                for(Id sObjectId : objectApiNameToIds.get(sObjectName)) {
                    sobjects.add(sObjectId);
                }
            }
            sobjects.addAll(mainAccountIds);
            
            todeleteSobjects.addAll([SELECT Id 
                                     FROM AccountShare 
                                     WHERE AccountId IN :sobjects AND UserOrGroupId = :strUserdId]);
            
            todeleteSobjects.addAll([SELECT Id
                                     FROM ContactShare 
                                     WHERE ContactId IN :sobjects AND UserOrGroupId = :strUserdId]);
            
            todeleteSobjects.addAll([SELECT Id
                                     FROM FinServ__FinancialAccount__Share 
                                     WHERE Parent.FinServ__Household__c IN :sobjects AND UserOrGroupId = :strUserdId]);
            
            todeleteSobjects.addAll([SELECT Id
                                     FROM Notes__Share 
                                     WHERE (Parent.Associated_Entity_Household__c IN :sobjects OR 
                                           Parent.Associated_Contact__c IN :sobjects) AND 
                                           UserOrGroupId = :strUserdId]);
            
            Database.delete(todeleteSobjects, false);
            strMessage = 'SUCCESS';
        } catch(Exception ex) {
            strMessage = ex.getMessage();
        }
        return strMessage;
    }
    
    /**
      @ PURPOSE     : METHOD FOR GETTING OBJECT TYPE 
      @ PARAMETER   : 1. String [ OBJECT API NAME ]
      @ RETURN TYPE : SObject [ OBJECT RECORD ].
   */
    public static SObject initializeSobjRecord(String strObjectApiName) {
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
    
    /**
      @ PURPOSE     : METHOD FOR GETTING CONTACTS RELATED CONTACTS 
      @ PARAMETER   : 1. Set<Id> [ CONTACTS ID's ]
      @ RETURN TYPE : List<FinServ__ContactContactRelation__c> [ CONTACTS RELATED CONTACT LIST ].
   */
    public static List<FinServ__ContactContactRelation__c> getContactToContactRelationByContacts(Set<Id> setOfContactIds) {
        return [ SELECT Id, FinServ__Contact__c, FinServ__Contact__r.Name, FinServ__Contact__r.FirstName, FinServ__Contact__r.LastName, 
                	FinServ__RelatedContact__c, FinServ__RelatedContact__r.Name, FinServ__RelatedContact__r.FirstName, FinServ__RelatedContact__r.LastName, 
                FinServ__Role__c, FinServ__Role__r.Name 
                FROM FinServ__ContactContactRelation__c 
                WHERE FinServ__Contact__c IN :setOfContactIds ];
    } 
    
    /**
      @ PURPOSE     : METHOD FOR GETTING CONTACTS RELATED CONTACTS RELATED EMAILS 
      @ PARAMETER   : 1. Set<Id> [ ACCOUNT ID's ]
      @ RETURN TYPE : List<Additional_Email__c> [ CONTACTS RELATED CONTACT LIST ].
   */
    public static List<FinServ__FinancialAccount__c> getAccountRelatedFinancialAccount(Set<Id> mainAccountIds) {        
        return [ SELECT Id FROM FinServ__FinancialAccount__c WHERE FinServ__Household__c  IN :mainAccountIds ];
    } 
    
    /**
      @ PURPOSE     : METHOD FOR GETTING CONTACTS RELATED CONTACTS RELATED EMAILS 
      @ PARAMETER   : 1. Set<Id> [ ACCOUNT ID's ]
      @ RETURN TYPE : List<Additional_Email__c> [ CONTACTS RELATED CONTACT LIST ].
   */
    public static List<FinServ__FinancialAccount__c> getAccountRelatedFinancialAccountForInstitution (Set<Id> mainAccountIds) {        
        return [ SELECT Id FROM FinServ__FinancialAccount__c WHERE FinServ__PrimaryOwner__r.Id  IN :mainAccountIds ];
    } 
    
    /**
      @ PURPOSE     : METHOD FOR GETTING ACCOUNT'S RELATED NOTES
      @ PARAMETER   : 1. Set<Id> [ ACCOUNT ID's ]
      @ RETURN TYPE : List<Additional_Email__c> [ CONTACTS RELATED CONTACT LIST ].
   */
    public static List<Notes__c> getAccountRelatedNote(Set<Id> mainAccountIds) {
        return [ SELECT Id FROM Notes__c WHERE Associated_Entity_Household__c IN :mainAccountIds ];
    }
    
    /**
      @ PURPOSE     : METHOD FOR GETTING CONTACTS RELATED CONTACTS RELATED NOTES 
      @ PARAMETER   : 1. Set<Id> [ CONTACTS ID's ]
      @ RETURN TYPE : List<Additional_Email__c> [ CONTACTS RELATED CONTACT LIST ].
   */
    public static List<Notes__c> getContactRelatedNotesByContacts(Set<Id> setOfContactIds) {
        return [ SELECT Id FROM Notes__c WHERE Associated_Contact__c IN :setOfContactIds ];
    }
    
    /**
      @ PURPOSE     : METHOD FOR GETTING ACCOUNT RELATED CONTACTS 
      @ PARAMETER   : 1. Set<Id> [ ACCOUNT ID's ]
      @ RETURN TYPE : List<AccountContactRelation> [ ACCOUNT RELATED CONTACT LIST ].
   */
    public static List<AccountContactRelation> getAccountContactRelationByAccounts(Set<Id> setOfAccountId) {
        return [ SELECT Id, AccountId, Account.Name, ContactId, Contact.Name 
                FROM AccountContactRelation 
                WHERE AccountId IN :setOfAccountId ];
    }
    
     /**
      @ PURPOSE     : METHOD FOR GETTING CONTACTS ACCOUNT RECORD
      @ PARAMETER   : 1. Map<String, String> [ strCONTACTID, strCONTACTNAME ]
      @ RETURN TYPE : List<AccountContactRelation> [ CONTACTS ACCOUNT RECORD LIST ].
   */
    public static List<AccountContactRelation> getContactAccount(Map<String, String> contactIdToContactName) {
        return  [SELECT  Id, AccountId,Account.Name, ContactId, Contact.Name
                 FROM AccountContactRelation 
                 WHERE ContactId IN : contactIdToContactName.keySet() AND  Account.Name IN : contactIdToContactName.values()];     
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
    public static SObject createShareObjectRecord(String strObjectApiName, Id userOrGroupId, String strRecordId, String strAccessLevel, String strShareRecordId) {
        SObject objRecord;
        if(String.isNotBlank(strObjectApiName)) {
            if(strObjectApiName.contains('__c')) {
                //objRecord = (Account)strObjectApiName.substring(0, strObjectApiName.length() - 3) + '__Share';
                objRecord = initializeSobjRecord(strObjectApiName.substring(0, strObjectApiName.length() - 3) + '__Share');
            } else {
                objRecord = initializeSobjRecord(strObjectApiName + 'Share');
            }
            
            if(String.isNotBlank(strShareRecordId)) {
                objRecord.put('Id', ID.valueOf(strShareRecordId));
            } else {
                objRecord.put('RowCause', 'Manual');
            }
            
            if(strObjectApiName.contains('__c') && String.isNotBlank(strShareRecordId)) {
                //objRecord.put('ParentId', strRecordId);
                objRecord.put('AccessLevel', strAccessLevel);
            } else if(strObjectApiName.contains('__c') ) {
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
      @ PURPOSE     : METHOD FOR GETTING CURRENT ACCOUNT AND ITS RELATED OTHER RECORDS 
      @ PARAMETER   : 1. String [ ACCOUNT ID ]
      @ RETURN TYPE : Map<String, Set<Id>> [ KEY = OBJECT API NAME, VALUE = ID's ].
   */
    public static Map<String, Set<Id>> getRelatedAccountsAndContacts(String accountId) {
        Map<String, Set<Id>> objectApiNameToIds = new map<String, Set<Id>> { 'Account' => new Set<Id>(), 
                                                                             'Contact' => new Set<Id>(),
                                                                             'Notes__c' => new Set<Id>(),
                                                                             'FinServ__FinancialAccount__c' => new Set<Id>() };
        Map<String, String> contactIdToContactName = new Map<String, String>();
        
        // FOR ACCOUNT RELATED CONTACTS
        for(AccountContactRelation accountContactRelation : getAccountContactRelationByAccounts(new Set<Id> {accountId})) {
            objectApiNameToIds.get('Contact').add(accountContactRelation.ContactId);
            contactIdToContactName.put(accountContactRelation.ContactId, accountContactRelation.Contact.Name);
            mainAccountIds.add(accountContactRelation.AccountId);
        }
        
        // FOR CONTACT RELATED CONTACTS
        for(FinServ__ContactContactRelation__c contactContactRelation : getContactToContactRelationByContacts(objectApiNameToIds.get('Contact'))) {
            objectApiNameToIds.get('Contact').add(contactContactRelation.FinServ__RelatedContact__c);
            String accountName;
            if(!String.isEmpty(contactContactRelation.FinServ__RelatedContact__r.FirstName) && !String.isEmpty(contactContactRelation.FinServ__RelatedContact__r.LastName)) {
                accountName = contactContactRelation.FinServ__RelatedContact__r.FirstName+' '+contactContactRelation.FinServ__RelatedContact__r.LastName;
            } else if(String.isEmpty(contactContactRelation.FinServ__RelatedContact__r.FirstName) && !String.isEmpty(contactContactRelation.FinServ__RelatedContact__r.LastName)) {
                accountName = contactContactRelation.FinServ__RelatedContact__r.LastName;
            } else {
                accountName = contactContactRelation.FinServ__RelatedContact__r.Name;
            }
            contactIdToContactName.put(contactContactRelation.FinServ__RelatedContact__c, accountName);
        }
        
        // FOR CONTACT RELATED CONTACTS RELATED NOTES
        for(Notes__c contactRelatedNoteId : getContactRelatedNotesByContacts(objectApiNameToIds.get('Contact'))) {
            contactRelatedNoteIds.add(contactRelatedNoteId.Id);
        }
        
        // FOR GETTING CONTACTS ACCOUNT RECORD
        for(AccountContactRelation accountContactRelation : getContactAccount(contactIdToContactName)) {
            mainAccountIds.add(accountContactRelation.AccountId);
        }
                
        // FOR ACCOUNT RELATED FinancialAccount (HH TYPE)
        for(FinServ__FinancialAccount__c accountRelatedFinancialAccount : getAccountRelatedFinancialAccount(mainAccountIds)) {
            accountRelatedFinancialAccountIds.add(accountRelatedFinancialAccount.Id);
        }
        
        // FOR ACCOUNT RELATED FinancialAccount (Institution TYPE)
        for(FinServ__FinancialAccount__c accountRelatedFinancialAccount : getAccountRelatedFinancialAccountForInstitution(mainAccountIds)) {
            accountRelatedFinancialAccountIds.add(accountRelatedFinancialAccount.Id);
        }
        
        // FOR ACCOUNT RELATED NOTE 
        for(Notes__c accountRelatedNote : getAccountRelatedNote(mainAccountIds)) {
            accountRelatedNotesIds.add(accountRelatedNote.Id);
        }
        
        mainAccountIds.add(accountId);
        //objectApiNameToIds.get('Account').add(accountId);
        return objectApiNameToIds;
    }
    
    /**
      @ PURPOSE     : FETCHES AND DISPLAYS AN EXCEPTION MESSAGE. 
      @ PARAMETER   : EXCEPTION.
      @ RETURN TYPE : STRING [ DETAILS OF THE EXCEPTION ].
   */
   public static String getPageErrorMessage(Exception e) {

       String strErrorMessage = e.getMessage();
       if(strErrorMessage.contains(',') && !strErrorMessage.endswith(',')) {         
           strErrorMessage = strErrorMessage.split(',').get(1);
       }
       return strErrorMessage;
   }
}