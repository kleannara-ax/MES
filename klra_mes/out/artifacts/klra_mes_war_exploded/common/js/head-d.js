var $botArea;
var botHeight;
var botPosition;
var bodyHeight;
var $bottomSectList;
var dynamicHeightList;

// draggable
$(document).ready(function(){	
	$bottomSectList = $('.bottomSect');
	$botArea = $bottomSectList.eq($bottomSectList.length-1);
	bodyHeight = commonUtil.getCssNum($("body"), "height");

	botHeight = bodyHeight;
	for(var i=0;i<$bottomSectList.length-1;i++){
		botHeight -= commonUtil.getCssNum($bottomSectList.eq(i), "height");
	}
	botPosition = bodyHeight - botHeight;
	
	midPosition = commonUtil.getCssNum($midArea, "top");

	$botArea.css({height : (botHeight-80)+"px", top:(botPosition+30)+'px'});
	botHeight = commonUtil.getCssNum($botArea, "height");
	botPosition = commonUtil.getCssNum($botArea, "top");
});

$(window).resize(function(){
    var tmpBodyHeight = commonUtil.getCssNum($("body"), "height");
    botHeight = botHeight - (bodyHeight-tmpBodyHeight);
    $botArea.css("height", botHeight+"px");
    bodyHeight = tmpBodyHeight;
    gridList.scrollResize();
});