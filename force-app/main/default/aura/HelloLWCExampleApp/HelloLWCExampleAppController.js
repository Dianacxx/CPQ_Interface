({
    myAction : function(component, event, helper) {

    },

    viewAccount : function(component, event, helper) {
        var viewRecordEvent = $A.get("e.force:navigateToURL");
        viewRecordEvent.setParams({
             "url": "/" + event.target.id
       });
       viewRecordEvent.fire();
    }
})
