
var $topArea;
var topHeight;
var topPosition;
var $midArea;
var midHeight;
var midPosition;
var $botArea;
var botHeight;
var botPosition;
var bodyHeight;
var midAreaHeightSet = "300px";

// draggable
$(document).ready(function(){
	$topArea = $('.bottomSect.top');
	$midArea = $('.bottomSect.bottom');
	$botArea = $('.bottomSect.bottomT');
	bodyHeight = commonUtil.getCssNum($("body"), "height");
	topHeight = commonUtil.getCssNum($topArea, "height");

	$midArea.css({height : midAreaHeightSet, top:(topHeight+20)+'px'});

	midHeight = commonUtil.getCssNum($midArea, "height");

	topPosition = commonUtil.getCssNum($topArea, "top");
	midPosition = commonUtil.getCssNum($midArea, "top");

	$botArea.css({height : (bodyHeight-topHeight-midHeight-80)+"px", top:(topHeight+midHeight+30)+'px'});
	botHeight = commonUtil.getCssNum($botArea, "height");

	botPosition = commonUtil.getCssNum($botArea, "top");

	//var num = parseInt((bodyHeight-topHeight-midHeight-70) / bodyHeight * 100)

	var $middleArea = jQuery("#"+configData.MIDDLE_AREA);
	if($middleArea.length > 0){
		$middleArea.draggable({
			axis: "y",
			cursor: "n-resize",
			helper: "none",
			//revert: true,
			start: function(event, ui) {
				var $obj = jQuery(event.target);
				//$obj.text(ui.position.left);
			},
			drag: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {

				}else{
					changeMiddleHeight($obj, ui);
				}
			},
			stop: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {
					changeMiddleHeight($obj, ui);
				}
				setTopHeight($obj, ui);
			}
		});
	}
	var $ThreeArea = $('#commonMiddleArea2')
	if($ThreeArea.length > 0){
		$ThreeArea.draggable({
			axis: "y",
			cursor: "n-resize",
			helper: "none",
			//revert: true,
			start: function(event, ui) {
				var $obj = jQuery(event.target);
				//$obj.text(ui.position.left);
			},
			drag: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {

				}else{
					changeBottomHeight($obj, ui);
				}
			},
			stop: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {
					changeBottomHeight($obj, ui);
				}
				setMiddleHeight($obj, ui);
			}
		});
	}

  var trigger = $('.fullSizer2');
  trigger.eq(0).on({
    click : function(){
      if(trigger.eq(0).hasClass('folded')){
        $('.bottomSect.top').css({"height":"100%","z-index":9999})
        $('.bottomSect.bottom').css({"z-index":0,"height":0})
        $('.bottomSect.bottomT').css({"z-index":0,"height":0})
        trigger.eq(0).removeClass('folded');
      }else{
        $('.bottomSect.top').css({"height":"185px","z-index":0})
        $('.bottomSect.bottom').css({"top":"205px","z-index":0,"height":"300px"})
        $('.bottomSect.bottomT').css({"top":"505px","z-index":0,"height":"333px"})
        trigger.eq(0).addClass('folded');
      }
    }
  })
  trigger.eq(1).on({
    click : function(){
      if(trigger.eq(1).hasClass('folded')){
        $('.bottomSect.top').css({"z-index":0,"height":0})
        $('.bottomSect.bottom').css({"top":"8px","height":"100%","z-index":9999})
        $('.bottomSect.bottomT').css({"z-index":0,"height":0})
        trigger.eq(1).removeClass('folded');
      }else{
        $('.bottomSect.top').css({"height":"185px","z-index":0})
        $('.bottomSect.bottom').css({"top":"205px","top":"202px","height":"300px","z-index":0})
        $('.bottomSect.bottomT').css({"top":"505px","z-index":0,"height":"333px"})
        trigger.eq(1).addClass('folded');
      }
    }
  })
  trigger.eq(2).on({
    click : function(){
      if(trigger.eq(2).hasClass('folded')){
        $('.bottomSect.top').css({"z-index":0,"height":0})
        $('.bottomSect.bottom').css({"z-index":0,"height":0})
        $('.bottomSect.bottomT').css({"top":"8px","height":"100%","z-index":9999})
        trigger.eq(2).removeClass('folded');
      }else{
        $('.bottomSect.top').css({"height":"185px","z-index":0})
        $('.bottomSect.bottom').css({"top":"205px","z-index":0,"height":"300px"})
        $('.bottomSect.bottomT').css({"top":"515px","height":"333px","z-index":0})
        trigger.eq(2).addClass('folded');
      }
    }
  })
});


function changeMiddleHeight($dragObj, ui){
	$topArea.css("height",(topHeight + ui.position.top)+"px");
	$midArea.css("height",(midHeight - ui.position.top)+"px");
	$midArea.css("top",(midPosition + ui.position.top)+"px");
}

function changeBottomHeight($dragObj, ui){
	$midArea.css("height",(midHeight + ui.position.top)+"px");
	$botArea.css("height",(botHeight - ui.position.top)+"px");
	$botArea.css("top",(botPosition + ui.position.top)+"px");
}

function setTopHeight($dragObj, ui){
	var sumHeight = topHeight + midHeight;
	resetHeight();
	if(topHeight < 100){
		$topArea.css("height", "100px");
		$midArea.css("height", (sumHeight - 100)+"px");
		$midArea.css("top", "120px");
	}else if(midHeight < 100){
		$topArea.css("height", (sumHeight - 100)+"px");
		$midArea.css("height", "100px");
		$midArea.css("top", (sumHeight - 100 + 20)+"px");
	}
	resetHeight();
	gridList.scrollResize();
}
function setMiddleHeight($dragObj, ui){
	var sumHeight = midHeight + botHeight;
	resetHeight();
	if(midHeight < 100){
		$midArea.css("height", "100px");
		$botArea.css("height", (sumHeight - 100)+"px");
		$botArea.css("top", (topHeight+100+30)+"px");
	}else if(botHeight < 100){
		$midArea.css("height", (sumHeight - 100)+"px");
		$botArea.css("height", "100px");
		$botArea.css("top", (topHeight + sumHeight - 100 + 20)+"px");
	}
	resetHeight();
	gridList.scrollResize();
}

function resetHeight(){
	topHeight = commonUtil.getCssNum($topArea, "height");
	midHeight = commonUtil.getCssNum($midArea, "height");
	botHeight = commonUtil.getCssNum($botArea, "height");

	topPosition = commonUtil.getCssNum($topArea, "top");
	midPosition = commonUtil.getCssNum($midArea, "top");
	botPosition = commonUtil.getCssNum($botArea, "top");
}

$(window).resize(function(){
    var tmpBodyHeight = commonUtil.getCssNum($("body"), "height");
    botHeight = botHeight - (bodyHeight-tmpBodyHeight);
    $botArea.css("height", botHeight+"px");
    bodyHeight = tmpBodyHeight;
    gridList.scrollResize();
});
