( function( $ ) {
$( document ).ready(function() {
	$('#user_wrap table.tdOpen').on('click', function(){
			var element = $(this).parent('div');
			
			if (element.hasClass('open')) {
				element.removeClass('open');
				element.find('li').removeClass('open');
				element.find('ul').slideUp();
				element.find('img').attr('src','/mobile/img/ico/arr_2.png');
			}else {
				element.addClass('open');
				element.children('ul').slideDown();
				element.siblings('li').children('ul').slideUp();
				element.siblings('li').removeClass('open');
				element.siblings('li').find('li').removeClass('open');
				element.siblings('li').find('ul').slideUp();
				element.find('img').attr('src','/mobile/img/ico/arr_1.png');	
			}
		});
	
	});
} )( jQuery );
