<%@ page import="project.common.bean.CommonConfig" %>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">

<body onload="document.forms[0].submit()">
<form action="https://ssodev.kleannara.com/loginProduct.do" method="post">
    <div>
        <!—legacy 시스템별 식별 entityId -->
        <input type="hidden" name=entityId value="<%=CommonConfig.SSO_SITE_URL%>"/>
        <!—legacy 시스템별 통합로그인 후 이동되어야 할 페이지 주소  -->
        <input type="hidden" name="relayState" value="<%=CommonConfig.getMES_SITE()%>/sso/assertionConsumer.page"/>
    </div>
    <noscript>
        <div>
            <input type="submit" value="Continue"/>
        </div>
    </noscript>
</form>
</body>
</html>
