import {PartitionedColumnList} from "./bits_vertical_infinite";

import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";

QUnit.module('Bits Vertical Infinite Test');

QUnit.test('List Partitioning', function(){
	var list = new PartitionedColumnList();
	var firstColumn;
	list.resetColumnsAndAppend(3, [1,2,3,4,5,6,7,8,9]);
	
	QUnit.deepEqual(list.columns().attr(), [[1,4,7], [2,5,8], [3,6,9]], 'Initial partitioning');
	
	list.resetColumns(5);

	QUnit.deepEqual(
		list.columns().attr(),
		[[1, 6], [2, 7], [3, 8], [4, 9], [5]],
		'Changing column count'
	);

	list.append([10, 11]);

	QUnit.deepEqual(
		list.columns().attr(),
		[[1, 6, 11], [2, 7], [3, 8], [4, 9], [5, 10]],
		'Appending Data'
	);

	list.resetColumns();

	QUnit.deepEqual(
		list.columns().attr(),
		[[1, 6, 11], [2, 7], [3, 8], [4, 9], [5, 10]],
		"Reseting columns with the same data and column count produces same results"
	);

	list.prepend([1001, 1002, 1003]);

	QUnit.deepEqual(
		list.columns().attr(),
		[[1, 6, 11], [2, 7], [3, 8], [4, 9], [5, 10]],
		"Prepending data will not change columns immediately"
	);

	list.resetColumns();

	QUnit.deepEqual(
		list.columns().attr(),
		[[1001, 3, 8], [1002, 4, 9], [1003, 5, 10], [1, 6, 11], [2, 7]],
		"Prepended data will be in the columns after we reset them"
	);

	list.prependImmediately([2001, 2002, 2003, 2004, 2005, 2006, 2007]);

	QUnit.deepEqual(
		list.columns().attr(),
		[[2006, 2001, 1001, 3, 8], [2007, 2002, 1002, 4, 9], [2003, 1003, 5, 10], [2004, 1, 6, 11], [2005, 2, 7]],
		"Prepended data is added immediately"
	);

	list.setLimit(17);

	firstColumn = list.columns()[0];

	QUnit.deepEqual(
		list.columns().attr(),
		[[2006, 2001, 1001, 3], [2007, 2002, 1002, 4], [2003, 1003, 5], [2004, 1, 6], [2005, 2, 7]],
		"Limit is applied to the collection"
	);

	QUnit.equal(list.columns()[0], firstColumn, 'Limit changes column lists in place');

	list.resetColumns(3);

	QUnit.deepEqual(
		list.columns().attr(),
		[[2001, 2004, 2007, 1003, 3, 6], [2002, 2005, 1001, 1, 4, 7], [2003, 2006, 1002, 2, 5]],
		"Limit is observed when resetting columns"
	);
	
	QUnit.ok(list.hasDataAfterLimit(), 'List knows when there is data that is not whown');

	list.setLimit(20);

	console.log(list.attr('__allData'))

	QUnit.deepEqual(
		list.columns().attr(),
		[[2001, 2004, 2007, 1003, 3, 6, 9], [2002, 2005, 1001, 1, 4, 7, 10], [2003, 2006, 1002, 2, 5, 8]],
		"Limit can be increased"
	);

	list.setLimit(Infinity);

	QUnit.deepEqual(
		list.columns().attr(),
		[[2001, 2004, 2007, 1003, 3, 6, 9], [2002, 2005, 1001, 1, 4, 7, 10], [2003, 2006, 1002, 2, 5, 8, 11]],
		"Limit can be set to infinity"
	);
});

