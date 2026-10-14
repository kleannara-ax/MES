package com.common.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import org.owasp.encoder.Encode;

public class XSSRequestWrapper extends HttpServletRequestWrapper {

	public XSSRequestWrapper(HttpServletRequest request) {
		super(request);
	}
	
	/**
	 * <pre>
	 * XSS 대응 필터
	 * 전반적으로 모든 XSS에 대응 하기 어렵기 때문에
	 * 'SCRIPT', 'STYLE' 단어에 대해 치환
	 * </pre>
	 * @param sInvalid
	 * @return
	 */
	public String getXSSFilter(String sInvalid) {
		
		String sValid = sInvalid;
		if (sValid == null || sValid.equals("")) {
			return "";
		}
		
		//sValid = sValid.replaceAll("(?i)script", " S  C  R  I  P  T ");
		//sValid = sValid.replaceAll("(?i)style", " S  T  Y  L  E ");
		sValid = Encode.forHtml(sValid);
		
		return sValid;
	}

	
	public String getParameter(String name) {
		
		String tmpVal = super.getParameter(name);
		if(null == tmpVal || "".equals(tmpVal.trim())){
			return tmpVal;
		}
		return getXSSFilter(tmpVal);
	}


	
	public String[] getParameterValues(String name) {
		String[] tmpVals = super.getParameterValues(name);
		
		if(tmpVals == null){
			return null;
		}
		int iLen = tmpVals.length;
		String [] rtnVals = new String[iLen];
		for(int i = 0; i < iLen; i += 1){
			rtnVals[i] = getXSSFilter(tmpVals[i]);
		}// end of for
		
		return rtnVals;
	}

}
