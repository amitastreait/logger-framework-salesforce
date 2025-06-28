public class TriggerLogger {
    
    public static void logTriggerStart(String objectName, String triggerType) {
        String message = 'Trigger started: ' + objectName + ' - ' + triggerType;
        Logger.logFromTrigger(objectName + 'Trigger', 'INFO', message, null);
    }
    
    public static void logTriggerEnd(String objectName, String triggerType, Integer recordCount) {
        String message = 'Trigger completed: ' + objectName + ' - ' + triggerType + ' - Records: ' + recordCount;
        Logger.logFromTrigger(objectName + 'Trigger', 'INFO', message, null);
    }
    
    public static void logTriggerError(String objectName, String triggerType, Exception ex) {
        String message = 'Trigger error: ' + objectName + ' - ' + triggerType + ' - ' + ex.getMessage();
        Logger.logFromTrigger(objectName + 'Trigger', 'ERROR', message, null);
    }
}