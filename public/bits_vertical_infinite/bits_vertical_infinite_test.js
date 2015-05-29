import PartitionedColumnList from "./partitioned_column_list";

import QUnit from "steal-qunit";
import F from "funcunit";
import $ from "jquery";

QUnit.module('Bits Vertical Infinite Test');

QUnit.test('List Partitioning', function(){
	var sourceList = new can.List();
	var list = new PartitionedColumnList(sourceList);
	var firstColumn;

	list.resetColumns(3);

	QUnit.equal(sourceList, list.source(), 'PartitionedColumnList keeps pointer to the sourceList');
	
	sourceList.push(1,2,3,4,5,6,7,8,9);

	QUnit.deepEqual(list.columns().attr(), [[1,4,7], [2,5,8], [3,6,9]], 'Initial partitioning');
	
	list.resetColumns(5);

	QUnit.deepEqual(
		list.columns().attr(),
		[[1, 6], [2, 7], [3, 8], [4, 9], [5]],
		'Changing column count'
	);

	sourceList.push(10, 11);

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


	list.prependPaused(true);
	sourceList.unshift(1001, 1002, 1003);

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

	list.prependPaused(false);
	sourceList.unshift(2001, 2002, 2003, 2004, 2005, 2006, 2007);

	QUnit.deepEqual(
		list.columns().attr(),
		[[2006, 2001, 1001, 3, 8], [2007, 2002, 1002, 4, 9], [2003, 1003, 5, 10], [2004, 1, 6, 11], [2005, 2, 7]],
		"Prepended data is added immediately"
	);
	
	
	list.setLimitAndFillColumns(17);

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
	
	QUnit.ok(list.hasDataAfterLimit(), 'List knows when there is data that is not shown');

	list.setLimitAndFillColumns(20);

	QUnit.deepEqual(
		list.columns().attr(),
		[[2001, 2004, 2007, 1003, 3, 6, 9], [2002, 2005, 1001, 1, 4, 7, 10], [2003, 2006, 1002, 2, 5, 8]],
		"Limit can be increased"
	);

	list.setLimitAndFillColumns(Infinity);

	QUnit.deepEqual(
		list.columns().attr(),
		[[2001, 2004, 2007, 1003, 3, 6, 9], [2002, 2005, 1001, 1, 4, 7, 10], [2003, 2006, 1002, 2, 5, 8, 11]],
		"Limit can be set to infinity"
	);

	list.resetColumns(5);

	sourceList.splice(2, 0, 3000);
	sourceList.splice(13, 0, 3001);

	QUnit.deepEqual(
		list.columns().attr(),
		[[2001, 2005, 1003, 4, 9],[2002, 2006, 1, 5, 10],[3000, 2007, 2, 6, 11],[2003, 1001, 3001, 7],[2004, 1002, 3, 8]],
		"Randomly inserted data is added immediately"
	);
	
	sourceList.splice(13, 1);
	
	QUnit.deepEqual(
		list.columns().attr(),
		[[2001, 2005, 1003, 4, 9],[2002, 2006, 1, 5, 10],[3000, 2007, 2, 6, 11],[2003, 1001, 7],[2004, 1002, 3, 8]],
		"Data removed from the source list is removed from the columns"
	);
});

QUnit.test('Pausing prepend and restarting the content', function(){
	var sourceList = new can.List();
	var list = new PartitionedColumnList(sourceList);

	list.prependPaused(true);
	sourceList.unshift(1,2,3,4,5,6);

	QUnit.deepEqual(list.columns().attr(), [], "No data in columns");

	list.resetColumns(4);

	QUnit.deepEqual(
		list.columns().attr(),
		[[1, 5], [2, 6], [3], [4]],
		"Data is partitioned"
	);

	list.PER_PAGE = 2;

	list.resetColumns(4, true);

	QUnit.deepEqual(
		list.columns().attr(),
		[[1], [2], [], []],
		"Data is partitioned and limited"
	);
});
