package project.common.bean;

import javax.servlet.http.HttpSession;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class CommonUser {
	static final Logger log = LogManager.getLogger(CommonUser.class.getName());
	
	private DataMap sessionIdMap;
	private DataMap userIdMap;
	
	public CommonUser(){
		sessionIdMap = new DataMap();
		userIdMap = new DataMap();
	}
	
	public String getUserId(HttpSession session){
		BaseUser user;
		HttpSession tmpSession;
		if(this.sessionIdMap.containsKey(session.getId())){
			user = (BaseUser)this.sessionIdMap.get(session.getId());
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
				killSession(tmpSession, userId, typeKey);
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
	
	public void addSessionMap(String sessionId, BaseUser user){
		this.sessionIdMap.put(sessionId, user);
	}
	
	public BaseUser getSessionUser(String sessionId){
		BaseUser user;
		HttpSession tmpSession;
		if(this.sessionIdMap.containsKey(sessionId)){
			user = (BaseUser)this.sessionIdMap.get(sessionId);
			tmpSession = (HttpSession)this.userIdMap.get(user.getUserKey());
			if(tmpSession != null){
				return user;
			}
		}
		
		return null;
	}
	
	public void killSession(HttpSession session, String userId, String typeKey){
		BaseUser user;
		HttpSession tmpSession;
		String userKey = userId+CommonConfig.DATA_CELL_SEPARATOR+typeKey;
		if(this.userIdMap.containsKey(userKey)){
			tmpSession = (HttpSession)this.userIdMap.get(userKey);
			if(tmpSession != null){
				this.sessionIdMap.remove(tmpSession.getId());
				try {
					tmpSession.invalidate();
				}catch(Exception e) {
					log.error("Session.invalidate()", e);
				}
				this.userIdMap.remove(userKey);
			}				
		}
	}
}