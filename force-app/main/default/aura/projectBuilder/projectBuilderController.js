({
    doInit : function(cmp, event, helper) {
        helper.getProjects(cmp, helper);

        var navService = cmp.find("navService");
        // Sets the route to /lightning/o/Account/home
        var pageReference = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Account',
                actionName: 'home'
            }
        };
        cmp.set("v.pageReference", pageReference);
        // Set the URL on the link or use the default if there's an error
        var defaultUrl = "/lightning/r/Onboarding_Request__c/" + cmp.get("v.recordId") + "/view";
        navService.generateUrl(pageReference)
            .then($A.getCallback(function(url) {
                // cmp.set("v.url", url ? url : defaultUrl);
                cmp.set("v.url", defaultUrl);
            }), $A.getCallback(function(error) {
                cmp.set("v.url", defaultUrl);
            }));
    },

    loadScript : function(component, event, helper) {
        jQuery(document).ready(function() {
            $( "#project-list" ).sortable({ items: "li:not(.non-sortable)" });
            $( "#project-list" ).disableSelection();
        });
    },

    okClick : function(component, event, helper) {
        component.set('v.loading', true);
        function onDone(result) {
            component.set('v.loading', false);

            if (result.newProjectId) {
                var url = '/lightning/r/inspire1__Project__c/' + result.newProjectId + '/view';
                component.set('v.newProjectUrl', url);
                component.set('v.done', true);
            } else {
                component.set('v.error', 'Something went wrong');
                component.set('v.hasError', true);
            }
        }
        helper.createProject(component, onDone);

        // $( "#project-list  input[type=checkbox]:checked" ).each(function( index ) {
        //     // console.log( index + ": " + $(this).attr('id') );
        //     console.log( index + ": " + $(this).parent().parent().text() );
        // });
        // $( "#project-list  input[type=radio]:checked" ).each(function( index ) {
        //     // console.log( index + ": " + $(this).attr('id') );
        //     console.log( index + ": " + $(this).parent().parent().parent().text() );
        // });
    }
})