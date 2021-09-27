public class CreateCheckBatchRecordForDeliveryService {
    
    @InvocableMethod
    public static List<List<Checks_Paperwork__c>> CheckBatchForDeliveryService(List<List<Checks_Paperwork__c>> checksPaperworkListofList){
                    
        System.debug('checksPaperworkListofList[0].size::::'+checksPaperworkListofList[0].size());
        List<List<Checks_Paperwork__c>> checkPaperworkRecordToUpdatedListOfList = new List<List<Checks_Paperwork__c>>();
        List<Checks_Paperwork__c> checkPaperworkRecordToUpdatedList = new List<Checks_Paperwork__c>();
        Map<String,Checkbatch__c> mapDeliveryServiceTocheckBatch = new Map<String,Checkbatch__c>();
        
        if(checksPaperworkListofList != null && checksPaperworkListofList.size() > 0){
            
            for(List<Checks_Paperwork__c> checksPaperworkList: checksPaperworkListofList){
                for(Checks_Paperwork__c checksPaperworkRecord: checksPaperworkList){
                    if(!mapDeliveryServiceTocheckBatch.containsKey(checksPaperworkRecord.Delivery_Service__c)){
                        mapDeliveryServiceTocheckBatch.put(checksPaperworkRecord.Delivery_Service__c,
                                                          new Checkbatch__c(Address__c = checksPaperworkRecord.Address__c,
                                                     		Delivery_Service__c = checksPaperworkRecord.Delivery_Service__c,
                                                     		Recipient__c = checksPaperworkRecord.Recipient__c ));
                    }
                }
            }
            try{
                INSERT mapDeliveryServiceTocheckBatch.Values();
            }Catch(DmlException e){
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            System.debug('mapDeliveryServiceTocheckBatch.Values().size() : ' + mapDeliveryServiceTocheckBatch.Values().size());
			System.debug('mapDeliveryServiceTocheckBatch.Values() : ' + JSON.serialize(mapDeliveryServiceTocheckBatch.Values()));
            
            for(List<Checks_Paperwork__c> checksPaperworkList : checksPaperworkListofList){
                for(Checks_Paperwork__c checkPaperworkRecord : checksPaperworkList){
                    if(String.isNotBlank(checkPaperworkRecord.Delivery_Service__c)){
                        String tempString = checkPaperworkRecord.Delivery_Service__c;
                        System.debug('tempString : ' + tempString);
                        if((tempString.equalsIgnoreCase('USPS') ||
                            tempString.equalsIgnoreCase('Certified Mail') ||
                            tempString.equalsIgnoreCase('Courier') ||
                            tempString.equalsIgnoreCase('Electronic Deposit') ||
                            tempString.equalsIgnoreCase('Picked up by Team')||
                            tempString.equalsIgnoreCase('Void Check'))){
                                Checkbatch__c checkBatchRecord = mapDeliveryServiceTocheckBatch.get(tempString);
                                checkPaperworkRecordToUpdatedList.add(new Checks_Paperwork__c(Id = checkPaperworkRecord.Id,
                                                                                              Processed_Date__c = System.today(),
                                                                                              Batch_ID__c = checkBatchRecord.Id));
                            }
                    }
                }
            }
            
            System.debug('checkPaperworkRecordToUpdatedList.size():::'+checkPaperworkRecordToUpdatedList.size());
            System.debug('checkPaperworkRecordToUpdatedList : ' + checkPaperworkRecordToUpdatedList);
            if(checkPaperworkRecordToUpdatedList.size() > 0){
                checkPaperworkRecordToUpdatedListOfList.add(checkPaperworkRecordToUpdatedList);    
            }

        }   

        return checkPaperworkRecordToUpdatedListOfList;
    }
}