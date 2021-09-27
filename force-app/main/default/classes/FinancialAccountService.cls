@RestResource(urlMapping='/FinancialAccountService/*')
global with sharing class FinancialAccountService {

	@HttpPost	
	global static void fetchPrimaryOwnersForClientIds(List<FinancialAccountInfo> clientIDsLst) {
		List<FinancialAccountInfo> faInfoRecords = FinancialAccountServiceHelper.processClientIDs(clientIDsLst);
		String faJSON = JSON.serialize(faInfoRecords);
		RestContext.response.addHeader('Content-Type', 'application/json');
		RestContext.response.responseBody = Blob.valueOf(faJSON);
        //RestContext.response.responseBody = Blob.valueOf('{ "s" : "Hello", "i" : 1234 }');
	}
}