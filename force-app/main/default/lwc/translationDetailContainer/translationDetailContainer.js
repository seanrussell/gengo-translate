/* Base lightning */
import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';

/* Pubsub */
import { registerListener, unregisterAllListeners } from 'c/pubsub';

/* Apex methods */
import retrieveTranslation from '@salesforce/apex/TranslationController.retrieveTranslation';


export default class TranslationDetailContainer extends LightningElement {
    @track translationId;
    @track translationDetail;
    @track currentStep;

    @wire(CurrentPageReference) pageRef;

    @wire(retrieveTranslation, { recordId: '$translationId' })
    translation(value) {
        if (value && value.data) {
            this.translationDetail = JSON.parse(value.data);
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
        //refreshApex(this.translationId);
    }

    showErrorToast() {
        const event = new ShowToastEvent({
            title: 'Translation not found',
            message: 'Selected translation was not located',
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    setCurrentStep() {
        let currStep;

        switch(this.translationDetail.status) {
            case 'available':
                currStep = 1;
                break;
            case 'pending':
                currStep = 2;
                break;
            case 'in progress':
                currStep = 3;
                break;
            case 'reviewable':
                currStep = 4;
                break;
            case 'approved':
                currStep = 5;
                break;
            default:
                currStep = 1;
        }

        this.currentStep = currStep;
        console.log('CURR STEP: ', this.currentStep);
    }
}