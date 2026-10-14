package project.common.task;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.service.CommonService;
import project.common.task.shedlock.JdbcLockService;
import project.mes.service.IFService;
import project.mes.service.IFServiceMapping;
import project.mes.service.MesService;

import javax.annotation.Resource;
import java.sql.SQLException;
import java.util.*;

@Service
public class InterfaceSchedule {

    private static Logger log = Logger.getLogger(InterfaceSchedule.class);
    @Autowired
    private IFService ifService;
    @Autowired
    private IFServiceMapping ifServiceMapping;
    @Autowired
    private CommonService commonService;
    @Autowired
    private CommonDAO commonDao;
    @Resource
    private InterfaceScheduleService interfaceScheduleService;
    @Resource
    private MesService mesService;

    private static final int SECOND= 1000;

    @Scheduled(cron = "0/30 * * * * *")
    // @Scheduled(fixedRate = 1000)
    public void batchSchedule() throws Exception {
        if(CommonConfig.isRealServer() || CommonConfig.isDevServer()) {
            JdbcLockService.startCrontabTask("MES_SCHEDULE",29*SECOND,29*SECOND,()-> {
                try {
                    batchScheduleAction();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            });
        }
    }

    public void batchScheduleAction() throws SQLException {
        Long curSeconds =System.currentTimeMillis()/1000L;
        Calendar cal = Calendar.getInstance();
        Date currentTime = cal.getTime();
        if (!commonService.isAccessScheduleIp()) return;
        List<DataMap> grpList = interfaceScheduleService.scheduleGroupListALL();
        if (grpList.size() == 0) return;
        for (DataMap grp : grpList) {
        	long start = System.currentTimeMillis();
            if (!interfaceScheduleService.isExecTimeNew(grp, curSeconds,currentTime)) continue;
            try {
                if (grpList.size() == 0) return;
                interfaceScheduleService.run(grp);
                long elapsed = System.currentTimeMillis() - start;
                log.info("[MES_SCHEDULE] 그룹 실행 요청 완료: "
                        + grp.getString("IF_GRP_NM")
                        + " (" + elapsed + "ms)");
            } catch (Exception e) {
                log.error("[MES_SCHEDULE] 그룹 실행 오류: "
                        + grp.getString("IF_GRP_NM"), e);
                e.printStackTrace();
            }
        }
        grpList.clear();
    }
}