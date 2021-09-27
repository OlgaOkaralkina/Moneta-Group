public with sharing class CreateTemplateProjectTaskJob implements Queueable {
    Id projectId;
    ProjectByObAccountId[] projectsByObAccountId;
    Integer i;
    Integer rowNumber;
    Boolean isReminderSet;

    public CreateTemplateProjectTaskJob(
        Id projectId,
        ProjectByObAccountId[] projectsByObAccountId,
        Integer i,
        Integer rowNumber,
        Boolean isReminderSet
    ) {
        this.projectId = projectId;
        this.projectsByObAccountId = projectsByObAccountId;
        this.i = i;
        this.rowNumber = rowNumber;
        this.isReminderSet = isReminderSet;
    }

    public void execute(QueueableContext context) {
        Integer size = this.projectsByObAccountId.size();
        if (size == 0 || i >= size) {
            return;
        }

        Integer newRowNumber = iteration();
        if (i < size - 1 && !Test.isRunningTest()) {
            CreateTemplateProjectTaskJob job = new CreateTemplateProjectTaskJob(
                this.projectId,
                this.projectsByObAccountId,
                this.i + 1,
                newRowNumber,
                this.isReminderSet
            );
            System.enqueueJob(job);
        }
    }

    private Integer iteration() {
        ProjectByObAccountId prByObId = this.projectsByObAccountId[i];

        String obAccountName = '';
        if (prByObId != null) {
            obAccountName = getObAccountName(prByObId);
        }

        Map<String, Schema.SObjectField> projectTaskFieldsMap = SchemaHelper.getFieldsMap('inspire1__Project_Tasks__c');

        Id obAccountProjectId = prByObId.Project.Id;
        String projectTaskFields = String.join(new List<String>(projectTaskFieldsMap.keySet()), ',');
        String query = 'SELECT ' + projectTaskFields + ' FROM inspire1__Project_Tasks__c' +
            ' WHERE inspire1__Project__c = :obAccountProjectId order by inspire1__RowNumber__c';
        List<inspire1__Project_Tasks__c> projectTasks = Database.query(query);
        if (projectTasks == null || projectTasks.size() == 0) {
            return this.rowNumber;
        }

        for (inspire1__Project_Tasks__c projectTask : projectTasks) {
            projectTask.Account_Name__c = obAccountName;
        }
        Integer nameFieldLength = projectTaskFieldsMap.get('Name').getDescribe().length;
        Integer subjectFieldLength = projectTaskFieldsMap.get('inspire1__Name__c').getDescribe().length;
        if (String.isNotBlank(obAccountName)) {
            setTaskNameAndSubject(nameFieldLength, subjectFieldLength, projectTasks[0], obAccountName);
        }

        return cloneProjectTasks(this.projectId, projectTasks, this.rowNumber, this.isReminderSet);
    }

    private String getObAccountName(ProjectByObAccountId prByObId) {
        OB_Account__c[] obAccounts = [
            SELECT
                Id
                , Name
            FROM OB_Account__c 
            WHERE Id = :prByObId.ObAccountId
        ];
        return obAccounts.size() > 0 ? obAccounts[0].Name : '';
    }

    private Integer cloneProjectTasks(Id projectId, List<inspire1__Project_Tasks__c> taskList, Integer startRowNumber, Boolean IsReminderSet) {
        List<inspire1__Project_Tasks__c> insertTasks = new List<inspire1__Project_Tasks__c>();
        Integer maxRowNumber = startRowNumber;
        Integer rowShift = startRowNumber - 1;

        for (inspire1__Project_Tasks__c task : taskList) {
            inspire1__Project_Tasks__c insertTask = task.clone();
            insertTask.inspire1__Project__c = projectId;
            insertTask.inspire1__Status__c = CreateTemplateProjectTaskJob.NotStartedString;
            insertTask.inspire1__Done__c = 0;

            Integer newRowNumber = Integer.valueOf(insertTask.inspire1__RowNumber__c) + rowShift;
            insertTask.inspire1__RowNumber__c = newRowNumber;

            if (newRowNumber > maxRowNumber) {
                maxRowNumber = newRowNumber;
            }

            if (rowShift > 0 && String.isNotBlank(insertTask.inspire1__Predecessors__c)) {
                insertTask.inspire1__Predecessors__c = translatePredecessors(insertTask.inspire1__Predecessors__c, rowShift);
            }

            if (rowShift > 0 && String.isNotBlank(insertTask.inspire1__Successors__c)) {
                insertTask.inspire1__Successors__c = translatePredecessors(insertTask.inspire1__Successors__c, rowShift);
            }

            insertTasks.add(insertTask);
        }
        insert insertTasks;

        Map<Id, inspire1__Project_Tasks__c> projectTasksTemplateAndNew = new Map<Id, inspire1__Project_Tasks__c>();
        Map<String, String> tasksPhantomIdToId = new Map<String, String>();
        for (Integer i = 0; i < insertTasks.size(); i++) {
            tasksPhantomIdToId.put(taskList[i].Id, insertTasks[i].Id);
            projectTasksTemplateAndNew.put(taskList[i].Id, insertTasks[i]);
        }

        // set parent tasks
        List<inspire1__Project_Tasks__c> updateTasks = new List<inspire1__Project_Tasks__c>();
        for (inspire1__Project_Tasks__c task : insertTasks) {
            if (task.inspire1__parent_task__c != null) {
                String newParentId = projectTasksTemplateAndNew.get(task.inspire1__parent_task__c).Id;
                task.inspire1__parent_task__c = newParentId;

                updateTasks.add(task);
            }
        }
        update updateTasks;

        // insert sf tasks from template
        Map<String, Schema.SObjectField> taskFieldsMap = SchemaHelper.getFieldsMap('Task');
        String taskFields = String.join(new List<String>(taskFieldsMap.keySet()), ',');

        Map<Id, inspire1__Project_Tasks__c> templateProjectTasksMap = new Map<Id, inspire1__Project_Tasks__c>(taskList);
        Set<Id> templateTaskIds = templateProjectTasksMap.keySet();

        String query = 'SELECT ' + taskFields + ' FROM Task WHERE inspire1__Inspire_Task__c in :templateTaskIds';

        System.debug('query => ' + query);
        List<Task> templateSFTasks = Database.query(query);

        if (!templateSFTasks.isEmpty()) {
            List<Task> sfTasksForInsert = new List<Task>();
            for (Task task: templateSFTasks) {
                Task newTask = task.clone();
                newTask.inspire1__Inspire_Task__c = projectTasksTemplateAndNew.get(task.inspire1__Inspire_Task__c).Id;
                newTask.WhatId = projectId;
                newTask.Status = CreateTemplateProjectTaskJob.NotStartedString; // 'Not Started';
                newTask.IsReminderSet = IsReminderSet;

                sfTasksForInsert.add(newTask);
            }
            insert sfTasksForInsert;
        }

        copyChecklistItems(templateProjectTasksMap, tasksPhantomIdToId, true);

        CopyTemplateAttachmentsHelper.copyTemplateAttachments(projectTasksTemplateAndNew);

        return maxRowNumber + 1;
    }

    private static void copyChecklistItems(Map<Id, inspire1__Project_Tasks__c> ptMap, Map<String, String> tasksPhantomIdToId, Boolean resetItems) {
        Schema.DescribeSObjectResult describeSObject = inspire1__Checklist_Item__c.sObjectType.getDescribe();
        List<String> fields = new List<String>(describeSObject.fields.getMap().keySet());

        Set<Id> templateTaskIds = ptMap.keySet();
        String query = String.format('SELECT {0} FROM inspire1__Checklist_Item__c WHERE inspire1__project_task__c in: templateTaskIds', new Object[] { String.join(fields, ',') });

        System.debug('query => ' + query);

        inspire1__Checklist_Item__c[] templateItems = Database.query(query);

        if (templateItems.isEmpty()) {
            return;
        }

        List<inspire1__Checklist_Item__c> newChecklistItems = new List<inspire1__Checklist_Item__c>();
        for (inspire1__Checklist_Item__c item : templateItems) {
            inspire1__Checklist_Item__c newItem = item.clone();
            newItem.inspire1__Project_Task__c = tasksPhantomIdToId.get(item.inspire1__Project_Task__c);
            if (resetItems) {
                newItem.inspire1__Completed__c = false;
                newItem.inspire1__Completion_Date__c = null;
                newItem.Start_Date__c = null;
            }
            newChecklistItems.add(newItem);
        }
        if (!Schema.sObjectType.inspire1__Checklist_Item__c.fields.inspire1__Item_Name__c.isCreateable()
            || !Schema.sObjectType.inspire1__Checklist_Item__c.fields.inspire1__Completed__c.isCreateable()
            || !Schema.sObjectType.inspire1__Checklist_Item__c.fields.inspire1__Completion_Date__c.isCreateable()
            || !Schema.sObjectType.inspire1__Checklist_Item__c.fields.inspire1__Order__c.isCreateable()
            || !Schema.sObjectType.inspire1__Checklist_Item__c.fields.inspire1__Project_Task__c.isCreateable()
            || !Schema.sObjectType.inspire1__Checklist_Item__c.fields.inspire1__Required__c.isCreateable()) {
            System.debug(LoggingLevel.ERROR, 'Checklist_Item__c fields are not createable');
        } else {
            Database.insert(newChecklistItems);
        }
    }

    private Void setTaskNameAndSubject(Integer nameFieldLength, Integer subjectFieldLength, inspire1__Project_Tasks__c projectTask, String name) {
       Integer nameLength = name.length();
       projectTask.Name = nameLength > nameFieldLength ? name.substring(0, nameFieldLength) : name;
       projectTask.inspire1__Name__c = nameLength > subjectFieldLength ? name.substring(0, subjectFieldLength) : name;
    }

    private String translatePredecessors(String predecessors, Integer rowShift) {
        return getPredecessorsFromDependencyList(parsePredecessors(predecessors), rowShift);
    }
      
    private final static Map<String, String> statusMappingMap {
        get {
            return new Map<String, String> {
                'Deferred' => 'inspire1__Task_Status_Deferred__c',
                'Waiting on Someone else' => 'inspire1__Task_Status_Waiting_on_Someone_else__c',
                'In Progress' => 'inspire1__Task_Status_In_Progress__c',
                'Not Started' => 'inspire1__Task_Status_Not_Started__c',
                'Completed' => 'inspire1__Task_Status_Completed__c'
            };
        }
    }
    
    private static Map<String, String> mStatusMapper;
    private static Map<String, String> getStatusMapper() {
        if (mStatusMapper == null) {
            mStatusMapper = new Map<String, String>();

            inspire1__InspirePlannerConfig__c config = inspire1__InspirePlannerConfig__c.getInstance();
            
            for (String key : statusMappingMap.keySet()) {
                String value = String.valueOf(config.get(statusMappingMap.get(key)));
                if (String.isNotBlank(value)) {
                    mStatusMapper.put(key, value);
                } else {
                    mStatusMapper.put(key, key);
                }
            }
        }
        
        return mStatusMapper;
    }

    private static String NotStartedString { get { return CreateTemplateProjectTaskJob.getStatusMapper().get('Not Started'); } }

    private static final String[] depTypes = new List<String>{'SS', 'SE', 'ES', 'EE'};

    private Dependency[] parsePredecessors(String predecessors) {
        Dependency[] result = new List<Dependency>();
        Integer depID = 0;
        List<String> predecessorsList = predecessors.split(';');
        
        //  2ES;4ES;8SS+4;
        for (String predecessor : predecessorsList) {
            depID++;
            Dependency dependency;

            for (Integer i = 0; i < 4; i++) {
                if (predecessor.indexOf(CreateTemplateProjectTaskJob.depTypes[i]) != -1) {
                    dependency = parsePredecessor(predecessor, CreateTemplateProjectTaskJob.depTypes[i]);
                    dependency.Type = i;
                    break;
                }
            }

            result.add(dependency);
        }

        return result;
    }

    // Get Lag and FromId fields from string.
    private Dependency parsePredecessor(String predecessor, String type) {
        Dependency dependency = new Dependency();

        //  2ES;4ES-2;8SS+4;
        try {
            List<String> partPredecessor;
            if (predecessor.indexOf('+') != -1) {
                partPredecessor = predecessor.split('\\+');
                dependency.Lag = Integer.valueOf(partPredecessor[1]);
            } else if (predecessor.indexOf('-') != -1) {
                partPredecessor = predecessor.split('\\-');
                dependency.Lag = -Integer.valueOf(partPredecessor[1]);
            } else {
                partPredecessor = new String[] { predecessor };
                dependency.Lag = 0;
            }

            dependency.FromNumber = getRowNumber(partPredecessor[0], type);
        } catch (Exception ex) {
            dependency.Lag = 0;
        }

        return dependency;
    }    

    // Get predecessor record form Dependency list. Predecessors string looks like '1SE+3'
    private String getPredecessorsFromDependencyList(Dependency[] depedencies, Integer rowShift) {
        String[] predList = new List<String>();
        
        for (Dependency dep : depedencies) {
            String depField = (rowShift == null ? dep.FromNumber : dep.FromNumber + rowShift).format();

            depField += CreateTemplateProjectTaskJob.depTypes[dep.Type];

            if (dep.Lag != 0) {
                if (dep.Lag > 0) {
                    depField += '+' + String.valueOf(dep.Lag);
                } else {
                    depField += String.valueOf(dep.Lag);
                }
            }

            predList.add(depField);
        }

        return String.join(predList, ';');
    }
    
    private Integer getRowNumber(String predecessor, String typeOfDependency) {
        Integer result = 0;
        try {
            result = Integer.valueOf(predecessor.replace(typeOfDependency, ''));
        } catch (System.TypeException e) {
        }
        return result;
    }

    private class Dependency { // This class represents a single Dependency in your gantt chart.
        public Integer FromNumber { get;set; } // The id of the task at which the dependency starts
        public Integer Lag { get;set; } // A numeric part of the lag value between the tasks. Negative values are supported.

        // An integer constant representing the type of the dependency:
        /*
            0 - start-to-start dependency
            1 - start-to-end dependency
            2 - end-to-start dependency
            3 - end-to-end dependency
        */
        public Integer Type { get;set; } 
    }
}