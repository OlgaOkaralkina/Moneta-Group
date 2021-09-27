/**
*@author Athene Group LLC
*@date 2017.05
*@group Apex Class - Batch
*@description Batch Class to Update Leads Next interaction date
*/
global class UpdateNextInteractionDateOnLeadBatch implements Database.Batchable<sObject> {
    
    // String to hold email address that emails will be sent to. 
    static String emailAddress = MonetaConstants.EmailId;
       
    // The start method is called at the beginning of a sharing recalculation.
    // This method returns a SOQL query locator containing the records to be recalculated. 
    global Database.QueryLocator start(Database.BatchableContext BC){       
        //Query Activity date greater than today from openactivities to calculate Next interaction date
        //Query Tasks and Events created date to calculate last interaction date
        return Database.getQueryLocator([SELECT Last_Interaction_Date__c,Next_Interaction_Date__c,id,(SELECT ActivityDate FROM OpenActivities where ActivityDate >= today ORDER BY ActivityDate ASC LIMIT 1),(SELECT CreatedDate FROM Tasks where CreatedDate = yesterday ORDER BY createdDate DESC LIMIT 1),(SELECT CreatedDate FROM events where CreatedDate = yesterday ORDER BY createdDate DESC LIMIT 1),(SELECT createddate from ActivityHistories where CreatedDate = yesterday ORDER BY createdDate DESC LIMIT 1) FROM Lead where IsConverted = false]);  
    }
    
    // The executeBatch method is called for each chunk of records returned from start.  
    global void execute(Database.BatchableContext BC, List<sObject> scope){
     
     // Create a list for the chunk of records passed into method.
        List<Lead> leadList = (List<Lead> ) scope;
        List<Lead> updateLeadList = new List<Lead>();
        for(Lead ld: leadList)
            {
                //List to hold Created dates
                List<Datetime> datelist = new List<Datetime>();
                
                //Date field to Initialize the date comparision
                Datetime Maxdate = Datetime.newInstance(1900, 12, 31, 00, 00, 00);
                
                Datetime lastInteractionDate = ld.Last_interaction_Date__c;
                Date nextInteractionDate = null;
                
                if(!(ld.OpenActivities).isEmpty())
                    {  
                        //If openactivities exist set the next interaction date 
                        nextInteractionDate = ld.OpenActivities[0].ActivityDate;
                    }
                //NULL check the date fields from activities objects and add date fields to the date list
                if(ld.events.size()>0 && ld.events[0].CreatedDate != null)
                    {
                        System.debug('size: '+ld.events.size()+' value: '+ld.events[0].CreatedDate);
                        datelist.add(ld.events[0].CreatedDate);
                    }
                 if(ld.tasks.size()>0 && ld.tasks[0].CreatedDate != null)
                    {
                            System.debug('size: '+ld.tasks.size()+' value: '+ld.tasks[0].CreatedDate);
                            datelist.add(ld.tasks[0].CreatedDate);
                    }
                 if(ld.ActivityHistories.size()>0 && ld.ActivityHistories[0].CreatedDate != null)
                    {
                        System.debug('size: '+ld.ActivityHistories.size()+' value: '+ld.ActivityHistories[0].CreatedDate);
                        datelist.add(ld.ActivityHistories[0].CreatedDate);
                    }
                System.debug('date list size: '+datelist.isEmpty());
                //Null check dateList
                if(!datelist.isEmpty())
                    {
                        //Iterate over the dates and calculate the most recent date
                        for(datetime createddate:datelist)
                        {
                            if(createddate !=null && Maxdate <= createddate)
                            Maxdate = createddate;
                        }
                        lastInteractionDate = Maxdate;
                    }
                if(lastInteractionDate != ld.Last_interaction_Date__c || nextInteractionDate != ld.Next_Interaction_Date__c )
                    {
                        if(lastInteractionDate != ld.Last_interaction_Date__c && nextInteractionDate != ld.Next_Interaction_Date__c )
                            {
                                ld.Last_interaction_Date__c = lastInteractionDate;
                                ld.Next_Interaction_Date__c = nextInteractionDate;
                            } 
                        else if(lastInteractionDate != ld.Last_interaction_Date__c && nextInteractionDate == ld.Next_Interaction_Date__c )
                            {
                                ld.Last_interaction_Date__c = lastInteractionDate;
                            }
                        else if(lastInteractionDate == ld.Last_interaction_Date__c && nextInteractionDate != ld.Next_Interaction_Date__c )
                            {
                                ld.Next_Interaction_Date__c = nextInteractionDate;
                            }
                        updateLeadList.add(ld);
                    }
        }
 
      //  upsert updateLeadList;
    // upsert Lead records
    if(updateLeadList.size()>0){
    try {
        update updateLeadList;
    
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }
    }
 }
    // The finish method is called at the end .
    global void finish(Database.BatchableContext BC){  
        // Send an email to the Apex job's submitter notifying of job completion.
     /*  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailAddress}; 
        mail.setToAddresses(toAddresses); 
        mail.setSubject('Next interaction date updated');
        mail.setPlainTextBody
                      ('Next interaction date updated');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
 
}