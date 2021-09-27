({
	getProjects: function (cmp, helper) {
		var action = cmp.get("c.getProjects");
		action.setParams({ parentId: cmp.get("v.recordId") });

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var projects = response.getReturnValue();
				cmp.set("v.projects", projects);
			} else {
				console.log(response);
			}
		});
		$A.enqueueAction(action);
	},
    	
	createProject: function (cmp, onDone) {
		var action = cmp.get("c.createProject");

		var selectedProjects = [];
        $( "#project-list input[type=checkbox]:checked" ).each(function( index ) {
			var projectId = $(this).attr('id').replace('check', '');
			var obAccountId = $(this).attr('data-ob-account-id');
            selectedProjects.push({
				Project: {
					Id: projectId,
				},
				ObAccountId: obAccountId,
			});
        });
		var masterId = $( "#project-list input[type=radio]:checked" ).attr('id').replace('master', '');
		action.setParams({ projectsByObAccountId: selectedProjects, masterId: masterId, parentId: cmp.get("v.recordId") });

		action.setCallback(this, function (response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var newProjectId = response.getReturnValue();
				onDone({ newProjectId })
			} else {
				onDone({})
			}
		});
		$A.enqueueAction(action);
	}

})