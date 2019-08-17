/* Base lightning */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

/* Pubsub */
import { registerListener, unregisterAllListeners } from 'c/pubsub';

/* Apex methods */
import retrieveTranslation from '@salesforce/apex/TranslationController.retrieveTranslation';
import updateTranslation from '@salesforce/apex/GengoTranslateController.updateTranslation';

export default class TranslationDetailContainer extends NavigationMixin(LightningElement) {
    @track translationId;
    @track translationDetail;
    @track currentStep;

    jobId;
    wiredTranslationResults

    @wire(CurrentPageReference) pageRef;

    @wire(retrieveTranslation, { recordId: '$translationId' })
    translation(value) {
        this.wiredTranslationResults = value;
        if (value && value.data) {
            this.translationDetail = JSON.parse(value.data);
            this.jobId = this.translationDetail.jobId;
            console.log('TRANSLATION DETAIL: ', this.translationDetail);
            this.setCurrentStep();
        } else {
            this.showErrorToast();
        }
    }

    connectedCallback() {
        registerListener('translationSelected', this.handleTranslationSelected, this);
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handleTranslationSelected(translationId) {
        this.translationId = translationId;
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Translation not found',
            message: 'Selected translation was not located',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(event);
    }

    setCurrentStep() {
        let currStep;

        switch(this.translationDetail.status) {
            case 'available':
                currStep = '1';
                break;
            case 'pending':
                currStep = '2';
                break;
            case 'in progress':
                currStep = '3';
                break;
            case 'reviewable':
                currStep = '4';
                break;
            case 'approved':
                currStep = '5';
                break;
            default:
                currStep = '1';
        }

        this.currentStep = currStep;
    }

    get isReviewable() {
        return this.currentStep === '4';
    }

    approveTranslation() {
        updateTranslation({ recordId: this.jobId, action: 'approve' })
            .then(result => {
                refreshApex(this.wiredTranslationResults);
                this.showSuccessToast('You have successfully approved this translation.');
            })
            .catch(error => {
                this.showErrorToast();
            });
    }

    rejectTranslation() {
        updateTranslation({ recordId: this.translationId, action: 'reject' })
            .then(result => {
                refreshApex(this.wiredTranslationResults);
                this.showSuccessToast('You have successfully rejected this translation.');
            })
            .catch(error => {
                this.showErrorToast();
            });
    }

    redirectToRecord() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                actionName: 'view'
            }
        });
    }
}