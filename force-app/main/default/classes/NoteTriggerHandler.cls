/* @PURPOSE             :   THIS IS HELPER APEX CLASS FOR NoteTrigger APEX TRIGGER 
*  @CREATED BY          :   DWS
*  @CREATED DATE        :   02 JAN 2019
*  @LAST MODIFIED DATE  :   02 JAN 2019
*  @UPDATED BY          :   DWS
*/
public class NoteTriggerHandler {

    /**
    @ PURPOSE     : CREATE CONTACT RELATED NOTES SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND FTER THAT ADDED NEW ACCOUNT RELATED CONTACTS).
    @ PARAMETER   : 1. List [ Additional_Email__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    public static void createContactNoteSharing(List<Notes__c> notes) {
        if(notes != NULL && !notes.isEmpty()) {
            List<Id> toShareWithIds = new List<Id>();
            List<ContactShare> contactShares;
            List<AccountShare> accountShares;
            List<SObject> sobjectList = new List<SObject>();
            for(Notes__c note : notes) {
                if(note.Associated_Contact__c != NULL) {
                    toShareWithIds.add(note.Associated_Contact__c);               
                } 
                if(note.Associated_Entity_Household__c != NULL) {
                    toShareWithIds.add(note.Associated_Entity_Household__c);               
                } 
            }
            
            if(!toShareWithIds.isEmpty()) {
                contactShares = [SELECT Id, UserOrGroupId, ContactAccessLevel, RowCause
                                 FROM ContactShare
                                 WHERE ContactId IN  :toShareWithIds];
                accountShares = [SELECT Id, UserOrGroupId, AccountAccessLevel, RowCause
                                 FROM AccountShare
                                 WHERE AccountId IN  :toShareWithIds];
            }
            
            
            if(contactShares != NULL && !contactShares.isEmpty()) { 
                for(ContactShare contactShare : contactShares) {
                    if(contactShare.RowCause != 'Owner') {
                        for(Notes__c note : notes) {
                            sobjectList.add(createShareObjectRecord('Notes__c', contactShare.UserOrGroupId, 
                                                                    note.Id, contactShare.ContactAccessLevel, NULL));
                        }
                    }
                }
            }
            
            if(accountShares != NULL && !accountShares.isEmpty()) {
                for(AccountShare accountShare : accountShares) {
                    if(accountShare.RowCause != 'Owner') {
                        for(Notes__c note : notes) {
                            sobjectList.add(createShareObjectRecord('Notes__c', accountShare.UserOrGroupId, 
                                                                    note.Id, accountShare.AccountAccessLevel, NULL));
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
    
    /**
    @ PURPOSE     : CREATE CONTACT RELATED NOTES SHARING RECORDS (IF ACCOUNT IS ALREADY SHARED WITH USER AND FTER THAT ADDED NEW ACCOUNT RELATED CONTACTS).
    @ PARAMETER   : 1. List [ Additional_Email__c RECORD ].
    @ RETURN TYPE : NOT RETURN.
    */
    public static void deleteContactNoteSharing(List<Notes__c> emails) {
        //
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