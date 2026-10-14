function WriteEZgenElement(openFile,wherestr,orderbystr,language,dataMap,width,height){
	
	var andValue = "";
	var url = "/common/common_ezprint.page";
	andValue += wherestr?"[:i_where]="+wherestr:"";
	andValue += orderbystr?"[:i_orderby]="+orderbystr:"";
	andValue += language?"[:i_language]="+language:"";
	if(dataMap){
		var keys = dataMap.keys();
		var len = keys.length;
		for(var i=0; i<len; i++){
			andValue += "[:"+keys[i]+"]="+dataMap.get(keys[i]);
		}
	}
	if(!width) width = "908";
	if(!height) height = "908";

	jQuery("#gridReportForm").remove();
	
	var formHtml = "<form action='"+url+"' method='post' id='gridReportForm'>"
				 + "<input name='filename'>" 
				 + "<input name='andvalue'>"
				 + "<input name='width'>"
				 + "<input name='height'>"
				 + "</form>";
	
	jQuery(formHtml).hide().appendTo('body');
	
	jQuery("#gridReportForm").find('[name="filename"]').val("/ezgen/ocx/"+document.location.protocol.slice(0,-1)+"/"+openFile);
	jQuery("#gridReportForm").find('[name="andvalue"]').val(andValue);
	jQuery("#gridReportForm").find('[name="width"]').val(width);
	jQuery("#gridReportForm").find('[name="height"]').val(height);
	jQuery("#gridReportForm").submit();
}

function getEZgenParameters(){
	return {"filename": $("body").data("filename"),"andvalue": $("body").data("andvalue")};
}