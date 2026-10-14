package com.board.bean;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

import com.common.bean.DataMap;

public class CommonBoard {
	private static Logger log = Logger.getLogger(CommonBoard.class);
	
	private List boardList = new ArrayList();
	private DataMap boradMap = new DataMap();

	public List getBoardList() {
		return boardList;
	}

	public void setBoardList(List boardList) {
		this.boardList = boardList;
		for(int i=0;i<this.boardList.size();i++){
			DataMap row = (DataMap)this.boardList.get(i);
			this.setBoard(row);
		}
	}
	
	public void setBoard(DataMap map){
		boradMap.put(map.getString("ID"), map);
	}
	
	public DataMap getBoard(String id){
		return boradMap.getMap(id);
	}
}