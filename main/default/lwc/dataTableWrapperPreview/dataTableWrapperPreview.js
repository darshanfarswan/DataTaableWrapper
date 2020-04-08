import { LightningElement, api, track } from 'lwc';

export default class RunCustomDataTable extends LightningElement {

    @track objectName;
    @track fieldsToQuery;
    @track filter;
    @track objectNameToSend;
    @track fieldNamesToSend;
    @track filtersToSend;

    handleObjectNameChange(event) {
        this.objectName = event.target.value;
    }

    handleObjectFieldsChange(event) {
        this.fieldsToQuery = event.target.value;
    }

    handleFilterChange(event) {
        this.filter = event.target.value;
    }

    handleClick(event) {
        console.log('Changing');
        this.objectNameToSend = this.objectName;
        this.fieldNamesToSend = this.fieldsToQuery;
        this.filtersToSend = this.filter;
    }

}