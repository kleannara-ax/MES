var $centerArea
var $leftArea;
var $rightArea;
var bodyWidth;
var leftWidth;
var rightWidth;
var rightLeft;
var centerLeft;
var startLeft;
var centerGap = 10;
var bodyPadding = 13;

// draggable
$(document).ready(function(){
	$centerArea = jQuery("#"+configData.CENTER_AREA);
	if($centerArea.length > 0){
		var $tmpArea = $('.bottomSect2');
		$leftArea = $tmpArea.eq(0);
		$rightArea = $tmpArea.eq(1);
		bodyWidth = commonUtil.getCssNum($("body"), "width");
		
		$leftArea.css("width",(bodyWidth/2 - centerGap - bodyPadding)+"px");
		$rightArea.css("width",(bodyWidth/2 - centerGap - bodyPadding)+"px");
		$rightArea.css("left",(bodyWidth/2 + centerGap)+"px");
		$centerArea.css("left",(bodyWidth/2 + centerGap/2 - 2)+"px");
		
		leftWidth = commonUtil.getCssNum($leftArea, "width");
		rightWidth = commonUtil.getCssNum($rightArea, "width");
		rightLeft = commonUtil.getCssNum($rightArea, "left");
		
		$centerArea.draggable({
			axis: "x",
			cursor: "n-resize",
			helper: "none",
			//revert: true,
			start: function(event, ui) {
				var $obj = jQuery(event.target);
				//$obj.text(ui.position.left);
				startLeft = ui.position.left;
			},
			drag: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {

				}else{
					changeCenterWidth($obj, ui);
				}
			},
			stop: function(event, ui) {
				var $obj = jQuery(event.target);
				if ((Browser.ie6) || (Browser.ie7) || (Browser.ie8)) {
					changeCenterWidth($obj, ui);
				}
				setCenterWidth($obj, ui);
			}
		});
	}
});

function changeCenterWidth($dragObj, ui){
	$leftArea.css("width",(leftWidth - (startLeft-ui.position.left))+"px");
	$rightArea.css("width",(rightWidth + (startLeft-ui.position.left))+"px");
	$rightArea.css("left",(rightLeft - (startLeft-ui.position.left))+"px");
}

function setCenterWidth($dragObj, ui){
	var tmpBodyWidth = bodyWidth - 20;
	resetWidth();
	/*
	if(leftWidth < 200){
		$leftArea.css("width","200px");
		$rightArea.css("width",(tmpBodyWidth-225)+"px");
		$rightArea.css("left","233px");	
		$centerArea.css("left","225px");
	}else if(rightWidth < 200){
		$leftArea.css("width",(tmpBodyWidth-230)+"px");
		$rightArea.css("width","200px");
		$rightArea.css("left",(tmpBodyWidth-200)+"px");
		$centerArea.css("left",(tmpBodyWidth-207)+"px");
	}
	resetWidth();
	*/
	gridList.scrollResize();
}

function resetWidth(){
	leftWidth = commonUtil.getCssNum($leftArea, "width");
	rightWidth = commonUtil.getCssNum($rightArea, "width");
	rightLeft = commonUtil.getCssNum($rightArea, "left");
	centerLeft = commonUtil.getCssNum($centerArea, "left");
	if(leftWidth < 200 || rightWidth < 200){
		var tmpBodyWidth = bodyWidth - 20;
		if(leftWidth < 200){
			$leftArea.css("width","200px");
			$rightArea.css("width",(tmpBodyWidth-225)+"px");
			$rightArea.css("left","233px");	
			$centerArea.css("left","225px");
		}else if(rightWidth < 200){
			$leftArea.css("width",(tmpBodyWidth-230)+"px");
			$rightArea.css("width","200px");
			$rightArea.css("left",(tmpBodyWidth-200)+"px");
			$centerArea.css("left",(tmpBodyWidth-207)+"px");
		}
		leftWidth = commonUtil.getCssNum($leftArea, "width");
		rightWidth = commonUtil.getCssNum($rightArea, "width");
		rightLeft = commonUtil.getCssNum($rightArea, "left");
		centerLeft = commonUtil.getCssNum($centerArea, "left");
	}	
}

$(window).resize(function(){
	if($centerArea.length > 0){
		var tmpBodyWidth = commonUtil.getCssNum($("body"), "width");
	    var tmpResizeWidth = tmpBodyWidth - bodyWidth;
	    if(tmpBodyWidth == 0 || tmpResizeWidth == 0){
			return;
		}
	    $leftArea.css("width",(leftWidth + tmpResizeWidth/2)+"px");
		$rightArea.css("width",(rightWidth + tmpResizeWidth/2)+"px");
		$rightArea.css("left",(rightLeft + tmpResizeWidth/2)+"px");
		$centerArea.css("left",(centerLeft + tmpResizeWidth/2)+"px");
	    bodyWidth = tmpBodyWidth;
	    resetWidth();
	    gridList.scrollResize();
	}    
});