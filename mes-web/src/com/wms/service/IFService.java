package com.wms.service;

import java.sql.SQLException;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.common.bean.DataMap;
import com.common.bean.DataMap;
import com.wms.dao.IFDAO;

@Service
public class IFService {

	@Autowired
	public IFDAO dao;
	
	public List getList(DataMap map) throws SQLException {
		return dao.getList(map);
	}
	public List getList(String module, String command) throws SQLException {
		DataMap map = new DataMap(module, command);
		return dao.getList(map);
	}	
	public DataMap getMap(DataMap map) throws SQLException {
		return dao.getMap(map);
	}
	public Object getObj(DataMap map) throws SQLException {
		return dao.getObj(map);
	}
	public Object insert(DataMap map) throws SQLException {
		return dao.insert(map);
	}
	public int update(DataMap map) throws SQLException {
		return dao.update(map);
	}
	public int delete(DataMap map) throws SQLException {
		return dao.delete(map);
	}
	public String getListString(DataMap map) throws SQLException{
		return dao.getListString(map);
	}
}