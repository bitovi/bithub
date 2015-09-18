import {TagListVM} from "./tag-list";
import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";

var template = can.stache("<bh-tag-list tags='{tags}'></bh-tag-list>");

var renderTemplate = function(data){
	$('#qunit-fixture').html(template(data));
};

var getTags = function(vm){
	return vm.attr('tags').attr();
};

QUnit.module("Tag List Tests");

QUnit.test('Adding tags', function(){
	var tags = new can.List();
	
	renderTemplate({tags: tags});

	F('bh-tag-list').exists();
	F('bh-tag-list').click();
	F('bh-tag-list input').type('FOO ');
	F.wait(1, function(){
		QUnit.assert.deepEqual(tags.attr(), ['FOO']);
	});
});

QUnit.test('Removing tags', function(){
	var tags = new can.List(['tag1', 'tag2']);
	
	renderTemplate({tags: tags});

	F('bh-tag-list input').type('\b');

	F.wait(1, function(){
		QUnit.assert.deepEqual(tags.attr(), ['tag1']);
	});
});

QUnit.test('addTag function', function(){
	var vm = new TagListVM();
	QUnit.assert.deepEqual(getTags(vm), [], 'VM is initalized with empty tag list');
	vm.addTag('foo');
	QUnit.assert.deepEqual(getTags(vm), ['foo'], 'Tag is added');
	vm.addTag('foo');
	QUnit.assert.deepEqual(getTags(vm), ['foo'], 'Duplicate tag entry is prevented');
	vm.addTag(' bar#$');
	QUnit.assert.deepEqual(getTags(vm), ['foo', 'bar'], 'Tags are cleaned before they are added to the list');
	vm.addTag('    bar$$$');
	QUnit.assert.deepEqual(getTags(vm), ['foo', 'bar'], 'Tags are cleaned before checking for duplicates');
});

QUnit.test('removeTag function', function(){
	var vm = new TagListVM({
		tags : ['foo', 'bar', 'baz']
	});
	vm.removeTag();
	QUnit.assert.deepEqual(getTags(vm), ['foo', 'bar'], 'When called without argument removeTag removes last tag from the list');
	vm.removeTag('foo');
	QUnit.assert.deepEqual(getTags(vm), ['bar'], 'When called with argument, removeTag will find the tag in the list and remove it');
	vm.removeTag('foobarbaz');
	QUnit.assert.deepEqual(getTags(vm), ['bar'], 'When called with the non existing tag removeTag function will do nothing');
});
