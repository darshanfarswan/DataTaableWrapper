import { LightningElement, api, track } from 'lwc';

export default class RunCustomDataTable extends LightningElement {

    @track objectName = '';
    @track fieldsToQuery = '';
    @track filter = '';
    @track recordsPerPage = 10;
    @track disableSort = false;
    @track disableSearch = false;
    @track objectNameToSend;
    @track fieldNamesToSend;
    @track filtersToSend;
    @track recordsPerPageToSend;
    @track disableSortToSend;
    @track disableSearchToSend;

    handleObjectNameChange(event) {
        this.objectName = event.target.value;
    }

    handleObjectFieldsChange(event) {
        this.fieldsToQuery = event.target.value;
    }

    handleFilterChange(event) {
        this.filter = event.target.value;
    }
    handleRecordsPerPageChange(event) {
        this.recordsPerPage = event.target.value;
    }
    handleSortChange(event) {
        this.disableSort = event.target.checked;
    }
    handleSearchChange(event) {
        this.disableSearch = event.target.checked;    }

    handleClick(event) {
        this.objectNameToSend = this.objectName;
        this.fieldNamesToSend = this.fieldsToQuery;
        this.filtersToSend = this.filter;
        this.recordsPerPageToSend = this.recordsPerPage;
        this.disableSortToSend = this.disableSort;
        this.disableSearchToSend = this.disableSearch;
    }

}