package project.common.bean;

import java.util.Arrays;

public class UriInfo {
	private String url;
	private String uri;
	private String[] uris;
	private String module;
	private String dataType;
	private String workType;
	private String command;
	private String params;
	private String ext;
	private DataMap param;
	
	public UriInfo(String url, String uri){
		try{
			this.url = url.substring(0, url.indexOf(uri));
			this.uri = uri;
			this.uris = uri.split("/");					
			this.command = uri.substring(uri.lastIndexOf("/")+1,uri.lastIndexOf("."));
			this.ext = uri.substring(uri.lastIndexOf(".")+1);			
			this.module = uris[1];
			this.dataType = uris[uris.length-2];
			this.workType = uris[uris.length-3];
		}catch(Exception e){}		
	}
	
	public String getMenuId() {
		return command.toUpperCase();
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getUri() {
		return uri;
	}

	public void setUri(String uri) {
		this.uri = uri;
	}

	public String[] getUris() {
		return uris;
	}

	public void setUris(String[] uris) {
		this.uris = uris;
	}

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

	public String getParams() {
		return params;
	}

	public void setParams(String params) {
		this.params = params;
	}

	public String getExt() {
		return ext;
	}

	public void setExt(String ext) {
		this.ext = ext;
	}

	public String getWorkType() {
		return workType;
	}

	public void setWorkType(String workType) {
		this.workType = workType;
	}
	
	public DataMap getParam() {
		return param;
	}

	public void setParam(DataMap param) {
		this.param = param;
	}

	@Override
	public String toString() {
		return "UriInfo [url=" + url + ", uri=" + uri + ", uris=" + Arrays.toString(uris) + ", module=" + module
				+ ", dataType=" + dataType + ", workType=" + workType + ", command=" + command + ", params=" + params
				+ ", ext=" + ext + ", param=" + param + "]";
	}
}