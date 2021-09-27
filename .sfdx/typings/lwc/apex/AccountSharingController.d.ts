declare module "@salesforce/apex/AccountSharingController.checkCurrentUserProfile" {
  export default function checkCurrentUserProfile(): Promise<any>;
}
declare module "@salesforce/apex/AccountSharingController.getcurrentPermissions" {
  export default function getcurrentPermissions(param: {accountId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountSharingController.getRecords" {
  export default function getRecords(param: {sObjectName: any, currentPermissionUsers: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountSharingController.createSharingRecord" {
  export default function createSharingRecord(param: {accountId: any, userType: any, userIds: any, accessType: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountSharingController.deleteShareRecord" {
  export default function deleteShareRecord(param: {accountId: any, strRecordId: any, strUserdId: any}): Promise<any>;
}
declare module "@salesforce/apex/AccountSharingController.updateShareRecord" {
  export default function updateShareRecord(param: {accountId: any, strRecordId: any, strAccessLevel: any, strUserId: any}): Promise<any>;
}
