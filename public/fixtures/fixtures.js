steal(
'can/util/fixture',
function(fixture){

	can.fixture('/api/v3/embeds/{hubId}/entities', "./fixtures/bits.json");
	can.fixture('/api/v3/embeds', "./fixtures/embeds.json");
	can.fixture('/api/v3/identities', "./fixtures/identities.json");
	can.fixture('/api/v3/services', "./fixtures/services.json");

	can.fixture.on = true;
	can.fixture.delay = 0;
});
