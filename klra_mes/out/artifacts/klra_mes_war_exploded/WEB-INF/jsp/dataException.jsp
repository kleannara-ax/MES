<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="
        org.apache.logging.log4j.LogManager,
        org.apache.logging.log4j.Logger,
        java.util.UUID,
        java.util.Enumeration,
        java.util.Set,
        java.util.HashSet,
        java.util.Arrays,
        javax.servlet.RequestDispatcher,
        org.springframework.web.util.HtmlUtils"
%>

<%!
    private static final Logger log = LogManager.getLogger("DataExceptionJSP");

    private Throwable getRootCause(Throwable t) {
        if (t == null) return null;
        Throwable cur = t;
        int guard = 0;
        while (cur.getCause() != null && cur.getCause() != cur && guard++ < 50) {
            cur = cur.getCause();
        }
        return cur;
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().length() == 0;
    }

    private String safeString(Object obj) {
        if (obj == null) return "";
        try {
            return String.valueOf(obj);
        } catch (Throwable t) {
            return "[[STRING_CONVERSION_FAILED:" + t.getClass().getName() + "]]";
        }
    }

    private boolean isSensitiveKey(String key) {
        if (key == null) return false;
        String k = key.toLowerCase();
        return k.contains("password") || k.contains("passwd") || k.contains("pwd")
                || k.contains("token") || k.contains("authorization") || k.contains("secret")
                || k.contains("credential") || k.contains("j_password") || k.contains("loginpw") || k.contains("userpw");
    }

    private String joinParameterValues(String[] values) {
        if (values == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < values.length; i++) {
            if (i > 0) sb.append(", ");
            sb.append(values[i]);
        }
        return sb.toString();
    }

    private String normalizeClientMessage(String msg) {
        if (msg == null) return "SYSTEM_ERROR";
        String s = msg.replace('\r', ' ').replace('\n', ' ').trim();
        if (s.length() == 0) return "SYSTEM_ERROR";
        if (s.length() > 500) s = s.substring(0, 500);
        return s;
    }

    private String getRawErrorMessage(Throwable ex, Throwable root) {
        if (root instanceof StackOverflowError || ex instanceof StackOverflowError) {
            return "StackOverflowError";
        } else if (root != null && !isBlank(root.getMessage())) {
            return root.getMessage();
        } else if (ex != null && !isBlank(ex.getMessage())) {
            return ex.getMessage();
        }
        return "SYSTEM_ERROR";
    }
%>

<%
    /*************************************************
     * Request 정보 사전 조회
     *************************************************/
    Object statusCodeObj = request.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
    Object originalUriObj = request.getAttribute(RequestDispatcher.ERROR_REQUEST_URI);
    Object servletNameObj = request.getAttribute(RequestDispatcher.ERROR_SERVLET_NAME);

    String currentUri = safeString(request.getRequestURI());
    String originalUri = safeString(originalUriObj);
    String method = safeString(request.getMethod());
    String remoteAddr = safeString(request.getRemoteAddr());
    String queryString = safeString(request.getQueryString());
    String dispatchType = safeString(request.getDispatcherType());
    String servletName = safeString(servletNameObj);

/*************************************************
 * Error Page 재진입 방지
 *************************************************/
    if (Boolean.TRUE.equals(request.getAttribute("__DATA_EXCEPTION_PAGE_VISITED__"))) {
        log.error("==============================================================");
        log.error("DATA EXCEPTION PAGE RE-ENTRY DETECTED");
        log.error("THREAD          : {}", Thread.currentThread().getName());
        log.error("CURRENT URI     : {}", currentUri);
        log.error("==============================================================");

        response.setStatus(500);
        out.clear();
        out.print("SYSTEM_ERROR");
        return;
    }

    request.setAttribute("__DATA_EXCEPTION_PAGE_VISITED__", Boolean.TRUE);

/*************************************************
 * Skip URI
 *************************************************/
//    Set<String> skipUriSet = new HashSet<String>(Arrays.asList(
//            "/wms/inventory/json/MV01CreatTaskOrder.data"
//    ));
//
//    if (skipUriSet.contains(originalUri)) {
//        response.setStatus(500);
//        out.clear();
//        out.print("SYSTEM_ERROR");
//        return;
//    }
//

/*************************************************
 * Error ID
 *************************************************/
    String errorId = UUID.randomUUID().toString();

/*************************************************
 * Exception 추출 및 로깅
 *************************************************/
    Throwable ex = (Throwable) request.getAttribute("exceptionMsg");
    if (ex == null) {
        ex = (Throwable) request.getAttribute(RequestDispatcher.ERROR_EXCEPTION);
    }
    Throwable root = getRootCause(ex);

    log.error("==============================================================");
    log.error("                  DATA EXCEPTION OCCURRED");
    log.error("==============================================================");
    log.error("ERROR ID        : {}", errorId);
    log.error("THREAD          : {}", Thread.currentThread().getName());
    log.error("METHOD          : {}", method);
    log.error("ORIGINAL URI    : {}", originalUri);
    log.error("REMOTE ADDR     : {}", remoteAddr);
    log.error("STATUS CODE     : {}", safeString(statusCodeObj));

/*************************************************
 * Parameter 마스킹 로깅
 *************************************************/
    Enumeration<String> names = request.getParameterNames();
    while (names != null && names.hasMoreElements()) {
        String name = null;
        try {
            name = names.nextElement();
            if (isSensitiveKey(name)) {
                log.error("PARAM [{}] = ******", name);
            } else {
                log.error("PARAM [{}] = {}", name, joinParameterValues(request.getParameterValues(name)));
            }
        } catch (Throwable t) {
            log.error("PARAM LOGGING FAILED [{}]", safeString(name));
        }
    }

/*************************************************
 * StackTrace 출력
 *************************************************/
    if (root instanceof StackOverflowError || ex instanceof StackOverflowError) {
        Throwable target = (root instanceof StackOverflowError) ? root : ex;
        StackTraceElement[] arr = target.getStackTrace();
        log.error("STACKOVERFLOW DETECTED - FIRST 30 FRAMES");
        for (int i = 0; i < Math.min(arr.length, 30); i++) {
            log.error("[{}] {}", i, arr[i]);
        }
    } else if (ex != null) {
        log.error("FULL STACK TRACE", ex);
    }
    log.error("==============================================================");

/*************************************************
 * Client Response 처리
 *************************************************/
    String rawMsg = getRawErrorMessage(ex, root);

// 버퍼 초기화 (이전 출력물 제거)
    out.clear();

    if ("Session Dup".equals(rawMsg)) {
        response.setStatus(200); // 스크립트 실행을 위해 200 처리
%>
<script>
    alert("다른 서비스에서 동일 계정으로 로그인하여 접속이 종료되었습니다.");
    window.top.location.href = "/index.jsp";
</script>
<%
    } else {
        int sc = 500;
        try {
            if (statusCodeObj != null) sc = Integer.parseInt(statusCodeObj.toString());
        } catch (Throwable t) { sc = 500; }
        if (sc < 400) sc = 500;

        response.setStatus(sc);

        // 일반 에러 메시지 HTML Escape 및 출력
        String clientMsg = HtmlUtils.htmlEscape(normalizeClientMessage(rawMsg));
        out.print(clientMsg);
    }
%>