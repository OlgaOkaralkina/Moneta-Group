/**
*@author Athene Group LLC
*@date 2017.05
*@group Apex Class - Batch
*@description Trigger handler to calculate the Household ID on create of an Account
*/
trigger Account_Trigger on Account (before insert , after insert , before update , after update , before delete) {
   /* if(CheckRecursive.runOnce())
    {*/
       //Instantiate the handler class
       AccountClientIdIncrementHandler handler = new AccountClientIdIncrementHandler();
       if(Trigger.isInsert && Trigger.isBefore)
        {
            handler.onBeforeInsert(Trigger.new);
        }

   // }

}