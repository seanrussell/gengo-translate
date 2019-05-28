/* Base lightning */
import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

/* Pubsub */
import { registerListener, unregisterAllListeners } from 'c/pubsub';

/* Apex methods */
import retrieveTranslations from '@salesforce/apex/TranslationController.retrieveTranslations';

/* Constants */
const PAGE_SIZE = 10;

export default class TranslationListContainer extends LightningElement {
    @track recordId = '';
    @track result;
    @track error;
    @track page = 1;
    @track filterObjectStringified;

    @wire(CurrentPageReference) pageRef;

    _filterObject = {
        status: '',
        sourceLanguage: '',
        targetLanguage: ''
    };

    pageSize = PAGE_SIZE;

    connectedCallback() {
        registerListener('translationFilterChange', this.handleTranslationFilterChange, this);

        const recordId = this.getParameterByName('recordId', window.location.search);
        
        if (recordId) {
            this.recordId = recordId;
        }
        
        this.filterObjectStringified = JSON.stringify(this._filterObject);

        this.getTranslations();
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    handlePagePrevious() {
        this.page = this.page - 1;
    }

    handlePageNext() {
        this.page = this.page + 1;
    }

    handleTranslationFilterChange(event) {
        if (event.status !== undefined) {
            this._filterObject.status = event.status;
        }
        if (event.sourceLanguage !== undefined) {
            this._filterObject.sourceLanguage = event.sourceLanguage;
        }
        if (event.targetLanguage !== undefined) {
            this._filterObject.targetLanguage = event.targetLanguage;
        }
        this.page = 1;
        this.filterObjectStringified = JSON.stringify(this._filterObject);
        this.getTranslations();
    }

    getParameterByName(name, url) {
        if (!url) url = window.location.href;
        name = name.replace(/[\[\]]/g, '\\$&');
        const regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)');
        const results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, ' '));
    }

    getTranslations() {
        console.log('REC ID: ', this.recordId);
        console.log('FILTERS: ', this.filterObjectStringified);
        console.log('P SIZE: ', this.pageSize);
        console.log('P NUM: ', this.page);
        retrieveTranslations({ recordId: this.recordId, filters: this.filterObjectStringified, pageSize: this.pageSize, pageNumber: this.page })
            .then(result => {
                console.log('RES: ', result);
                this.result = result;
            })
            .catch(error => {
                console.log('ERR: ', error);
                this.error = error;
            });
    }

    handleClick(event) {
        event.preventDefault();
    }
}