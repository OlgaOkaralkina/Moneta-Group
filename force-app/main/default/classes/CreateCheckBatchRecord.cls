public class CreateCheckBatchRecord {
	@InvocableMethod
    public static List<List<Checks_Paperwork__c>> CheckBatch(List<List<Checks_Paperwork__c>> checksPaperworkListofList){
                    
        List<Checks_Paperwork__c> checkPaperworkRecordToUpdatedList = new List<Checks_Paperwork__c>();
        List<List<Checks_Paperwork__c>> checkPaperworkRecordToUpdatedListOfList = new List<List<Checks_Paperwork__c>>();
        
        if(checksPaperworkListofList != null && checksPaperworkListofList.size() > 0){
            
            System.debug('checksPaperworkListofList inside CreateCheckBatchRecord::::'+checksPaperworkListofList);
            System.debug('checksPaperworkListofList[0].size::::'+checksPaperworkListofList[0].size());
            List<Checkbatch__c> checkBatchList = new List<Checkbatch__c>();        
            
            List<Checks_Paperwork__c> checksPaperworkListForFurtherProcessing = new List<Checks_Paperwork__c>();
            set<String> checksPaperworkAddress_DeliveryServiceSet = new set<String>();
            Map<String,String> checksPaperworkMap = new Map<String,string>();
            String tempStr;
            
            for(List<Checks_Paperwork__c> checksPaperworkList : checksPaperworkListofList){
                checksPaperworkListForFurtherProcessing.addAll(checksPaperworkList);
                System.debug('checksPaperworkListForFurtherProcessing : ' + checksPaperworkListForFurtherProcessing);
                for(Checks_Paperwork__c checkPaperworkRecord : checksPaperworkList){
                    
                    if(String.isNotBlank(checkPaperworkRecord.Address__c) && String.isNotBlank(checkPaperworkRecord.Delivery_Service__c)){
                        
                        tempStr = checkPaperworkRecord.Address__c + '@' + checkPaperworkRecord.Delivery_Service__c;
                        if(!checksPaperworkAddress_DeliveryServiceSet.contains(tempStr)){
                            
                            checksPaperworkAddress_DeliveryServiceSet.add(tempStr);
                            checkBatchList.add(new Checkbatch__c(Address__c = checkPaperworkRecord.Address__c,
                                                                 Delivery_Service__c = checkPaperworkRecord.Delivery_Service__c,
                                                                 Recipient__c = checkPaperworkRecord.Recipient__c ));
                        }  
                    } 
                }
            }
            if(checkBatchList.size() > 0){
                //checkBatchListofList.add(checkBatchList) ;
                insert checkBatchList;
            }
            System.debug('checkBatchList.size() : ' + checkBatchList.size());
            System.debug('checkBatchList : ' + JSON.serializePretty(checkBatchList) );
            
            for(Checkbatch__c checkBatchRecord :checkBatchList){            
                
                for(Checks_Paperwork__c checkPaperworkRecord: checksPaperworkListForFurtherProcessing){
                    
                    if(checkPaperworkRecord.Address__c == checkBatchRecord.Address__c){
                        
                        String tempString = checkPaperworkRecord.Delivery_Service__c;
                        if((tempString.equalsIgnoreCase('UPS Overnight') ||
                            tempString.equalsIgnoreCase('UPS 2 Day Shipping') ||
                            tempString.equalsIgnoreCase('FedEx') ||
                            tempString.equalsIgnoreCase('UPS Ground')) && tempString.equals(checkBatchRecord.Delivery_Service__c)){
                                
                                checkPaperworkRecordToUpdatedList.add(new Checks_Paperwork__c(Id = checkPaperworkRecord.Id,
                                                                                              Processed_Date__c = System.today(),
                                                                                              Batch_ID__c = checkBatchRecord.Id));                                                      
                            }
                    }
                }
            }
            
            System.debug('checkPaperworkRecordToUpdatedList.size():::'+checkPaperworkRecordToUpdatedList.size());
            
            if(checkPaperworkRecordToUpdatedList.size() > 0){
                checkPaperworkRecordToUpdatedListOfList.add(checkPaperworkRecordToUpdatedList);    
            }
            System.debug('checkPaperworkRecordToUpdatedListOfList.size():::'+checkPaperworkRecordToUpdatedListOfList.size());

        }
        return checkPaperworkRecordToUpdatedListOfList;
    }
}