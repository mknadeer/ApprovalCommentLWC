public with sharing class ApprovalCommentsController {

    @AuraEnabled(cacheable=true)
    public static Map<String,String> ApprovalCommentList(Id recordId) {

        //Check the Record Type Id - ProcessInstanceWorkitem/ProcessInstanceStep
        SObjectType sObjectType = recordId.getSObjectType();
        String sObjectTypeName = sObjectType.getDescribe().getName();

        Map<String,String> InstanceMap = new Map<String,String>();
        Id targetObjectId;

        if (sObjectTypeName == 'ProcessInstanceWorkitem') {
            // Query the ProcessInstanceWorkitem record
            ProcessInstanceWorkitem step = [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE Id = :recordId];
            targetObjectId = step.processInstance.TargetObjectId;
        }else if (sObjectTypeName == 'ProcessInstanceStep') {
            // Query the ProcessInstanceStep record
            ProcessInstanceStep step = [SELECT Id, ProcessInstance.TargetObjectId FROM ProcessInstanceStep WHERE Id = :recordId];
            targetObjectId = step.processInstance.TargetObjectId;
        }

        

        if (targetObjectId != null) {
            Map<Id,ProcessInstance> processinstence = New Map<Id,ProcessInstance>([SELECT Id, Status,ProcessDefinition.Name, (SELECT ID, ProcessNodeId,  
                                        StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,OriginalActor.Name   
                                        ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,  
                                         Ispending,ProcessNode.Name FROM StepsAndWorkitems)   
                                    FROM ProcessInstance where TargetObjectId =:targetObjectId order by CreatedDate DESC]); 
                for(ProcessInstance pr :  processinstence.values()){
                    for(ProcessInstanceHistory  str : pr.StepsAndWorkitems) {
                        InstanceMap.put(str.OriginalActor.Name,str.Comments);
                    }
                }
            }
        System.debug('InstanceMap->'+InstanceMap);
        if(!InstanceMap.isEmpty()) return InstanceMap;
        else return null;
    }
}