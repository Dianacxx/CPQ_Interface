
import LightningDatatable from 'lightning/datatable';
import DatatablePicklistTemplate from './picklistTemplate.html';

export default class Bl_customReviewTable extends LightningDatatable {
    static customTypes = {
        picklist: {
            template: DatatablePicklistTemplate,
            standardCellLayout: true,
            typeAttributes: ['label', 'placeholder', 'options', 'value', 'context', 'variant','name']
        }
    };
}