import { LightningElement, api } from 'lwc';

export default class TranslationListItem extends LightningElement {
    @api translationListItem;

    handleClick(event) {
        event.preventDefault();
        const selectedEvent = new CustomEvent('selected', {
            detail: this.translationListItem.id
        });
        this.dispatchEvent(selectedEvent);
    }
}