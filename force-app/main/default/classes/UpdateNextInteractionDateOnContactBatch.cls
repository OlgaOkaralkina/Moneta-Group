/**
*@author Athene Group LLC
*@date 2017.06
*@group Apex Class - Batch
*@description Batch Class to Update Contacts Next and Last interaction date
*/
global class UpdateNextInteractionDateOnContactBatch implements Database.Batchable<sObject> {
    
    // String to hold email address that emails will be sent to. 
    static String emailAddress = MonetaConstants.EmailId;
       
    // The start method is called at the beginning of a sharing recalculation.
    // This method returns a SOQL query locator containing the records to be recalculated. 
    global Database.QueryLocator start(Database.BatchableContext BC){
        //Query Activity date greater than today from openactivities to calculate Next interaction date
        //Query Tasks and Events created date to calculate last interaction date
        return Database.getQueryLocator([SELECT Last_Interaction_Date__c,Next_Interaction_Date__c,id,(SELECT ActivityDate FROM OpenActivities where ActivityDate >= today ORDER BY ActivityDate ASC LIMIT 1),(SELECT CreatedDate FROM Tasks where CreatedDate = yesterday ORDER BY createdDate DESC LIMIT 1),(SELECT CreatedDate FROM events  where CreatedDate = yesterday ORDER BY createdDate DESC LIMIT 1),(SELECT createddate from ActivityHistories where CreatedDate = yesterday ORDER BY createdDate DESC LIMIT 1) FROM Contact]);  
    }
    
    // The executeBatch method is called for each chunk of records returned from start.  
    global void execute(Database.BatchableContext BC, List<sObject> scope){
       
	   // Create a list for the chunk of records passed into method.
        List<Contact> cntList = (List<Contact> ) scope;
        List<Contact> updateContactList = new List<Contact>();
        for(Contact cnt: cntList)
			{
				//List to hold Created dates
				List<Datetime> datelist = new List<Datetime>();
				
				//Date field to Initialize the date comparision
				Datetime Maxdate = Datetime.newInstance(1900, 12, 31, 00, 00, 00);
				
				Datetime lastInteractionDate = cnt.Last_interaction_Date__c;
				Date nextInteractionDate = null;
				System.debug('nextInteractionDate -'+cnt.OpenActivities);
                System.debug('Event created -'+cnt.events);
                System.debug('cnt.tasks[0].CreatedDate -'+cnt.tasks);
                System.debug('cnt.ActivityHistories[0].CreatedDate -'+cnt.ActivityHistories);
				if(!(cnt.OpenActivities).isEmpty())
					{	//If openactivities exist set the next interaction date
						nextInteractionDate = cnt.OpenActivities[0].ActivityDate;
					}
				//NULL check the date fields from activities objects and add date fields to the date list	
				if(!cnt.events.isEmpty() && cnt.events[0].CreatedDate != null)
					{
						System.debug('size: '+cnt.events.size()+' value: '+cnt.events[0].CreatedDate);
						datelist.add(cnt.events[0].CreatedDate);
					}
				 if(!cnt.tasks.isEmpty() && cnt.tasks[0].CreatedDate != null)
					{
							System.debug('size: '+cnt.tasks.size()+' value: '+cnt.tasks[0].CreatedDate);
							datelist.add(cnt.tasks[0].CreatedDate);
					}
				 if(!cnt.ActivityHistories.isEmpty() && cnt.ActivityHistories[0].CreatedDate != null)
					{
						System.debug('size: '+cnt.ActivityHistories.size()+' value: '+cnt.ActivityHistories[0].CreatedDate);
						datelist.add(cnt.ActivityHistories[0].CreatedDate);
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
				if(lastInteractionDate != cnt.Last_interaction_Date__c || nextInteractionDate != cnt.Next_Interaction_Date__c )
				{
					if(lastInteractionDate != cnt.Last_interaction_Date__c && nextInteractionDate != cnt.Next_Interaction_Date__c )
						{
							cnt.Last_interaction_Date__c = lastInteractionDate;
							cnt.Next_Interaction_Date__c = nextInteractionDate;
						} 
					else if(lastInteractionDate != cnt.Last_interaction_Date__c && nextInteractionDate == cnt.Next_Interaction_Date__c )
						{
							cnt.Last_interaction_Date__c = lastInteractionDate;
						}
					else if(lastInteractionDate == cnt.Last_interaction_Date__c && nextInteractionDate != cnt.Next_Interaction_Date__c )
						{
							cnt.Next_Interaction_Date__c = nextInteractionDate;
						}
					updateContactList.add(cnt);
				}

					
			}
        
      //  upsert updateContactList;
    // upsert Contact records
    if(!updateContactList.isEmpty()){
    try {
        update updateContactList;
    
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