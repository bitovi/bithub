import can from "can";
export default can.Model.extend({
	findAll : '/api/v3/services/suggestions/{service}?brand_identity_id={brandIdentityId}'
}, {});
