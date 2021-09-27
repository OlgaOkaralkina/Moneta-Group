public with sharing class FinancialAccountServiceUtil {
	
	//This method get the API input list and returns a set of unique client Ids
	public static Set<double> getUniqueClientIds(List<FinancialAccountInfo> clientIDsLst, set<string> setInvalidClientIds){
		set<double> setOfUniqueClientIds = new set<double>();
		for(FinancialAccountInfo faInfo :clientIDsLst){
			if(faInfo != null && faInfo.faClientId != null){
				try{
					setOfUniqueClientIds.add(double.valueOf(faInfo.faClientId));
				}
				catch(Exception e){
					setInvalidClientIds.add(string.valueOf(faInfo.faClientId));
				}
			}
		}
		return setOfUniqueClientIds;
	}
	
	
	//This method takes in the final list of ClientId-AccountId & returns the API output wrapper 
	public static List<FinancialAccountInfo> getFinancialInfoFormattedResult(map<string, FinancialAccountInfo> mapClientId2FAInfo){
		List<FinancialAccountInfo> faInfoRecords = new List<FinancialAccountInfo>();
		for(string clientId :mapClientId2FAInfo.KeySet()){
			faInfoRecords.add(mapClientId2FAInfo.get(clientId));
		}
		return faInfoRecords;
	}
	
	
}