package project.common.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.apache.log4j.Logger;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import project.common.bean.DataMap;

public class PostParamRequest {
	protected final Logger log = Logger.getLogger(PostParamRequest.class);
	private String charset;

	public PostParamRequest() {
		this.charset = "UTF-8";
	}

	public PostParamRequest(String charset) {
		this.charset = charset;
	}

	public String excutePost(String targetURL, DataMap params) {
		StringBuilder sb = new StringBuilder();
		Iterator it = params.keySet().iterator();
		String key;
		while (it.hasNext()) {
			key = it.next().toString();
			if (sb.length() > 0) {
				sb.append('&');
			}
			sb.append(key).append('=').append(params.getString(key));
		}

		return excutePost(targetURL, sb.toString());
	}

	public String excutePost(String targetURL, String urlParameters) {
		HttpURLConnection connection = null;
		try {

			byte[] textByte = urlParameters.getBytes(charset);

			// Create connection
			URL url = new URL(targetURL);
			connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("POST");
			connection.setRequestProperty("Accept-Charset", charset);
			// connection.setRequestProperty("Accept-Encoding", "identity");
			connection.setRequestProperty("Content-Length", Integer.toString(textByte.length));
			// connection.setRequestProperty("Content-Language", "en-US");

			connection.setUseCaches(false);
			connection.setDoInput(true);
			connection.setDoOutput(true);

			OutputStream out = connection.getOutputStream();
			out.write(textByte, 0, textByte.length);
			out.flush();
			out.close();

			// Send request
			/*
			 * DataOutputStream wr = new
			 * DataOutputStream(connection.getOutputStream());
			 * wr.writeBytes(urlParameters); wr.flush(); wr.close();
			 */
			// Get Response
			InputStream is = connection.getInputStream();

			StringBuffer sb = new StringBuffer();
			String line = null;
			try {
				BufferedReader reader = new BufferedReader(new InputStreamReader(is));
				line = reader.readLine();
				while (line != null) {
					sb.append(line);
					line = reader.readLine();
				}
			} catch (IOException e) {
				log.error("Error reading JSON string", e);
			}
			return sb.toString();
		} catch (IOException e) {
			return null;
		} finally {
			if (connection != null) {
				connection.disconnect();
			}
		}
	}
	
	public String excuteGet(String targetURL) {
		HttpURLConnection connection = null;
		try {
			// Create connection
			URL url = new URL(targetURL);
			connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("GET");
			connection.setRequestProperty("Accept-Charset", charset);
			connection.setUseCaches(false);
			connection.setDoInput(true);
			connection.setDoOutput(true);

			// Send request
			/*
			 * DataOutputStream wr = new
			 * DataOutputStream(connection.getOutputStream());
			 * wr.writeBytes(urlParameters); wr.flush(); wr.close();
			 */
			// Get Response
			InputStream is = connection.getInputStream();

			StringBuffer sb = new StringBuffer();
			String line = null;
			try {
				BufferedReader reader = new BufferedReader(new InputStreamReader(is));
				line = reader.readLine();
				while (line != null) {
					sb.append(line);
					line = reader.readLine();
				}
			} catch (IOException e) {
				log.error("Error reading JSON string", e);
			}
			return sb.toString();
		} catch (IOException e) {
			return null;
		} finally {
			if (connection != null) {
				connection.disconnect();
			}
		}
	}
	
	public DataMap jsonPost(String targetURL, DataMap params) {
		String jsonString = excutePost(targetURL, params);
		if(jsonString == null) {
			return null;
		}
		
		jsonString = jsonString.replaceAll("\\\\", "");
		if(jsonString.charAt(0) == '[') {
			jsonString = "{'LIST' : "+jsonString+"}";
		}
		
		JSONObject json;

		DataMap data = null;
		try {
			json = new JSONObject(jsonString);

			data = getMap(json);

		} catch (JSONException e) {
			return null;
		}

		return data;
	}
	
	public DataMap jsonPostOld(String targetURL, DataMap params) {
		String jsonString = excutePost(targetURL, params);
		if(jsonString == null) {
			return null;
		}
		if(jsonString.charAt(0) != '{') {
			jsonString = jsonString.substring(1);
		}
		
		if(jsonString.charAt(jsonString.length()-1) != '}') {
			jsonString = jsonString.substring(0,jsonString.length()-1);
		}
		
		

		JSONObject json;

		DataMap data = null;
		try {
			json = new JSONObject(jsonString);

			data = getMap(json);
			
			if(jsonString.indexOf(",    {") != -1) {
				List list = new ArrayList();
				while(jsonString.indexOf(",    {") != -1) {
					jsonString = jsonString.substring(jsonString.indexOf(",    {")+1);
					JSONObject json2 = new JSONObject(jsonString.substring(jsonString.indexOf(",    {")+1));
					DataMap data2 = getMap(json2);
					list.add(data2);
				}				
				
				data.put("DATA", list);
			}
		} catch (JSONException e) {
			return null;
		}

		return data;
	}
	
	public DataMap getMap(JSONObject json) {
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
			} catch (JSONException e) {
				log.error("Error mapping JSON map", e);
			}
		}
		return paramMap;
	}
}