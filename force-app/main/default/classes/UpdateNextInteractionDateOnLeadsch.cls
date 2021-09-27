/**
*@author Athene Group LLC
*@date 2017.05
*@group Apex Class - Scheduler
*@description Schedule Batch Class to update Leads
*/

global class UpdateNextInteractionDateOnLeadsch implements schedulable
{
    public void execute(SchedulableContext sc)
    {
    UpdateNextInteractionDateOnLeadBatch b = new UpdateNextInteractionDateOnLeadBatch();
    database.executebatch(b, 500);
    }
}