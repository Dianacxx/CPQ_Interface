import { LightningElement, track, api , wire} from 'lwc';

//MOCK DATA
import fetchAccounts from '@salesforce/apex/blMockData.fetchAccounts';

export default class Bl_treeProducts extends LightningElement {

    @track gridData; //MOCK DATA
    @track columns; 
    connectedCallback(){
        //MOCK DATA FOR TREE
        this.columns = [
            { type: 'text', fieldName: 'Name', label: 'Level 2' , initialWidth: 350,},
            { type: 'text', fieldName: 'FirstName', label: 'Level 3', initialWidth: 200,},
            { type: 'text', fieldName: '_children.Level', label: 'Level 4', initialWidth: 200,},
            { type: 'action', typeAttributes: { rowActions: this.getRowActions }, initialWidth: 50, },
        ]
        fetchAccounts()
        .then((data) => {
            if ( data ) {
                var tempData = JSON.parse( JSON.stringify( data ) );
                for ( var i = 0; i < tempData.length; i++ ) {
                    tempData[ i ]._children = tempData[ i ][ 'Contacts' ];
                    console.log('Childrens: '+ Object.getOwnPropertyNames(tempData[ i ]._children));
                    
                    for(var j =0;j<tempData[ i ]._children.length; j++){
                        tempData[ i ]._children[j]._children = {"Level":"Level 4" };
                        console.log('Nietos: '+  tempData[ i ]._children[j]._children); 
                    } 
                    
                    delete tempData[ i ].Contacts;
                }
                this.gridData = tempData;
            } else if ( error ) {
                if ( Array.isArray( error.body ) )
                    console.log( 'Error is ' + error.body.map( e => e.message ).join( ', ' ) );
                else if ( typeof error.body.message === 'string' )
                    console.log( 'Error is ' + error.body.message );
            }
        });
    }

    getRowActions(row, doneCallback) {
        if(row.level == 1) {
          doneCallback([{ label: 'View', name: 'view' }]);
          console.log('LEVEL 2');
        }
        if(row.level == 2) {
          doneCallback([
              { label: 'Add', name: 'add' },
              { label: 'Clone', name: 'clone' },
              { label: 'Edit', name: 'edit' },
              { label: 'Delete', name: 'delete' },                 
          ]);
          console.log('LEVEL 3');
        }
        if(row.level == 3) {
            doneCallback([
                { label: 'Add', name: 'add' },
                { label: 'Clone', name: 'clone' },
                { label: 'Edit', name: 'edit' },
                { label: 'Delete', name: 'delete' },                 
            ]);
            console.log('LEVEL 4');
          }
      }

    //Tree View Collapse or Expand
    clickToExpandAll( e ) {
        const grid =  this.template.querySelector( 'lightning-tree-grid' );
        grid.expandAll();
    }

    clickToCollapseAll( e ) {
        const grid =  this.template.querySelector( 'lightning-tree-grid' );
        grid.collapseAll();
    }

}