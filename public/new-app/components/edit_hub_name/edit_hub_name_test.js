import {EditHubNameVM} from "./edit_hub_name";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";

var template = can.stache("<bh-edit-hub-name hub='{hub}'></bh-edit-hub-name>");

var Hub = can.Map.extend({
	save : function(){
		QUnit.ok(true, 'Save Called');
	}
});

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

var renderTemplateAndCheckIfHubNameIsShown = function(){
	renderTemplate({
		hub : new Hub({name: 'Hub Name'})
	});
	F('bh-edit-hub-name h2').text('Hub Name', 'Hub Name is shown');
};

var renderTemplateAndEnterEditingState = function(){
	renderTemplateAndCheckIfHubNameIsShown();
	F('bh-edit-hub-name').click();
};

QUnit.module("Edit Hub Name Tests");

QUnit.test("Hub Name will be shown by default", function(){
	renderTemplateAndCheckIfHubNameIsShown();
});

QUnit.test("Clicking on a component will toggle editing state", function(){
	renderTemplateAndEnterEditingState();
	F('bh-edit-hub-name input').exists('Input field is shown');
});

QUnit.test("Pressing escape inside the input field will exit the editing state and revert the changes", 3, function(){
	renderTemplateAndEnterEditingState();
	F('bh-edit-hub-name input').click().type('aaa[escape]');
	F('bh-edit-hub-name input').missing('Exiting edit state');
	F('bh-edit-hub-name h2').text('Hub Name', 'Name is reverted');
});

QUnit.test("Pressing enter inside the input field will save changes and exit the editing state", 4, function(){
	renderTemplateAndEnterEditingState();
	F('bh-edit-hub-name input').click().type('[\b][\b]foo[enter]');
	F('bh-edit-hub-name input').missing('Exited edit state');
	F('bh-edit-hub-name h2').text('foo', 'Hub name is updated');
});

QUnit.test('Bluring the input field will save changes and exit the editing state', 4, function(){
	renderTemplateAndEnterEditingState();
	F('bh-edit-hub-name input').click().type('[\b][\b]foo');
	F('bh-edit-hub-name input').type('[\t][\t]');
	F('body').click();
	F('bh-edit-hub-name input').missing('Exited edit state');
	F('bh-edit-hub-name h2').text('foo', 'Hub name is updated');
});

QUnit.test('Committing the same name will not trigger save', 0, function(){
	var editVM = new EditHubNameVM({hub: new Hub({name: 'Hub Name'})});
	editVM.commitNewHubName('Hub Name');
});

QUnit.test('Toggling edit state works', function(){
	var editVM = new EditHubNameVM({hub: new Hub({name: 'Hub Name'})});
	editVM.toggleHubEditing();
	ok(editVM.attr('isEditing'), 'Editing State');
	editVM.toggleHubEditing();
	ok(!editVM.attr('isEditing'), 'Exited editing state');
	editVM.toggleHubEditing(false);
	ok(!editVM.attr('isEditing'), 'Did not enter editing state');
});
