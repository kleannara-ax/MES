<%
	String APRKEY = (String)request.getAttribute("APRKEY");
	String LINKKEY = (String)request.getAttribute("LINKKEY");
	String REDESC = (String)request.getAttribute("REDESC");
	String APRTYPE = (String)request.getAttribute("APRTYPE");
	String SORTKEY = (String)request.getAttribute("SORTKEY");
	String IAPRTYPE = (String)request.getAttribute("IAPRTYPE");
	String LASTAPUSER = (String)request.getAttribute("LASTAPUSER");
%>
<script type="text/javascript">
	$(document).ready(function(){
		
	});
	
	function commonBtnClick(btnName){
		//commonUtil.debugMsg("commonBtnClick : ", arguments);
		if(btnName == "Aprove"){
			aprove('A');
		}else if(btnName == "Return"){
			aprove('R');
		}else if(btnName == "Delete"){
			aprove('D');
		}
	}
	
	function aprove(aprtype){
		var param = dataBind.paramData("searchArea");
		param.put("APRKEY","<%=APRKEY%>");
		param.put("APRTYPE",aprtype);
		
		var json = netUtil.sendData({
			url : "/aprove/update/json/FWAPI.data",
			param : param
		}); 
		
		if(json && json.data){
			//commonUtil.msgBox("SYSTEM_APROVEOK");
			//this.location.reload();
			//event fn
			if(commonUtil.checkFn("aproveAfterEvent")){
				aproveAfterEvent(aprtype, true);
			}
		}else{
			//commonUtil.msgBox("SYSTEM_APROVEFAIL");
			//event fn
			if(commonUtil.checkFn("aproveAfterEvent")){
				aproveAfterEvent(aprtype, false);
			}
		}
	}
</script>