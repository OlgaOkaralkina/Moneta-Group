public with sharing class CustomSettingsDataAccess {
    public static FSC_Setting__c getGeneralFSCOrgDefaults(){
    	return FSC_Setting__c.getOrgDefaults();
    }
    
    public static void upsertGeneralFSCOrgDefaults(FSC_Setting__c settingVal){
    	upsert settingVal;
    }
}