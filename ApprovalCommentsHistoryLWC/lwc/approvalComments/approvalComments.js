import { LightningElement,api,wire } from 'lwc';
import ApprovalCommentsList from '@salesforce/apex/ApprovalCommentsController.ApprovalCommentList';

export default class ApprovalComments extends LightningElement {
    @api recordId;

    mapData = [];
    mapColumns = [
        { label: 'User', fieldName: 'key', type: 'text' },
        { label: 'Comments', fieldName: 'value', type: 'text' }
    ];

    @wire(ApprovalCommentsList, { recordId: '$recordId' })
    wiredMapData({ error, data }) {
        if (data) {
            // Transform the Map into an array of objects for the datatable
            this.mapData = Object.keys(data).map(key => ({ key, value: data[key] }));
        } else if (error) {
            console.error('Error retrieving string map:', error);
        }
    }
}