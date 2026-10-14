
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH_GET_IFR_SYNC_CA_BAK" 
IS

/*==============================================================================
 * PROGRAM ID    : 인터페이스
 * PROGRAM NAME  : 생산오더 수신
 * VERSION       : 1.0.0
 * DESCRIPTION   : 생산오더 수신
 *                 
 * AUTHOR NAME   : 강현주
 * CREATE DATE   : 2022/07/29
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}	<생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}		<생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}			<생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술}	<생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/07/29    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        인터페이스설계서(총괄표) 참조
 *=============================================================================*/

----------------------------------------------------[작업지시번호 생성규칙]----------
--22-06-16 아래와 같이 작업지시 생성시 구분자로 활용하는것으로 결정 함.
--화장지 합지 : AA
--화장지 가공 : RA
--생리대     : RB
--기저귀     : RC
--
--점보롤 : JA
--밀롤 : MA
--재단 : CA
--포장 : PA
--예외생산: ?
---------------------------------------------------------------------------------
  o_msg_CODE    VARCHAR2 (10);
  o_msg_MSG     VARCHAR2 (4000);
  V_CNT         NUMBER;
  

/* ------- TB_IFR020 : 생산오더-재단  Begin ------------------------------ */
CURSOR  cur_ifr020_ca IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  ZCOR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM  ( SELECT IF_IFR_NO ,
                 AUFNR ,
                 ZCOR ,
                 IF_MES_ID ,
                 IF_MES_KEY ,
                 ROW_NUMBER() OVER ( PARTITION BY AUFNR  ORDER BY IF_IFR_NO DESC ) AS ROWNUMBER
            FROM TB_IFR020
           WHERE IF_STATUS IN ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
         ) 
  WHERE ROWNUMBER = 1 
  ORDER BY  IF_IFR_NO ;
  
  
/* ------- TB_IFR020 : 생산오더-재단 End --------------------------------- */

/* ------- TB_IFR020 : 생산오더-재단  Begin ------------------------->22-08-31 재단출고여부'X'일때 WCS로 넘기는 S/P통합함. */
PROCEDURE sp_ifr020_ca (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                         ,i_AUFNR          IN   VARCHAR2
                         ,i_ZCOR           IN   VARCHAR2                      
                         ,o_msg_CODE       OUT  VARCHAR2
                         ,o_msg_MSG        OUT  VARCHAR2  ) IS

  V_CNT           NUMBER          := 0;       -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;       -- 카운트(작업지시BOM존재여부)
  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  
  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;       -- 작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..) 
  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG
  V_DOC_NO        VARCHAR2(50)    := '';      -- MES문서번호  
  V_DOC_SEQ       NUMBER          := 1;       -- MES문서순번  
  V_FRAUFNR       VARCHAR2(50)    := '';      -- WCS로 넘기기 위한 이전오더번호 
  V_MILLROLL_BAR  VARCHAR2(50)    := '';      -- WCS로 넘기기 위한 밀롤바코드 
  
BEGIN

    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_IFR020
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO ;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_SCH008
      SET DLFL = V_DLFL
      WHERE AUFNR = i_AUFNR ;

      UPDATE TB_SCH017
      SET USE_YN = 'N'
      WHERE ORDER_NO = i_AUFNR ;             

      UPDATE  TB_IFR020
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO ;

      o_msg_MSG  := 'TB_IFR020, 생산오더-재단 삭제 수신되었습니다.2' ;
      o_msg_code := '0' ;
      RETURN ;
    END IF ;


    --재단출고여부 'X'이면 WCS로 I/F 한다.(sp_ifr020_X 분리된것을 여기에 통합함) 22-08-31 
    --2022-10-06 현재 당분간 일단보류 처리 함.(생산오더 수신 안정화 될때까지....)
/*    
    IF i_ZCOR = 'X' THEN
      V_DOC_NO := FN_GET_MDOCNO('M','IFWC006');
      
      SELECT NVL(FRAUFNR,'@') INTO V_FRAUFNR
      FROM TB_IFR020
      WHERE IF_IFR_NO =  i_IF_IFR_NO;
      
      IF  V_FRAUFNR = '@' THEN
          o_msg_MSG  := 'TB_IFR020, 이전오더번호가 없습니다.';
          o_msg_code := '-1' ;
          DBMS_OUTPUT.PUT_LINE (o_msg_msg );
     --     ROLLBACK;

          UPDATE  TB_IFR020
          SET     IF_STATUS   =  'E'               --  I/F상태, N:신규, S:성공, E:오류              
                , IF_SET_DATE =  sysdate            --  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                , IF_ERR_MESS =  o_msg_MSG          --  데이터 처리 결과 Message(Oracle)              
          WHERE  IF_IFR_NO =  i_IF_IFR_NO;    
          
          RETURN;      
      END IF;
      
      -----------------------------------------------------------------------------------------------------------------------
      --조회하는 내용이 한건도 조회 안될때 아래와 같이 처리해야 함. KHJ 22-09-19
      --다른방법1:데이타 존재여부를 V_CNT로 판단을 하고 존해했을때 변수에 넣는 방법으로 할수도 있다.(★)
      --다른방법2:아래와 같이 BEGIN~END문을 이용 할수도 있다.(★)
      --              BEGIN
      --               ~      
      --               EXCEPTION
      --                  WHEN NO_DATA_FOUND THEN      
      --               END                  
      -----------------------------------------------------------------------------------------------------------------------      
      SELECT NVL((SELECT IND_BCD 
                  FROM TB_INV001 
                  WHERE (ORDER_NO = V_FRAUFNR or LOT_NO = V_FRAUFNR) 
                  AND STCK_QTY > 0 
                  AND ROWNUM=1),'@') INTO V_MILLROLL_BAR 
      FROM DUAL;
      
      IF  V_MILLROLL_BAR = '@' THEN
          o_msg_MSG  :=  'TB_IFR020, WCS를 위한 밀롤바코드번호를 찾지 못했습니다.';
          o_msg_code := '-1' ;
          DBMS_OUTPUT.PUT_LINE (o_msg_msg );
    --      ROLLBACK;

          UPDATE  TB_IFR020
          SET     IF_STATUS   =  'E'                --  I/F상태, N:신규, S:성공, E:오류              
                , IF_SET_DATE =  sysdate            --  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                , IF_ERR_MESS =  o_msg_MSG          --  데이터 처리 결과 Message(Oracle)             
          WHERE  IF_IFR_NO =  i_IF_IFR_NO;    
          
          RETURN;      
      END IF;      

      INSERT INTO TB_IFSWC006(
         DOC_NO     			   --문서번호                                         
        ,DOC_NOSEQ                 --문서번호 순번   
        ,BARCODE                   --밀롤바코드
        ,CT_LOT_ID
        ,WRKORD                    --ERP 생산오더번호                                 
        ,PLNT_CD                   --플랜트                                           
        ,WORK_DT                   --생산 계획일 (YYYYMMDD)                           
        ,MCHN_CD                   --투입할 Cutter 호기(PM3)                          
        ,REMARK5                   --비고5                                            
        ,REMARK6                   --비고6                                            
        ,SPECIAL_NO                --ERP 특별재고번호                                 
        ,REMARK8                   --비고8                                            
        ,REMARK1                   --비고1                                            
        ,REMARK2                   --비고2                                            
        ,LOT_ID                    --MR LOTID                                         
        ,CLASS                     --반                                               
        ,MATERIAL_NO               --ERP 자재코드 (커터 자재코드)                     
        ,LENGTH                    --권치수, 길이(M)                                  
        ,WEIGHT                    --중량(KG)   
        ,WORK_DRCT                 --생산 작업 지시사항
        ,WORK_TIME                 --생산 계획 시간 (HHMM)
        ,WORK_SEQ                  --생산 계획 순번
        ,AUFNR                     --오더번호
        ,IF_STATUS                 --WCS 결과값 Return( N:대기,S:성공, E:오류 )       
        ,IF_GET_DATE               --MES 등록일시                                     
        ,IF_SET_DATE               --WCS 전송일시                                     
        ,IF_ERR_MESS               --WCS 결과 메시지                                  
        ,IF_MES_KEY                --MES Inserface Key
      )
      SELECT 
         V_DOC_NO
        ,V_DOC_SEQ
        ,V_MILLROLL_BAR            --밀롤바코드
        ,'*'
        ,AUFNR                     --ERP 생산오더번호                       
        ,WERKS                     --플랜트                              
        ,BUDAT                     --생산 계획일 (YYYYMMDD)                
        ,MACHINE                   --투입할 Cutter 호기(PM3)               
        ,WLEN                      --비고5                              
        ,VLEN                      --비고6                              
        ,VBELN                     --ERP 특별재고번호                       
        ,PACKTYPE                  --비고8-포장타입                              
        ,KUNNR                     --비고1                              
        ,NAME1                     --비고2                              
        ,MRLOT                     --MR LOTID                         
        ,WORKGROUP                 --반                                
        ,MMATNR                    --ERP 자재코드 (커터 자재코드)               
        ,MROLLCNT                  --권치수, 길이(M)                       
        ,MBRGEW                    --중량(KG)  
        ,REMARK                    --생산 작업 지시사항
        ,PTIM                      --생산 계획 시간 (HHMM)
        ,PSEQ                      --생산 계획 순번
        ,AUFNR                     --오더번호
        ,'N'
        ,sysdate
        ,null
        ,null
        ,null
      FROM TB_IFR020 
      WHERE IF_IFR_NO = i_IF_IFR_NO;        
    END IF; 
*/  


    SELECT COUNT(1) INTO V_CNT FROM TB_SCH017 WHERE ORDER_NO = i_AUFNR; 

    IF V_CNT > 0 THEN    
      UPDATE TB_SCH017
      SET(        
            PRE_ORDER_NO         																--이전 오더 번호
           ,WERKS                																--플랜트코드
           ,PRD_REQ_DT           																--생산요청일자
           ,ORDER_DIV            																--오더유형
           ,ORDER_DIV_NM         																--오더유형 텍스트
           ,MACHINE              																--FROM 생산호기
           ,MACHINE_NM           																--FROM 생산 호기명
           ,TO_MACHINE           																--TO 생산호기
           ,TO_MACHINE_NM        																--TO 생산 호기명
           ,MATNR                																--자재 코드
           ,PCODE                																--지종
           ,BS_WGT               																--평량
           ,VLEN                 																--세로길
           ,WLEN                 																--가로길
           ,PKCNT                																--폭수
           ,WRK_ORDR_QTY         																--생산지시량
           ,TOT_WGT              																--총중량
           ,UNIT                 																--단위
           ,PLT_PER_CNT          																--팔레트당연수
           ,IN_PER_CNT           																--속당매수
           ,DBL_FLAG             																--쌍팔레트
           ,VBELN                																--판매문서
           ,POSNR                																--판매문서 항목번호
           ,SAUART_DIV           																--판매문서 유형
           ,SAUART_NM            																--판매 문서 오더 유형 텍스트
           ,OVBELN               																--판매문서
           ,OPOSNR               																--판매문서 항목번호
           ,OAUART_DIV           																--판매문서 유형
           ,OAUART_NM            																--판매 문서 오더 유형 텍스트
           ,CUTTER               																--카터
           ,BOM_NO               																--BOM Num
           ,ATN_BOM_NO           																--대체Bom
           ,PRT_MATNR_QTY        																--모품목기준수량
           ,PRT_MATNR_UNIT       																--모품목기준수량 단위
           ,DLFL                 																--오더 삭제 지시자
           ,ZCOR                 																--재단출고 오더 여부
           ,ORDER_RMK            																--비고
           ,ROUTE                																--항차
           ,KUNNR                																--판매처
           ,KUNNRT               																--판매처명
           ,MAUFNR				  		 																--M/R LOT Number
           ,PTIM                 																--생산 계획 시간 (HHMM)
           ,PSEQ                 																--IS-M: Production Sequence
           ,WORKGROUP            																--반
           ,MMATNR               																--자재 번호
           ,MROLLCNT             																--M/R 권치수
           ,MBRGEW               																--M/ROLL 중량
           ,MGEWEI               																--중량 단위
           ,CORESIZE             																--밀롤 지관 인치(SIZE)
           ,PACKTYPE             																--포장타입
           ,MWIDTH_INPUT         																--M/R 지폭
           ,MRCNT                																--폭수
           ,MCNT                 																--수량
           ,SCNT                 																--수량
           ,CONTYPE              																--컨테이너유형
           ,SIZE_VAL             																--규격   					 
           ,UPDDATE              																--수정일시
           ,UPDID                																--수정자ID
           ,USE_YN               																--사용여부(Y:사용 N:미사용)                         
      )=(SELECT                         										
            FRAUFNR                        											--이전 오더 번호
           ,WERKS                          											--플랜트코드
           ,BUDAT                          											--생산요청일자
           ,AUART                          											--오더유형
           ,AUARTXT                        											--오더유형 텍스트
           ,MACHINE                        											--FROM 생산호기
           ,MACHINETXT                     											--FROM 생산 호기명
           ,TOMACHINE                      											--TO 생산호기
           ,TOMACHINETXT                   											--TO 생산 호기명
           ,CMATNR                         											--자재 코드
           ,PCODE                          											--지종
           ,WEIGHT                         											--평량
           ,VLEN                           											--세로길
           ,WLEN                           											--가로길
           ,CTCNT                          											--폭수
           ,CNT                            											--생산지시량
           ,CGEWEW                         											--총중량
           ,CGEWEI                         											--단위
           ,ZZATT1                         											--팔레트당연수
           ,ZZATT2                         											--속당매수
           ,DOUBLEFLAG                     											--쌍팔레트
           ,VBELN                          											--판매문서
           ,POSNR                          											--판매문서 항목번호
           ,SAUART                         											--판매문서 유형
           ,SAUARTXT                       											--판매 문서 오더 유형 텍스트
           ,OVBELN                         											--판매문서
           ,OPOSNR                         											--판매문서 항목번호
           ,OAUART                         											--판매문서 유형
           ,OAUARTXT                       											--판매 문서 오더 유형 텍스트
           ,CUTTER                         											--카터
           ,STLNR                          											--BOM Num
           ,STLAL                          											--대체Bom
           ,BMENG                          											--모품목기준수량
           ,BMEIN                          											--모품목기준수량 단위
           ,DLFL                           											--오더 삭제 지시자
           ,ZCOR                           											--재단출고 오더 여부
           ,REMARK                         											                        --비고
           ,ROUTE                          											--항차
           ,KUNNR                          											--판매처
           ,NAME1                          											--판매처명
           ,MAUFNR     					  															--M/R LOT Number
           ,PTIM                           											--생산 계획 시간 (HHMM)
           ,PSEQ                           											--IS-M: Production Sequence
           ,WORKGROUP                      											--반
           ,MMATNR                         											--자재 번호
           ,MROLLCNT                       											--M/R 권치수
           ,MBRGEW                         											--M/ROLL 중량
           ,MGEWEI                         											--중량 단위
           ,CORESIZE                       											--밀롤 지관 인치(SIZE)
           ,PACKTYPE                       											--포장타입
           ,MWIDTH_INPUT                   											--M/R 지폭
           ,MRCNT                          											--폭수
           ,MCNT                           											--수량
           ,SCNT                           											--수량
           ,CONTYPE                        											--컨테이너유형
           ,SIZE_VAL                       											--규격   					 
           ,sysdate                               							--수정일시
           ,'SP_SCH_SYNC_PA'                           						--수정자ID
           ,case when DLFL = 'Y' then 'N'  							          
                 when DLFL = 'N' then 'Y'  							
            end                                  								--사용여부(Y:사용 N:미사용)                                                           
         FROM TB_IFR020 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE  ORDER_NO   = i_AUFNR;       
    ELSE    
      INSERT INTO TB_SCH017(  
           WRK_ORDR_NO                              					--작업지시번호-->작업지시 생성자 사용 WO + R  
          ,WRK_ORDR_SEQNO                           					--작업지시순번
          ,WRK_SEQNO                                					--작업순서
          ,ORDR_GEN_DT                              					--지시생성일자
          ,ORDER_NO																					  --오더번호
          ,PRE_ORDER_NO          														--이전 오더 번호
          ,WERKS                 														--플랜트코드
          ,PRD_REQ_DT            														--생산요청일자
          ,ORDER_DIV             														--오더유형
          ,ORDER_DIV_NM          														--오더유형 텍스트
          ,MACHINE               														--FROM 생산호기
          ,MACHINE_NM            														--FROM 생산 호기명
          ,TO_MACHINE            														--TO 생산호기
          ,TO_MACHINE_NM         														--TO 생산 호기명
          ,MATNR                 														--자재 코드
          ,PCODE                 														--지종
          ,BS_WGT                														--평량
          ,VLEN                  														--세로길
          ,WLEN                  														--가로길
          ,PKCNT                 														--폭수
          ,WRK_ORDR_QTY          														--생산지시량
          ,TOT_WGT               														--총중량
          ,UNIT                  														--단위
          ,PLT_PER_CNT           														--팔레트당연수
          ,IN_PER_CNT            														--속당매수
          ,DBL_FLAG              														--쌍팔레트
          ,VBELN                 														--판매문서
          ,POSNR                 														--판매문서 항목번호
          ,SAUART_DIV            														--판매문서 유형
          ,SAUART_NM             														--판매 문서 오더 유형 텍스트
          ,OVBELN                														--판매문서
          ,OPOSNR                														--판매문서 항목번호
          ,OAUART_DIV            														--판매문서 유형
          ,OAUART_NM             														--판매 문서 오더 유형 텍스트
          ,CUTTER                														--카터
          ,BOM_NO                														--BOM Num
          ,ATN_BOM_NO            														--대체Bom
          ,PRT_MATNR_QTY         														--모품목기준수량
          ,PRT_MATNR_UNIT        														--모품목기준수량 단위
          ,DLFL                  														--오더 삭제 지시자
          ,ZCOR                  														--재단출고 오더 여부
          ,ORDER_RMK                                					--비고
          ,ROUTE                                    					--항차
          ,KUNNR                                    					--판매처
          ,KUNNRT                                   					--판매처명
          ,MAUFNR								  													--M/R LOT Numb
          ,PTIM                                     					--생산 계획 시간
          ,PSEQ                                     					--IS-M: Produc
          ,WORKGROUP                                					--반
          ,MMATNR                                   					--자재 번호
          ,MROLLCNT                                 					--M/R 권치수
          ,MBRGEW                                   					--M/ROLL 중량
          ,MGEWEI                                   					--중량 단위
          ,CORESIZE                                 					--밀롤 지관 인치(
          ,PACKTYPE                                 					--포장타입
          ,MAN_CUT_YN                               					--수재단여부(6/14 무조건 N으로 처리함)
          ,MWIDTH_INPUT                             					--M/R 지폭
          ,MRCNT                                    					--폭수
          ,MCNT                                     					--수량
          ,SCNT                                     					--수량
          ,CONTYPE                                  					--컨테이너유형
          ,SIZE_VAL                                 					--규격
          ,COMP_YN                                  					--완료여부
          ,REGDATE                                  					--등록일시
          ,REGID                                    					--등록자ID
          ,UPDDATE                                  					--수정일시
          ,UPDID                                    					--수정자ID
          ,USE_YN                                   					--사용여부(Y:사용 N:미사용)              
      )                                           					                              
      SELECT                                      					                              
           V_WO_NO														    							--작업지시번호
          ,1                                                   --작업지시순번
          ,SUBSTR(V_WO_NO,-4)                                  --작업순서(작업지시번호,-4)
          ,TO_CHAR(sysdate,'YYYYMMDD')                         --지시생성일자
          ,AUFNR     																		      --오더번호
          ,FRAUFNR                         										--이전 오더 번호
          ,WERKS                          											--플랜트코드
          ,BUDAT                          											--생산요청일자
          ,AUART                          											--오더유형
          ,AUARTXT                        											--오더유형 텍스트
          ,MACHINE                        											--FROM 생산호기
          ,MACHINETXT                     											--FROM 생산 호기명
          ,TOMACHINE                      											--TO 생산호기
          ,TOMACHINETXT                   											--TO 생산 호기명
          ,CMATNR                         											--자재 코드
          ,PCODE                          											--지종
          ,WEIGHT                         											--평량
          ,VLEN                           											--세로길
          ,WLEN                           											--가로길
          ,CTCNT                          											--폭수
          ,CNT                            											--생산지시량
          ,CGEWEW                         											--총중량
          ,CGEWEI                         											--단위
          ,ZZATT1                         											--팔레트당연수
          ,ZZATT2                         											--속당매수
          ,DOUBLEFLAG                     											--쌍팔레트
          ,VBELN                          											--판매문서
          ,POSNR                          											--판매문서 항목번호
          ,SAUART                         											--판매문서 유형
          ,SAUARTXT                       											--판매 문서 오더 유형 텍스트
          ,OVBELN                         											--판매문서
          ,OPOSNR                         											--판매문서 항목번호
          ,OAUART                         											--판매문서 유형
          ,OAUARTXT                       											--판매 문서 오더 유형 텍스트
          ,CUTTER                         											--카터
          ,STLNR                          											--BOM Num
          ,STLAL                          											--대체Bom
          ,BMENG                          											--모품목기준수량
          ,BMEIN                          											--모품목기준수량 단위
          ,DLFL                           											--오더 삭제 지시자
          ,ZCOR                           											--재단출고 오더 여부
          ,REMARK                                       				                                        --오더비고
          ,ROUTE                                        				--항차
          ,KUNNR                                        				--판매처 
          ,NAME1                                        				--판매처명
          ,MAUFNR     																					--M/R LOT Number
          ,PTIM                           											--생산 계획 시간 (HHMM)
          ,PSEQ                           											--IS-M: Production Sequence
          ,WORKGROUP                      											--반
          ,MMATNR                         											--자재 번호
          ,MROLLCNT                       											--M/R 권치수
          ,MBRGEW                         											--M/ROLL 중량
          ,MGEWEI                         											--중량 단위
          ,CORESIZE                       											--밀롤 지관 인치(SIZE)
          ,PACKTYPE                       											--포장타입
          ,'N'                                                 --수재단여부(6/14 무조건 N으로 처리함)
          ,MWIDTH_INPUT                                				--M/R 지폭
          ,MRCNT                                       				--폭수
          ,MCNT                                        				--수량
          ,SCNT                                        				--수량
          ,CONTYPE                                     				--컨테이너유형
          ,SIZE_VAL                                    				--규격
          ,'N'                                                 --완료여부
          ,sysdate                                             --등록일시
          ,'SP_SCH_SYNC_CA'                                         --등록자ID
          ,null                                                --수정일시
          ,null                                                --수정자ID 
          ,case when DLFL = 'X' then 'N'
               else 'Y'
          end                                                 --사용여부(Y:사용 N:미사용)                                      
      FROM  TB_IFR020
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;   
    
    

    --========================================
    --KHJ추가 2022-05-02:작업지시-재단
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(1) INTO V_CNT
    FROM TB_SCH017
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT BUDAT INTO V_WO_DT
      FROM TB_IFR020
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('WOCA',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------

    MERGE
        INTO  TB_SCH017 SCH017
        USING TB_IFR020 IFR020
           ON ( SCH017.ORDER_NO   =  IFR020.AUFNR
           AND  IFR020.AUFNR      =  i_AUFNR 
           AND  IFR020.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN    
        UPDATE SET
              SCH017.PRE_ORDER_NO         = IFR020.FRAUFNR                        --이전 오더 번호
             ,SCH017.WERKS                = IFR020.WERKS                          --플랜트코드
             ,SCH017.PRD_REQ_DT           = IFR020.BUDAT                          --생산요청일자
             ,SCH017.ORDER_DIV            = IFR020.AUART                          --오더유형
             ,SCH017.ORDER_DIV_NM         = IFR020.AUARTXT                        --오더유형 텍스트
             ,SCH017.MACHINE              = IFR020.MACHINE                        --FROM 생산호기
             ,SCH017.MACHINE_NM           = IFR020.MACHINETXT                     --FROM 생산 호기명
             ,SCH017.TO_MACHINE           = IFR020.TOMACHINE                      --TO 생산호기
             ,SCH017.TO_MACHINE_NM        = IFR020.TOMACHINETXT                   --TO 생산 호기명
             ,SCH017.MATNR                = IFR020.CMATNR                         --자재 코드
             ,SCH017.PCODE                = IFR020.PCODE                          --지종
             ,SCH017.BS_WGT               = IFR020.WEIGHT                         --평량
             ,SCH017.VLEN                 = IFR020.VLEN                           --세로길
             ,SCH017.WLEN                 = IFR020.WLEN                           --가로길
             ,SCH017.PKCNT                = IFR020.CTCNT                          --폭수
             ,SCH017.WRK_ORDR_QTY         = IFR020.CNT                            --생산지시량
             ,SCH017.TOT_WGT              = IFR020.CGEWEW                         --총중량
             ,SCH017.UNIT                 = IFR020.CGEWEI                         --단위
             ,SCH017.PLT_PER_CNT          = IFR020.ZZATT1                         --팔레트당연수
             ,SCH017.IN_PER_CNT           = IFR020.ZZATT2                         --속당매수
             ,SCH017.DBL_FLAG             = IFR020.DOUBLEFLAG                     --쌍팔레트
             ,SCH017.VBELN                = IFR020.VBELN                          --판매문서
             ,SCH017.POSNR                = IFR020.POSNR                          --판매문서 항목번호
             ,SCH017.SAUART_DIV           = IFR020.SAUART                         --판매문서 유형
             ,SCH017.SAUART_NM            = IFR020.SAUARTXT                       --판매 문서 오더 유형 텍스트
             ,SCH017.OVBELN               = IFR020.OVBELN                         --판매문서
             ,SCH017.OPOSNR               = IFR020.OPOSNR                         --판매문서 항목번호
             ,SCH017.OAUART_DIV           = IFR020.OAUART                         --판매문서 유형
             ,SCH017.OAUART_NM            = IFR020.OAUARTXT                       --판매 문서 오더 유형 텍스트
             ,SCH017.CUTTER               = IFR020.CUTTER                         --카터
             ,SCH017.BOM_NO               = IFR020.STLNR                          --BOM Num
             ,SCH017.ATN_BOM_NO           = IFR020.STLAL                          --대체Bom
             ,SCH017.PRT_MATNR_QTY        = IFR020.BMENG                          --모품목기준수량
             ,SCH017.PRT_MATNR_UNIT       = IFR020.BMEIN                          --모품목기준수량 단위
             ,SCH017.DLFL                 = IFR020.DLFL                           --오더 삭제 지시자
             ,SCH017.ZCOR                 = IFR020.ZCOR                           --재단출고 오더 여부
             ,SCH017.ORDER_RMK            = IFR020.REMARK                         --비고
             ,SCH017.ROUTE                = IFR020.ROUTE                          --항차
             ,SCH017.KUNNR                = IFR020.KUNNR                          --판매처
             ,SCH017.KUNNRT               = IFR020.NAME1                          --판매처명
             ,SCH017.MAUFNR				  = IFR020.MAUFNR     					  --M/R LOT Number
             ,SCH017.PTIM                 = IFR020.PTIM                           --생산 계획 시간 (HHMM)
             ,SCH017.PSEQ                 = IFR020.PSEQ                           --IS-M: Production Sequence
             ,SCH017.WORKGROUP            = IFR020.WORKGROUP                      --반
             ,SCH017.MMATNR               = IFR020.MMATNR                         --자재 번호
             ,SCH017.MROLLCNT             = IFR020.MROLLCNT                       --M/R 권치수
             ,SCH017.MBRGEW               = IFR020.MBRGEW                         --M/ROLL 중량
             ,SCH017.MGEWEI               = IFR020.MGEWEI                         --중량 단위
             ,SCH017.CORESIZE             = IFR020.CORESIZE                       --밀롤 지관 인치(SIZE)
             ,SCH017.PACKTYPE             = IFR020.PACKTYPE                       --포장타입
             ,SCH017.MWIDTH_INPUT         = IFR020.MWIDTH_INPUT                   --M/R 지폭
             ,SCH017.MRCNT                = IFR020.MRCNT                          --폭수
             ,SCH017.MCNT                 = IFR020.MCNT                           --수량
             ,SCH017.SCNT                 = IFR020.SCNT                           --수량
             ,SCH017.CONTYPE              = IFR020.CONTYPE                        --컨테이너유형
             ,SCH017.SIZE_VAL             = IFR020.SIZE_VAL                       --규격   					 
             ,SCH017.UPDDATE              = sysdate                               --수정일시
             ,SCH017.UPDID                = 'sp_IFR020'                           --수정자ID
             ,SCH017.USE_YN               = case when IFR020.DLFL = 'Y' then 'N'            
                                                 when IFR020.DLFL = 'N' then 'Y'
                                            end                                  --사용여부(Y:사용 N:미사용)
       WHERE IFR020.IF_STATUS in ('N','E')                                     --I/F상태, N:신규, S:성공, E:오류
        AND  IFR020.AUFNR     =  i_AUFNR
        AND  IFR020.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
        INSERT (
              SCH017.WRK_ORDR_NO                                                --작업지시번호-->작업지시 생성자 사용 WO + R  
             ,SCH017.WRK_ORDR_SEQNO                                             --작업지시순번
             ,SCH017.WRK_SEQNO                                                  --작업순서
             ,SCH017.ORDR_GEN_DT                                                --지시생성일자
             ,SCH017.ORDER_NO													--오더번호
             ,SCH017.PRE_ORDER_NO          										--이전 오더 번호
             ,SCH017.WERKS                 										--플랜트코드
             ,SCH017.PRD_REQ_DT            										--생산요청일자
             ,SCH017.ORDER_DIV             										--오더유형
             ,SCH017.ORDER_DIV_NM          										--오더유형 텍스트
             ,SCH017.MACHINE               										--FROM 생산호기
             ,SCH017.MACHINE_NM            										--FROM 생산 호기명
             ,SCH017.TO_MACHINE            										--TO 생산호기
             ,SCH017.TO_MACHINE_NM         										--TO 생산 호기명
             ,SCH017.MATNR                 										--자재 코드
             ,SCH017.PCODE                 										--지종
             ,SCH017.BS_WGT                										--평량
             ,SCH017.VLEN                  										--세로길
             ,SCH017.WLEN                  										--가로길
             ,SCH017.PKCNT                 										--폭수
             ,SCH017.WRK_ORDR_QTY          										--생산지시량
             ,SCH017.TOT_WGT               										--총중량
             ,SCH017.UNIT                  										--단위
             ,SCH017.PLT_PER_CNT           										--팔레트당연수
             ,SCH017.IN_PER_CNT            										--속당매수
             ,SCH017.DBL_FLAG              										--쌍팔레트
             ,SCH017.VBELN                 										--판매문서
             ,SCH017.POSNR                 										--판매문서 항목번호
             ,SCH017.SAUART_DIV            										--판매문서 유형
             ,SCH017.SAUART_NM             										--판매 문서 오더 유형 텍스트
             ,SCH017.OVBELN                										--판매문서
             ,SCH017.OPOSNR                										--판매문서 항목번호
             ,SCH017.OAUART_DIV            										--판매문서 유형
             ,SCH017.OAUART_NM             										--판매 문서 오더 유형 텍스트
             ,SCH017.CUTTER                										--카터
             ,SCH017.BOM_NO                										--BOM Num
             ,SCH017.ATN_BOM_NO            										--대체Bom
             ,SCH017.PRT_MATNR_QTY         										--모품목기준수량
             ,SCH017.PRT_MATNR_UNIT        										--모품목기준수량 단위
             ,SCH017.DLFL                  										--오더 삭제 지시자
             ,SCH017.ZCOR                  										--재단출고 오더 여부
             ,SCH017.ORDER_RMK                                                  --비고
             ,SCH017.ROUTE                                                      --항차
             ,SCH017.KUNNR                                                      --판매처
             ,SCH017.KUNNRT                                                     --판매처명
             ,SCH017.MAUFNR								  						--M/R LOT Numb
             ,SCH017.PTIM                                       				--생산 계획 시간
             ,SCH017.PSEQ                                       				--IS-M: Produc
             ,SCH017.WORKGROUP                                  				--반
             ,SCH017.MMATNR                                     				--자재 번호
             ,SCH017.MROLLCNT                                   				--M/R 권치수
             ,SCH017.MBRGEW                                     				--M/ROLL 중량
             ,SCH017.MGEWEI                                     				--중량 단위
             ,SCH017.CORESIZE                                   				--밀롤 지관 인치(
             ,SCH017.PACKTYPE                                   				--포장타입
             ,SCH017.MAN_CUT_YN                                                 --수재단여부(6/14 무조건 N으로 처리함)
             ,SCH017.MWIDTH_INPUT                                               --M/R 지폭
             ,SCH017.MRCNT                                                      --폭수
             ,SCH017.MCNT                                                       --수량
             ,SCH017.SCNT                                                       --수량
             ,SCH017.CONTYPE                                                    --컨테이너유형
             ,SCH017.SIZE_VAL                                                   --규격
             ,SCH017.COMP_YN                                                    --완료여부
             ,SCH017.REGDATE                                                    --등록일시
             ,SCH017.REGID                                                      --등록자ID
             ,SCH017.UPDDATE                                                    --수정일시
             ,SCH017.UPDID                                                      --수정자ID
             ,SCH017.USE_YN                                                     --사용여부(Y:사용 N:미사용)
        )VALUES(
              V_WO_NO														    --작업지시번호
             ,1                                                                 --작업지시순번
             ,SUBSTR(V_WO_NO,-4)                                                --작업순서(작업지시번호,-4)
             ,TO_CHAR(sysdate,'YYYYMMDD')                                       --지시생성일자
             ,IFR020.AUFNR     													--오더번호
             ,IFR020.FRAUFNR                         							--이전 오더 번호
             ,IFR020.WERKS                          							--플랜트코드
             ,IFR020.BUDAT                          							--생산요청일자
             ,IFR020.AUART                          							--오더유형
             ,IFR020.AUARTXT                        							--오더유형 텍스트
             ,IFR020.MACHINE                        							--FROM 생산호기
             ,IFR020.MACHINETXT                     							--FROM 생산 호기명
             ,IFR020.TOMACHINE                      							--TO 생산호기
             ,IFR020.TOMACHINETXT                   							--TO 생산 호기명
             ,IFR020.CMATNR                         							--자재 코드
             ,IFR020.PCODE                          							--지종
             ,IFR020.WEIGHT                         							--평량
             ,IFR020.VLEN                           							--세로길
             ,IFR020.WLEN                           							--가로길
             ,IFR020.CTCNT                          							--폭수
             ,IFR020.CNT                            							--생산지시량
             ,IFR020.CGEWEW                         							--총중량
             ,IFR020.CGEWEI                         							--단위
             ,IFR020.ZZATT1                         							--팔레트당연수
             ,IFR020.ZZATT2                         							--속당매수
             ,IFR020.DOUBLEFLAG                     							--쌍팔레트
             ,IFR020.VBELN                          							--판매문서
             ,IFR020.POSNR                          							--판매문서 항목번호
             ,IFR020.SAUART                         							--판매문서 유형
             ,IFR020.SAUARTXT                       							--판매 문서 오더 유형 텍스트
             ,IFR020.OVBELN                         							--판매문서
             ,IFR020.OPOSNR                         							--판매문서 항목번호
             ,IFR020.OAUART                         							--판매문서 유형
             ,IFR020.OAUARTXT                       							--판매 문서 오더 유형 텍스트
             ,IFR020.CUTTER                         							--카터
             ,IFR020.STLNR                          							--BOM Num
             ,IFR020.STLAL                          							--대체Bom
             ,IFR020.BMENG                          							--모품목기준수량
             ,IFR020.BMEIN                          							--모품목기준수량 단위
             ,IFR020.DLFL                           							--오더 삭제 지시자
             ,IFR020.ZCOR                           							--재단출고 오더 여부
             ,IFR020.REMARK                                                     --오더비고
             ,IFR020.ROUTE                                                      --항차
             ,IFR020.KUNNR                                                      --판매처 
             ,IFR020.NAME1                                                      --판매처명
             ,IFR020.MAUFNR     												--M/R LOT Number
             ,IFR020.PTIM                           							--생산 계획 시간 (HHMM)
             ,IFR020.PSEQ                           							--IS-M: Production Sequence
             ,IFR020.WORKGROUP                      							--반
             ,IFR020.MMATNR                         							--자재 번호
             ,IFR020.MROLLCNT                       							--M/R 권치수
             ,IFR020.MBRGEW                         							--M/ROLL 중량
             ,IFR020.MGEWEI                         							--중량 단위
             ,IFR020.CORESIZE                       							--밀롤 지관 인치(SIZE)
             ,IFR020.PACKTYPE                       							--포장타입
             ,'N'                                                               --수재단여부(6/14 무조건 N으로 처리함)
             , IFR020.MWIDTH_INPUT                                              --M/R 지폭
             , IFR020.MRCNT                                                     --폭수
             , IFR020.MCNT                                                      --수량
             , IFR020.SCNT                                                      --수량
             , IFR020.CONTYPE                                                   --컨테이너유형
             , IFR020.SIZE_VAL                                                  --규격
             ,'N'                                                               --완료여부
             ,sysdate                                                           --등록일시
             ,'sp_IFR020'                                                       --등록자ID
             ,null                                                              --수정일시
             ,null                                                              --수정자ID 
             ,case when IFR020.DLFL = 'X' then 'N'
                   else 'Y'
              end                                                               --사용여부(Y:사용 N:미사용)
        )
        WHERE IFR020.IF_STATUS IN ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
        AND   IFR020.AUFNR     =  i_AUFNR
        AND   IFR020.IF_IFR_NO =  i_IF_IFR_NO ; 

    --작업지시 생성되면 작업지시BOM을 구성한다. 
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_SCH017
    WHERE ORDER_NO = i_AUFNR;

    SELECT COUNT(ORDER_NO) INTO V_BOM_CNT 
    FROM TB_SCH020 
    WHERE WRK_ORDR_NO = V_WO_NO
    AND WRK_ORDR_SEQNO = V_WO_SEQ; 

    --작업지시BOM이 존재하지 않으면 생산BOM->작업지시BOM을 생성 한다.
    IF V_BOM_CNT = 0 THEN 
      INSERT INTO TB_SCH020 
      (      ORDER_NO                     --오더번호
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
            ,REGDATE                      --등록일자
            ,REGID                        --등록자
            ,UPDDATE                      --수정일자
            ,UPDID                        --수정자                   
      )
      SELECT AUFNR				          --오더번호
            ,POSNR				          --오더Item번호
            ,MATNR				          --자품목자재
            ,BDMNG				          --오더BOM 수량
            ,MEINS				          --오더BOM 수량단위
            ,LOT_NO                       --LOT번호            
            ,LGORT                        --저장위치
            ,case when XLOEK = 'X' then 'Y'
                  else 'N'
             end				          --삭제여부
            ,V_WERKS
            ,V_WO_NO
            ,1
            ,sysdate
            ,'sp_ifr020'
            ,null
            ,null
      FROM TB_SCH001          
     WHERE AUFNR = i_AUFNR ;
     
    END IF;

    UPDATE  TB_IFR020
    SET     IF_STATUS   = 'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE = sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS = o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')            /*  I/F상태, N:신규, S:성공, E:오류               */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO  ;

    o_msg_MSG  := 'TB_IFR020, 생산오더-재단가 수신되었습니다.2' ;
    o_msg_code := '0' ;

    EXCEPTION
      WHEN OTHERS THEN
        o_msg_MSG  :=  'TB_IFR020, 생산오더-재단 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
        o_msg_code      := '-1' ;
        DBMS_OUTPUT.PUT_LINE (o_msg_msg );
    --    ROLLBACK;

        UPDATE  TB_IFR020
        SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
              , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
              , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
        WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
        AND    AUFNR     =  i_AUFNR
        AND    IF_IFR_NO =  i_IF_IFR_NO  ;

END  sp_ifr020_ca ;
/* ------- TB_IFR020 : 생산오더-재단  End --------------------------- */

BEGIN
/* ------- TB_IFR020 : 생산오더-재단  Begin ------------------------- */

 --   DBMS_OUTPUT.PUT_LINE('MES_IF_120==>START'); 
    
    V_CNT := 1;

    FOR ifr020 IN cur_ifr020_ca LOOP

        sp_ifr020_ca(  ifr020.IF_IFR_NO
                     , ifr020.AUFNR
                     , ifr020.ZCOR
                     , o_msg_CODE
                     , o_msg_MSG
                    );

        
        IF o_msg_CODE <> '0' THEN
           ROLLBACK;
        ELSE
            COMMIT ;
        END IF;
        
        SP_IF_MIG_LOG ( 'SP_SCH_GET_IFR_SYNC_CA', o_msg_CODE, TO_CHAR(V_CNT)||':'||ifr020.IF_IFR_NO ||'/'||ifr020.AUFNR||' => ' ||o_msg_MSG );
        
   --     DBMS_OUTPUT.PUT_LINE(TO_CHAR(V_CNT)||':'||ifr020.IF_IFR_NO ||'/'||ifr020.AUFNR||' => ' ||o_msg_CODE) ;
        
        V_CNT := V_CNT + 1 ;

    END LOOP;

 ---   DBMS_OUTPUT.PUT_LINE('MES_IF_120==>END');

/* ------- TB_IFR020 : 생산오더-재단  End --------------------------- */

EXCEPTION
  WHEN OTHERS THEN
    o_msg_code := '-1' ;
    o_msg_msg  := 'Error,생산오더 수신 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
    
    SP_IF_MIG_LOG ( 'SP_SCH_GET_IFR_SYNC_CA', o_msg_code, o_msg_msg );
    
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    rollback ;

END SP_SCH_GET_IFR_SYNC_CA_BAK ;
/
