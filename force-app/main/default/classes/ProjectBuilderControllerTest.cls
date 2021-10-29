@isTest
private class ProjectBuilderControllerTest {

    private static String timezone;

    @testSetup
    static void makeData() {
        String userId = Userinfo.getUserId();
        String timeZoneSidKey = null;
        if (User.sObjectType.getDescribe().isAccessible() && !String.isBlank(userId)) {
            User[] owner = [SELECT Id, TimeZoneSidKey FROM User where Id = :userId limit 1];
            if (!owner.isEmpty()) {
                timeZoneSidKey = owner[0].TimeZoneSidKey;
            }
        }
        List<PicklistEntry> entries = Schema.SObjectType.User.fields.TimeZoneSidKey.picklistValues;
        Map<String, String> timezoneIdsMap = new Map<String, String>();
        for (PicklistEntry e : entries) {
            timezoneIdsMap.put(e.getValue(), e.getLabel());
        }
        if (!String.isBlank(timeZoneSidKey)) {
            timezone = timezoneIdsMap.get(timeZoneSidKey);
        } else {
            timezone = '(GMT-06:00) Central Standard Time (America/Chicago)';
        }
    }

    @isTest
    static void testController() {
        inspire1__Project__c[] projects = new inspire1__Project__c[] {
            new inspire1__Project__c(Name = 'Test project#1', inspire1__Template__c = true, inspire1__Timezone__c = timezone),
            new inspire1__Project__c(Name = 'Test project#2', inspire1__Template__c = true, inspire1__Timezone__c = timezone)
        };
        insert projects;
        
        Datetime startOfDay = Datetime.newInstance(Date.today(), Time.newInstance(9, 0, 0, 0));
        Datetime endOfDay = Datetime.newInstance(Date.today(), Time.newInstance(17, 0, 0, 0));
        inspire1__Project_Tasks__c[] pts = new inspire1__Project_Tasks__c[] {
            new inspire1__Project_Tasks__c(Name = 'Project #1 Task #1', inspire1__Project__c = projects[0].Id, inspire1__RowNUmber__c = 1, inspire1__StartDate__c = startOfDay.addDays(-6), inspire1__FinishDate__c = endOfDay.addDays(-1)),
            new inspire1__Project_Tasks__c(Name = 'Project #1 Task #2', inspire1__Project__c = projects[0].Id, inspire1__RowNumber__c = 2, inspire1__StartDate__c = startOfDay.addDays(-2), inspire1__FinishDate__c = endOfDay.addDays(2), inspire1__Predecessors__c = '1ES'),
            new inspire1__Project_Tasks__c(Name = 'Project #1 Task #3', inspire1__Project__c = projects[0].Id, inspire1__RowNUmber__c = 3, inspire1__Predecessors__c = '2SS+1'),
            new inspire1__Project_Tasks__c(Name = 'Project #2 Task #1', inspire1__Project__c = projects[1].Id, inspire1__RowNUmber__c = 1, inspire1__StartDate__c = startOfDay.addDays(-6), inspire1__FinishDate__c = endOfDay.addDays(-3)),
            new inspire1__Project_Tasks__c(Name = 'Project #2 Task #2', inspire1__Project__c = projects[1].Id, inspire1__RowNUmber__c = 2, inspire1__StartDate__c = startOfDay.addDays(1), inspire1__FinishDate__c = endOfDay.addDays(6), inspire1__Predecessors__c = '1ES'),
            new inspire1__Project_Tasks__c(Name = 'Project #2 Task #3', inspire1__Project__c = projects[1].Id, inspire1__RowNUmber__c = 3, inspire1__Predecessors__c = '2SS')
        };
        insert pts;

        CopyTemplateAttachmentsHelper.createFeedItem(pts[0].Id);
        
        Account acc = new Account(Name = 'Test account #1');
        insert acc;

        RecordType[] rts = [SELECT Id, DeveloperName FROM RecordType
                            WHERE IsActive = true AND SobjectType = 'Onboarding_Request__c' AND DeveloperName = 'Onboarding' LIMIT 1];
        if (rts.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'RecordType is missing');
            return;
        }

        Onboarding_Request__c obr = new Onboarding_Request__c(RecordTypeId = rts[0].Id, Household__c = acc.Id);
        insert obr;

        List<OB_Account__c> obas = new List<OB_Account__c> {
            new OB_Account__c(Account_Type__c = 'IRA', Custodian__c = 'Schwab', Onboarding_Request__c = obr.Id, Beneficiary_to_Be_Added_Updated__c = 'No', Funding_Method__c = 'Check'),
            new OB_Account__c(Account_Type__c = 'Trust', Custodian__c = 'Fidelity', Onboarding_Request__c = obr.Id, Beneficiary_to_Be_Added_Updated__c = 'No', Funding_Method__c = 'Check')
        };
        insert obas;
    
        Account_Template_Mapping__c[] atms = new Account_Template_Mapping__c[] {
            new Account_Template_Mapping__c(Account_Type__c = 'IRA', Custodian__c = 'Schwab', Project_Template__c = projects[0].Id),
            new Account_Template_Mapping__c(Account_Type__c = 'Trust', Custodian__c = 'Fidelity', Project_Template__c = projects[1].Id)
        };
        insert atms;
        
        Test.startTest();

        ProjectByObAccountId[] projectsList = ProjectBuilderController.getProjects(obr.Id);
        Id projectId = ProjectBuilderController.createProject(projectsList, projectsList[0].Project.Id, obr.Id);
        
        Test.stopTest();
    }

    @isTest
    static void testController2() {
        inspire1__Project__c[] projects = new inspire1__Project__c[] {
            new inspire1__Project__c(Name = 'Test project#1', inspire1__Template__c = true, inspire1__Timezone__c = timezone),
            new inspire1__Project__c(Name = 'Test project#2', inspire1__Template__c = true, inspire1__Timezone__c = timezone)
        };
        insert projects;
        
        Datetime startOfDay = Datetime.newInstance(Date.today(), Time.newInstance(9, 0, 0, 0));
        Datetime endOfDay = Datetime.newInstance(Date.today(), Time.newInstance(17, 0, 0, 0));
        inspire1__Project_Tasks__c[] pts = new inspire1__Project_Tasks__c[] {
            new inspire1__Project_Tasks__c(Name = 'Project #1 Task #1', inspire1__Project__c = projects[0].Id, inspire1__RowNUmber__c = 1, inspire1__StartDate__c = startOfDay.addDays(-6), inspire1__FinishDate__c = endOfDay.addDays(-1)),
            new inspire1__Project_Tasks__c(Name = 'Project #1 Task #2', inspire1__Project__c = projects[0].Id, inspire1__RowNumber__c = 2, inspire1__StartDate__c = startOfDay.addDays(-2), inspire1__FinishDate__c = endOfDay.addDays(2), inspire1__Predecessors__c = '1ES'),
            new inspire1__Project_Tasks__c(Name = 'Project #1 Task #3', inspire1__Project__c = projects[0].Id, inspire1__RowNUmber__c = 3, inspire1__Predecessors__c = '2SS+1'),
            new inspire1__Project_Tasks__c(Name = 'Project #2 Task #1', inspire1__Project__c = projects[1].Id, inspire1__RowNUmber__c = 1, inspire1__StartDate__c = startOfDay.addDays(-6), inspire1__FinishDate__c = endOfDay.addDays(-3)),
            new inspire1__Project_Tasks__c(Name = 'Project #2 Task #2', inspire1__Project__c = projects[1].Id, inspire1__RowNUmber__c = 2, inspire1__StartDate__c = startOfDay.addDays(1), inspire1__FinishDate__c = endOfDay.addDays(6), inspire1__Predecessors__c = '1ES'),
            new inspire1__Project_Tasks__c(Name = 'Project #2 Task #3', inspire1__Project__c = projects[1].Id, inspire1__RowNUmber__c = 3, inspire1__Predecessors__c = '2SS')
        };
        insert pts;

        CopyTemplateAttachmentsHelper.createFeedItem(pts[0].Id);
        
        Account acc = new Account(Name = 'Test account #1');
        insert acc;

        RecordType[] rts = [SELECT Id, DeveloperName FROM RecordType
                            WHERE IsActive = true AND SobjectType = 'Onboarding_Request__c' AND DeveloperName = 'Onboarding' LIMIT 1];
        if (rts.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'RecordType is missing');
            return;
        }

        Onboarding_Request__c obr = new Onboarding_Request__c(RecordTypeId = rts[0].Id, Household__c = acc.Id);
        insert obr;

        List<OB_Account__c> obas = new List<OB_Account__c> {
            new OB_Account__c(Account_Type__c = 'IRA', Custodian__c = 'Schwab', Onboarding_Request__c = obr.Id, Beneficiary_to_Be_Added_Updated__c = 'No', Funding_Method__c = 'Check'),
            new OB_Account__c(Account_Type__c = 'Trust', Custodian__c = 'Fidelity', Onboarding_Request__c = obr.Id, Beneficiary_to_Be_Added_Updated__c = 'No', Funding_Method__c = 'Check')
        };
        insert obas;
    
        Account_Template_Mapping__c[] atms = new Account_Template_Mapping__c[] {
            new Account_Template_Mapping__c(Account_Type__c = 'IRA', Custodian__c = 'Schwab', Project_Template__c = projects[0].Id),
            new Account_Template_Mapping__c(Account_Type__c = 'Trust', Custodian__c = 'Fidelity', Project_Template__c = projects[1].Id)
        };
        insert atms;
        
        Test.startTest();

        ProjectByObAccountId[] projectsList = ProjectBuilderController.getProjects(obr.Id);
        Id projectId = ProjectBuilderController.createProjectInner(projectsList, projectsList[0].Project.Id, obr.Id, 2);
        
        Test.stopTest();
    }

    @isTest
    static void testWithHeaderProject() {
        inspire1__Project__c[] projects = new inspire1__Project__c[] {
            new inspire1__Project__c(Name = 'Test project#1', inspire1__Template__c = true, inspire1__Timezone__c = timezone),
            new inspire1__Project__c(Name = 'Test project#2', inspire1__Template__c = true, inspire1__Timezone__c = timezone)
        };
        insert projects;

        inspire1__Project__c headerProject = new inspire1__Project__c(Name = 'Header project', inspire1__Template__c = true);
        insert headerProject;
        
        inspire1__InspirePlannerConfig__c plannerConfig = inspire1__InspirePlannerConfig__c.getOrgDefaults();
        plannerConfig.Header_Template_ID__c = headerProject.Id;
        upsert plannerConfig;
        
        Datetime startOfDay = Datetime.newInstance(Date.today(), Time.newInstance(9, 0, 0, 0));
        Datetime endOfDay = Datetime.newInstance(Date.today(), Time.newInstance(17, 0, 0, 0));
        inspire1__Project_Tasks__c[] pts = new inspire1__Project_Tasks__c[] {
            new inspire1__Project_Tasks__c(Name = 'Project #1 Task #1', inspire1__Project__c = projects[0].Id, inspire1__RowNUmber__c = 1, inspire1__StartDate__c = startOfDay.addDays(-6), inspire1__FinishDate__c = endOfDay.addDays(-1)),
            new inspire1__Project_Tasks__c(Name = 'Project #1 Task #2', inspire1__Project__c = projects[0].Id, inspire1__RowNumber__c = 2, inspire1__StartDate__c = startOfDay.addDays(-2), inspire1__FinishDate__c = endOfDay.addDays(2), inspire1__Predecessors__c = '1ES'),
            new inspire1__Project_Tasks__c(Name = 'Project #1 Task #3', inspire1__Project__c = projects[0].Id, inspire1__RowNUmber__c = 3, inspire1__Predecessors__c = '2SS+1'),
            new inspire1__Project_Tasks__c(Name = 'Project #2 Task #1', inspire1__Project__c = projects[1].Id, inspire1__RowNUmber__c = 1, inspire1__StartDate__c = startOfDay.addDays(-6), inspire1__FinishDate__c = endOfDay.addDays(-3)),
            new inspire1__Project_Tasks__c(Name = 'Project #2 Task #2', inspire1__Project__c = projects[1].Id, inspire1__RowNUmber__c = 2, inspire1__StartDate__c = startOfDay.addDays(1), inspire1__FinishDate__c = endOfDay.addDays(6), inspire1__Predecessors__c = '1ES'),
            new inspire1__Project_Tasks__c(Name = 'Project #2 Task #3', inspire1__Project__c = projects[1].Id, inspire1__RowNUmber__c = 3, inspire1__Predecessors__c = '2SS')
        };
        insert pts;

        CopyTemplateAttachmentsHelper.createFeedItem(pts[0].Id);
        
        List<Task> tasks = new List<Task> {
            new Task(Subject = pts[1].Name, inspire1__Inspire_Task__c = pts[1].Id),
            new Task(Subject = pts[2].Name, inspire1__Inspire_Task__c = pts[2].Id),
            new Task(Subject = pts[4].Name, inspire1__Inspire_Task__c = pts[4].Id),
            new Task(Subject = pts[5].Name, inspire1__Inspire_Task__c = pts[5].Id)
        };
        insert tasks;
        
        Account acc = new Account(Name = 'Test account #1');
        insert acc;

        RecordType[] rts = [SELECT Id, DeveloperName FROM RecordType
                            WHERE IsActive = true AND SobjectType = 'Onboarding_Request__c' AND DeveloperName = 'Onboarding' LIMIT 1];
        if (rts.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'RecordType is missing');
            return;
        }

        Onboarding_Request__c obr = new Onboarding_Request__c(RecordTypeId = rts[0].Id, Household__c = acc.Id);
        insert obr;

        List<OB_Account__c> obas = new List<OB_Account__c> {
            new OB_Account__c(Account_Type__c = 'IRA', Custodian__c = 'Schwab', Onboarding_Request__c = obr.Id, Beneficiary_to_Be_Added_Updated__c = 'No', Funding_Method__c = 'Check'),
            new OB_Account__c(Account_Type__c = 'Trust', Custodian__c = 'Fidelity', Onboarding_Request__c = obr.Id, Beneficiary_to_Be_Added_Updated__c = 'No', Funding_Method__c = 'Check')
        };
        insert obas;
    
        Account_Template_Mapping__c[] atms = new Account_Template_Mapping__c[] {
            new Account_Template_Mapping__c(Account_Type__c = 'IRA', Custodian__c = 'Schwab', Project_Template__c = projects[0].Id),
            new Account_Template_Mapping__c(Account_Type__c = 'Trust', Custodian__c = 'Fidelity', Project_Template__c = projects[1].Id)
        };
        insert atms;
        
        Test.startTest();

        ProjectByObAccountId[] projectsList = ProjectBuilderController.getProjects(obr.Id);
        Id projectId = ProjectBuilderController.createProject(projectsList, projectsList[0].Project.Id, obr.Id);
        
        Test.stopTest();
    }

    @isTest
    static void testWithDefaultProject() {
        inspire1__Project__c defaultProject = new inspire1__Project__c(Name = 'Header project', inspire1__Template__c = true);
        insert defaultProject;
        inspire1__InspirePlannerConfig__c plannerConfig = inspire1__InspirePlannerConfig__c.getOrgDefaults();
        plannerConfig.Default_Project_Template_Id__c = defaultProject.Id;
        upsert plannerConfig;
        
        Account acc = new Account(Name = 'Test account #1');
        insert acc;

        RecordType[] rts = [SELECT Id, DeveloperName FROM RecordType
                            WHERE IsActive = true AND SobjectType = 'Onboarding_Request__c' AND DeveloperName = 'Onboarding' LIMIT 1];
        if (rts.isEmpty()) {
            System.debug(LoggingLevel.ERROR, 'RecordType is missing');
            return;
        }

        Onboarding_Request__c obr = new Onboarding_Request__c(RecordTypeId = rts[0].Id, Household__c = acc.Id);
        insert obr;

        List<OB_Account__c> obas = new List<OB_Account__c> {
            new OB_Account__c(Account_Type__c = 'IRA', Custodian__c = 'Schwab', Onboarding_Request__c = obr.Id, Beneficiary_to_Be_Added_Updated__c = 'No', Funding_Method__c = 'Check'),
            new OB_Account__c(Account_Type__c = 'Trust', Custodian__c = 'Fidelity', Onboarding_Request__c = obr.Id, Beneficiary_to_Be_Added_Updated__c = 'No', Funding_Method__c = 'Check')
        };
        insert obas;
        
        Test.startTest();

        ProjectByObAccountId[] projectsList = ProjectBuilderController.getProjects(obr.Id);
        Id projectId = ProjectBuilderController.createProject(projectsList, projectsList[0].Project.Id, obr.Id);

        ProjectBuilderController.createProject(projectsList, null, obr.Id);
        ProjectBuilderController.createProject(projectsList, null, null);
        ProjectBuilderController.createProject(new List<ProjectByObAccountId>(), projectsList[0].Project.Id, obr.Id);
        
        Test.stopTest();
    }
}