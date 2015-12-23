$(function(){
	$('.hamburger').click(function(){
		$('body').toggleClass('sidebar-menu-open')
	});
	$('.read-more').click(function(){
		$(this).parent().siblings('.outer-feature-details-wrap').toggleClass('outer-feature-details-wrap--open');
	});

	$('.close-registration-overlay').click(function(){
		$('body').removeClass('registration-open');
		$('.register-account-overlay').removeClass('register-account-overlay--shown');
	});

	$('.try-it-now,.open-registration-overlay').click(function(){
		$('.register-account-overlay').addClass('register-account-overlay--shown');
		setTimeout(function(){
			$('body').addClass('registration-open');
		});
		return false;
	});
	$('.intro-wrap').click(function(){
		var width = $(window).width();
		var $el = $(this);
		var panel = $el.data('panel');
		if(width > 760){
			$('.features-wrap').removeClass('active-feature-connect active-feature-moderate active-feature-publish').addClass('active-feature-' + panel);
		}
	});
});
