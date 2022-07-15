import { LightningElement, api } from 'lwc';
import getShippingRates from '@salesforce/apex/cls_FedEx_Callout.getShippingRates';

export default class Lwc_ShippingRatesAppContainer extends LightningElement {

    @api rates = [];

    handleSubmit(event){
        var formData = JSON.stringify(event.detail);
        getShippingRates({jsonInputData: formData})
            .then(result => {
                console.log(result.statusCode);
                if(result.statusCode == 200){
                    this.rates = result.data;
                } else {
                    alert('There may be an issue with your request. Check all fields and try again.');
                }
                
            })
            .catch(error => {
                this.error = error;
            });
    }
}