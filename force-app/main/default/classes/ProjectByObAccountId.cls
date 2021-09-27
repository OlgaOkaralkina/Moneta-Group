public with sharing class ProjectByObAccountId {
    @AuraEnabled
    public Id ObAccountId { get; set; }
    
    @AuraEnabled
    public inspire1__Project__c Project { get; set; }

    public ProjectByObAccountId(Id obAccountId, inspire1__Project__c project) {
        this.ObAccountId = obAccountId;
        this.Project = project;
    }

    public ProjectByObAccountId() {
    }
}