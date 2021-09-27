({
    doInit: function(component, event, helper) {
       
        // CALL HELEPER METHOD 
        helper.checkCurrentUserProfile(component, event, helper); 
        
        component.set("v.isShowSpinner", true);
        
        // CALL HELEPER METHOD 
        helper.getAccessPickList(component, event, helper); 
        
        // CALL HELEPER METHOD 
        helper.getUserPickList(component, event, helper);
        
        // CALL HELEPER METHOD 
        helper.getcurrentPermissions(component, event, helper);
    },
    
    // ONCHANGE DUALLISTBOX 
    addSelectedUsers : function (component, event, helper) {
        component.set("v.isShowSpinner", true);
        helper.addSelectedUsers(component, event, helper);
    },
    
    // ONCHANGE ACCESS 
    getSharingAccessType : function(component, event, helper) {
        var selectedAccessType =  event.getSource().get("v.value");    
        component.set("v.isShowSpinner", true);
        helper.getSharingAccessType(component, event, helper, selectedAccessType);
    },
    
    // ONCLICK SHARE BUTTON 
    shareAccess : function(component, event, helper) {
        component.set("v.isShowSpinner", true);
        helper.shareAccess(component, event, helper);
    },
    
    // ONCHANGE USER_TYPE 
    changeUserType: function (component, event, helper) {
        component.set("v.isShowSpinner", true);
        var sObjectName =  event.getSource().get("v.value");    
        helper.changeUserType(component, event, helper, sObjectName);
    },
    
    // TO OPEN/CLOSE SECTIONS.
    sectionClick: function(component, event, helper) {
        component.set("v.isShowSpinner", true);
        helper.sectionClick(component, event, helper);
    },
    
    // TO CLOSE QUICK ACTION MODAL.
    closeModal: function(component, event, helper) {
        component.set("v.isShowSpinner", true);
        helper.closeModal(component, event, helper);
    },
    
    // TO HIDE ERROR MWSSAGE SECTION
    hideErrorMessage: function(component, event, helper) {
        //component.set("v.isShowSpinner", true);
        helper.hideErrorMessage(component, event, helper);        
    },
    
    // TO HIDE SUCCESS MWSSAGE SECTION
    hideSuccessMessage: function(component, event, helper) {
        //component.set("v.isShowSpinner", true);
        helper.hideSuccessMessage(component, event, helper);        
    },
    
    // ONCLICK REMOVE BUTTON
    handleRowAction: function (component, event, helper){
        component.set("v.isShowSpinner", true);
        helper.handleRowAction(component, event, helper);
    },
    
    // ONCLICK READ BUTTON
    giveReadtAccess: function (component, event, helper){
        component.set("v.isShowSpinner", true);
        helper.giveReadtAccess(component, event, helper);
    },
    
    // ONCLICK READ/EDIT BUTTON
    giveEditAccess: function (component, event, helper){
        component.set("v.isShowSpinner", true);
        helper.giveEditAccess(component, event, helper);
    },
    
    // ONCLICK DELETE BUTTON
    removeAccess: function (component, event, helper){
        component.set("v.isShowSpinner", true);
        helper.removeAccess(component, event, helper);
    },
    
    // OONCLICK USER NAME
    redirectOnUserRecord: function (component, event, helper){
        component.set("v.isShowSpinner", true);
       helper.redirectOnUserRecord(component, event, helper);
    },
})