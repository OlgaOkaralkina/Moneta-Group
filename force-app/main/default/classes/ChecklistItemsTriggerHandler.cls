public with sharing class ChecklistItemsTriggerHandler {
    public static void SetChecklistItemsStartDate(List<inspire1__Checklist_Item__c> checklistItems, Map<Id, inspire1__Checklist_Item__c> checklistItemsOldMap) {
        List<inspire1__Checklist_Item__c> itemsToUpdate = new List<inspire1__Checklist_Item__c>();

        for (inspire1__Checklist_Item__c item : checklistItems) {
            inspire1__Checklist_Item__c oldItem = checklistItemsOldMap != null ? checklistItemsOldMap.get(item.Id) : null;

            if ((oldItem == null && item.inspire1__Completed__c) || 
            (oldItem != null && !oldItem.inspire1__Completed__c && item.inspire1__Completed__c)) {
                Integer nextItemsCount  = [SELECT count() FROM inspire1__Checklist_Item__c WHERE inspire1__Project_Task__c =: item.inspire1__Project_Task__c 
                AND inspire1__Order__c >: item.inspire1__Order__c];

                if (nextItemsCount > 0) {
                    inspire1__Checklist_Item__c nextItem = [SELECT id, Start_Date__c FROM inspire1__Checklist_Item__c WHERE inspire1__Project_Task__c =: item.inspire1__Project_Task__c 
                    AND inspire1__Order__c =:(item.inspire1__Order__c + 1) LIMIT 1];

                    if (nextItem != null) {
                        nextItem.Start_Date__c = DateTime.now();
                        itemsToUpdate.add(nextItem);
                    }
                }
            }
        }
        UPDATE itemsToUpdate;
    }
}