<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.common.bean.CommonConfig"%>
<%
	String userid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);
	if(userid.equals("DEV")){
%>
		<li AMNUID="root" MENUID="TOOL">
			<a href="#"><span class="mnuTxt">TOOL</span></a>
		</li>
		<li AMNUID="TOOL" MENUID="SAMPLE">
			<a href="#" onclick="goPage(this, '/sample/sample.page')">
				<span class="mnuTxt">SAMPLE</span>
			</a>
		</li>
		<li AMNUID="TOOL" MENUID="SAMPLE1">
			<a href="#" onclick="goPage(this, '/sample/sample1.page')">
				<span class="mnuTxt">SAMPLE1</span>
			</a>
		</li>
		<li AMNUID="TOOL" MENUID="BOARD_SAMPLE">
			<a href="#" onclick="goPage(this, '/board/board.page?ID=2')">
				<span class="mnuTxt">BOARD_SAMPLE</span>
			</a>
		</li>
		<li AMNUID="TOOL" MENUID="TABLE">
			<a href="#" onclick="goPage(this, '/common/tool/table.page')">
				<span class="mnuTxt">TABLE</span>
			</a>
		</li>
		<li AMNUID="TOOL" MENUID="SQL">
			<a href="#" onclick="goPage(this, '/common/tool/sql.page')">
				<span class="mnuTxt">SQL</span>
			</a>
		</li>
		<li AMNUID="TOOL" MENUID="page">
			<a href="#" onclick="goPage(this, '/common/tool/page.page')">
				<span class="mnuTxt">PAGE</span>
			</a>
		</li>
		<li AMNUID="TOOL" MENUID="page2">
			<a href="#" onclick="goPage(this, '/common/tool/page2.page')">
				<span class="mnuTxt">PAGE2</span>
			</a>
		</li>
		<li AMNUID="TOOL" MENUID="cpage">
			<a href="#" onclick="goPage(this, '/common/tool/pagecreate/grid.page')">
				<span class="mnuTxt">CPAGE</span>
			</a>
		</li>
		<li AMNUID="TOOL" MENUID="GRID_SQL">
			<a href="#" onclick="goPage(this, '/common/tool/sqlGrid.page')">
				<span class="mnuTxt">sql grid</span>
			</a>
		</li>
		<li AMNUID="TOOL" MENUID="GRID_EXCEL">
			<a href="#" onclick="goPage(this, '/common/tool/excelGrid.page')">
				<span class="mnuTxt">excel grid</span>
			</a>
		</li>
		<li AMNUID="root" MENUID="DEMO">
			<a href="#"><span class="mnuTxt">DEMO</span></a>
		</li>
		<li AMNUID="DEMO" MENUID="GRID">
			<a href="#"><span class="mnuTxt">GRID</span></a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_DEFAULT">
			<a href="#" onclick="goPage(this, '/demo/grid/default.page')">
				<span class="mnuTxt">default</span>
			</a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_ITEMLINK">
			<a href="#" onclick="goPage(this, '/demo/grid/itemlink.page')">
				<span class="mnuTxt">itemlink</span>
			</a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_HEADITEM">
			<a href="#" onclick="goPage(this, '/demo/grid/headitem.page')">
				<span class="mnuTxt">headitem</span>
			</a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_PAGING">
			<a href="#" onclick="goPage(this, '/demo/grid/paging.page')">
				<span class="mnuTxt">paging</span>
			</a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_SCROLLPAGING">
			<a href="#" onclick="goPage(this, '/demo/grid/scrollpaging.page')">
				<span class="mnuTxt">scrollpaging</span>
			</a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_APPENDPAGING">
			<a href="#" onclick="goPage(this, '/demo/grid/appendpaging.page')">
				<span class="mnuTxt">appendpaging</span>
			</a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_MHEAD">
			<a href="#" onclick="goPage(this, '/demo/grid/multihead.page')">
				<span class="mnuTxt">multi head</span>
			</a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_HEADSET">
			<a href="#" onclick="goPage(this, '/demo/grid/headset.page')">
				<span class="mnuTxt">head set</span>
			</a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_FILTER">
			<a href="#" onclick="goPage(this, '/demo/grid/filter.page')">
				<span class="mnuTxt">filter</span>
			</a>
		</li>
		<li AMNUID="GRID" MENUID="GRID_LOTTO">
			<a href="#" onclick="goPage(this, '/demo/grid/lotto.page')">
				<span class="mnuTxt">lotto</span>
			</a>
		</li>
		<li AMNUID="DEMO" MENUID="INPUT">
			<a href="#"><span class="mnuTxt">INPUT</span></a>
		</li>
		<li AMNUID="INPUT" MENUID="INPUT_DEFAULT">
			<a href="#" onclick="goPage(this, '/demo/input/default.page')">
				<span class="mnuTxt">default</span>
			</a>
		</li>
		<li AMNUID="INPUT" MENUID="INPUT_MULTI">
			<a href="#" onclick="goPage(this, '/demo/input/multicombo.page')">
				<span class="mnuTxt">multicombo</span>
			</a>
		</li>
		<li AMNUID="INPUT" MENUID="INPUT_FILEUP">
			<a href="#" onclick="goPage(this, '/demo/input/fileupload.page')">
				<span class="mnuTxt">fileupload</span>
			</a>
		</li>
		<li AMNUID="INPUT" MENUID="INPUT_CROSSUP">
			<a href="#" onclick="goPage(this, '/demo/input/crossUp.page')">
				<span class="mnuTxt">crossupload</span>
			</a>
		</li>
		<li AMNUID="DEMO" MENUID="LAYOUT">
			<a href="#"><span class="mnuTxt">LAYOUT</span></a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID1">
			<a href="#" onclick="goPage(this, '/demo/layout/grid1.page')">
				<span class="mnuTxt">grid1</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID21">
			<a href="#" onclick="goPage(this, '/demo/layout/grid2-1.page')">
				<span class="mnuTxt">grid2-1</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID22">
			<a href="#" onclick="goPage(this, '/demo/layout/grid2-2.page')">
				<span class="mnuTxt">grid2-2</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID23">
			<a href="#" onclick="goPage(this, '/demo/layout/grid2-3.page')">
				<span class="mnuTxt">grid2-3</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID31">
			<a href="#" onclick="goPage(this, '/demo/layout/grid3-1.page')">
				<span class="mnuTxt">grid3-1</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID32">
			<a href="#" onclick="goPage(this, '/demo/layout/grid3-2.page')">
				<span class="mnuTxt">grid3-2</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID33">
			<a href="#" onclick="goPage(this, '/demo/layout/grid3-3.page')">
				<span class="mnuTxt">grid3-3</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID4">
			<a href="#" onclick="goPage(this, '/demo/layout/grid4.page')">
				<span class="mnuTxt">grid4</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID6">
			<a href="#" onclick="goPage(this, '/demo/layout/grid6.page')">
				<span class="mnuTxt">grid6</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_GRID61">
			<a href="#" onclick="goPage(this, '/demo/layout/grid6-1.page')">
				<span class="mnuTxt">grid6-1</span>
			</a>
		</li>
		<li AMNUID="LAYOUT" MENUID="LAYOUT_DASH">
			<a href="#" onclick="goPage(this, '/demo/layout/dash.page')">
				<span class="mnuTxt">dash</span>
			</a>
		</li>
		<li AMNUID="DEMO" MENUID="TREE">
			<a href="#"><span class="mnuTxt">TREE</span></a>
		</li>
		<li AMNUID="TREE" MENUID="TREE_DEFAULT">
			<a href="#" onclick="goPage(this, '/demo/tree/tree.page')">
				<span class="mnuTxt">Tree</span>
			</a>
		</li>
		<li AMNUID="DEMO" MENUID="HWLS">
			<a href="#"><span class="mnuTxt">HWLS</span></a>
		</li>
		<li AMNUID="HWLS" MENUID="HWLS_DEFAULT">
			<a href="#" onclick="goPage(this, '/demo/hwls/hwls.page')">
				<span class="mnuTxt">hwls</span>
			</a>
		</li>
		<li AMNUID="HWLS" MENUID="HWLS_GRID_FILE_UPLOAD">
			<a href="#" onclick="goPage(this, '/demo/hwls/grid_file_upload.page')">
				<span class="mnuTxt">GRID 파일 업로드</span>
			</a>
		</li>
		<li AMNUID="root" MENUID="APROVE">
			<a href="#"><span class="mnuTxt">APROVE</span></a>
		</li>
		<li AMNUID="APROVE" MENUID="APROVE_MASTER">
			<a href="#" onclick="goPage(this, '/aprove/AL01.page')">
				<span class="mnuTxt">Aprove master</span>
			</a>
		</li>
		<li AMNUID="APROVE" MENUID="APROVE_REQUEST">
			<a href="#" onclick="goPage(this, '/aprove/AR01.page')">
				<span class="mnuTxt">Aprove request</span>
			</a>
		</li>
		<li AMNUID="APROVE" MENUID="APROVE_DEMO">
			<a href="#" onclick="goPage(this, '/aprove/AD01.page')">
				<span class="mnuTxt">Aprove demo</span>
			</a>
		</li>
<%
	}
%>