@isTest
public class CreateCheckBatchRecordTest {
    
     @testSetup static void setup() {
        // Create Checks/Paperwork records
        Account accountRecord = CreateReceipent();
        INSERT accountRecord;
         
        List<Checks_Paperwork__c> checksPaperWorkList ;
        checksPaperWorkList = CreateCheckBatchRecordTest.CreateChecksPaperWork();
        INSERT checksPaperWorkList;
         
    }
    
    @isTest
    public Static void CheckBatchTest(){
        List<Checks_Paperwork__c> checksPaperWorkList = [SELECT Id,Delivery_Service__c,Recipient__c,Status__c,Address__c
                                                         FROM Checks_Paperwork__c];
        
        List<List<Checks_Paperwork__c>> checksPwkListOfList = new List<List<Checks_Paperwork__c>>();
        checksPwkListOfList.add(checksPaperWorkList);
        
        Test.startTest();
        List<List<Checks_Paperwork__c>> checkPaperworkRecordToUpdatedListOfList = 
                                                            CreateCheckBatchRecord.CheckBatch(checksPwkListOfList);
        Test.stopTest();
        
        System.assertEquals(4, checkPaperworkRecordToUpdatedListOfList[0].size());
    }
    
    public Static List<Checks_Paperwork__c> CreateChecksPaperWork(){
        Account accountRecord = [SELECT ID 
                                 FROM Account
                                 LIMIT 1];
        
        List<Checks_Paperwork__c> checksPaperWorkList = new List<Checks_Paperwork__c>();
        Map<Integer,String> deliveryServiceMap = new Map<Integer,String>();
        deliveryServiceMap.put(0, 'FedEx');
        deliveryServiceMap.put(1, 'FedEx');
        deliveryServiceMap.put(2, 'UPS Overnight');
        deliveryServiceMap.put(3, 'UPS 2 Day Shipping');
        
        for(Integer i = 0 ; i < 4 ; i++){
            checksPaperWorkList.add(new Checks_Paperwork__c(
                                Delivery_Service__c = deliveryServiceMap.get(i),Status__c = 'Processing Underway',
                                Recipient__c = accountRecord.Id, Household__c = accountRecord.Id));
        }
        
        return checksPaperWorkList;
    }
    
    public Static Account CreateReceipent(){
        
        Account accountRecord = new Account();
        accountRecord.Name = 'Test Account';
        accountRecord.BillingStreet = '1';
        accountRecord.BillingCity = 'test';
        accountRecord.BillingState = 'address';
        accountRecord.BillingPostalCode = '2021';
        accountRecord.BillingCountry = 'SFDC';
        accountRecord.RecordTypeId = '0121K0000013LbhQAE';
        
        return accountRecord;
    }
}