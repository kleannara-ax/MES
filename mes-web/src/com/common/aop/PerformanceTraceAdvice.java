package com.common.aop;

import org.apache.log4j.Logger;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.Signature;

public class PerformanceTraceAdvice {
	private static Logger log = Logger.getLogger(PerformanceTraceAdvice.class);
	
	public Object trace(ProceedingJoinPoint joinPoint) throws Throwable{
		Signature signature = joinPoint.getSignature();
		log.info("PerformanceTraceAdvice : " + signature.toShortString() + " Start");
		long start = System.currentTimeMillis();
		try {
			Object result = joinPoint.proceed();
			return result;
		} finally {
			log.info("PerformanceTraceAdvice : " +signature.toShortString() + " RunTime : "+(System.currentTimeMillis() - start)+"ms");
		}
	}
}