package project.mes.service;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.mes.util.CommonUtil;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class IFServiceMapping {

    private static Logger log = Logger.getLogger(IFServiceMapping.class);
    @Autowired
    public CommonDAO commonDao;

    // sap param setting
    public void setCallSapParam(DataMap pMap, String ifid, String rfcp2,String werks) {
        // 플랜트 자재마스터
        if(ifid.equals("MES_IF_101")) {
        }
        // 생산마스터
        if(ifid.equals("MES_IF_102")) {
        }
        // 저장위치 마스터(공정창고내 저장위치 포함)
        if(ifid.equals("MES_IF_103")) {
            pMap.put("I_IF_NAM",pMap.get("I_IF_ID"));
            pMap.remove("I_IF_ID");
        }
        // 자재별 단위 환산 마스터
        if(ifid.equals("MES_IF_105")) {
            pMap.put("I_IF_NAM",pMap.get("I_IF_ID"));
            pMap.remove("I_IF_ID");
        }
        // 플랜트 생산 마스터
        if(ifid.equals("MES_IF_106")) {
        }
        // 생산법전
        if(ifid.equals("MES_IF_107")) {
        }
        if(ifid.equals("MES_IF_110")) {
        }
        // 거래처(고객사) 마스터
        if(ifid.equals("MES_IF_111")) {
            pMap.put("I_IF_NAM",pMap.get("I_IF_ID"));
            pMap.remove("I_IF_ID");
            pMap.put("I_PARVW","WE");
        }
        if(ifid.equals("MES_IF_112")) {
            pMap.put("I_IF_NAM",pMap.get("I_IF_ID"));
            pMap.remove("I_IF_ID");
        }
        if(ifid.equals("MES_IF_113")) {
        }
        if(ifid.equals("MES_IF_114")) {
            String now =  CommonUtil.getDate(null);
            pMap.put("I_FDATE",now);
        }
        // order
        if(this.isPlantUseInParam(ifid)) {
            pMap.put("I_WERKS", werks);
        }
    }

    // 파렛트 foreach 여부, BOM,생산오더예외가 사용
    public boolean isPlantUseInParam(String ifid) {
    	if(ifid.equals("MES_IF_907"))	return false;
        String plantUseYn = this.geIFMasterValue(ifid, "PLANTYN");
        return "Y".equals(plantUseYn);
    }

    //
    public String geIFMasterValue(String ifId, String key) {
        try {
        	if(ifId.equals("MES_IF_907")) {
        		return "Y";
        	}
            DataMap map = new DataMap();
            map.setModuleCommand("Erpif", "IFMA");
            map.put("IFID",ifId);
            DataMap rsMap = commonDao.getMap(map);
            map.clear();
            return rsMap.getString(key);
        }catch (SQLException e) {
            return "";
        }
    }

    public static Map<String, Object> getMapFromJsonObject(JSONObject jsonObject) {
        Map<String, Object> map = null;
        try {
            map = new ObjectMapper().readValue(jsonObject.toJSONString(), Map.class);
        } catch (JsonParseException e) {
            e.printStackTrace();
        } catch (JsonMappingException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return map;
    }

    public DataMap geIFMasterValue(String ifId) throws SQLException {
        DataMap map = new DataMap();
        map.setModuleCommand("Erpif","IFMA");
        map.put("IFID",ifId);
        DataMap rsMap = commonDao.getMap(map);
        map.clear();
        return rsMap;
    }

public void mapingField(String ifid, List<DataMap> sendList, JSONArray jarr) throws SQLException {
        DataMap dataMap = new DataMap();
        dataMap.setModuleCommand("Erpif", "FLDMAP");
        dataMap.put("IFID", ifid);
        List<DataMap> list = commonDao.getList(dataMap);
        JSONObject jobj;
        dataMap.clear();
        
        for(HashMap sendMap: sendList) {
            DataMap sendMap1 = new DataMap();
            sendMap1.putAll(sendMap);
            jobj = new JSONObject();
            for(DataMap li: list){
                String tarfld = li.getString("TARFLD");
                String mesfld = li.getString("MESFLD");
                String dfval = li.getString("DFVAL");
                if("MES".equals(li.getString("SYSFR"))) {
                    String tarValue = "";
                    int slen = li.getInt("SLEN");
                    if(jobj.get(tarfld)!=null) {
                        tarValue = String.valueOf(jobj.get(tarfld));
                    }
                    if(sendMap1.getString(mesfld).length() <= slen) slen = sendMap1.getString(mesfld).length();
                    if(slen > 0) {
                        tarValue+= sendMap1.getString(mesfld).substring(0,slen);
                    }else {
                        if(StringUtils.isBlank(dfval)) {
                            tarValue+= sendMap1.getString(mesfld);
                        }else {
                            tarValue+= dfval;
                        }
                    }
                    jobj.put(tarfld,tarValue);
                }
                else {
                }
            }
            sendMap1.clear();
            list.clear();
            jarr.add(jobj);
        }
    }

    public List<DataMap> setSapSendField(String ifid, List<DataMap> sendList) throws SQLException {

        DataMap dataMap = new DataMap();
        dataMap.setModuleCommand("Erpif", "FLDMAP");
        dataMap.put("IFID", ifid);
        List<DataMap> list = commonDao.getList(dataMap);
        DataMap jobj;

        List<DataMap> rtnList = new ArrayList<>() ;

        for(HashMap sendMap: sendList) {
            jobj = new DataMap();
            for(HashMap lis: list){
                DataMap li = new DataMap();
                li.putAll(lis);
                String tarfld = li.getString("TARFLD");
                String mesfld = li.getString("MESFLD");
                if("MES".equals(li.getString("SYSFR")) || ifid.equals("WCS_IF_860")) { // 송신
                    Object obj = sendMap.get(mesfld);
                    jobj.put(tarfld,obj);
                    if("Y".equals(li.getString("BIGDECYN"))) {
                        jobj.put(tarfld, CommonUtil.getBigDecimallToInt(obj));
                    }
                }
                else {
                }
            }
            rtnList.add(jobj);
        }
        list.clear();
        dataMap.clear();
        return rtnList;
    }

    // sap에 여러개 DOC_NO를 보낼수 없다고 해서 그룹으로 나누어서 보냄
    public Map groupByList(List<DataMap> newList) {
        Map<String,List<DataMap>> rtnMap = new HashMap();
        for(DataMap m: newList) {
            String docNo = m.getString("MDOCNO");
            if( rtnMap.get(docNo) != null ) {
                ArrayList<DataMap> list = (ArrayList<DataMap>) rtnMap.get(docNo);
                list.add(m);
                rtnMap.put(docNo, list);
            }else {
                ArrayList<DataMap> list = new ArrayList<>();
                list.add(m);
                rtnMap.put(docNo, list);
            }
        }
        return rtnMap;
    }

    // sap 받은 에러가 묶음으로 와서 interface테이블에 넣어줌, 정상적으로 오면 for 돌려서 프로시저로 넣어주게 되어 있음)
    public void updateSapErrorCallBackMessage(String ifTbl, String mDocNo, String messge,String logseqno) {
        try {
            if(!(StringUtils.isNotEmpty(ifTbl) && StringUtils.isNotEmpty(mDocNo) && StringUtils.isNotEmpty(mDocNo))) return;
            DataMap d  = new DataMap();
            d.setModuleCommand("Erpif", "SAPMSG");
            d.put("TBL", ifTbl);
            d.put("MDOCNO", mDocNo);
            d.put("MSG",messge);
            d.put("IF_MES_KEY",logseqno);
            commonDao.update(d);
            d.clear();
        }catch (Exception e) {
            log.error(e.getMessage());
        }
    }
}
