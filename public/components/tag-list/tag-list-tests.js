steal('funcunit', './tag-list.js', function(F, AppState){
	var tags;

	QUnit.module('Tag List', {

		beforeEach : function(){
			var template = can.stache('<bh-tag-list tags="{tags}"></bh-tag-list>');

			tags = new can.List;

			$('#qunit-fixture').html(template({
				tags : tags
			}));
		},
		afterEach : function(){

		}
	});

	QUnit.test('Tag List is shown', 1, function(assert){
		QUnit.stop();
		F('bh-tag-list').exists(function(){
			assert.ok(true);
			QUnit.start();
		});
	});

	QUnit.test('Tag List works', 1, function(assert){
		QUnit.stop();
		F('bh-tag-list').exists();
		F('bh-tag-list').click();
		F('bh-tag-list input').type('FOO ');
		F.wait(1, function(){
			assert.deepEqual(tags.attr(), ['FOO']);
			QUnit.start();
		})
	})
});