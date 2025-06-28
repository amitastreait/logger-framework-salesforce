public class Logger {

    public enum LogLevel {
        DEBUG_LEVEL,
        INFO_LEVEL, 
        WARN_LEVEL,
        ERROR_LEVEL,
        FATAL_LEVEL
    }

    public enum Source {
        APEX,
        FLOW,
        APEX_TRIGGER,
        LWC,
        AURA
    }
    
    private static List<Application_Log__c> logBuffer = new List<Application_Log__c>();
    private static String transactionId = generateTransactionId();
    private static Boolean isEnabled = true;
    
    // Configuration - can be moved to Custom Settings
    private static final Integer MAX_BUFFER_SIZE = 100;
    private static final LogLevel MIN_LOG_LEVEL = LogLevel.DEBUG_LEVEL;
    
    // ==================================================
    // PUBLIC LOGGING METHODS
    // ==================================================
    
    public static void debug(String message) {
        log(LogLevel.DEBUG_LEVEL, Source.APEX, '', message, null, null, null);
    }
    
    public static void debug(String classMethod, String message) {
        log(LogLevel.DEBUG_LEVEL, Source.APEX, classMethod, message, null, null, null);
    }
    
    public static void info(String message) {
        log(LogLevel.INFO_LEVEL, Source.APEX, '', message, null, null, null);
    }
    
    public static void info(String classMethod, String message) {
        log(LogLevel.INFO_LEVEL, Source.APEX, classMethod, message, null, null, null);
    }
    
    public static void warn(String message) {
        log(LogLevel.WARN_LEVEL, Source.APEX, '', message, null, null, null);
    }
    
    public static void warn(String classMethod, String message) {
        log(LogLevel.WARN_LEVEL, Source.APEX, classMethod, message, null, null, null);
    }
    
    public static void error(String message) {
        log(LogLevel.ERROR_LEVEL, Source.APEX, '', message, null, null, null);
    }
    
    public static void error(String classMethod, String message) {
        log(LogLevel.ERROR_LEVEL, Source.APEX, classMethod, message, null, null, null);
    }
    
    public static void error(Exception ex) {
        log(LogLevel.ERROR_LEVEL, Source.APEX, '', ex.getMessage(), ex.getStackTraceString(), null, null);
    }
    
    public static void error(String classMethod, Exception ex) {
        log(LogLevel.ERROR_LEVEL, Source.APEX, classMethod, ex.getMessage(), ex.getStackTraceString(), null, null);
    }
    
    public static void fatal(String message) {
        log(LogLevel.FATAL_LEVEL, Source.APEX, '', message, null, null, null);
    }
    
    public static void fatal(String classMethod, String message) {
        log(LogLevel.FATAL_LEVEL, Source.APEX, classMethod, message, null, null, null);
    }
    
    // ==================================================
    // EXTERNAL SOURCE LOGGING METHODS
    // ==================================================
    
    public static void logFromFlow(String flowName, String level, String message, String recordId) {
        LogLevel logLevel = getLogLevelFromString(level);
        log(logLevel, Source.FLOW, flowName, message, null, recordId, null);
    }
    
    public static void logFromLWC(String component, String level, String message, String recordId, String additionalData) {
        LogLevel logLevel = getLogLevelFromString(level);
        log(logLevel, Source.LWC, component, message, null, recordId, additionalData);
    }
    
    public static void logFromTrigger(String triggerName, String level, String message, String recordId) {
        LogLevel logLevel = getLogLevelFromString(level);
        log(logLevel, Source.APEX_TRIGGER, triggerName, message, null, recordId, null);
    }
    
    // ==================================================
    // CORE LOGGING METHOD
    // ==================================================
    
    private static void log(LogLevel level, Source source, String classMethod, String message, 
                           String stackTrace, String recordId, String additionalData) {
        
        if (!isEnabled || !shouldLog(level)) {
            return;
        }
        
        Application_Log__c logEntry = new Application_Log__c();
        logEntry.Level__c = getLogLevelString(level);
        logEntry.Source__c = getSourceString(source);
        logEntry.Component_Name__c = classMethod;
        logEntry.Message__c = truncateString(message, 32768);
        logEntry.Stack_Trace__c = truncateString(stackTrace, 32768);
        logEntry.User__c = UserInfo.getUserId();
        logEntry.Record_Id__c = recordId;
        logEntry.Transaction_Id__c = transactionId;
        logEntry.Additional_Data__c = truncateString(additionalData, 32768);
        
        logBuffer.add(logEntry);
        
        // Auto-flush if buffer is getting full
        if (logBuffer.size() >= MAX_BUFFER_SIZE) {
            flush();
        }
    }
    
    // ==================================================
    // BUFFER MANAGEMENT
    // ==================================================
    
    public static void flush() {
        if (logBuffer.isEmpty()) {
            return;
        }
        
        try {
            Database.insert(logBuffer, false);
            logBuffer.clear();
        } catch (Exception ex) {
            // Prevent infinite logging loop
            System.debug('Logger: Failed to insert logs - ' + ex.getMessage());
        }
    }
    
    public static void setTransactionId(String txnId) {
        transactionId = txnId;
    }
    
    public static String getTransactionId() {
        return transactionId;
    }
    
    private static Boolean shouldLog(LogLevel level) {
        return getLogLevelValue(level) >= getLogLevelValue(MIN_LOG_LEVEL);
    }
    
    private static Integer getLogLevelValue(LogLevel level) {
        switch on level {
            when DEBUG_LEVEL { return 1; }
            when INFO_LEVEL { return 2; }
            when WARN_LEVEL { return 3; }
            when ERROR_LEVEL { return 4; }
            when FATAL_LEVEL { return 5; }
            when else { return 1; }
        }
    }
    
    private static String getLogLevelString(LogLevel level) {
        switch on level {
            when DEBUG_LEVEL { return 'DEBUG'; }
            when INFO_LEVEL { return 'INFO'; }
            when WARN_LEVEL { return 'WARN'; }
            when ERROR_LEVEL { return 'ERROR'; }
            when FATAL_LEVEL { return 'FATAL'; }
            when else { return 'DEBUG'; }
        }
    }
    
    private static LogLevel getLogLevelFromString(String level) {
        switch on level.toUpperCase() {
            when 'DEBUG' { return LogLevel.DEBUG_LEVEL; }
            when 'INFO' { return LogLevel.INFO_LEVEL; }
            when 'WARN' { return LogLevel.WARN_LEVEL; }
            when 'ERROR' { return LogLevel.ERROR_LEVEL; }
            when 'FATAL' { return LogLevel.FATAL_LEVEL; }
            when else { return LogLevel.INFO_LEVEL; }
        }
    }
    
    private static String getSourceString(Source source) {
        switch on source {
            when APEX { return 'Apex'; }
            when FLOW { return 'Flow'; }
            when APEX_TRIGGER { return 'Trigger'; }
            when LWC { return 'LWC'; }
            when AURA { return 'Aura'; }
            when else { return 'Unknown'; }
        }
    }
    
    private static String truncateString(String input, Integer maxLength) {
        if (String.isBlank(input)) {
            return input;
        }
        return input.length() > maxLength ? input.substring(0, maxLength) : input;
    }
    
    private static String generateTransactionId() {
        return String.valueOf(System.currentTimeMillis()) + '_' + String.valueOf(Math.random()).substring(2, 8);
    }
    
    public static void enable() {
        isEnabled = true;
    }
    
    public static void disable() {
        isEnabled = false;
    }
    
    public static Boolean isEnabled() {
        return isEnabled;
    }
}