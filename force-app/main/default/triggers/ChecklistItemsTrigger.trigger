trigger ChecklistItemsTrigger on inspire1__Checklist_Item__c (after insert, after update) {
    ChecklistItemsTriggerHandler.SetChecklistItemsStartDate(Trigger.New, Trigger.oldMap);
}