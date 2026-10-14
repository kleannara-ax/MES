package project.common.util;

 

import java.security.SecureRandom;

 

import org.apache.commons.lang.RandomStringUtils;

 

public class Keygen {

	

	private final static String KEY_STR = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

	private final static String KEY_NUM_STR = "0123456789";

 

	public static void main(String[] args) {

		// TODO Auto-generated method stub

		/*

		String authNo = makeRandomPassword(10)+makeRandomPassword(10);

		authNo = authNo.substring(0, 16);

		

		System.out.print(authNo);

		*/

		String smsNum = makeRandomNumber(6);

		

		System.out.print(smsNum);

	}

 

	public static String makeRandomPassword(int randomStrLength2){

        StringBuilder sb = new StringBuilder(1000);

 

        int randomStrLength = 7;

 

        char[] possibleCharacters = KEY_STR.toCharArray();

//        sb.append(RandomStringUtils.random( randomStrLength, 0, possibleCharacters.length-1, false, false, possibleCharacters, new SecureRandom()));
        sb.append(RandomStringUtils.random( randomStrLength, false, true));

//        SecureRandom secRandom = new SecureRandom();
//
//        int length = secRandom.nextInt(randomStrLength2 -1); //렌덤으로 가져온 size에 특수문자를 넣어준다.
//
//        sb.insert(length, "!"); //응용하면 여기서 특수문자를 렌덤으로 넣는 것도 괜찮은 방법이다.
//
//        int length2 = secRandom.nextInt(randomStrLength2 -1);
//
//        sb.insert(length2, "@");
//
//        int length3 = secRandom.nextInt(randomStrLength2 -1);
//
//        sb.insert(length3, "#");
 

		return sb.toString();

	}

	

	public static String makeRandomNumber(int randomStrLength){

        StringBuilder sb = new StringBuilder(1000);

 

        char[] possibleCharacters = KEY_NUM_STR.toCharArray();

        sb.append(RandomStringUtils.random( randomStrLength, 0, possibleCharacters.length-1, false, false, possibleCharacters, new SecureRandom()));

 

		return sb.toString();

	}

}