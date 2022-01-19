import { LightningElement, api , track} from 'lwc';

export default class Bl_listProducts extends LightningElement {

    @api listToDisplay = []; 
    @track openFilterPopup = false; 
    @track openConfiguredPopup = false; 
    connectedCallback(){
        
    }

    constructor() {
        super();
        this.gridColumns = [ 
            { label: '', fieldName: 'lookupCode' ,initialWidth: 200, hideDefaultActions: true}, 
            { type: 'action', typeAttributes: { rowActions: this.getRowActions.bind(this) } },
        ];
    }
    getRowActions(row, doneCallback) {
        const actions = [];
        if (row.isAdd[0] == false && (row.selectionType == 'Filtered' || row.selectionType == 'Configured') ) {
            actions.push({ label: 'Add' , name: 'add', disabled: row.isAdd[0], });
        } 
        else if (row.isAdd[0] == true && (row.selectionType == 'Filtered' || row.selectionType == 'Configured')){
            actions.push(
            { label: 'Clone', name: 'clone', disabled: row.isAdd[1], },
            { label: 'Edit', name: 'edit', disabled: row.isAdd[2],},
            { label: 'Delete', name: 'delete', disabled: row.isAdd[3], },);
        } else {
            actions.push({ label: 'Not Available' , name: 'notavailable', disabled: true, });
        }
        setTimeout(() => {
            doneCallback(actions);
        }, 200);
    }
    
    callRowAction(event){
        //console.log(Object.getOwnPropertyNames(event.detail));
        let row = event.detail.row; //This way is going to edit the real value.
        //console.log('Row '+ Object.getOwnPropertyNames(row));
        //console.log('Row selectionType '+ row.selectionType);
        switch (event.detail.action.name){
            case 'add':
                if (row.selectionType == 'Filtered'){
                    this.openFilterPopup = true; 
                    //console.log('Is filtered');
                } else if (row.selectionType == 'Configured'){
                    //Must save process before turning there
                    this.openConfiguredPopup = true; 
                } else {
                    alert('This row has no type (Filtered or configured)');
                    row.isAdd[0] = true; 
                    row.selectionType = '';
                }
            break; 
            case 'clone':
            break; 
            case 'edit':
            break; 
            case 'delete':
            break; 
            default:
                alert('MEGA ERROR WITH ROW ACTIONS');
            break; 
        }
    }


    //FILTERED POP UP FUNCTIONS
    @track tabOption = false; 
    @track activeFilterTab = 'Filter';
    closeFilterAndSelected(){
        this.openFilterPopup = false;
    }
    moreAdd(){ //Button in pop up that says Add More
        //Change to filter tab
        this.activeFilterTab = 'Filter';
        this.tabOption = false;
    }
    handleFilterTabActive(){ //If user returns to tab clicking in the name
        this.tabOption = false;
    }
    handleReviewTabActive(){ //If user returns to tab clicking in the name
        this.tabOption = true;
    }
    addAndReview(){ //Button in pop up that says Add and Review
        //Change to review tab
        this.activeFilterTab = 'Review';
        this.tabOption = true;
    }

    //CONFIGURED POP UP FUNCTIONS
    closeConfiguredAlert(){
        this.openConfiguredPopup = false; 
    }

    continueCofiguredQLE(){
        //HERE SAVE THE PROCESS BEFORE
        //IF THERE ARE NO ERRORS, GET ID OF PRODUCT IN ROW AND GO TO CONFIGURED PRODUCT 
    }
}