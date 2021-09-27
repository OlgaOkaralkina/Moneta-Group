/**
*@author Athene Group LLC
*@date 2017.05
*@group Apex Class - Scheduler
*@description Schedule Batch Class to update contacts
*/

global class UpdateNextInteractionDateOnContactsch implements schedulable
{
    public void execute(SchedulableContext sc)
    {
    UpdateNextInteractionDateOnContactBatch b = new UpdateNextInteractionDateOnContactBatch();
    database.executebatch(b, 500);
    }
}