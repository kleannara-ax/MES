<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String langky = "KO";
	String theme = "/theme/webdek";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>아이디 / 비밀번호 찾기</title>
<%-- <%@ include file="/common/include/webdek/head.jsp" %> --%>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/pop_reset.css"/>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/layout.css"/>
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/content_ui.css">
<link rel="stylesheet" type="text/css" href="/common/theme/webdek/css/multiple-select.css">
<style>
.ui-tabs-active{background-color: #ddd;}
</style>
<script type="text/javascript" src="/common/js/jquery.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.js"></script>
<script type="text/javascript" src="/common/js/jquery-ui.custom.js"></script>
<script type="text/javascript" src="/common/js/jquery.plugin.js"></script>
<script type="text/javascript" src="/common/js/jquery.form.js"></script>
<script type="text/javascript" src="/common/js/jquery.cookie.js"></script>
<script type="text/javascript" src="/common/js/jquery.mousewheel.js"></script>
<script type="text/javascript" src="/common/js/jquery.ui.monthpicker.js"></script>
<script type="text/javascript" src="/common/js/jquery.ui.timepicker.js"></script>
<script type="text/javascript" src="/common/js/multiple-select.js"></script>
<script type="text/javascript" src="/common/js/json2.js"></script>
<script type="text/javascript" src="/common/js/big.js"></script>
<script type="text/javascript" src="/common/js/dataMap.js"></script>
<script type="text/javascript" src="/common/js/configData.js"></script>
<script type="text/javascript" src="/common/js/label.js"></script>
<script type="text/javascript" src="/common/lang/label-<%=langky%>.js?v=<%=System.currentTimeMillis()%>"></script>
<script type="text/javascript" src="/common/lang/message-<%=langky%>.js?v=<%=System.currentTimeMillis()%>"></script>
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
<script type="text/javascript" src="/common/js/datepicker/jquery.ui.datepicker-ko.js"></script>

<script type="text/javascript">
	window.resizeTo("560", "510");
	window.res
	// 공통버튼
	function commonBtnClick(btnName){
		if(btnName == "IdFind"){
			idFind();
			
		}else if(btnName == "PsSearch"){
			psSearch();
			
		}else if(btnName == "PsFind"){
			psFind();
		}
	}
	$(document).ready(function(){
		$("body").show();
		$("#tab1-2").hide();
		$(".tab1-1").parent().css("background", "#ccc");
	});
	
	function idFind(){
		var idfindCk  = $("input[name='SMS_ID_TYPE']:checked").val();
		var userName;
		var userFind;
		var validName;
		var validColum;
		
		if(idfindCk == "ID_FIND_EMAIL"){
			userName = $("#ID_FIND_EMAIL input[name='USER_NAME']").val();
			userFind = $("#ID_FIND_EMAIL input[name='USER_FIND']").val();
			validColum = "USERG3";
			validName = "이메일";
			
		}else if(idfindCk == "ID_FIND_PNUM"){
			userName = $("#ID_FIND_PNUM input[name='USER_NAME']").val();
			userFind = $("#ID_FIND_PNUM input[name='USER_FIND']").val();
			validColum = "TELNUM";
			validName = "휴대폰";
			
		}
		
		if(userName.length == 0 || userFind.length == 0){
			alert("이름과  "+validName+"은 필수 입력 입니다.");
			return;
		}
		
		var param = new DataMap();
		param.put("FIND", idfindCk.split("_")[0]);
		param.put("FIND_SEND", idfindCk.split("_")[2]);
		param.put("USERNAME", userName);
		param.put("FIND_VALUE", userFind);
		param.put("FIND_COLUM", validColum);
		
		sendData(param);
	}
	
	function psSearch(){
		var userid = $("#USERID").val();
		
		if(userid.length == 0){
			alert("아이디는 필수 입력 입니다.");
			return;
		}
		
		var param = new DataMap();
		param.put("FIND_SEND", "PS_SEARCH");
		param.put("FIND", "PS_SEARCH");
		param.put("FIND_VALUE", userid);
		param.put("FIND_COLUM", "USERID");
		
		sendData(param)
	}
	function loadingOpen(){
		
	}

	function loadingClose(){
		
	}
	
	function psFind(){
		var psfindCk  = $("input[name='SMS_PS_TYPE']:checked").val();
		
		if(psfindCk.split("_")[2] == "EMAIL"){
			if($("#PS_EMAIL_TEXT").text().length == 0 || $("#PS_EMAIL").length == 0){
				alert("조회된 정보가 없습니다.");
				return;
			}
		}else if(psfindCk.split("_")[2] == "PNUM"){
			if($("#PS_PNUM_TEXT").text().length == 0 || $("#PS_PNUM").length == 0){
				alert("조회된 정보가 없습니다.");
				return;
			}
		}
		
		var param = new DataMap();
		param.put("FIND", psfindCk.split("_")[0]);
		param.put("FIND_SEND", psfindCk.split("_")[2]);
		param.put("FIND_VALUE", $("#PS_USER_ID").val());
		param.put("FIND_COLUM", "USERID");
		
		sendData(param);
	}
	
	function sendData(param){
		var json = netUtil.sendData({
			url : "/common/json/idPsFind.data",
			param : param
		});
		
		if(json && json.data){
			if(json.data == "ID_NOTHING"){
				alert("존재하는 아이디가 없습니다.");
				
			}else if(json.data == "PS_SEARCH_NOTHING"){
				alert("존재하는 아이디가 없습니다.");
				$("#PS_EMAIL_TEXT").text("");
				$("#PS_PNUM_TEXT").text("");
				$("#PS_USER_ID").val("");
				
			}else if(json.data == "PS_SEARCH"){
				$("#PS_EMAIL").val(json.dataMap.USERG3);
				$("#PS_PNUM").val(json.dataMap.TELNUM);
				$("#PS_EMAIL_TEXT").text(json.dataMap.USERG3_MA);
				$("#PS_PNUM_TEXT").text(json.dataMap.TELNUM_MA);
				$("#PS_USER_ID").val(json.dataMap.USERID);
				
			}else if(json.data == "S"){
				alert("전송되었습니다.");
			}
		}
	}
	
	function tabChange(tab){
		if(tab == "tab1-1"){
			$("#tab1-2").hide();
			$(".tab1-2").parent().css("background", "#fff");
			$("#"+tab).show();
			$("."+tab).parent().css("background", "#ccc");
// 		    background: #ccc;
		}else if(tab == "tab1-2"){
			$("#tab1-1").hide();
			$(".tab1-1").parent().css("background", "#fff");
			$("#"+tab).show();
			$("."+tab).parent().css("background", "#ccc");
		}
	}
	
	function onlyNumber(event){
        event = event || window.event;
        var keyID = (event.which) ? event.which : event.keyCode;
        if ( (keyID >= 48 && keyID <= 57) || (keyID >= 96 && keyID <= 105) || keyID == 8 || keyID == 46 || keyID == 37 || keyID == 39 ) 
            return;
        else
            return false;
    }
    function removeChar(event) {
        event = event || window.event;
        var keyID = (event.which) ? event.which : event.keyCode;
        if ( keyID == 8 || keyID == 46 || keyID == 37 || keyID == 39 ) 
            return;
        else
            event.target.value = event.target.value.replace(/[^0-9]/g, "");
    }
</script>
</head>
<body>
<%@ include file="/common/include/webdek/layout.jsp" %>
<!-- content -->
<div class="content_wrap" style="min-width: 420px">
	<div class="content_inner">
	<%@ include file="/common/include/webdek/title.jsp" %>
		
		<div class="search_next_wrap">
			<div class="content_layout tabs" style=" padding: 0;" id="FINDTAB">
				<ul class="tab tab_style02">
					<li style="border: 1px solid #ccc; border-radius: 15px 15px 0 0;"><a href="#tab1-1" id="ID" class="tab1-1" onclick="tabChange('tab1-1')"><span>아이디 찾기</span></a></li>
					<li style="border: 1px solid #ccc; border-radius: 15px 15px 0 0;"><a href="#tab1-2" id="PS" class="tab1-2" onclick="tabChange('tab1-2')"><span>비밀번호 찾기</span></a></li>
				</ul>
				<div class="table_box section" id="tab1-1" style="height: auto">
					<div class="inner_search_wrap"  id="email_wrap"  style="height:auto; margin-top: 20px;">
						<div>
							<input type="radio" class="input" id="radio1" name="SMS_ID_TYPE" checked style="width: 50px;" value="ID_FIND_EMAIL"/>
							<label for="radio1" style="display: inline;"><span>등록된 이메일로 찾기</span></label>
							<span style="display: block;font-size: 9px; padding: 5px 0 5px 55px;">시스템에  등록된 이메일 주소와 입력한 이메일 주소가 같아야 인증번호를 받을 수 있습니다.</span>
						</div>
						<table class="detail_table" id="ID_FIND_EMAIL">
							<colgroup>
								<col width="40%" />
								<col width="60%" />
							</colgroup>
							<tbody>
								<tr>
									<th>이름</th><!-- 이륾 -->
									<td>
										<input type="text" class="input" id="EST_NM" name="USER_NAME" style="width: 100%"/>
									</td>
								</tr>
								<tr>
									<th>이메일</th><!-- 이메일 -->
									<td>
										<input type="text" class="input" id="EMAIL" name="USER_FIND" style="width: 100%"/>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
                    <div class="inner_search_wrap" id="sms_wrap" style="height:auto; margin-top: 20px;">
                        <div>
                            <input type="radio" class="input" id="radio2" name="SMS_ID_TYPE" value="ID_FIND_PNUM" style="width: 50px;"/>
                            <label for="radio2" style="display: inline;"><span>등록된 휴대폰으로 찾기</span></label>
                        </div>
                        <table class="detail_table" id="ID_FIND_PNUM">
                            <colgroup>
                                <col width="40%" />
                                <col width="60%" />
                            </colgroup>
                            <tbody>
                                <tr>
                                    <th>이름</th><!-- 이륾 -->
                                    <td>
                                        <input type="text" class="input" id="EST_NM" name="USER_NAME" style="width: 100%"/>
                                        
                                    </td>
                                </tr>   
                                <tr>
                                    <th>휴대폰</th><!-- 휴대폰 -->
                                    <td>
                                        <input type="text" class="input" id="PNUM" name="USER_FIND" onkeydown='return onlyNumber(event)' onkeyup='removeChar(event)' style="width: 100%"/>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                            <span style="display: block;font-size: 9px; padding: 5px 0 5px 55px; text-align: right;">숫자만 입력해주세요.</span>
                    </div>
                    <div class="btn_wrap" style="text-align: center;">
<!--                     	<input type="button" CB="IdFind SAVE 찾기" id="btnSave" style="width: 100%; margin: 30px 0; float: left"/>   저장 -->
<!--                     	<input type="button" id="btnSave" style="width: 100%; margin: 30px 0; float: left"/>   저장 -->
							<button id="IdFind" style="width:100px;height: 30px;margin: 30px 0; border: 1px solid #ccc; border-radius:15px; padding: 0 20px" onclick="idFind()">발송</button>
                    </div>
                </div>
                <div class="table_box section" id="tab1-2" style="height: auto">
                    <div class="inner_search_wrap"  id="email_wrap" style="height:auto;" id="estDetail">
                        <h2 style="font-size: 18px;padding-bottom: 10px;">G-HUB 시스템 비밀번호 찾기</h2>
                        <table class="detail_table">
                            <colgroup>
                                <col width="40%" />
                                <col width="60%" />
                            </colgroup>
                            <tbody>
                                <tr>
                                    <th>아이디</th><!-- 아이디 -->
                                    <td>
                                        <input type="text" class="input" id="USERID" name="USERID" style="width: 75%"/>
										<button id="PsSearch" style="width:25%;height: 24px;float: right; border:1px solid #ccc;" onclick="psSearch()">찾기</button>
                                        
                                    </td>
                                </tr>   
                            </tbody>
                        </table>
                        <div style="padding: 20px 0;">
                            <input type="radio" class="input" id="radio1" name="SMS_PS_TYPE" checked style="width: 50px;" value="PS_FIND_EMAIL"/>
                            <label for="radio1" style="display: inline;"><span>등록된 이메일로 임시비밀번호 발급</span></label>
                            <span style="display: block;font-size: 12px; padding: 5px 0 5px 55px;" id="PS_EMAIL_TEXT"></span>
                            <input type="hidden" class="input" id="PS_EMAIL" name="PS_EMAIL" />
                            
                            <input type="radio" class="input" id="radio1" name="SMS_PS_TYPE" style="width: 50px;" value="PS_FIND_PNUM"/>
                            <label for="radio1" style="display: inline;"><span>등록된 휴대폰번호로  임시비밀번호 발급</span></label>
                            <span style="display: block;font-size: 12px; padding: 5px 0 5px 55px;" id="PS_PNUM_TEXT"></span>
                            <input type="hidden" class="input" id="PS_PNUM" name="PS_PNUM" />
                            <input type="hidden" class="input" id="PS_USER_ID" name="PS_USER_ID" />
                        </div>
                    </div>
                    <div class="btn_wrap" style="text-align: center;">
							<button id="PsFind" style="width:100px;height: 30px;margin: 30px 0; border: 1px solid #ccc; border-radius:15px; padding: 0 20px" onclick="psFind()">발급</button>
                    </div>
                </div>
            </div>
        </div>
	</div>
</div>
<!-- // content -->
<%@ include file="/common/include/webdek/bottom.jsp" %>
</body>
</html>