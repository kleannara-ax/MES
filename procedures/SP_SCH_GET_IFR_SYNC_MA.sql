
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH_GET_IFR_SYNC_MA" 
AS                                                                                     
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : 생산오더의 데이타 수신후 누락된부분 각 I/F테이블과 동기화 한다.
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산오더 밀롤->작업지시 동기화
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/10/05
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/10/05  1.0.0   강현주         Initial Version 
 *==============================================================================
 * 관련 테이블
 * - [XXX] : (.I..)데이타 생성  
--------------------------------------------------------------------------------------------------------------------------------   
--화장지 합지 : AA
--화장지 가공 : RA
--생리대     : RB
--기저귀     : RC
--
--점보롤 : JA
--밀롤 : MA
--재단 : CA
--포장 : PA
--예외생산: EX    
 *=============================================================================*/
 
  o_msg_code         VARCHAR2(1000)   := '';
  o_msg_MSG          VARCHAR2(4000)   := '';
   
 
  E_EXCEPTION_USER  EXCEPTION;                        -- 사용자 에러 처리용 변수선언 영역 
  
  --오더별 마지막 IF_MES_KEY를 잡아와서 처리 한다.
  CURSOR  CUR_DATA IS 
    SELECT INFO.*
    FROM (
          SELECT K.AUFNR,(SELECT MAX(IF_MES_KEY) FROM TB_IFR019 WHERE AUFNR = K.AUFNR) IF_MES_KEY  
          FROM (SELECT DISTINCT AUFNR 
                FROM TB_IFR019) K      
          WHERE K.AUFNR NOT IN(SELECT ORDER_NO FROM TB_SCH016 WHERE ORDER_NO = K.AUFNR)
         ) DATA
        ,TB_IFR019 INFO
    WHERE  DATA.AUFNR       = INFO.AUFNR
    AND    DATA.IF_MES_KEY  = INFO.IF_MES_KEY 
    AND    INFO.IF_STATUS IN('N','E')
    ORDER BY IF_IFR_NO;
 

  
  
  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..) 

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG   
         
  V_DLFL_CNT      NUMBER          := 0;      -- 생산오더 모두 삭제 되었으면 작업지시 삭제 하기 위해서 사용함. 
  
  i_IF_IFR_NO     NUMBER          := 0;      -- MES Interface Sequence(수신번호)   
  i_AUFNR         VARCHAR2(50)    := '';  

BEGIN
  
  FOR cur_row in CUR_DATA LOOP
  BEGIN
    i_IF_IFR_NO := cur_row.IF_IFR_NO;
    i_AUFNR     := cur_row.AUFNR;
  
    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR019
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH007
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH016
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  := 'SP_SCH_SYNC_MA==>완료==>'|| i_AUFNR  ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');      
           
      UPDATE  TB_IFR019
      SET     IF_STATUS   =  'S'                                                    -- I/F상태, N:신규, S:성공, E:오류
            , IF_SET_DATE =  sysdate            
            , IF_ERR_MESS =  o_msg_MSG          
      WHERE IF_IFR_NO =  i_IF_IFR_NO;

      o_msg_MSG  := 'SP_SCH_SYNC_MA==>완료==>'|| i_AUFNR  ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
      o_msg_code := '0' ;
                                      
      DBMS_OUTPUT.PUT_LINE(o_msg_MSG);
      SP_IF_MIG_LOG('SP_SCH_SYNC_MA','0',o_msg_MSG);
      COMMIT;      
                        
      CONTINUE;  
    END IF;
    
    
  -----------------------------------------------------------------------------------------------------------------------------
  --생산오더
  -----------------------------------------------------------------------------------------------------------------------------
    SELECT COUNT(1) INTO V_CNT FROM TB_SCH007 WHERE AUFNR = i_AUFNR;   
  
    IF V_CNT > 0 THEN    
      UPDATE TB_SCH007
      SET(
         JRPO			     								--오더 번호			                               	
        ,WERKS			     							--플랜트			                               	
        ,ORDER_NUM			 							--생산지시 No			                           	
        ,ORDER_SEQ			 							--생산지시 seq			                         	
        ,BUDAT			     							--시작일자			                               	
        ,AUART			     							--오더유형			                               	
        ,AUARTXT			   							--오더유형 텍스트			                                 	
        ,MMATNR			   								--밀롤 자재 코드			                               	
        ,MACHINE        							--FROM 생산호기                                	     
        ,MACHINETXT     							--FROM 생산 호기명                                	      
        ,TOMACHINE      							--TO 생산호기                                  	 
        ,TOMACHINETXT   							--TO 생산 호기명                                  	  
        ,MATNR			     							--점보롤 자재 코드			                                 	
        ,PCODE			     							--지종코드			                               	
        ,WEIGHT			   								--평량			                             	
        ,MWIDTH			   								--M/R 지폭			                         	
        ,MWIDTH_INPUT									--M/R 지폭_INPUT			                       	
        ,MWIDTH_SLITER	 							--M/R 지폭_SLITER			                 	
        ,MROLLCNT			 								--M/R 권치수			                         	
        ,MRCNT			     							--M/R 폭수			                         	
        ,MBRGEW			   								--M/R 중량			                         	
        ,MGEWEI			   								--단위			                             	
        ,JRCNT			     							--J/R 개수			                         	
        ,OVBELN			   								--판매 문서			                               	
        ,OPOSNR			   								--판매 문서 품목 번호			                                 	
        ,OAUART			   								--판매 문서 오더 유형			                                 	
        ,OAUARTXT			 								--판매 문서 오더 유형 텍스트			                                	   
        ,VBELN			     							--판매 문서			                               	
        ,POSNR			     							--판매 문서 품목 번호			                                 	
        ,VDATU			     							--납품 요청일자			                                 	
        ,SAUART			   								--판매 문서 오더 유형			                                 	
        ,SAUARTXT			 								--판매 문서 오더 유형 텍스트			                                	    
        ,REMARK			   								   --비고			                             	
        ,SHEET			     							--판지 구분자			                               	
        ,SLITER_SET										--슬리터 구분			                                 	
        ,MRLDCK			   								--밀롤 창고 적치 여부			                                 	 
        ,CUTTER			   								--카터			                             	
        ,STLNR			     							--BOM Num			                     	
        ,STLAL			     							--대체Bom			                           	
        ,BMENG			     							--모품목기준수량			                                   	
        ,BMEIN			     							--모품목기준수량 단위			                                   	  
        ,ROUTE          							--항차                                   	    
        ,DLFL			     								--오더 삭제 지시자			                                 	  
        ,KUNNR          							--판매처                                    	
        ,KUNNRT         							--판매처명                                     	
                                                                          
        ,UPDDATE        							--수정일자                                     	                
        ,UPDID          							--수정자                              	                                                              
      )=(SELECT                         										
         JRPO			      							--오더 번호			                   
        ,WERKS			                  --플랜트			                     
        ,ORDER_NUM			              --생산지시 No			                 
        ,ORDER_SEQ			              --생산지시 seq			               
        ,BUDAT			                  --시작일자			                   
        ,AUART			                  --오더유형			                   
        ,AUARTXT			                --오더유형 텍스트			               
        ,MMATNR			                  --밀롤 자재 코드			               
        ,MACHINE                      --FROM 생산호기                    
        ,MACHINETXT                   --FROM 생산 호기명                  
        ,TOMACHINE                    --TO 생산호기                      
        ,TOMACHINETXT                 --TO 생산 호기명                    
        ,MATNR			                  --점보롤 자재 코드			               
        ,PCODE			                  --지종코드			                   
        ,WEIGHT			                  --평량			                     
        ,MWIDTH			                  --M/R 지폭			                 
        ,MWIDTH_INPUT		              --M/R 지폭_INPUT			           
        ,MWIDTH_SLITER	              --M/R 지폭_SLITER			           
        ,MROLLCNT			                --M/R 권치수			                 
        ,MRCNT			                  --M/R 폭수			                 
        ,MBRGEW			                  --M/R 중량			                 
        ,MGEWEI			                  --단위			                     
        ,JRCNT			                  --J/R 개수			                 
        ,OVBELN			                  --판매 문서			                   
        ,OPOSNR			                  --판매 문서 품목 번호			             
        ,OAUART			                  --판매 문서 오더 유형			             
        ,OAUARTXT			                --판매 문서 오더 유형 텍스트			         
        ,VBELN			                  --판매 문서			                   
        ,POSNR			                  --판매 문서 품목 번호			             
        ,VDATU			                  --납품 요청일자			                 
        ,SAUART			                  --판매 문서 오더 유형			             
        ,SAUARTXT			                --판매 문서 오더 유형 텍스트			         
        ,REMARK			                                    --비고			                     
        ,SHEET			                  --판지 구분자			                 
        ,SLITER_SET			              --슬리터 구분			                 
        ,MRLDCK			                  --밀롤 창고 적치 여부			             
        ,CUTTER			                  --카터			                     
        ,STLNR			                  --BOM Num			                 
        ,STLAL			                  --대체Bom			                   
        ,BMENG			                  --모품목기준수량			                 
        ,BMEIN			                  --모품목기준수량 단위			             
        ,ROUTE                        --항차                           
        ,DLFL			                    --오더 삭제 지시자			               
        ,KUNNR                        --판매처                          
        ,NAME1                        --판매처명                         
                                                                     
        ,sysdate                      --수정일자                         
        ,'SP_SCH_SYNC_MA'               --수정자                                                                                    
         FROM TB_IFR019 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE  AUFNR   = i_AUFNR;       
    ELSE    
      INSERT INTO TB_SCH007(  
         AUFNR							          --오더번호			                                                                                                                                                                   
        ,JRPO							            --점보롤 오더 번호			                                                                                                                                                
        ,WERKS							          --플랜트			                                                                                                                                                 
        ,ORDER_NUM							      --생산지시 No			                                                                                                                                              
        ,ORDER_SEQ							      --생산지시 seq			                                                                                                                                            
        ,BUDAT							          --시작일자			                                                                                                                                                
        ,AUART							          --오더유형			                                                                                                                                                
        ,AUARTXT							        --오더유형 텍스트			                                                                                                                                              
        ,MMATNR							          --밀롤 자재 코드			                                                                                                                                              
        ,MACHINE                      --FROM 생산호기                                                                                                                                                 
        ,MACHINETXT                   --FROM 생산 호기명                                                                                                                                                
        ,TOMACHINE                    --TO 생산호기                                                                                                                                                   
        ,TOMACHINETXT                 --TO 생산호기명                                                                                                                                                   
        ,MATNR							          --점보롤 자재 코드			                                                                                                                                                
        ,PCODE							          --지종코드			                                                                                                                                                
        ,WEIGHT							          --평량			                                                                                                                                                
        ,MWIDTH							          --M/R 지폭			                                                                                                                                            
        ,MWIDTH_INPUT							    --M/R 지폭_INPUT			                                                                                                                                      
        ,MWIDTH_SLITER							  --M/R 지폭_SLITER			                                                                                                                                      
        ,MROLLCNT							        --M/R 권치수			                                                                                                                                             
        ,MRCNT							          --M/R 폭수			                                                                                                                                            
        ,MBRGEW							          --M/R 중량			                                                                                                                                            
        ,MGEWEI							          --단위			                                                                                                                                                
        ,JRCNT							          --J/R 개수			                                                                                                                                            
        ,OVBELN							          --판매 문서			                                                                                                                                                
        ,OPOSNR							          --판매 문서 품목 번호			                                                                                                                                             
        ,OAUART							          --판매 문서 오더 유형			                                                                                                                                             
        ,OAUARTXT							        --판매 문서 오더 유형 텍스트			                                                                                                                                           
        ,VBELN							          --판매 문서			                                                                                                                                                
        ,POSNR							          --판매 문서 품목 번호			                                                                                                                                             
        ,VDATU							          --납품 요청일자			                                                                                                                                                
        ,SAUART							          --판매 문서 오더 유형			                                                                                                                                             
        ,SAUARTXT							        --판매 문서 오더 유형 텍스트			                                                                                                                                           
        ,REMARK							                              --비고			                                                                                                                            
        ,SHEET							          --판지 구분자			                                                                                                                                              
        ,SLITER_SET							      --슬리터 구분			                                                                                                                                              
        ,MRLDCK							          --밀롤 창고 적치 여부			                                                                                                                                             
        ,CUTTER							          --카터			                                                                                                                                                
        ,STLNR							          --BOM Num			                                                                                                                                          
        ,STLAL							          --대체Bom			                                                                                                                                              
        ,BMENG							          --모품목기준수량			                                                                                                                                                
        ,BMEIN							          --모품목기준수량 단위			                                                                                                                                             
        ,ROUTE                        --항차                                                                                                                                                      
        ,DLFL							            --오더 삭제 지시자			                                                                                                                                                
        ,KUNNR                        --판매처                                                                                                                                                      
        ,KUNNRT                       --판매처명                                                                                                                                                      
        ,SLITER                       --슬리터구분                                                                                                                                                      
        ,FRAUFNR                      --이전오더                                                                                                                                                      
                                                                                                                                                                                              
        ,REGDATE                      --등록일자                                                                                                                                                             
        ,REGID                        --등록자                                                                                                                                                             
        ,UPDDATE                      --수정일자                                                                                                                                                             
        ,UPDID                        --수정자                                                                                                		                   		                  
      )                                           					                              
      SELECT                                      					                              
         AUFNR				         				--오더번호			                                                                                       
        ,JRPO				                  --점보롤 오더 번호			                                                                
        ,WERKS				                --플랜트			                                                                      
        ,ORDER_NUM				            --생산지시 No			                                                                  
        ,ORDER_SEQ				            --생산지시 seq			                                                                
        ,BUDAT				                --시작일자			                                                                    
        ,AUART				                --오더유형			                                                                    
        ,AUARTXT				              --오더유형 텍스트			                                                                
        ,MMATNR				                --밀롤 자재 코드			                                                                
        ,MACHINE                      --FROM 생산호기                                                                     
        ,MACHINETXT                   --FROM 생산 호기명                                                                   
        ,TOMACHINE                    --TO 생산호기                                                                       
        ,TOMACHINETXT			            --TO 생산호기명                                                                      
        ,MATNR				                --점보롤 자재 코드			                                                                
        ,PCODE				                --지종코드			                                                                    
        ,WEIGHT				                --평량			                                                                      
        ,MWIDTH				                --M/R 지폭			                                                                  
        ,MWIDTH_INPUT				          --M/R 지폭_INPUT			                                                            
        ,MWIDTH_SLITER				        --M/R 지폭_SLITER			                                                            
        ,MROLLCNT				              --M/R 권치수			                                                                  
        ,MRCNT				                --M/R 폭수			                                                                  
        ,MBRGEW				                --M/R 중량			                                                                  
        ,MGEWEI				                --단위			                                                                      
        ,JRCNT				                --J/R 개수			                                                                  
        ,OVBELN				                --판매 문서			                                                                    
        ,OPOSNR				                --판매 문서 품목 번호			                                                              
        ,OAUART				                --판매 문서 오더 유형			                                                              
        ,OAUARTXT				              --판매 문서 오더 유형 텍스트			                                                          
        ,VBELN				                --판매 문서			                                                                    
        ,POSNR				                --판매 문서 품목 번호			                                                              
        ,VDATU				                --납품 요청일자			                                                                  
        ,SAUART				                --판매 문서 오더 유형			                                                              
        ,SAUARTXT				              --판매 문서 오더 유형 텍스트			                                                          
        ,REMARK				                                          --비고			                                                                      
        ,SHEET				                --판지 구분자			                                                                  
        ,SLITER_SET				            --슬리터 구분			                                                                  
        ,MRLDCK				                --밀롤 창고 적치 여부			                                                              
        ,CUTTER				                --카터			                                                                      
        ,STLNR				                --BOM Num			                                                                  
        ,STLAL				                --대체Bom			                                                                    
        ,BMENG				                --모품목기준수량			                                                                  
        ,BMEIN				                --모품목기준수량 단위			                                                              
        ,ROUTE                        --항차                                                                            
        ,DLFL				                  --오더 삭제 지시자			                                                                
        ,KUNNR                        --판매처                                                                           
        ,NAME1                        --판매처명                                                                          
        ,SLITER                       --슬리터구분                                                                         
        ,FRAUFNR                      --이전오더                                                                          
                                                                                                                      
        ,sysdate                      --등록일자                                                                                 
        ,'SP_SCH_SYNC_MA'               --등록자                                                                                  
        ,null                         --수정일자                                                                                 
        ,null                         --수정자                                                                                                                                        
      FROM  TB_IFR019
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;    
  


    --========================================         
    --KHJ추가 2022-05-01:작업지시-밀롤
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH016
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR019
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOMA',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    IF V_CNT > 0 THEN    
      UPDATE TB_SCH016
      SET(        
         PRE_ORDER_NO         									--이전 오더 번호       
        ,WERKS                									--플랜트코드          
        ,ORDER_NUM            									--생산지시 No        
        ,ORDER_SEQ            									--생산지시 seq       
        ,PRD_REQ_DT           									--생산요청일자         
        ,ORDER_DIV            									--오더유형           
        ,ORDER_DIV_NM         									--오더유형 텍스트       
        ,MATNR                									--자재 코드          
        ,MACHINE              									--생산호기           
        ,MACHINE_NM           									--생산 호기명         
        ,TO_MACHINE           									--TO 생산호기        
        ,TO_MACHINE_NM        									--TO 생산 호기명      
        ,JMATNR               									--점보롤 자재 코드      
        ,PCODE                									--지종코드           
        ,BS_WGT               									--평량             
        ,MWIDTH               									--M/R 지폭         
        ,MWIDTH_INPUT         									--M/R 지폭_INPUT   
        ,MWIDTH_SLITER        									--M/R 지폭_SLITER  
        ,MROLLCNT             									--M/R 권치수        
        ,MRCNT                									--M/R 폭수         
        ,MBRGEW               									--M/R 중량         
        ,UNIT                 									--단위             
        ,JRCNT                									--J/R 개수         
        ,OVBELN               									--판매문서           
        ,OPOSNR               									--판매문서 항목번호      
        ,OAUART_DIV           									--판매문서 유형        
        ,OAUART_NM            									--판매 문서 오더 유형 텍스트
        ,VBELN                									--판매문서           
        ,POSNR                									--판매문서 항목번호      
        ,VDATU                									--납품 요청일자        
        ,SAUART_DIV           									--판매문서 유형        
        ,SAUART_NM            									--판매 문서 오더 유형 텍스트
        ,ORDER_RMK            									--비고(22-06-08:REMARK->ORDER_RMK로 변경함)             
        ,SHEET                									--판지 구분자         
        ,SLITER_SET           									--슬리터 구분         
        ,MRLDCK               									--밀롤 창고 적치 여부    
        ,CUTTER               									--카터             
        ,ATN_BOM_NO           									--대체Bom          
        ,BOM_NO               									--BOM Num        
        ,PRT_MATNR_QTY        									--모품목기준수량        
        ,PRT_MATNR_UNIT       									--모품목기준수량 단위     
        ,DLFL                 									--오더 삭제 지시자  
        ,ROUTE                									--항차 
        ,KUNNR                									--판매처 
        ,KUNNRT               									--판매처명	
        ,SLITER               									--슬리터구분		 					 					  
                                                
        ,UPDDATE              									--수정일시
        ,UPDID                									--수정자ID
        ,USE_YN               									--사용여부(Y:사용 N:미사용)	                       
      )=(SELECT                         										
         FRAUFNR                        				--이전 오더 번호       
        ,WERKS                          				--플랜트코드          
        ,ORDER_NUM                      				--생산지시 No        
        ,ORDER_SEQ                      				--생산지시 seq       
        ,BUDAT                          				--생산요청일자         
        ,AUART                          				--오더유형           
        ,AUARTXT                        				--오더유형 텍스트       
        ,MMATNR                         				--자재 코드          
        ,MACHINE                        				--생산호기           
        ,MACHINETXT                     				--생산 호기명         
        ,TOMACHINE                      				--TO 생산호기        
        ,TOMACHINETXT                   				--TO 생산 호기명      
        ,MATNR                          				--점보롤 자재 코드      
        ,PCODE                          				--지종코드           
        ,WEIGHT                         				--평량             
        ,MWIDTH                         				--M/R 지폭         
        ,MWIDTH_INPUT                   				--M/R 지폭_INPUT   
        ,MWIDTH_SLITER                  				--M/R 지폭_SLITER  
        ,MROLLCNT                       				--M/R 권치수        
        ,MRCNT                          				--M/R 폭수         
        ,MBRGEW                         				--M/R 중량         
        ,MGEWEI                         				--단위             
        ,JRCNT                          				--J/R 개수         
        ,OVBELN                         				--판매문서           
        ,OPOSNR                         				--판매문서 항목번호      
        ,OAUART                         				--판매문서 유형        
        ,OAUARTXT                       				--판매 문서 오더 유형 텍스트
        ,VBELN                          				--판매문서           
        ,POSNR                          				--판매문서 항목번호      
        ,VDATU                          				--납품 요청일자        
        ,SAUART                         				--판매문서 유형        
        ,SAUARTXT                       				--판매 문서 오더 유형 텍스트
        ,REMARK                         				                           --비고(22-06-08:REMARK->ORDER_RMK로 변경함)             
        ,SHEET                          				--판지 구분자         
        ,SLITER_SET                     				--슬리터 구분         
        ,MRLDCK                         				--밀롤 창고 적치 여부    
        ,CUTTER                         				--카터             
        ,STLNR                          				--대체Bom          
        ,STLAL                          				--BOM Num        
        ,BMENG                          				--모품목기준수량        
        ,BMEIN                          				--모품목기준수량 단위     
        ,DLFL                           				--오더 삭제 지시자  
        ,ROUTE                          				--항차 
        ,KUNNR                          				--판매처 
        ,NAME1                          				--판매처명	
        ,SLITER                         				--슬리터구분		 					 					  

        ,sysdate                                --수정일시
        ,'SP_SCH_SYNC_MA'                          --수정자ID
        --,case when DLFL = 'Y' then 'N'            
        --      when DLFL = 'N' then 'Y'
        -- end                                    --사용여부(Y:사용 N:미사용)	
        ,case when DLFL = 'X' then 'N'   --22-10-10 위의 내용 잘못되어 이것으로 교체함.
              else 'Y'                 
         end                                                                 
         FROM TB_IFR019 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE ORDER_NO = i_AUFNR;      
    ELSE    
      INSERT INTO TB_SCH016(  
           WRK_ORDR_NO                            --작업지시번호-->작업지시 생성자 사용 WO + R  
          ,WRK_ORDR_SEQNO                         --작업지시순번
          ,WRK_SEQNO                              --작업순서
          ,ORDR_GEN_DT                            --지시생성일자           

          ,ORDER_NO																--오더번호                   
          ,PRE_ORDER_NO         									--이전 오더 번호       
          ,WERKS                									--플랜트코드          
          ,ORDER_NUM            									--생산지시 No        
          ,ORDER_SEQ            									--생산지시 seq       
          ,PRD_REQ_DT           									--생산요청일자         
          ,ORDER_DIV            									--오더유형           
          ,ORDER_DIV_NM         									--오더유형 텍스트       
          ,MATNR                									--자재 코드          
          ,MACHINE              									--생산호기           
          ,MACHINE_NM           									--생산 호기명         
          ,TO_MACHINE           									--TO 생산호기        
          ,TO_MACHINE_NM        									--TO 생산 호기명      
          ,JMATNR               									--점보롤 자재 코드      
          ,PCODE                									--지종코드           
          ,BS_WGT               									--평량             
          ,MWIDTH               									--M/R 지폭         
          ,MWIDTH_INPUT         									--M/R 지폭_INPUT   
          ,MWIDTH_SLITER        									--M/R 지폭_SLITER  
          ,MROLLCNT             									--M/R 권치수        
          ,MRCNT                									--M/R 폭수         
          ,MBRGEW               									--M/R 중량         
          ,UNIT                 									--단위             
          ,JRCNT                									--J/R 개수         
          ,OVBELN               									--판매문서           
          ,OPOSNR               									--판매문서 항목번호      
          ,OAUART_DIV           									--판매문서 유형        
          ,OAUART_NM            									--판매 문서 오더 유형 텍스트
          ,VBELN                									--판매문서           
          ,POSNR                									--판매문서 항목번호      
          ,VDATU                									--납품 요청일자        
          ,SAUART_DIV           									--판매문서 유형        
          ,SAUART_NM            									--판매 문서 오더 유형 텍스트
          ,ORDER_RMK             									--비고(22-06-08:REMARK->ORDER_RMK로 변경함)              
          ,SHEET                									--판지 구분자         
          ,SLITER_SET           									--슬리터 구분         
          ,MRLDCK               									--밀롤 창고 적치 여부    
          ,CUTTER               									--카터             
          ,ATN_BOM_NO           									--대체Bom          
          ,BOM_NO               									--BOM Num        
          ,PRT_MATNR_QTY        									--모품목기준수량        
          ,PRT_MATNR_UNIT       									--모품목기준수량 단위     
          ,DLFL                 									--오더 삭제 지시자 
          ,ROUTE                                  --항차
          ,KUNNR                                  --판매처
          ,KUNNRT                                 --판매처명	
          ,SLITER			 					                  --슬리터구분
          ,WRK_ORDR_QTY

          ,COMP_YN                                --완료여부
          ,REGDATE                                --등록일시
          ,REGID                                  --등록자ID
          ,UPDDATE                                --수정일시
          ,UPDID                                  --수정자ID
          ,USE_YN                                 --사용여부(Y:사용 N:미사용)                 
      )                                           					                              
      SELECT                                      					                              
           V_WO_NO     														--작업지시번호             
          ,1                                      --작업지시순번   
          ,SUBSTR(V_WO_NO,-4)                     --작업순서(작업지시번호,-4)
          ,TO_CHAR(sysdate,'YYYYMMDD')            --지시생성일자             

          ,AUFNR																	--오더번호                   
          ,FRAUFNR                           			--이전 오더 번호       
          ,WERKS                          				--플랜트코드          
          ,ORDER_NUM                      				--생산지시 No        
          ,ORDER_SEQ                      				--생산지시 seq       
          ,BUDAT                          				--생산요청일자         
          ,AUART                          				--오더유형           
          ,AUARTXT                        				--오더유형 텍스트       
          ,MMATNR                         				--자재 코드          
          ,MACHINE                        				--생산호기           
          ,MACHINETXT                     				--생산 호기명         
          ,TOMACHINE                      				--TO 생산호기        
          ,TOMACHINETXT                   				--TO 생산 호기명      
          ,MATNR                          				--점보롤 자재 코드      
          ,PCODE                          				--지종코드           
          ,WEIGHT                         				--평량             
          ,MWIDTH                         				--M/R 지폭         
          ,MWIDTH_INPUT                   				--M/R 지폭_INPUT   
          ,MWIDTH_SLITER                  				--M/R 지폭_SLITER  
          ,MROLLCNT                       				--M/R 권치수        
          ,MRCNT                          				--M/R 폭수         
          ,MBRGEW                         				--M/R 중량         
          ,MGEWEI                         				--단위             
          ,JRCNT                          				--J/R 개수         
          ,OVBELN                         				--판매문서           
          ,OPOSNR                         				--판매문서 항목번호      
          ,OAUART                         				--판매문서 유형        
          ,OAUARTXT                       				--판매 문서 오더 유형 텍스트
          ,VBELN                          				--판매문서           
          ,POSNR                          				--판매문서 항목번호      
          ,VDATU                          				--납품 요청일자        
          ,SAUART                         				--판매문서 유형        
          ,SAUARTXT                       				--판매 문서 오더 유형 텍스트
          ,REMARK                         				--비고             
          ,SHEET                          				--판지 구분자         
          ,SLITER_SET                     				--슬리터 구분         
          ,MRLDCK                         				--밀롤 창고 적치 여부    
          ,CUTTER                         				--카터             
          ,STLNR                          				--대체Bom          
          ,STLAL                          				--BOM Num        
          ,BMENG                          				--모품목기준수량        
          ,BMEIN                          				--모품목기준수량 단위     
          ,DLFL                           				--오더 삭제 지시자 
          ,ROUTE                                  --항차
          ,KUNNR                                  --판매처
          ,NAME1                                  --판매처명				 					 
          ,SLITER			 					                  --슬리터구분
          ,MBRGEW               									--M/R 중량             

          ,'N'                                    --완료여부               
          ,sysdate                                --등록일시               
          ,'SP_SCH_SYNC_MA'                                       --등록자ID              
          ,null                                   --수정일시               
          ,null                                   --수정자ID 
          ,case when DLFL = 'X' then 'N'   
                else 'Y'                 
           end                                    --사용여부(Y:사용 N:미사용)	                                  
      FROM  TB_IFR019
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;       


    --작업지시 생성되면 작업지시BOM을 구성한다.                           
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH016
    WHERE ORDER_NO = i_AUFNR;

    SELECT COUNT(ORDER_NO) INTO V_BOM_CNT 
    FROM TB_SCH020 
    WHERE WRK_ORDR_NO = V_WO_NO
    AND WRK_ORDR_SEQNO = V_WO_SEQ; 

    --작업지시BOM이 존재하지 않으면 생산BOM->작업지시BOM을 생성 한다.
    IF V_BOM_CNT = 0 THEN 
      INSERT INTO TB_SCH020 
      (      ORDER_NO                  		--오더번호        
            ,ORDER_ITM_NO                 --오더Item번호    
            ,MATNR                        --자품목자재       
            ,ORDER_BOM_QTY                --오더BOM 수량    
            ,UNIT                         --오더BOM 수량단위  
            ,LOT_NO                       --LOT NO      
            ,STOR_LOC_CD                  --저장위치        
            ,DLFL                         --삭제 지시자(불출요청)
            ,WERKS                        --플랜트         
            ,WRK_ORDR_NO                  --작업지시번호      
            ,WRK_ORDR_SEQNO               --작업지시번호 순번  

            ,REGDATE                       /*     등록일자                       */
            ,REGID                         /*     등록자                        */
            ,UPDDATE                       /*     수정일자                       */
            ,UPDID                         /*     수정자                        */                   
      )
      SELECT AUFNR				                 /*		오더번호					                */
            ,POSNR				                 /*		오더Item번호					            */
            ,MATNR				                 /*		자품목자재					                */
            ,BDMNG				                 /*		오더BOM 수량					            */
            ,MEINS				                 /*		오더BOM 수량단위					          */
            ,LOT_NO                        --LOT번호            
            ,LGORT                         /*   저장위치                          */
            ,case when XLOEK = 'X' then 'Y'
                  else 'N'                           
             end				                 /*		삭제여부					                */
            ,V_WERKS
            ,V_WO_NO
            ,1  

            ,sysdate
            ,'SP_SCH_SYNC_MA'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                              

    
    o_msg_MSG  := 'SP_SCH_SYNC_MA==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');

    UPDATE  TB_IFR019
    SET     IF_STATUS   =  'S'                                                    -- I/F상태, N:신규, S:성공, E:오류
          , IF_SET_DATE =  sysdate            
          , IF_ERR_MESS =  o_msg_MSG          
    WHERE IF_IFR_NO =  i_IF_IFR_NO;

    o_msg_MSG  := 'SP_SCH_SYNC_MA==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
    o_msg_code := '0';
                                    
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    SP_IF_MIG_LOG('SP_SCH_SYNC_MA',o_msg_code,o_msg_MSG);
    COMMIT;
      
    EXCEPTION  
      WHEN E_EXCEPTION_USER THEN        
            DBMS_OUTPUT.PUT_LINE(o_msg_MSG);
            ROLLBACK;
       
            UPDATE  TB_IFR019
            SET     IF_STATUS   =  'E'  
                  , IF_SET_DATE =  sysdate                                      --I/F상태, N:신규, S:성공, E:오류               
                  , IF_ERR_MESS =  o_msg_MSG                                                            
            WHERE IF_IFR_NO =  i_IF_IFR_NO; 
            
            DBMS_OUTPUT.PUT_LINE (o_msg_msg );            
            SP_IF_MIG_LOG('USER:SP_SCH_SYNC_MA',o_msg_code,o_msg_msg);                                        
            COMMIT;                                    
                                      
      WHEN OTHERS THEN
            o_msg_msg  :=  'OTHER:SP_SCH_SYNC_MA에서 오류가 발생 되었습니다=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') || ',' || SQLERRM ;
            o_msg_code := '-1' ;
            ROLLBACK;

            UPDATE  TB_IFR019
            SET     IF_STATUS   =  'E'                                            --I/F상태, N:신규, S:성공, E:오류               
                  , IF_ERR_MESS =  o_msg_MSG                                                            
            WHERE IF_IFR_NO =  i_IF_IFR_NO;
            
            DBMS_OUTPUT.PUT_LINE (o_msg_msg );            
            SP_IF_MIG_LOG('SP_SCH_SYNC_MA',o_msg_code,o_msg_msg);                                        
            COMMIT;       
  END;
  END LOOP;

  o_msg_code      := '0' ;
  o_msg_msg       := 'End:SP_SCH_SYNC_MA 종료 되었습니다..=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
  DBMS_OUTPUT.PUT_LINE(o_msg_msg);  
  SP_IF_MIG_LOG('SP_SCH_SYNC_MA',o_msg_code,o_msg_msg);
  COMMIT;                                                                   
                                                                      
       
 EXCEPTION
    WHEN OTHERS THEN
      o_msg_code      := '-1' ;
      o_msg_msg       := 'Error: SP_SCH_SYNC_MA에서 오류가 발생하였습니다.=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
      rollback ;

      DBMS_OUTPUT.PUT_LINE(o_msg_msg);      
      SP_IF_MIG_LOG('SP_SCH_SYNC_MA',o_msg_code,o_msg_msg);
      COMMIT;       

END;
/
