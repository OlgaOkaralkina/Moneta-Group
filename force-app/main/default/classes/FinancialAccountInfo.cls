global class FinancialAccountInfo {
	public String faClientId;
	public String primaryOwnerId;
	public String hhOwnerId;
	
	global FinancialAccountInfo(String clientId){
		this.faClientId = clientId;
	}
	    
	global FinancialAccountInfo(String clientId, String accountId, String ownerId){
		this.faClientId = clientId;
		this.primaryOwnerId = accountId;
		this.hhOwnerId = ownerId;
	}
}