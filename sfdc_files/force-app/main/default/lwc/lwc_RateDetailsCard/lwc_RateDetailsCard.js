import { LightningElement, api } from 'lwc';

export default class Lwc_RateDetailsCard extends LightningElement {
    @api rate;
    @api netPrice;
    connectedCallback(){
        this.netPrice = this.rate.ratedShipmentDetails[0].totalNetCharge
    }
}