package com.common.task;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;

//@Service
public class SampleTask1 {
	private static Logger log = Logger.getLogger(SampleTask1.class);

	@Autowired
	private SampleAsyncTask sampleAsyncTask;
	
	//@Scheduled(fixedRate=100)
	public void tskTest(){
		log.info("start : "+this.hashCode());
		try {
			Thread.sleep(5000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		for (int i = 0; i < 5; i++) {
			sampleAsyncTask.asyncTask(this.hashCode());
			//sampleAsyncTask.taskTest();
		}
		log.info("end : "+this.hashCode());
	}
}
