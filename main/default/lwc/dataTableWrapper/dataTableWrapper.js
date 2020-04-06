import { LightningElement, api, track, wire } from 'lwc';
import getRecords from '@salesforce/apex/DataTableWrapperController.getRecords';
import getFieldDetails from '@salesforce/apex/DataTableWrapperController.getFieldDetails';

export default class DemoApp extends LightningElement {
    @track viewRecords;
    @track allRecords;
    @track columns;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;
    @track recordCount = 0;
    @track beginIndex = 0;
    @track endndex = 0;
    @track currentPage = 0;
    @track totalPages = 0;
    @track disableBack = true;
    @track disableForward = true;
    @track errorMessage = '';
    @track hasError = false;
    @api objectName;
    @api fieldToQuery;
    @api filters;
    @api recordsPerPage = 10;

    @wire (getRecords, {objectName : '$objectName', fieldToQuery : '$fieldToQuery', filters : '$filters'})
    wiredRecords({error, data}) {
        this.shasError = false;
        this.errorMessage = '';
        if (data) {
            var allRecords = [];
            for (var record in data) {
                allRecords.push(data[record]);
            }
            this.allRecords = allRecords;
            this.recordCount = allRecords.length;
            this.totalPages = Math.ceil(this.recordCount / this.recordsPerPage);
            this.filterRecords(0);
        } else if (error) {
            console.log(error);
            this.hasError = true;
            this.errorMessage = error.body.exceptionType + ' ' + error.body.message + ' ' + error.body.stackTrace;
        }
    };

    @wire (getFieldDetails, {objectName : '$objectName', fieldToQuery : '$fieldToQuery', filters : '$filters'})
    wiredFields({error, data}) {
        this.hasError = false;
        this.errorMessage = '';
        var columns = [];
        if (data) {
            for (var fieldName in data) {
                var fieldLabel = data[fieldName]["label"];
                var fieldDisplaytype = data[fieldName]["displaytype"];
                var fieldApiName = data[fieldName]["apiname"];
                columns.push({
                    label: fieldLabel,
                    fieldName: fieldApiName,
                    type: fieldDisplaytype,
                    sortable: true
                });
            }
            this.columns = columns;
        } else if (error) {
            console.log(error);
            this.hasError = true;
            this.errorMessage = error.body.exceptionType + ' ' + error.body.message + ' ' + error.body.stackTrace;
        }
    };

    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };
        return function(a, b) {
            a = key(a) === undefined ? "" : key(a);
            b = key(b) === undefined ? "" : key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.allRecords];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.allRecords = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.filterRecords(0);

    }

    goToFirst(event) {
        this.filterRecords(0);
    }

    goToPrevious(event) {
        var newIndex = (this.beginIndex - this.recordsPerPage);
        newIndex--;
        this.filterRecords(newIndex);
    }

    goToNext(event) {
        var newIndex = (this.beginIndex + this.recordsPerPage);
        newIndex--;
        this.filterRecords(newIndex);
    }

    goToLast(event) {
        var newIndex = (this.totalPages-1) * this.recordsPerPage;
        this.filterRecords(newIndex);
    }

    filterRecords(startingIndex) {
        var viewRecords = [];
        var endingIndex = startingIndex + this.recordsPerPage;
        if (endingIndex > this.recordCount) {
            endingIndex = this.recordCount;
        }
        this.beginIndex = startingIndex + 1;
        this.endndex = endingIndex;

        var index = startingIndex;
        this.currentPage = Math.ceil(this.beginIndex / this.recordsPerPage);
        while(index < endingIndex) {
            viewRecords.push(this.allRecords[index]);
            index++;
        }
        this.viewRecords = viewRecords;

        this.renderButtons();
    }

    renderButtons() {
        if (this.beginIndex < this.recordsPerPage) {
            this.disableBack = true;
        } else {
            this.disableBack = false;
        }

        if (this.currentPage == this.totalPages) {
            this.disableForward = true;
        } else {
            this.disableForward = false;
        }
    }
}
