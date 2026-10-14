<%@page contentType="text/html;charset=utf-8" %>
<%@include file = "./include/session_check.jsp"%>
<%@include file = "manager_util.jsp"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>Namo CrossEditor : Admin</title>
	<script type="text/javascript"> var pe_nc = "pe_tY"; </script>
	<script type="text/javascript" src="../manage_common.js"></script>
	<script type="text/javascript" language="javascript" src="../../js/namo_cengine.js"></script>
	<script type="text/javascript" language="javascript" src="../manager.js"></script>
	<link href="../css/common.css" rel="stylesheet" type="text/css">
</head>

<body>

<%@include file = "../include/top.html"%>

<div id="pe_YA" class="pe_ee">	
	<table class="pe_lT">
	  <tr>
		<td class="pe_ee">
		
			<table id="Info">
				<tr>
					<td style="padding:0 0 0 10px;height:30px;text-align:left">
					<font style="font-size:14pt;color:#3e77c1;font-weight:bold;text-decoration:none;"><span id="pe_vv"></span></font></td>
					<td id="InfoText"><span id="pe_oT"></span></td>
				</tr>
				<tr>
					<td colspan="2"><img id="pe_qF" src="../images/title_line.jpg" alt="" /></td>
				</tr>
			</table>
		
		</td>
	  </tr>
	  <tr>
		<td class="pe_ee">
			
				<form method="post" id="pe_agD" action="account_proc.jsp" onsubmit="return pe_J(this);">
				<table class="pe_hy" >
				  <tr>
					<td>

						<table class="pe_ca">
						  <tr><td class="pe_dv" colspan="3"></td></tr>
						</table>
						 
						<table class="pe_ca" >
						  <tr>
							<td class="pe_bV">&nbsp;&nbsp;&nbsp;&nbsp;<b><span id="pe_sy"></span></b></td>
							<td class="pe_bO"></td>
							<td class="pe_bM">
								<input type="hidden" name="u_id" id="u_id" value="<%=detectXSSEx(session.getAttribute("memId").toString())%>" autocomplete="off"/>
								<input type="password" name="passwd" id="passwd" value="" class="pe_iI" autocomplete="off"/>
							</td>
						  </tr>
						  <tr>
							<td class="pe_bS" colspan="3"></td>
						  </tr>
						  <tr>
							<td class="pe_bV">&nbsp;&nbsp;&nbsp;&nbsp;<b><span id="pe_we"></span></b></td>
							<td class="pe_bO"></td>
							<td class="pe_bM">
								<input type="password" name="newPasswd" id="newPasswd" value="" class="pe_iI" autocomplete="off"/>
							</td>
						  </tr>
						  <tr>
							<td class="pe_bS" colspan="3"></td>
						  </tr>
						  <tr>
							<td class="pe_bV">&nbsp;&nbsp;&nbsp;&nbsp;<b><span id="pe_vT"></span></b></td>
							<td class="pe_bO"></td>
							<td class="pe_bM">
								<input type="password" name="newPasswdCheck" id="newPasswdCheck" value="" class="pe_iI" autocomplete="off"/>
							</td>
						  </tr>
						</table>
					
						<table class="pe_ca">
						  <tr><td class="pe_dv" colspan="3"></td></tr>
						</table>
								
					</td>
				  </tr>
				  <tr id="pe_xP">
					<td id="pe_xT">
						<ul style="margin:0 auto;width:170px;">
							<li class="pe_ea">
								<input type="submit" id="pe_uw" value="" class="pe_dW pe_dj" style="width:66px;height:26px;" />
							</li>
							<li class="pe_ea"><input type="button" id="pe_pa" value="" class="pe_dW pe_dj" style="width:66px;height:26px;"></li>
						</ul>
					</td>
				  </tr>
				</table>
				</form>
		
		</td>
	  </tr>
	</table>

</div>

<%@include file = "../include/bottom.html"%>

</body>
<script>
var webPageKind = '<%=detectXSSEx(session.getAttribute("webPageKind").toString())%>'
topInit();
pe_z();
</script>

</html>

	
	

