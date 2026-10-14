package project.common.airfw;

public class Utils {

	
	// 패스워드 구성이 연속된 숫자나 영문으로 4개 이상인지 체크
	public boolean passwd_count(String passwd){
		int x = 0, count2 = 1, count3 = 1;
	
		for( x = 0 ; x < passwd.length() ; x++) {
			char temp_p = '\u0000';
			char temp_pass1 = '\u0000';
			char temp_c = '\u0000';
		
			temp_pass1 = passwd.charAt(x);// 입력받은 비밀번호의 char값
		
			if((x+1) == passwd.length()) {
				break;
			} else {
				temp_p = passwd.charAt(x+1);// 입력받은 비밀번호의 현재 index의 다음 index char값(index+1)
				temp_c = (char)(temp_pass1+1);// 입력받은 char값의 다음 char값 ( ex. a 다음은 b, 1 다음은 2...)
			}
		
			if(temp_c == temp_p) {// 입력받은 char값의 다음 index char값과 다음 char값을 비교
				count3 = count3 + 1;
			} else {
				count3 = 1;
			}
		
			if (count3 > 3) break;
		}
	
		if(count3 > 3) {
			return false;
		} else {
			return true;
		}	
	}
	
	public static double parseDouble(Object value) {
		try {
			String str = value.toString();
			return Double.parseDouble(str);
		} catch(Exception e) {
			return 0;
		}
	}
}
