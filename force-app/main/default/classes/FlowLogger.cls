public class FlowLogger {
    
    @InvocableMethod(label='Log Message' description='Log a message from Flow' iconName='slds:custom:custom67')
    public static void logFromFlow(List<FlowLogRequest> requests) {
        for (FlowLogRequest request : requests) {
            Logger.logFromFlow(request.flowName, request.level, request.message, request.recordId);
        }
    }
    
    public class FlowLogRequest {
        @InvocableVariable(required=true)
        public String flowName;
        
        @InvocableVariable(required=true)
        public String level;
        
        @InvocableVariable(required=true)
        public String message;
        
        @InvocableVariable
        public String recordId;
    }
}