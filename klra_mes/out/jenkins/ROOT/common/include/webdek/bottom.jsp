<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<script type="text/javascript">
$(document).ready(function(){
	extendSizeType = false;
	$extenSizeBtn = jQuery(".btn_extend");
	for(var i=0;i<$extenSizeBtn.length;i++){
		var $tmpScroll = $extenSizeBtn.eq(i).parents(".content_layout");
		var tmpIndex = $contentLayout.index($tmpScroll);
		$extenSizeBtn.eq(i).attr("extenSizeBtnNum", tmpIndex);
	}
	$extenSizeBtn.click(function(event) {
		var $obj = jQuery(event.target);
		if(!$obj.attr("extenSizeBtnNum")){
			$obj = $obj.parent();
		}
		if(extendSizeType){
			extendSizeType = false;
			$searchAreaLayer.show();
			for(var i=0;i<$sizeDragBtn.length;i++){
				$sizeDragBtn.eq(i).show();
			}
			for(var i=0;i<$scrollBoxList.length;i++){
				$scrollBoxList.eq(i).parents(".content_layout").css("margin-top","0px").show();
				$scrollBoxList.eq(i).css("height",scrollBoxHeightList[i]+"px");
			}
		}else{
			extendSizeType = true;
			$searchAreaLayer.hide();
			setScrollBoxHeightList();
			for(var i=0;i<$sizeDragBtn.length;i++){
				$sizeDragBtn.eq(i).hide();
			}
			var extenSizeBtnNum = parseInt($obj.attr("extenSizeBtnNum"));
			for(var i=0;i<$scrollBoxList.length;i++){
				if(extenSizeBtnNum == i){
					if($scrollBoxList.eq(i).parents('.content_layout').css("margin-top","50px").find(".tab_style02").length == 0){
						$scrollBoxList.eq(i).css("height",(bodyHeight-110)+"px");
					}else{
						$scrollBoxList.eq(i).css("height",(bodyHeight-140)+"px");
					}					
				}else{
					$scrollBoxList.eq(i).parents(".content_layout").hide();
				}
			}
		}
	});
	
	jQuery("body").find("input :first").focus();
});
</script>