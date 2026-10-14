<%@ page import="com.common.bean.*,com.common.util.*,com.common.bean.CommonConfig,java.util.*"%>
<%
	DataMap paramDataMap = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);
	if(paramDataMap == null){
		paramDataMap = new DataMap(request);
	}
	String menuId = paramDataMap.getString(CommonConfig.MENU_ID_KEY);
	String langky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_LANGUAGE_KEY);
	String wareky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_WHAREHOUSE_KEY);
	String ownrky = (String)request.getSession().getAttribute(CommonConfig.SES_USER_OWNER_KEY);
	String theme =(String)request.getSession().getAttribute(CommonConfig.SES_USER_THEME_KEY);
%>
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<link rel="stylesheet" href="/pop/css/layer_grid.css" type="text/css" />
<link rel="stylesheet" href="/pop/css/jquery.custom.checkbox.css" type="text/css">
<link rel="stylesheet" href="/pop/css/jquery.select.css" type="text/css">
<link rel="stylesheet" href="/pop/css/content_ui.css" type="text/css">
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.custom.js"></script>
<script type="text/javascript" src="/pop/js/jquery-custom-checkbox-min.js"></script>
<!-- <script type="text/javascript" src="/pop/js/jquery.jqtransform.js"></script>
<script type="text/javascript">
	$(function(){
		// selectbox design
		$('.select').jqTransform();
	});
</script> -->
<script type="text/javascript" src="/common/js/jquery.plugin.js"></script>
<script type="text/javascript" src="/common/js/jquery.form.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/jquery.mousewheel.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/big.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js"></script>
<script type="text/javascript" src="/common/js/site.js"></script>
<script type="text/javascript" src="/common/js/commonUtil.js"></script>
<script type="text/javascript" src="/common<%=theme%>/js/theme.js"></script>
<script type="text/javascript" src="/common/js/dataBind.js"></script>
<script type="text/javascript" src="/common/js/input.js"></script>
<script type="text/javascript" src="/common/js/netUtil.js"></script>
<script type="text/javascript" src="/common/js/ui.js"></script>
<script type="text/javascript" src="/common/js/worker-ajax.js"></script>
<script type="text/javascript" src="/common/js/bigdata.js"></script>
<script type="text/javascript" src="/common/js/dataRequest.js"></script>
<script type="text/javascript" src="/common/js/grid.js"></script>
<script type="text/javascript" src="/common/js/layoutSave.js"></script>
<script type="text/javascript" src="/common/js/validateUtil.js"></script>
<script type="text/javascript" src="/common/js/page.js"></script>
<script type="text/javascript" src="/wms/js/wms.js"></script>
<script>
//탭 인덱스 변경
(function() {
	$(function() {
		var tab = $('.tab.type2')
			, tabTrigger = tab.children('a');

		tabTrigger.each(function(i) {

			var zIndex = tabTrigger.length - i;

			$(this).css('zIndex',zIndex);

		});
	});
})();

var topGridHeight = "160px";
//그리드 크기 조절
(function() {
	$(function() {
		var trigger = $('.fullSizer')
		, target1 = $('.bottomSect.top')
		, target1Height = target1.css('height')
		, target2 = $('.bottomSect.bottom')
		, target2OriginTop = target2.css('top');
		
		if(target1.length > 0){
			trigger.eq(0).on({
				click : function() {
					if ( trigger.eq(0).hasClass('folded') ) {
						target1.css({ height : target1Height, bottom : 'auto' });
						target2.css({ top : target2OriginTop, height : 'auto' });
						trigger.eq(0).removeClass('folded');
					} else {
						target1.css({ height : 'auto', bottom : 10 });
						target2.css({ height : 0, top : 'auto' });
						trigger.eq(0).addClass('folded');
					}
				}
			});
		
			trigger.eq(1).on({
				click : function() {
					if ( trigger.eq(1).hasClass('folded') ) {
						target1.css({ height : target1Height, bottom : 'auto' });
						target2.css({ top : target2OriginTop, height : 'auto' });
						trigger.eq(1).removeClass('folded');
					} else {
						target1.css({ height : 0 });
						target2.css({ top : 8 });
						trigger.eq(1).addClass('folded');
					}
				}
			});
		}else{
			target2 = $('.bottomSect');
			target2OriginTop = target2.css('top');
			trigger.eq(0).on({
				click : function() {
					if ( trigger.eq(0).hasClass('folded') ) {
						target2.css({ top : target2OriginTop, height : 'auto' });
						trigger.eq(0).removeClass('folded');
					} else {
						target2.css({ top : 8 });
						trigger.eq(0).addClass('folded');
					}
				}
			});
		}		
	});
})();

// jQuery 탭 기능
(function() {
	$(function() {
		$('.tabs').tabs();
	});
})();


// 검색 팝업
(function() {
	$(function() {
		var trigger = $('#showPop')
			, pop = $('.searchPop')
			, closer = pop.find('.closer');

		trigger.on({
			click : function() {
				pop.stop(true, true).fadeIn(150);
			}
		});

		closer.on({
			click : function() {
				pop.stop(true, true).fadeOut(150);
			}
		});
	});
})();

// 테이블 스크롤
(function() {
	$(function() {
		var table = $('.table.type2');

		table.each(function() {
			var _this = $(this)
				, header = _this.find('.tableHeader')
				, body = _this.find('.tableBody');

			body.on({
				scroll : function(e) {
					var scrollLeft = $(this).scrollLeft();

					//console.log(scrollLeft);
					header.css({
						marginLeft : -scrollLeft
					});
				}
			});
		});
	});
})();

//레인지 팝업
function rangePop() {

	var	pop = $('.layerPopup')
		, closer = pop.find('.closer');

	pop.stop(true, true).fadeIn(150);
	closer.on({
		click : function() {
			pop.stop(true, true).fadeOut(150);
		}
	});
}

function rangePopClose() {
	var	pop = $('.layerPopup');
	pop.stop(true, true).fadeOut(150);
}

// 경고창
function alertMessage() {

	var alert = $('.alertMessage')
		, closer = alert.find('.closer');

	alert.fadeIn(150);

	closer.on({
		click : function() {
			alert.fadeOut(150);
		}
	});
}

// 로딩 열기
function loadingOpen() {

	var loader = $('<div class="contentLoading"></div>').appendTo('body');

	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
}

var $contentLoading;
//로딩 열기
function loadingOpen() {
	
	$contentLoading.show();
}

//로딩 닫기
function loadingClose() {
	
	$contentLoading.hide();
}

function searchOpen(showType){
	var pop = $('.searchPop');
	if(!showType){
		showType = false;
	}
	if (showType) {
		pop.stop(true, true).fadeIn(150);
	} else {
		pop.stop(true, true).fadeOut(150);
	}
}

function showLayoutSave(){
	var loader = $('<div class="contentLayoutSave"></div>').appendTo('body');
	
	loader.stop().animate({
		top : '0px'
	}, 30, function() {
	});
	
    $('#layoutSavePop').show();
}

function hideLayoutSave(){
	 var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
	$('#layoutSavePop').hide();
}

function setTopSize(height){
	$('.bottomSect.top').css("height",height+"px");
	$('.bottomSect.bottom').css("top",(height+20)+"px");
}

configData.MENU_ID = '<%=menuId%>';

function layoutSaveClose(){
	var loader = $('.contentLayoutSave');

	loader.stop().animate({
		top : '100%'
	}, 30, function() {
		loader.remove();
	});
	
    $('#layoutSavePop').hide();
}

</script>
<script type="text/javascript">
	function openPop(target) {
		 var documentWidth = document.documentElement.clientWidth;
		 var documentHeight = document.documentElement.clientHeight;
		 var targetPop = $(".layer_popup");
		 var willLeft = (documentWidth / 2) - (targetPop.width() / 2 + 53);
		 var willTop = (documentHeight / 2) - (targetPop.height() / 2 + 50);
		 var targetPop = $(".layer_popup");
	
		 willLeft = parseInt(willLeft);
		 willTop = parseInt(willTop);
		 targetPop.css({"left": willLeft, "top":willTop});
		 targetPop.show();
	
		 $("body").append("<div class='glayLayer'></div>");
		 $(".glayLayer").show();
	}
	function closePop(target) {
		 var targetPop = $(".layer_popup");
		 targetPop.hide();
		 $(".glayLayer").remove();
	}
	
	$(document).ready(function(){
		try{
			var searchParam = window.opener.page.getSearchParam();
			if(searchParam){
				dataBind.dataNameBind(searchParam, "searchArea");			
			}
		}catch(e){}
		
		$("body").hide();
		
		$contentLoading = jQuery("#contentLoading");
		
		$('.searchPop').stop(true, true).fadeIn(150);	
		
		uiList.UICheck();
		inputList.setCombo();
		inputList.setInput();
		
		gridScroll();
		
		$("body").show();
	});
	
	window.moveTo(0,0);
	var sWidth = window.screen.availWidth;
	var sHeight = window.screen.availHeight;
	
	$(window).resize(function(){
		gridScroll();
	});
	
	window.resizeTo(sWidth,sHeight);
	
	function checkBoxLoad(){
		var body = gebtn(d,'body')[0];
	    body.className = body.className && body.className != '' ? body.className + ' has-js' : 'has-js';
	    
	    if (!d.getElementById || !d.createTextNode) return;
	    var ls = gebtn(d,'label');
	    for (var i = 0; i < ls.length; i++) {
	        var l = ls[i];
	        if (l.className.indexOf('label_') == -1) continue;
	        var inp = gebtn(l,'input')[0];
	        if (l.className == 'label_check') {
	            l.className = (safari && inp.checked == true || inp.checked) ? 'label_check c_on' : 'label_check c_off';
	            l.onclick = check_it;
	        };
	        if (l.className == 'label_radio') {
	            l.className = (safari && inp.checked == true || inp.checked) ? 'label_radio r_on' : 'label_radio r_off';
	            l.onclick = turn_radio;
	        };
	    };
	}
	
	function gridScroll(){
		var scrollObj = document.getElementById('scroll').offsetHeight;
		var scrollTable = document.getElementById('scroll_t').offsetHeight;
		if(scrollObj < scrollTable){
			document.getElementById('scroll').style.right = 3 + "px";
		}else{
			document.getElementById('scroll').style.right = 20 + "px";
		}
	}
	
	function getIntervalDate(date, interval){
		if(date.length > 8){
			while(1){
				if(date.indexOf("-") != -1){
					date = date.replace("-","");
				}else if(date.indexOf(".") != -1){
					date = date.replace(".","");
				}else if(date.indexOf("/") != -1){
					date = date.replace("/","");
				}else{
					break;
				}
			}
		}
		
		var y = date.substring(0,4);
		var m = date.substring(4,6);
		var d = date.substring(6,8);
		
		var today = new Date(y + "/" + m + "/" + d + " 00:00:00");
		today.setDate(today.getDate() + (Number)(interval));
		
		var year = today.getFullYear();
	    var month = today.getMonth()+1;
	    var date = today.getDate();
	    
	    if (month < 10) month = "0" + month;
	    if (date < 10) date = "0" + date;
	    year = year + "";
	    month = month + "";
	    date = date + "";
	    
		var resultDate = year+month+date;
	    return resultDate;
	}
</script>