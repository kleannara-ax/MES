package com.common.util;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.Locale;
import java.util.Date;

public class DateUtil {
	
	public static String getFormatString(String pattern) {
		SimpleDateFormat formatter = new SimpleDateFormat(pattern, Locale.KOREA);
		String dateString = formatter.format(new Date());
		return dateString;
	}

	//현재 시각을 "yyyyMMdd" 형태의 문자열로 표현하여 리턴한다
	public static String getShortDateString() {
		return getFormatString("yyyyMMdd");
	}
	
	//현재 시각을 "HHmmss" 형태의 문자열로 표현하여 리턴한다.
	public static String getShortTimeString() {
		return getFormatString("HHmmss");
	}
	
	public static String getShortFormString(String form) {
		return getFormatString(form);
	}
	
	public static String getShortTimeString1() {
		return getFormatString("HH:mm:ss");
	}
	
	Calendar calendar = null;

	public DateUtil(){
		calendar = Calendar.getInstance( );
	}
	
	// date = yyyymmdd;
	public DateUtil(String date){
		calendar = new GregorianCalendar(getInt(date.substring(0,4)), getInt(date.substring(4,6))-1, getInt(date.substring(6,8)));
	}
	
	public void setDate(){
		calendar = Calendar.getInstance( );
	}
	
	//date = yyyymmdd;
	public void setDate(String date){
		calendar = new GregorianCalendar(getInt(date.substring(0,4)), getInt(date.substring(4,6))-1, getInt(date.substring(6,8)));
	}
	
	public int getYear(){
		return calendar.get(Calendar.YEAR);
	}
	
	public int getMonth(){
		return calendar.get(Calendar.MONTH)+1;
	}
	
	public String getMonthString(){
		return addZero(2,calendar.get(Calendar.MONTH)+1);
	}
	
	public int getDay(){
		return calendar.get(Calendar.DAY_OF_MONTH);
	}
	
	public String getDayString(){
		return addZero(2,calendar.get(Calendar.DAY_OF_MONTH));
	}
	
	//0 = 일요일
	public int getWeek(){
		return calendar.get(Calendar.DAY_OF_WEEK);
	}
	
	public void setMonthFirstDay(){
		setDate(getDate().substring(0,6)+"01");
	}
	
	public void setMonthLastDay(){
		addMonth(1);
		setMonthFirstDay();
		addDay(-1);
	}
	
	public void addDay(int amount){
		calendar.add(Calendar.DAY_OF_MONTH, amount);
	}
	
	public void addMonth(int amount){
		calendar.add(Calendar.MONTH, amount);
	}
	
	public void addYear(int amount){
		calendar.add(Calendar.YEAR, amount);
	}
	
	public int getInt(String num){
		int rs;
		try{
			rs = Integer.parseInt(num);
		}catch(Exception e){
			rs = -1;
		}
		
		return rs;
	}
	
	public String addZero(int zero, int num){
		String rs = "";
		String tmp = num+"";
		if(zero > tmp.length()){
			for(int i=0;i<zero-tmp.length();i++){
				rs += "0";
			}
			rs += tmp;
		}else{
			rs = tmp;
		}
		
		return rs;
	}
	
	public String getDate(){
		return calendar.get(Calendar.YEAR)
				+addZero(2, calendar.get(Calendar.MONTH)+1)
				+addZero(2, calendar.get(Calendar.DAY_OF_MONTH));
	}
	
	public String getTime(){
		return addZero(2,calendar.get(Calendar.HOUR_OF_DAY))
				+addZero(2, calendar.get(Calendar.MINUTE))
				+addZero(2, calendar.get(Calendar.SECOND));
	}
	
	public static void main(String[] args) {
		System.out.println(DateUtil.getShortTimeString1());
	}
}
