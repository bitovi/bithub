
var Q = require('q');

var getRandomInt = function(min, max) {
	return Math.floor(Math.random() * (max - min)) + min; 
}

var  waitForTimeout = function(timeout){
	return function(){
		var deferred = Q.defer();
		setTimeout(function(){
			deferred.resolve();
		}, timeout);
		return deferred.promise;
	}
};

describe('Smoketest', function() {

	var integrationCode;

	it('Will open the index page', function() {
		return browser.url('/');
	}); 

	it('Will enter the data for a new user', function(){
		return Q.all([
			browser.setValue('[name="account[name]"]', "Mihael"),
			browser.setValue('[name="account[email]"]', "konjevic+" + getRandomInt(1, 20000) + "@gmail.com"),
			browser.setValue('[name="account[password]"]', "Welcome123"),
			browser.setValue('[name="account[password_confirmation]"]', "Welcome123"),
		]);
	});

	it('Will submit a new user form', function(){
		return browser.submitForm('#new_account');
	});

	it('Will wait until the admin page is loaded', function(){
		return browser.waitForExist('[can-click="createAndEditHub"]')
	});

	it('Will click a button to create a new hub', function(){
		return browser.click('[can-click="createAndEditHub"]');
	});

	it('Will wait until sidebar is loaded', function(){
		return browser.waitForExist('bh-sidebar [data-feed="rss"]');
	});

	it('Will enter data for a new RSS feed', function(){
		return browser.click('bh-sidebar [data-feed="rss"]').then(function(){
			return browser.setValue('[can-value="map.config.url"]', 'http://retroaktive.me/rss');
		});
	});

	it('Will save a new RSS feed', function(){
		return browser.click('.save-service');
	});

	it('Will wait until data is loaded', function(){
		return browser.frame(0).then(function(){
			return browser.waitForExist('bh-bit',  60 * 1000  /* 1 minute */);
		}).then(function(){
			return browser.frameParent();
		});
	});

	it('Will click the add a Twitter feed button', function(){
		return browser.click('bh-sidebar [data-feed="twitter"]');
	});
	
	it('Will select a hashtag search', function(){
		return browser.selectByValue('[can-value="type_name"]', 'hashtag');
	});

	it('Will wait until the OAuth button is visible', function(){
		return browser.waitForExist('button.oauthorize');
	});

	it('Will click the OAuth button', function(){
		return browser.click('button.oauthorize');
	});

	it('Will switch to the popup', function(){
		return browser.windowHandles().then(function(handles){
			var popupHandle = handles.value[1];
			return browser.window(popupHandle);
		});
	});

	it('Will wait until the login form is available', function(){
		return browser.waitForExist('[name="session[username_or_email]"]');
	})

	it('Will enter the login data', function(){
		return Q.all([
			browser.setValue('[name="session[username_or_email]"]', 'MirkoSlavko1337'),
			browser.setValue('[name="session[password]"]', 'hunter2.io')
		]);
	});

	it('Will click the login button', function(){
		return browser.click('#allow');
	});

	it('Will switch to the original window', function(){
		return browser.windowHandles().then(function(handles){
			var popupHandle = handles.value[0];
			return browser.window(popupHandle);
		});
	});

	it('Will wait until the hashtag form field is available', function(){
		return browser.waitForExist('[can-value="map.config.hashtag"]');
	});

	it('Will enter the hashtag', function(){
		return browser.setValue('[can-value="map.config.hashtag"]', 'canjs');
	});

	it('Will save a new Twitter feed', function(){
		return browser.click('.save-service');
	});

	it('Will wait until Twitter items are available', function(){
		return browser.waitForExist('[src="images/social-empty/twitter.png"]', 1000000);
	})

	it('Will switch to the moderation tab', function(){
		return browser.click('a=Moderation').then(function(){ // Click Moderation link
			return browser.waitForExist('label=No. I want all items blocked by default.');
		});
	});

	it('Will wait a second before continuing', waitForTimeout(1000));

	it('Will change the embed default', function(){
		return browser.click('label=No. I want all items blocked by default.');
	});
	
	it('Will wait a second before continuing', waitForTimeout(1000));
	
	it('Will save the embed default', function(){
		return browser.click('bh-moderation .btn-save-moderation');
	});

	it('Will wait until items are blocked', function(){
		return browser.frame(0).then(function(){
			return browser.waitForExist('bh-bit .blocked');
		});
	});
	
	it('Will wait a second before continuing', waitForTimeout(1000));

	it('Will wait for toggleApproveBit element to exist', function(){
		return browser.waitForExist('[can-click="toggleApproveBit"]');
	});
	
	it('Will move the mouse over the toggleApproveBit element', function(){
		return browser.execute(function(){
			$('[can-click="toggleApproveBit"]:first').click();
			return true;
		}).then(function(){
			return browser.frameParent();
		});
	});

	it('Will wait a second before continuing', waitForTimeout(1000));
	
	it('Will switch to the integration tab', function(){
		return browser.click('a=Integration & Design').then(function(){
			return browser.waitForExist('.cc-body');
		});
	});

	it('Will enter CC number', function(){
		return browser.click('[can-value="cc.number"]').then(function(){
			return browser.keys('4242').then(function(){
				return browser.click('[can-value="cc.number"]').then(function(){
					return browser.keys('4242').then(function(){
						return browser.click('[can-value="cc.number"]').then(function(){
							return browser.keys('4242').then(function(){
								return browser.click('[can-value="cc.number"]').then(function(){
									return browser.keys('4242');
								});
							});
						});
					});
				});
			});
		});
	});

	it('Will wait a second before continuing', waitForTimeout(1000));

	it('Will enter Expiration month', function(){
		return browser.click('[can-value="cc.expiration"]', function(){
			return browser.keys('01');
		});
	});

	it('Will enter Expiration year', function(){
		return browser.click('[can-value="cc.expiration"]', function(){
			return browser.keys('2016');
		});
	});

	it('Will enter CC data', function(){
		return browser.setValue('[can-value="cc.cvc"]', '123');
	});

	it('Will click the Publish hub button', function(){
		return browser.click('[can-click="createSubscriptionAndPublishHub"]');
	});

	it('Will wait for the integration to be available', function(){
		return browser.waitForExist('[can-value="defaultIntegrationCode"]');
	});

	it('Will read the integration code', function(){
		return browser.getValue('[can-value="defaultIntegrationCode"]').then(function(val){
			integrationCode = val;
		});
	});

	it('Will wait a second before continuing', waitForTimeout(1000));
	
	it('Will create a new page with the embed', function(){
		return browser.newWindow('about:blank').then(function(){
			return browser.execute(function(code){
				document.write(code);
				setTimeout(function(){
					document.dispatchEvent(new Event('DOMContentLoaded'));
				}, 1000);
			}, integrationCode);
		});
	});

	it('Will wait a second before continuing', waitForTimeout(1000));

	it('Will wait until the embed is loaded', function(){
		return browser.frame(0).then(function(){
			return browser.waitForExist('bh-bit',  60 * 1000  /* 1 minute */);
		});
	});

	it('Will wait ten seconds before exiting', waitForTimeout(10000));
});
