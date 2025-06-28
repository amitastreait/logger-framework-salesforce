public with sharing class LoggerController {
    
    @AuraEnabled
    public static void logFromComponent(String component, String level, String message, String recordId, String additionalData) {
        try {
            Logger.logFromLWC(component, level, message, recordId, additionalData);
            Logger.flush();
        } catch (Exception ex) {
            System.debug('LoggerController: Error logging from component - ' + ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static String getTransactionId() {
        return Logger.getTransactionId();
    }
}