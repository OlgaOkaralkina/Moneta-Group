({
    TAOST_MESSAGE_TIMEOUT: 2000,
    
    // SET ACCESS PICKLIST VALUES
    getAccessPickList: function (component, event, helper, selectedVAl) {        
        var opts = [
            { value: "Read", label: "Read" },
            { value: "Edit", label: "Read/Write" }
        ];
        component.set("v.accessOptions", opts);
    },
    
    // SET USER_OPTION PICKLIST VALUES
    getUserPickList: function (component, event, helper, selectedVAl) {  
        /*var opts = [
            { value: "User", label: "User" },
            { value: "Group", label: "Public Group" },
            { value: "UserRole", label: "Role" }
        ];*/
        var opts = [
            { value: "User", label: "User" },
            { value: "Group", label: "Public Group" }
        ];
        component.set("v.userSelectionOptions", opts);
        // component.set("v.isShowSpinner", false);
    },
    
    // TO HIDE ERROR MESSAGE SECTION.
    hideErrorMessage: function (component, event, helper, selectedVAl) {
        component.set("v.isShowSpinner", false);
        component.set("v.errorMessage", "");
        component.set("v.isShowError", false);
    },
    
    // TO HIDE SUCCESS MESSAGE SECTION.
    hideSuccessMessage: function (component, event, helper, selectedVAl) {
        component.set("v.isShowSpinner", false);
        component.set("v.successMessage", "");
        component.set("v.isShowSuccess", false);
    },
    
    // SET SELECTED USERS TO ATTRIBUTE
    addSelectedUsers: function (component, event, helper, selectedVAl) {
        // This will contain an array of the "value" attribute of the selected options
        var selectedOptionValue = event.getParam("value");
        component.set("v.selectedUserIds",selectedOptionValue);
        component.set("v.isShowError", false);    
        component.set("v.isShowSpinner", false);
    },
    
    // SET SHAREING ACCESS TYPE TO ATTRIBUTE
    getSharingAccessType: function (component, event, helper, selectedVAl) {
        if(selectedVAl != null || selectedVAl != undefined || selectedVAl != '') {
            component.set("v.accessType",selectedVAl);
            component.set("v.isShowSpinner", false);
        }
    },    
    
    // TO CLOSE QUICK ACTION MODAL.
    closeModal: function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },
    
    // TO OPEN/CLOSE SECTIONS.
    sectionClick: function(component, event, helper) {
        var val = event.getSource().get("v.ariaLabel");
        component.set("v." + val, !component.get("v."+val));
        component.set("v.isShowSpinner", false);
    },
    
    // NEVIGATE ON USER DETAIL PAGE
    redirectOnUserRecord : function(component, event, helper) {         
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": event.target.id,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    
    // GIVE READ ACCESS TO USER AFTER CLICK ON READ BUTTON
    giveReadtAccess : function(component, event, helper) {    
        var currentButtonData = event.getSource().get("v.ariaLabel");
        var array = currentButtonData.split(" ");
        var accessLavel = array[0];
        var recordId = array[1];
        var userId = array[2]
        helper.updateShareRecord(component, event, helper, recordId, accessLavel, userId);
    },
    
    // GIVE READ/EDIT ACCESS TO USER AFTER CLICK ON READ/EDIT BUTTON
    giveEditAccess: function (component, event, helper) {
        var currentButtonData = event.getSource().get("v.ariaLabel");
        var array = currentButtonData.split(" ");
        var accessLavel = array[0];
        var recordId = array[1];
        var userId = array[2]
        helper.updateShareRecord(component, event, helper, recordId, accessLavel, userId);
    },
    
    // REMOVE ACCESS AFTER CLICK ON REMOVE BUTTON
    removeAccess: function (component, event, helper) {
        var currentButtonData = event.getSource().get("v.ariaLabel");
        var array = currentButtonData.split(" ");
        var recordId = array[0];
        var userID = array[1];
        helper.deleteShareRecord(component, event, helper, recordId, userID);
    },
    
    // TO GET CURRENT RECORD PERMISSIONS 
    getcurrentPermissions: function(component, event, helper) {   
        // CALL APEX CONTROLLER METHOD
        (this).doCallout(component, 'c.getcurrentPermissions', {
            "accountId" : component.get("v.recordId")
        }, function(response) {
            let state = response.getState();
            if (state == "SUCCESS") {
                if(response.getReturnValue().length > 0) {
                    component.set('v.data', response.getReturnValue());               
                    component.set("v.isShowSpinner", false);
                } else {
                    var errorMsg = response.getReturnValue();
                    helper.tostMessage(component, event, helper, null, errorMsg);                    
                }
            } else {                
                helper.tostMessage(component, event, helper, null, state);
            }            
        });
    },
    
    checkCurrentUserProfile : function(component, event, helper) {        
        // CALL APEX CONTROLLER METHOD
        (this).doCallout(component, 'c.checkCurrentUserProfile', {
            
        }, function(response) {
            let state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue() == false) {
                    this.closeModal(component, event, helper);
                    helper.showToast('Error', 'Error', "Insufficient privileges, please contact your System Administrator to modify sharing settings");
                }                
            } else {
                this.closeModal(component, event, helper);
                helper.showToast('Error', 'Error', "Insufficient privileges, please contact your System Administrator to modify sharing settings");
            }
        });
        
    },
    
    // TO UPDATE SELECTED USER'S ACCESS PERMISSION
    updateShareRecord : function(component, event, helper, recordId, accessLavel, userId) {        
        // CALL APEX CONTROLLER METHOD
        (this).doCallout(component, 'c.updateShareRecord', {
            "accountId" : component.get("v.recordId"),
            "strRecordId" : recordId,
            "strAccessLevel" : accessLavel,
            "strUserId" : userId
        }, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == 'SUCCESS') {
                    helper.tostMessage(component, event, helper, "User Access Changed", null);
                    helper.getcurrentPermissions(component, event, helper);
                } else {
                    var errorMsg = response.getReturnValue();
                    helper.tostMessage(component, event, helper, null, errorMsg);
                }               
            } else {
                helper.tostMessage(component, event, helper, null, state);
                var errorMsg = response.getReturnValue();
                helper.tostMessage(component, event, helper, null, errorMsg);
            }
        });
    },
    
    deleteShareRecord : function(component, event, helper, recordId, userID) {
        //var deleteRecordId = row.shareRecordId;
        
        // CALL APEX CONTROLLER METHOD
        (this).doCallout(component, 'c.deleteShareRecord', {
            "accountId" : component.get("v.recordId"),
            "strRecordId" : recordId,
            "strUserdId" : userID
        }, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {                
                helper.getcurrentPermissions(component, event, helper);
                helper.tostMessage(component, event, helper, "User Access Removed", null);
            } else {
                var errorMsg = response.getReturnValue();
                helper.tostMessage(component, event, helper, null, errorMsg);
            }
        });
    },
    
    // CALL THIS METHOD WHEN USER TYPE CHANGED LIKE AS 'USER, PUBLIC GROUP, ROLE'
    changeUserType: function (component, event, helper, sObjectName) {
        component.set("v.isShowSpinner", true);
        if(sObjectName != null && sObjectName != undefined && sObjectName != '') {  
            // CALL APEX CONTROLLER METHOD
            (this).doCallout(component, 'c.getRecords', {
                "sObjectName" : sObjectName,
                "currentPermissionUsers" : component.get("v.data")
            }, function(response) {
                let state = response.getState();
                if (state === "SUCCESS") {   
                    if(response.getReturnValue().length > 0) {
                        var users = [];
                        for (var count = 0; count < response.getReturnValue().length; count++) {
                            if(response.getReturnValue()[count].Name != null &&
                               response.getReturnValue()[count].Name != undefined &&
                               response.getReturnValue()[count].Name != '') {
                                var item = {
                                    "label": response.getReturnValue()[count].Name,
                                    "value": response.getReturnValue()[count].Id,
                                };
                                users.push(item);
                            }                        
                        }
                        component.set("v.userList",users);
                        component.set("v.isSobject",true);
                        component.set("v.userType",sObjectName);
                        component.set("v.isAccessShow",true);
                        component.set("v.isShowError", false);
                        component.set("v.isShowSpinner", false);
                    } else {
                        var errorMsg = response.getReturnValue();
                        helper.tostMessage(component, event, helper, null, errorMsg);
                    }
                } else {
                    helper.tostMessage(component, event, helper, null, state);
                }
            });
        } else {
            component.set("v.userList",'');
            component.set("v.isSobject",false);
            component.set("v.isAccessShow",false);
            component.set("v.isShowSpinner", false);
        }
    },
    
    // CRETAE NEW SHARE ACCESS_RECORD 
    shareAccess: function (component, event, helper, selectedVAl) {
        var userType = component.get("v.userType");
        var selectedUserIds = component.get("v.selectedUserIds");
        var accessType = component.get("v.accessType");
        var isValid = true;
        var errorString = '';
        
        if(userType == null || userType == undefined || userType == '') { 
            isValid = false;
        } 
        
        if(selectedUserIds == null || selectedUserIds == undefined || selectedUserIds.length == 0) {
            isValid = false;
            component.set("v.errorMessage", "");
            helper.tostMessage(component, event, helper, null, "Please select required fields.");
        } 
        
       /* if(selectedUserIds.length != 0 && selectedUserIds.length > 5) {
            isValid = false;     
            helper.tostMessage(component, event, helper, null, "Please select maximum 5 "+userType+"s at time");
        } */
        
        if(accessType == null || accessType == undefined || accessType == '') {
            component.set("v.errorMessage", "");
            isValid = false; 
            /*var errorMsg = component.get("v.errorMessage");
            if(errorMsg == null || errorMsg == undefined || errorMsg == '') {
                component.set("v.errorMessage",'');
            } */
            helper.tostMessage(component, event, helper, null, "Please select required fields.");
        } 
        
        // CALL APEX CONTROLLER METHOD
        if(isValid) {
            (this).doCallout(component, 'c.createSharingRecord', {
                "accountId" : component.get("v.recordId"),
                "userType" : userType,
                "userIds" : selectedUserIds,
                "accessType" : accessType                
            }, function(response) {
                let state = response.getState();
                if(state === "SUCCESS") 
                    if(response.getReturnValue() ==="SUCCESS") {
                        this.closeModal(component, event, helper);
                        helper.showToast('Success', 'success', "Record Share");
                        component.set("v.isShowSpinner", false);
                    } else {
                        component.set("v.isShowSpinner", false);
                        isValid = false;
                        var errorMsg = response.getReturnValue();
                        helper.tostMessage(component, event, helper, null, errorMsg);
                    } else {
                        helper.tostMessage(component, event, helper, null, state);
                    }
            });
        }
    },
    
    // TO MAKE CALLOUT TO SERVER METHOD.
    doCallout: function(component, methodName, params, callBackFunction) {
        var action = component.get(methodName);
        action.setParams(params);
        action.setCallback(this, callBackFunction);
        $A.enqueueAction(action);
    },
    
    // TO SHOW TOAST MESSAGES.
    showToast : function(title, type, message) {
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        showToast.fire();
    },
    
    // TO SHOW TOAST MESSAGES ON QUICK ACTION.
    tostMessage : function(component, event, helper, successMsg, errorMsg) {
        if(successMsg != null && successMsg != undefined && successMsg != '') {
            component.set("v.successMessage", successMsg); 
        } else if(errorMsg != null && errorMsg != undefined && errorMsg != '') {
            component.set("v.errorMessage", errorMsg);
        }
        
        component.set("v.isShowSpinner", false);
        
        /*window.setTimeout(function() {            
            component.set("v.errorMessage", '');
            component.set("v.successMessage", '');
        }, this.TAOST_MESSAGE_TIMEOUT);*/
    },
})