package com.common.task;

import java.sql.SQLException;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.common.service.CommonService;

@Service
public class DBConnectionKeeperTask {
	private static Logger log = Logger.getLogger(DBConnectionKeeperTask.class);

	@Autowired
	public CommonService commonService;
	
	@Scheduled(cron="0 0/1 * * * *")
	public void DBConnectionKeeping(){
		try {
			commonService.keepConnectionDatabase();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}