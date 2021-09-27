@isTest
private class PCEAlternativeInvestmentCallsTriggerTest {
private static testMethod void Test_PCEAlternativeInvestmentCallsTrigger () { 
        Alternative_Investment_Calls__c fw = new Alternative_Investment_Calls__c(); 
    	fw.Financial_Account__c = 'a0A4100000DJ60aEAD';
        insert fw; 
        System.assertNotEquals(null, fw.Id); 
        update fw; 
        delete fw; 
    } 
}