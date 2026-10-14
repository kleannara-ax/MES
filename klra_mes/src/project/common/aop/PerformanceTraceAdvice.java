package project.common.aop;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.Signature;

public class PerformanceTraceAdvice {
	static final Logger log = LogManager.getLogger(PerformanceTraceAdvice.class.getName());
	
	public Object trace(ProceedingJoinPoint joinPoint) throws Throwable{
		Signature signature = joinPoint.getSignature();
		log.debug("PerformanceTraceAdvice : " + signature.toShortString() + " Start");
		long start = System.currentTimeMillis();
		try {
			Object result = joinPoint.proceed();
			return result;
		} finally {
			log.debug("PerformanceTraceAdvice : " +signature.toShortString() + " RunTime : "+(System.currentTimeMillis() - start)+"ms");
		}
	}
}