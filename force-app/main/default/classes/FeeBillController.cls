public with sharing class FeeBillController {
    public Account currentHousehold {get; set;}
    
    public FeeBillController(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()){
            controller.addFields(new List<String>{'Billing_Group_ID__c'});
        }
        currentHousehold = (Account)controller.getRecord();
    }
    
    public PageReference init(){
        User currentUser = [Select Id, Billing_Group_ID__c From User where Id = :UserInfo.getUserId()];
        currentUser.Billing_Group_ID__c = currentHousehold.Billing_Group_ID__c;
        update currentUser;
        FSC_Setting__c generalSettings = CustomSettingsDataAccess.getGeneralFSCOrgDefaults();
        return new PageReference((String)generalSettings.Fee_Bill_URL__c);
    }

}