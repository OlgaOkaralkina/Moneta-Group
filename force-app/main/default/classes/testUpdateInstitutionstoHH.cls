//Execution:
//Id batchInstanceId = Database.executeBatch(new testUpdateContact2('0031K00002oUF64QAG,0031K00002oUF65QAG,0031K00002sCHBgQAO,0031K00002zvPsWQAU'), 1);
//system.debug(batchInstanceId);


global class testUpdateInstitutionstoHH implements Database.Batchable<sObject>{
string strAccIDList;
    
   public testUpdateInstitutionstoHH(String strAccs){
             strAccIDList=strAccs;
   }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        List <ID> lstID = strAccIDList.split(',');
        return Database.getQueryLocator([Select FinServ__SourceSystemId__c, Name from Account where ID in :lstID and RecordTypeId <> '01241000000v2V3AAI']);
    }
    
    global void execute(Database.BatchableContext bc, List<Account> lAcc) {
        for (Account acct:lAcc) {
            changeTypeToInst(acct);
            FA2Brooke(acct);
            Contact2Primary(acct);
            createOrionContact(acct);
            FA2OrionContact(acct);
            changeNameInst(acct);
        }
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
    
    private static void changeTypeToInst(Account acct){
        if (acct.FinServ__SourceSystemId__c !=null)   
            acct.FinServ__SourceSystemId__c  = 'H' + 
            acct.FinServ__SourceSystemId__c.Right(acct.FinServ__SourceSystemId__c.length()-1 );
        acct.FinServ__Notes__c = acct.Name;
        acct.RecordTypeId = '01241000000v2V3AAI';
        
    }
    
    
    private static void FA2Brooke(Account acct){
        List<FinServ__FinancialAccount__c> FAcctAssign;
        FAcctAssign = [Select FinServ__Household__c, FinServ__PrimaryOwner__c from FinServ__FinancialAccount__c where FinServ__PrimaryOwner__c =: acct.ID];

        for(FinServ__FinancialAccount__c facct:FAcctAssign){            
            facct.FinServ__Address1__c  = acct.ID;
            //Assign to Brooke's HH
            facct.FinServ__PrimaryOwner__c = '0014100001IwShfAAF';
            facct.FinServ__Household__c = '0014100001IwShfAAF';            
        }
        update FAcctAssign;        
    }
    
    private static void Contact2Primary(Account acct){
        List<AccountContactRelation> acrList;
        acrList = [select ID, ContactID, Roles from AccountContactRelation where AccountId =: acct.ID and ContactID =: acct.Head_of_Household__c];
        
        for (AccountContactRelation acr:acrList){            
            //acr.FinServ__PrimaryGroup__c = true; No need for adding to Primary Group
            if (acr.Roles != null)
                if (!acr.Roles.contains('Primary'))
                acr.Roles = acr.Roles + ';Primary';
            
            if (acr.Roles == null)
                acr.Roles = 'Primary';            
        }
        update acrList;        
    }
    
    private static void createOrionContact(Account acct){
        List <Contact> conList;
        List<AccountContactRelation> acrList;
        Contact con;
        
        conList = new List<Contact>();

        acrList = [select ID, ContactID, Roles from AccountContactRelation where AccountId =: acct.ID and Roles = 'Orion Integration Contact'];
        if(acrList.size() == 0) {
            //Might not need Comment__c = acct.Id
            if (acct.FinServ__SourceSystemId__c !=null)   
                con = new Contact(FirstName = 'Orion Integration', LastName = acct.FinServ__Notes__c.Left(50), Team__c = acct.Team__c, 
                                  Contact_Type__c = 'Orion Integration Contact', Comment__c = acct.Id, OwnerId = acct.OwnerId,
                                  FinServ__SourceSystemId__c= acct.FinServ__SourceSystemId__c.Right(acct.FinServ__SourceSystemId__c.length()-1 ));
            else
                con = new Contact(FirstName = 'Orion Integration', LastName = acct.FinServ__Notes__c.Left(50), Team__c = acct.Team__c, 
                                  Contact_Type__c = 'Orion Integration Contact', Comment__c = acct.Id, OwnerId = acct.OwnerId);    
            upsert con;
            
            //Create Relation with Orion Contact
            AccountContactRelation acr = new AccountContactRelation(AccountId = acct.ID, ContactId=con.ID, FinServ__PrimaryGroup__c=TRUE, Roles='Orion Integration Contact');
            upsert acr;
        }
    }
    
    private static void FA2OrionContact(Account acct){
        // 1.Put Financial Accounts back to Orion+HH, only for those that are still attached to Brooke's Orion 0014100001IwShfAAF.
        List<FinServ__FinancialAccount__c> FAcctAssign;
        Contact con;
        
        FAcctAssign = [Select FinServ__Household__c, FinServ__PrimaryOwner__c, FinServ__Address1__c from FinServ__FinancialAccount__c where FinServ__Address1__c  =: acct.ID and FinServ__PrimaryOwner__c = '0014100001IwShfAAF'];
        
        con = [Select ID, AccountID from Contact where ID in (Select ContactID from AccountContactRelation where AccountID = :acct.id and Roles='Orion Integration Contact')];
        for(FinServ__FinancialAccount__c facct:FAcctAssign){
            facct.FinServ__PrimaryOwner__c = con.AccountId;     //Replace with Orion Account ID            
        }
        update FAcctAssign;
        
        //Update Orion Account with Source Sys ID
        Account ornAcct = [Select FinServ__SourceSystemId__c, Name, FinServ__Notes__c, Team__c, OwnerId from Account where ID=:con.AccountID];
        ornAcct.FinServ__SourceSystemId__c = con.FinServ__SourceSystemId__c; 
        update ornAcct;
    }
    
    private static void changeNameInst(Account acct){
        acct.Name = acct.FinServ__Notes__c;
        update acct;        
    }
    
}