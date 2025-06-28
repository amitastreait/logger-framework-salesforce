// lwcLogger.js
import logFromComponent from '@salesforce/apex/LoggerController.logFromComponent';
import getTransactionId from '@salesforce/apex/LoggerController.getTransactionId';

class LWCLogger {
    constructor() {
        this.transactionId = null;
        this.componentName = 'Unknown';
        this.isInitialized = false;
    }

    async init() {
        if (this.isInitialized) return;
        
        try {
            this.transactionId = await getTransactionId();
            this.isInitialized = true;
        } catch (error) {
            console.error('Failed to get transaction ID:', error);
            // Set a fallback transaction ID
            this.transactionId = 'LWC_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
            this.isInitialized = true;
        }
    }

    setComponentName(name) {
        this.componentName = name;
    }

    async log(level, message, recordId = null, additionalData = null) {
        // Ensure logger is initialized
        if (!this.isInitialized) {
            await this.init();
        }

        try {
            // Call the Apex method with correct parameter structure
            await logFromComponent({
                component: this.componentName,
                level: level,
                message: message,
                recordId: recordId,
                additionalData: additionalData ? JSON.stringify(additionalData) : null
            });
        } catch (error) {
            console.error('Logging failed:', error);
            // Fallback to console logging
            console.log(`[${level}] ${this.componentName}: ${message}`, { recordId, additionalData });
        }
    }

    async debug(message, recordId = null, additionalData = null) {
        return this.log('DEBUG', message, recordId, additionalData);
    }

    async info(message, recordId = null, additionalData = null) {
        return this.log('INFO', message, recordId, additionalData);
    }

    async warn(message, recordId = null, additionalData = null) {
        return this.log('WARN', message, recordId, additionalData);
    }

    async error(message, recordId = null, additionalData = null) {
        return this.log('ERROR', message, recordId, additionalData);
    }

    async fatal(message, recordId = null, additionalData = null) {
        return this.log('FATAL', message, recordId, additionalData);
    }

    // Helper method to log errors with stack trace
    async logError(error, context = '', recordId = null) {
        const errorInfo = {
            message: error.message,
            stack: error.stack,
            context: context,
            timestamp: new Date().toISOString()
        };
        return this.error(`Error in ${context}: ${error.message}`, recordId, errorInfo);
    }

    // Helper method to log performance metrics
    async logPerformance(operation, duration, additionalData = null) {
        const perfData = {
            operation: operation,
            duration: duration,
            timestamp: new Date().toISOString(),
            ...additionalData
        };
        return this.info(`Performance: ${operation} took ${duration}ms`, null, perfData);
    }

    // Synchronous logging for situations where you can't wait for async
    logSync(level, message, recordId = null, additionalData = null) {
        // Fire and forget - don't wait for the result
        this.log(level, message, recordId, additionalData).catch(error => {
            console.error('Async logging failed:', error);
        });
    }
}

// Create and export singleton instance
const logger = new LWCLogger();

// Export the singleton instance as default
export default logger;

// Also export individual methods for direct use
export const debug = (message, recordId = null, additionalData = null) => logger.debug(message, recordId, additionalData);
export const info = (message, recordId = null, additionalData = null) => logger.info(message, recordId, additionalData);
export const warn = (message, recordId = null, additionalData = null) => logger.warn(message, recordId, additionalData);
export const error = (message, recordId = null, additionalData = null) => logger.error(message, recordId, additionalData);
export const fatal = (message, recordId = null, additionalData = null) => logger.fatal(message, recordId, additionalData);
export const logError = (error, context = '', recordId = null) => logger.logError(error, context, recordId);
export const logPerformance = (operation, duration, additionalData = null) => logger.logPerformance(operation, duration, additionalData);
export const setComponentName = (name) => logger.setComponentName(name);
export const init = () => logger.init();

// Export the class itself for advanced usage
export { LWCLogger };