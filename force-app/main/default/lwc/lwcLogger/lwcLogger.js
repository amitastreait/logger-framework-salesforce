import { LightningElement, api, track } from 'lwc';
import logger from 'c/logger';

export default class ExampleLogComponent extends LightningElement {
    @api recordId;
    @track data = [];
    @track error;

    async connectedCallback() {
        // Initialize logger with component name
        logger.setComponentName('ExampleLogComponent');
        
        // Log component initialization
        await logger.info('Component initialized', this.recordId, {
            timestamp: new Date().toISOString(),
            userAgent: navigator.userAgent
        });
    }

    disconnectedCallback() {
        // Log component destruction
        logger.logSync('INFO', 'Component disconnected', this.recordId);
    }

    async handleDebugLog() {
        await logger.debug('Debug button clicked', this.recordId, {
            buttonType: 'debug',
            clickTime: new Date().toISOString()
        });
    }

    async handleInfoLog() {
        await logger.info('Info button clicked', this.recordId, {
            buttonType: 'info',
            clickTime: new Date().toISOString()
        });
    }

    async handleErrorLog() {
        await logger.error('Manual error log triggered', this.recordId, {
            buttonType: 'error',
            clickTime: new Date().toISOString()
        });
    }

    async handleLoadData() {
        const startTime = performance.now();
        this.error = null;
        
        try {
            await logger.debug('Starting data load operation', this.recordId);
            
            // Simulate API call
            const result = await this.fetchData();
            this.data = result;
            
            const endTime = performance.now();
            await logger.logPerformance('Data Load', endTime - startTime, { 
                recordCount: result.length,
                recordId: this.recordId
            });
            
            await logger.info('Data loaded successfully', this.recordId, { 
                recordCount: result.length,
                loadTime: endTime - startTime
            });
            
        } catch (error) {
            await logger.logError(error, 'handleLoadData', this.recordId);
            this.error = error.message;
        }
    }

    async handleSimulateError() {
        try {
            await logger.warn('About to simulate an error', this.recordId);
            
            // Intentionally throw an error
            throw new Error('This is a simulated error for testing logging');
            
        } catch (error) {
            await logger.logError(error, 'handleSimulateError', this.recordId);
            this.error = error.message;
        }
    }

    async fetchData() {
        // Simulate async data loading
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                if (Math.random() > 0.8) {
                    reject(new Error('Simulated API error - network timeout'));
                } else {
                    resolve([
                        { id: '1', name: 'Item 1' },
                        { id: '2', name: 'Item 2' },
                        { id: '3', name: 'Item 3' }
                    ]);
                }
            }, 1000);
        });
    }

    // Error handler for unexpected errors
    errorCallback(error, stack) {
        logger.logSync('FATAL', `Unexpected component error: ${error.message}`, this.recordId, {
            stack: stack,
            component: 'ExampleLogComponent',
            timestamp: new Date().toISOString()
        });
    }
}