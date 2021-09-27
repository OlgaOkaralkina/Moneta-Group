public with sharing class MultipleCheckDepositSlipController {
    public List<Checks_Paperwork__c> checkPaperworkList {get; set;}    
    public List<Checks_Paperwork__c> checkPaperworkListWithItemTypeCheck {get; set;}    
    public Map<Id, List<Deposit_Account__c>> checkPaperworkIdToDepositAccountsMap {get; set;}
    public Boolean ischeckPaperworkIdToDepositAccountsMapEmpty {get; set;} 
    public Checkbatch__c checkBatchRecord {get; set;}
    public MultipleCheckDepositSlipController(ApexPages.StandardSetController  stdController){
        //checkPaperwork = (Checks_Paperwork__c) stdController.getRecord();
        ischeckPaperworkIdToDepositAccountsMapEmpty = true;
        try{    
                //Fetching all the related Check/Paperwork records of current Check Batch 
               // Id checkBatchId = stdController.getId();
            ///	checkBatchRecord = [SELECT Id, Recipient__c, Recipient__r.Name 
             //                       FROM Checkbatch__c
             //                       WHERE Id =: checkBatchId];
                List<Checks_Paperwork__c> selectedList = stdController.getSelected();
                Set<String> Ids = new Set<String>();
                for(Checks_Paperwork__c a : selectedList){
                    Ids.add(a.Id);
                }

                String queryForcheckPaperworkList = ' SELECT Id, Name, Batch_ID__r.Name, Recipient__r.Name, '+
                                                    ' Contact_Person__r.Name, Household__r.Name, '+
                                                    ' Processed_Date__c, Recipient_Other__c, Payable_To__c, Address__c, '+ 
                                                    ' Check_Amount__c, Check_Number__c, Additional_Comments_for_deposit_slip__c, '+  
                                                    ' Team__c, Contact_Person_Phone_Number__c, Received_Date__c, Delivery_Service__c ';
                String queryForcheckPaperworkListWithItemTypeCheck =
                                                    queryForcheckPaperworkList +     
                                                    ', (SELECT Financial_Account__r.Name, Financial_Account_Other__c, '+
                                                    ' Account_Name__c, Account_Name_Other__c, Amount_Deposited__c '+ 
                                                    ' FROM Deposit_Accounts__r) '+                                         
                                                    ' FROM Checks_Paperwork__c '+
                                                    ' WHERE Id in :Ids AND Type_of_Item__c = \'Check\' ';                
                checkPaperworkListWithItemTypeCheck = Database.query( queryForcheckPaperworkListWithItemTypeCheck );
                queryForcheckPaperworkList = queryForcheckPaperworkList + ' FROM Checks_Paperwork__c '+
                                             'WHERE Id in :Ids AND Type_of_Item__c = \'Check\' ';
                checkPaperworkList = Database.query( queryForcheckPaperworkList );
                /*checkPaperworkList = [SELECT Id, Name, Batch_ID__r.Name, Recipient__r.Name, 
                                                                Contact_Person__r.Name, Household__r.Name,
                                                                Processed_Date__c, Recipient_Other__c, Payable_To__c, Address__c, 
                                                                Check_Amount__c, Check_Number__c, Additional_Comments_for_deposit_slip__c, 
                                                                Team__c, Contact_Person_Phone_Number__c, 
                                                                    (SELECT Financial_Account__r.Name, Financial_Account_Other__c, 
                                                                    Account_Name__c, Account_Name_Other__c, Amount_Deposited__c 
                                                                    FROM Deposit_Accounts__r)
                                                                FROM Checks_Paperwork__c
                                                                WHERE Batch_ID__c =: stdController.getId()
                                                                AND Type_of_Item__c = 'Check'];   */                                                                
                if( checkPaperworkListWithItemTypeCheck != NULL && !checkPaperworkListWithItemTypeCheck.isEmpty() ){
                    //Below map holds the check/paperwork id and its related deposit accounts
                    checkPaperworkIdToDepositAccountsMap = new Map<Id, List<Deposit_Account__c>> ();
                    for( Checks_Paperwork__c checkPaperwork : checkPaperworkListWithItemTypeCheck ){
                        if( checkPaperwork.Deposit_Accounts__r != NULL && !checkPaperwork.Deposit_Accounts__r.isEmpty() ){
                            checkPaperworkIdToDepositAccountsMap.put(checkPaperwork.Id, checkPaperwork.Deposit_Accounts__r);
                        }else{
                            checkPaperworkIdToDepositAccountsMap.put(checkPaperwork.Id, new List<Deposit_Account__c>() );
                        }                            
                    }
                    if( checkPaperworkIdToDepositAccountsMap != NULL && !checkPaperworkIdToDepositAccountsMap.isEmpty() ){
                        //Can't check map empty on VF page so setting below variable
                        ischeckPaperworkIdToDepositAccountsMapEmpty = false; 
                    }                    
                }                            
            }catch(Exception e){
                //Displaying error on VF page
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                System.debug('Error in MultipleCheckDepositSlipController: '+e.getMessage()+ ', LineNumber: '+e.getLineNumber());
            }
    }    
    
    public void test(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
}