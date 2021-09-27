/**
*@author Athene Group LLC
*@date 2017.06
*
*@group Apex Class - Test
*
*@description Test Class for UpdateNextInteraldionDateOnLeadbatch batch class
*/

@isTest
private class UpdateNextInteraldionDateOnLeadTest {
	   static testMethod void testUpdateNextInteraldionDateOnLead(){
           // Instantiate the class implementing the Database.Batchable interface.     
           UpdateNextInteractionDateOnLeadBatch Updatedate = new UpdateNextInteractionDateOnLeadBatch();
           
                      //Create a Lead
           Lead ld = new Lead();
           ld.LastName ='Test Lead';
           ld.Company = 'Test Lead';
           ld.Next_Interaction_Date__c = null;
		   ld.Last_interaction_Date__c = null;
           Insert ld;
           
           //Create a task with activity date set for Contact1
           Task tsk1 = new Task(WhoId = ld.Id,Subject = 'call',ActivityDate = date.today(),status = 'Open');
		   Task tsk2 = new Task(status = 'Open',WhoId = ld.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(+2));
		   Task ActvtyHist = new Task(status = 'completed',WhoId = ld.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(-2));
		   Event evt = new Event(WhoId = ld.Id,DurationInMinutes = 60,ActivityDate = date.today().addYears(+2),ActivityDateTime = date.today().addYears(+2),Subject = 'call');
           insert tsk1;
           insert tsk2;
           insert ActvtyHist;
           insert evt;
		   Test.setCreatedDate(tsk1.Id, Datetime.now().addDays(-1));
		   //Test.setCreatedDate(ActvtyHist.Id, Datetime.now().addDays(-4));
		   Test.setCreatedDate(tsk2.Id, Datetime.now().addDays(-1));     
           Test.setCreatedDate(evt.Id, Datetime.now().addDays(-1));

		   		   
		  //Create a Lead
           Lead ld2 = new Lead();
           ld2.LastName ='Test Lead';
           ld2.Company = 'Test Lead';
           ld2.Next_Interaction_Date__c = null;
		   ld2.Last_interaction_Date__c = Datetime.now().addDays(-1);
           Insert ld2;
		   
            //Create a task with activity date set for Lead2
		   Task tsk3 = new Task(status = 'Open',WhoId = ld2.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(+2));
		   Task ActvtyHist2 = new Task(status = 'completed',WhoId = ld2.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(-2));
		   Event evt2 = new Event(WhoId = ld2.Id,DurationInMinutes = 60,ActivityDate = date.today().addYears(+2),ActivityDateTime = date.today().addYears(+2),Subject = 'call');
           insert tsk3;
           insert ActvtyHist2;
           insert evt2;
		   Test.setCreatedDate(tsk3.Id, ld2.Last_interaction_Date__c);
		   //Test.setCreatedDate(ActvtyHist2.Id, Datetime.now().addDays(-4));
           Test.setCreatedDate(evt2.Id, ld2.Last_interaction_Date__c);
           
           
           
           //Create a Lead
           Lead ld3 = new Lead();
           ld3.LastName ='Test Lead';
           ld3.Company = 'Test Lead';
           ld3.Next_Interaction_Date__c = date.today().addYears(+2);
		   ld3.Last_interaction_Date__c = null;
           Insert ld3;
		   
		   //Create a task with activity date set for Lead3
		   Task tsk4 = new Task(status = 'Open',WhoId = ld3.Id,Priority ='Normal',Subject = 'call',ActivityDate = ld3.Next_Interaction_Date__c);
		   Task ActvtyHist3 = new Task(status = 'completed',WhoId = ld3.Id,Priority ='Normal',Subject = 'call',ActivityDate = date.today().addYears(-2));
           insert tsk4;
           insert ActvtyHist3;
		   Test.setCreatedDate(tsk4.Id, Datetime.now().addDays(-1));
		  // Test.setCreatedDate(ActvtyHist3.Id, Datetime.now().addDays(-4));
           Test.startTest();
           // Invoke the Batch class.
           String jobId2 = Database.executeBatch(Updatedate);
           
            // Get the Apex job and verify there are no errors.
            AsyncApexJob aaj2 = [Select JobType, TotalJobItems, JobItemsProcessed, Status,CompletedDate, CreatedDate, NumberOfErrors from AsyncApexJob where Id = :jobId2];
            System.assertEquals(0, aaj2.NumberOfErrors);
           Test.stopTest();
       }     
          
}