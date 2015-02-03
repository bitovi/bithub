steal(
'can/component',
'./sidebar.stache!',
'models',
'./sidebar.less!',
'components/services',
'can/route',
'components/helpers.js',
function(Component, initView, Models){

	var KEYMAP = {
		13 : 'ENTER',
		27 : 'ESC'
	};

	var INTEGRATION_TEMPLATE = '<a href="http://{embedEndpoint}/admin/embed?tenantName={tenantName}&hubId={hubId}" data-hub-id="{hubId}" data-tenant-name="{tenantName}" class="bithub-embed">{hubName} Embed</a><script src="http://{embedEndpoint}/admin/embed.js"></script>'

	return Component.extend({
		tag : 'bh-sidebar',
		template : initView,
		scope : {
			isEditing: false,
			init : function(){
				var self = this;
				Models.Brand.findOne({}).then(function(brand){
					self.attr('currentBrand', brand);
				});
				if(this.attr('state.hubId')){
					Models.Hub.findOne({
						id: this.attr('state.hubId')
					}).then(function(hub){
						self.attr('hub', hub);
					});
				} else {
					throw "No Hub selected";
				}
			},
			toggleHubEditing : function(ctx, el, ev){
				var newVal = !this.attr('isEditing');
				newVal && this.attr('hub').backup();
				this.attr('isEditing', newVal);
				ev.stopPropagation();
			},
			preventHubEditingToggle : function(ctx, el, ev){
				ev.stopPropagation();
			},
			restoreOrSave : function(ctx, el, ev){
				var key = KEYMAP[ev.which];

				if(key === 'ENTER'){
					this.attr('hub').attr('name', el.val());
					this.attr('hub').save();
				} else {
					this.attr('hub').restore();
				}

				key && this.attr('isEditing', false);
			},
			toggleSidebarPosition : function(ctx, el, ev){
				this.attr('state.sidebarIsExpanded', !this.attr('state.sidebarIsExpanded'));
			},
			integrationCode : function(){
				var currentBrand = this.attr('currentBrand');
				var hub = this.attr('hub');
				var tenantName, hubId;
				if(currentBrand && hub){
					return can.sub(INTEGRATION_TEMPLATE, {
						tenantName: currentBrand.attr('tenant_name'),
						embedEndpoint: EMBED_ENDPOINT,
						hubName: hub.attr('name'),
						hubId: hub.attr('id')
					});
				}
			}
		},
		events : {
			inserted : 'setPanelHeight',
			'{window} resize' : 'setPanelHeight',
			'{can.route} panel' : 'setPanelHeight',
			'{scope} hub' : 'setPanelHeight',
			setPanelHeight: function(){
				var self = this;
				setTimeout(function(){
					if(!self.element){
						return;
					}
					var containerHeight = self.element.height(),
						headerHeight = self.element.find('.header').outerHeight(),
						hubNameHeight = self.element.find('.hub-name-wrap').outerHeight() + 29, // height + margin
						linksHeight = (1 * 37),
						totalHeight = headerHeight + hubNameHeight + linksHeight + 50; // add padding
					self.element.find('.panel-container').height(containerHeight - totalHeight)
				}, 1);
			},
			'{scope} isEditing' : function(scope, ev, newVal){
				var self = this;
				if(newVal){
					setTimeout(function(){
						self.element && self.element.find('.hub-name').select().focus();
					}, 100);
				}
			}
		},
		helpers : {
			linkToPanel : function(panel){
				panel = can.isFunction(panel) ? panel() : panel;
				return can.route.url({panel: panel}, true);
			},
			isPanel : function(panel, opts){
				panel = can.isFunction(panel) ? panel() : panel;
				return panel === this.attr('state.panel') ? opts.fn(this) : opts.inverse(this);
			}
		}
	});
});
