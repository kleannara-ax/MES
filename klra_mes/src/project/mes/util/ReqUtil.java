package project.mes.util;

import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import org.springframework.stereotype.Component;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

@Component
public class ReqUtil {
    public Map post(String strUrl, String jsonMessage){

        Map result = null;
        try {
            URL url = new URL(strUrl);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setConnectTimeout(5000); //서버에 연결되는 Timeout 시간 설정
            con.setReadTimeout(5000); // InputStream 읽어 오는 Timeout 시간 설정

            con.setRequestMethod("POST");

            //json으로 message를 전달하고자 할 때
            con.setRequestProperty("Content-Type", "application/json");
            con.setDoInput(true);
            con.setDoOutput(true); //POST 데이터를 OutputStream으로 넘겨 주겠다는 설정
            con.setUseCaches(false);
            con.setDefaultUseCaches(false);

            OutputStreamWriter wr = new OutputStreamWriter(con.getOutputStream());
            wr.write(jsonMessage); //json 형식의 message 전달
            wr.flush();

            StringBuilder sb = new StringBuilder();
            if (con.getResponseCode() == HttpURLConnection.HTTP_OK) {

                //Stream을 처리해줘야 하는 귀찮음이 있음.
                BufferedReader br = new BufferedReader(
                        new InputStreamReader(con.getInputStream(), "utf-8"));
                String line;
                while ((line = br.readLine()) != null) {
                    sb.append(line).append("\n");
                }
                br.close();


                result = new HashMap();

                String returnJson = sb.toString();

                // returnJson parsing
                JSONParser parser = new JSONParser();
                Object obj = parser.parse(returnJson);
                JSONObject jsonObj = (JSONObject) obj;
                System.out.println("## " +jsonObj.toJSONString());

                // head parsing
                Map headMap = (Map)jsonObj.get("head");
                String returnCode = Long.toString((Long)headMap.get("returnCode"));
                String returnDesc = (String)headMap.get("returnDesc");

                if (returnCode.equals("0")) {
                    // body parsing
                    Map bodyMap = (Map)jsonObj.get("body");

                    result.put("bodyMap", bodyMap);
                }

                result.put("headMap", headMap);

            } else {
                System.out.println(con.getResponseMessage());
            }
        } catch (Exception e){
            System.err.println(e.toString());
        }

        return result;

    }
}
