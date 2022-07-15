import { LightningElement, api, track} from 'lwc';

export default class Lwc_AddressForm extends LightningElement {

    @api ratesData;
    @track formData = {
      requestedShipment:{
        shipper:{
          address:{

          }
        },
        recipient:{
          address:{

          }
        },
        requestedPackageLineItems:[{}]
      }
    };
    @track error;
    @track isMissingRequiredData = true;

    handleSubmitClick(){
        const addressSubmitEvent = new CustomEvent("addresssubmitevent", {
          detail: this.formData
        });
        this.dispatchEvent(addressSubmitEvent);
    }

    handleShipperInputChange(event) {
        var streetAddressArray = event.target.street.includes(',') ? event.target.street.split(',') : [event.target.street, ''] ;
        var addressLine1 = streetAddressArray[0];
        var addressLine2 = streetAddressArray[1].trim();
        this.formData.requestedShipment.shipper.address = {
            streetLines: [addressLine1, addressLine2],
            city: event.target.city,
            stateOrProvinceCode: event.target.province,
            postalCode: event.target.postalCode,
            countryCode: event.target.country,
            residential: true
          }
        this.checkAllFields();
    }

    handleRecipientInputChange(event) {
        var streetAddressArray = event.target.street.includes(',') ? event.target.street.split(',') : [event.target.street, ''] ;
        var addressLine1 = streetAddressArray[0];
        var addressLine2 = streetAddressArray[1].trim();
        this.formData.requestedShipment.recipient.address = {
            streetLines: [addressLine1, addressLine2],
            city: event.target.city,
            stateOrProvinceCode: event.target.province,
            postalCode: event.target.postalCode,
            countryCode: event.target.country,
            residential: true
          }
        this.checkAllFields();
    }

    handleWeightInputChange(event) {
        this.formData.requestedShipment.requestedPackageLineItems = [
            {
              weight: {
                units: "LB",
                value: event.detail.value
              }
            }
          ];
        this.checkAllFields();
    }

    checkAllFields(){
      var includesAllRequiredData = !!this.formData.requestedShipment.requestedPackageLineItems[0].weight 
          && !!this.formData.requestedShipment.recipient.address.streetLines
          && !!this.formData.requestedShipment.recipient.address.city
          && !!this.formData.requestedShipment.recipient.address.stateOrProvinceCode
          && !!this.formData.requestedShipment.recipient.address.postalCode
          && !!this.formData.requestedShipment.recipient.address.countryCode
          && !!this.formData.requestedShipment.shipper.address.streetLines
          && !!this.formData.requestedShipment.shipper.address.city
          && !!this.formData.requestedShipment.shipper.address.stateOrProvinceCode
          && !!this.formData.requestedShipment.shipper.address.postalCode
          && !!this.formData.requestedShipment.shipper.address.countryCode;
      this.isMissingRequiredData = !includesAllRequiredData
      
    }
}