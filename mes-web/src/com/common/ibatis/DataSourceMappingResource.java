package com.common.ibatis;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;

import org.springframework.core.io.Resource;

public class DataSourceMappingResource implements Resource {

	private String xml;
	
	private InputStream xmlStream;
	
	private long lastModified;
	
	private String desc;
	
	public DataSourceMappingResource(String xml, long lastModified, String desc) {
		this.xml = xml;
		this.lastModified = lastModified;
		this.desc = desc;
		this.xmlStream = new ByteArrayInputStream(xml.getBytes());
	}
	
	public InputStream getInputStream() throws IOException {
		return xmlStream;
	}

	public boolean exists() {
		return xmlStream != null;
	}

	public boolean isReadable() {
		return xmlStream != null;
	}

	public boolean isOpen() {
		return false;
	}

	public URL getURL() throws IOException {
		return null;
	}

	public URI getURI() throws IOException {
		return null;
	}

	public File getFile() throws IOException {
		return null;
	}

	public long contentLength() throws IOException {
		return xmlStream == null ? 0 : xmlStream.available();
	}

	public long lastModified() throws IOException {
		return lastModified;
	}

	public Resource createRelative(String relativePath) throws IOException {
		return null;
	}

	public String getFilename() {
		return null;
	}

	public String getDescription() {
		return desc;
	}

}
