package ezgen;

import java.io.*;
import java.util.Enumeration;
import java.util.Properties;

import javax.servlet.*;
import javax.servlet.http.*;

import org.apache.log4j.lf5.util.ResourceUtils;
import org.springframework.core.io.support.PropertiesLoaderSupport;
import org.springframework.core.io.support.PropertiesLoaderUtils;

import elsoft.unicode.jdbc.*;

//주의 hnwjdbc.java 이름을 다른이름.java로 변경사용시 public class 다른이름 extends HttpServlet
public class hnwjdbc extends HttpServlet {
	//DBMS와 접속을 위한 고정 변수 elsjdbc의 Connect Pooling을 위한 필수 멤버 입니다.
	//아래의 문자 값은 DBMS마다 조금식 차이가 있습니다.
	//Connect Pooling을 위한 멤버 -------------------------------------------------------------------
	static String m_stDriverClass = "";
	
	//<!-- LOTOS Development DB -->
	static String m_stURL = "";
	static String m_stUID = "";
	static String m_stPWD = "";
	
	static String m_stLogFile = "";
	static String m_stConLogFile = "";
	
	//-----------------------------------------------------------------------------------------------
	static final int m_nMaxThreads = 10;	//최대 동시 접속 수를 지정합니다.
	static final int m_nTimeOut = 60;		//최대 동시 접속 수를 초과시 대기시간(초)

	//Encoding을 위한 멤버 --------------------------------------------------------------------------
//	public final static int IN_NONE = 0;
//	public final static int IN_ENG_TO_KOR = 1;
//	public final static int IN_KOR_TO_ENG = 2;	//보통 DB NLS가 영문일때

//	public final static int OUT_NONE = 0;
//	public final static int OUT_TO_KOR = 1;
//	public final static int OUT_ENG_TO_KOR = 2;	//보통 DB NLS가 영문일때

//	static final String m_stEncoding = "KSC5601";	//Unicode를 Encoding 문자(KSC5601,MS949,...)로 변환합니다.
//	static final int m_nInEncoding = IN_NONE;			//Input String 변환형식.
//	static final int m_nOutEncoding = OUT_NONE;		//Output Stringf 변환 형식.
//	static final boolean m_bTrim = false;					//문자 필드 Trim 사용 여부.
	
	//Log을 위한 멤버 -------------------------------------------------------------------------------
	//static final int m_nLogType = 2;		//0:하지않음,1:System.out,2:사용자 파일
	//static final String m_stLogFile = "c:\\temp\\ezgen.log";
	//static final int m_nConLogType = 2;	//0:하지않음,1:System.out,2:사용자 파일
	//static final String m_stConLogFile = "c:\\temp\\ezgencon.log";
	
	//Pool을 위한 멤버 ------------------------------------------------------------------------------
	private int m_nMonitorInterval = 600;	//600초(10분) 주기 마다 쓰레드가 돌면서 Connection 의 상태를 검점합니다.
	private int m_nPoolTimeout = 3000; 		//3000초(50분) 동안 놀고 있는 커넥션이 있다면 reap 쓰레드가 제거합니다.
	
	//elsjdbc를 생성 합니다.(필수 사항) -------------------------------------------------------------
	private elsjdbc m_HnwQuery = new elsjdbc(m_nMonitorInterval,m_nPoolTimeout);
	
	
	
	//HttpServlet 기본 함수로 Servlet POST 요청시 호출되는 함수입니다. ------------------------------
	public void doPost(HttpServletRequest request, HttpServletResponse response)
        	throws ServletException, IOException
	{
//		request.setCharacterEncoding("euc-kr");
		m_HnwQuery.setLogFile(1,m_stLogFile);
		m_HnwQuery.setLogConnect(1,m_stConLogFile);
		//m_HnwQuery.setLogFile(1,"C:\\ezgen.log");
		//m_HnwQuery.setLogConnect(1,"C:\\ezgen2.log");
		
		response.setContentType("text/html;charset=EUC-KR");
		try {
			m_HnwQuery.RunQuery(request,response);	//elsjdbc Connect Pooling을 사용하여 쿼리를 실행합니다.
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}
	
	//HttpServlet 기본 함수로 Servlet GET 요청시 호출되는 함수입니다. -------------------------------
	public void doGet(HttpServletRequest request, HttpServletResponse response)
        	throws ServletException, IOException
	{
//		request.setCharacterEncoding("euc-kr");
		response.setContentType("text/html;charset=EUC-KR");
		try {
			m_HnwQuery.getStatus(request,response);	//Connect Pooling에 대한 현재 정보(elsjdbc의 현재 정보)를 모니터링합니다. 
		} catch (Exception e) {
			System.out.println(e.getMessage());
		}
	}
	
	//Servlet 초기화시 호출되는 함수입니다. ---------------------------------------------------------
	//elsjdbc의 Connect Pooling을 위한 필수 함수로 웹서버 자체 Connect Pooling을 사용할 경우 아래 함수를 삭제 하십시오.
	//------>
	public void init(ServletConfig config) throws ServletException {
		super.init(config);
		
		if(m_stURL.equals("")){
			try {
				String contextConfigLocation = config.getInitParameter("contextConfigLocation");
				String rPath = config.getServletContext().getRealPath(contextConfigLocation);
				
				File file = new File(rPath);
				if(!file.isFile()){
					throw new ServletException();
				}
				FileInputStream fis = new FileInputStream(file);
				Properties properties = new Properties();
				properties.load(fis);
				m_stDriverClass = properties.getProperty("jdbc.driverClassName");
				m_stURL = properties.getProperty("jdbc.url");
				m_stUID = properties.getProperty("jdbc.username");
				m_stPWD = properties.getProperty("jdbc.password");
				
				rPath = rPath.substring(1, rPath.indexOf("WEB-INF"));
				
				m_stLogFile = rPath+"log/ezgen.log";
				m_stConLogFile = rPath+"log/ezgencon.log";
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		m_HnwQuery.init(m_stDriverClass,m_nMaxThreads,m_nTimeOut,m_stURL,m_stUID,m_stPWD);
//		m_HnwQuery.UseEncoding(m_nInEncoding,m_nOutEncoding,m_stEncoding,m_bTrim);	//Encoding 문자를 사용할 경우 지정합니다.
		
		//DNS 필터 보안 -------------------------------------------------------------------------------
		//필터 추가시 도메인과 IP를 모두 추가하여 사용 하십시오.
		//m_HnwQuery.addDNSFilter("129.1.*");
		//m_HnwQuery.addDNSFilter("www.ezgen.co.kr");
	}
	
	//Servlet 종료시 호출되는 함수로 Connect된 모든 Pooling를 닫습니다. -----------------------------
 	public void destroy() {
		super.destroy();
		m_HnwQuery.release();
	}
}