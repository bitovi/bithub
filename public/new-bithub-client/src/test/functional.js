import F from 'funcunit';
import QUnit from 'steal-qunit';

F.attach(QUnit);

QUnit.module('bithub-client functional smoke test', {
  beforeEach() {
    F.open('../development.html');
  }
});

QUnit.test('bithub-client main page shows up', function() {
  F('title').text('bithub-client', 'Title is set');
});
