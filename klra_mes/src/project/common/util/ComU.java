package project.common.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

import org.apache.commons.lang.StringUtils;
//import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;

//import com.mysql.cj.util.StringUtils;

import project.common.bean.DataMap;
public class ComU {
	
	private static Logger log = Logger.getLogger(ComU.class);
    /**
     * CommonUtil 기본 생성자
     */
    public ComU() {
        super();
    }
    
    /**
     * <p>문자열이 비어있거나("") null인 경우를 검사합니다</p>
     *
     * <pre>
     * StringUtils.isEmpty(null)      = true
     * StringUtils.isEmpty("")        = true
     * StringUtils.isEmpty(" ")       = false
     * StringUtils.isEmpty("bob")     = false
     * StringUtils.isEmpty("  bob  ") = false
     * </pre>
     *
     * @param str  검사할 문자열
     * @return 문자열이 비어있거나 null인 경우<code>true</code>를 반환
     */
    public static boolean isEmpty(String str) {
         return StringUtils.isEmpty(str);
    }
    /**
     * <p>문자열이 비어있지 않거나 null이 아닌경우를 검사합니다</p>
     *
     * <pre>
     * StringUtils.isNotEmpty(null)      = false
     * StringUtils.isNotEmpty("")        = false
     * StringUtils.isNotEmpty(" ")       = true
     * StringUtils.isNotEmpty("bob")     = true
     * StringUtils.isNotEmpty("  bob  ") = true
     * </pre>
     *
     * @param str  검사할 문자열
     * @return 문자열이 비어있지 않거나 null이 아닌 경우<code>true</code>를 반환
     */
    public static boolean isNotEmpty(String str) {
         return StringUtils.isNotEmpty(str);
    }

    /**
     * <p>문자열이 공백문자 , 빈 문자열 또는 null인지 검사합니다</p>
     *
     * <pre>
     * StringUtils.isBlank(null)      = true
     * StringUtils.isBlank("")        = true
     * StringUtils.isBlank(" ")       = true
     * StringUtils.isBlank("bob")     = false
     * StringUtils.isBlank("  bob  ") = false
     * </pre>
     *
     * @param str  검사할 문자열
     * @return 문자열이 공백문자 ,빈 문자열 또는 null이면<code>true</code> 를 반환합니다
     */
    public static boolean isBlank(String str) {
         return StringUtils.isBlank(str);
    }

    /**
     * <p>문자열이 공백문자 , 빈 문자열 또는 null가 아닌지 검사합니다</p>
     *
     * <pre>
     * StringUtils.isNotBlank(null)      = false
     * StringUtils.isNotBlank("")        = false
     * StringUtils.isNotBlank(" ")       = false
     * StringUtils.isNotBlank("bob")     = true
     * StringUtils.isNotBlank("  bob  ") = true
     * </pre>
     *
     * @param str  검사할 문자열
     * @return 문자열이 공백문자 ,빈 문자열 또는 null이 아니면 <code>true</code> 를 반환합니다
     */
    public static boolean isNotBlank(String str) {
         return StringUtils.isNotBlank(str);
    }
    
    
    /****************************************************************************************************************************
    *** Trim 관련 
    ****************************************************************************************************************************/
    
    
    /**
     * <p>문자열 앞 뒤에 불필요한 null이나 빈 문자열이 있다면 삭제합니다.</p>
     *
     * <pre>
     * StringUtils.clean(null)          = ""
     * StringUtils.clean("")            = ""
     * StringUtils.clean("abc")         = "abc"
     * StringUtils.clean("    abc    ") = "abc"
     * StringUtils.clean("     ")       = ""
     * </pre>
     *
     * @see java.lang.String#trim()
     * @param str  불필요한 공백을 삭제할 문자열
     * @return 공백을 제거한 문자열
     */

    @SuppressWarnings("deprecation")
     public static String clean(String str) {
         return StringUtils.clean(str);
    }

    /**
     * <p>문자열 앞 뒤에 불필요한 null이나 빈 문자열이 있다면 삭제합니다.</p>
     *
     * <pre>
     * StringUtils.trim(null)          = null
     * StringUtils.trim("")            = ""
     * StringUtils.trim("     ")       = ""
     * StringUtils.trim("abc")         = "abc"
     * StringUtils.trim("    abc    ") = "abc"
     * </pre>
     *
     * @param str  공백을 삭제할 문자열
     * @return 공백을 제거한 문자열, 만약 null을 입력했으면 <code>null</code> 반환합니다
     */
    public static String trim(String str) {
         return StringUtils.trim(str);
    }

    /**
     *<p>문자열 앞 뒤에 불필요한 null이나 빈 문자열이 있다면 삭제합니다.</p>
     *
     * <pre>
     * StringUtils.trimToNull(null)          = null
     * StringUtils.trimToNull("")            = null
     * StringUtils.trimToNull("     ")       = null
     * StringUtils.trimToNull("abc")         = "abc"
     * StringUtils.trimToNull("    abc    ") = "abc"
     * </pre>
     *
     * @param str  공백을 삭제할 문자열
     * @return the 공백을 제거한 문자열,만약 빈문자열이나 null 또는 공백 문자을 입력한 경우 <code>null</code>을 반환합니다
     */
    public static String trimToNull(String str) {
         return StringUtils.trimToNull(str);
    }

    /**
     * <p>문자열 앞 뒤에 불필요한 null이나 빈 문자열이 있다면 삭제합니다.</p>
     *
     * <pre>
     * StringUtils.trimToEmpty(null)          = ""
     * StringUtils.trimToEmpty("")            = ""
     * StringUtils.trimToEmpty("     ")       = ""
     * StringUtils.trimToEmpty("abc")         = "abc"
     * StringUtils.trimToEmpty("    abc    ") = "abc"
     * </pre>
     *
     * @param str  공백을 삭제할 문자열
     * @return the 공백을 제거한 문자열g, 만약 <code>null</code> 을 입력하면 빈 문자열을 반환합니다.
     */
    public static String trimToEmpty(String str) {
         return StringUtils.trimToEmpty(str);
    }

    
    
    /****************************************************************************************************************************
    *** Equals 관련 
    ****************************************************************************************************************************/
    
    
    /**
     * <p>두 문자열을 비교해서 문자열이 같다면 <code>true</code> 를 반환합니다</p>
     *
     * <p>예외없이 <code>null</code>을 처리합니다 두개의 <code>null</code> 레퍼런스는 같은 것으로 간주됩니다</p>
     *
     * <pre>
     * StringUtils.equals(null, null)   = true
     * StringUtils.equals(null, "abc")  = false
     * StringUtils.equals("abc", null)  = false
     * StringUtils.equals("abc", "abc") = true
     * StringUtils.equals("abc", "ABC") = false
     * </pre>
     *
     * @see java.lang.String#equals(Object)
     * @param str1  비교할 첫번째 문자열
     * @param str2  비교할 두번째 문자열
     * @return 두개의 문자열이 같거나 두 문자열이 둘다 null일 경우 true을 반환합니다.
     */
    public static boolean equals(String str1, String str2) {
         return StringUtils.equals(str1, str2);
    }

    /**
     * <p>두 문자열을 대소문자 구분없이 비교해서 문자열이 같다면 <code>true</code> 를 반환합니다</p>
     *
     * <p>예외없이 <code>null</code>을 처리합니다 두개의 <code>null</code> 레퍼런스는 같은 것으로 간주됩니다</p>
     *
     * <pre>
     * StringUtils.equalsIgnoreCase(null, null)   = true
     * StringUtils.equalsIgnoreCase(null, "abc")  = false
     * StringUtils.equalsIgnoreCase("abc", null)  = false
     * StringUtils.equalsIgnoreCase("abc", "abc") = true
     * StringUtils.equalsIgnoreCase("abc", "ABC") = true
     * </pre>
     *
     * @see java.lang.String#equalsIgnoreCase(String)
     * @param str1  비교할 첫번째 문자열
     * @param str2  비교할 두번째 문자열
     * @return 두개의 문자열이 같거나 두 문자열이 둘다 null일 경우 true을 반환합니다.
     */
    public static boolean equalsIgnoreCase(String str1, String str2) {
         return StringUtils.equalsIgnoreCase(str1, str2);
    }
    
    /****************************************************************************************************************************
    *** Date/Time 관련 
    ****************************************************************************************************************************/    
    
    /**
     * <p>dateType 별로 날짜/시간을 반환합니다.</p>
     *
     * <pre>
     * dateType : A   = yyyy/MM/dd hh:mm:ss
     * dateType : D   = yyyy/MM/dd
     * dateType : H   = hh:mm:ss
     * dateType : HN   = hhmmss
     * </pre>
     *
     * @param dateType  비교할 첫번째 문자열
     * @return dateType 별로 날짜/시간을 반환합니다.
     */
    public static String getDateTime(String dateType) {
    	String nowDate = null;
    	Date date = new Date();  

    	if(ComU.equals("A", dateType)) {
    		//여기서 MM은 대문자로 써줘야지 month(월)이 제대로 표시된다.
    		SimpleDateFormat dayTime = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");  
    		nowDate = dayTime.format(date);
    		
    	} else if(ComU.equals("D", dateType)){
    		SimpleDateFormat dayTime = new SimpleDateFormat("yyyy/MM/dd");
    		nowDate = dayTime.format(date);
    		
    	} else if(ComU.equals("H", dateType)){
    		SimpleDateFormat dayTime = new SimpleDateFormat("hh:mm:ss");
    		nowDate = dayTime.format(date);
    	} else if(ComU.equals("HN", dateType)){
    		SimpleDateFormat dayTime = new SimpleDateFormat("hhmmss");
    		nowDate = dayTime.format(date);
    	} else if(ComU.equals("DN", dateType)){
    		SimpleDateFormat dayTime = new SimpleDateFormat("yyyyMMdd");
    		nowDate = dayTime.format(date);
    	}
    	  
    	return nowDate;
	}
    
    /**
     * <p>dateType 별로 오늘 또는 이전 날짜를 반환합니다.</p>
     *
     * <pre>
     * dateType : N, dateCount: "" = 오늘 기준 날짜.
     * dateType : D, dateCount: "1" = 날짜 단위 기준으로 이전날짜. (하루전 날짜)
     * dateType : W, dateCount: "1" = 주   단위 기준으로 이전날짜. (일주일전 날짜)
     * dateType : M, dateCount: "1" = 월   단위 기준으로 이전날짜. (한달전 날짜)
     * dateType : Y, dateCount: "1" = 년   단위 기준으로 이전날짜. (일년전 날짜)
     * </pre>
     *
     * @param dateType   오늘, 일 ,주, 월, 년 단위 선택.
     * @param dateCount  구하고자 하는 수.
     * @return 단위에 따라 이전 일자를 구해서 리턴한다.
     */
    public static String GetCalendarDate (String dateType, String dateCount) {

    	Calendar cal = Calendar.getInstance();
    	String toDay = null;
    	int rtnVal;

    	// 오늘 날짜 인지 Check
    	if (!ComU.equals("N", dateType)) {

	    	// Day 인지 Check
	    	if (ComU.equals("D", dateType)) {
		    	rtnVal = Integer.parseInt(dateCount);
		    	cal.add(Calendar.DATE, -rtnVal);
	    	}
	
	    	// Week 인지 Check
	    	if (ComU.equals("W", dateType)) {
		    	rtnVal = Integer.parseInt(dateCount) * 7;
		    	cal.add(Calendar.DATE, -rtnVal);
	    	}
	
	    	// Month 인지 Check
	    	if (ComU.equals("M", dateType)) {
		    	rtnVal = Integer.parseInt(dateCount);
		    	cal.add(Calendar.MONTH, -rtnVal);
	    	}
	
	    	// Year 인지 Check
	    	if (ComU.equals("Y", dateType)) {
		    	rtnVal = Integer.parseInt(dateCount);
		    	cal.add(Calendar.YEAR, -rtnVal);
	    	}
    	}

    	String year = Integer.toString(cal.get(Calendar.YEAR));
    	String mon = Integer.toString(cal.get(Calendar.MONTH)+1);
    	String day = Integer.toString(cal.get(Calendar.DAY_OF_MONTH));

    	// Month 가 2자리 이하일때 공백을 0 으로 채워준다.
    	if (mon.length() < 2 ) {
    		mon = "0" + mon;
    	}
    	// Day 가 2자리 이하일때 공백을 0 으로 채워준다.
    	if (day.length() < 2 ) {
    		day = "0" + day;
    	}

//    	toDay = year + "-"+ mon + "-"+ day;
    	toDay = year + "" + mon + "" + day;

    	return toDay;

    }

    
    /****************************************************************************************************************************
    *** Replacing 관련 
    ****************************************************************************************************************************/
    
    /**
     * <p>문자열에 지정한 문자중에서 첫번째 문자를 다른 문자로 대체해서 반환합니다.</p>
     *
     * <pre>
     * StringUtils.replaceOnce(null, *, *)        = null
     * StringUtils.replaceOnce("", *, *)          = ""
     * StringUtils.replaceOnce("any", null, *)    = "any"
     * StringUtils.replaceOnce("any", *, null)    = "any"
     * StringUtils.replaceOnce("any", "", *)      = "any"
     * StringUtils.replaceOnce("aba", "a", null)  = "aba"
     * StringUtils.replaceOnce("aba", "a", "")    = "ba"
     * StringUtils.replaceOnce("aba", "a", "z")   = "zba"
     * </pre>
     *
     * @see #replace(String text, String searchString, String replacement, int max)
     * @param text  피 문자열
     * @param searchString  바뀔 문자열
     * @param replacement  대체할 문자열
     * @return 바뀐 문자열
     */
    public static String replaceOnce(String text, String searchString, String replacement) {
         return StringUtils.replaceOnce(text, searchString, replacement);
    }

    /**
     * <p>문자열에 지정한 문자를 모두 다른 문자로 대체해서 반환합니다.</p>
     *
     * <pre>
     * StringUtils.replace(null, *, *)        = null
     * StringUtils.replace("", *, *)          = ""
     * StringUtils.replace("any", null, *)    = "any"
     * StringUtils.replace("any", *, null)    = "any"
     * StringUtils.replace("any", "", *)      = "any"
     * StringUtils.replace("aba", "a", null)  = "aba"
     * StringUtils.replace("aba", "a", "")    = "b"
     * StringUtils.replace("aba", "a", "z")   = "zbz"
     * </pre>
     *
     * @see #replace(String text, String searchString, String replacement, int max)
     * @param text  피 문자열
     * @param searchString  바뀔 문자열
     * @param replacement  대체할 문자열
     * @return 바뀐 문자열
     */
    public static String replace(String text, String searchString, String replacement) {
         return StringUtils.replace(text, searchString, replacement);
    }

    /**
     * <p>문자열에 지정한 문자중에서 첫번째 문자부터 지정한 인덱스까지 다른 문자로 대체해서 반환합니다.</p>
     *
     * <pre>
     * StringUtils.replace(null, *, *, *)         = null
     * StringUtils.replace("", *, *, *)           = ""
     * StringUtils.replace("any", null, *, *)     = "any"
     * StringUtils.replace("any", *, null, *)     = "any"
     * StringUtils.replace("any", "", *, *)       = "any"
     * StringUtils.replace("any", *, *, 0)        = "any"
     * StringUtils.replace("abaa", "a", null, -1) = "abaa"
     * StringUtils.replace("abaa", "a", "", -1)   = "b"
     * StringUtils.replace("abaa", "a", "z", 0)   = "abaa"
     * StringUtils.replace("abaa", "a", "z", 1)   = "zbaa"
     * StringUtils.replace("abaa", "a", "z", 2)   = "zbza"
     * StringUtils.replace("abaa", "a", "z", -1)  = "zbzz"
     * </pre>
     *
     * @param text  피 문자열
     * @param searchString  바뀔 문자열
     * @param replacement  대체할 문자열
     * @param max  대체할 최대 인덱스, 만약 지정된 값이 없으면 -1로 모든 문자를 치환합니다.
     * @return the text with any replacements processed,
     *  <code>null</code> if null String input
     */
    public static String replace(String text, String searchString, String replacement, int max) {
         return StringUtils.replace(text, searchString, replacement, max);
    }

    /**
     * <p>
     * 문자열에서 searchList에 있는 문자열들을 replacementList에 있는 문자열로 모두 대체합니다.
     * </p>
     *
     * <pre>
     *  StringUtils.replaceEach(null, *, *)        = null
     *  StringUtils.replaceEach("", *, *)          = ""
     *  StringUtils.replaceEach("aba", null, null) = "aba"
     *  StringUtils.replaceEach("aba", new String[0], null) = "aba"
     *  StringUtils.replaceEach("aba", null, new String[0]) = "aba"
     *  StringUtils.replaceEach("aba", new String[]{"a"}, null)  = "aba"
     *  StringUtils.replaceEach("aba", new String[]{"a"}, new String[]{""})  = "b"
     *  StringUtils.replaceEach("aba", new String[]{null}, new String[]{"a"})  = "aba"
     *  StringUtils.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"w", "t"})  = "wcte"
     *  (example of how it does not repeat)
     *  StringUtils.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"d", "t"})  = "dcte"
     * </pre>
     *
     * @param text 피 문자열
     * @param searchList 검색할 문자열이 있는 배열
     * @param replacementList 대체할 문자열이 있는 배열
     * @return 변환된 문자열
     * @throws 배열이 길이가 0이거나 null일 경우 IndexOutOfBoundsException이 발생
     * @since 2.4
     */
    public static String replaceEach(String text, String[] searchList, String[] replacementList) {
         return StringUtils.replaceEach(text, searchList, replacementList);
    }

    /**
     * <p>
     * 문자열에서 searchList에 있는 문자열들을 replacementList에 있는 문자열로 모두 대체합니다.
     * </p>
     *
     * <pre>
     *  StringUtils.replaceEach(null, *, *)        = null
     *  StringUtils.replaceEach("", *, *)          = ""
     *  StringUtils.replaceEach("aba", null, null) = "aba"
     *  StringUtils.replaceEach("aba", new String[0], null) = "aba"
     *  StringUtils.replaceEach("aba", null, new String[0]) = "aba"
     *  StringUtils.replaceEach("aba", new String[]{"a"}, null)  = "aba"
     *  StringUtils.replaceEach("aba", new String[]{"a"}, new String[]{""})  = "b"
     *  StringUtils.replaceEach("aba", new String[]{null}, new String[]{"a"})  = "aba"
     *  StringUtils.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"w", "t"})  = "wcte"
     *  (example of how it does not repeat)
     *  StringUtils.replaceEach("abcde", new String[]{"ab", "d"}, new String[]{"d", "t"})  = "dcte"
     * </pre>
     *
     * @param text 피 문자열
     * @param searchList 검색할 문자열이 있는 배열
     * @param replacementList 대체할 문자열이 있는 배열
     * @return 변환된 문자열
     * @throws 배열이 길이가 0이거나 null일 경우 IndexOutOfBoundsException이 발생
     * @since 2.4
     */
    public static String replaceEachRepeatedly(String text, String[] searchList, String[] replacementList) {
         return StringUtils.replaceEachRepeatedly(text, searchList, replacementList);
    }
    
    /****************************************************************************************************************************
    *** Replace, character based 관련 
    ****************************************************************************************************************************/
    /**
     * <p>문자열의 문자들을 지정한 문자로 모두 바꿉니다.</p>
     *
     * <p>문자열이 null일 경우 null을 반환합니다
     * 빈 문자열일 경우 빈 문자열을 반환합니다.</p>
     *
     * <pre>
     * StringUtils.replaceChars(null, *, *)        = null
     * StringUtils.replaceChars("", *, *)          = ""
     * StringUtils.replaceChars("abcba", 'b', 'y') = "aycya"
     * StringUtils.replaceChars("abcba", 'z', 'y') = "abcba"
     * </pre>
     *
     * @param str  변화할 문자열
     * @param searchChar  바뀔 문자
     * @param replaceChar  대체할 문자
     * @return 수정된 문자열
     */
    public static String replaceChars(String str, char searchChar, char replaceChar) {
         return StringUtils.replaceChars(str, searchChar, replaceChar);
    }

    /**
     * <p>문자열에서 지정한 문자열을 다른 문자열을 모두 바꿉니다.</p>
     *
     * <p>예를들어:<br />
     * <code>replaceChars(&quot;hello&quot;, &quot;ho&quot;, &quot;jy&quot;) = jelly</code>.</p>
     *
     * <p>문자열이 null일 경우 null을 반환합니다
     * 빈 문자열일 경우 빈 문자열을 반환합니다.</p>
     * null이나 빈문자열로 대체하려는 경우 원래 문자가 반환됩니다.</p>
     *
     *
     * <pre>
     * StringUtils.replaceChars(null, *, *)           = null
     * StringUtils.replaceChars("", *, *)             = ""
     * StringUtils.replaceChars("abc", null, *)       = "abc"
     * StringUtils.replaceChars("abc", "", *)         = "abc"
     * StringUtils.replaceChars("abc", "b", null)     = "ac"
     * StringUtils.replaceChars("abc", "b", "")       = "ac"
     * StringUtils.replaceChars("abcba", "bc", "yz")  = "ayzya"
     * StringUtils.replaceChars("abcba", "bc", "y")   = "ayya"
     * StringUtils.replaceChars("abcba", "bc", "yzx") = "ayzya"
     * </pre>
     *
     * @param str  변화할 문자열
     * @param searchChars  바뀔 문자열
     * @param replaceChars  대체할 문자열
     * @return 수정된 문자열
     */
    public static String replaceChars(String str, String searchChars, String replaceChars) {
         return StringUtils.replaceChars(str, searchChars, replaceChars);
    }
    
    /****************************************************************************************************************************
    *** Substring 관련 
    ****************************************************************************************************************************/
    
    /**
     * <p>문자열에서 주어진 위치부터 문자를 잘라서 반환합니다.</p>
     *문자열이 null인 경우 null을 리턴하고 빈 문자열일 경우 빈 문자열을 반환합니다
     * <pre>
     * StringUtils.substring(null, *)   = null
     * StringUtils.substring("", *)     = ""
     * StringUtils.substring("abc", 0)  = "abc"
     * StringUtils.substring("abc", 2)  = "c"
     * StringUtils.substring("abc", 4)  = ""
     * StringUtils.substring("abc", -2) = "bc"
     * StringUtils.substring("abc", -4) = "abc"
     * </pre>
     *
     * @param str  피 문자열
     * @param start  시작위치
     *
     * @return 주어진 위치에서 부터 잘라낸 문자열
     */
    public static String substring(String str, int start) {
         return StringUtils.substring(str, start);
    }

    /**
     * <p>문자열을 주어진 시작위치 부터 끝위치까지 잘라냅니다.</p>
     *
     * <pre>
     * StringUtils.substring(null, *, *)    = null
     * StringUtils.substring("", * ,  *)    = "";
     * StringUtils.substring("abc", 0, 2)   = "ab"
     * StringUtils.substring("abc", 2, 0)   = ""
     * StringUtils.substring("abc", 2, 4)   = "c"
     * StringUtils.substring("abc", 4, 6)   = ""
     * StringUtils.substring("abc", 2, 2)   = ""
     * StringUtils.substring("abc", -2, -1) = "b"
     * StringUtils.substring("abc", -4, 2)  = "ab"
     * </pre>
     *
     * @param str  피 문자열
     * @param start  시작위치
     * @param end  끝 위치
     * @return 주어진 위치에 의해 잘라진 문자열, 문자열이 null일 경우 null을 반환합니다
     *  <code>null</code> if null String input
     */
    public static String substring(String str, int start, int end) {
         return StringUtils.substring(str, start, end);
    }
    
    /****************************************************************************************************************************
    *** Left/Right/Mid 관련 
    ****************************************************************************************************************************/
    
    /**
     * <p>문자열을 왼쪽에서 부터 주어진 길이 만큼 잘라냅니다</p>
     *
     * <p>만약 길이가 문자열의 길이가 존재하지 않거나 문자열이 null이여도 예외없이 문자열을 반환합니다
     *     예외의 문자열의 길이에 의해서 발생됩니다.</p>
     *
     * <pre>
     * StringUtils.left(null, *)    = null
     * StringUtils.left(*, -ve)     = ""
     * StringUtils.left("", *)      = ""
     * StringUtils.left("abc", 0)   = ""
     * StringUtils.left("abc", 2)   = "ab"
     * StringUtils.left("abc", 4)   = "abc"
     * </pre>
     *
     * @param str  피 문자열
     * @param len  문자열을 잘라낼 길이, 길이는 0 이거나 반드시 존재해야 합니다.
     * @return 왼쪽에서 부터 주어진 길이 만큼 잘라낸 문자열, 문자열이 null일 경우 null을 반환합니다
     */
    public static String left(String str, int len) {
         return StringUtils.left(str, len);
    }

    /**
     ***
     * <p>문자열을 오른쪽에서 부터 주어진 길이 만큼 잘라냅니다</p>
     *
     * <p>만약 길이가 문자열의 길이가 존재하지 않거나 문자열이 null이여도 예외없이 문자열을 반환합니다
     *     예외의 문자열의 길이에 의해서 발생됩니다.</p>
     *
     * <pre>
     * StringUtils.right(null, *)    = null
     * StringUtils.right(*, -ve)     = ""
     * StringUtils.right("", *)      = ""
     * StringUtils.right("abc", 0)   = ""
     * StringUtils.right("abc", 2)   = "bc"
     * StringUtils.right("abc", 4)   = "abc"
     * </pre>
     *
     * @param str  피 문자열
     * @param len  문자열을 잘라낼 길이, 길이는 0 이거나 반드시 존재해야 합니다.
     * @return 오른쪽에서 부터 주어진 길이 만큼 잘라낸 문자열, 문자열이 null일 경우 null을 반환합니다
     */
    public static String right(String str, int len) {
         return StringUtils.right(str, len);
    }

    /**
     * <p>문자열을 주어진 위치부터 지정한 길이까지 잘라냅니다.</p>
     *
     * <p>만약 길이가 문자열의 길이가 존재하지 않거나 문자열이 null이여도 예외없이 문자열을 반환합니다
     *     예외의 문자열의 길이에 의해서 발생됩니다.</p>
     *
     * <pre>
     * StringUtils.mid(null, *, *)    = null
     * StringUtils.mid(*, *, -ve)     = ""
     * StringUtils.mid("", 0, *)      = ""
     * StringUtils.mid("abc", 0, 2)   = "ab"
     * StringUtils.mid("abc", 0, 4)   = "abc"
     * StringUtils.mid("abc", 2, 4)   = "c"
     * StringUtils.mid("abc", 4, 2)   = ""
     * StringUtils.mid("abc", -2, 2)  = "ab"
     * </pre>
     *
     * @param str  피 문자열
     * @param pos  시작 위치
     * @param len  문자열을 잘라낼 길이
     * @return 중간에서 부터 잘라낸 문자열, 문자열이 null일 경우 null을 반환합니다
     */
    public static String mid(String str, int pos, int len) {
         return StringUtils.mid(str, pos, len);
    }
    
    /*
     *  2015 - 10 - 17 
     *  성공 -> SKUWD 
     *	실패 -> SKUWD_T
     *	체크 : 길이 , 문자 , 숫자 
     *	
     */
    
    //문자길이 체크 
    public static boolean isStringlength(String data,int datalength){
    	data.trim();
    	if( data.length() > datalength ){
    		return true;
    	}
    	return false;
    }
   

    
    // 숫자 이고 길이가 맞으면 체크 
    public static boolean isStringDouble(String data, String type) {
    	boolean b_Chk = false;
    		
    	/**
    	 *  Case (A) : [ null, "", " ", 0 ] 
    	 */
		if(ComU.equals("A", type)) {
			
			try {
				if (ComU.isNotBlank(data) && !"0".equals(data)){
					Double.parseDouble(data);
					b_Chk =  false;
				}else{
					b_Chk  = true;
				}
			} catch (NumberFormatException e) {
				b_Chk  = true;
			}
			
		/**
		 *  Case (B) : [ null, "", " "] 
		 */
		}else if(ComU.equals("B", type)) {
			
			try {
				if (ComU.isNotBlank(data)){
					Double.parseDouble(data);
					b_Chk =  false;
				}else{
					b_Chk  = true;
				}
			} catch (NumberFormatException e) {
				b_Chk  = true;
			}
			
		/**
		 *  Case (C) : [ "," ] 
		 */
		}else if(ComU.equals("C", type)) {
			  
			try {
				if (data.indexOf(",") != -1){
					b_Chk  = true;
				}else{
					b_Chk =  false;
				}
			} catch (NumberFormatException e) {
				b_Chk  = true;
			}
			
		}else {
			b_Chk =  false;
		}
        	
    	return b_Chk;
    }
    /*
     * Type => F 유효성 걸림
     * Type => S 유효성 없음 
     */
    public static DataMap ExcelValidation(DataMap map){
    	
    	String Type = "S";
    	
    	if( "G".equals(map.getString("SCMZ00")) || "D".equals(map.getString("SCMZ00")) )
    	{ }else { Type="SCMZ00";  map.put("Type",Type); return map; }
    	if( isStringlength(map.getString("SCMZ01") ,20 ) )  { Type = "SCMZ01"; map.put("Type",Type); return map; }
    	if( !map.getString("SES_WAREKY").equals(map.getString("SCMY10")) ) { Type = "SCMY10"; map.put("Type",Type); return map; }
    	if( isStringlength(map.getString("SCMZ02"),20) ) { Type = "SCMZ02";  map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ03"),40) ) { Type = "SCMZ03";  map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ04"),30) ) { Type = "SCMZ04";  map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ05"),"C") ) { Type = "SCMZ05"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ06"),"F") ) { Type = "SCMZ06"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ07"),"F") ) { Type = "SCMZ07"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ08"),"F") ) { Type = "SCMZ08"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ09"),6) ) { Type = "SCMZ09"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ10"),1) ) { Type = "SCMZ10"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ11"),1) ) { Type = "SCMZ11"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ12"),1) ) { Type = "SCMZ12"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ13"),20) ) { Type = "SCMZ13"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ14"),1) ) { Type = "SCMZ14"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ15"),4) ) { Type = "SCMZ15"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ16"),"A") ) { Type = "SCMZ16"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ17"),"F") ) { Type = "SCMZ17"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ18"),"F") ) { Type = "SCMZ18"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ19"),1) ) { Type = "SCMZ19"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ20"),20) ) { Type = "SCMZ20"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ21"),40) ) { Type = "SCMZ21"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ22"),20) ) { Type = "SCMZ22";	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ23"),"F") ) { Type = "SCMZ23"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ24"),"F") ) { Type = "SCMZ24"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ25"),40) ) { Type = "SCMZ25";	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ26"),4) ) { Type = "SCMZ26"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ27"),30) ) { Type = "SCMZ27"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ28"),1) ) { Type = "SCMZ28"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ29"),"F") ) { Type = "SCMZ29"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ30"),"F") ) { Type = "SCMZ30"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ31"),"F") ) { Type = "SCMZ31"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ32"),"F") ) { Type = "SCMZ32"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ33"),3) ) { Type = "SCMZ33"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ34"),5) ) { Type = "SCMZ34"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ35"),5) ) { Type = "SCMZ35"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ36"),5) ) { Type = "SCMZ36"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ37"),20) ) { Type = "SCMZ37"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ38"),100) ) { Type = "SCMZ38";map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ39"),40) ) { Type = "SCMZ39"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ40"),1) ) { Type = "SCMZ40"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ41"),40) ) { Type = "SCMZ41";	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ51"),3) ) { Type = "SCMZ51"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ52"),"F") ) { Type = "SCMZ52";  	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ53"),"F") ) { Type = "SCMZ53";  	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ54"),1) ) { Type = "SCMZ54"; 	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ58"),1) ) { Type = "SCMZ58"; 	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ59"),"F") ) { Type = "SCMZ59";  	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ60"),"F") ) { Type = "SCMZ60";  	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ65"),"F") ) { Type = "SCMZ65";  	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ82"),1) ) { Type = "SCMZ82";  map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ83"),"F") ) { Type = "SCMZ83";  	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ86"),10) ) { Type = "SCMZ86"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ87"),20) ) { Type = "SCMZ87"; map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ92"),"F") ) { Type = "SCMZ92";  	map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ93"),"F") ) { Type = "SCMZ93";  	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ94"),40) ) { Type = "SCMZ94"; map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMZ95"),"F") ) { Type = "SCMZ95";  	map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ96"),1) ) { Type = "SCMZ96";  map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ97"),1) ) { Type = "SCMZ97";  map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMZ99"),10) ) { Type = "SCMZ99";  map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMY01"),120) ) { Type = "SCMY01"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMY02"),120) ) { Type = "SCMY02"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMY03"),120) ) { Type = "SCMY03"; map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMY04"),30) ) { Type = "SCMY04";  map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMY05"),40) ) { Type = "SCMY05";  map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMY06"),20) ) { Type = "SCMY06";  map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMY07"),"F") ) { Type = "SCMY07";  	 map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMY08"),20) ) { Type = "SCMY08";  map.put("Type",Type); return map;}
    	if( isStringDouble(map.getString("SCMY09"),"F") ) { Type = "SCMY09";  	 map.put("Type",Type); return map;}
    	if( isStringlength(map.getString("SCMY11"),1) ) { Type = "SCMY11";   map.put("Type",Type); return map;}
    	
    	map.put("Type",Type);
		return map;
    }
    // 자바 sha256 암호화 add pjw 
    public static String Sha256Encrypt(String str) {
    	String SHA = ""; 
    	try{
    		MessageDigest sh = MessageDigest.getInstance("SHA-256"); 
    		sh.update(str.getBytes()); 
    		byte byteData[] = sh.digest();
    		StringBuffer sb = new StringBuffer(); 
    		for(int i = 0 ; i < byteData.length ; i++){
    			sb.append(Integer.toString((byteData[i]&0xff) + 0x100, 16).substring(1));
    		}
    		SHA = sb.toString();
    		
    	}catch(NoSuchAlgorithmException e){
    		log.debug(e.getMessage()); 
    		SHA = null; 
    	}
    	return SHA;
    }
    
    public static String getLastMsg(String txt) {
    	if(isEmpty(txt)) return "";
		
		if (-1 < txt.indexOf("@*") && -1 < txt.indexOf("*@")) {
			txt = txt.substring(txt.lastIndexOf("@*")+2, txt.lastIndexOf("*@"));
		} else{
			txt = "시스템 오류가 발생했습니다.\n관리자에게 문의해 주세요.";
		}
		return txt;
	}
}
