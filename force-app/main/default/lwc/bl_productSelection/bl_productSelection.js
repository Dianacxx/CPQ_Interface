import { LightningElement, api , track} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getProductLevels  from '@salesforce/apex/QuoteController.getProductLevels'; 
const EXAMPLES_DATA_BASIC = [
    {
        name: 'Id000001',
        level2: 'Product 1',
        _children: [
            {
                name: 'Id000001-Idc00001',
                level3: 'OSP Cable Assemblies child',
                selectionType: 'filtered',
                filteredGrouping: 'Permise Cable',
                isAdd: [false, true, true, true],
            },
        ],
    },

    {
        name: '01t8A000007bfBaQAI',
        level2: 'Product 2',
        _children: [
            {
                name: '01t8A000007bfBaQAI',
                level3: 'Titan RTD',
                _children: [
                    {
                        name: '01t8A000007bfBfQAI',
                        level4: 'Titan RTD Child 1',
                        selectionType: 'bundle',
                        isAdd: [false, true, true, true],
                    },
                    {
                        name: '01t8A000007bfBkQAI',
                        level4: 'Titan RTD Child 2',
                        selectionType: 'filtered',
                        filteredGrouping: 'ADSS Cable',
                        isAdd: [false, true, true, true],
                    },
                ],
            },

            {
                name: '2-B',
                level3: 'Nodeflex',
                _children: [
                    {
                        name: '2-B-A',
                        level4: 'Nodeflex Child 1',
                        selectionType: 'filtered',
                        filteredGrouping: 'ADSS Cable',
                        isAdd: [false, true, true, true],
                    },
                    {
                        name: '2-B-B',
                        level4: 'Nodeflex Child 2',
                        selectionType: 'bundle',
                        isAdd: [false, true, true, true],
                    },
                ],
            },
        ],
    },

    {
        name: '3',
        level2: 'Product 3',
        _children: [
            {
                name: '3-A',
                level3: 'Product 3 child',
                selectionType: 'filtered',
                filteredGrouping: 'Loose Tube Cable',
                isAdd: [false, true, true, true],
            },
        ],
    },

    {
        name: '4',
        level2: 'Product 4',
        _children: [
            {
                name: '4-A',
                level3: 'Titan RTD',
                _children: [
                    {
                        name: '4-A-A',
                        level4: 'Titan RTD Child 1',
                        selectionType: 'filtered',
                        filteredGrouping: 'SkyWrap Cable',
                        isAdd: [false, true, true, true],
                    },
                    {
                        name: '4-A-B',
                        level4: 'Titan RTD Child 2',
                        selectionType: 'bundle',
                        isAdd: [false, true, true, true],
                    },
                ],
            },

            {
                name: '4-B',
                level3: 'Nodeflex',
                _children: [
                    {
                        name: '4-B-A',
                        level4: 'Nodeflex Child 1',
                        selectionType: 'filtered',
                        filteredGrouping: 'Permise Cable',
                        isAdd: [false, true, true, true],
                    },
                    {
                        name: '4-B-B',
                        level4: 'Nodeflex Child 2',
                        selectionType: 'filtered',
                        filteredGrouping: 'Wrapping Tube Cable',
                        isAdd: [false, true, true, true],
                    },
                ],
            },
        ],
    },
];

export default class Bl_productSelection extends NavigationMixin(LightningElement) {
    @api recordId; //Quote Record Id that opens the UI
    @api quotelinesString; //Quotelines information in string
    @api quoteNotesString; //Quotelines Notes in string 

    @api girdDataFirstTab; 
    connectedCallback(){
        /*
        getProductLevels({level1: 'OCA'})
        .then((data)=>{
            let tempData = JSON.parse(data);
            console.log('DATA: ' + data);
            for ( let i = 0; i < tempData.length; i++ ) {
                //tempData[ i ].selectionType = 'filtered'; 
                //tempData[ i ].isAdd = [false, true, true, true];
                tempData[ i ]._children = JSON.parse(tempData[ i ][ 'children' ]);
                for (let j = 0; j< tempData[ i ]._children.length; j++){
                    if ( JSON.parse(tempData[ i ]._children[ j ][ 'children' ]) == null) {
                        //THIS LINE GOES ONCE IS FULL
                        tempData[ i ]._children[ j ].selectionType = 'filtered';
                        tempData[ i ]._children[ j ].id = tempData[ i ].id+'-'+tempData[ i ]._children[ j ].id;
                        tempData[ i ]._children[ j ].isAdd = [false, true, true, true];
                    }
                    else {
                        tempData[ i ]._children[ j ]._children = JSON.parse(tempData[ i ]._children[ j ][ 'children' ]);
                        //console.log('i: '+ i + ' j: '+ j);
                        //console.log('Children of childre: '+ JSON.stringify(tempData[ i ]._children[ j ]._children));
                        tempData[ i ]._children[ j ].id = tempData[ i ].id+'-'+tempData[ i ]._children[ j ].id;
                        for (let k = 0; k< tempData[ i ]._children[ j ]._children.length; k++){
                            //THIS LINE GOES ONCE IS FULL
                            tempData[ i ]._children[ j ]._children[ k ].selectionType = 'filtered';
                            tempData[ i ]._children[ j ]._children[ k ].id = tempData[ i ]._children[ j ].id+'-'+tempData[ i ]._children[ j ]._children[ k ].id;
                            tempData[ i ]._children[ j ]._children[ k ].isAdd = [false, true, true, true];
                        }
                        delete tempData[ i ]._children[j].children;
                    }
                }
                delete tempData[ i ].children;
            }
            this.girdDataFirstTab = tempData;
            console.log('Edited DATA: '+JSON.stringify(this.girdDataFirstTab));
            this.girdDataFirstTab = EXAMPLES_DATA_BASIC; //BORRAR ESTO CUANDO YA LA DATA ESTE BIEN
        })
        .catch((error)=>{
            console.log(error);
            this.girdDataFirstTab = EXAMPLES_DATA_BASIC;
        })
        */
        
    }

    @api productId; 
    handleProductSelectionBundle(){

        //let link = '/apex/sbqq__sb?scontrolCaching=1&id=' + this.recordId + '#quote/le?qId=' + this.recordId; //To QLE of quote. 
        //To Configure Products of a Bundle one
        this.productId = '01t8A000007c76KQAQ';
        let link2 = '/apex/sbqq__sb?id='+this.recordId+'&tour=&isdtp=p1&ltn_app_id=06m8A0000004jM5QAI&clc=0#/product/pc?qId='+this.recordId+'&aId=a5e8A000000EK29QAG&pId='+this.productId+'&redirectUrl=LineEditor&open=0';
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: link2,
                recordId : this.recordId,
            }
        })
    }
    //When click cancel button in Product Selection UI
    handleCancel(){
        this.dispatchEvent(new CustomEvent('cancelps'));
    }
    //When click Save and Exit button in Product Selection UI
    handleSaveAndExit(){
        this.dispatchEvent(new CustomEvent('saveandexit'));
    }
    
    
}