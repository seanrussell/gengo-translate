/* Base Lightning */
import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

/* Apex methods */
import getFieldsForObject from '@salesforce/apex/GengoTranslateController.getFieldsForObject';
import getFieldContentToTranslate from '@salesforce/apex/GengoTranslateController.getFieldContentToTranslate';
import getLanguages from '@salesforce/apex/GengoTranslateController.getLanguages';
import getLanguagePairs from '@salesforce/apex/GengoTranslateController.getLanguagePairs';
import getAccountBalance from '@salesforce/apex/GengoTranslateController.getAccountBalance';
import submitTranslation from '@salesforce/apex/GengoTranslateController.submitTranslation';

export default class GengoTranslate extends NavigationMixin(LightningElement) {
    @api fieldName;
    @api recordId;
    @api objectApiName;

    @track error;
    @track objectFields;
    @track objectFieldsError;
    @track sourceLangs;
    @track targetLangs;
    @track targetLangError;
    @track tierPrices;
    @track availableTiers;
    @track showSubmitTranslationButton;
    @track showSuccessMessage = false ;
    
    pairs;
    codeToLanguage;
    selectedSourceLanguage;
    selectedSourceLanguageCode;
    selectedTargetLanguage;
    selectedTargetLanguageCode;
    tiersForSelection;
    fieldContentToTranslate;
    selectedTier;
    selectedField;

    connectedCallback() {}

    resetProperties() {
        this.error = false;
        this.targetLangError = false;
        this.objectFieldsError = false;
        this.targetLangs = null;
        this.availableTiers = null;
        this.selectedTier = '';
        this.selectedTargetLanguage = '';
        this.selectedTargetLanguageCode = '';
    }

    resetAllProperties() {
        this.resetProperties();
        this.selectedSourceLanguage = '';
        this.selectedSourceLanguageCode = '';
        this.sourceLangs = null;
        this.targetLangError = null;
        this.showSubmitTranslationButton = false;
    }

    handleStart() {
        if (!this.objectFields) {
            this.retrieveObjectFields();
        }
    }

    retrieveObjectFields() {
        getFieldsForObject({objectName: this.objectApiName})
            .then(result => {
                const fields = JSON.parse(result);
                
                if (fields.length > 0) {
                    this.retrieveLanguagesAndAccount();
                    this.setObjectFieldsList(fields);
                } else {
                    this.objectFieldsError = true;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    retrieveLanguagesAndAccount() {
        if (!this.sourceLangs) {
            this.retrieveLanguages();
        }

        if (!this.pairs && !this.tierPrices) {
            this.retrieveLanguagePairs();
        }

        this.retrieveAccountBalance();
    }

    setObjectFieldsList(fields) {
        const flds = [];

        fields.forEach(fld => {
            flds.push({
                label: fld.label,
                value: fld.name
            });
        });

        this.objectFields = flds;
    }

    retrieveLanguages() {
        getLanguages()
            .then(result => {
                const items = JSON.parse(result).response;
                this.codeToLanguage = this.mapCodesToLanguage(items);
                this.sourceLangs = this.setSourceLanguages();
            })
            .catch(error => {
                this.error = error;
            });
    }

    retrieveLanguagePairs() {
        getLanguagePairs()
            .then(result => {
                const items = JSON.parse(result).response;
                this.pairs = this.getPairs(items);
                this.tierPrices = this.getTierPrices(items);
            })
            .catch(error => {
                this.error = error;
            });
    }

    retrieveAccountBalance() {
        getAccountBalance()
            .then(result => {
                this.credits = JSON.parse(result).response.credits.toFixed(2);
            })
            .catch(error => {
                this.error = error;
            });
    }

    mapCodesToLanguage(items) {
        const codeToLanguage = items.reduce(function(map, obj) {
            map[obj.lc] = obj.language;
            return map;
        }, {});

        return codeToLanguage;
    }

    setSourceLanguages() {
        const langs = [];

        Object.keys(this.codeToLanguage).forEach(key => {
            langs.push({
                label: this.codeToLanguage[key],
                value: key
            });
        });

        langs.sort((a, b) => {
            if(a.label < b.label) { return -1; }
            if(a.label > b.label) { return 1; }
            return 0;
        });

        return langs;
    }

    getPairs(items) {
        const pairs = items.reduce((map, obj) => {
            var vals = map[obj.lc_src] || [];
            if (vals.indexOf(obj.lc_tgt) === -1) {
                vals.push(obj.lc_tgt);
            }
            map[obj.lc_src] = vals;                    
            return map;
        }, {});

        return pairs;
    }

    getTierPrices(items) {
        const tiers = items.reduce((map, obj) => {
            var key = obj.lc_src + ':' + obj.lc_tgt;
            var vals = map[key] || [];
            if (vals.indexOf(key) === -1) {
                vals.push({
                    tier: obj.tier,
                    unitPrice: obj.unit_price,
                    currency: obj.currency
                });
            }
            map[key] = vals;                    
            return map;
        }, {});

        return tiers;
    }

    handleObjectFieldSelect(event) {
        this.selectedField = event.detail.value;

        getFieldContentToTranslate({recordId: this.recordId, objectName: this.objectApiName, fieldName: this.selectedField})
            .then(result => {
                this.fieldContentToTranslate = result;
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleSourceLanguageSelect(event) {
        this.resetProperties();
        
        this.selectedSourceLanguage = this.codeToLanguage[event.detail.value];
        this.selectedSourceLanguageCode = event.detail.value;
        this.selectedTargetLanguageCode = null;

        const validLangs = this.pairs[event.detail.value];
        
        if (validLangs) {
            const langs = [];

            validLangs.forEach(key => {
                langs.push({
                    label: this.codeToLanguage[key],
                    value: key
                });
            });

            langs.sort((a, b) => {
                if(a.label < b.label) { return -1; }
                if(a.label > b.label) { return 1; }
                return 0;
            });

            this.targetLangs = langs;
        } else {
            this.targetLangError = true;
        }
    }

    handleTargetLanguageSelect(event) {
        this.selectedTargetLanguageCode = event.detail.value;
        this.selectedTargetLanguage = this.codeToLanguage[event.detail.value];
        const key = this.selectedSourceLanguageCode + ':' + this.selectedTargetLanguageCode;
        this.tiersForSelection = this.tierPrices[key];

        if (this.tiersForSelection) {
            const tiers = [];

            this.tiersForSelection.forEach((obj) => {
                const label = obj.tier.charAt(0).toUpperCase() + obj.tier.slice(1) + ' (' + parseFloat(obj.unitPrice).toFixed(2) + '/word ' + obj.currency + ')';
                tiers.push({
                    label: label,
                    value: obj.tier
                });
            });

            this.availableTiers = tiers; 
        }
    }

    handleTierSelect(event) {
        this.selectedTier = event.detail.value;
        this.showSubmitTranslationButton = true;
    }

    getJobDetail() {
        return {
            "type": "text",
            "slug": "Translation :: " + this.selectedSourceLanguage + ' to ' + this.selectedTargetLanguage,
            "sourceContent": this.fieldContentToTranslate,
            "sourceLanguageCode": this.selectedSourceLanguageCode,
            "targetLanguageCode": this.selectedTargetLanguageCode,
            "sourceLanguage": this.selectedSourceLanguage,
            "targetLanguage": this.selectedTargetLanguage,
            "tier": this.selectedTier,
            "autoApprove": 0,
            "customData": this.recordId + "|" + this.objectApiName + "|" + this.selectedField
        };
    }

    getPayloadData(jobs) {
        return {
            "relatedRecordId": this.recordId,
            "objectName": this.objectApiName,
            "fieldName": this.selectedField,
            "jobs": jobs
        }
    }

    postTranslation() {
        const jobDetail = this.getJobDetail();
        const data = this.getPayloadData([jobDetail]);

        submitTranslation({ payload: JSON.stringify(data) } )
            .then(result => {
                console.log('TRANS RES: ', result);
                
                this.resetAllProperties();

                if (result.status === 'ok') {
                    this.showNotification('Success', 'Translation submission was successful', 'success');
                    this.showSuccessMessage = true;
                } else {
                    this.showNotification('Error', 'An error occurred during the submission of your translation.', 'error');
                    this.showSuccessMessage = false;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    showNotification(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });

        this.dispatchEvent(event);
    }

    handleTranslationListClick(event) {
        console.log('CLICK TRANSLATION LIST LINK');
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Translation'
            }
        });
    }
}