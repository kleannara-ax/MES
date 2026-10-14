package com.common.util;

import java.text.CharacterIterator;
import java.text.StringCharacterIterator;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.common.bean.CommonConfig;

public class StringUtility {
	public static String singleSpaceReturn(String text) {
		char[] toCharArray = text.toCharArray();
		int index = 1;

		for (int i = 1; i < toCharArray.length; i++) {
			toCharArray[index] = toCharArray[i];
			if (toCharArray[index] != ' ') {
				index++;
			} else if (toCharArray[index - 1] != ' ') {
				index++;
			}
		}

		return new String(toCharArray, 0, index).trim();
	}
	
	public Map getStringToMap(String str){
		Map map = new HashMap();
		
		String[] list = str.split(CommonConfig.DATA_ROW_SEPARATOR);
		String[] row;
		for(int i=0;i<list.length;i++){
			row = list[i].split(CommonConfig.DATA_COL_SEPARATOR);
			if(row.length > 1){
				map.put(row[0], row[1]);
			}
		}
		
		return map;
	}
	
	public List getStringToList(String str){
		List list = new ArrayList();
		String[] strList = str.split(CommonConfig.DATA_ROW_SEPARATOR);
		
		for(int i=0;i<strList.length;i++){
			list.add(strList[i]);
		}
		
		return list;
	}
	
	public static String leftPad(String stringToPad, String padder, int size) {
		StringBuffer strb;
		StringCharacterIterator sci;

		if (padder.length() == 0)
			return stringToPad;

		if (isNull(stringToPad)) {
			char[] t = new char[size];
			for (int i = 0; i < t.length; i++)
				t[i] = padder.charAt(0);

			stringToPad = String.valueOf(t);
		}

		strb = new StringBuffer(size);
		sci = new StringCharacterIterator(padder);

		while (strb.length() < (size - stringToPad.length()))
			for (char ch = sci.first(); ch != CharacterIterator.DONE; ch = sci.next())
				if (strb.length() < size - stringToPad.length())
					strb.insert(strb.length(), String.valueOf(ch));
		return strb.append(stringToPad).toString();
	}
	public static String rightPad(String stringToPad, String padder, int size) {
		StringBuffer strb;
		StringCharacterIterator sci;

		if (padder.length() == 0)
			return stringToPad;

		if (isNull(stringToPad)) {
			char[] t = new char[size];
			for (int i = 0; i < t.length; i++)
				t[i] = padder.charAt(0);
			stringToPad = String.valueOf(t);
		}

		strb = new StringBuffer(stringToPad);
		sci = new StringCharacterIterator(padder);

		while (strb.length() < size) {
			for (char ch = sci.first(); ch != CharacterIterator.DONE; ch = sci.next())
				if (strb.length() < size)
					strb.append(String.valueOf(ch));
		}
		return strb.toString();
	}
	
	public static String isNull(String value, String defalutValue) {
		return isNull(value) ? defalutValue : value;
	}
	
	public static boolean isNull(String value) {
		return (value == null);
	}
}