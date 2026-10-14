package project.mes.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.simple.parser.JSONParser;
import org.json.simple.parser.ParseException;
import org.springframework.util.StringUtils;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.util.SqlUtil;
import project.mes.bean.DataMesMap;

import javax.servlet.http.HttpServletRequest;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.text.SimpleDateFormat;
import java.util.*;

public class CommonUtil {
    static final Logger log = LogManager.getLogger(CommonUtil.class.getName());

    public static String getMap(Map map, String key, String ifnull) {
        if (map == null) return null;
        if (map.get(key) == null) return ifnull;
        return String.valueOf(map.get(key));
    }

    public static String map2Json(Map map) {
        if (map == null) return "";
        JSONObject json = new JSONObject(map);
        return json.toString();
    }

    public static String getIp() {
        String result = null;
        try {
            result = InetAddress.getByName("local.server.ip").getHostAddress();
            // log.info(">>>>>> get host1 local.server.ip===="+result);
        } catch (Exception e) {
            //e.printStackTrace();
            try {
                result = InetAddress.getLocalHost().getHostAddress();
                // log.info(">>>>>> get host2 inet address ip ===="+result);
            } catch (UnknownHostException ex) {
                // log.error(">>>>>> get host3 ip exception ===="+ex.getMessage());
                ex.printStackTrace();
            }
        }
        return result;
    }

    public static DataMesMap convert(DataMap param, String paramKey) {
        if (param == null) return null;
        DataMesMap rsMap = new DataMesMap();
        for (Object keyObj : param.keySet()) {
            String key = (String) keyObj;
            DataMap params = null;
            SqlUtil sqlUtil = new SqlUtil();
            if (key.startsWith("{")) {
                for (String pk : paramKey.split(",")) {
                    if (CommonConfig.RNAGE_DATA_PARAM_KEY.equals(pk) && (key).indexOf(pk) != -1) {
                        try {
                            if (key != null && !key.equals("")) {
                                JSONObject jsonObject = new JSONObject(key);
                                params = getMap(jsonObject);
                                sqlUtil.setRangeSql(params);
                                System.out.println(params);
                                String sql = params.get(CommonConfig.RANGE_SQL_KEY).toString().replaceAll("\"", "\'");
//                        String sql = params.get(CommonConfig.RANGE_SQL_KEY).toString().replaceAll("\'","\''");
//                        String sql = sql.replaceAll("\"","\''");
                                rsMap.put(CommonConfig.RNAGE_DATA_PARAM_KEY, sql);
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    } else if (key.indexOf(pk) != -1) {
                        try {
                            JSONObject jsonObject = new JSONObject(key);
                            params = getMap(jsonObject);
                            rsMap.put(pk, params.get(pk));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
            } else {
                rsMap.put(key, param.get(key));
            }
        }
        return rsMap;
    }

    public static DataMesMap convertAll(DataMap param) {
        if (param == null) return null;
        DataMesMap rsMap = new DataMesMap();
        for (Object keyObj : param.keySet()) {
            String key = (String) keyObj;
            DataMap params = null;
            SqlUtil sqlUtil = new SqlUtil();
            if (key.startsWith("{")) {
                try {
                    JSONObject jsonObject = new JSONObject(key);
                    params = getMap(jsonObject);
                    for (Object pk : params.keySet()) {
                        if (CommonConfig.RNAGE_DATA_PARAM_KEY.equals(pk)) {
                            sqlUtil.setRangeSql(params);
                            System.out.println(params);
                            String sql = params.get(CommonConfig.RANGE_SQL_KEY).toString().replaceAll("\"", "\'");
                            rsMap.put(CommonConfig.RNAGE_DATA_PARAM_KEY, sql);
                        } else {
                            rsMap.put(pk, params.get(pk));
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            } else {
                rsMap.put(key, param.get(key));
            }
        }
        return rsMap;
    }


    public static String mapToJson(Map params) throws JsonProcessingException {
        ObjectMapper mapper = new ObjectMapper();
        String jsonStr = mapper.writeValueAsString(params);
        return jsonStr;
    }

    public static DataMap getMap(JSONObject json) {
        DataMap paramMap = new DataMap();
        Iterator it = json.keys();
        while (it.hasNext()) {
            String key = (String) it.next();
            if (json.isNull(key)) {
                continue;
            }
            try {
                Object obj = json.get(key);
                if (obj instanceof JSONObject) {
                    JSONObject jObject = (JSONObject) obj;
                    paramMap.put(key, getMap(jObject));
                } else if (obj instanceof ArrayList) {
                    paramMap.put(key, obj);
                } else if (obj instanceof JSONArray) {
                    JSONArray array = (JSONArray) obj;
                    List list = new ArrayList();
                    Object tmpObj;
                    for (int i = 0; i < array.length(); i++) {
                        tmpObj = array.get(i);
                        if (tmpObj instanceof JSONObject) {
                            list.add(getMap(array.getJSONObject(i)));
                        } else {
                            list.add(tmpObj);
                        }
                    }

                    paramMap.put(key, list);
                } else {
                    paramMap.put(key, obj);
                }
            } catch (Exception e) {
                log.error("Error mapping JSON map", e);
            }
        }
        return paramMap;
    }

    public static boolean processSuccess(DataMesMap map) {
        if (map.containsKey("P_SUCCESS") && "Y".equals(map.get("P_SUCCESS"))) return true;
        return false;
    }

    public static List<DataMap> processList(DataMap map, String key) {
        List<DataMap> list = new ArrayList<>();
        if (map.containsKey(key)) {
            list = (List<DataMap>) map.getList(key);
        }
        return list;
    }

    //public static List<DataMap> processList(DataMap map, String key) {
    //	  List<DataMap> list = new ArrayList<>();
    //	  if (map.containsKey(key)) {
    //		  List li = map.getList(key);
    //		  if(li !=null && li.size() > 0) {
    //			  for(Object o : li) {
    //				  DataMap m = new DataMap();
    //				  m.putAll((Map)o);
    //				  list.add(m);
    //			  }
    //		  }
    //	  }
    //	  return list;
    //}


    public static JSONObject getJsonNode(String strJson) throws ParseException, JSONException {
        JSONParser jsonParser = new JSONParser();

        Object obj = jsonParser.parse(strJson);
        if (obj == null) return null;
        JSONObject jsonObj = (JSONObject) obj;
        return jsonObj;
    }


    public static String getRequestBody(HttpServletRequest request) throws IOException {

        String body = null;
        StringBuilder stringBuilder = new StringBuilder();
        BufferedReader bufferedReader = null;

        try {
            InputStream inputStream = request.getInputStream();
            if (inputStream != null) {
                bufferedReader = new BufferedReader(new InputStreamReader(inputStream));
                char[] charBuffer = new char[128];
                int bytesRead = -1;
                while ((bytesRead = bufferedReader.read(charBuffer)) > 0) {
                    stringBuilder.append(charBuffer, 0, bytesRead);
                }
            }
        } catch (IOException ex) {
            throw ex;
        } finally {
            if (bufferedReader != null) {
                try {
                    bufferedReader.close();
                } catch (IOException ex) {
                    throw ex;
                }
            }
        }

        body = stringBuilder.toString();
        return body;
    }

    public static ObjectNode responseOK(Integer o) {
        ObjectNode node = new ObjectNode(null);
        node.put("returnCode", 0);
        node.put("returnDesc", "OK");
        return node;
    }

    public static ObjectNode responseError(int i, String message) {
        ObjectNode node = new ObjectNode(null);
        node.put("returnCode", 0);
        node.put("returnDesc", message);
        return node;
    }

    public static List<DataMap> converPageDataList(List<DataMap> list) {
        if(list!=null && list.size() > 0) {
           List<DataMap> newList = new ArrayList<>();
           for(DataMap info : list) {
              DataMap newInfo = new DataMap();
              newInfo.put("map", info);
              newList.add(newInfo);
           }
           return newList;
        }

        return list;
    }

    public static int getBigDecimallToInt(Object tarValue) {
        try {
            if (tarValue == null || "".equals(tarValue)) return 0;
            if (tarValue instanceof BigDecimal) {
                return ((BigDecimal) tarValue).intValue();
            } else if (tarValue instanceof String) {
                return Integer.parseInt(tarValue.toString());
            } else if (tarValue instanceof Integer) {
                return (int) tarValue;
            }
            return 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public static String getDate(String fmt) {
        if (StringUtils.isEmpty(fmt)) {
            fmt = "yyyyMMdd";
        }
        Date nowDate = new Date();
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat(fmt);
        String fmtDate = simpleDateFormat.format(nowDate);
        return fmtDate;
    }

    public static void main(String args[]) {
        String ip = getIp();
        System.out.println("=====" + ip+"====");

    }

    public static String getIpAddr(HttpServletRequest request) {

        String ip = request.getHeader("X-Forwarded-For");

        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {

            ip = request.getHeader("Proxy-Client-IP");

        }

        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {

            ip = request.getHeader("WL-Proxy-Client-IP");

        }

        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {

            ip = request.getHeader("HTTP_CLIENT_IP");

        }

        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {

            ip = request.getHeader("HTTP_X_FORWARDED_FOR");

        }

        if (ip == null || ip.length() == 0 || "unknown".equalsIgnoreCase(ip)) {

            ip = request.getRemoteAddr();

        }

        return ip;

    }
}
