package project.common.task.shedlock;

import net.javacrumbs.shedlock.core.LockConfiguration;
import net.javacrumbs.shedlock.core.LockProvider;
import net.javacrumbs.shedlock.core.SimpleLock;
import net.javacrumbs.shedlock.provider.jdbctemplate.JdbcTemplateLockProvider;
import org.apache.log4j.Logger;

import java.time.Instant;
import java.util.Date;
import java.util.Optional;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;

import static java.time.temporal.ChronoUnit.MILLIS;

/**jdbc分布式锁调度
 * @Desc
 * @Author zzb
 * @CreateTime 2019/12/9 10:36
 */
public class JdbcLockService {
    private static Logger log = Logger.getLogger(JdbcLockService.class);


    /**提供参数，没有返回值
     * @param name
     * @param lockAtMostLen
     * @param lockAtLeastLen
     * @param supplier
     * @param param
     * @param 
     * @throws Exception
     */
    public static <T>  void startSupplierTask(String name, long lockAtMostLen, long lockAtLeastLen, Supplier<T> supplier,T param) throws Exception{
        startTask(name,lockAtMostLen,lockAtLeastLen,null,param,null,supplier,null);
    }

    /**没有参数，没有返回结果
     * @param name
     * @param lockAtMostLen
     * @param lockAtLeastLen
     * @param crontabFunction
     * @throws Exception
     */
    public static  void startCrontabTask(String name, long lockAtMostLen, long lockAtLeastLen, CrontabFunction crontabFunction) throws Exception{
        startTask(name,lockAtMostLen,lockAtLeastLen,crontabFunction,null,null,null,null);
    }

    /**有参数，没返回结果
     * @param name
     * @param lockAtMostLen
     * @param lockAtLeastLen
     * @param consumer
     * @param param
     * @param 
     * @throws Exception
     */
    public static <T>  void startConsumerTask(String name, long lockAtMostLen, long lockAtLeastLen, Consumer<T> consumer,T param) throws Exception{
        startTask(name,lockAtMostLen,lockAtLeastLen,null,param,consumer,null,null);
    }


    /**有参数，有返回
     * @param name
     * @param lockAtMostLen
     * @param lockAtLeastLen
     * @param function
     * @param param
     * @param 
     * @param 
     * @return
     * @throws Exception
     */
    public static <T,R> R  startFunctionTask(String name, long lockAtMostLen, long lockAtLeastLen, Function<T,R>  function,T param) throws Exception{
        return startTask(name,lockAtMostLen,lockAtLeastLen,null,param,null,null,function);
    }


    /**统一任务
     * @param name
     * @param lockAtMostLen
     * @param lockAtLeastLen
     * @param crontabFunction
     * @param param
     * @param consumer
     * @param supplier
     * @param function
     * @param 
     * @param 
     * @return
     * @throws Exception
     */
    public static  <T,R> R startTask(String name, long lockAtMostLen, long lockAtLeastLen, CrontabFunction crontabFunction, T param, Consumer<T> consumer, Supplier<R> supplier, Function<T, R> function) throws Exception{
        Instant now = Instant.now();
        long st = now.getEpochSecond()*1000;

        String lockAtMostUntilString = DateUtils.dateFormat(new Date(st+lockAtMostLen),DateUtils.DATE_TIME_PATTERN);
        String lockAtLeastUntilString = DateUtils.dateFormat(new Date(st+lockAtLeastLen),DateUtils.DATE_TIME_PATTERN);

        log.info("start task name={} lockAtMostUntil={} lockAtLeastUntil={}"+ name + ","+lockAtMostUntilString+","+lockAtLeastUntilString);
        LockProvider lockProvider = SpringBeanUtils.getBean(JdbcTemplateLockProvider.class);
        if(lockProvider == null){
            throw new NullPointerException("JdbcTemplateLockProvider is null");
        }
        LockConfiguration configuration = new LockConfiguration(name,now.plus(lockAtMostLen, MILLIS),now.plus(lockAtLeastLen, MILLIS));
        Optional<SimpleLock> optional =  lockProvider.lock(configuration);
        if(optional.isPresent()){
            log.info("get task lock success, task name={}"+name);
            try{
                if(supplier != null){
                    return supplier.get();
                }else if(function != null){
                    return function.apply(param);
                }else if(consumer != null){
                    consumer.accept(param);
                    return null;
                }else if(crontabFunction != null){
                    crontabFunction.runTask();
                    return null;
                }

            }finally {
                optional.get().unlock();
                long et = System.currentTimeMillis();
                log.info("task unlock, timeLen ={},task name={}"+ (et-st)+name);
            }
        }else{
            log.info("get task lock failure,task name={}"+name);
        }
        return null;
    }


}
