@isTest

public with sharing class AutoConvertLeadsTest {
    @testSetup 
    static void setupData(){
        Lead l = new Lead(Company = 'Lead Last Name',
                        LastName = 'Lead Last Name',
                        Engagement_Agreement_Date__c = Date.today()
                        );
        insert l;

    }

    private static testmethod void testAutoConvertLeads() {
        // AcctSeed__Cash_Disbursement__c cashDisburse = [SELECT Id, Name FROM AcctSeed__Cash_Disbursement__c LIMIT 1];
                 
         Test.startTest();
         
         List<Lead> leads = [Select Id from Lead];
         System.debug('leads: ' + leads);

         List<Id> LeadIds = new List<Id>();

         for(Lead lead : leads){
            System.debug('lead: ' + lead);
            LeadIds.add(lead.Id);
         }

         AutoConvertLeads.LeadAssign(LeadIds);


                 
         Test.stopTest();
         
       //  System.assertEquals(1, cashDisbursementIds.size());
     
     }
}