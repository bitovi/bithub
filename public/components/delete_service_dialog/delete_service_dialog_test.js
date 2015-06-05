import {DeleteServiceDialogVM} from "./delete_service_dialog";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";

var template = can.stache("<bh-delete-service-dialog service='{service}' state='{state}'></bh-delete-service-dialog>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

var Service = can.Model.extend({
	destroy : function(){
		ok(true, 'Destroy called');
	}
});

var State = can.Map.extend({
	resetEmbed : function(){
		ok(true, 'Reset Embed called');
	}
});

QUnit.module("Delete Service Dialog Tests");

QUnit.test('Alert panel is rendered correctly', function(){
	renderTemplate({
		service: new Service()
	});

	F('bh-delete-service-dialog h3').text('Delete Service', 'Title is rendered');
	F('bh-delete-service-dialog button[disabled]').missing('Buttons are not disabled');
});

QUnit.test('Clicking delete will destroy the service', 1, function(){
	renderTemplate({
		service: new Service()
	});
	F('bh-delete-service-dialog [can-click=deleteService]').click();
});

QUnit.test('Clicking cancel will clear the service', function(){
	renderTemplate({
		service: new Service()
	});
	F('bh-delete-service-dialog [can-click=cancelDelete]').click();
	F.wait(1, function(){
		equal(F('bh-delete-service-dialog').scope().attr('service'), null, 'Service is cleared');
	});
});

QUnit.test('Clicking delete will disable the buttons and show the spinner', function(){
	renderTemplate({
		service: new Service()
	});
	F('bh-delete-service-dialog [can-click=deleteService]').click();
	F('bh-delete-service-dialog button[can-click=cancelDelete][disabled]').exists('Cancel button is disabled');
	F('bh-delete-service-dialog button[can-click=deleteService][disabled]').exists('Delete service button is disabled');
	F('bh-delete-service-dialog .fa-circle-o-notch').exists('Spinner exists');
});

QUnit.test('Triggering destroy on service will clear the service from the VM', 2, function(){
	var service = new Service();
	var state = new State();
	renderTemplate({
		service : service,
		state : state
	});
	F.wait(1, function(){
		service.destroyed();
		equal(F('bh-delete-service-dialog').scope().attr('service'), null, 'Service is cleared');
	});
});
