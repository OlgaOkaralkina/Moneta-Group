/* @PURPOSE             :   THIS IS HELPER APEX CLASS FOR CopyAccountShare APEX TRIGGER
*  @CREATED BY          :   DWS
*  @CREATED DATE        :   17 JAN 2019
*  @LAST MODIFIED DATE  :   17 JAN 2019
*  @UPDATED BY          :   DWS
*/
public with sharing class CopyAccountShareHandler {
    
    // USED TO MAINTAIN CONTACTS ACCOUNT RECORD ID
    public static Set<Id> mainAccountIds = new Set<Id>();
    public static Set<Id> contactRelatedNoteIds = new Set<Id>();
    public static Set<Id> accountRelatedFinancialAccountIds = new Set<Id>();
    public static Set<Id> accountRelatedNotesIds = new Set<Id>();
    
    /**
    @ PURPOSE     : CREATE SHARING RECORD FOR OLD OWNER IF OWNER OF RECORD CHANGE
    @ PARAMETER   : 1. List [ Additional_Email__c RECORD ].
    @				2. Map [ ACCOUNT ID, ACCOUNT RECORD]
    @ RETURN TYPE : NOT RETURN.
    */    
    public static void deleteDuplicateAccountShareRec(List<Account> accounts, Map<Id,Account> oldAccounts) {
        Set<Id> accountIds = new Set<Id>();
        Set<Id> newOwnerIds = new Set<Id>();
        Set<Id> oldOwnerIds = new Set<Id>();
        for(Account accRecord: accounts) {
            if(accRecord.OwnerId != oldAccounts.get(accRecord.Id).OwnerId) {
                accountIds.add(accRecord.Id);
                newOwnerIds.add(accRecord.OwnerId);
                oldOwnerIds.add(oldAccounts.get(accRecord.Id).OwnerId);
            }
        }
        
        if(!oldOwnerIds.isEmpty()) {
            List<AccountShare> allAccountShareList = [SELECT Id, AccountId, UserOrGroupId, UserOrGroup.Type, UserOrGroup.Name, UserOrGroup.profile.Name,
                                                      AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel, RowCause
                                                      FROM   AccountShare
                                                      WHERE  AccountId IN :accountIds
                                                      LIMIT 50000];
            List<Groupmember> ownerGroup = [SELECT Userorgroupid , GroupId
                                            FROM Groupmember
                                            WHERE Userorgroupid IN :newOwnerIds
                                            LIMIT 50000];
            if(allAccountShareList != NULL && !allAccountShareList.isEmpty() && ownerGroup != NULL && !ownerGroup.isEmpty()) {
                String ownerGroupString = JSON.serialize(ownerGroup);
                String allAccountShareListString = JSON.serialize(allAccountShareList);
                
                if(!System.isFuture() && !System.isBatch()) {
                    deleteShareRecords(ownerGroupString, allAccountShareListString);
                }                
            }
        }
    } 
     
    @future 
    private static void deleteShareRecords(String ownerGroupString, String allAccountShareListString) {
        List<Groupmember> newOwnerGroup = (Groupmember[])JSON.deserialize(ownerGroupString, Groupmember[].class);
        List<AccountShare> allAccountShareList = (AccountShare[])JSON.deserialize(allAccountShareListString, AccountShare[].class);
        Set<AccountShare> toDeleteUserShareRecords = new Set<AccountShare>(); 
        Set<Id> groupIds = new Set<Id>();
        if(newOwnerGroup != NULL && !newOwnerGroup.isEmpty() && allAccountShareList != NULL && !allAccountShareList.isEmpty()) {           
            if(newOwnerGroup != NULL && !newOwnerGroup.isEmpty()) {
                for(Groupmember grpMember : newOwnerGroup) {
                    groupIds.add(grpMember.GroupId);                    
                }
            }
            
            List<User> userList = [SELECT Id, Name, Email, Isactive, Profile.Name, Userrole.Name, Usertype
                                   FROM user 
                                   WHERE Id IN (SELECT Userorgroupid 
                                                FROM Groupmember 
                                                WHERE GroupId IN :groupIds)
                                  LIMIT 50000];
            if(!userList.isEmpty()) {
                List<SObject> records = new List<SObject>();
                List<SObject> newRecords;
                List<Id> recordOwnerIds;
                for(User userRec : userList) {
                    for(AccountShare accountShareRec : allAccountShareList) {
                        newRecords = new List<SObject>();
                        recordOwnerIds = new List<id>();
                        if(accountShareRec.UserOrGroup.Type == 'User') {
                            if((userRec.Name == accountShareRec.UserOrGroup.Name) && accountShareRec.RowCause != 'Owner') {
                                toDeleteUserShareRecords.add(accountShareRec);
                            } else if((userRec.Name == accountShareRec.UserOrGroup.Name) && accountShareRec.RowCause == 'Owner') {
                                recordOwnerIds.add(accountShareRec.UserOrGroupId);
                                newRecords.addAll(createSharingRecord(accountShareRec.AccountId, NULL, recordOwnerIds, 'Edit'));  
                                if(newRecords != NULL && !newRecords.isEmpty()) {
                                    records.addAll(newRecords);
                                }
                            } 
                        } 
                    }
                }  
                
                if(!groupIds.isEmpty()) {
                    List<Id> toShareGroupIds;
                    for(Id grpId : groupIds) {
                        for(AccountShare accountShareRec : allAccountShareList) {
                            newRecords = new List<SObject>();
                            recordOwnerIds.add(accountShareRec.UserOrGroupId);
                            newRecords.addAll(createSharingRecord(accountShareRec.AccountId, NULL, recordOwnerIds, 'Edit'));  
                            if(newRecords != NULL && !newRecords.isEmpty()) {
                                records.addAll(newRecords);
                            }
                        }
                    }
                }
                
                if(!toDeleteUserShareRecords.isEmpty()) {
                    List<AccountShare> toDeleteAccountShareList = new List<AccountShare>(toDeleteUserShareRecords);
                    DELETE toDeleteAccountShareList;
                }
                
                if(!records.isEmpty()) {
                    List<SObject> accountList = new List<SObject>();
                    List<SObject> contactList = new List<SObject>();
                    List<SObject> noteList = new List<SObject>();
                    List<SObject> financialAccountList = new List<SObject>();
                    
                    for(SObject sobjectRec : records) {
                        if(sobjectRec.getSobjectType().getDescribe().getName() == 'AccountShare') {
                            accountList.add(sobjectRec);
                        } else if(sobjectRec.getSobjectType().getDescribe().getName() == 'ContactShare') {
                            contactList.add(sobjectRec);
                        } else if(sobjectRec.getSobjectType().getDescribe().getName() == 'FinServ__FinancialAccount__Share') {
                            financialAccountList.add(sobjectRec);
                        } else if(sobjectRec.getSobjectType().getDescribe().getName() == 'Notes__Share') {
                            noteList.add(sobjectRec);
                        }                         
                    }
                    Database.insert(accountList, false);
                    Database.insert(contactList, false);
                    Database.insert(financialAccountList, false);
                    Database.insert(noteList, false);
                }
                
            }
        }        
    }
    
    /**
    @ PURPOSE     : KEEP EXISTING SHARING RECORDS IF OWNER OF RECORD WILL CHANGE
    @ PARAMETER   : 1. List [ Additional_Email__c RECORD ].
    @				2. Map [ ACCOUNT ID, ACCOUNT RECORD]
    @ RETURN TYPE : NOT RETURN.
    */
    /**
    @ PURPOSE     : KEEP EXISTING SHARING RECORDS IF OWNER OF RECORD WILL CHANGE
    @ PARAMETER   : 1. List [ Additional_Email__c RECORD ].
    @				2. Map [ ACCOUNT ID, ACCOUNT RECORD]
    @ RETURN TYPE : NOT RETURN.
    */
    /*public static void keepOldSharing(List<Account> accounts, Map<Id,Account> oldAccounts) {  
        Set<Account> accountSet = new Set<Account>(accounts);
        Set<Id> oldOwnerIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(Account accRecord: accounts) {
            if(accRecord.OwnerId != oldAccounts.get(accRecord.Id).OwnerId) {
                accountIds.add(accRecord.Id);
                oldOwnerIds.add(oldAccounts.get(accRecord.Id).OwnerId);
            }            
        }        
        keepOldSharingFetureMethod(accountIds, oldOwnerIds);
    }
    
    @future*/
    public static void keepOldSharing(List<Account> accounts, Map<Id,Account> oldAccounts) {        
        Set<Id> accountIds = new Set<Id>();
        Set<Id> oldOwnerIds = new Set<Id>();
        for(Account accRecord: accounts) {
            if(accRecord.OwnerId != oldAccounts.get(accRecord.Id).OwnerId) {
                accountIds.add(accRecord.Id);
                oldOwnerIds.add(oldAccounts.get(accRecord.Id).OwnerId);
            }            
        }
        
        List<AccountShare> accountShareList = [SELECT Id, AccountId, UserOrGroupId, UserOrGroup.profile.Name, AccountAccessLevel, OpportunityAccessLevel, 
                                               			CaseAccessLevel, ContactAccessLevel, RowCause 
                                               FROM   AccountShare 
                                               WHERE  AccountId IN :accountIds
                                               LIMIT 50000];
        
        List<SObject> sobjectList = new List<SObject>();
        for(AccountShare accountShare : accountShareList) {
            SObject objRecord = AccountSharingHelper.initializeSobjRecord('Account' + 'Share');
            objRecord.put('Id',null);
            objRecord.put('UserOrGroupId',accountShare.UserOrGroupId);
            objRecord.put('AccountAccessLevel',accountShare.AccountAccessLevel);
            objRecord.put('OpportunityAccessLevel',accountShare.OpportunityAccessLevel);
            objRecord.put('CaseAccessLevel',accountShare.CaseAccessLevel);
            objRecord.put('ContactAccessLevel',accountShare.ContactAccessLevel);
            objRecord.put('AccountId',accountShare.AccountId);
            if(accountShare.UserOrGroup.profileId != null &&
               accountShare.UserOrGroup.profile.Name != null &&
               accountShare.UserOrGroup.profile.Name == 'System Administrator') {
                   objRecord.put('RowCause','Rule');
               } else {
                   objRecord.put('RowCause','Manual');
               }
            sobjectList.add(objRecord);
        }
        
        if(!System.isFuture() && !System.isBatch()) {
        	persistSharing(JSON.serialize(sobjectList), accountIds, oldOwnerIds);
        }
        
    }
    
    @future
    private static void persistSharing(String ShareString, Set<Id> accountIds,  Set<Id> oldOwnerIds) {
        SObject[] reasons = (AccountShare[])JSON.deserialize(shareString, AccountShare[].class);
        Database.insert(reasons, false);
        
        List<AccountShare> accountShareList = [SELECT Id, AccountId, UserOrGroupId, UserOrGroup.profile.Name, AccountAccessLevel, OpportunityAccessLevel,
                                               CaseAccessLevel, ContactAccessLevel, RowCause, UserOrGroup.Name
                                               FROM AccountShare
                                               WHERE AccountId IN :accountIds
                                               LIMIT 50000];
        
        List<AccountShare> duplicateAccountShareRec = new List<AccountShare>();
        for(Integer i=0; i<accountShareList.size(); i++) {
            AccountShare firstuserName = accountShareList.get(i);
            for(Integer j=0; j<accountShareList.size(); j++) {
                AccountShare secontUserName = accountShareList.get(j);
                if(firstuserName.UserOrGroup.Name == secontUserName.UserOrGroup.Name && i!=j) {
                    duplicateAccountShareRec.add(accountShareList.get(j));
                }
            }
        }
        
        Set<Id> toDeletes = new Set<Id>();
        if(!duplicateAccountShareRec.isEmpty()) {
            for(AccountShare accountShareRec : duplicateAccountShareRec) {
                if(accountShareRec.RowCause == 'Manual') {
                    toDeletes.add(accountShareRec.Id);
                }
            }
        }
        
        if(!toDeletes.isEmpty()) {
            
            DELETE [SELECT ID 
                    FROM AccountShare 
                    WHERE Id IN: toDeletes 
                    LIMIT 50000];
        }
        
        if(!oldOwnerIds.isEmpty()) {            
            List<Groupmember> ownerGroup = [SELECT Userorgroupid , GroupId
                                            FROM Groupmember 
                                            WHERE Userorgroupid IN :oldOwnerIds
                                            LIMIT 50000];  
            
            Set<AccountShare> toDeleteUserShareRecords = new Set<AccountShare>(); 
            Set<Id> groupIds = new Set<Id>();            
            if(ownerGroup != NULL && !ownerGroup.isEmpty()) {
                for(Groupmember grpMember : ownerGroup) {
                    groupIds.add(grpMember.GroupId);
                }
            }
            for(AccountShare accountShareRec : accountShareList) {
                if(groupIds.contains(accountShareRec.UserOrGroupId )) {
                    toDeleteUserShareRecords.add(accountShareRec);
                }
            } 
            if(!toDeleteUserShareRecords.isEmpty()) {
                List<AccountShare> toDeleteAccountShareList = new List<AccountShare>(toDeleteUserShareRecords);
                Database.delete(toDeleteAccountShareList, FALSE);
            }
        }
        
        List<AccountShare> allAccountShares = [SELECT Id, UserOrGroupId 
                                               FROM AccountShare 
                                               WHERE AccountId IN: accountIds 
                                               LIMIT 50000];
        
        Set<Id> keepSharingRecordsForOtherRecords = new Set<Id>();
        if(allAccountShares != NULL && !allAccountShares.isEmpty()) {
            for(AccountShare accountShare : allAccountShares) {
                keepSharingRecordsForOtherRecords.add(accountShare.UserOrGroupId);
            }
        }
        
        if(!keepSharingRecordsForOtherRecords.isEmpty()) {
            Map<String, Set<Id>> objectApiNameToIds = new Map<String, Set<Id>>();
            List<id> mainAccountIds = new List<id>(accountIds);
            for(Id accId : mainAccountIds) {
                objectApiNameToIds.putAll(getRelatedAccountsAndContacts(accId));
            }
            
            Set<Id> sobjects = new Set<Id>();
            List<sobject> todeleteAccountShare = new List<sobject>();
            List<sobject> todeleteContactShare = new List<sobject>();
            List<sobject> todeleteFinServFinancialAccountShare = new List<sobject>();
            List<sobject> todeleteNotesShare = new List<sobject>();
            sobjects.addAll(mainAccountIds);
            
            for(String sObjectName : objectApiNameToIds.keySet()) {
                for(Id sObjectId : objectApiNameToIds.get(sObjectName)) {
                    sobjects.add(sObjectId);
                }
            }
            
            todeleteAccountShare.addAll([SELECT Id 
                                         FROM AccountShare 
                                         WHERE AccountId IN :sobjects AND UserOrGroupId != :keepSharingRecordsForOtherRecords
                                         LIMIT 50000]);
            
            todeleteContactShare.addAll([SELECT Id
                                         FROM ContactShare 
                                         WHERE ContactId IN :sobjects AND UserOrGroupId != :keepSharingRecordsForOtherRecords
                                         LIMIT 50000]);
            
            todeleteFinServFinancialAccountShare.addAll([SELECT Id
                                                         FROM FinServ__FinancialAccount__Share 
                                                         WHERE Parent.FinServ__Household__c IN :sobjects AND UserOrGroupId != :keepSharingRecordsForOtherRecords
                                                         LIMIT 50000]);
            
            todeleteFinServFinancialAccountShare.addAll([SELECT Id
                                                         FROM FinServ__FinancialAccount__Share 
                                                         WHERE Parent.FinServ__PrimaryOwner__c IN :sobjects AND UserOrGroupId != :keepSharingRecordsForOtherRecords
                                                         LIMIT 50000]);
            
            todeleteNotesShare.addAll([SELECT Id
                                       FROM Notes__Share 
                                       WHERE (Parent.Associated_Entity_Household__c IN :sobjects OR 
                                              Parent.Associated_Contact__c IN :sobjects) AND 
                                       UserOrGroupId != :keepSharingRecordsForOtherRecords
                                       LIMIT 50000]);
            
            Database.delete(todeleteAccountShare, false);
            Database.delete(todeleteContactShare, false);
            Database.delete(todeleteFinServFinancialAccountShare, false);
            Database.delete(todeleteNotesShare, false);
        }
    }
    
    private static List<SObject> createSharingRecord(String accountId, String userType, List<String> userIds, String accessType) {        
        Map<String, Set<Id>> objectApiNameToIds = getRelatedAccountsAndContacts(accountId);
        List<SObject> records = new List<SObject>();            
        
        if(String.isNotBlank(userType) && userType.equalsIgnoreCase('userrole')) {
            
        } else {
            for(String userId : userIds) {
                for(String sObjectName : objectApiNameToIds.keySet()) {
                    for(Id sObjectId : objectApiNameToIds.get(sObjectName)) {
                        records.add(AccountSharingHelper.createShareObjectRecord(sObjectName, userId, sObjectId, accessType, NULL));
                    }
                }
            }
        }
        
        RETURN records;
        /*if(!records.isEmpty()) { 
			RETURN records;
            //Database.insert(records, false);
        } else {
            RETURN NULL;
        } */  
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
            'FinServ__FinancialAccount__c' => new Set<Id>()};
                Map<String, String> contactIdToContactName = new Map<String, String>();
        
        // FOR ACCOUNT RELATED CONTACTS
        for(AccountContactRelation accountContactRelation : AccountSharingHelper.getAccountContactRelationByAccounts(new Set<Id> {accountId})) {
            objectApiNameToIds.get('Contact').add(accountContactRelation.ContactId);
            contactIdToContactName.put(accountContactRelation.ContactId, accountContactRelation.Contact.Name);
            mainAccountIds.add(accountContactRelation.AccountId);
        }
        
        // FOR CONTACT RELATED CONTACTS
        for(FinServ__ContactContactRelation__c contactContactRelation : AccountSharingHelper.getContactToContactRelationByContacts(objectApiNameToIds.get('Contact'))) {
            objectApiNameToIds.get('Contact').add(contactContactRelation.FinServ__RelatedContact__c);
            contactIdToContactName.put(contactContactRelation.FinServ__RelatedContact__c, contactContactRelation.FinServ__RelatedContact__r.Name);
        }
        
        // FOR CONTACT RELATED CONTACTS RELATED NOTES
        for(Notes__c contactRelatedNoteId : AccountSharingHelper.getContactRelatedNotesByContacts(objectApiNameToIds.get('Contact'))) {
            contactRelatedNoteIds.add(contactRelatedNoteId.Id);
            objectApiNameToIds.get('Notes__c').add(contactRelatedNoteId.Id);
        }
        
        // FOR GETTING CONTACTS ACCOUNT RECORD
        for(AccountContactRelation accountContactRelation : AccountSharingHelper.getContactAccount(contactIdToContactName)) {
            mainAccountIds.add(accountContactRelation.AccountId);
            objectApiNameToIds.get('Account').add(accountContactRelation.AccountId);
        }
        
         // FOR ACCOUNT RELATED FinancialAccount (HH TYPE)
        for(FinServ__FinancialAccount__c accountRelatedFinancialAccount : AccountSharingHelper.getAccountRelatedFinancialAccount(mainAccountIds)) {
            accountRelatedFinancialAccountIds.add(accountRelatedFinancialAccount.Id);
            objectApiNameToIds.get('FinServ__FinancialAccount__c').add(accountRelatedFinancialAccount.Id);
        }
        
        // FOR ACCOUNT RELATED FinancialAccount (Institution TYPE)
        for(FinServ__FinancialAccount__c accountRelatedFinancialAccount : AccountSharingHelper.getAccountRelatedFinancialAccountForInstitution(mainAccountIds)) {
            accountRelatedFinancialAccountIds.add(accountRelatedFinancialAccount.Id);
            objectApiNameToIds.get('FinServ__FinancialAccount__c').add(accountRelatedFinancialAccount.Id);
        }
        
        // FOR ACCOUNT RELATED NOTE 
        for(Notes__c accountRelatedNote : AccountSharingHelper.getAccountRelatedNote(mainAccountIds)) {
            accountRelatedNotesIds.add(accountRelatedNote.Id);
            objectApiNameToIds.get('Notes__c').add(accountRelatedNote.Id);
        }
        
        mainAccountIds.add(accountId);
        //objectApiNameToIds.get('Account').add(accountId);
        return objectApiNameToIds;
    }
}