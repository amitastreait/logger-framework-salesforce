trigger AccountLoggerTrigger on Account (before insert, before update, after insert, after update) {
    TriggerLogger.logTriggerStart('Account', String.valueOf(Trigger.operationType));
    try {
        TriggerLogger.logTriggerEnd('Account', String.valueOf(Trigger.operationType), Trigger.New.size());
    } catch (Exception ex) {
        TriggerLogger.logTriggerError('Account', String.valueOf(Trigger.operationType), ex);
        Logger.flush();
        throw ex;
    }
    Logger.flush();
}