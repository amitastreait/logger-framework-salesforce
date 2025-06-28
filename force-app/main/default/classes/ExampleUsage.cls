public class ExampleUsage {
    
    public void demonstrateLogging() {
        // Simple logging
        Logger.info('Process started');
        Logger.debug('ExampleUsage.demonstrateLogging', 'Debug information');
        
        try {
            // Some business logic
            performBusinessLogic();
            Logger.info('ExampleUsage.demonstrateLogging', 'Business logic completed successfully');
        } catch (Exception ex) {
            Logger.error('ExampleUsage.demonstrateLogging', ex);
            Logger.fatal('ExampleUsage.demonstrateLogging', 'Critical error occurred');
        } finally {
            Logger.flush(); // Ensure logs are written
        }
    }
    
    private void performBusinessLogic() {
        // Simulate some processing
        Logger.debug('ExampleUsage.performBusinessLogic', 'Starting business logic');
        
        // Simulate an error
        throw new CalloutException('Simulated error for demonstration');
    }
}