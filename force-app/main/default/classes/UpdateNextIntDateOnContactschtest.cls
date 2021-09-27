/**
*@author Athene Group LLC
*@date 2017.06
*
*@group Apex Class - Test
*
*@description Test Class for UpdateNextIntDateOnContactschtest batch class
*/

@isTest
public class UpdateNextIntDateOnContactschtest {
        public static testMethod void testschedule()
        {
            Test.StartTest();
            UpdateNextInteractionDateOnContactsch sh1 = new UpdateNextInteractionDateOnContactsch();
            String sch = '0 0 23 * * ?'; system.schedule('Test UpdateNextInteractionDateOnContactsch Check', sch, sh1); 
            Test.stopTest(); 
        }
 }