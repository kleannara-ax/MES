$(function(){
	/*상단 언어선택 시작*/
	$('a').click(function(e){
		var href = $(this).attr("href");
		if(href == "#" || href == ""){
			e.preventDefault();
		}
	});
	
	$('.drop_select > div > a').on('click focusin', function(){
		$(this).parent().css('height','auto');
		$(this).parent().parent().find('ul').css('margin-top','-35px');
		$(this).parent().parent().find('ul').css('position','relative');
	});
	$('.drop_select > ul a').on('click', function(){
		$(this).parent().parent().parent().removeAttr("style");
		$(this).parent().parent().parent().find('ul').removeAttr("style");
	});
	
	$('.drop_select > ul a').focusin(function(){
		$(this).parent().parent().parent().css('height','auto');
		$(this).parent().parent().parent().find('ul').css('margin-top','-35px');
		$(this).parent().parent().parent().find('ul').css('position','relative');
	});
	
	$('.drop_select > ul a').focusout(function(){
		$(this).parent().parent().parent().removeAttr("style");
		$(this).parent().parent().parent().find('ul').removeAttr("style");
	});

	$(".drop_select").focusout(function(){
		$(this).removeAttr("style");
		$(this).find('ul').removeAttr("style");
	});
	
	$(".drop_select > ul").hover(function(){
		$(this).parent().css('height','auto');
		},function(){
			$(this).parent().removeAttr("style");
			$(this).parent().find('ul').removeAttr("style");
		});
	/*상단 언어선택 끝*/
	
	/*서브 왼쪽메뉴 컨트롤 시작*/	
	$('#left_layout .left_control li.btn_1depth a').click(function(){
		$("#left_layout").animate({"width":"28px"},500);
		$("#contents_layout .left_bg").animate({"width":"1px"},500);
		$("#left_layout .left_navi").animate({"width":"1px"},500);
		$("#contents_layout").animate({"padding-left":"1px"},500);
		$("#contents_layout .grid_dynamic .grid_scroll").animate({"left":"41px"},500);
		$("#left_layout .left_control li.btn_1depth").css("display","none");
		$("#left_layout .left_control li.btn_2depth.left").css("display","none");
		$("#left_layout .left_control li.btn_2depth.right").css("display","block");
		$("#left_layout .left_control li.btn_3depth").css("display","block");
		$("#left_layout .left_control li.btn_1depth").removeClass('small');
		$('#left_layout .left_control li.btn_3depth').removeClass('small');
		setTimeout(function(){
			$("#left_layout .left_navi").addClass('small');
			},500);
	});
	$('#left_layout .left_control li.btn_2depth a').click(function(){
		$("#left_layout").animate({"width":"85px"},500);
		$("#contents_layout .left_bg").animate({"width":"58px"},500);
		$("#left_layout .left_navi").animate({"width":"58px"},500);
		$("#contents_layout").animate({"padding-left":"58px"},500);
		$("#contents_layout .grid_dynamic .grid_scroll").animate({"left":"95px"},500);
		$("#left_layout .left_control li.btn_1depth").css("display","block");
		$("#left_layout .left_control li.btn_2depth.left").css("display","none");
		$("#left_layout .left_control li.btn_2depth.right").css("display","none");
		$("#left_layout .left_control li.btn_3depth").css("display","block");
		$("#left_layout .left_control li.btn_1depth").addClass('small');
		$('#left_layout .left_control li.btn_3depth').addClass('small');
		$('#left_layout .depth2_ul').css("display","none");
		$('#left_layout .depth3_ul').css("display","none");
		$('#left_layout .depth1_ul > li').removeAttr("style");
		$('#left_layout .depth1_ul > li').removeClass('on');
		setTimeout(function(){
			$("#left_layout .left_navi").addClass('small');
			},500);
	});
	$('#left_layout .left_control li.btn_3depth a').click(function(){
		$("#left_layout").animate({"width":"207px"},500);
		$("#contents_layout .left_bg").animate({"width":"180px"},500);
		$("#left_layout .left_navi").animate({"width":"180px"},500);
		$("#contents_layout").animate({"padding-left":"180px"},500);
		$("#contents_layout .grid_dynamic .grid_scroll").animate({"left":"220px"},500);
		$("#left_layout .left_control li.btn_1depth").css("display","block");
		$("#left_layout .left_control li.btn_2depth.left").css("display","block");
		$("#left_layout .left_control li.btn_2depth.right").css("display","none");
		$("#left_layout .left_control li.btn_3depth").css("display","none");
		$("#left_layout .left_control li.btn_1depth").removeClass('small');
		$('#left_layout .left_control li.btn_3depth').removeClass('small');
		$('#left_layout .depth2_ul').css("display","none");
		$('#left_layout .depth3_ul').css("display","none");
		$('#left_layout .depth1_ul > li').removeAttr("style");
		$('#left_layout .depth1_ul > li').removeClass('on');
		$("#left_layout .left_navi").removeClass('small');
	});
	
	$('#left_layout .depth1_ul > li > h2 > a').click(function(){
		if($('#left_layout').css('width') == "207px"){
			var depth1_height = 0;
			if($(this).parent().parent().find('.depth2_ul').css('height') > "0px"){
				depth1_height = 23;
				}
			$('#left_layout .depth2_ul').css("display","none");
			$('#left_layout .depth3_ul').css("display","none");
			$('#left_layout .depth1_ul > li').removeAttr("style");
			$('#left_layout .depth2_ul > li').removeAttr("style");
			$('#left_layout .depth1_ul > li').removeClass('on');
			$('#left_layout .depth2_ul > li').removeClass('on');
			$(this).parent().parent().addClass('on');
			$(this).parent().parent().animate({"height":($(this).parent().parent().find('.depth2_ul').height()) + $(this).parent().height()+depth1_height},500);
			$(this).parent().parent().find('.depth2_ul').css("display","inline-block");
			}else if($('#left_layout').css('width') == "85px"){
				$("#left_layout").animate({"width":"207px"},500);
				$("#contents_layout .left_bg").animate({"width":"180px"},500);
				$("#left_layout .left_navi").animate({"width":"180px"},500);
				$("#contents_layout").animate({"padding-left":"180px"},500);
				$("#left_layout .left_control li.btn_1depth").css("display","inline-block");
				$("#left_layout .left_control li.btn_2depth.left").css("display","inline-block");
				$("#left_layout .left_control li.btn_2depth.right").css("display","none");
				$("#left_layout .left_control li.btn_3depth").css("display","none");
				$("#left_layout .left_control li.btn_1depth").removeClass('small');
				$('#left_layout .left_control li.btn_3depth').removeClass('small');
				$('#left_layout .depth2_ul').css("display","none");
				$('#left_layout .depth3_ul').css("display","none");
				$('#left_layout .depth1_ul > li').removeAttr("style");
				$('#left_layout .depth2_ul > li').removeAttr("style");
				$('#left_layout .depth1_ul > li').removeClass('on');
				$('#left_layout .depth2_ul > li').removeClass('on');
				$("#left_layout .left_navi").removeClass('small');
				$(this).parent().parent().addClass('on');
				$(this).parent().parent().animate({"height":$(this).parent().parent().find('.depth2_ul').height() + $(this).parent().height()+depth1_height},500);
				$(this).parent().parent().find('.depth2_ul').css("display","block");
				}
	});
	
	$('#left_layout .depth2_ul > li > a').click(function(){
		var depth1_height = 0;
		if($(this).parent().parent().parent().find('.depth2_ul').css('height') > "0px"){
			depth1_height = 23;
			}
		/*
		$('#left_layout .depth3_ul').css("display","none");
		$(this).parent().parent().parent().css("height",$(this).parent().parent().height() + $(this).parent().parent().parent().find('h2').height() + depth1_height);
		$('#left_layout .depth2_ul > li').removeAttr("style");
		$('#left_layout .depth1_ul > li').removeClass('on');
		$('#left_layout .depth2_ul > li').removeClass('on');
		$('#left_layout .depth3_ul > li').removeClass('on');
		$(this).parent().addClass('on');
		$(this).parent().parent().parent().addClass('on');
		$(this).parent().parent().parent().animate({"height":$(this).parent().parent().height() + $(this).parent().parent().parent().find('h2').height() + depth1_height + $(this).parent().find('.depth3_ul').height()},500);
		if($(this).parent().find('ul').attr("class") == "depth3_ul"){
			$(this).parent().animate({"height":$(this).parent().find('.depth3_ul').height() + $(this).parent().height() + 12},500);	
		}else{
			$(this).parent().animate({"height":$(this).parent().find('.depth3_ul').height() + $(this).parent().height()},500);			
		}
		$(this).parent().find('.depth3_ul').css("display","block");
		*/
		$('#left_layout .depth3_ul').css("display","none");
		$(this).parent().parent().parent().css("height",$(this).parent().parent().parent().find('.depth2_ul').height() + $(this).parent().parent().parent().find('h2').height() + depth1_height);
		$('#left_layout .depth2_ul > li').removeAttr("style");
		$('#left_layout .depth1_ul > li').removeClass('on');
		$('#left_layout .depth2_ul > li').removeClass('on');
		$(this).parent().addClass('on');
		$(this).parent().parent().parent().addClass('on');
		$(this).parent().find('.depth3_ul').css("display","block");
		$(this).parent().parent().parent().animate({"height":($(this).parent().parent().parent().find('.depth2_ul').height()) + $(this).parent().parent().parent().find('h2').height()+depth1_height},500);
		$('#left_layout .depth3_ul').css("display","none");
		$(this).parent().css("height",$(this).height());
		$(this).parent().find('.depth3_ul').css("display","block");
		if($(this).parent().find('ul').attr("class") == "depth3_ul"){
			$(this).parent().animate({"height":$(this).parent().find('.depth3_ul').height() + $(this).parent().find('a').height() + 12},500);	
		}else{
			$(this).parent().animate({"height":$(this).parent().find('.depth3_ul').height() + $(this).parent().find('a').height()},500);			
		}
	});
	
	$('#left_layout .depth3_ul > li > a').click(function(){
		$('#left_layout .depth3_ul > li').removeClass('on');
		$(this).parent().addClass('on');
	});
	/*서브 왼쪽메뉴 컨트롤 끝*/
	
	/*로케이서 드롭메뉴 시작*/
	$("#lcation_menu > li > a").on('click focusin', function(){
		$(this).parent().css('height','auto');
		$(this).parent().find(".drop_menu").css('top','0px');
		$(this).parent().css('overflow','visible');
	});
	$("#lcation_menu > li > a").focusout(function(){
		$(this).parent().removeAttr("style");
		$(this).parent().find(".drop_menu").removeAttr("style");
		$(this).parent().removeAttr("style");
	});
	$("#lcation_menu > li .drop_menu a").focusin(function(){
		$(this).parent().parent().parent().parent().css('height','auto');
		$(this).parent().parent().parent().css('top','0px');
		$(this).parent().parent().parent().parent().css('overflow','visible');
	});
	$("#lcation_menu > li .drop_menu").focusout(function(){
		$(this).parent().removeAttr("style");
		$(this).removeAttr("style");
		$(this).parent().removeAttr("style");
	});
	$("#lcation_menu > li .drop_menu").hover(function(){
		$(this).parent().css('height','auto');
		$(this).parent().find(".drop_menu").css('top','0px');
		$(this).parent().css('overflow','visible');
		},function(){
			$(this).parent().css('height','15px');
			$(this).parent().find(".drop_menu").css('top','19px');
			$(this).parent().css('overflow','hidden');
		});
	/*로케이서 드롭메뉴 끝*/
	
	/*검색박스 더보기/감추기 시작*/
	$('.search_wrap > .btn.more a').click(function(){
		$('.search_wrap > .btn.more').css('display','none');
		$('.search_wrap > .btn.hide').css('display','block');
		$('.search_wrap .search_basics').css('border-bottom','0px');
		$('.search_wrap .search_skip').css('display','inline-block');
		//$('.search_wrap .search_skip').css('top',($('.search_wrap .search_basics').height()+27));
		//$('.search_wrap > .btn.hide').css('top',($('.search_wrap .search_basics').height()+27+$('.search_wrap .search_skip').height()+27));
	});
	$('.search_wrap > .btn.hide a').click(function(){
		$('.search_wrap > .btn.more').css('display','block');
		$('.search_wrap > .btn.hide').css('display','none');
		$('.search_wrap .search_basics').removeAttr("style");
		$('.search_wrap .search_skip').css('display','none');
		//$('.search_wrap .search_skip').removeAttr("style");
		//$('.search_wrap > .btn.hide').removeAttr("style");
	});
	
	$('.code_view > .code_view_btn a.btn_m').click(function(){
		$('.code_view > .code').css('display','none');
		$('.code_view > .code_view_btn a.btn_h').css('display','none');
		$('.code_view > .code_view_btn a.btn_m').css('display','block');
		$(this).parent().parent().find('.code_view_btn a.btn_m').css('display','none');
		$(this).parent().parent().find('.code_view_btn a.btn_h').css('display','block');
		$(this).parent().parent().find('.code').css('display','block');
		$(this).parent().parent().css('height','auto');
	});
	$('.code_view > .code_view_btn a.btn_h').click(function(){
		$(this).parent().parent().find('.code_view_btn a.btn_m').css('display','block');
		$(this).parent().parent().find('.code_view_btn a.btn_h').css('display','none');
		$(this).parent().parent().find('.code').css('display','none');
		$(this).parent().parent().css('height','1px');
	});	
	/*검색박스 더보기/감추기 끝*/
	
	/*로그인 공지탭 시작*/
	$('#contents_layout .tab_wrap .tab_con.n1 .btn a').click(function(){
		$('#contents_layout .tab_wrap .tab_con.n1').addClass("on");
		$('#contents_layout .tab_wrap .tab_con.n2').removeClass("on");
	});
	
	$('#contents_layout .tab_wrap .tab_con.n2 .btn a').click(function(){
		$('#contents_layout .tab_wrap .tab_con.n2').addClass("on");
		$('#contents_layout .tab_wrap .tab_con.n1').removeClass("on");
	});
	/*로그인 공지탭 끝*/
	
	/*로그인 아이디/비밀번호 텍스트 시작*/
	$('#contents_layout .contents_wrap .login_wrap .idpw li label').on('click focusin', function(){
		$(this).css('left','-99999px');
	});
	$('#contents_layout .contents_wrap .login_wrap .idpw li input').on('click focusin', function(){
		$(this).parent().find('label').css('left','-99999px');
	});
	$("#contents_layout .contents_wrap .login_wrap .idpw li input").focusout(function(){
		if( $(this).val() == "" ){
			$(this).parent().find('label').css('left','0px');
		}
	});
	/*로그인 아이디/비밀번호 텍스트 끝*/
	
	/*input박스 타이틀 숨기기 시작*/
	$('.input_skipTitle > label').click(function(){
		$(this).css('left','-99999px');
	});
	$('.input_skipTitle > input').click(function(){
		$(this).parent().find('label').css('left','-99999px');
	});
	$(".input_skipTitle > input").focusout(function(){
		if( $(this).val() == "" ){
			$(this).parent().find('label').css('left','0px');
		}
	});	
	/*input박스 타이틀 숨기기 끝*/
	
	/*레이어 팝업 시작*/	
	$('.pop_open1').click(function(){
		$('#layer_pop1').css('display','block');
		$('#layer_pop1 .pop_wrap').css('margin-top', -(($('#layer_pop1 .pop_wrap').height())/2));
		$('#layer_pop1 .pop_wrap').css('margin-left', -((($('#layer_pop2 .pop_body').width())+60)/2));
		$('#layer_pop1 .pop_wrap .close_btn').css('width', $('#layer_pop1 .pop_wrap').width());
	});
	$(".pop_close1").on('click focusout', function(){
		$('#layer_pop1').css('display','none');
	});
	
	$('.pop_open2').click(function(){
		$("#layer_pop2").css('display','block');
		$('#layer_pop2 .pop_wrap').css('margin-top', -(($('#layer_pop2 .pop_wrap').height())/2));
		$('#layer_pop2 .pop_wrap').css('margin-left', -((($('#layer_pop2 .pop_body').width())+60)/2));
	});
	$(".pop_close2").on('click focusout', function(){
		$(this).parent().parent().parent().css('display','none');
	});
	
	$('.pop_open3').click(function(){
		$('#layer_pop3').css('display','block');
		$('#layer_pop3 .pop_wrap').css('margin-top', -(($('#layer_pop3 .pop_wrap').height())/2));
		$('#layer_pop3 .pop_wrap').css('margin-left', -((($('#layer_pop2 .pop_body').width())+60)/2));
	});
	$(".pop_close3").on('click focusout', function(){
		$("#layer_pop3").css('display','none');
	});	
	
	$('.pop_open4').click(function(e){
		e.preventDefault();
		var pop_name = $(this).attr("href").substring(1);
		$("#layer_pop4."+pop_name).css('display','block');
		$("#layer_pop4."+pop_name+" .pop_wrap").css('margin-top', -(($("#layer_pop4."+pop_name+" .pop_wrap").height())/2));
		$("#layer_pop4."+pop_name+" .pop_wrap").css('margin-left', -((($("#layer_pop4."+pop_name+" .pop_body").width())+60)/2));
	});
	$("#layer_pop4 .pop_close").on('click focusout', function(){
		$(this).parent().parent().parent().css('display','none');
	});
	/*레이어 팝업 끝*/
	
	
	/*공통 그리드 팝업 시작*/
	$('.open_search_pop_option').click(function(){
		$('.search_pop_option').css('display','block');
		$('.search_pop_option .pop_wrap').css('width', ($('.search_pop_option .pop_body').width())+60);

		$('.search_pop_option .pop_wrap').css('margin-top', -(($('.search_pop_option .pop_wrap').height())/2));
		$('.search_pop_option .pop_wrap').css('margin-left', -(($('.search_pop_option .pop_body').width())/2));
	});
	$(".search_pop_option .colse_pop").on('click focusout', function(){
		$(".search_pop_option").css('display','none');
	});
	
	
	$('.open_grid_pop_layout').click(function(){
		$('.grid_pop_layout').css('display','block');
		$('.grid_pop_layout .pop_wrap').css('width', ($('.grid_pop_layout .pop_body').width())+60);
		$('.grid_pop_layout .pop_wrap').css('margin-top', -(($('.grid_pop_layout .pop_wrap').height())/2));
		$('.grid_pop_layout .pop_wrap').css('margin-left', -(($('.grid_pop_layout .pop_body').width())/2));
	});
	$(".grid_pop_layout .colse_pop").on('click focusout', function(){
		$(".grid_pop_layout").css('display','none');
	});
	/*공통 그리드 팝업 끝*/
	
	
	/* 탭 시작 */
	$('.tab_box').each(function() {
		$(this).find('.tab_con:first').parent('.tab_con').addClass('on');
	});
	$('.tab_box .tab_wrap').each(function() {
		$(this).find('.tab_con:first').parent('.tab_con').addClass('on');
	});
	$('.tab_box .tab_wrap .tab_btn > a').click(function(){
			$(this).parent().parent().siblings().removeClass('on');
			$(this).parent().parent().addClass('on');		
	});
	
	/*
	$('.tab_box2').each(function() {
		$(this).find('.tab_btn li:first').addClass('on');
		$(this).find('.tab_con:first').addClass('on');
	});
	$('.tab_box2 .tab_btn > li > a').click(function(e){
		if ($(this).attr("href") == "#" || $(this).attr("href") == "")
		{
			$(this).parent().siblings().removeClass('on');
			$(this).parent().addClass('on');
			e.preventDefault();
			$(this).parent().parent().parent().find(".tab_con").removeClass("on");
			if ($(this).parent().attr("class") == "b1 on"){				
				$(this).parent().parent().parent().find(".tab_con.t1").addClass("on");
			}else if ($(this).parent().attr("class") == "b2 on"){				
				$(this).parent().parent().parent().find(".tab_con.t2").addClass("on");
			}else if ($(this).parent().attr("class") == "b3 on"){				
				$(this).parent().parent().parent().find(".tab_con.t3").addClass("on");
			}else if ($(this).parent().attr("class") == "b4 on"){				
				$(this).parent().parent().parent().find(".tab_con.t4").addClass("on");
			}else if ($(this).parent().attr("class") == "b5 on"){				
				$(this).parent().parent().parent().find(".tab_con.t5").addClass("on");
			}else if ($(this).parent().attr("class") == "b6 on"){				
				$(this).parent().parent().parent().find(".tab_con.t6").addClass("on");
			}else if ($(this).parent().attr("class") == "b7 on"){				
				$(this).parent().parent().parent().find(".tab_con.t7").addClass("on");
			}else if ($(this).parent().attr("class") == "b8 on"){				
				$(this).parent().parent().parent().find(".tab_con.t8").addClass("on");
			}else if ($(this).parent().attr("class") == "b9 on"){				
				$(this).parent().parent().parent().find(".tab_con.t9").addClass("on");
			}else if ($(this).parent().attr("class") == "b10 on"){				
				$(this).parent().parent().parent().find(".tab_con.t10").addClass("on");
			}
		}
	});
	*/
	/* 탭 끝 */
	
	
	/* 그리드 클릭 배경 시작 */
	$('.grid_scroll > .grid_body > table > tbody > tr td').click(function(){
		if($(this).parent().attr("class") == "on"){
			$(this).parent().removeClass('on');
		}else{
			$(this).parent().addClass('on');
		}
	});	
	/* 그리드 클릭 배경 끝 */
	
});

/*공지사항 롤링 시작*/
jQuery(function() {
		jQuery("#srolling").srolling({
			data : $("#txt_wrap > div"),  // 노출될 아이템
			auto : true,                    //자동 롤링 true , false
			width : 100+'%',                 // 노출될 아이템 크기
			height : 40,                    // 노출될 아이템 크기
			item_count : 1,         // 이동 될 아이템 수
			cache_count : 1,            // 임시로 불러올 아이템 수
			delay : 1000,               // 이동 아이템 딜레이
			delay_frame : 500,      // 아이템 흐르는 속도
			move : 'top',               // 이동 방향 left , right , top , down
			prev : '#p_click',          // < 이동 버튼
			next : '#n_click'           // > 이동 버튼
		});
	});
/*공지사항 롤링 시작*/


/*그리드 리스트 넘 시작*/
function grid_list(gd){
	var list_num = gd.value;
	var gd_id = gd.id;
	var $grid = $(".grid_scroll."+gd_id+" .grid_body");
	if(list_num == 10){	
		$grid .addClass("list_10");
		$grid .removeClass("list_20");
		$grid .removeClass("list_50");
		$grid .removeClass("list_100");
	}else if(list_num == 20){
		$grid.addClass("list_20");
		$grid.removeClass("list_10");
		$grid.removeClass("list_50");
		$grid.removeClass("list_100");
	}else if(list_num == 50){
		$grid.addClass('list_50');
		$grid.removeClass('list_10');
		$grid.removeClass('list_20');
		$grid.removeClass('list_100');
	}else if(list_num == 100){
		$grid.addClass('list_100');
		$grid.removeClass('list_10');
		$grid.removeClass('list_20');
		$grid.removeClass('list_50');
	}
	gridList.scrollResize();
}
/*그리드 리스트 넘 끝*/