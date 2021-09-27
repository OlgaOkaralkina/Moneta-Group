@isTest
public with sharing class ChecklistItemsTriggerHandlerTest {
    @isTest
    public Static void SetChecklistItemsStartDateTest() {
        inspire1__Project__c project = new inspire1__Project__c(Name = 'Test Project');
		insert project;

		inspire1__Project_Tasks__c projectTask = new inspire1__Project_Tasks__c(
				inspire1__Name__c = 'Test Task',
				inspire1__Project__c = project.Id
		);
		insert projectTask;

        List<inspire1__Checklist_Item__c> checklistItems = new List<inspire1__Checklist_Item__c>{
            new inspire1__Checklist_Item__c(inspire1__Project_Task__c = projectTask.Id, inspire1__Item_Name__c = 'testChecklist1', inspire1__Completed__c = true,
             inspire1__Completion_Date__c = DateTime.now(), inspire1__Order__c = 1),
            new inspire1__Checklist_Item__c(inspire1__Project_Task__c = projectTask.Id, inspire1__Item_Name__c = 'testChecklist2', inspire1__Order__c = 2)
        };
        insert checklistItems;

        Test.startTest();
        List<inspire1__Checklist_Item__c> savedChecklistItems = [SELECT Id, Start_Date__c FROM inspire1__Checklist_Item__c 
        WHERE inspire1__Project_Task__c =: projectTask.Id AND inspire1__Order__c = 2];
        Test.stopTest();
        System.assertNotEquals(null, savedChecklistItems[0].Start_Date__c);
    }
}