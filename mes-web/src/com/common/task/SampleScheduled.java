package com.common.task;

import org.apache.log4j.Logger;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

@Service
public class SampleScheduled {

	private static Logger log = Logger.getLogger(SampleScheduled.class);	
	
	//@Scheduled(fixedRate=10000)
	public void tenSecond(){
		log.debug("tenSecond");
	}

	//@Scheduled(cron="0 0/5 * * * *")
	public void cronFiveMinute(){
		log.debug("cronFiveMinute");
	}
}