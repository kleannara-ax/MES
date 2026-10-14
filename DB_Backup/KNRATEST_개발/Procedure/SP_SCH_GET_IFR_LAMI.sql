--------------------------------------------------------
--  DDL for Procedure SP_SCH_GET_IFR_LAMI
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_SCH_GET_IFR_LAMI" (  i_IF_MES_ID        IN    VARCHAR2
                                                    ,i_IF_MES_KEY       IN    VARCHAR2
                                                    ,o_msg_CODE         OUT   VARCHAR2
                                                    ,o_msg_MSG          OUT   VARCHAR2
) is


/*==============================================================================
 * PROGRAM ID    : SP_SCH_GET_IFR_LAMI{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 라미네이팅 인쇄코팅 작업지시 저장{호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 라미네이팅 인쇄코팅 작업지시 저장한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 김수현{최초 작성자 명 기술}
 * CREATE DATE   : 2022/12/09 {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/12/08    1.0.0   김수현         Initial Version 
 *==============================================================================
 *  관련 테이블
 *       - [TB_LAMI_PC_IFR015] : (CRUD)SAP I/F TABLE                                
 *=============================================================================*/
/* ------- TB_LAMI_PC_IFR015 : 생산오더-라미네이팅 인쇄코팅  Begin ------------------------- */
CURSOR  cur_ifr015 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  AUFNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_LAMI_PC_IFR015
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
--  AND     ROWNUM <= 100
  ORDER  BY  IF_IFR_NO
  ;
/* ------- TB_IFR015 : 생산오더-라미네이팅 인쇄코팅  End --------------------------- */

/* ------- TB_IFR015 : 생산오더-라미네이팅 인쇄코팅공정  Begin ------------------------- */
PROCEDURE sp_ifr015 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_AUFNR          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부) 
  V_BOM_CNT       NUMBER          := 0;      -- 카운트(작업지시BOM존재여부)

  V_WO_DT         VARCHAR2(50)    := '';      -- 지시일자(작업지시생성하기 위해서..)  

  V_WO_NO         VARCHAR2(50)    := '';      -- 작업지시번호 (작업지시BOM생성을 위해서..)  
  V_WO_SEQ        NUMBER          := 0;      --작업지시순번 (작업지시BOM생성을 위해서..)  
  V_WERKS         VARCHAR2(50)    := '';      -- 플랜트 (작업지시BOM생성을 위해서..)   

  V_DLFL          VARCHAR2(50)    := '';      -- 삭제FLAG  
BEGIN


    SELECT NVL(DLFL,' ') INTO V_DLFL
    FROM TB_LAMI_PC_IFR015
    WHERE AUFNR = i_AUFNR
    AND IF_IFR_NO = i_IF_IFR_NO;    

    IF V_DLFL = 'X' THEN
      UPDATE TB_LAMI_PC_SCH002
         SET DLFL = V_DLFL
           , UPDDATE = SYSDATE
           , UPDID = 'SP_LAMI_PC_IFR015'
       WHERE AUFNR =  i_AUFNR;

      UPDATE TB_LAMI_PC
         SET USE_YN = 'N'
           , UPDDATE = SYSDATE
           , UPDID = 'SP_LAMI_PC_IFR015'
       WHERE ORDER_NO =  i_AUFNR;             

      o_msg_MSG  :=  'TB_LAMI_PC_IFR015, 생산오더-라미네이팅 인쇄코팅 삭제 수신되었습니다.1'; -- || ',' || SQLERRM ;

      UPDATE  TB_LAMI_PC_IFR015
      SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
            , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
            , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
      WHERE  AUFNR     =  i_AUFNR
      AND    IF_IFR_NO =  i_IF_IFR_NO           
      ;

      o_msg_MSG  :=  'TB_LAMI_PC_IFR015, 생산오더-라미네이팅 인쇄코팅 삭제 수신되었습니다.2'; -- || ',' || SQLERRM ;
      o_msg_code := '0' ;
      RETURN;    
    END IF;

  -----------------------------------------------------------------------------------------------------------------------------
  --생산오더
  -----------------------------------------------------------------------------------------------------------------------------
    MERGE
        INTO  TB_LAMI_PC_SCH002 SCH002
        USING TB_LAMI_PC_IFR015 IFR015
           ON ( SCH002.AUFNR      =  IFR015.AUFNR
           AND  IFR015.AUFNR      =  i_AUFNR 
           AND  IFR015.IF_IFR_NO  =  i_IF_IFR_NO   )
    WHEN MATCHED THEN
         UPDATE
         SET    	SCH002.WERKS			=	IFR015.WERKS			           /*		플랜트				                   */
                ,	SCH002.GSTRP			=	IFR015.GSTRP			           /*		시작일자				                 */
                ,	SCH002.MATNR			=	IFR015.MATNR			           /*		제품코드				                 */
                ,	SCH002.FQTY			  =	IFR015.FQTY			             /*		생산지시량				                 */
                ,	SCH002.MEINS			=	IFR015.MEINS			           /*		생산지시단위				               */
                ,	SCH002.AENAM			=	IFR015.AENAM			           /*		작업지시자				                 */
                ,	SCH002.PRCMC			=	IFR015.PRCMC			           /*		가공호기				                 */
                ,	SCH002.MACHINE		=	IFR015.MACHINE			         /*		생산호기				                 */
                ,	SCH002.STLNR			=	IFR015.STLNR			           /*		BOM Num				                  */
                ,	SCH002.STLAL			=	IFR015.STLAL			           /*		대체Bom				                   */
                ,	SCH002.BMENG			=	IFR015.BMENG			           /*		모품목기준수량				              */
                ,	SCH002.BMEIN			=	IFR015.BMEIN			           /*		모품목기준수량 단위				         */
                ,	SCH002.SPEC1			=	IFR015.SPEC1			           /*		규격				                      */
                ,	SCH002.WDTH1			=	IFR015.WDTH1			           /*		폭수				                      */
                ,	SCH002.PUPOS			=	IFR015.PUPOS			           /*		용도				                      */
                ,	SCH002.PUPNM			=	IFR015.PUPNM			           /*		용도내역				                   */
                ,	SCH002.REMRK			=	IFR015.REMRK			           /*		비고				                       */
                ,	SCH002.DLFL			  =	IFR015.DLFL			             /*		오더 삭제 지시자				              */
                , SCH002.REM        = IFR015.REM                   /*    반복생산 지시자                      */
                , SCH002.SEQ        = IFR015.SEQ                    --작업순서

                , SCH002.UPDDATE    = sysdate                      /*    수정일자                             */
                , SCH002.UPDID      = 'SP_LAMI_PC_IFR015'                  /*    수정자                               */
                ,	SCH002.OPTYPE			=	IFR015.OPTYPE			           /*		비고				                       */
          WHERE  IFR015.IF_STATUS in ('N','E')                     /*  I/F상태, N:신규, S:성공, E:오류        */
          AND    IFR015.AUFNR     =  i_AUFNR
          AND    IFR015.IF_IFR_NO =  i_IF_IFR_NO   
    WHEN NOT MATCHED THEN
         INSERT (  	SCH002.AUFNR			                             /*		오더번호				                      */
                  ,	SCH002.WERKS			                             /*		플랜트				                        */
                  ,	SCH002.GSTRP			                             /*		시작일자				                      */
                  ,	SCH002.MATNR			                             /*		제품코드				                      */
                  ,	SCH002.FQTY			                               /*		생산지시량				                      */
                  ,	SCH002.MEINS			                             /*		생산지시단위				                    */
                  ,	SCH002.AENAM			                             /*		작업지시자				                      */
                  ,	SCH002.PRCMC			                             /*		가공호기				                      */
                  ,	SCH002.MACHINE			                           /*		생산호기				                      */
                  ,	SCH002.STLNR			                             /*		BOM Num				                       */
                  ,	SCH002.STLAL			                             /*		대체Bom				                        */
                  ,	SCH002.BMENG			                             /*		모품목기준수량				                   */
                  ,	SCH002.BMEIN			                             /*		모품목기준수량 단위				              */
                  ,	SCH002.SPEC1			                             /*		규격				                           */
                  ,	SCH002.WDTH1			                             /*		폭수				                           */
                  ,	SCH002.PUPOS			                             /*		용도				                           */
                  ,	SCH002.PUPNM			                             /*		용도내역				                        */
                  ,	SCH002.REMRK			                             /*		비고				                           */
                  ,	SCH002.DLFL			                               /*		오더 삭제 지시자				                  */
                  , SCH002.REM                                     /*    반복생산 지시자                          */
                  , SCH002.WRK_CD                                   --작업장코드
                  , SCH002.SEQ                                      --작업순서

                  , SCH002.REGDATE                                 /*    등록일자                                */
                  , SCH002.REGID                                   /*    등록자                                 */
                  , SCH002.UPDDATE                                 /*    수정일자                                */
                  , SCH002.UPDID                                   /*    수정자                                 */
                  , SCH002.OPTYPE                                   /*    OPTYPE : L(인쇄코팅), X(슬리팅)                */
                    )
         VALUES (   IFR015.AUFNR			                             /*		오더번호				                        */
                  ,	IFR015.WERKS			                             /*		플랜트				                           */
                  ,	IFR015.GSTRP			                             /*		시작일자				                         */
                  ,	IFR015.MATNR			                             /*		제품코드				                         */
                  ,	IFR015.FQTY			                               /*		생산지시량				                         */
                  ,	IFR015.MEINS			                             /*		생산지시단위				                      */
                  ,	IFR015.AENAM			                             /*		작업지시자				                         */
                  ,	IFR015.PRCMC			                             /*		가공호기				                          */
                  ,	IFR015.MACHINE			                           /*		생산호기				                          */
                  ,	IFR015.STLNR			                             /*		BOM Num				                          */
                  ,	IFR015.STLAL			                             /*		대체Bom				                           */
                  ,	IFR015.BMENG			                             /*		모품목기준수량				                      */
                  ,	IFR015.BMEIN			                             /*		모품목기준수량 단위				                 */
                  ,	IFR015.SPEC1			                             /*		규격				                              */
                  ,	IFR015.WDTH1			                             /*		폭수				                              */
                  ,	IFR015.PUPOS			                             /*		용도				                              */
                  ,	IFR015.PUPNM			                             /*		용도내역				                           */
                  ,	IFR015.REMRK			                             /*		비고				                              */
                  ,	IFR015.DLFL			                               /*		오더 삭제 지시자				                     */
                  , IFR015.REM                                     /*    반복생산 지시자                             */
                  , IFR015.ARBPL                                    --작업장코드
                  , IFR015.SEQ                                      --작업순서
                  , sysdate                                        /*    등록일자                                   */
                  , 'SP_LAMI_PC_IFR015'                                    /*    등록자                                     */
                  , null                                           /*    수정일자                                   */
                  , null                                           /*    수정자                                     */
                  , IFR015.OPTYPE                                   /*    OPTYPE : L(인쇄코팅), X(슬리팅)                */
                    )
         WHERE  IFR015.IF_STATUS in ('N','E')  /*  I/F상태, N:신규, S:성공, E:오류   */
         AND    IFR015.AUFNR     =  i_AUFNR
         AND    IFR015.IF_IFR_NO =  i_IF_IFR_NO   
         ;

DBMS_OUTPUT.PUT_LINE('3' );

    --========================================
    --KHJ추가 2022-05-02:작업지시-라미네이팅 인쇄코팅
    --========================================
    ------------------------------------------
    --작업지시가 존재하지 않으면 작업지시 번호 생성
    SELECT COUNT(ORDER_NO) INTO V_CNT
    FROM TB_LAMI_PC
    WHERE ORDER_NO = i_AUFNR;

    IF V_CNT = 0 THEN
      SELECT GSTRP INTO V_WO_DT
      FROM TB_LAMI_PC_IFR015
      WHERE IF_IFR_NO  =  i_IF_IFR_NO;

      SP_GET_DOC_SEQ('LP',V_WO_DT,V_WO_NO); 
    END IF;
    ------------------------------------------
DBMS_OUTPUT.PUT_LINE('5' );

    IF V_CNT > 0 THEN    
      UPDATE TB_LAMI_PC
      SET(        
           WERKS                																--플랜트코드
           ,PRD_REQ_DT           																--생산요청일자
--           ,ORDER_DIV            																--오더유형
--           ,ORDER_DIV_NM         																--오더유형 텍스트
           ,MACHINE              																--FROM 생산호기
           ,MACH_CD               																--생산호기
           ,MATNR                																--자재 코드
--           ,PPCODE                																--지종
--           ,EQUIL               																--평량
--           ,HEIGHT               																--평량
--           ,STD               																--평량
--           ,VLEN                 																--세로길
--           ,WLEN                 																--가로길
           ,WRK_ORDR_QTY         																--생산지시량
           ,ORDER_QTY         																--생산지시량
           ,REMAIN_QTY              																--총중량
           ,PRFM_QTY
           ,UNIT                 																--단위
           ,BOM_NO               																--BOM Num
           ,ATN_BOM_NO           																--대체Bom
           ,DLFL                 																--오더 삭제 지시자
           ,ORDER_RMK            																--비고
--           ,KUNNR                																--판매처
           ,UPDDATE              																--수정일시
           ,UPDID                																--수정자ID
           ,USE_YN               																--사용여부(Y:사용 N:미사용)
           ,ORDR_GEN_DT
            ,SPEC
            ,PUPOS
            ,PUPNM
            ,ORDER_SEQNO
            ,CNL_YN
      )=(SELECT                         										
--            FRAUFNR                   --이전 오더 번호
           WERKS                        --플랜트코드
           ,GSTRP                       --생산요청일자
--           ,AUART                     --오더유형
--           ,AUARTXT                   --오더유형 텍스트
           ,MACHINE                     --FROM 생산호기
           ,'PRD01'                     --설비코드
           ,MATNR                         											--자재 코드
--           ,PCODE                          											--지종
--           ,WEIGHT                         											--평량
--           ,WLEN                           											--가로길
--           ,SIZE_VAL                       											--규격   					 
--           ,VLEN                           											--세로길
--           ,WLEN                           											--가로길
           ,FQTY                            											--생산지시량
           ,FQTY                         											--총중량
           ,FQTY                            											--생산지시량
           ,0
           ,'KG'                         											--단위
           ,STLNR                          											--BOM Num
           ,STLAL                          											--대체Bom
           ,DLFL                           											--오더 삭제 지시자
           ,REMRK                         											                        --비고
--           ,KUNNR                          											--판매처
           ,sysdate                               							--수정일시
           ,'SP_LAMI_PC_IFR015'                           						--수정자ID
           ,case when DLFL = 'X' then 'N'  							          
                 when DLFL = 'N' then 'Y'
            end  --사용여부(Y:사용 N:미사용)
           ,TO_CHAR(SYSDATE,'YYYYMMDD')
            ,SPEC1
            ,PUPOS
            ,PUPNM
            ,SEQ
            ,'N'
         FROM TB_LAMI_PC_IFR015 
         WHERE  IF_IFR_NO = i_IF_IFR_NO      
      )
      WHERE ORDER_NO = i_AUFNR;
--        AND NVL(MAN_CUT_YN,'N') <> 'X';       
    ELSE    
      INSERT INTO TB_LAMI_PC(  
           WRK_ORDR_NO                              					--작업지시번호-->작업지시 생성자 사용 WO + R  
          ,WRK_ORDR_SEQNO                           					--작업지시순번
          ,WRK_SEQNO                                					--작업순서
          ,ORDR_GEN_DT                              					--지시생성일자
          ,ORDER_NO																					  --오더번호
          ,WERKS                 														--플랜트코드
          ,PRD_REQ_DT            														--생산요청일자
--          ,ORDER_DIV             														--오더유형
--          ,ORDER_DIV_NM          														--오더유형 텍스트
          ,MACHINE               														--FROM 생산호기
          ,MACH_CD               																--생산호기
          ,MATNR                 														--자재 코드
--          ,PPCODE                 														--지종
--          ,EQUIL                														--평량
--          ,HEIGHT                														--길이
--          ,STD                       											--규격   					 
--          ,VLEN                  														--세로길
--          ,WLEN                  														--가로길
          ,WRK_ORDR_QTY          														--생산지시량
          ,ORDER_QTY          														--생산지시량
          ,REMAIN_QTY               														--총중량
          ,PRFM_QTY
          ,UNIT                  														--단위
--          ,VBELN                 														--판매문서
--          ,POSNR                 														--판매문서 항목번호
--          ,CUTTER                														--카터
          ,BOM_NO                														--BOM Num
          ,ATN_BOM_NO            														--대체Bom
--          ,PRT_MATNR_QTY         														--모품목기준수량
--          ,PRT_MATNR_UNIT        														--모품목기준수량 단위
          ,DLFL                  														--오더 삭제 지시자
          ,ORDER_RMK                                					--비고
--          ,KUNNR                                    					--판매처
          ,COMP_YN                                  					--완료여부
          ,REGDATE                                  					--등록일시
          ,REGID                                    					--등록자ID
          ,UPDDATE                                  					--수정일시
          ,UPDID                                    					--수정자ID
          ,USE_YN                                   					--사용여부(Y:사용 N:미사용)              
          ,SPEC
          ,PUPOS
          ,PUPNM
          ,ORDER_SEQNO
          ,CNL_YN
      )                                           					                              
      SELECT                                      					                              
           V_WO_NO														    							--작업지시번호
          ,1                                                   --작업지시순번
          ,SUBSTR(V_WO_NO,-4)                                  --작업순서(작업지시번호,-4)
          ,TO_CHAR(sysdate,'YYYYMMDD')                         --지시생성일자
          ,AUFNR     																		      --오더번호
          ,WERKS                          											--플랜트코드
          ,GSTRP                          											--생산요청일자
--          ,AUART                          											--오더유형
--          ,AUARTXT                        											--오더유형 텍스트
          ,MACHINE                        											--FROM 생산호기
          ,'PRD01'                        											--설비코드
          ,MATNR                         											--자재 코드
--          ,PCODE                          											--지종
--          ,WEIGHT                         											--평량
--          ,WLEN                           											--가로길
--          ,SIZE_VAL                       											--규격   					 
--          ,VLEN                           											--세로길
--          ,WLEN                           											--가로길
          ,FQTY                            											--생산지시량
          ,FQTY                         											--총중량
          ,FQTY                            											--생산지시량
          ,0
          ,'KG'                         											--단위
--          ,''                          											--판매문서
--          ,''                          											--판매문서 항목번호
--          ,0                         											--카터
          ,STLNR                          											--BOM Num
          ,STLAL                          											--대체Bom
--          ,''                          											--모품목기준수량
--          ,''                          											--모품목기준수량 단위
          ,DLFL                           											--오더 삭제 지시자
          ,REMRK                                       				                                        --오더비고
--          ,KUNNR                                        				--판매처 
          ,'N'                                                 --완료여부
          ,sysdate                                             --등록일시
          ,'SP_LAMI_PC_IFR015'                                         --등록자ID
          ,null                                                --수정일시
          ,null                                                --수정자ID 
          ,case when DLFL = 'X' then 'N'
               else 'Y'
          end                                                 --사용여부(Y:사용 N:미사용)                                      
            ,SPEC1
            ,PUPOS
            ,PUPNM
            ,SEQ
            ,'N'
      FROM  TB_LAMI_PC_IFR015
      WHERE  IF_IFR_NO = i_IF_IFR_NO;                      
    END IF;  

DBMS_OUTPUT.PUT_LINE('4' );

    --작업지시 생성되면 작업지시BOM을 구성한다. 
    --작업지시정보 추출
    SELECT WRK_ORDR_NO, WRK_ORDR_SEQNO, WERKS INTO V_WO_NO,V_WO_SEQ,V_WERKS
    FROM TB_LAMI_PC
    WHERE ORDER_NO = i_AUFNR;
--    AND NVL(MAN_CUT_YN,'N') <> 'X';

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
            ,'SP_LAMI_PC_IFR015'
            ,null
            ,null
      FROM TB_SCH001          
      WHERE  AUFNR  =  i_AUFNR;       
    END IF;                          

DBMS_OUTPUT.PUT_LINE('AAAA' );


    o_msg_MSG  :=  'TB_LAMI_PC_IFR015, 생산오더-라미네이팅 인쇄코팅이 수신되었습니다.1'; -- || ',' || SQLERRM ;

DBMS_OUTPUT.PUT_LINE('BBB' );
    UPDATE  TB_LAMI_PC_IFR015
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    AUFNR     =  i_AUFNR
    AND    IF_IFR_NO =  i_IF_IFR_NO    
    ;
DBMS_OUTPUT.PUT_LINE('CCC' );
    o_msg_MSG  :=  'TB_LAMI_PC_IFR015, 생산오더-라미네이팅 인쇄코팅이 수신되었습니다.2'; -- || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_LAMI_PC_IFR015, 생산오더-라미네이팅 인쇄코팅 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_LAMI_PC_IFR015
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    AUFNR     =  i_AUFNR
                AND    IF_IFR_NO =  i_IF_IFR_NO    
                ;

END  sp_ifr015 ;
/* ------- TB_LAMI_PC_IFR015 : 생산오더-라미네이팅 인쇄코팅  End --------------------------- */

BEGIN

/* ------- TB_LAMI_PC_IFR015 : 생산오더-라미네이팅 인쇄코팅  Begin --------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_971'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_971==>START');

        for ifr015 in cur_ifr015 loop

            sp_ifr015(  ifr015.IF_IFR_NO
                      , ifr015.AUFNR
                      , o_msg_CODE
                      , o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_971 개별처리중 ERROR==>'|| ifr015.aufnr || ',' || o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

        DBMS_OUTPUT.PUT_LINE('MES_IF_971==>END');        

    END IF ;
/* ------- TB_IFR015 : 생산오더-라미네이팅 인쇄코팅  End --------------------------- */




EXCEPTION
  WHEN OTHERS THEN
    o_msg_code      := '-1' ;
    o_msg_msg       := 'Error,생산오더 수신 중 MAIN에서 오류가 발생하였습니다.' ||
                       ',' || to_char(SQLCODE) || ',' || SQLERRM ;
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    rollback ;

END ;

/
