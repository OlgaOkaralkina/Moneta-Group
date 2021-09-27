/*
* @purpose : This is trigger for accountcontactrelationship
* @createdDate : 19 Nov 2018
* @createdBy	: Navin (Dreamwares)
*/ 
trigger AccountContactRelationshipDeleteTrigger on AccountContactRelation (before delete) {
    AccConRelationshipDeleteHelper.updateAccount(Trigger.old);
}