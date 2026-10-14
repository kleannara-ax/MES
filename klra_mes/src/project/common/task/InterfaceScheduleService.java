package project.common.task;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.service.CommonService;
import project.mes.service.IFService;
import project.mes.service.IFServiceMapping;
import project.mes.service.MesService;

import javax.annotation.Resource;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

@Service
public class InterfaceScheduleService {
    private static Logger log = Logger.getLogger(InterfaceScheduleService.class);
    @Autowired
    private CommonDAO commonDao;

    @Autowired
    private IFService ifService;

    @Resource
    private IFServiceMapping ifServiceMapping;

    @Resource
    private CommonService commonService;

    @Resource
    private MesService mesService;

    public List<DataMap> scheduleGroupListALL() throws SQLException {
        DataMap param = new DataMap();
        param.setModuleCommand("Erpif", "IFGRPALL");
//        param.put("IF_GRP_CD", "");
        List<DataMap> list = commonDao.getList(param);
        if (list == null) list = new ArrayList<>();
        param.clear();
        return list;
    }

    @Async
    @Transactional(propagation = Propagation.NOT_SUPPORTED)
    public void run(DataMap grp) throws SQLException {
        long start = System.currentTimeMillis();

        String grpCd = grp.getString("IF_GRP_CD");
        String grpNm = grp.getString("IF_GRP_NM");

        log.info( "[MES_SCHEDULE][GROUP ASYNC START] grpCd=" + grpCd + ", grpNm= " + grpNm + ", thread= " + Thread.currentThread().getName());

        try {
            List<DataMap> list = this.selectScheduleGroupScheduleList(grp);
            if(list.size() == 0) return;
            updateGroupTime("R", grp);
            if("Y".equals(grp.getString("IF_ASYNC_YN"))) runList(list);
            else  synchronized (this){ runList(list);}
            list.clear();
        } finally {
            long elapsed = System.currentTimeMillis() - start;
            log.info( "[MES_SCHEDULE][GROUP ASYNC END] grpCd=" + grpCd + ", grpNm= " + grpNm  + ", elapsed= " + elapsed + ", thread= " + Thread.currentThread().getName());
        }
    }

    private void runList(List<DataMap> list) throws SQLException {
        for (DataMap m : list) {
            log.info("[MES_SCHEDULE][RFC 실행 시작] "
                    + "IFID=" + m.getString("IFID")
                    + ", RFCFN=" + m.getString("RFCFN")
            );

            if ((m.get("IFSTAT").equals("Y")) && !"R".equals(m.getString("FIN_CD"))) {
                String ifid = m.getString("IFID");

                long start = System.currentTimeMillis();
                log.info("[MES_SCHEDULE][IF START] IFID=" + m.getString("IFID")
                        + ", RFCFN=" + m.getString("RFCFN")
                );

                if (!ifServiceMapping.isPlantUseInParam(ifid)) runStart(m);
                else plantListRun(m);

                long end = System.currentTimeMillis();
                log.info("[MES_SCHEDULE] IFID = " + ifid + " 완료 (" + (end - start) + "ms)");

            } else {
                log.debug("[MES_SCHEDULE][IF_SKIP] "
                        + "IFID=" + m.getString("IFID")
                        + ", IFSTAT=" + m.getString("IFSTAT")
                        + ", FIN_CD=" + m.getString("FIN_CD"));
            }
        }
    }

    private void plantListRun(DataMap masterInfo) throws SQLException {
        masterInfo.setModuleCommand("mes", "PLANT");
        List<DataMap> plantList = commonService.getList(masterInfo);
        if(plantList.size() == 0 ) return ;
        for (DataMap pMap : plantList) {
        	String werks = pMap.getString("WERKS");
            if (!StringUtils.isEmpty(werks)) {
                masterInfo.put("WERKS", werks);
                runStart(masterInfo);
            }
        }
        plantList.clear();
    }

    private void runStart(DataMap masterInfo) throws SQLException {
    	long start = System.currentTimeMillis();
	    String ifid = masterInfo.getString("IFID");
	    String werks = masterInfo.getString("WERKS");

        mesService.updateMasterStatus(masterInfo, "R");
        masterInfo.put("FR","BATCH");
        // ifService.run_START1(masterInfo);
        ifService.run_START(masterInfo);

        long end = System.currentTimeMillis();
        log.info("[MES_SCHEDULE][IF END] IFID = " + ifid + ", WERKS=" + werks + ", 실행시간=" + (end - start) + "ms");

    }

    public void updateGroupTime(String RSTAT, DataMap grp) throws SQLException {
        DataMap dataMap = new DataMap();
        dataMap.setModuleCommand("Erpif", "ITFMAGRP");
        dataMap.put("IF_GRP_CD", grp.getString("IF_GRP_CD"));
        dataMap.put("type", RSTAT);
        commonDao.update(dataMap);
        dataMap.clear();
    }

    private List<DataMap> selectScheduleGroupScheduleList(DataMap grp) throws SQLException {
        DataMap map = new DataMap();
        map.setModuleCommand("Erpif", "IF");
        map.put("GRP_CD", grp.getString("IF_GRP_CD"));
        List<DataMap> batchList = commonDao.getList(map);
        if (batchList == null) batchList = new ArrayList<>();
        map.clear();
        return batchList;
    }

    public boolean isExecTime(DataMap grp, Date startTime) throws SQLException {
        boolean resultFlag = false;
        String currentTime = "";
        String execTime = grp.getString("POLLTM");
        String formatType = grp.getString("POLLTY");
        String formatTime = "";

        if (formatType.equals("HH")) {
            formatTime = "HH";
        } else if (formatType.equals("MI")) {
            formatTime = "mm";
        } else if (formatType.equals("SS")) {
            formatTime = "ss";
        } else {
            formatTime = "HHmm";
        }
        if (StringUtils.isEmpty(execTime.trim()) == false) {
            SimpleDateFormat sdf = new SimpleDateFormat(formatTime);
            currentTime = sdf.format(startTime);

            if (formatType.equals("HH")) {
                if ((Integer.valueOf(currentTime) % Integer.valueOf(execTime)) == 0) {
                    resultFlag = true;
                } else {
                    resultFlag = false;
                }
            } else if (formatType.equals("MI")) {
                if ((Integer.valueOf(currentTime) % Integer.valueOf(execTime)) == 0) {
                    resultFlag = true;
                } else {
                    resultFlag = false;
                }
            } else if (formatType.equals("SS")) {
                if ((Integer.valueOf(currentTime) % Integer.valueOf(execTime)) == 0) {
                    resultFlag = true;
                } else {
                    resultFlag = false;
                }
            } else {
                if (execTime.indexOf(currentTime) >= 0) {
                    resultFlag = true;
                } else {
                    resultFlag = false;
                }
            }
        }
        return resultFlag;
    }

    public boolean isExecTimeNew(DataMap grp, Long curSeconds,Date startTime) throws SQLException {
//        boolean isRunIng = this.isGroupRun(grp);
//        if (isRunIng) return false;
        String execTime = grp.getString("POLLTM").trim();
        String formatType = grp.getString("POLLTY").toUpperCase();
        if(formatType.equals("HHMI")) return this.isExecTime(grp,startTime);
        Long tarTime = Long.valueOf(execTime);
        if(formatType.equals("SS")) {
            return curSeconds % tarTime == 0;
        }
        if(formatType.equals("MI")) {
            return (curSeconds % (tarTime * 60)) == 0;
        }
        if(formatType.equals("HH")) {
            return (curSeconds % (tarTime * 3600)) == 0;
        }
        return false;
    }

    private boolean isGroupRun(DataMap grp) throws SQLException {
        DataMap dataMap = new DataMap();
        dataMap.setModuleCommand("Erpif", "ITFMAGRP");
        dataMap.put("IF_GRP_CD", grp.getString("IF_GRP_CD"));
        DataMap m = commonDao.getMap(dataMap);
        dataMap.clear();
        return m.getInt("CNT") > 0;
    }
}
