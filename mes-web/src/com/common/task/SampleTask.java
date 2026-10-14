package com.common.task;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.task.TaskExecutor;

public class SampleTask {
	
	private static Logger log = Logger.getLogger(SampleTask.class);

	@Autowired
	private SampleAsyncTask sampleAsyncTask;
	
	TaskExecutor executor;
	
	public SampleTask(TaskExecutor taskExecutor){
		this.executor = taskExecutor;
	}
	
	public void taskTest(){
		 for (int i = 0; i < 3; i++) {
            executor.execute(new Task());
        }
	}

    private class Task implements Runnable {
        public void run() {
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
}