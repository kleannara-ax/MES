
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH_GET_IFR_SYNC_JA" 
AS                                                                                     
/*==============================================================================
 * PROGRAM ID    : 마이그레이션
 * PROGRAM NAME  : 생산오더의 데이타 수신후 누락된부분 각 I/F테이블과 동기화 한다.
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산오더 점보롤->작업지시 동기화
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
          SELECT K.AUFNR,(SELECT MAX(IF_MES_KEY) FROM TB_IFR018 WHERE AUFNR = K.AUFNR) IF_MES_KEY  
          FROM (SELECT DISTINCT AUFNR 
                FROM TB_IFR018) K      
          WHERE K.AUFNR NOT IN(SELECT ORDER_NO FROM TB_SCH015 WHERE ORDER_NO = K.AUFNR)
         ) DATA
        ,TB_IFR018 INFO
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
    FROM TB_IFR018
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH006
      SET DLFL = V_DLFL
      WHERE AUFNR =  i_AUFNR;

      UPDATE TB_SCH015
      SET USE_YN = 'N'
      WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  := 'SP_SCH_SYNC_JA==>완료==>'|| i_AUFNR  ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');      
           
      UPDATE  TB_IFR018
      SET     IF_STATUS   =  'S'                                                    -- I/F상태, N:신규, S:성공, E:오류
            , IF_SET_DATE =  sysdate            
            , IF_ERR_MESS =  o_msg_MSG          
      WHERE IF_IFR_NO =  i_IF_IFR_NO;

      o_msg_MSG  := 'SP_SCH_SYNC_JA==>완료==>'|| i_AUFNR  ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
      o_msg_code := '0' ;
                                      
      DBMS_OUTPUT.PUT_LINE(o_msg_MSG);
      SP_IF_MIG_LOG('SP_SCH_SYNC_JA','0',o_msg_MSG);
      COMMIT;      
                        
      CONTINUE;
    END IF;


  -----------------------------------------------------------------------------------------------------------------------------
  --생산오더
  -----------------------------------------------------------------------------------------------------------------------------
    SELECT COUNT(1) INTO V_CNT FROM TB_SCH006 WHERE AUFNR = i_AUFNR;   
  
    IF V_CNT > 0 THEN    
      UPDATE TB_SCH006
      SET(
           WERKS							     								--플랜트					                                                              
          ,BUDAT							     								--시작일자					                                                            
          ,PRDTYPE		    		     								--생산라인구분					       	                                            
          ,PRDTYPETXT	    	       								--생산라인구분명					                                                  
          ,MATNR							     								--제품코드					                                                            
          ,PCODE							     								--지종코드					                                                            
          ,WEIGHT						       								--평량					                                                            
          ,JWIDTH						       								--J/R 지폭					                                                        
          ,JROLLCNT		    	       								--J/R 권치수					                                                    
          ,JBRGEW						       								--총중량					                                                            
          ,JRCNT							     								--J/R 개수					                                                          
          ,MEINS							     								--생산지시단위					                                                         
          ,SHEET							     								--판지구분자					                                                            
          ,AENAM							     								--작업지시자					                                                            
          ,MACHINE		    		     								--FROM 생산호기					     	                                            
          ,MACHINETXT				       								-- FROM 생산호기명                                                            
          ,TOMACHINE	    		     								--TO 생산호기					                                                       
          ,TOMACHINETXT				     								--TO 생산호기명                                                            
          ,STLNR							     								--BOM Num					                                                          
          ,STLAL							     								--대체Bom					                                                            
          ,BMENG							     								--모품목기준수량					                                                        
          ,BMEIN							     								--모품목기준수량 단위			       			                                           
          ,NAUFNR						       								--오더 변경 번호					                                                     
          ,DLFL			    		       								--오더 삭제 지시자					     	                                           
          ,ORDER_RMK  				     								--특이사항                                                                       
          ,WRK_CD     				     								--작업장                                                                        
          ,REM        				     								            --반복생산지시자                                                                    
          ,ROUTE      				     								--항차                                                                         
                                                                                                                       
          ,UPDDATE          	     								--수정일자                                                               
          ,UPDID            	     								--수정자                          	                                                              
      )=(SELECT                         										
           WERKS			         										--플랜트					                
          ,BUDAT			                            --시작일자					         
          ,PRDTYPE			                          --생산라인구분					       
          ,PRDTYPETXT			                        --생산라인구분명					       
          ,MATNR			                            --제품코드					         
          ,PCODE			                            --지종코드					         
          ,WEIGHT			                            --평량					           
          ,JWIDTH			                            --J/R 지폭					       
          ,JROLLCNT			                          --J/R 권치수					       
          ,JBRGEW			                            --총중량					           
          ,JRCNT			                            --J/R 개수					       
          ,MEINS			                            --생산지시단위					       
          ,SHEET			                            --판지구분자					         
          ,AENAM			                            --작업지시자					         
          ,MACHINE			                          --FROM 생산호기					     
          ,MACHINETXT		                          -- FROM 생산호기명            
          ,TOMACHINE		                          --TO 생산호기					       
          ,TOMACHINETXT			                      --TO 생산호기명               
          ,STLNR			                            --BOM Num					       
          ,STLAL			                            --대체Bom					         
          ,BMENG			                            --모품목기준수량					       
          ,BMEIN			                            --모품목기준수량 단위			       
          ,NAUFNR			                            --오더 변경 번호					     
          ,DLFL			                              --오더 삭제 지시자					     
          ,ZMEMO                                  --특이사항                   
          ,ARBPL                                  --작업장                    
          ,REM                                                                        --반복생산지시자                
          ,ROUTE                                  --항차                     
                                                                           
          ,sysdate                                --수정일자                   
          ,'SP_SCH_SYNC_JA'                           --수정자                                                                                
         FROM TB_IFR018 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE  AUFNR   = i_AUFNR;       
    ELSE    
      INSERT INTO TB_SCH006(  
           AUFNR							                    --오더번호					                       
          ,WERKS							                    --플랜트					                      
          ,BUDAT							                    --시작일자					                       
          ,PRDTYPE							                  --생산라인구분					                         
          ,PRDTYPETXT							                --생산라인구분명					                      
          ,MATNR							                    --제품코드					                       
          ,PCODE							                    --지종코드					                       
          ,WEIGHT							                    --평량					                        
          ,JWIDTH							                    --J/R 지폭					                    
          ,JROLLCNT							                  --J/R 권치수					                     
          ,JBRGEW							                    --총중량					                       
          ,JRCNT							                    --J/R 개수					                    
          ,MEINS							                    --생산지시단위					                        
          ,SHEET							                    --판지구분자					                       
          ,AENAM							                    --작업지시자					                       
          ,MACHINE							                  --FROM 생산호기					                        
          ,MACHINETXT							                --FROM 생산호기명				                                             
          ,TOMACHINE							                --TO 생산호기명               
          ,TOMACHINETXT							              --TO 생산호기명                                  
          ,STLNR							                    --BOM Num					                   
          ,STLAL							                    --대체Bom					                      
          ,BMENG							                    --모품목기준수량					                      
          ,BMEIN							                    --모품목기준수량 단위		                           
          ,NAUFNR							                    --오더 변경 번호				                       
          ,DLFL							                      --오더 삭제 지시자				                        
          ,REM                                    --반복생산 지시자                                             
          ,ROUTE                                  --항차                                                  
          ,ORDER_RMK                              --특이사항                   
          ,WRK_CD                                 --작업장                    
                                                                           
          ,REGDATE                                --등록일자                                                  
          ,REGID                                  --등록자                                                   
          ,UPDDATE                                --수정일자                                                   
          ,UPDID                                  --수정자                                                                                                                                               		                   		                  
      )                                           					                              
      SELECT                                      					                              
           AUFNR				                          --오더번호					                                     
          ,WERKS				                          --플랜트					                                     
          ,BUDAT				                          --시작일자					                                     
          ,PRDTYPE				               		      --생산라인구분					                                        
          ,PRDTYPETXT				             	        --생산라인구분명					                                      
          ,MATNR				                          --제품코드					                                     
          ,PCODE				                          --지종코드					                                     
          ,WEIGHT				                          --평량					                                   
          ,JWIDTH				                          --J/R 지폭					                               
          ,JROLLCNT				                        --J/R 권치수					                                   
          ,JBRGEW				                          --총중량					                                     
          ,JRCNT				                          --J/R 개수					                               
          ,MEINS				                 		      --생산지시단위					                                      
          ,SHEET				                          --판지구분자					                                      
          ,AENAM				                          --작업지시자					                                      
          ,MACHINE				               		      --FROM 생산호기					                                      
          ,MACHINETXT				             	        --FROM 생산호기명				                                                       
          ,TOMACHINE				                      --TO 생산호기                       
          ,TOMACHINETXT				                    --TO 생산호기명                                                 
          ,STLNR				                          --BOM Num					                             
          ,STLAL				                          --대체Bom					                                   
          ,BMENG				                 		      --모품목기준수량					                                         
          ,BMEIN				                 		      --모품목기준수량 단위		                   	                        
          ,NAUFNR				                 	        --오더 변경 번호				                                       
          ,DLFL				                   	        --오더 삭제 지시자				             	                          
          ,REM                                    --반복생산 지시자                                                      
          ,ROUTE                                  --항차                                                      
          ,ZMEMO                                  --특이사항                         
          ,ARBPL                                  --작업장                         
                                                                           
          ,sysdate                                --등록일자                                                                  
          ,'SP_SCH_SYNC_JA'                       --등록자                                                                       
          ,null                                   --수정일자                                                                   
          ,null                                   --수정자                                                                                                                                                                                                       
      FROM  TB_IFR018
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;    



    --========================================         
    --KHJ추가 2022-05-01:작업지시
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_SCH015
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR018
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOJA',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------
    IF V_CNT > 0 THEN    
      UPDATE TB_SCH015
      SET(        
         WERKS                 									--플랜트코드      
        ,PRD_REQ_DT            									--생산요청일자     
        ,PRDTYPE               									--생산라인구분     
        ,PRDTYPETXT            									--생산라인구분명    
        ,MATNR                 									--자재 코드      
        ,PCODE                 									--지종         
        ,BS_WGT                									--평량         
        ,JWIDTH                									--J/R 지폭     
        ,JROLLCNT              									--J/R 권치수    
        ,TOT_WGT               									--총중량        
        ,JRCNT                 									--J/R 개수     
        ,UNIT                  									--단위         
        ,SHEET                 									--판지구분자      
        ,WORK_ORDER            									--작업지시자      
        ,MACHINE               									--FROM 생산호기  
        ,MACHINE_NM            									--FROM 생산 호기명
        ,TO_MACHINE            									--TO 생산호기    
        ,TO_MACHINE_NM         									--TO 생산 호기명  
        ,WRK_CD                									--작업장코드      
        ,BOM_NO                									--BOM Num    
        ,ATN_BOM_NO            									--대체Bom      
        ,PRT_MATNR_QTY         									--모품목기준수량 수량 
        ,PRT_MATNR_UNIT        									--모품목기준수량 단위 
        ,NAUFNR                									--오더 변경 번호   
        ,DLFL                  									--오더 삭제 지시자
        ,ORDER_RMK             									--특이사항
        ,REM                   									                    --반복생산지시자
        ,ROUTE                 									--항차
        ,WRK_ORDR_QTY          									--지시수량
                                                
                                                
        ,UPDDATE               									--수정일시
        ,UPDID                 									--수정자ID
        ,USE_YN                									--사용여부(Y:사용 N:미사용)	                 
      )=(SELECT                         										
         WERKS                          				--플랜트코드      
        ,BUDAT                          				--생산요청일자     
        ,PRDTYPE                        				--생산라인구분     
        ,PRDTYPETXT                     				--생산라인구분명    
        ,MATNR                          				--자재 코드      
        ,PCODE                          				--지종         
        ,WEIGHT                         				--평량         
        ,JWIDTH                         				--J/R 지폭     
        ,JROLLCNT                       				--J/R 권치수    
        ,JBRGEW                         				--총중량        
        ,JRCNT                          				--J/R 개수     
        ,MEINS                          				--단위         
        ,SHEET                          				--판지구분자      
        ,AENAM                          				--작업지시자      
        ,MACHINE                        				--FROM 생산호기  
        ,MACHINETXT                     				--FROM 생산 호기명
        ,TOMACHINE                      				--TO 생산호기    
        ,TOMACHINETXT                   				--TO 생산 호기명  
        ,ARBPL                          				--작업장코드      
        ,STLNR                          				--BOM Num    
        ,STLAL                          				--대체Bom      
        ,BMENG                          				--모품목기준수량 수량 
        ,BMEIN                          				--모품목기준수량 단위 
        ,NAUFNR                         				--오더 변경 번호   
        ,DLFL                           				--오더 삭제 지시자
        ,ZMEMO                          				--특이사항
        ,REM                            				--반복생산지시자
        ,ROUTE                          				--항차
        ,JBRGEW                         				--지시수량
                                                                                                
        ,sysdate                               	--수정일시
        ,'SP_SCH_SYNC_JA'                      	--수정자ID
        ,case when DLFL = 'Y' then 'N'  	          
              when DLFL = 'N' then 'Y'  	
         end                                   	--사용여부(Y:사용 N:미사용)	                                                     
         FROM TB_IFR018 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE ORDER_NO = i_AUFNR;      
    ELSE    
      INSERT INTO TB_SCH015(  
         WRK_ORDR_NO                     				--작업지시번호-->작업지시 생성자 사용 WO + R  
        ,WRK_ORDR_SEQNO                  				--작업지시순번
        ,WRK_SEQNO                       				--작업순서
        ,ORDR_GEN_DT                     				--지시생성일자           
                                                
        ,ORDER_NO             									--오더번호       
        ,WERKS                									--플랜트코드      
        ,PRD_REQ_DT           									--생산요청일자     
        ,PRDTYPE              									--생산라인구분     
        ,PRDTYPETXT           									--생산라인구분명    
        ,MATNR                									--자재 코드      
        ,PCODE                									--지종         
        ,BS_WGT               									--평량         
        ,JWIDTH               									--J/R 지폭     
        ,JROLLCNT             									--J/R 권치수    
        ,TOT_WGT              									--총중량        
        ,JRCNT                									--J/R 개수     
        ,UNIT                 									--단위         
        ,SHEET                									--판지구분자      
        ,WORK_ORDER           									--작업지시자      
        ,MACHINE              									--FROM 생산호기  
        ,MACHINE_NM           									--FROM 생산 호기명
        ,TO_MACHINE           									--TO 생산호기    
        ,TO_MACHINE_NM        									--TO 생산 호기명  
        ,WRK_CD               									--작업장코드      
        ,BOM_NO               									--BOM Num    
        ,ATN_BOM_NO           									--대체Bom      
        ,PRT_MATNR_QTY        									--모품목기준수량 수량
        ,PRT_MATNR_UNIT       									--모품목기준수량 단위 					  
        ,NAUFNR               									--오더 변경 번호   
        ,DLFL                 									--오더 삭제 지시자   
        ,ORDER_RMK                       				--특이사항
        ,REM                             				                            --반복생산지시자
        ,ROUTE                           				--항차
        ,WRK_ORDR_QTY                    				--지시수량
                                                
        ,COMP_YN                         				--완료여부
        ,REGDATE                         				--등록일시
        ,REGID                           				--등록자ID
        ,UPDDATE                         				--수정일시
        ,UPDID                           				--수정자ID
        ,USE_YN                          				--사용여부(Y:사용 N:미사용)                 
      )                                           					                              
      SELECT                                      					                              
        V_WO_NO     																			--작업지시번호             
        ,1                                                --작업지시순번 
        ,SUBSTR(V_WO_NO,-4)                               --작업순서(작업지시번호,-4)
        ,TO_CHAR(sysdate,'YYYYMMDD')                      --지시생성일자           

        ,AUFNR       																			--오더번호       
        ,WERKS                          									--플랜트코드      
        ,BUDAT                          									--생산요청일자     
        ,PRDTYPE                        									--생산라인구분     
        ,PRDTYPETXT                     									--생산라인구분명    
        ,MATNR                          									--자재 코드      
        ,PCODE                          									--지종         
        ,WEIGHT                         									--평량         
        ,JWIDTH                         									--J/R 지폭     
        ,JROLLCNT                       									--J/R 권치수    
        ,JBRGEW                         									--총중량        
        ,JRCNT                          									--J/R 개수     
        ,MEINS                          									--단위         
        ,SHEET                          									--판지구분자      
        ,AENAM                          									--작업지시자      
        ,MACHINE                        									--FROM 생산호기  
        ,MACHINETXT                     									--FROM 생산 호기명
        ,TOMACHINE                      									--TO 생산호기    
        ,TOMACHINETXT                   									--TO 생산 호기명  
        ,ARBPL                          									--작업장코드      
        ,STLNR                          									--BOM Num    
        ,STLAL                          									--대체Bom      
        ,BMENG                          									--모품목기준수량 수량 
        ,BMEIN                          									--모품목기준수량 단위 
        ,NAUFNR                         									--오더 변경 번호   
        ,DLFL                           									--오더 삭제 지시자 
        ,ZMEMO                                            --특이사항
        ,REM                                                                                            --반복생산지시자
        ,ROUTE                                            --항차
        ,JBRGEW                                           --지시수량

        ,'N'                                              --완료여부               
        ,sysdate                                          --등록일시               
        ,'SP_SCH_SYNC_JA'                                      --등록자ID              
        ,null                                             --수정일시               
        ,null                                             --수정자ID 
        ,case when DLFL = 'X' then 'N'                     
             else 'Y'                 
        end                                               --사용여부(Y:사용 N:미사용)	                              
      FROM  TB_IFR018
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;      
    


    --작업지시 생성되면 작업지시BOM을 구성한다.(점보롤은 생산BOM이 없음, 22-06-09 존재한다고 해서 다시 추가함)              
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH015
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
            ,'SP_SCH_SYNC_JA'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                      

    
    o_msg_MSG  := 'SP_SCH_SYNC_JA==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');

    UPDATE  TB_IFR018
    SET     IF_STATUS   =  'S'                                                    -- I/F상태, N:신규, S:성공, E:오류
          , IF_SET_DATE =  sysdate            
          , IF_ERR_MESS =  o_msg_MSG          
    WHERE IF_IFR_NO =  i_IF_IFR_NO;

    o_msg_MSG  := 'SP_SCH_SYNC_JA==>완료==>'|| i_AUFNR ||'=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
    o_msg_code := '0';
                                    
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    SP_IF_MIG_LOG('SP_SCH_SYNC_JA',o_msg_code,o_msg_MSG);
    COMMIT;
      
    EXCEPTION  
      WHEN E_EXCEPTION_USER THEN        
            DBMS_OUTPUT.PUT_LINE(o_msg_MSG);
            ROLLBACK;
       
            UPDATE  TB_IFR018
            SET     IF_STATUS   =  'E'  
                  , IF_SET_DATE =  sysdate                                      --I/F상태, N:신규, S:성공, E:오류               
                  , IF_ERR_MESS =  o_msg_MSG                                                            
            WHERE IF_IFR_NO =  i_IF_IFR_NO; 
            
            DBMS_OUTPUT.PUT_LINE (o_msg_msg );            
            SP_IF_MIG_LOG('USER:SP_SCH_SYNC_JA',o_msg_code,o_msg_msg);                                        
            COMMIT;                                    
                                      
      WHEN OTHERS THEN
            o_msg_msg  :=  'OTHER:SP_SCH_SYNC_JA에서 오류가 발생 되었습니다=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') || ',' || SQLERRM ;
            o_msg_code := '-1' ;
            ROLLBACK;

            UPDATE  TB_IFR018
            SET     IF_STATUS   =  'E'                                            --I/F상태, N:신규, S:성공, E:오류               
                  , IF_ERR_MESS =  o_msg_MSG                                                            
            WHERE IF_IFR_NO =  i_IF_IFR_NO;
            
            DBMS_OUTPUT.PUT_LINE (o_msg_msg );            
            SP_IF_MIG_LOG('SP_SCH_SYNC_JA',o_msg_code,o_msg_msg);                                        
            COMMIT;       
  END;
  END LOOP;

  o_msg_code      := '0' ;
  o_msg_msg       := 'End:SP_SCH_SYNC_JA 종료 되었습니다..=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS');
  DBMS_OUTPUT.PUT_LINE(o_msg_msg);  
  SP_IF_MIG_LOG('SP_SCH_SYNC_JA',o_msg_code,o_msg_msg);
  COMMIT;                                                                   
                                                                      
       
 EXCEPTION
    WHEN OTHERS THEN
      o_msg_code      := '-1' ;
      o_msg_msg       := 'Error: SP_SCH_SYNC_JA에서 오류가 발생하였습니다.=>' || TO_CHAR(sysdate,'YYYY-MM-DD HH24:MI:SS') || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
      rollback ;

      DBMS_OUTPUT.PUT_LINE(o_msg_msg);      
      SP_IF_MIG_LOG('SP_SCH_SYNC_JA',o_msg_code,o_msg_msg);
      COMMIT;       

END;
/
