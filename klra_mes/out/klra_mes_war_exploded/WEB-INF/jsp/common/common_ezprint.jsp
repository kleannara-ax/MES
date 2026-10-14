<%@ page language="java" pageEncoding="UTF-8"%>
<%
	String fileName = (String) request.getAttribute("filename");
	String andValue = (String) request.getAttribute("andvalue");
	
	String width    = (String) request.getAttribute("width");
	String height   = (String) request.getAttribute("height") ;
	
	String url      = (String) request.getAttribute("url");

	String platformUrl = url + "/eftpmanager";
	String hnwUrl = url + fileName;

// 	String realFile = "gc"+System.currentTimeMillis()+".ezxml";
	String realFile = "mes"+System.currentTimeMillis()+".ezxml";
	response.addHeader("content-type", "application/download");
	response.addHeader("Content-Disposition", "inline;filename="+realFile);
	response.addHeader("Pragma", "no-cache;");
%>
<EzApplication
	 noTitle="no" title="" fullScreen="no" addressbar="no" posCenter="yes" width="<%=width %>" height="<%=height %>" noResize="no">
 	<codebase src="EzipFiles/EzPlatform_1_0_0_11.ezip" url="<%=platformUrl%>" AppPath="EZgen/EzPlatform_1_0_0_11.exe" version="1,0,0,11"/> 
	<frameset rows="*" border="4" borderColor="#FFFFFF" bgColor="#ffffff">
		<frame name="top" scrolling="no" noResize="yes">
			<codebase src="EzipFiles/HnwActivw_8_0_0_90.ezip" url="<%=platformUrl%>" AppPath="EZgen/HnwActivw_8_0_0_90/HnwActivw.dll" version="8,0,0,90"/>
			<param name="hnwsrc" value="<%=hnwUrl%>"/>
		    <param name="initvalue" value="<%=andValue%>"/> 
			<param name="UrlEncoding" value="Y"/>
		</frame>
	</frameset>
</EzApplication>
