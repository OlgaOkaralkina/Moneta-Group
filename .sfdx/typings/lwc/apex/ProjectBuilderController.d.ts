declare module "@salesforce/apex/ProjectBuilderController.getProjects" {
  export default function getProjects(param: {parentId: any}): Promise<any>;
}
declare module "@salesforce/apex/ProjectBuilderController.createProject" {
  export default function createProject(param: {projectsByObAccountId: any, masterId: any, parentId: any}): Promise<any>;
}
