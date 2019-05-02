import { LightningElement, api, track } from 'lwc';

export default class GengoTranslate extends LightningElement {
    @api fieldName;
    @api recordId;
    @api objectApiName;

    @track langs;
    @track pairs;

    connectedCallback() {
        console.log('RECORD ID: ', this.recordId);
        console.log('OBJECT: ', this.objectApiName);
        console.log('FIELD: ', this.fieldName);
    }

    handleStart() {
        console.log('IN START');

        // Do call to apex to fetch language pairs
        // 
        const result = arr.reduce(function(map, obj) {
            var vals = map[obj.lc_src] || [];
            if (vals.indexOf(obj.lc_tgt) === -1) {
                    vals.push(obj.lc_tgt);
            }
            map[obj.lc_src] = vals;
            return map;
        }, {});
    }
}