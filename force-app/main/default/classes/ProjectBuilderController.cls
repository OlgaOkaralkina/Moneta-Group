public with sharing class ProjectBuilderController {
    @AuraEnabled
    public static ProjectByObAccountId[] getProjects(Id parentId) {
        List<OB_Account__c> obas = [SELECT Id, Account_Type__c, Custodian__c FROM OB_Account__c 
            WHERE Onboarding_Request__c = :parentId];

        Set<String> accountTypes = getValueSet(obas, 'Account_Type__c');
        Set<String> custodians = getValueSet(obas, 'Custodian__c');

        List<Account_Template_Mapping__c> atms = [SELECT Id, Account_Type__c, Project_Template__c, Custodian__c FROM Account_Template_Mapping__c
            WHERE Account_Type__c in :accountTypes AND Custodian__c in :custodians];

        Set<String> projectIds = getValueSet(atms, 'Project_Template__c');

        inspire1__InspirePlannerConfig__c config = inspire1__InspirePlannerConfig__c.getOrgDefaults();
        Id defaultTemplateId = config.Default_Project_Template_Id__c;
        Id headerTemplateId = config.Header_Template_Id__c;

        if (String.isNotBlank(defaultTemplateId)) {
            projectIds.add(defaultTemplateId);
        }
        if (String.isNotBlank(headerTemplateId)) {
            projectIds.add(headerTemplateId);
        }

        Map<Id, inspire1__Project__c> projectsMap = new Map<Id, inspire1__Project__c>([select Id, Name from inspire1__Project__c where Id in :projectIds]);
        
        ProjectByObAccountId[] result = new ProjectByObAccountId[0];

        if (headerTemplateId != null && projectsMap.containsKey(headerTemplateId)) {
            result.add(new ProjectByObAccountId(null, projectsMap.get(headerTemplateId)));
        }

        for (OB_Account__c oba : obas) {
            inspire1__Project__c pr = findProject(projectsMap, atms, oba);
            if (pr != null)
                result.add(new ProjectByObAccountId(oba.Id, pr));
            else {
                if (String.isNotBlank(defaultTemplateId)) {
                    pr = projectsMap.get(defaultTemplateId);

                    if (pr != null) {
                        result.add(new ProjectByObAccountId(oba.Id, pr));
                    }
                }
            }
        }
        return result;
    }

    private static Set<String> getValueSet(SObject[] sObjects, String fieldName) {
        Set<String> result = new Set<String>();

        if (sObjects != null) {
            for (SObject e : sObjects) {
                if (String.isEmpty(fieldName)) {
                    result.add(e.Id);
                } else {
                    String value = (String)e.get(fieldName);

                    if (String.isNotBlank(value))
                        result.add(value);
                }
            }
        }

        return result;
    }

    static inspire1__Project__c findProject(Map<Id, inspire1__Project__c> projectsMap, List<Account_Template_Mapping__c> atms, OB_Account__c oba) {
        for (Account_Template_Mapping__c atm : atms) {
            if (oba.Account_Type__c == atm.Account_Type__c && oba.Custodian__c == atm.Custodian__c) {
                if (projectsMap.containsKey(atm.Project_Template__c))
                    return projectsMap.get(atm.Project_Template__c);
            }
        }

        return null;
    }
    
    @AuraEnabled
    public static Id createProject(ProjectByObAccountId[] projectsByObAccountId, Id masterId, Id parentId) {
        return createProjectInner(projectsByObAccountId, masterId, parentId, 1);
    }

    @TestVisible
    static Id createProjectInner(ProjectByObAccountId[] projectsByObAccountId, Id masterId, Id parentId, Integer startRow) {
        if (projectsByObAccountId == null || projectsByObAccountId.isEmpty())
            return null;

        if (String.isBlank(masterId)) {
            masterId = projectsByObAccountId[0].Project.Id;
        }

        Onboarding_Request__c[] ors = [SELECT Id, Name, Household__c from Onboarding_Request__c where Id = :parentId];
        if (ors.isEmpty())
            return null;
        
        String projectName = ors[0].Name;

        Map<String, Schema.SObjectField> projectFieldsMap = SchemaHelper.getFieldsMap('inspire1__Project__c');
		Set<String> fieldSet = projectFieldsMap.keySet();
        
        Set<String> hiddenFields = new Set<String>(SchemaHelper.getInaccessible('inspire1__Project__c'));
        fieldSet.removeAll(hiddenFields);                                              

        String projectFields = String.join(new List<String>(fieldSet), ',');
        String query = 'SELECT ' + projectFields + ' FROM inspire1__Project__c WHERE Id = :masterId limit 1';
        List<inspire1__Project__c> masterProjects = Database.query(query);

        if (masterProjects.isEmpty())
            return null;
        
        inspire1__Project__c masterProject = masterProjects[0];

        inspire1__Project__c newProject = masterProject.clone();
        newProject.Id = null;
        newProject.Name = projectName;
        newProject.OwnerId = Userinfo.getUserId();
        newProject.inspire1__Project_Template__c = null;
        newProject.inspire1__Template__c = false;
        newProject.inspire1__Project_Template__c = null;
        newProject.inspire1__Chatter_Group_Id__c = null;
        newProject.Onboarding_Request__c = ors[0].Id;
        newProject.inspire1__Account__c = ors[0].Household__c;
        insert newProject;

        CreateTemplateProjectTaskJob job = new CreateTemplateProjectTaskJob(
            newProject.Id,
            projectsByObAccountId,
            0,
            startRow,
            masterProject.inspire1__Send_Task_Notification__c
        );
        System.enqueueJob(job);

        return newProject.Id;
    }
}