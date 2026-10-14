package project.common.util;

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
import java.net.MalformedURLException;
import java.net.URL;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.Security;
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

import project.common.bean.DataMap;

public class PostJsonRequest {
	protected final Logger log = Logger.getLogger(PostJsonRequest.class);
	private String charset;
	private int TIMEOUT_VALUE = 1000*60*10;
	private boolean secType = false;
	private String secKey = "ke2Yg6@24@F2bxhI";
	private String apiKey = "ke2Yg6@24@F2bxhI";

	public PostJsonRequest() {
		this.charset = "UTF-8";
	}

	public PostJsonRequest(String charset) {
		this.charset = charset;
	}
	
	public PostJsonRequest(boolean secType, String secKey) {
		this.charset = "UTF-8";
		this.secType = secType;
		this.secKey = secKey;
	}
	
	public static void main(String[] args) {
		// TODO Auto-generated method stub
		PostJsonRequest post = new PostJsonRequest();
		post.excutePost("http://127.0.0.1:8080/api/restful/order_list/20190921", "");
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
			connection.setRequestProperty("Content-Type", "application/json");
			connection.setRequestProperty("Accept-Charset", charset);
			// connection.setRequestProperty("Accept-Encoding", "identity");
			connection.setRequestProperty("Content-Length", Integer.toString(textByte.length));
			// connection.setRequestProperty("Content-Language", "en-US");
			connection.setRequestProperty("APIKEY", apiKey);

			connection.setUseCaches(false);
			connection.setDoInput(true);
			connection.setDoOutput(true);
			
			connection.setConnectTimeout(TIMEOUT_VALUE);

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
	
	public DataMap jsonPost(String targetURL, DataMap params) {
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
			return null;
		}

		return data;
	}
	
	public String excuteGet(String targetURL) {
		HttpURLConnection connection = null;
		try {
			// Create connection
			URL url = new URL(targetURL);
			connection = (HttpURLConnection) url.openConnection();
			connection.setRequestMethod("GET");
			connection.setRequestProperty("Content-Type", "application/json");
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
	
	public DataMap jsonGet(String targetURL) {
		String jsonString = excuteGet(targetURL);

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
	
	public String excuteHttpsPost(String targetURL, String urlParameters) {
		HttpsURLConnection connection = null;
		try {
			// Create a trust manager that does not validate certificate chains
	        TrustManager[] trustAllCerts = new TrustManager[] {new X509TrustManager() {
	                public java.security.cert.X509Certificate[] getAcceptedIssuers() {
	                    return null;
	                }
	                public void checkClientTrusted(X509Certificate[] certs, String authType) {
	                }
	                public void checkServerTrusted(X509Certificate[] certs, String authType) {
	                }
					@Override
					public void checkClientTrusted(java.security.cert.X509Certificate[] chain, String authType)
							throws java.security.cert.CertificateException {
						// TODO Auto-generated method stub
						
					}
					@Override
					public void checkServerTrusted(java.security.cert.X509Certificate[] chain, String authType)
							throws java.security.cert.CertificateException {
						// TODO Auto-generated method stub
						
					}
	            }
	        };
	 
	        // Install the all-trusting trust manager
	        SSLContext sc = SSLContext.getInstance("SSL");
	        sc.init(null, trustAllCerts, new java.security.SecureRandom());
	        HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
	 
	        // Create all-trusting host name verifier
	        HostnameVerifier allHostsValid = new HostnameVerifier() {
	            public boolean verify(String hostname, SSLSession session) {
	                return true;
	            }
	        };
	 
	        // Install the all-trusting host verifier
	        HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
	        
			// Create connection
			//targetURL += "?x-Gateway-APIKey=dce00904-0547-4fd9-a9ed-f533ba45cdd7";
			URL url = new URL(targetURL);
			connection = (HttpsURLConnection) url.openConnection();
			connection.setRequestMethod("POST");
			connection.setRequestProperty("Accept", "application/json");
			connection.setRequestProperty("Content-Type", "application/json");
			connection.setRequestProperty("Accept-Charset", charset);
			connection.setUseCaches(false);
			connection.setDoInput(true);
			connection.setDoOutput(true);
			connection.setConnectTimeout(TIMEOUT_VALUE);
			
			byte[] textByte = urlParameters.getBytes(charset);
			OutputStream out = connection.getOutputStream();
			out.write(textByte, 0, textByte.length);
			out.flush();
			out.close();
			
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
			} catch (JSONException e) {
				log.error("Error mapping JSON map", e);
			}
		}
		return paramMap;
	}

	public JSONObject getJSONObj(Map map) throws JSONException {
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
		for (int i = 0; i < list.size(); i++) {
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
		T t = null;
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
		T t = null;
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

	/*
	public void getHttpsConnection() {

		HttpsURLConnection conn = null;
		try {
			URL url = new URL("https://myurl/api/");

			conn = (HttpsURLConnection) url.openConnection();

			conn.setRequestMethod("POST");
			conn.setRequestProperty("User-Agent", "java-client");
			conn.setDoInput(true);
			conn.setDoOutput(true);
			conn.setUseCaches(false);
			conn.setHostnameVerifier(new HostnameVerifier() {

				@Override
				public boolean verify(String hostname, SSLSession session) {
					return true;
				}
			});

			// SSL setting
			SSLContext context = SSLContext.getInstance("TLS");
			context.init(null, new TrustManager[] { new javax.net.ssl.X509TrustManager() {

				@Override
				public X509Certificate[] getAcceptedIssuers() {
					return null;
				}

				@Override
				public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {
				}

				@Override
				public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {
				}
			} }, null);
			conn.setSSLSocketFactory(context.getSocketFactory());

			// Connect to host
			// conn.connect();
			// conn.setInstanceFollowRedirects(true);

			String param = "param=1234&param2=abcd";

			DataOutputStream wr = new DataOutputStream(conn.getOutputStream());
			wr.writeBytes(param);
			wr.flush();
			wr.close();

			// Print response from host
			InputStream in = conn.getInputStream();
			BufferedReader reader = new BufferedReader(new InputStreamReader(in));
			String line = null;
			while ((line = reader.readLine()) != null) {
				System.out.printf("%s\n", line);
			}

			reader.close();

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (conn != null) {
				conn.disconnect();
			}
		}

	}
	*/
	public Logger getLog() {
		return log;
	}
}