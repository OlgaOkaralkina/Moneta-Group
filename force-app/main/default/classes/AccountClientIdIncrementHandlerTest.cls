/**
*@author Athene Group LLC
*@date 2017.06
*
*@group Apex Class - Test
*
*@description Test Class for AccountClientIdIncrementHandler class
*/

@isTest
private class AccountClientIdIncrementHandlerTest {
    static testMethod void testAccountClientIdIncrementHandler(){
        AccountClientIdIncrementHandler tst = new AccountClientIdIncrementHandler();
        Test.starttest();
        List<Account> acclist = new List<Account>();    
        Account acc1 = new Account(name = 'test account');
        Account acc2 = new Account(name = 'test account2');
        acclist.add(acc1);
        acclist.add(acc2);
        tst.onBeforeInsert(acclist);
        Test.stopTest();
    }

}