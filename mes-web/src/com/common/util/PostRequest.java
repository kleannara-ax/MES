package com.common.util;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.StringReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.security.cert.X509Certificate;

import org.apache.log4j.Logger;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.common.bean.DataMap;

public class PostRequest {
	private static Logger log = Logger.getLogger(PostRequest.class);

	private String charset;

	public PostRequest() {
		this.charset = "UTF-8";
	}

	public PostRequest(String charset) {
		this.charset = charset;
	}
	
	public String excutePost(String targetURL, DataMap params) {
		StringBuilder sb = new StringBuilder();
		Iterator it = params.keySet().iterator();
		String key;
		while (it.hasNext()) {
			key = it.next().toString();
			if (sb.length() > 0) {
				sb.append("&");
			}
			sb.append(key).append("=").append(params.getString(key));
		}

		return excutePost(targetURL, sb.toString());
	}

	public String excutePost(String targetURL, String urlParameters) {
		HttpURLConnection connection = null;
		try {
			
			byte[] textByte = urlParameters.getBytes("UTF-8");
			
			// Create connection
			URL url = new URL(targetURL);
			connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("POST");
			connection.setRequestProperty("Content-Type", "application/json");
			connection.setRequestProperty("Accept-Charset", "UTF-8");
			//connection.setRequestProperty("Accept-Encoding", "identity");
			connection.setRequestProperty("Content-Length", Integer.toString(textByte.length));
			//connection.setRequestProperty("Content-Language", "en-US");

			connection.setUseCaches(false);
			connection.setDoInput(true);
			connection.setDoOutput(true);
			
			OutputStream out = connection.getOutputStream();
			out.write(textByte, 0, textByte.length);
			out.flush();
			out.close();
			
			// Send request
			/*
			DataOutputStream wr = new DataOutputStream(connection.getOutputStream());
			wr.writeBytes(urlParameters);
			wr.flush();
			wr.close();
			*/
			// Get Response
			InputStream is = connection.getInputStream();

			StringBuffer sb = new StringBuffer();
			String line = null;
			try {
				BufferedReader reader = new BufferedReader(new InputStreamReader(is));
				while ((line = reader.readLine()) != null) {
					sb.append(line);
				}
			} catch (Exception e) {
				log.error("Error reading JSON string", e);
			}
			return sb.toString();
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		} finally {
			if (connection != null) {
				connection.disconnect();
			}
		}
	}

	public DataMap jsonPost(String targetURL, Object params) {
		JSONObject jsonObject = new JSONObject(params);

		return jsonPost(targetURL, jsonObject);
	}

	public DataMap jsonPost(String targetURL, JSONObject jsonObject) {
		String jsonString = excutePost(targetURL, jsonObject.toString());

		JSONObject json;

		DataMap data = null;
		try {
			json = new JSONObject(jsonString);
			
			data = getMap(json);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

		return data;
	}
	
	public String excuteGet(String targetURL) {
		HttpURLConnection connection = null;
		try {
			// Create connection
			targetURL += "?x-Gateway-APIKey=dce00904-0547-4fd9-a9ed-f533ba45cdd7";
			URL url = new URL(targetURL);
			connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("GET");
			connection.setRequestProperty("Content-Type", "application/json");
			connection.setRequestProperty("Accept-Charset", charset);
			connection.setRequestProperty("x-Gateway-APIKey", "dce00904-0547-4fd9-a9ed-f533ba45cdd7");
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
			e.printStackTrace();
			return null;			
		} finally {
			if (connection != null) {
				connection.disconnect();
			}
		}
	}
	
	public DataMap jsonGet(String targetURL) {
		String jsonString = excuteGetHttps(targetURL);
		//log.info("jsonGet : "+targetURL+"\n"+jsonString);
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
	
	public String excuteGetHttps(String targetURL){
		HttpURLConnection connection = null;
		try {
			TrustManager[] trustAllCerts = new TrustManager[] { new X509TrustManager() {
	            public java.security.cert.X509Certificate[] getAcceptedIssuers() { return null; }
	            public void checkClientTrusted(X509Certificate[] certs, String authType) { }
	            public void checkServerTrusted(X509Certificate[] certs, String authType) { }
				@Override
				public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType)
						throws CertificateException {
					// TODO Auto-generated method stub
					
				}
				@Override
				public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType)
						throws CertificateException {
					// TODO Auto-generated method stub
					
				}

	        } };

	        SSLContext sc = SSLContext.getInstance("SSL");
	        sc.init(null, trustAllCerts, new java.security.SecureRandom());
	        HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());

	        // Create all-trusting host name verifier
	        HostnameVerifier allHostsValid = new HostnameVerifier() {
	            public boolean verify(String hostname, SSLSession session) { return true; }
	        };
	        // Install the all-trusting host verifier
	        HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
	        
			// Create connection
			//targetURL += "?x-Gateway-APIKey=dce00904-0547-4fd9-a9ed-f533ba45cdd7";
			URL url = new URL(targetURL);
			connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("GET");
			connection.setRequestProperty("Content-Type", "application/json");
			connection.setRequestProperty("Accept-Charset", charset);
			connection.setRequestProperty("x-Gateway-APIKey", "dce00904-0547-4fd9-a9ed-f533ba45cdd7");
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
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
			return null;
		} catch (KeyManagementException e) {
			e.printStackTrace();
			return null;
		} catch (IOException e) {
			e.printStackTrace();
			return null;			
		} finally {
			if (connection != null) {
				connection.disconnect();
			}
		}
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
			} catch (Exception e) {
				log.error("Error mapping JSON map", e);
			}
		}
		return paramMap;
	}
	
	public JSONObject getJSONObj(Map map) throws JSONException {
		DataMap paramMap = new DataMap();
		Set set = map.keySet();
		Iterator it = set.iterator();
		JSONObject json = new JSONObject();
		while (it.hasNext()) {
			String key = (String) it.next();
			json.put(key, map.get(key));
		}
		return json;
	}
	
	public JSONArray getJSONArray(List<DataMap> list) throws JSONException {
		JSONArray array = new JSONArray();
		for(int i=0;i<list.size();i++){
			array.put(getJSONObj(list.get(i)));
		}
		
		return array;
	}

	public Element xmlPost(String targetURL, DataMap params) throws JDOMException, IOException {
		String xmlStr = excutePost(targetURL, params);
		Element rootNode = null;
		if (xmlStr.length() > 0) {
			SAXBuilder builder = new SAXBuilder();
			StringReader sb = new StringReader(xmlStr);
			Document document = (Document) builder.build(sb);
			rootNode = document.getRootElement();
		}

		return rootNode;
	}

	public <T> T map2Bean(Map<String, Object> map, Class<T> clazz) throws InstantiationException, IllegalAccessException, IllegalArgumentException, InvocationTargetException {
		T t= null;
		t = clazz.newInstance();
		for (Entry<String, Object> entry : map.entrySet()) {
			String key = entry.getKey();
			Object value = entry.getValue();
			if (value == null) {
			    continue;
			}
			for (Method m : clazz.getDeclaredMethods()) {
				if (m.getName().equalsIgnoreCase("set" + key)) {
					m.invoke(t, value);
				}
			}
		}
		return t;
	}
	
	public <T> T map2Bean(JSONObject json, Class<T> clazz) throws InstantiationException, IllegalAccessException, IllegalArgumentException, InvocationTargetException, JSONException {
		T t= null;
		t = clazz.newInstance();
		Iterator<String> it = json.keys();
		while (it.hasNext()) {
			String key = it.next();
			Object value = json.get(key);
			if (value == null) {
			    continue;
			}
			for (Method m : clazz.getDeclaredMethods()) {
				if (m.getName().equalsIgnoreCase("set" + key)) {
					m.invoke(t, value);
				}
			}
		}
		return t;
	}
}