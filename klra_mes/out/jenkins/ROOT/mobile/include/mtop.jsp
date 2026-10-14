	<script>
	 $(function(){
		 $(".mobile-data-color li").click(function(){
			var tabType = $(this).index();
			$('.mobile-data').hide();
			$('.mobile-data').eq(tabType).show();
			
			if( tabType > 0) {
				$('.mobile-data-color li').eq(1).css({'color':'#ea552b'});
			}else {
				$('.mobile-data-color li').eq(1).css({'color':'#666666'});
			}
			if( tabType > 1) {
				$('.mobile-data-color li').eq(2).css({'color':'#ea552b'});
			}else  {
				$('.mobile-data-color li').eq(2).css({'color':'#666666'});
			}
			if( tabType > 0) {
				$('.label-btn label').eq(0).css({'display':'none'});
			}else {
				$('.label-btn label').eq(0).css({'display':'block'});
			}
			if( tabType > 1) {
				$('.label-btn label').eq(1).css({'display':'none'});
				$('.label-btn label').eq(2).css({'display':'none'});
			}else {
				$('.label-btn label').eq(1).css({'display':'block'});
				$('.label-btn label').eq(2).css({'display':'block'});
			}
		}); 
		
		/* $('.mobile-departure').show();
		$('label[for="data1"]').click(function(){
			$(this).hide();
			$('label[for="data2"]').show();
			$('label[for="data3"]').show();
			$('.mobile-data-color li').eq(1).css({'color':'#ea552b'});
			$('.mobile-data').hide();
			$('.mobile-data').eq(1).show();
		}); */
		$('label[for="data3"]').click(function(){
			$('label[for="data2"],label[for="data3"]').hide();
			$('label[for="data4"],label[for="data5"]').show();
			$('.mobile-data-color li').eq(2).css({'color':'#ea552b'});
			$('.mobile-data').hide();
			$('.mobile-data').eq(2).show();
		});
		$('label[for="data2"]').click(function(){
			$(this).hide();
			$('label[for="data1"]').show();
			$('.mobile-data-color li').eq(1).css({'color':'#666666'});
			$('.mobile-data').hide();
			$('.mobile-data').eq(0).show();
		});
		$('label[for="data4"]').click(function(){
			$('label[for="data4"],label[for="data5"]').hide();
			$('label[for="data2"],label[for="data3"]').show();
			$('.mobile-data-color li').eq(2).css({'color':'#666666'});
			$('.mobile-data').hide();
			$('.mobile-data').eq(1).show();
		});
 	}); 
	</script>
    <div class="mbile_header">
		<button class="submenu_all"><img src="/mobile/images/mobile-menu02.png" /></button>
		<button class="mobile-user"><img src="/mobile/images/logo01.png" /></button>
		<!-- <button class="mobile-user"><img src="/redeess/images/mobile-user.png" /></button> -->
	</div>
    