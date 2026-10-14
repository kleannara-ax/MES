<%@page contentType="text/html;charset=utf-8" %>
<%@include file = "./include/session_check.jsp"%>
<%@include file = "manager_util.jsp"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
<title>Namo CrossEditor : Admin</title>
	<script type="text/javascript"> var pe_Gw = "True"; var pe_nc = "pe_sR"; </script>
	<script type="text/javascript" src="../manage_common.js"></script>
	<script type="text/javascript" src="../../js/namo_scripteditor.js"></script>
	<script type="text/javascript" src="../manager.js"></script>
	<link href="../css/common.css" rel="stylesheet" type="text/css" />
</head>


<body>

<%@include file = "../include/top.html"%>

<div id="preview" class="pe_ee">
	<table class="pe_lT">
	  <tr>
		<td class="pe_ee">
		
			<table id="Info">
				<tr>
					<td style="padding:0 0 0 10px;height:30px;text-align:left">
					<font style="font-size:14pt;color:#3e77c1;font-weight:bold;text-decoration:none;"><span id="pe_Od">&nbsp;</span></font></td>
					<td id="InfoText">&nbsp;</td>
				</tr>
				<tr>
					<td colspan="2"><img id="pe_qF" src="../images/title_line.jpg" alt="" /></td>
				</tr>
			</table>
		
		</td>
	  </tr>
	  <tr>
		<td class="pe_ee">
			
			<table class="pe_hy">
			 <tr>
				<td class="pe_er">
					<script>
						var CrossEditor = new NamoSE('namoeditor1');
						CrossEditor.params.ManageMode = true;
						CrossEditor.params.UserLang = "auto";
						CrossEditor.params.Width = "100%";
						if (pe_hN != "") CrossEditor.params.UserDomain = pe_hN;
						CrossEditor.editorStart();
					</script>
				</td>
			  </tr>
			  <tr>
				<td id="pe_WX" style="height:20px"></td>
			  </tr>
			</table>
			
		</td>
	  </tr>
	</table>
</div>

<%@include file = "../include/bottom.html"%>
<script>
	var webPageKind = '<%= detectXSSEx(session.getAttribute("webPageKind").toString()) %>'
	topInit();
</script>

</body>
</html>
