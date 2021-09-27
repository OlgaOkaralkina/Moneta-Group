/**
*@author Athene Group LLC
*@date 2017.06
*
*@group Apex Class - Test
*
*@description Test Class for UpdateNextInteraldionDateOnLeadbatch batch class
*/

@isTest
public class UpdateNextInteractionDateOnLeadschtest {
        public static testMethod void testschedule()
        {
            Test.StartTest();
            UpdateNextInteractionDateOnLeadsch sh1 = new UpdateNextInteractionDateOnLeadsch();
            String sch = '0 0 23 * * ?'; system.schedule('Test UpdateNextInteractionDateOnLeadsch Check', sch, sh1); 
            Test.stopTest(); 
        }
 }