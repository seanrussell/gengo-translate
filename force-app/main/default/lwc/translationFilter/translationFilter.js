/* Base Lightning */
import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

/* Pubsub */
import { fireEvent } from 'c/pubsub';

export default class TranslationFilter extends LightningElement {
    @wire(CurrentPageReference) pageRef;

    handleStatusChange(event) {
        if (event.detail !== undefined) {
            fireEvent(this.pageRef, 'translationFilterChange', {
                status: event.detail
            });
        }
    }

    handleSourceLanguageChange(event) {
        if (event.detail) {
            fireEvent(this.pageRef, 'translationFilterChange', {
                sourceLanguage: event.detail
            });
        }
    }

    handleTargetLanguageChange(event) {
        if (event.detail) {
            fireEvent(this.pageRef, 'translationFilterChange', {
                targetLanguage: event.detail
            });
        }
    }
}