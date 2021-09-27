/**
*@author Athene Group LLC
*@date 2017.06
*
*@group Apex Class - Test
*
*@description Test Class for UpdateNextInteractionDateOnContactTest batch class
*/

@isTest
private class UpdateNextInteractionDateOnContactTest {
	   static testMethod void testUpdateNextInteractionDateOnContact(){
            // Instantiate the class implementing the Database.Batchable interface.     
           UpdateNextInteractionDateOnContactBatch updateInteractionDate = new UpdateNextInteractionDateOnContactBatch();

			//Create a contact
           Contact ct = new Contact();
           ct.LastName = 'Test Contact 1';
           ct.Next_Interaction_Date__c = null;
		   ct.Last_interaction_Date__c = null;
           Insert ct;
           
           //Create a task with activity date set for Contact1
           Task tsk1 = new Task(WhoId = ct.Id,Subject = 'call',ActivityDate = date.today(),status = 'Open');
		   Task tsk2 = new Task(status = 'Open',WhoId = ct.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(+2));
		   Task ActvtyHist = new Task(status = 'completed',WhoId = ct.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(-2));
		   Event evt = new Event(WhoId = ct.Id,DurationInMinutes = 60,ActivityDate = date.today().addYears(+2),ActivityDateTime = date.today().addYears(+2),Subject = 'call');
           insert tsk1;
           insert tsk2;
           insert ActvtyHist;
           insert evt;
		   Test.setCreatedDate(tsk1.Id, Datetime.now().addDays(-1));
		   //Test.setCreatedDate(ActvtyHist.Id, Datetime.now().addDays(-4));
		   Test.setCreatedDate(tsk2.Id, Datetime.now().addDays(-1));     
           Test.setCreatedDate(evt.Id, Datetime.now().addDays(-1));

		   		   
		   Contact ct2 = new Contact();
           ct2.LastName = 'Test Contact 2';
		   ct2.Next_Interaction_Date__c = null;
		   ct2.Last_interaction_Date__c = Datetime.now().addDays(-1);
           Insert ct2;
		   
            //Create a task with activity date set for Contact2
		   Task tsk3 = new Task(status = 'Open',WhoId = ct2.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(+2));
		   Task ActvtyHist2 = new Task(status = 'completed',WhoId = ct2.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(-2));
		   Event evt2 = new Event(WhoId = ct2.Id,DurationInMinutes = 60,ActivityDate = date.today().addYears(+2),ActivityDateTime = date.today().addYears(+2),Subject = 'call');
           insert tsk3;
           insert ActvtyHist2;
           insert evt2;
		   Test.setCreatedDate(tsk3.Id, ct2.Last_interaction_Date__c);
		   //Test.setCreatedDate(ActvtyHist2.Id, Datetime.now().addDays(-4));
           Test.setCreatedDate(evt2.Id, ct2.Last_interaction_Date__c);
           
           
           
           Contact ct3 = new Contact();
           ct3.LastName = 'Test Contact 2';
		   ct3.Next_Interaction_Date__c = date.today().addYears(+2);
		   ct3.Last_interaction_Date__c = null;
           Insert ct3;
		   
		   //Create a task with activity date set for Contact3
		   Task tsk4 = new Task(status = 'Open',WhoId = ct3.Id,Priority ='Normal',Subject = 'call',ActivityDate = ct3.Next_Interaction_Date__c);
		   Task ActvtyHist3 = new Task(status = 'completed',WhoId = ct3.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(-2));
           insert tsk4;
           insert ActvtyHist3;
		   Test.setCreatedDate(tsk4.Id, Datetime.now().addDays(-1));
		  // Test.setCreatedDate(ActvtyHist3.Id, Datetime.now().addDays(-4));
		   
		   Test.startTest();
             // Invoke the Batch class.
             String jobId2 = Database.executeBatch(updateInteractionDate);

               // Get the Apex job and verify there are no errors.
      		  AsyncApexJob aaj2 = [Select JobType, TotalJobItems, JobItemsProcessed, Status,CompletedDate, CreatedDate, NumberOfErrors from AsyncApexJob where Id = :jobId2];
               System.assertEquals(0, aaj2.NumberOfErrors);
           Test.stopTest();
       }     
          
}