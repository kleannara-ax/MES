package com.common.task;

import org.apache.log4j.Logger;
import org.springframework.core.task.TaskExecutor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
public class SampleAsyncTask {

	private static Logger log = Logger.getLogger(SampleAsyncTask.class);	

	TaskExecutor executor;
	
	public SampleAsyncTask(){}
	
	public SampleAsyncTask(TaskExecutor taskExecutor){
		this.executor = taskExecutor;
	}
	
	@Async
	public void taskTest(){
		executor.execute(new Task());
	}
	
	private class Task implements Runnable {
        public void run() {
        	try {
    			Thread.sleep(1000);
    		} catch (InterruptedException e) {
    			// TODO Auto-generated catch block
    			e.printStackTrace();
    		}
    		
    		log.info(this.hashCode());
        }
    }
	
	@Async
	public void asyncTask(int code){
		try {
			Thread.sleep(1000);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		log.info(this.hashCode());
	}
}