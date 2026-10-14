<%@ page import="project.common.bean.CommonConfig" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html lang="en">
<head>
  <title>전자결재 호출 예제</title>
</head>
<body>
<!-- 결재요청 항목 -->
<form id="approval" name="approval" method="post">
  <input type="hidden" name="targetUrl" value="/groupware/approval/apprDocPost.do"/>
  <input type="hidden" name="userId" value="hnw.shyou"/>
  <input type="hidden" name="formCd" value="MES001"/>
  <input type="hidden" name="appKey01" value="AA1050600"/>
  <input type="hidden" name="appKey02" value=""/>
  <input type="hidden" name="appKey03" value=""/>
  <input type="hidden" name="appKey04" value=""/>
  <input type="hidden" name="appKey05" value=""/>
  <input type="hidden" name="title" value="검사성적서"/>
<%--  <input type="hidden" name="htmlParam" value="&lt;html&gt;&lt;head&gt;   &lt;title&gt;계약서&lt;/title&gt;&lt;/head&gt;&lt;body&gt; &lt;table style=border-top-color:#e5e5e5;border-top-width:1px;border-top-style:solid;&gt;   &lt;colgroup&gt;&lt;col width=15%&gt;&lt;col width=35%&gt;&lt;col width=15%&gt;&lt;col width=35%&gt;&lt;/colgroup&gt;&lt;tbody&gt;&lt;tr&gt;    &lt;th&gt;문서번호&lt;/th&gt;   &lt;td&gt;CON202107210001   &lt;/td&gt; &lt;th&gt;차수&lt;/th&gt; &lt;td&gt;1.00  &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;계약명&lt;/th&gt;    &lt;td colspan=3&gt;전자결재 테스트    &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;계약구분&lt;/th&gt;   &lt;td&gt;신규    &lt;/td&gt; &lt;th&gt;계약기간&lt;/th&gt;   &lt;td&gt;2021.07.01~2021.07.31 &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;Category&lt;/th&gt;   &lt;td&gt;ERP 매입 계약서    &lt;/td&gt; &lt;th&gt;프로젝트&lt;/th&gt;   &lt;td&gt;1111  &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;계약대상구분&lt;/th&gt; &lt;td&gt;기업    &lt;/td&gt; &lt;th&gt;계약대상&lt;/th&gt;   &lt;td&gt;테스트 기업 001(1046886)   &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;작성자&lt;/th&gt;    &lt;td&gt;IT기획팀/이미연 &lt;/td&gt; &lt;th&gt;작성일자&lt;/th&gt;   &lt;td&gt;2021.07.21    &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;담당자(정)&lt;/th&gt; &lt;td&gt;이미연   &lt;/td&gt; &lt;th&gt;담당자(부)&lt;/th&gt; &lt;td&gt;  &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;회계검토대상&lt;/th&gt; &lt;td&gt;회계검토 대상   &lt;/td&gt; &lt;th&gt;법무검토대상&lt;/th&gt; &lt;td&gt;법무검토 대상   &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;사업장&lt;/th&gt;    &lt;td&gt;본사    &lt;/td&gt; &lt;th&gt;세금계산서&lt;/th&gt;  &lt;td&gt;정발행   &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;자동연장&lt;/th&gt;   &lt;td colspan=3&gt;예   &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;td colspan=4&gt;매입계약서&lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;   &lt;th&gt;지급조건&lt;/th&gt;   &lt;td&gt;전자어음(일반) 고지   &lt;/td&gt; &lt;th&gt;리스계약포함여부&lt;/th&gt;   &lt;td&gt;아니오   &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;리베이트기준&lt;/th&gt; &lt;td colspan=3&gt;전자결재 테스트    &lt;/td&gt;&lt;/tr&gt;&lt;tr&gt;    &lt;th&gt;비용기준&lt;/th&gt;   &lt;td colspan=3&gt;전자결재 테스트    &lt;/td&gt;&lt;/tr&gt;&lt;/tbody&gt;   &lt;/table&gt;&lt;p&gt;&lt;br/&gt;&lt;/p&gt;&lt;/body&gt;&lt;/html&gt;"/>--%>
  <input type="hidden" name="htmlParam" value="<%=request.getAttribute("html")%>"/>
<%--  <input type="hidden" name="formEditorData" value="&lt;p style=&#034;font-family: &amp;quot;맑은 고딕&amp;quot;; font-size: 12pt; line-height: 19.2px; margin-top: 0px; margin-bottom: 0px;&#034;&gt;매입 계약서 수정&lt;/p&gt;"/>--%>
  <input type="hidden" name="formEditorData" value="<%=request.getAttribute("html")%>"/>
<%--  <input type="hidden" name="attachFile" value="1.jpg|D:\통합결재\깨끗한나라 EP 통합 결재 API 연계 가이드_V0.6_20210721.docx"/>--%>
<%--  <input type="hidden" name="attachFile" value="2.jpg|http://rule.kleannara,.com/2.jpg"/>--%>
<%--  <input type="hidden" name="attachFile" value="3.jpg|http://rule.kleannara,.com/3.jpg"/>--%>
</form>

<script type="text/javascript" language="javascript">

  // 팝업오픈하여 폼데이터 Post 전송
  function openPop(){

    var pop_title = "approvalSyncFormPopup" ;

    var features = "channelmode=no, directories=no, location=no, menubar=no, scrollbars=yes, status=no, titlebar=no, toolbar=no, width=1070, height=635, fullscreen=no, left=745, top=207, resizable=no, scrollbars=yes";
    var popupOpen = window.open(null, pop_title, features);

    var frmData = document.approval ;

    // 개발서버
    frmData.action = '<%=CommonConfig.getGW_SITE()%>/support/ssoProxy.do';
    // 운영서버
    // frmData.action = 'https://gw.kleannara.com/support/ssoProxy.do';

    frmData.target = pop_title ;
    frmData.submit();

    var isPopUp = true;

    /*
    * 팝업 호출 이후 1초간격으로 팝업닫힘을 체크하며
    * 팝업이 닫히면 닫힌 이후 처리로직 구현
    */
    var interval = window.setInterval(function() {
      try {
        //console.log('popupOpen = ' + popupOpen);
        if (popupOpen == null || popupOpen.closed) {
          isPopUp = false;
          //console.log('popupOpen = ' + isPopUp);
          // alert('팝업 닫힘');
          // 팝업 닫힌 후 로직 구현
          clearInterval(interval);
        }
      } catch (e) {
        console.log(e);
        clearInterval(interval);
      }
    }, 1000);

  }

</script>

<a href="#" onClick="openPop();">전자결재 팝업</a>

</body>
</html>
