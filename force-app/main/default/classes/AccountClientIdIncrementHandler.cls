/**
 *@author Athene Group LLC
 *@date 2017.05
 *@group Apex Class - Trigger Handler
 *@description Trigger handler to calculate the Household ID on create of an Account
 */
public class AccountClientIdIncrementHandler {
    public void onBeforeInsert(List < Account > newlist) {
       
        //Fetch Household recordtype name from Constants and Query the record type Id 
        String HouseholdRecordtype = MonetaConstants.HouseholdRecordtype;
        List < RecordType > rt = [SELECT Id, Name FROM RecordType WHERE  SobjectType = 'Account' and (Name = 'Institution' or Name = 'Household')];

        // Fetch FSC_ClientGroupId field name
        String FSC_ClientGroupId = MonetaConstants.FSC_ClientGroupId;


        //Set the default Id value to 0
        Integer currentIdVal = 0;

        //Query the highest household value in the ORG.
        AggregateResult[] res = [SELECT MAX(Client_group_ID__c) FROM Account where RecordType.Name = :MonetaConstants.HouseholdRecordtype OR RecordType.Name = :MonetaConstants.InstitutionRecordtype];
        if (res != null && !res.isEmpty()) {
            object resObj = res[0].get('expr0');
            currentIdVal = Integer.valueOf(resObj);

            //Check if the Query returned any value.If No,set currentIdval to 0
            if (currentIdVal == null) {
                currentIdVal = 0;
            }
        }
         
        //Fetch the custom settings
        FSC_Setting__c settings = CustomSettingsDataAccess.getGeneralFSCOrgDefaults();

        //Check if Custom settings FSC_setting exist
        if (settings == null || settings.Client_group_ID__c == null || currentIdVal != settings.Client_group_ID__c) {
         //Create or update FSC settings
            settings = AccountClientIdIncrementHandler.upsertFSCSettingsWithClientGroupId(settings, currentIdVal);
        }
        //Check if the Client Group ID is not empty
        if (settings.Client_group_ID__c != null) { 
            Integer CurrentID = (settings.Client_group_ID__c).intValue();

            //Iterate over the new Household accounts
            for (Account newacc: newlist) {

                //Check if the Household already has the ID set.
                if (newacc.Client_group_ID__c == null && (newacc.RecordTypeId == rt[0].Id || newacc.RecordTypeId == rt[1].Id)) {

                    //Increment the Client group Id to be set
                    newAcc.Client_group_ID__c = ++CurrentID;

                }
            }

            //Update FSC Settings with the latest Client ID 
            settings.Client_group_ID__c = CurrentID;
            try
            { 
               update settings;
            }
            catch(exception e)
            {
                //In case of exception update the settings with null;  
                settings.Client_group_ID__c = null;
                update settings;
            }
            
        }
    }
    //Method to create or Update FSC_Setting__c record
    public static FSC_Setting__c upsertFSCSettingsWithClientGroupId(FSC_Setting__c settingVal, Integer currentIdVal) {

            //Assign the Current id i.e, the highest household id from the org to the customsettings 'Client_group_ID__c' field.
            settingVal.Client_group_ID__c = currentIdVal;
            //create/Update the custom settings.
            CustomSettingsDataAccess.upsertGeneralFSCOrgDefaults(settingVal);

        return settingVal;
    }

}