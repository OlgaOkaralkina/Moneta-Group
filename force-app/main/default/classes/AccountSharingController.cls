/* @PURPOSE				: 	THIS IS CONTROLER APEX CLASS FOR AccountSharing LIGHTNING COMPONENT
 * @CREATED BY			:	DWS
 * @CREATED DATE		:	08 DEC 2018
 * @LAST MODIFIED DATE	:	25 DES 2018 
 * @MODIFIED BY 		:	DWS
 */
public class AccountSharingController {

    /**
      @ PURPOSE     : CHECK CURRENT LOGGED IN USER IS System Administrator OR NOT.
      @ RETURN TYPE : BOOLEAN [ IF CURRENT USER IS SYSTEM ADMINISTRATOR RETURN TRUE ELSE FALSE].
   */
    @auraEnabled
    public static Boolean checkCurrentUserProfile() {
        return AccountSharingHelper.checkCurrentUserProfile();
    }
    
    /**
      @ PURPOSE     : FETCHES AND RETURNS ALL PERMISSION FOR CURRENT ACCOUNT RECORD.
      @ PARAMETER   : 1. String [ ACCOUNT ID ].
      @ RETURN TYPE : List<AccountShare>.
   */
    @auraEnabled
    public static List<AccountShare> getcurrentPermissions(String accountId) {
        return AccountSharingHelper.getcurrentPermissions(accountId);
    }
    
    /**
      @ PURPOSE     : FETCHES AND RETURNS ALL USERS OR PUBLIC GROUP
      @ PARAMETER   : 1. String [ OBJECT API NAME ],
					  2. List<sObject> [ TO SKIP CURRENT USER PERMISSION ID's ]
      @ RETURN TYPE : List<SObject> [ DEPEND's ON OBJECT API NAME ].
   */
    @auraEnabled 
    public static List<sObject> getRecords(String sObjectName, List<sObject> currentPermissionUsers) {
         return AccountSharingHelper.getRecords(sObjectName, currentPermissionUsers);
    }  
    
    /**
      @ PURPOSE     : CREATING SHARING RECORD FOR CURRENT ACCOUNT, RELATED CONTACTS, RELATED ACCOUNTS, AND RELATED ACCOUNTS CONTACTS
      @ PARAMETER   : 1. String [ ACCOUNT ID ],
					  2. String [ USER TYPE (USER, PUBLIC GROUP. OR USER ROLE) ],
					  3. List<String> [ CREATE SHARING RECORDS FOR THIS USER ],
					  4. String [ RECORD ACCESS LAVEL ]
      @ RETURN TYPE : String [ SUCCESS OR ERROR MESSAGE ].
   */
    @auraEnabled
    public static String createSharingRecord(String accountId, String userType, List<String> userIds, String accessType) {
        return AccountSharingHelper.createSharingRecord(accountId, userType, userIds, accessType);
    } 
    
     /**
      @ PURPOSE     : DELETING SHARING RECORD FOR CURRENT ACCOUNT, RELATED CONTACTS, RELATED ACCOUNTS, AND RELATED ACCOUNTS CONTACTS
      @ PARAMETER   : 1. String [ ACCOUNT ID ],
					  2. String [ SHARE RECORD ID ],
					  4. String [ USER ID ]
      @ RETURN TYPE : String [ SUCCESS OR ERROR MESSAGE ].
   */
    @auraEnabled
    public static String deleteShareRecord(String accountId, String strRecordId, String strUserdId) {
        return AccountSharingHelper.deleteShareRecord(accountId,strRecordId,strUserdId);
    }
     
    /**
      @ PURPOSE     : UPDATING SHARING RECORD FOR CURRENT ACCOUNT, RELATED CONTACTS, RELATED ACCOUNTS, AND RELATED ACCOUNTS CONTACTS
      @ PARAMETER   : 1. String [ ACCOUNT ID ],
					  2. String [ SHARE RECORD ID ],
					  3. String [ RECORD ACCESS LAVEL ],
					  4. String [ USER ID ]
      @ RETURN TYPE : String [ SUCCESS OR ERROR MESSAGE ].
   */
    @auraEnabled
    public static String updateShareRecord(String accountId, String strRecordId, String strAccessLevel, String strUserId) {
        return AccountSharingHelper.updateShareRecord(accountId, strRecordId, strAccessLevel,strUserId);
    }
}