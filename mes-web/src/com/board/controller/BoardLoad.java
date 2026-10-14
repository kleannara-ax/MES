package com.board.controller;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.context.event.ContextRefreshedEvent;

import com.board.service.BoardService;

public class BoardLoad implements ApplicationListener {

	private static Logger log = Logger.getLogger(BoardLoad.class);
	@Autowired
	private BoardService boardService;

	public void onApplicationEvent(ApplicationEvent event){
		if(event instanceof ContextRefreshedEvent){
			try {
					boardService.loadBoard();
			} catch (Exception e) {
				// TODO Auto-generated catch block
				log.error("BoardLoad : ", e);
			}
		}
	}
}