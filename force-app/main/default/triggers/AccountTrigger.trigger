/**
*@purpose       : To copy the Orian Sync Fields of Household Account From related Houshold Contact.
*@Created Date  : 07 June 2019
**/
trigger AccountTrigger on Account (before insert, before update) {
    
    if(Trigger.isBefore){

        if(Trigger.isInsert){
          
            AccountTriggerHandler.onBeforeInsert(Trigger.new);  

        }else if(Trigger.isUpdate){
         
            AccountTriggerHandler.onBeforeUpdate(Trigger.oldMap, Trigger.new);
        }
    }
}