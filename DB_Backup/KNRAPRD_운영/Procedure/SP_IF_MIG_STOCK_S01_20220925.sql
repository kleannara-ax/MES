--------------------------------------------------------
--  DDL for Procedure SP_IF_MIG_STOCK_S01_20220925
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_MIG_STOCK_S01_20220925" (
	P_TYPE           IN    varchar2, -- LIST, SAVE
	P_JSON_STR       IN    CLOB,
	P_SUCCESS       OUT    varchar2,
	P_RS_LIST       OUT    SYS_REFCURSOR 
)
/*==============================================================================
 * PROGRAM ID    : MIG01
 * PROGRAM NAME  : 초기재고SETUP
 * VERSION       : 1.0.0
 * DESCRIPTION   : 초기재고SETUP
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/09/05
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/09/05    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [TX_SAP_INIT] : ( R  ) SAP초기재고 
 *        - [TX_PIS_INIT] 	: ( R  ) PIS초기재고
 *        - [TX_BASE_INIT] : ( I  ) 초기재고 테이블
 *[PTYPE사용법]--------------------------------------------------------------------------------------------------------------
 *LIST : 등록된 초기재고데이타를 조회(개별바코드번호사용)
 *SCAN:개별바코드번호를 스캔하여 SAP,PIS정보 조회-->초기재고데이터 등록전 사용
 *SAVE:스캔하여 데이타 조정후 초기재고데이터를 등록 한다.
 *=============================================================================*/


AS
	V_PRG_NM          	VARCHAR2(100) 	:= 'SP_IF_MIG_STOCK_S01';     -- PROCEDURE NAME

	-- 오라클 에러 처리용 변수선언 영역
  E_EXCEPTION_USER  	EXCEPTION;
  E_SQL_ERR_CD      	NUMBER(5) 		:= 0;
  E_SQL_ERR_MSG		    VARCHAR2(4000);

  -- JSON을 위한 변수선언 영역
  V_JSON		      JSON_OBJECT_T;
  V_ARR_LIST       	  JSON_ARRAY_T;
  V_OBJ               JSON_OBJECT_T;

	-- 세션값 처리용 변수선언 영역
  V_SESS_USER_ID   	  varchar2(20);
  V_PLT_CD         	  varchar2(2);
  V_DEBUG          	  varchar2(1);

	-- 조건절 처리용 변수선언 영역

	V_SQL				        CLOB;
		
  V_WERKS      		  TX_BASE_INIT.WERKS%TYPE;      					--플랜트       	
  V_MACH_CD           TX_BASE_INIT.MACH_CD%TYPE;              --설비코드      
  V_STOR_LOC_CD       TX_BASE_INIT.STOR_LOC_CD%TYPE;          --저장위치      
  V_LOC_CD            TX_BASE_INIT.LOC_CD%TYPE;               --로케이션      
  V_MATNR             TX_BASE_INIT.MATNR%TYPE;                --자재코드      
  V_LOT_NO            TX_BASE_INIT.LOT_NO%TYPE;               --LOT번호     
  V_IND_BCD           TX_BASE_INIT.IND_BCD%TYPE;              --개별바코드     
  V_ORDER_NO          TX_BASE_INIT.ORDER_NO%TYPE;             --오더번호      
  V_MACHINE           TX_BASE_INIT.MACHINE%TYPE;              --생산호기      
  V_PROC_CD           TX_BASE_INIT.PROC_CD%TYPE;              --공정        
  V_PRD_DT            TX_BASE_INIT.PRD_DT%TYPE;               --생산일자      
  V_PRFM_DT           TX_BASE_INIT.PRFM_DT%TYPE;              --제조일자      
  V_DSTBT_DDLIN       TX_BASE_INIT.DSTBT_DDLIN%TYPE;          --유통기간      
  V_PCODE             TX_BASE_INIT.PCODE%TYPE;                --지종        
  V_UNIT              TX_BASE_INIT.UNIT%TYPE;                 --단위        
  V_ROLLCNT           TX_BASE_INIT.ROLLCNT%TYPE;              --실적_권치수    
  V_PCNT              TX_BASE_INIT.PCNT%TYPE;                 --실적_연수_REAM
  V_SCNT              TX_BASE_INIT.SCNT%TYPE;                 --실적_속당매수   
  V_MCNT              TX_BASE_INIT.MCNT%TYPE;                 --실적_속수     
  V_WGT               TX_BASE_INIT.WGT%TYPE;                  --실적_중량     
  V_CORE              TX_BASE_INIT.CORE%TYPE;                 --지관        
  V_BS_WGT            TX_BASE_INIT.BS_WGT%TYPE;               --평량        
  V_PACKTYPE          TX_BASE_INIT.PACKTYPE%TYPE;             --포장타입      
  V_CONTYPE           TX_BASE_INIT.CONTYPE%TYPE;              --컨테이너유형    
  V_WLEN              TX_BASE_INIT.WLEN%TYPE;                 --가로길이      
  V_VLEN              TX_BASE_INIT.VLEN%TYPE;                 --세로길이      
  V_WIDTH             TX_BASE_INIT.WIDTH%TYPE;                --지폭        
  V_VBELN             TX_BASE_INIT.VBELN%TYPE;                --판매문서번호    
  V_POSNR             TX_BASE_INIT.POSNR%TYPE;                --판매문서항목번호  
  V_KUNNR             TX_BASE_INIT.KUNNR%TYPE;                --판매처_MTO   
  V_MRG_YN            TX_BASE_INIT.MRG_YN%TYPE;               --라벨병합여부    
  V_WRK_CLASS         TX_BASE_INIT.WRK_CLASS%TYPE;            --작업반       
  V_WRK_SHIFT         TX_BASE_INIT.WRK_SHIFT%TYPE;            --작업조
	
	
	--임시사용변수 선언
	V_CNT               NUMBER        := 0;
		

BEGIN
    OPEN P_RS_LIST FOR 

	SELECT NULL FROM DUAL WHERE ROWNUM = 0;

	V_JSON 				  := JSON_OBJECT_T.parse(P_JSON_STR);

	V_SESS_USER_ID	      := V_JSON.get_string('SES_USER_ID');

	V_WERKS				  := V_JSON.get_string('WERKS');			                            --플랜트코드
	V_IND_BCD			  := V_JSON.get_string('IND_BCD');	                              --개별바코드
		

	

    IF P_TYPE = 'LIST' THEN  
        --스캔했을때 MES의 코드로 변환해줘야 된다.(설비코드,생산호기,공정=TB_MAS012에서...)(저장위치=SAP에서...)(로케이션=화면에서...)
		V_SQL :=' 
              SELECT PIS.WERKS      				AS WERKS      			--플랜트       	  
                    ,PIS.MACH_CD            AS MACH_CD          --*설비코드          
                    ,SAP.STOR_LOC_CD        AS STOR_LOC_CD      --저장위치          
                    ,''''             		AS LOC_CD           --로케이션          
                    ,PIS.MATNR              AS MATNR            --자재코드          
                    ,PIS.LOT_NO             AS LOT_NO           --LOT번호         
                    ,PIS.IND_BCD            AS IND_BCD          --개별바코드         
                    ,SUBSTR(PIS.ORDER_NO,-10)   AS ORDER_NO         --오더번호          
                    ,PIS.MACHINE            AS MACHINE          --*생산호기          
                    ,PIS.PROC_CD            AS PROC_CD          --*공정            
                    ,PIS.PRD_DT             AS PRD_DT           --생산일자          
                    ,PIS.PRFM_DT            AS PRFM_DT          --제조일자          
                    ,PIS.DSTBT_DDLIN        AS DSTBT_DDLIN      --유통기간          
                    ,PIS.PCODE              AS PCODE            --지종            
                    ,PIS.UNIT               AS UNIT             --단위            
                    ,PIS.ROLLCNT            AS ROLLCNT          --실적_권치수        
                    ,PIS.PCNT               AS PCNT             --실적_연수_REAM    
                    ,PIS.SCNT               AS SCNT             --실적_속당매수       
                    ,PIS.MCNT               AS MCNT             --실적_속수         
                    ,PIS.WGT                AS WGT              --실적_중량         
                    ,PIS.CORE               AS CORE             --지관            
                    ,PIS.BS_WGT             AS BS_WGT           --평량            
                    ,PIS.PACKTYPE           AS PACKTYPE         --포장타입          
                    ,PIS.CONTYPE            AS CONTYPE          --컨테이너유형        
                    ,PIS.WLEN               AS WLEN             --가로길이          
                    ,PIS.VLEN               AS VLEN             --세로길이          
                    ,PIS.WIDTH              AS WIDTH            --지폭            
                    ,SUBSTR(PIS.VBELN,-8)   AS VBELN            --판매문서번호        
                    ,PIS.POSNR              AS POSNR            --판매문서항목번호      
                    ,SUBSTR(PIS.KUNNR,-6)   AS KUNNR            --판매처_MTO       
                    ,PIS.MRG_YN             AS MRG_YN           --라벨병합여부        
                    ,PIS.WRK_CLASS          AS WRK_CLASS        --작업반           
                    ,PIS.WRK_SHIFT          AS WRK_SHIFT        --작업조           
              FROM TX_PIS_INIT PIS
                  ,TX_SAP_INIT SAP
              WHERE PIS.LOT_NO = SAP.LOT_NO
			 ';
                				             
		IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN                   --개별바코드
            V_SQL := V_SQL || ' AND PIS.IND_BCD = ''' || V_IND_BCD || '''';            				      
        END IF;             

        IF (V_DEBUG = 'Y') THEN
            INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
        END IF;

        OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'LIST2' THEN         --이력조회
		V_SQL :=' 
			SELECT  WERKS      										 AS WERKS      									--플랜트       	
                     ,MACH_CD                        AS MACH_CD                     --설비코드      
                     ,STOR_LOC_CD                    AS STOR_LOC_CD                 --저장위치      
                     ,LOC_CD                         AS LOC_CD                      --로케이션      
                     ,MATNR                          AS MATNR                       --자재코드      
                     ,LOT_NO                         AS LOT_NO                      --LOT번호     
                     ,IND_BCD                        AS IND_BCD                     --개별바코드     
                     ,ORDER_NO                       AS ORDER_NO                    --오더번호      
                     ,MACHINE                        AS MACHINE                     --생산호기      
                     ,PROC_CD                        AS PROC_CD                     --공정        
                     ,PRD_DT                         AS PRD_DT                      --생산일자      
                     ,PRFM_DT                        AS PRFM_DT                     --제조일자      
                     ,DSTBT_DDLIN                    AS DSTBT_DDLIN                 --유통기간      
                     ,PCODE                          AS PCODE                       --지종        
                     ,UNIT                           AS UNIT                        --단위        
                     ,ROLLCNT                        AS ROLLCNT                     --실적_권치수    
                     ,PCNT                           AS PCNT                        --실적_연수_REAM
                     ,SCNT                           AS SCNT                        --실적_속당매수   
                     ,MCNT                           AS MCNT                        --실적_속수     
                     ,WGT                            AS WGT                         --실적_중량     
                     ,CORE                           AS CORE                        --지관        
                     ,BS_WGT                         AS BS_WGT                      --평량        
                     ,PACKTYPE                       AS PACKTYPE                    --포장타입      
                     ,CONTYPE                        AS CONTYPE                     --컨테이너유형    
                     ,WLEN                           AS WLEN                        --가로길이      
                     ,VLEN                           AS VLEN                        --세로길이      
                     ,WIDTH                          AS WIDTH                       --지폭        
                     ,VBELN                          AS VBELN                       --판매문서번호    
                     ,POSNR                          AS POSNR                       --판매문서항목번호  
                     ,KUNNR                          AS KUNNR                       --판매처_MTO   
                     ,MRG_YN                         AS MRG_YN                      --라벨병합여부    
                     ,WRK_CLASS                      AS WRK_CLASS                   --작업반       
                     ,WRK_SHIFT                      AS WRK_SHIFT                   --작업조 
                     ,INS_DT                          AS INS_DT                       --등록일자      
                     ,UPD_DT                         AS UPD_DT                      --수정일자      
                     ,IF_YN                          AS IF_YN                       --처리여부      
                     ,IF_MSG                         AS IF_MSG                      --처리결과      
			FROM TX_BASE_INIT
			 ';

      /*
			IF (V_WERKS IS NOT NULL OR TRIM(V_WERKS) != '') THEN
            	V_SQL := V_SQL || ' AND WERKS = ''' || V_WERKS || '''';                  --플랜트코드				      
            END IF;
            */
        				              
			IF (V_IND_BCD IS NOT NULL OR TRIM(V_IND_BCD) != '') THEN                   --개별바코드
          V_SQL := V_SQL || ' AND IND_BCD = ''' || V_IND_BCD || '''';            				      
      END IF;             

      V_SQL := V_SQL || ' ORDER BY IND_BCD';

      IF (V_DEBUG = 'Y') THEN
        INSERT INTO PROC_LOG (SQL_STR) VALUES (V_SQL);
      END IF;

		OPEN P_RS_LIST FOR V_SQL;
    ELSIF P_TYPE = 'LIST3' THEN --저장위치
		V_SQL := ' SELECT STOR_LOC_CD
                        , STOR_LOC_NM
                     FROM TB_MAS003 --저장위치
                    WHERE WERKS = ''' || V_WERKS || '''
                    ORDER BY STOR_LOC_CD ';
        OPEN P_RS_LIST FOR V_SQL;
        
    ELSIF P_TYPE = 'LIST4' THEN --로케이션
        V_STOR_LOC_CD       :=      V_JSON.get_string('STOR_LOC_CD');
        
		V_SQL := ' SELECT LOC_CD
                        , LOC_NM
                     FROM TB_MAS028 --로케이션
                    WHERE WERKS = ''' || V_WERKS || '''
                      AND STOR_LOC_CD = ''' || V_STOR_LOC_CD || '''
                    ORDER BY LOC_CD ';
                    
        OPEN P_RS_LIST FOR V_SQL;
        
    ELSIF P_TYPE = 'SAVE' THEN            
        V_MACH_CD           :=      V_JSON.get_string('MACH_CD');
        V_STOR_LOC_CD       :=      V_JSON.get_string('STOR_LOC_CD');
        V_LOC_CD            :=      V_JSON.get_string('LOC_CD');
        V_MATNR             :=      V_JSON.get_string('MATNR');
        V_LOT_NO            :=      V_JSON.get_string('LOT_NO');
        V_ORDER_NO          :=      V_JSON.get_string('ORDER_NO');
        V_MACHINE           :=      V_JSON.get_string('MACHINE');
        V_PROC_CD           :=      V_JSON.get_string('PROC_CD');
        V_PRD_DT            :=      V_JSON.get_string('PRD_DT');
        V_PRFM_DT           :=      V_JSON.get_string('PRFM_DT');
        V_DSTBT_DDLIN       :=      V_JSON.get_string('DSTBT_DDLIN');
        V_PCODE             :=      V_JSON.get_string('PCODE');
        V_UNIT              :=      V_JSON.get_string('UNIT');
        V_ROLLCNT           :=      V_JSON.get_string('ROLLCNT');
        V_PCNT              :=      V_JSON.get_string('PCNT');
        V_SCNT              :=      V_JSON.get_string('SCNT');
        V_MCNT              :=      V_JSON.get_string('MCNT');
        V_WGT               :=      V_JSON.get_string('WGT');
        V_CORE              :=      V_JSON.get_string('CORE');
        V_BS_WGT            :=      V_JSON.get_string('BS_WGT');
        V_PACKTYPE          :=      V_JSON.get_string('PACKTYPE');
        V_CONTYPE           :=      V_JSON.get_string('CONTYPE');
        V_WLEN              :=      V_JSON.get_string('WLEN');
        V_VLEN              :=      V_JSON.get_string('VLEN');
        V_WIDTH             :=      V_JSON.get_string('WIDTH');
        V_VBELN             :=      V_JSON.get_string('VBELN');
        V_POSNR             :=      V_JSON.get_string('POSNR');
        V_KUNNR             :=      V_JSON.get_string('KUNNR');
        V_MRG_YN            :=      V_JSON.get_string('MRG_YN');
        V_WRK_CLASS         :=      V_JSON.get_string('WRK_CLASS');
        V_WRK_SHIFT         :=      V_JSON.get_string('WRK_SHIFT');      

        SELECT count(1) INTO V_CNT 
          FROM TX_BASE_INIT
         WHERE IND_BCD = V_IND_BCD;
    
        IF V_CNT > 0 THEN
            UPDATE TX_BASE_INIT
               SET
                 WERKS      		=  		   V_WERKS      				--플랜트       	  
                ,MACH_CD            =          V_MACH_CD    				--설비코드          
                ,STOR_LOC_CD        =          V_STOR_LOC_CD				--저장위치          
                ,LOC_CD             =          V_LOC_CD     				--로케이션          
                ,MATNR              =          V_MATNR      				--자재코드          
                ,LOT_NO             =          V_LOT_NO     				--LOT번호                
                ,ORDER_NO           =          V_ORDER_NO   				--오더번호          
                ,MACHINE            =          V_MACHINE    				--생산호기          
                ,PROC_CD            =          V_PROC_CD    				--공정            
                ,PRD_DT             =          V_PRD_DT     				--생산일자          
                ,PRFM_DT            =          V_PRFM_DT    				--제조일자          
                ,DSTBT_DDLIN        =          V_DSTBT_DDLIN				--유통기간          
                ,PCODE              =          V_PCODE      				--지종            
                ,UNIT               =          V_UNIT       				--단위            
                ,ROLLCNT            =          V_ROLLCNT    				--실적_권치수        
                ,PCNT               =          V_PCNT       				--실적_연수_REAM    
                ,SCNT               =          V_SCNT       				--실적_속당매수       
                ,MCNT               =          V_MCNT       				--실적_속수         
                ,WGT                =          V_WGT        				--실적_중량         
                ,CORE               =          V_CORE       				--지관            
                ,BS_WGT             =          V_BS_WGT     				--평량            
                ,PACKTYPE           =          V_PACKTYPE   				--포장타입          
                ,CONTYPE            =          V_CONTYPE    				--컨테이너유형        
                ,WLEN               =          V_WLEN       				--가로길이          
                ,VLEN               =          V_VLEN       				--세로길이          
                ,WIDTH              =          V_WIDTH      				--지폭            
                ,VBELN              =          V_VBELN      				--판매문서번호        
                ,POSNR              =          V_POSNR      				--판매문서항목번호      
                ,KUNNR              =          V_KUNNR      				--판매처_MTO       
                ,MRG_YN             =          V_MRG_YN     				--라벨병합여부        
                ,WRK_CLASS          =          V_WRK_CLASS  				--작업반           
                ,WRK_SHIFT          =          V_WRK_SHIFT  				--작업조  
                ,UPD_DT             =          sysdate              --수정일자          
              WHERE IND_BCD = V_IND_BCD;        
        ELSE
            INSERT INTO TX_BASE_INIT(
                                     WERKS      									--플랜트       	  
                                    ,MACH_CD                      --설비코드          
                                    ,STOR_LOC_CD                  --저장위치          
                                    ,LOC_CD                       --로케이션          
                                    ,MATNR                        --자재코드          
                                    ,LOT_NO                       --LOT번호         
                                    ,IND_BCD                      --개별바코드         
                                    ,ORDER_NO                     --오더번호          
                                    ,MACHINE                      --생산호기          
                                    ,PROC_CD                      --공정            
                                    ,PRD_DT                       --생산일자          
                                    ,PRFM_DT                      --제조일자          
                                    ,DSTBT_DDLIN                  --유통기간          
                                    ,PCODE                        --지종            
                                    ,UNIT                         --단위            
                                    ,ROLLCNT                      --실적_권치수        
                                    ,PCNT                         --실적_연수_REAM    
                                    ,SCNT                         --실적_속당매수       
                                    ,MCNT                         --실적_속수         
                                    ,WGT                          --실적_중량         
                                    ,CORE                         --지관            
                                    ,BS_WGT                       --평량            
                                    ,PACKTYPE                     --포장타입          
                                    ,CONTYPE                      --컨테이너유형        
                                    ,WLEN                         --가로길이          
                                    ,VLEN                         --세로길이          
                                    ,WIDTH                        --지폭            
                                    ,VBELN                        --판매문서번호        
                                    ,POSNR                        --판매문서항목번호      
                                    ,KUNNR                        --판매처_MTO       
                                    ,MRG_YN                       --라벨병합여부        
                                    ,WRK_CLASS                    --작업반           
                                    ,WRK_SHIFT                    --작업조  
                                    ,INS_DT                       --등록일자
                                    ,IF_YN                        --상태
                                    ,IF_MSG                       --메시지
                            )VALUES(
                                     V_WERKS      								--플랜트       	  
                                    ,V_MACH_CD                    --설비코드          
                                    ,V_STOR_LOC_CD                --저장위치          
                                    ,V_LOC_CD                     --로케이션          
                                    ,V_MATNR                      --자재코드          
                                    ,V_LOT_NO                     --LOT번호         
                                    ,V_IND_BCD                    --개별바코드         
                                    ,V_ORDER_NO                   --오더번호          
                                    ,V_MACHINE                    --생산호기          
                                    ,V_PROC_CD                    --공정            
                                    ,V_PRD_DT                     --생산일자          
                                    ,V_PRFM_DT                    --제조일자          
                                    ,V_DSTBT_DDLIN                --유통기간          
                                    ,V_PCODE                      --지종            
                                    ,V_UNIT                       --단위            
                                    ,V_ROLLCNT                    --실적_권치수        
                                    ,V_PCNT                       --실적_연수_REAM    
                                    ,V_SCNT                       --실적_속당매수       
                                    ,V_MCNT                       --실적_속수         
                                    ,V_WGT                        --실적_중량         
                                    ,V_CORE                       --지관            
                                    ,V_BS_WGT                     --평량            
                                    ,V_PACKTYPE                   --포장타입          
                                    ,V_CONTYPE                    --컨테이너유형        
                                    ,V_WLEN                       --가로길이          
                                    ,V_VLEN                       --세로길이          
                                    ,V_WIDTH                      --지폭            
                                    ,V_VBELN                      --판매문서번호        
                                    ,V_POSNR                      --판매문서항목번호      
                                    ,V_KUNNR                      --판매처_MTO       
                                    ,V_MRG_YN                     --라벨병합여부        
                                    ,V_WRK_CLASS                  --작업반           
                                    ,V_WRK_SHIFT                  --작업조 
                                    ,sysdate                      --등록일자
                                    ,'N'                           --처리완료
                                    ,null                         --메시지
                                  );    
        END IF;
	END IF;

	P_SUCCESS := 'Y';
    COMMIT;

--	EXCEPTION
--    WHEN E_EXCEPTION_USER THEN
--
--    -- 에러 내역 SET
--    P_SUCCESS           := 'N';
--    
--    --에러메시지는 사용자에러 호출 위치에서 지정해야 함.
--    --E_SQL_ERR_CD        := SQLCODE;
--		--E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';        
--
--		ROLLBACK;
--		SP_PROC_ERROR(V_PLT_CD, V_PRG_NM, E_SQL_ERR_CD, E_SQL_ERR_MSG, V_SESS_USER_ID);
--		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);		
--
--	WHEN OTHERS THEN
--		P_SUCCESS			      := 'N';
--    E_SQL_ERR_CD        := SQLCODE;
--		E_SQL_ERR_MSG       := 'EXCEPTION OTHER ERROR. [' || SUBSTR(SQLERRM,1,500) || ']';
--
--		ROLLBACK;
--		RAISE_APPLICATION_ERROR(E_SQL_ERR_CD, E_SQL_ERR_MSG);
END;

/
