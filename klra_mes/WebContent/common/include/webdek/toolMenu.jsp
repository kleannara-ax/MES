<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="project.common.bean.CommonConfig"%>
<%
	String userid = (String)request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY);	
	String pmenuid = (String)request.getSession().getAttribute("PMENUID");

	if(userid != null && (userid.equals("WDSCM") || userid.equals("DEV"))){
%>
		<li AMNUID="root" MENUID="DEMO">
			<a href="#"><span class="mnuTxt">DEMO</span></a>
		</li>
		<li AMNUID="DEMO" MENUID="WEBDEK">
			<a href="#"><span class="mnuTxt">WEBDEK</span></a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_LAYOUT_SETTING">
			<a href="#" onclick="goPage(this, '/demo/webdek/layout_setting.page')">
				<span class="mnuTxt">사용자 설정 팝업</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_INPUT_DEFAULT">
			<a href="#" onclick="goPage(this, '/demo/webdek/input.page')">
				<span class="mnuTxt">Input</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_DEFAULT">
			<a href="#" onclick="goPage(this, '/demo/webdek/gridSingle.page')">
				<span class="mnuTxt">Grid</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_2">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid2grid.page')">
				<span class="mnuTxt">2 Grid</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_3">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid3grid.page')">
				<span class="mnuTxt">3 Grid</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_1_2">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid1-2Hgrid.page')">
				<span class="mnuTxt">1-2H Grid</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_1_3">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid1-3Hgrid.page')">
				<span class="mnuTxt">1-3H Grid</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_2_2">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid2-2Hgrid.page')">
				<span class="mnuTxt">2-2H Grid</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_2H_2H">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid2H-2H.page')">
				<span class="mnuTxt">2H-2H Grid</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_2H_2H_NOTAB">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid2H-2H-NOTAB.page')">
				<span class="mnuTxt">2H-2H Grid without tab</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_2_H">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid2grid_horizontal.page')">
				<span class="mnuTxt">Grid 2H</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_3_H">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid3grid_horizontal.page')">
				<span class="mnuTxt">Grid 3H</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_INNER">
			<a href="#" onclick="goPage(this, '/demo/webdek/gridSingle-inner.page')">
				<span class="mnuTxt">Grid inner list + search</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_INNER_2">
			<a href="#" onclick="goPage(this, '/demo/webdek/gridSingle-inner-2.page')">
				<span class="mnuTxt">Grid inner list + list</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_2H_SEARCH">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid2H-SEARCH.page')">
				<span class="mnuTxt">grid2H-SEARCH</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_SEARCH_2H">
			<a href="#" onclick="goPage(this, '/demo/webdek/gridSEARCH-2H.page')">
				<span class="mnuTxt">gridSEARCH-2H</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_NOTICE_ICON">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid_noticeIcon.page')">
				<span class="mnuTxt">grid Notice Icon</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_ICON">
			<a href="#" onclick="goPage(this, '/demo/webdek/gridSingle_icon.page')">
				<span class="mnuTxt">grid Icon</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_WIDE">
			<a href="#" onclick="goPage(this, '/demo/webdek/gridSingle_wide.page')">
				<span class="mnuTxt">grid Wide ver.</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_2_WIDE">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid2grid_wide.page')">
				<span class="mnuTxt">2 Grid Wide ver.</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_3H_CHART">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid3grid_chart.page')">
				<span class="mnuTxt">Grid 3H Chart</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_ICON">
			<a href="#" onclick="goPage(this, '/demo/webdek/gridSingle_icon.page')">
				<span class="mnuTxt">grid Icon</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_SEARCH_3GRID">
			<a href="#" onclick="goPage(this, '/demo/webdek/gridSingle-SEARCH-3grid.page')">
				<span class="mnuTxt">grid 5</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_3_S5">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid3-S5.page')">
				<span class="mnuTxt">grid 3 Search 5</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_2_3S">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid2_3S.page')">
				<span class="mnuTxt">grid2 3S</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_TREE">
			<a href="#" onclick="goPage(this, '/demo/webdek/tree.page')">
				<span class="mnuTxt">tree</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_GRIDTREE">
			<a href="#" onclick="goPage(this, '/demo/webdek/gridTree.page')">
				<span class="mnuTxt">gridTree</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_3_HEIGHT">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid3grid_height.page')">
				<span class="mnuTxt">grid3 height</span>
			</a>
		</li>
		<li AMNUID="WEBDEK" MENUID="WEBDEK_GRID_4_3S">
			<a href="#" onclick="goPage(this, '/demo/webdek/grid4_3S.page')">
				<span class="mnuTxt">grid4 3S</span>
			</a>
		</li>
		<li AMNUID="root" MENUID="SAMPLE">
			<a href="#"><span class="mnuTxt">SAMPLE</span></a>
		</li>
		<li AMNUID="SAMPLE" MENUID="SAMPLE_INPUT">
			<a href="#"><span class="mnuTxt">INPUT</span></a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_COMPOP">
			<a href="#" onclick="goPage(this, '/demo/input/commonpop.page')">
				<span class="mnuTxt">commonpop</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_COMBO">
			<a href="#" onclick="goPage(this, '/demo/input/combo.page')">
				<span class="mnuTxt">combo</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_DAUMPOST">
			<a href="#" onclick="goPage(this, '/demo/input/daumpost.page')">
				<span class="mnuTxt">Daum post</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_SEARCHLISTPARAM">
			<a href="#" onclick="goPage(this, '/demo/input/search-list-param.page')">
				<span class="mnuTxt">search-list-param</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_LAYERPOP">
			<a href="#" onclick="goPage(this, '/demo/input/layerpop.page')">
				<span class="mnuTxt">layerpop</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_WINPOP">
			<a href="#" onclick="goPage(this, '/demo/input/windowpop.page')">
				<span class="mnuTxt">Windowpop</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_MENULINK">
			<a href="#" onclick="goPage(this, '/demo/input/menuopen.page')">
				<span class="mnuTxt">Menu open</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_MENULINKPOP">
			<a href="#" onclick="goPage(this, '/demo/input/menuopen_pop.page')">
				<span class="mnuTxt">Menu open pop</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_VALMSG">
			<a href="#" onclick="goPage(this, '/demo/input/validataMsg.page')">
				<span class="mnuTxt">Validata message</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_INPUTFORM">
			<a href="#" onclick="goPage(this, '/demo/input/inputFormat.page')">
				<span class="mnuTxt">Input format</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_RANGEGROUP">
			<a href="#" onclick="goPage(this, '/demo/input/rangeGroup.page')">
				<span class="mnuTxt">Range group</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_INPUT" MENUID="SAMPLE_EZGEN">
			<a href="#" onclick="goPage(this, '/demo/input/ezgen.page')">
				<span class="mnuTxt">ezgen</span>
			</a>
		</li>
		<li AMNUID="SAMPLE" MENUID="SAMPLE_GRID">
			<a href="#"><span class="mnuTxt">GRID</span></a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDPK">
			<a href="#" onclick="goPage(this, '/demo/grid/gridPk.page')">
				<span class="mnuTxt">gridPk</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDRITEM">
			<a href="#" onclick="goPage(this, '/demo/grid/gridItem.page')">
				<span class="mnuTxt">Grid item</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDFILE">
			<a href="#" onclick="goPage(this, '/demo/grid/gridFile.page')">
				<span class="mnuTxt">gridFile</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDFILEM">
			<a href="#" onclick="goPage(this, '/demo/grid/gridFileM.page')">
				<span class="mnuTxt">gridFileM</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDMHEAD">
			<a href="#" onclick="goPage(this, '/demo/grid/gridMultiHead.page')">
				<span class="mnuTxt">gridMultiHead</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDROWMOVE">
			<a href="#" onclick="goPage(this, '/demo/grid/gridRowMove.page')">
				<span class="mnuTxt">gridRowMove</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDR2GRID">
			<a href="#" onclick="goPage(this, '/demo/grid/grid2grid.page')">
				<span class="mnuTxt">Grid to Grid</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDRCRELOAD">
			<a href="#" onclick="goPage(this, '/demo/grid/gridComboReload.page')">
				<span class="mnuTxt">Grid combo reload</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDRJSON">
			<a href="#" onclick="goPage(this, '/demo/grid/gridJson.page')">
				<span class="mnuTxt">Grid json</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDEVENTTEST">
			<a href="#" onclick="goPage(this, '/demo/grid/gridEventTest.page')">
				<span class="mnuTxt">Grid event</span>
			</a>
		</li>
		<li AMNUID="SAMPLE_GRID" MENUID="SAMPLE_GRIDCOLOR">
			<a href="#" onclick="goPage(this, '/demo/grid/gridColor.page')">
				<span class="mnuTxt">Grid color</span>
			</a>
		</li>
		<li AMNUID="SAMPLE" MENUID="SAMPLE_CHART">
			<a href="#"><span class="mnuTxt">CHART</span></a>
		</li>
		<li AMNUID="SAMPLE_CHART" MENUID="SAMPLE_FCHART">
			<a href="#" onclick="goPage(this, '/demo/chart/fusioncharts.page')">
				<span class="mnuTxt">fusioncharts</span>
			</a>
		</li>
		<li AMNUID="root" MENUID="TREE">
			<a href="#"><span class="mnuTxt">TREE</span></a>
		</li>
		<li AMNUID="TREE" MENUID="TREE_SAMPLE">
			<a href="#" onclick="goPage(this, '/demo/tree/tree.page')">
				<span class="mnuTxt">Tree</span>
			</a>
		</li>
<%
	}
%>