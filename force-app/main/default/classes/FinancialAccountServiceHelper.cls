public with sharing class FinancialAccountServiceHelper {
    public static String bdDefaultContactNamePrefix = 'Black Diamond Integration';
    public static List<FinancialAccountInfo> processClientIDs(List<FinancialAccountInfo> clientIDsLst){
        //Collection that is final desired map
        map<string, FinancialAccountInfo> mapClientId2FinancialAccountInfo = new map<string, FinancialAccountInfo>();
        
        map<string, Id> mapClientId2HouseholdId = new map<string, Id>();
        map<Id, String> mapHouseholdId2ClientId = new map<Id, String>();
        set<Id> allHouseholdIdsWithClientIds = new set<Id>();
        
        //Primary Group Contact cannot be the marked Primary Group on more than 1 household
        map<Id, Id> mapPrimaryGroupContact2Household = new map<Id, Id>();
        map<Id, Id> mapHousehold2PrimaryGroupContact = new map<Id, Id>();
        map<Id, Id> mapHousehold2OwnerId = new map<Id, Id>();
        
        
        //1. Get Client IDs from the API Request
        set<string> setInvalidClientIds = new set<string>();
        set<double> setClientIds = FinancialAccountServiceUtil.getUniqueClientIds(clientIDsLst, setInvalidClientIds);
        //Initialize with null so that we know which client Ids don't have households
        for(double clientId :setClientIds){
        String clientIdStr = clientId == 0.0 ? '0000': string.valueOf(Integer.valueOf(clientId));
            mapClientId2HouseholdId.put(clientIdStr, null);
        }
                
        //2. Get all Households based on client Ids collected from the above FA Ids. Only where the match is found.
        set<String> fieldsHHtoQuery = new set<string>{'Id', 'Client_group_ID__c', 'Name', 'OwnerId'};
        String householdWhereClause = 'RecordType.Name = \'' + MonetaConstants.HouseholdRecordtype + '\' AND Client_group_ID__c IN :setClientIds';
        String hhQuery = QueryUtil.getQueryString(MonetaConstants.object_Account, fieldsHHtoQuery, null, householdWhereClause);
        list<sObject> allHouseholds = Database.query(hhQuery);      
        
        //Get all Households mapped by client Id
        for(Sobject s :allHouseholds){
            Account household = (Account)s; 
            system.debug('Client Group Id : ' + household.Client_group_ID__c);
            system.debug('Household Account Id : ' + household.Id);
            
            mapClientId2HouseholdId.put(string.valueof(household.Client_group_ID__c), household.Id);
            mapHouseholdId2ClientId.put(household.Id, string.valueof(household.Client_group_ID__c));
            allHouseholdIdsWithClientIds.add(household.Id);
            //Initialize the map so that we know which Households don't have Primary Group Contacts
            mapHousehold2PrimaryGroupContact.put(household.Id, null);
            mapHousehold2OwnerId.put(household.Id, household.OwnerId);
        }
        
        
        //3. Get all Contact IDs that are marked Primary Group for the Households concerned 
        //Getting all AccountContactRelations based on the Household Ids collected above
        set<String> fieldsA2CtoQuery = new set<string>{'Id', 'AccountId', 'ContactId', 'FinServ__PrimaryGroup__c'};
        String a2cRelWhereClause = 'FinServ__PrimaryGroup__c = true AND AccountId IN :allHouseholdIdsWithClientIds';
        String a2CRelQuery = QueryUtil.getQueryString(MonetaConstants.objectA2CRel, fieldsA2CtoQuery, null, a2cRelWhereClause);
        System.debug('a2CRelQuery'+a2CRelQuery);
        list<sObject> allA2CRelsLst = Database.query(a2CRelQuery);
        System.debug('allA2CRelsLst'+allA2CRelsLst);
        
        set<Id> setOfPrimaryContactIds = new set<Id>();
        
        for(Sobject s :allA2CRelsLst){
            AccountContactRelation relationA2C = (AccountContactRelation)s;
            Id primaryContactId = relationA2C.ContactId;
            if(primaryContactId != null){
                setOfPrimaryContactIds.add(primaryContactId);
                mapPrimaryGroupContact2Household.put(primaryContactId, relationA2C.AccountId);
                mapHousehold2PrimaryGroupContact.put(relationA2C.AccountId, primaryContactId);
            }
        }
system.debug('setOfPrimaryContactIds : ' + setOfPrimaryContactIds);
        
        //4. Get all Contacts & Individual IDs based on Contact IDs collected above
        map<string, Id> mapIndividualId2ContactId = new map<string, Id>();
        map<Id, string> mapContactId2IndividualId = new map<Id, string>();
        set<string> setOfPrimaryIndividualIds = new set<string>();
        //Getting all Primary Contacts based on the Primary Contact Ids collected above
        
        set<String> fieldsPrimaryContactsQuery = new set<string>{'Id', 'FinServ__IndividualId__c', 'Name'};
        String primaryContactWhereClause = 'Name LIKE \'' + bdDefaultContactNamePrefix + '%\' AND Id IN :setOfPrimaryContactIds';
        String primaryContactsQuery = QueryUtil.getQueryString(MonetaConstants.object_Contact, fieldsPrimaryContactsQuery, null, primaryContactWhereClause);
        system.debug('primaryContactsQuery '+primaryContactsQuery);
        list<sObject> allContactsLst = Database.query(primaryContactsQuery);
        //Getting the Individual Id for all Contacts from AccountContactRelations
        for(Sobject s :allContactsLst){
            Contact cont = (Contact)s;
            if(cont.FinServ__IndividualId__c != null){
                setOfPrimaryIndividualIds.add(cont.FinServ__IndividualId__c);
                mapIndividualId2ContactId.put(cont.FinServ__IndividualId__c, cont.Id);
                mapContactId2IndividualId.put(cont.Id, cont.FinServ__IndividualId__c);
            }
        }
        system.debug('setOfPrimaryIndividualIds : ' + setOfPrimaryIndividualIds);
        
        //5. Get Individual Accounts based on Individual Ids obtained above
        map<Id, Id> mapContactId2PrimaryAccountId = new map<Id,Id>();
        
        //Getting all Primary Accounts based on the Primary Contact Ids collected above
        set<String> fieldsPrimaryAcctsQuery = new set<string>{'Id', 'FinServ__IndividualId__c'};
        String primaryAccountWhereClause = ' FinServ__IndividualId__c IN :setOfPrimaryIndividualIds';
        String primaryAccountsQuery = QueryUtil.getQueryString(MonetaConstants.object_Account, fieldsPrimaryAcctsQuery, null, primaryAccountWhereClause);
        system.debug('primaryAccountsQuery : ' + primaryAccountsQuery);
        list<sObject> allPrimaryAccountsLst = Database.query(primaryAccountsQuery);
        for(Sobject s :allPrimaryAccountsLst){
            Account acct = (Account)s;
            //If we find the Contact for the Individual Id
            Id associatedContactId = mapIndividualId2ContactId.get(acct.FinServ__IndividualId__c);
            if(associatedContactId != null && acct.FinServ__IndividualId__c == mapContactId2IndividualId.get(associatedContactId)){
                system.debug('associatedContactId : ' + associatedContactId + ' ---- ' + 'acct.Id ' + acct.Id);
                mapContactId2PrimaryAccountId.put(associatedContactId, acct.Id);
            }
        }
        system.debug('mapContactId2PrimaryAccountId '+mapContactId2PrimaryAccountId);
        map<Id, Id> mapHouseholdId2NewPrimaryAccountId = new map<Id, Id>();
        //6. Reassociate with the correct maps - Primary Account
        for(Sobject s :allA2CRelsLst){
            AccountContactRelation relationA2C = (AccountContactRelation)s;
            Id currentContactId = relationA2C.ContactId;
            if(mapContactId2PrimaryAccountId.containsKey(currentContactId)) {
            Id currentPrimaryAccountId = mapContactId2PrimaryAccountId.get(currentContactId);
            Id currentHouseholdId = relationA2C.AccountId;
            mapHouseholdId2NewPrimaryAccountId.put(currentHouseholdId, currentPrimaryAccountId);
            }
        }
        
        //7. 
        //Create default Household
        //Id defaultHHId = FinancialAccountServiceUtil.fetchDefaultHousehold();
        //For the above households, create Primary Group contacts where absent
        //FinancialAccountServiceUtil.reconcileHouseholdPrimaryGroupContacts(mapClientId2HouseholdId, 
        //                                                                  mapHousehold2PrimaryGroupContact, defaultHHId, 
        //                                                                  allHouseholds, mapHouseholdId2NewPrimaryAccountId);
        
        //8. Associate client Id to Primary Account Id
        system.debug('mapHouseholdId2NewPrimaryAccountId '+mapHouseholdId2NewPrimaryAccountId);
        for(Id hhId :mapHouseholdId2NewPrimaryAccountId.keySet()){
            Id primaryAccountId = mapHouseholdId2NewPrimaryAccountId.get(hhId);
            system.debug('primaryAccountId '+primaryAccountId);
            string clientIdStr = mapHouseholdId2ClientId.get(hhId);
            //string clientIdStr = string.valueOf(clientId);
            string hhOwnerId = mapHousehold2OwnerId.get(hhId);
            FinancialAccountInfo fainfo = new FinancialAccountInfo(clientIdStr, string.valueOf(primaryAccountId), hhOwnerId);
            mapClientId2FinancialAccountInfo.put(clientIdStr, fainfo);
        }
        
        //Get the latest from the custom setting
        FSC_Setting__c defaultOrgSettings = CustomSettingsDataAccess.getGeneralFSCOrgDefaults();
        
        
        //9. For Client Ids without Households, associate the primary of the default household
        for(String clientId : mapClientId2HouseholdId.keySet()){
            System.debug('invalidClientId'+clientId);
            if(mapClientId2HouseholdId.get(clientId) == null){
                //string clientIdStr = string.valueOf(integer.valueOf(clientId));
                string hhOwnerId = UserInfo.getUserId(); //Setting the owner to be the same as the API User since the default HH is created by the API.
                FinancialAccountInfo fainfo = new FinancialAccountInfo(clientId, defaultOrgSettings.FA_Service_Default_Household_Primary_Acc__c, hhOwnerId);
                mapClientId2FinancialAccountInfo.put(clientId, fainfo);
            }
        }
        
        for(string invalidClientId : setInvalidClientIds){
            string hhOwnerId = UserInfo.getUserId(); //Setting the owner to be the same as the API User since the default HH is created by the API.
            
            FinancialAccountInfo fainfo = new FinancialAccountInfo(invalidClientId, defaultOrgSettings.FA_Service_Default_Household_Primary_Acc__c, hhOwnerId);
            mapClientId2FinancialAccountInfo.put(invalidClientId, fainfo);
        }
        system.debug('mapClientId2FinancialAccountInfo '+mapClientId2FinancialAccountInfo);
        return FinancialAccountServiceUtil.getFinancialInfoFormattedResult(mapClientId2FinancialAccountInfo);
    }
    
}