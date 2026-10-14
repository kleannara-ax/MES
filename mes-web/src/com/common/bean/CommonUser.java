package com.common.bean;

import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;

public class CommonUser {
	private static Logger log = Logger.getLogger(CommonUser.class);
	
	private DataMap sessionIdMap;
	private DataMap userIdMap;
	
	public CommonUser(){
		sessionIdMap = new DataMap();
		userIdMap = new DataMap();
	}
	
	public String getUserId(HttpSession session){
		User user;
		HttpSession tmpSession;
		if(this.sessionIdMap.containsKey(session.getId())){
			user = (User)this.sessionIdMap.get(session.getId());
			return user.getUserid();
		}
		
		return null;	
	}
	
	public boolean addUserIdMap(HttpSession session, String userId, String typeKey){
		String userKey = userId+CommonConfig.DATA_CELL_SEPARATOR+typeKey;
		HttpSession tmpSession;
		if(this.userIdMap.containsKey(userKey)){
			tmpSession = (HttpSession)this.userIdMap.get(userKey);
			if(tmpSession == null){
				this.userIdMap.put(userKey, session);
				return true;
			}else if(tmpSession.getId() == null){
				tmpSession.invalidate();
				this.userIdMap.put(userKey, session);
				return true;
			}else if(tmpSession.getId() == session.getId()){
				return true;
			}else{
				return false;
			}
		}else{
			this.userIdMap.put(userKey, session);
		}
		
		return true;
	}
	
	public void addSessionMap(String sessionId, User user){
		this.sessionIdMap.put(sessionId, user);
	}
	
	public User getSessionUser(String sessionId){
		User user;
		HttpSession tmpSession;
		if(this.sessionIdMap.containsKey(sessionId)){
			user = (User)this.sessionIdMap.get(sessionId);
			tmpSession = (HttpSession)this.userIdMap.get(user.getUserKey());
			if(tmpSession != null){
				return user;
			}
		}
		
		return null;
	}
	
	public void killSession(String userId, String typeKey){
		User user;
		HttpSession tmpSession;
		String userKey = userId+CommonConfig.DATA_CELL_SEPARATOR+typeKey;
		if(this.userIdMap.containsKey(userKey)){
			tmpSession = (HttpSession)this.userIdMap.get(userKey);
			if(tmpSession != null){
				this.sessionIdMap.remove(tmpSession.getId());
				tmpSession.invalidate();
				this.userIdMap.remove(userKey);
			}
		}
	}
}