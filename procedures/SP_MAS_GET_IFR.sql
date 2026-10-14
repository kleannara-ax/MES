
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_MAS_GET_IFR" (  i_IF_MES_ID        IN    VARCHAR2
                                                    ,i_IF_MES_KEY       IN    VARCHAR2
                                                    ,o_msg_CODE         OUT   VARCHAR2
                                                    ,o_msg_MSG          OUT   VARCHAR2
                                             ) is
                                             
                                             
/*==============================================================================
 * PROGRAM ID    : 인터페이스
 * PROGRAM NAME  : 기준정보 수신
 * VERSION       : 1.0.0
 * DESCRIPTION   : 기준정보 수신
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
                                             
                                             
	V_STOR_LOC_NM		TB_MAS003.STOR_LOC_NM%TYPE;                                  
    V_CNT				NUMBER	:= 1;                                         
                                             

/* ------- TB_IFR001 : 자재기준정보 수신 (Interface)  Begin ---------------- */
CURSOR  cur_ifr001 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  MATNR               /* 품목코드                                */
       ,  WERKS               /* 공장코드                                */
       ,  MTART               /* 유형                                   */
       ,  MTBEZ               /* 유형명                                  */
       ,  MATKL               /* 자재그룹                                 */
       ,  WGBEZ               /* 자재그룹명                               */
       ,  SPART               /* 제품군                                  */
       ,  VTEXT               /* 제품군명                                 */
       ,  MMSTA               /* 플랜트고유자재상태                         */
       ,  MMSTATXT            /* 플랜트고유자재상태명                        */
       ,  MSTAE               /* 자재상태                                 */
       ,  MSTAETXT            /* 자재상태명                                */
       ,  MATTYPE             /* HL LOT 구분                              */
       ,  MATTPTXT            /* HL LOT 구분명                            */
       ,  DIVISION            /* 사업부                                   */
       ,  DVTXT               /* 사업부명                                 */
       ,  BRAND_ID            /* 브랜드                                   */
       ,  BRAND_DESCR         /* 브랜드명                                 */
       ,  PCODE               /* 지종                                    */
       ,  PCODETXT            /* 지종명                                   */
			 ,  ZQRTAYN							--품질검사 대상 여부
			 ,  MHDHB               --유통기간      
			 ,  EAN11               --KAN 번호         
       ,  IF_MES_ID           /* MES Interface ID                        */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  FROM    TB_IFR001
  WHERE   IF_STATUS  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  AND     WERKS IN('P100','P200','P300','P500')
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR001 : 자재기준정보 수신 (Interface)  End ----------------- */

/* ------- TB_IFR002 : 플랜트 마스터  Begin ------------------------------ */
CURSOR  cur_ifr002 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  WERKS
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR002
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR002 : 플랜트 마스터  End -------------------------------- */

/* ------- TB_IFR003 : 저장위치 마스터  Begin ---------------------------- */
CURSOR  cur_ifr003 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  WERKS
       ,  LGORT
       ,  LGOBE
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR003
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR003 : 저장위치 마스터  End ------------------------------ */

/* ------- SAP와 협의 후 I/F 대상에서 제외
\* ------- TB_IFR004 : 단위 기준정보  Begin ---------------------------- *\
CURSOR  cur_ifr004 IS
  SELECT  MSEHI
  FROM    TB_IFR004
  WHERE   IF_STATUS  in  ( 'N','E' )  \*  I/F상태, N:신규, S:성공, E:오류   *\
  ORDER  BY  IF_GET_DATE
         ,   IF_MES_KEY
  ;
\* ------- TB_IFR004 : 단위 기준정보  End ------------------------------ *\
*/

/* ------- TB_IFR005 : 자재별 단위환산 마스터  Begin ---------------------- */
CURSOR  cur_ifr005 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  MATNR
       ,  MSEHI
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR005
  WHERE   IF_STATUS  in  ( 'N','E' )   /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR005 : 자재별 단위환산 마스터  End ------------------------- */

/* ------- TB_IFR006 : 작업장(WorkCenterCode) 마스터  Begin -------------- */
CURSOR  cur_ifr006 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  WERKS
       ,  ARBPL
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR006
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR006 : 작업장(WorkCenterCode) 마스터  End ---------------- */

/* ------- TB_IFR007 : 생산버전  Begin ---------------------------------- */
CURSOR  cur_ifr007 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  MATNR
       ,  WERKS
       ,  VERID
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR007
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR007 : 생산버전  End ------------------------------------ */

/* ------- TB_IFR008 : BOM 마스터  Begin -------------------------------- */
CURSOR  cur_ifr008 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  MATNR
       ,  WERKS
       ,  STLNR
       ,  STLAL
       ,  POSNR
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR008
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR008 : BOM 마스터  End ---------------------------------- */

/* ------- TB_IFR009 : 거래처(고객사) 마스터  Begin -------------------------------- */
CURSOR  cur_ifr009 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  KUNWE
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR009
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR009 : 거래처(고객사) 마스터  End ---------------------------------- */

/* ------- TB_IFR010 : 거래처(공급사) 마스터  Begin -------------------------------- */
CURSOR  cur_ifr010 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  ZCODE
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR010
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
--  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR010 : 거래처(공급사) 마스터 End ---------------------------------- */

/* ------- TB_IFR011 : 실적취소 가능한 월  Begin -------------------------- */
CURSOR  cur_ifr011 IS
  SELECT  IF_IFR_NO           /* MES Interface Sequence(수신번호)        */
       ,  WERKS
       ,  YYMM
       ,  IF_MES_ID           /* MES Interface ID      */
       ,  IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)   */
  FROM    TB_IFR011
  WHERE   IF_STATUS  in  ( 'N','E' )  /*  I/F상태, N:신규, S:성공, E:오류   */
  AND     IF_MES_ID  =   i_IF_MES_ID           /*  MES Interface ID                       */
  AND     IF_MES_KEY =   i_IF_MES_KEY          /* MES Inserface Key(SAP->MES 인 경우만)     */
  ORDER  BY  IF_GET_DATE
  --       ,   IF_MES_KEY
  ;
/* ------- TB_IFR011 : 실적취소 가능한 월  End ----------------------------- */


/* ------- TB_IFR001 : 자재기준정보 수신 (Interface)  Begin ---------------- */
PROCEDURE sp_ifr001 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_MATNR          IN   VARCHAR2
                      ,i_WERKS          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT   NUMBER  DEFAULT 0;

BEGIN


    SELECT COUNT(MATNR) INTO V_CNT FROM TB_MAS001 WHERE MATNR = i_MATNR AND WERKS = i_WERKS;

    IF V_CNT > 0 THEN
           UPDATE TB_MAS001
           SET(     MATNR_NM                                            /* 품명                        */
                  , MATNR_SHRT_NM                                       /* 품명                        */
                  , MATNR_SPEC                                          /* 규격-KHJ:GROES->MATNR_SPEC                */
                  , MATNR_DIV                                           /* 유형                        */
                  , MATNR_DIV_NM                                        /* 유형명                       */
                  , MATNR_GRP_CD                                        /* 자재그룹                     */
                  , MATNR_GRP_NM                                        /* 자재그룹명                    */
                  , PROD_GRP_CD                                         /* 제품군-KHJ:SPART->PROD_GRP_CD              */
                  , PROD_GRP_NM                                         /* 제품군명-KHJ:VTEXT->PROD_GRP_NM             */
                  , UNIT                                                /* 기본단위-KHJ:MEINS->UNIT                    */
                  , RCV_UNIT                                            /* 입고단위                     */
                  , IN_UNIT                                             /* 투입단위                     */
                  , PROD_UNIT                                           /* 생산단위                     */
                  , LGFSB                                               /* 외부입고저장위치               */
                  , LGPRO                                               /* 투입저장위치                  */
                  , BESKZ                                               /* 조달유형                     */
                  , LOT_YN                                              /* LOT 관리여부                 */
                  , BISMT                                               /* 기존품목코드                   */
                  , MMSTA                                               /* 플랜트 고유 자재상태            */
                  , MMSTA_NM                                            /* 플랜트 고유 자재상태 텍스트      */
                  , PRDHA                                               /* 제품계층구조                   */
                  , SOBSL                                               /* 특별조달유형                   */
                  , MATNR_STA                                           /* 자재상태                      */
                  , MATNR_STA_NM                                        /* 자재상태 텍스트                */
                  , MIN_LOT_SIZE                                        /* 최소LOT크기                   */
                  , MAX_LOT_SIZE                                        /* 최대LOT크기                   */
                  , FIX_LOT_SIZE                                        /* 고정LOT크기                   */
                  , SV_STCK_QTY                                         /* 안전재고                      */
                  , DISLS                                               /* 로트크기유형                   */
                  , MATTYPE                                             /* HL LOT 구분                   */
                  , MATTP_NM                                            /* HL LOT 구분명                 */
                  , BUSICD                                              /* 사업부                        */
                  , BUSINM                                              /* 사업부명                      */
                  , PCODE                                               /* 지종                         */
                  , PCODE_NM                                            /* 지종명                        */
                  , BS_WGT                                              /* 평량                         */
                  , INSP_MATNR                                          /* 자재검사대상여부               */
                  , KZAUS                                               /* 단종여부                      */
                  , MSTDE                                               /* 단종일자                      */
                  , BRAND_ID                                            /* 브랜드                       */
                  , BRAND_DESCR                                         /* 브랜드명                      */
                  , DL_YN                                               /* 삭제여부                      */
                  , TSPEED                                              /* 목표 선속                     */
                  , STRGR                                               /* 생산전략                      */
									, INSP_YN															                --품질검사 대상 여부
									, DSTBT_DDLIN                                         --유통기간      
									, KAN_NO                                              --KAN 번호  
									, WLEN                                                --가로  
									, VLEN                                                --세로  																		                 
                  
                  , USE_YN                                              /* 사용유무-KHJ:USE_FLAG->USE_YN                      */               
                  , UPDDATE                                             /* 수정일자-KHJ:EDIT_DATE->UPDDATE                   */
                  , UPDID                                               /* 수정자-KHJ:EDITOR->UPDID                           */
           )=
           (SELECT  MAKTX                																/* 품명                        */
                  , MAKTG                																/* 품명                        */
                  , GROES                																/* 규격-KHJ:GROES->MATNR_SPEC                */
                  , MTART                																/* 유형                        */
                  , MTBEZ                																/* 유형명                       */
                  , MATKL                																/* 자재그룹                     */
                  , WGBEZ                																/* 자재그룹명                    */
                  , SPART                																/* 제품군-KHJ:SPART->PROD_GRP_CD              */
                  , VTEXT                																/* 제품군명-KHJ:VTEXT->PROD_GRP_NM             */
                  , MEINS                																/* 기본단위-KHJ:MEINS->UNIT                    */
                  , BSTME                																/* 입고단위                     */
                  , AUSME                																/* 투입단위                     */
                  , FRTME                																/* 생산단위                     */
                  , LGFSB                																/* 외부입고저장위치               */
                  , LGPRO                																/* 투입저장위치                  */
                  , BESKZ                																/* 조달유형                     */
                  , XCHAR                																/* LOT 관리여부                 */
                  , BISMT                																/* 기존품목코드                   */
                  , MMSTA                																/* 플랜트 고유 자재상태            */
                  , MMSTATXT             																/* 플랜트 고유 자재상태 텍스트      */
                  , PRDHA                																/* 제품계층구조                   */
                  , SOBSL                																/* 특별조달유형                   */
                  , MSTAE                																/* 자재상태                      */
                  , MSTAETXT             																/* 자재상태 텍스트                */
                  , BSTMI                																/* 최소LOT크기                   */
                  , BSTMA                																/* 최대LOT크기                   */
                  , BSTFE                																/* 고정LOT크기                   */
                  , EISBE                																/* 안전재고                      */
                  , DISLS                																/* 로트크기유형                   */
                  , MATTYPE              																/* HL LOT 구분                   */
                  , MATTPTXT             																/* HL LOT 구분명                 */
                  , DIVISION             																/* 사업부                        */
                  , DVTXT                																/* 사업부명                      */
                  , PCODE                																/* 지종                         */
                  , PCODETXT             																/* 지종명                        */
                  , WEIGHT               																/* 평량                         */
                  , INSP_MATNR           																/* 자재검사대상여부               */
                  , KZAUS                																/* 단종여부                      */
                  , MSTDE                																/* 단종일자                      */
                  , BRAND_ID             																/* 브랜드                       */
                  , BRAND_DESCR          																/* 브랜드명                      */
                  , LVORM                																/* 삭제여부                      */
                  , TSPEED               																/* 목표 선속                     */
                  , STRGR                																/* 생산전략                      */
			 						, ZQRTAYN															                --품질검사 대상 여부
			 						, MHDHB                								                --유통기간      
			 						, EAN11                								                --KAN 번호                    
									, WLEN                                                --가로  
									, VLEN                                                --세로     			 						
                  
                  , 'Y'                          												/* 사용유무-KHJ:USE_FLAG->USE_YN                      */               
                  , sysdate                      												/* 수정일자-KHJ:EDIT_DATE->UPDDATE                   */
                  , 'sp_ifr001'                  												/* 수정자-KHJ:EDITOR->UPDID                           */
            FROM TB_IFR001
            WHERE  IF_IFR_NO =  i_IF_IFR_NO
           )
           WHERE MATNR = i_MATNR AND WERKS = i_WERKS;               

    ELSE
           INSERT INTO TB_MAS001 
           (          MATNR                         			 /* 품목코드                            */
                    , WERKS                         			 /* 공장코드                            */
                    , MATNR_NM                      			 /* 품명                               */
                    , MATNR_SHRT_NM                 			 /* 품명                               */
                    , MATNR_SPEC                    			 /* 규격-KHJ:GROES->MATNR_SPEC                               */
                    , MATNR_DIV                     			 /* 유형                               */
                    , MATNR_DIV_NM                  			 /* 유형명                              */
                    , MATNR_GRP_CD                  			 /* 자재그룹                            */
                    , MATNR_GRP_NM                  			 /* 자재그룹명                           */
                    , PROD_GRP_CD                   			 /* 제품군-KHJ:SPART->PROD_GRP_CD                              */
                    , PROD_GRP_NM                   			 /* 제품군명-KHJ:VTEXT->PROD_GRP_NM                           */
                    , UNIT                          			 /* 기본단위-KHJ:MEINS->UNIT                            */
                    , RCV_UNIT                      			 /* 입고단위                            */
                    , IN_UNIT                       			 /* 투입단위                            */
                    , PROD_UNIT                     			 /* 생산단위                            */
                    , LGFSB                         			 /* 외부입고저장위치                      */
                    , LGPRO                         			 /* 투입저장위치                         */
                    , BESKZ                         			 /* 조달유형                            */
                    , LOT_YN                        			 /* LOT 관리여부                        */
                    , BISMT                         			 /* 기존품목코드                         */
                    , MMSTA                         			 /* 플랜트 고유 자재상태                  */
                    , MMSTA_NM                      			 /* 플랜트 고유 자재상태 텍스트            */
                    , PRDHA                         			 /* 제품계층구조                         */
                    , SOBSL                         			 /* 특별조달유형                         */
                    , MATNR_STA                     			 /* 자재상태                            */
                    , MATNR_STA_NM                  			 /* 자재상태 텍스트                      */
                    , MIN_LOT_SIZE                  			 /* 최소LOT크기                         */
                    , MAX_LOT_SIZE                  			 /* 최대LOT크기                         */
                    , FIX_LOT_SIZE                  			 /* 고정LOT크기                         */
                    , SV_STCK_QTY                   			 /* 안전재고                            */
                    , DISLS                         			 /* 로트크기유형                         */
                    , MATTYPE                       			 /* HL LOT 구분                        */
                    , MATTP_NM                      			 /* HL LOT 구분명                       */
                    , BUSICD                        			 /* 사업부                              */
                    , BUSINM                        			 /* 사업부명                            */
                    , PCODE                         			 /* 지종                               */
                    , PCODE_NM                      			 /* 지종명                              */
                    , BS_WGT                        			 /* 평량                               */
                    , INSP_MATNR                    			 /* 자재검사대상여부                     */
                    , KZAUS                         			 /* 단종여부                            */
                    , MSTDE                         			 /* 단종일자                            */
                    , BRAND_ID                      			 /* 브랜드                             */
                    , BRAND_DESCR                   			 /* 브랜드명                            */
                    , DL_YN                         			 /* 삭제여부                            */
                    , TSPEED                        			 /* 목표 선속                           */
                    , STRGR                         			 /* 생산전략                            */
										, INSP_YN															 --품질검사 대상 여부
										, DSTBT_DDLIN                          --유통기간      
										, KAN_NO                               --KAN 번호 
									  , WLEN                                 --가로  
									  , VLEN                                 --세로			
									  , PART_DIV                             --품목구분							                                        
                    
                    , USE_YN                        			 /* 사용유무-KHJ:USE_FLAG->USE_YN                            */
                    , REGDATE                       			 /* 등록일자-KHJ:MAKE_DATE->REGDATE                            */
                    , REGID                         			 /* 등록자-KHJ:MAKER->REGID                             */
                    , UPDDATE                       			 /* 수정일자-KHJ:EDIT_DATE->UPDDATE                            */
                    , UPDID                         			 /* 수정자-KHJ:EDITOR->UPDID                             */
           )
           SELECT     MATNR                         			 /* 품목코드                            */
                    , WERKS                         			 /* 공장코드                            */
                    , MAKTX                         			 /* 품명                               */
                    , MAKTG                         			 /* 품명                               */
                    , GROES                         			 /* 규격                               */
                    , MTART                         			 /* 유형                               */
                    , MTBEZ                         			 /* 유형명                              */
                    , MATKL                         			 /* 자재그룹                            */
                    , WGBEZ                         			 /* 자재그룹명                           */
                    , SPART                         			 /* 제품군                             */
                    , VTEXT                         			 /* 제품군명                            */
                    , MEINS                         			 /* 기본단위                            */
                    , BSTME                         			 /* 입고단위                            */
                    , AUSME                         			 /* 투입단위                            */
                    , FRTME                         			 /* 생산단위                            */
                    , LGFSB                         			 /* 외부입고저장위치                     */
                    , LGPRO                         			 /* 투입저장위치                         */
                    , BESKZ                         			 /* 조달유형                           */
                    , XCHAR                         			 /* LOT 관리여부                       */
                    , BISMT                         			 /* 기존품목코드                        */
                    , MMSTA                         			 /* 플랜트 고유 자재상태                 */
                    , MMSTATXT                      			 /* 플랜트 고유 자재상태 텍스트           */
                    , PRDHA                         			 /* 제품계층구조                        */
                    , SOBSL                         			 /* 특별조달유형                        */
                    , MSTAE                         			 /* 자재상태                           */
                    , MSTAETXT                      			 /* 자재상태 텍스트                     */
                    , BSTMI                         			 /* 최소LOT크기                        */
                    , BSTMA                         			 /* 최대LOT크기                        */
                    , BSTFE                         			 /* 고정LOT크기                        */
                    , EISBE                         			 /* 안전재고                           */
                    , DISLS                         			 /* 로트크기유형                        */
                    , MATTYPE                       			 /* HL LOT 구분                       */
                    , MATTPTXT                      			 /* HL LOT 구분명                      */
                    , DIVISION                      			 /* 사업부                             */
                    , DVTXT                         			 /* 사업부명                           */
                    , PCODE                         			 /* 지종                              */
                    , PCODETXT                      			 /* 지종명                            */
                    , WEIGHT                        			 /* 평량                              */
                    , INSP_MATNR                    			 /* 자재검사대상여부                    */
                    , KZAUS                         			 /* 단종여부                           */
                    , MSTDE                         			 /* 단종일자                           */
                    , BRAND_ID                      			 /* 브랜드                            */
                    , BRAND_DESCR                   			 /* 브랜드명                           */
                    , LVORM                         			 /* 삭제여부                           */
                    , TSPEED                        			 /* 목표 선속                          */
                    , STRGR                         			 /* 생산전략                           */
			 							, ZQRTAYN															 --품질검사 대상 여부
			 							, MHDHB                								 --유통기간      
			 							, EAN11                								 --KAN 번호   
									  , WLEN                                 --가로  
									  , VLEN                                 --세로	
                    , CASE WHEN WERKS IN('P200','P300','P500') AND MTART IN('FERT','HALB','HAWA') THEN SUBSTR(MATNR,2,2)
                           ELSE NULL
                      END									  									                                        			 							                 
                    
                    , 'Y'                                   /* 사용유무                           */
                    , sysdate                              /* 생성일자                           */
                    , 'sp_ifr001'                            /* 생성자                            */
                    , null                                 /* 수정일자                           */
                    , null                                 /* 수정자                            */
           FROM TB_IFR001           
           WHERE  IF_IFR_NO  =  i_IF_IFR_NO     
           ;

    END IF;
  
    
    o_msg_MSG  :=  'TB_IFR001, 자재기준정보가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR001
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    WERKS      =  i_WERKS
    AND    MATNR      =  i_MATNR 
    AND    IF_IFR_NO  =  i_IF_IFR_NO   ;
    

    o_msg_MSG  :=  'TB_IFR001, 자재기준정보가 수신되었습니다.1' || ',' || SQLERRM ;
    o_msg_code      := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
                o_msg_MSG  :=  'TB_IFR001, 자재기준정보가 수신 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                o_msg_code      := '-1' ;
                DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                ROLLBACK;

                UPDATE  TB_IFR001
                SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                      , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                      , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
                WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
                AND    WERKS      =  i_WERKS
                AND    MATNR      =  i_MATNR
                AND    IF_IFR_NO  =  i_IF_IFR_NO   ;

END  sp_ifr001 ;
/* ------- TB_IFR001 : 자재기준정보 수신 (Interface)  End ---------------- */


/* ------- TB_IFR002 : 플랜트 마스터  Begin ---------------- */
PROCEDURE sp_ifr002 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_WERKS          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
BEGIN

    MERGE
    INTO  TB_MAS002 MAS002
    USING TB_IFR002 IFR002
    ON    ( MAS002.WERKS      =  IFR002.WERKS
    AND     IFR002.WERKS      =  i_WERKS       
    AND     IFR002.IF_IFR_NO  =  i_IF_IFR_NO  )
    WHEN MATCHED THEN
         UPDATE
         SET     MAS002.PLANTNM     = IFR002.NAME1       /* 플랜트명                   */
               , MAS002.USE_YN      =  'Y'               /* 사용유무                   */
               , MAS002.UPDDATE     =  sysdate           /* 수정일자                   */
               , MAS002.UPDID       =  'sp_ifr002'       /* 수정자                    */
          WHERE  IFR002.IF_STATUS in ('N','E')           /* I/F상태, N:신규, S:성공, E:오류                */
          AND    IFR002.WERKS     =  i_WERKS
          AND    IFR002.IF_IFR_NO =  i_IF_IFR_NO   
         ;

    o_msg_MSG  :=  'TB_IFR002, 플랜트 마스터 데이터가 수신되었습니다.1'|| ',' || SQLERRM ;

    UPDATE  TB_IFR002
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    WERKS      =  i_WERKS
    AND    IF_IFR_NO  =  i_IF_IFR_NO  
    ;

    o_msg_MSG  :=  'TB_IFR002, 플랜트 마스터 데이터가 수신되었습니다.2'|| ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR002, 플랜트 마스터 수신 중 오류가 발생하였습니다.'||SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              --ROLLBACK;

              UPDATE  TB_IFR002
              SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                    , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                    , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
              WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
              AND    WERKS      =  i_WERKS
              AND    IF_IFR_NO  =  i_IF_IFR_NO  
              ;

END  sp_ifr002 ;
/* ------- TB_IFR002 : 플랜트 마스터  End ---------------- */


/* ------- TB_IFR003 : 저장위치 마스터  Begin ---------------- */
PROCEDURE sp_ifr003 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_WERKS          IN   VARCHAR2
                      ,i_LGORT          IN   VARCHAR2
                      ,i_LGOBE			IN 	 VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
BEGIN
	
	--MERGE
    --INTO  TB_MAS003 MAS003
    --USING TB_IFR003 IFR003
    --ON    ( MAS003.WERKS      =  IFR003.WERKS
    --AND     MAS003.STOR_LOC_CD=  IFR003.LGORT
    --AND     IFR003.WERKS      =  i_WERKS
    --AND     IFR003.LGORT      =  i_LGORT 
    --AND     IFR003.IF_IFR_NO  =  i_IF_IFR_NO    )
    --WHEN MATCHED THEN
    --     UPDATE
    --     SET     MAS003.STOR_LOC_NM = IFR003.LGOBE       /* 저장위치명-KHJ:LGOBE->STOR_LOC_NM              */
    --           , MAS003.USE_YN  =  'Y'                   /* 사용유무-KHJ:USE_FLAG->USE_YN               */
    --           , MAS003.UPDDATE =  sysdate               /* 수정일자-KHJ:EDIT_DATE->UPDDATE              */
    --           , MAS003.UPDID    =  'sp_ifr003'          /* 수정자-KHJ:EDITOR->UPDID                 */
    --      WHERE  IFR003.IF_STATUS in ('N','E')           /* I/F상태, N:신규, S:성공, E:오류                */
    --      AND    IFR003.WERKS     =  i_WERKS
    --      AND    IFR003.LGORT     =  i_LGORT
    --      AND    IFR003.IF_IFR_NO =  i_IF_IFR_NO
    --WHEN NOT MATCHED THEN
    --     INSERT (    MAS003.WERKS                          /* 플랜트명                */
    --               , MAS003.STOR_LOC_CD                    /* 저장위치-KHJ:LGORT->STOR_LOC_CD                */
    --               , MAS003.STOR_LOC_NM                    /* 저장위치명-KHJ:LGOBE->STOR_LOC_NM               */
    --               , MAS003.USE_YN                         /* 사용유무-KHJ:USE_FLAG->USE_YN                */
    --               , MAS003.REGDATE                        /* 등록일자-KHJ:MAKE_DATE->REGDATE                */
    --               , MAS003.REGID                          /* 등록자-KHJ:MAKER->REGID                  */
    --               , MAS003.UPDDATE                        /* 수정일자-KHJ:EDIT_DATE->UPDDATE                */
    --               , MAS003.UPDID                          /* 수정자-KHJ:EDITOR->UPDID                 */
    --                 )
    --     VALUES (    IFR003.WERKS                          /* 플랜트명                */
    --               , IFR003.LGORT                          /* 저장위치                */
    --               , IFR003.LGOBE                          /* 저장위치명               */
    --               , 'Y'                                   /* 사용유무                */
    --               , sysdate
    --               , 'sp_ifr003'
    --               , null                                  /* 수정일자                */
    --               , null                                  /* 수정자                  */
    --                 )
    --     WHERE  IFR003.IF_STATUS in ('N','E')              /*  I/F상태, N:신규, S:성공, E:오류                */
    --     AND    IFR003.WERKS     =  i_WERKS
    --     AND    IFR003.LGORT     =  i_LGORT
    --     AND    IFR003.IF_IFR_NO =  i_IF_IFR_NO
    --       ;
	
	BEGIN
		SELECT STOR_LOC_NM	INTO V_STOR_LOC_NM
		  FROM TB_MAS003
		 WHERE WERKS = i_WERKS
		   AND STOR_LOC_CD = i_LGORT;
		
		V_CNT := 1;  
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			V_CNT := 0; 
	END;
	
	IF V_CNT = 0 THEN
		INSERT INTO TB_MAS003(WERKS, STOR_LOC_CD, STOR_LOC_NM, USE_YN, REGDATE, REGID)
						SELECT WERKS, LGORT, LGOBE, 'Y', SYSDATE, 'sp_ifr003'
						  FROM TB_IFR003 ti 
						 WHERE IF_IFR_NO = i_IF_IFR_NO;
	ELSE
		IF V_STOR_LOC_NM != i_LGOBE THEN
			UPDATE TB_MAS003 
			   SET STOR_LOC_NM = i_LGOBE
			      ,UPDDATE = SYSDATE
			      ,UPDID = 'sp_ifr003'
			 WHERE WERKS = i_WERKS
			   AND STOR_LOC_CD = i_LGORT;
		END IF;
	END IF;

    --MERGE
    --INTO  TB_MAS003 MAS003
    --USING TB_IFR003 IFR003
    --ON    ( MAS003.WERKS      =  IFR003.WERKS
    --AND     MAS003.STOR_LOC_CD=  IFR003.LGORT
    --AND     IFR003.WERKS      =  i_WERKS
    --AND     IFR003.LGORT      =  i_LGORT 
    --AND     IFR003.IF_IFR_NO  =  i_IF_IFR_NO    )
    --WHEN MATCHED THEN
    --     UPDATE
    --     SET     MAS003.STOR_LOC_NM = IFR003.LGOBE       /* 저장위치명-KHJ:LGOBE->STOR_LOC_NM              */
    --           , MAS003.USE_YN  =  'Y'                   /* 사용유무-KHJ:USE_FLAG->USE_YN               */
    --           , MAS003.UPDDATE =  sysdate               /* 수정일자-KHJ:EDIT_DATE->UPDDATE              */
    --           , MAS003.UPDID    =  'sp_ifr003'          /* 수정자-KHJ:EDITOR->UPDID                 */
    --      WHERE  IFR003.IF_STATUS in ('N','E')           /* I/F상태, N:신규, S:성공, E:오류                */
    --      AND    IFR003.WERKS     =  i_WERKS
    --      AND    IFR003.LGORT     =  i_LGORT
    --      AND    IFR003.IF_IFR_NO =  i_IF_IFR_NO
    --WHEN NOT MATCHED THEN
    --     INSERT (    MAS003.WERKS                          /* 플랜트명                */
    --               , MAS003.STOR_LOC_CD                    /* 저장위치-KHJ:LGORT->STOR_LOC_CD                */
    --               , MAS003.STOR_LOC_NM                    /* 저장위치명-KHJ:LGOBE->STOR_LOC_NM               */
    --               , MAS003.USE_YN                         /* 사용유무-KHJ:USE_FLAG->USE_YN                */
    --               , MAS003.REGDATE                        /* 등록일자-KHJ:MAKE_DATE->REGDATE                */
    --               , MAS003.REGID                          /* 등록자-KHJ:MAKER->REGID                  */
    --               , MAS003.UPDDATE                        /* 수정일자-KHJ:EDIT_DATE->UPDDATE                */
    --               , MAS003.UPDID                          /* 수정자-KHJ:EDITOR->UPDID                 */
    --                 )
    --     VALUES (    IFR003.WERKS                          /* 플랜트명                */
    --               , IFR003.LGORT                          /* 저장위치                */
    --               , IFR003.LGOBE                          /* 저장위치명               */
    --               , 'Y'                                   /* 사용유무                */
    --               , sysdate
    --               , 'sp_ifr003'
    --               , null                                  /* 수정일자                */
    --               , null                                  /* 수정자                  */
    --                 )
    --     WHERE  IFR003.IF_STATUS in ('N','E')              /*  I/F상태, N:신규, S:성공, E:오류                */
    --     AND    IFR003.WERKS     =  i_WERKS
    --     AND    IFR003.LGORT     =  i_LGORT
    --     AND    IFR003.IF_IFR_NO =  i_IF_IFR_NO
    --       ;

    o_msg_MSG  :=  'TB_IFR003, 저장위치 마스터 데이터가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR003
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    WERKS      =  i_WERKS
    AND    LGORT      =  i_LGORT
    AND    IF_IFR_NO  =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR003, 저장위치 마스터 데이터가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR003, 저장위치 마스터 수신 중 오류가 발생하였습니다.' || SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              ROLLBACK;

              UPDATE  TB_IFR003
              SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                    , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                    , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
              WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
              AND    WERKS      =  i_WERKS
              AND    LGORT      =  i_LGORT
              AND    IF_IFR_NO  =  i_IF_IFR_NO
              ;

END  sp_ifr003 ;
/* ------- TB_IFR003 : 저장위치 마스터  End ---------------- */

/* ------- SAP와 협의 후 I/F 대상에서 제외
\* ------- TB_IFR004 : 단위 기준정보  Begin ---------------- *\
PROCEDURE sp_ifr004 (  i_MSEHI          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
BEGIN

    MERGE
    INTO  TB_MAS004 MAS004
    USING TB_IFR004 IFR004
    ON    ( MAS004.MSEHI      =  IFR004.MSEHI
    AND     IFR004.MSEHI      =  i_MSEHI )
    WHEN NOT MATCHED THEN
         INSERT (  MAS004.MSEHI                          \*  단위                *\
                 , MAS004.USE_FLAG                       \*  사용유무                *\
                 , MAS004.MAKE_DATE                      \*  등록일자                *\
                 , MAS004.MAKER                          \*  등록자                 *\
                 , MAS004.EDIT_DATE                      \*   수정일자                *\
                 , MAS004.EDITOR                         \*   수정자                  *\
                    )
         VALUES (  IFR004.MSEHI                          \*  단위                *\
                 , 'Y'                                   \*  사용유무                *\
                 , sysdate
                 , 'sp_ifr004'
                 , null                                  \*   수정일자                *\
                 , null                                  \*   수정자                  *\
                    )
         WHERE  IFR004.IF_STATUS in ('N','E')            \*  I/F상태, N:신규, S:성공, E:오류                *\
         AND    IFR004.MSEHI     =  i_MSEHI
           ;

    o_msg_MSG  :=  'TB_IFR004, 단위 기준정보 데이터가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR004
    SET     IF_STATUS   =  'S'                \*  I/F상태, N:신규, S:성공, E:오류               *\
          , IF_SET_DATE =  sysdate            \*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) *\
          , IF_ERR_MESS =  o_msg_MSG          \*  데이터 처리 결과 Message(Oracle)              *\
    WHERE  IF_STATUS in ('N','E')             \*  I/F상태, N:신규, S:성공, E:오류                *\
    AND    MSEHI      =  i_MSEHI
    ;

    o_msg_MSG  :=  'TB_IFR004, 단위 기준정보 데이터가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR004, 단위 기준정보 수신 중 오류가 발생하였습니다.' || SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              ROLLBACK;

              UPDATE  TB_IFR004
              SET     IF_STATUS   =  'E'                \*  I/F상태, N:신규, S:성공, E:오류               *\
                    , IF_SET_DATE =  sysdate            \*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) *\
                    , IF_ERR_MESS =  o_msg_MSG          \*  데이터 처리 결과 Message(Oracle)              *\
              WHERE  IF_STATUS in ('N','E')             \*  I/F상태, N:신규, S:성공, E:오류                *\
              AND    MSEHI      =  i_MSEHI
              ;

END  sp_ifr004 ;
\* ------- TB_IFR004 : 단위 기준정보  End ---------------- *\
*/

/* ------- TB_IFR005 : 자재별 단위환산 마스터  Begin ---------------- */
PROCEDURE sp_ifr005 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_MATNR          IN   VARCHAR2
                      ,i_MSEHI          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
                      
  V_CNT   NUMBER  DEFAULT 0;
                        
BEGIN

    SELECT COUNT(MATNR) INTO V_CNT FROM TB_MAS005 WHERE MATNR = i_MATNR AND UNIT = i_MSEHI;

    IF V_CNT > 0 THEN
           UPDATE TB_MAS005
           SET(     UMREZ                                               /* 분자                  */
                  , UMREN                                               /* 분모                  */                 
                  
                  , USE_YN                                              /* 사용유무-KHJ:USE_FLAG->USE_YN                      */               
                  , UPDDATE                                             /* 수정일자-KHJ:EDIT_DATE->UPDDATE                   */
                  , UPDID                                               /* 수정자-KHJ:EDITOR->UPDID                           */
           )=
           (SELECT  UMREZ                																--분자
                  , UMREN                																--분모                  
                  
                  , 'Y'                          												  /* 사용유무-KHJ:USE_FLAG->USE_YN                      */               
                  , sysdate                      												/* 수정일자-KHJ:EDIT_DATE->UPDDATE                   */
                  , 'sp_ifr005'                  												    /* 수정자-KHJ:EDITOR->UPDID                           */
            FROM TB_IFR005
            WHERE  IF_IFR_NO =  i_IF_IFR_NO
           )
           WHERE MATNR = i_MATNR AND UNIT = i_MSEHI;               

    ELSE
           INSERT INTO TB_MAS005 
           (          MATNR                                --자재번호                
                    , UNIT                                 --단위-KHJ:MSEHI->UNIT                        
                    , UMREZ                                --분자
                    , UMREN                                --분모                                         
                    
                    , USE_YN                        			 /* 사용유무-KHJ:USE_FLAG->USE_YN                            */
                    , REGDATE                       			 /* 등록일자-KHJ:MAKE_DATE->REGDATE                            */
                    , REGID                         			 /* 등록자-KHJ:MAKER->REGID                             */
                    , UPDDATE                       			 /* 수정일자-KHJ:EDIT_DATE->UPDDATE                            */
                    , UPDID                         			 /* 수정자-KHJ:EDITOR->UPDID                             */
           )
           SELECT     MATNR                         			 --자재번호
                    , MSEHI                         			 --단위
                    , UMREZ                         			 --분자
                    , UMREN                         			 --분모
                    
                    , 'Y'                                   /* 사용유무                           */
                    , sysdate                              /* 생성일자                           */
                    , 'sp_ifr005'                              /* 생성자                            */
                    , null                                 /* 수정일자                           */
                    , null                                 /* 수정자                            */
           FROM TB_IFR005           
           WHERE  IF_IFR_NO  =  i_IF_IFR_NO;

    END IF;


         

    o_msg_MSG  :=  'TB_IFR005, 자재별 단위환산 마스터 데이터가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR005
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    MSEHI      =  i_MSEHI
    AND    MATNR      =  i_MATNR
    AND    IF_IFR_NO  =  i_IF_IFR_NO  
    ;

    o_msg_MSG  :=  'TB_IFR005, 자재별 단위환산 마스터 데이터가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR005, 자재별 단위환산 마스터 수신 중 오류가 발생하였습니다.' || SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              ROLLBACK;

              UPDATE  TB_IFR005
              SET   IF_STATUS   =  'E'                /* I/F상태, N:신규, S:성공, E:오류               */
                  , IF_SET_DATE =  sysdate            /* 데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                  , IF_ERR_MESS =  o_msg_MSG          /* 데이터 처리 결과 Message(Oracle)              */
              WHERE  IF_STATUS in ('N','E')           /* I/F상태, N:신규, S:성공, E:오류                */
              AND    MSEHI      =  i_MSEHI
              AND    MATNR      =  i_MATNR
              AND    IF_IFR_NO  =  i_IF_IFR_NO  
              ;

END  sp_ifr005 ;
/* ------- TB_IFR005 : 자재별 단위환산 마스터  Begin ---------------- */


/* ------- TB_IFR006 : 작업장(WorkCenterCode) 마스터  Begin ---------------- */
PROCEDURE sp_ifr006 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_WERKS          IN   VARCHAR2
                      ,i_ARBPL          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
BEGIN

    MERGE
    INTO  TB_MAS006 MAS006
    USING TB_IFR006 IFR006
    ON    ( MAS006.SAP_WRK_CD =  IFR006.ARBPL
    AND     MAS006.WERKS      =  IFR006.WERKS
    AND     IFR006.ARBPL      =  i_ARBPL
    AND     IFR006.WERKS      =  i_WERKS          
    AND     IFR006.IF_IFR_NO  =  i_IF_IFR_NO           )
    WHEN MATCHED THEN
         UPDATE
         SET     MAS006.SAP_WRK_NM= IFR006.KTEXT         /*  작업장명               */
               , MAS006.DL_YN     = IFR006.LVORM         /*  삭제여부               */
               , MAS006.USE_YN    = case when IFR006.LVORM = 'Y' then 'N'
                                         when IFR006.LVORM = 'N' then 'Y'
                                         else 'Y'                                         
                                    end                 /*  사용유무               */
               , MAS006.UPDDATE   =  sysdate            /*  수정일자               */
               , MAS006.UPDID     =  'sp_ifr006'        /*  수정자                 */
          WHERE  IFR006.IF_STATUS in ('N','E')          /*  I/F상태, N:신규, S:성공, E:오류                */
          AND    IFR006.ARBPL     =  i_ARBPL
          AND    IFR006.WERKS     =  i_WERKS
          AND    IFR006.IF_IFR_NO =  i_IF_IFR_NO
    WHEN NOT MATCHED THEN
         INSERT (    MAS006.WERKS                         /*  플랜트                 */
                   , MAS006.SAP_WRK_CD                    /*  작업장(Work Center)-KHJ:ARBPL->SAP_WRK_CD       */
                   , MAS006.SAP_WRK_NM                    /*  작업장명-KHJ:KTEXT->SAP_WRK_NM                   */
                   , MAS006.DL_YN                         /*  삭제여부                 */
                   , MAS006.USE_YN                        /*  사용유무-KHJ:USE_FLAG->USE_YN                    */
                   , MAS006.REGDATE                       /*  등록일자-KHJ:MAKE_DATE->REGDATE                  */
                   , MAS006.REGID                         /*  등록자-KHJ:MAKER->REGID                         */
                   , MAS006.UPDDATE                       /*  수정일자-KHJ:EDIT_DATE->UPDDATE                  */
                   , MAS006.UPDID                         /*  수정자-KHJ:EDITOR->UPDID                        */
                     )
         VALUES (    IFR006.WERKS                          /*  플랜트                 */
                   , IFR006.ARBPL                          /*  작업장(Work Center)    */
                   , IFR006.KTEXT                          /*  작업장명                */
                   , IFR006.LVORM                          /*  삭제여부                 */
                   , case when IFR006.LVORM = 'Y' then 'N'
                          when IFR006.LVORM = 'N' then 'Y'
                          else 'Y'                           
                     end                                  /*  사용유무                */
                   , sysdate                              /*  등록일자                */
                   , 'sp_ifr006'                          /*  등록자                 */
                   , null                                 /*  수정일자                */
                   , null                                 /*  수정자                  */
                     )
         WHERE  IFR006.IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
         AND    IFR006.ARBPL     =  i_ARBPL
         AND    IFR006.WERKS     =  i_WERKS
         AND    IFR006.IF_IFR_NO =  i_IF_IFR_NO
           ;

    o_msg_MSG  :=  'TB_IFR006, 작업장(WorkCenterCode) 마스터 데이터가 수신되었습니다.1' || ',' || SQLERRM ;

    UPDATE  TB_IFR006
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')
    AND    ARBPL      =  i_ARBPL
    AND    WERKS      =  i_WERKS
    AND    IF_IFR_NO  =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR006, 작업장(WorkCenterCode) 마스터 데이터가 수신되었습니다.2' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR006, 작업장(WorkCenterCode) 마스터 수신 중 오류가 발생하였습니다.' || SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              ROLLBACK;

              UPDATE  TB_IFR006
              SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                    , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                    , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
              WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
              AND    ARBPL      =  i_ARBPL
              AND    WERKS      =  i_WERKS
              AND    IF_IFR_NO  =  i_IF_IFR_NO
              ;

END  sp_ifr006 ;
/* ------- TB_IFR006 : 작업장(WorkCenterCode) 마스터  Begin ---------------- */



/* ------- TB_IFR007 : 생산버전  Begin ---------------- */
PROCEDURE sp_ifr007 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_MATNR          IN   VARCHAR2
                      ,i_WERKS          IN   VARCHAR2
                      ,i_VERID          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
                      
  V_CNT   NUMBER  DEFAULT 0;
                        
BEGIN


    SELECT COUNT(MATNR) INTO V_CNT 
    FROM TB_MAS007 
    WHERE PRCMC    =  i_VERID
    AND WERKS      =  i_WERKS
    AND MATNR      =  i_MATNR;

    IF V_CNT > 0 THEN
           UPDATE TB_MAS007
           SET(  PRCMC_NM                                   /*  생산버전내용            */
               , BOM_NO                                     /*  BOM Num              */
               , ATN_BOM_NO                                 /*  대체BOM               */
               
               , DL_YN                                      /*  삭제플래그-KHJ변경:NVL처리             */
               , USE_YN                                     /*  사용유무               */
               , UPDDATE                                    /*  수정일자               */
               , UPDID                                      /*  수정자                 */
           )=
           (SELECT TEXT1                                    --생산버전내용 
                  ,NVL(STLAN, 'NULL')                         -- BOM Num               
                  ,STLAL                                    --대체BOM                                                
                  ,NVL(LVORM,'N')                             --삭제플래그-KHJ변경:NVL처리             */
                  
                  ,case when LVORM = 'Y' then 'N'
                        when LVORM = 'N' then 'Y'
                        else 'Y'                           
                   end                                     -- 사용유무                                                                  
                  ,sysdate                      					 --  수정일자 
                  ,'sp_ifr007'                  							 --  수정자 
            FROM TB_IFR007
            WHERE  IF_IFR_NO =  i_IF_IFR_NO
           )
           WHERE PRCMC      =  i_VERID
           AND WERKS      =  i_WERKS
           AND MATNR      =  i_MATNR;              

    ELSE
           INSERT INTO TB_MAS007(          
                    MATNR                                 /*  품목코드                                     */
                  , WERKS                                 /*  플랜트                                       */
                  , PRCMC                                 /*  생산버전                                     */
                  , PRCMC_NM                              /*  생산버전내용                                  */
                  , BOM_NO                                /*  BOM Num-KHJ:STLAN->STLNR                    */
                  , ATN_BOM_NO                            /*  대체BOM                                      */
                  , DL_YN                                 /*  삭제플래그                                    */
                  , USE_YN                                /*  사용유무-KHJ:USE_FLAG->USE_YN                 */
                  , REGDATE                               /*  등록일자-KHJ:MAKE_DATE->REGDATE               */
                  , REGID                                 /*  등록자-KHJ:MAKER->REGID                       */
                  , UPDDATE                               /*  수정일자-KHJ:EDIT_DATE->UPDDATE                */
                  , UPDID                                 /*  수정자-KHJ:EDITOR->UPDID                       */
           )
           SELECT   MATNR                                 /*  품목코드                */
                  , WERKS                                 /*  플랜트                 */
                  , VERID                                 /*  생산버전                */
                  , TEXT1                                 /*  생산버전내용             */
                  , NVL(STLAN,'NULL')                      /*  BOM Num                */
                  , STLAL                                 /*  대체BOM                */
                  , NVL(LVORM,'N')                        /*  삭제플래그-KHJ변경:NVL처리       */
                  , case when LVORM = 'Y' then 'N'
                         when LVORM = 'N' then 'Y'
                         else 'Y'                           
                    end                                     /*  사용유무                */
                  , sysdate                               /*  등록일자                */
                  , 'sp_ifr007'                               /*  등록자                 */
                  , null                                  /*  수정일자                */
                  , null                                  /*  수정자                  */
           FROM TB_IFR007           
           WHERE  IF_IFR_NO  =  i_IF_IFR_NO;

    END IF;



    o_msg_MSG  :=  'TB_IFR007, 생산버전 데이터가 수신되었습니다.1' || ',' || SQLERRM ;
    o_msg_code := '0' ;

    UPDATE  TB_IFR007
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    VERID      =  i_VERID
    AND    WERKS      =  i_WERKS
    AND    MATNR      =  i_MATNR
    AND    IF_IFR_NO  =  i_IF_IFR_NO
    ;

    o_msg_MSG  :=  'TB_IFR007, 생산버전 데이터가 수신되었습니다.2' || ',' || SQLERRM ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR007, 생산버전 수신 중 오류가 발생하였습니다.'|| SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              ROLLBACK;

              UPDATE  TB_IFR007
              SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                    , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                    , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
              WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
              AND    VERID      =  i_VERID
              AND    WERKS      =  i_WERKS
              AND    MATNR      =  i_MATNR
              AND    IF_IFR_NO  =  i_IF_IFR_NO
              ;

END  sp_ifr007 ;
/* ------- TB_IFR007 : 생산버전  Begin ---------------- */


/* ------- TB_IFR008 : BOM 마스터  Begin ---------------- */
PROCEDURE sp_ifr008 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_MATNR          IN   VARCHAR2 --모품목코드
                      ,i_WERKS          IN   VARCHAR2 --플랜트
                      ,i_STLNR          IN   VARCHAR2 --BOM Num
                      ,i_STLAL          IN   VARCHAR2 --대체BOM
                      ,i_POSNR          IN   VARCHAR2 --자품목항목
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT   NUMBER  DEFAULT 0;                      

BEGIN
           
    --데이트량증가로 인한 속도저하 개선
    SELECT COUNT(MATNR) INTO V_CNT 
    FROM TB_MAS008 
    WHERE MATNR = i_MATNR 
    AND WERKS = i_WERKS
    AND BOM_NO = i_STLNR
    AND ATN_BOM_NO = i_STLAL
    AND ITEM_NO = i_POSNR;

    IF V_CNT > 0 THEN
           UPDATE TB_MAS008
           SET(      PRT_MATNR_QTY                  /*  모품목기준수량-KHJ:BMENG->QTY           */
                   , PRT_MATNR_UNIT                 /*  모품목기준수량 단위-KHJ:BMEIN->UNIT       */
                   , SUB_MATNR                      /*  자품목자재-KHJ:IDNRK->SUB_MATNR               */
                   , SUB_MATNR_QTY                  /*  수량-KHJ:MENGE->SUB_QTY                   */
                   , SUB_MATNR_UNIT                 /*  수량단위-KHJ:MEINS->SUB_UNIT                */
                   , AUSCH                          /*  스크랩                 */
                   , ITSOB                          /*  특별유형                */
                   , DL_YN                          /*  삭제여부                */                                   
                   , USE_YN                         /* 사용유무-KHJ:USE_FLAG->USE_YN                      */
                                  
                   , UPDDATE                        /* 수정일자-KHJ:EDIT_DATE->UPDDATE                   */
                   , UPDID                          /* 수정자-KHJ:EDITOR->UPDID                           */
           )=
           (SELECT   BMENG                          /*  모품목기준수량            */
                   , BMEIN                          /*  모품목기준수량 단위        */
                   , IDNRK                          /*  자품목자재               */
                   , MENGE                          /*  수량                    */
                   , MEINS                          /*  수량단위                 */
                   , AUSCH                          /*  스크랩                  */
                   , ITSOB                          /*  특별유형                 */
                   , LKENZ                          /*  삭제여부                 */                   
                   , case when LKENZ = 'Y' then 'N'
                          when LKENZ = 'N' then 'Y'
                          else 'Y'                           
                     end                            /*  사용유무                */
                                                       
                  , sysdate                      		/* 수정일자-KHJ:EDIT_DATE->UPDDATE                   */
                  , 'sp_ifr008'                  				/* 수정자-KHJ:EDITOR->UPDID                           */
            FROM TB_IFR008
            WHERE  IF_IFR_NO =  i_IF_IFR_NO
           )
          WHERE MATNR = i_MATNR 
          AND WERKS = i_WERKS
          AND BOM_NO = i_STLNR
          AND ATN_BOM_NO = i_STLAL
          AND ITEM_NO = i_POSNR;               

    ELSE
           INSERT INTO TB_MAS008 
           (         MATNR                          /*  품목코드                */
                   , WERKS                          /*  플랜트                 */
                   , BOM_NO                         /*  BOM Num               */
                   , ATN_BOM_NO                     /*  대체BOM                */
                   , PRT_MATNR_QTY                  /*  모품목기준수량-KHJ:BMENG->QTY           */
                   , PRT_MATNR_UNIT                 /*  모품목기준수량 단위-KHJ:BMEIN->UNIT       */
                   , ITEM_NO                        /*  자품목항목                        */
                   , SUB_MATNR                      /*  자품목자재-KHJ:IDNRK->SUB_MATNR               */
                   , SUB_MATNR_QTY                  /*  수량-KHJ:MENGE->SUB_QTY                   */
                   , SUB_MATNR_UNIT                 /*  수량단위-KHJ:MEINS->SUB_UNIT                */
                   , AUSCH                          /*  스크랩                 */
                   , ITSOB                          /*  특별유형                */
                   , DL_YN                          /*  삭제여부                */
                   , USE_YN                         /*  사용유무-KHJ:USE_FLAG->USE_YN                */
                   
                   , REGDATE                        /*  등록일자-KHJ:MAKE_DATE->REGDATE                */
                   , REGID                          /*  등록자-KHJ:MAKER->REGID                  */
                   , UPDDATE                        /*  수정일자-KHJ:EDIT_DATE->UPDDATE                */
                   , UPDID                          /*  수정자-KHJ:EDITOR->UPDID                  */
           )
           SELECT    MATNR                          /*  품목코드                */
                   , WERKS                          /*  플랜트                  */
                   , STLNR                          /*  BOM Num                */
                   , STLAL                          /*  대체BOM                 */
                   , BMENG                          /*  모품목기준수량            */
                   , BMEIN                          /*  모품목기준수량 단위        */
                   , POSNR                          /*  자품목항목               */
                   , IDNRK                          /*  자품목자재               */
                   , MENGE                          /*  수량                    */
                   , MEINS                          /*  수량단위                 */
                   , AUSCH                          /*  스크랩                  */
                   , ITSOB                          /*  특별유형                 */
                   , LKENZ                          /*  삭제여부                 */
                   , case when LKENZ = 'Y' then 'N'
                          when LKENZ = 'N' then 'Y'
                          else 'Y'                           
                     end                            /*  사용유무                */
                                                
                   , sysdate                        /*  등록일자                */
                   , 'sp_ifr008'                        /*  등록자                 */
                   , null                           /*  수정일자                */
                   , null                           /*  수정자                  */
           FROM TB_IFR008           
           WHERE  IF_IFR_NO  =  i_IF_IFR_NO     
           ;

    END IF;                  
           
           
           
           

    o_msg_MSG  :=  'TB_IFR008, BOM 마스터 데이터가 수신되었습니다.1'|| o_msg_MSG || ',' || SQLERRM ;

    UPDATE  TB_IFR008
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    POSNR     =  i_POSNR
    AND    STLAL     =  i_STLAL
    AND    STLNR     =  i_STLNR
    AND    WERKS     =  i_WERKS
    AND    MATNR     =  i_MATNR
    AND    IF_IFR_NO =  i_IF_IFR_NO           
    ;

    o_msg_MSG  :=  'TB_IFR008, BOM 마스터 데이터가 수신되었습니다.2'|| o_msg_MSG || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR008, BOM 마스터 수신 중 오류가 발생하였습니다.'|| SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              ROLLBACK;

              UPDATE  TB_IFR008
              SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                    , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                    , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
              WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
              AND    POSNR     =  i_POSNR
              AND    STLAL     =  i_STLAL
              AND    STLNR     =  i_STLNR
              AND    WERKS     =  i_WERKS
              AND    MATNR     =  i_MATNR
              AND    IF_IFR_NO =  i_IF_IFR_NO           
              ;

END  sp_ifr008 ;
/* ------- TB_IFR008 : BOM 마스터  Begin ---------------- */

/* ------- TB_IFR009 : 거래처(고객사) 마스터  Begin -------------------------------- */
PROCEDURE sp_ifr009 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_KUNWE          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is

  V_CNT   NUMBER  DEFAULT 0;                                          
                      
BEGIN

    --데이트량증가로 인한 속도저하 개선(2022-10-16 김성하)
    SELECT COUNT(CUST_CD) INTO V_CNT 
    FROM TB_MAS009 MAS009 
    WHERE MAS009.CUST_DIV   =  'C'
    AND   MAS009.CUST_CD    =  i_KUNWE;
    
    IF V_CNT > 0 THEN

         UPDATE  TB_MAS009 MAS009
         SET (  	MAS009.CUST_NM 		                /*	CUSTNAME	,	납품처명			                        */
                ,	MAS009.PSTLZ 		                /*	PSTLZ	,	우편번호			                            */
                ,	MAS009.LAND1 		                /*	LAND1	,	국가키			                              */
                ,	MAS009.TELF1 		                /*	TELF1	,	전화번호			                            */
                ,	MAS009.TELF2 		                /*	TELF2	,	휴대폰번호			                            */
                ,	MAS009.TELFX 		                /*	TELFX	,	팩스번호			                            */
                ,	MAS009.SMTP_ADDR 		            /*	SMTP_ADDR	,	거래처담당자 email주소 (소속부서명)			 */
                ,	MAS009.STCD2	 		            /*	STCD2	,	사업자등록번호			                         */
                ,	MAS009.J_1KFREPRE 		            /*	J_1KFREPRE	,	대표자명			                        */
                ,	MAS009.DL_YN	 		            /*	LVORM	,	삭제여부			                              */
                ,	MAS009.ADDR1	 		            /*	ORT01	,	도시			                                */
                ,	MAS009.ADDR2	 		            /*	STRAS	,	번지 및 상세 주소			                      */
                ,	MAS009.KUNNR	 		            /*	KUNNR	,	판매처			                                */
                ,	MAS009.KUNNRT	 		            /*	KUNNRT	,	판매처명			                            */
                ,	MAS009.KUNZP	 		            /*	KUNZP	,	영업자ID			                              */
                ,	MAS009.KUNZPT	 		            /*	KUNZPT	,	영업사원명                           		*/
                ,	MAS009.TELFZP	 		            /*	TELFZP	,	영업사원 휴대폰 번호                 			*/
                ,	MAS009.J_1KFTIND 		            /*	J_1KFTIND	,	업태			                             */
                ,	MAS009.J_1KFTBUS 		            /*	J_1KFTBUS	,	업종			                             */
                --,	MAS009.CNAME	 		            /*	CNAME	,	거래처 담당자명			                        */
                --,	MAS009.CPHON	 		            /*	CPHON	,	거래처 담당자 휴대폰 번호1			                */
                --,	MAS009.PTNG01	 		            /*	PTNG01	,	거래처메모			                            */
                --,	MAS009.PTNL01	 		            /*	PTNL01	,	공급처구분 (원부자재,상품)			              */                               
                , MAS009.USE_YN                         /*  사용유무              */                                                    
                , MAS009.UPDDATE                        /*	EDIT_DATE	,	수정일자			                           */
                , MAS009.UPDID                          /*	EDITOR	,	수정자			                                */
         ) =
         (SELECT
                 IFR009.KUNWET		                /*	CUSTNAME	,	납품처명			                        */
                , IFR009.PSTLZ		                /*	PSTLZ	,	우편번호			                            */
                , IFR009.LAND1		                /*	LAND1	,	국가키			                              */
                , IFR009.TELF1		                /*	TELF1	,	전화번호			                            */
                , IFR009.TELF2		                /*	TELF2	,	휴대폰번호			                            */
                , IFR009.TELFX		                /*	TELFX	,	팩스번호			                            */
                , IFR009.SMTP_ADDR		            /*	SMTP_ADDR	,	거래처담당자 email주소 (소속부서명)			 */
                , IFR009.STCD2		                /*	STCD2	,	사업자등록번호			                         */
                , IFR009.J_1KFREPRE		            /*	J_1KFREPRE	,	대표자명			                        */
                , IFR009.LOEVM		                /*	LVORM	,	삭제여부			                              */
                , IFR009.ORT01		                /*	ORT01	,	도시			                                */
                , IFR009.STRAS		                /*	STRAS	,	번지 및 상세 주소			                      */
                , IFR009.KUNNR		                /*	KUNNR	,	판매처			                                */
                , IFR009.KUNNRT		                /*	KUNNRT	,	판매처명			                            */
                , IFR009.KUNZP		                /*	KUNZP	,	영업자ID			                              */
                , IFR009.KUNZPT		                /*	KUNZPT	,	영업사원명                           		*/
                , IFR009.TELFZP		                /*	TELFZP	,	영업사원 휴대폰 번호                 			*/
                , IFR009.J_1KFTIND		            /*	J_1KFTIND	,	업태			                             */
                , IFR009.J_1KFTBUS		            /*	J_1KFTBUS	,	업종			                             */
        --        , IFR009.CNAME		                /*	CNAME	,	거래처 담당자명			                        */
        --        , IFR009.CPHON		                /*	CPHON	,	거래처 담당자 휴대폰 번호1			                */
        --        , IFR009.PTNG01		                /*	PTNG01	,	거래처메모			                            */
        --        , IFR009.PTNL01		                /*	PTNL01	,	공급처구분 (원부자재,상품)			              */                               
                ,  case when IFR009.LOEVM = 'Y' then 'N'
                                                        when IFR009.LOEVM = 'N' then 'Y'  
                                                        else 'Y'  
                                                    end                                                 /*  사용유무              */                                                    
                , sysdate                          /*	EDIT_DATE	,	수정일자			                           */
                , 'sp_ifr009'                      /*	EDITOR	,	수정자			                                */
           FROM TB_IFR009 IFR009
          WHERE IFR009.IF_STATUS  in ('N','E')           /*  I/F상태, N:신규, S:성공, E:오류                */
            AND IFR009.KUNWE      =  i_KUNWE
            AND IFR009.IF_IFR_NO  =  i_IF_IFR_NO    
          )
          WHERE  MAS009.CUST_CD   =  i_KUNWE
          AND    MAS009.CUST_DIV   =  'C'; 
          
    ELSE

         INSERT INTO TB_MAS009 (  	
                    CUST_DIV		                 	         /*	CUSTTYPE->CUST_DIV	,	거래처구분                             */
                  ,	CUST_CD			                         /*	CUSTCODE->CUST_CD	,	납품처			                           */
                  ,	CUST_NM			                         /*	CUSTNAME->CUST_NM	,	납품처명			                         */
                  ,	PSTLZ			                         /*	PSTLZ	,	우편번호			                             */
                  ,	LAND1			                         /*	LAND1	,	국가키			                               */
                  ,	TELF1			                         /*	TELF1	,	전화번호			                             */
                  ,	TELF2			                         /*	TELF2	,	휴대폰번호			                             */
                  ,	TELFX			                         /*	TELFX	,	팩스번호			                             */
                  ,	SMTP_ADDR			                     /*	SMTP_ADDR	,	거래처담당자 email주소 (소속부서명)			 */
                  ,	STCD2			                         /*	STCD2	,	사업자등록번호			                         */
                  ,	J_1KFREPRE			                     /*	J_1KFREPRE	,	대표자명			                      */
                  ,	DL_YN			                         /*	LVORM	,	삭제여부			                            */
                  ,	ADDR1			                         /*	ADDR1	,	도시			                               */
                  ,	ADDR2			                         /*	ADDR2	,	번지 및 상세 주소			                    */
                  ,	KUNNR			                         /*	KUNNR	,	판매처			                               */
                  ,	KUNNRT			                         /*	KUNNRT	,	판매처명			                           */
                  ,	KUNZP			                         /*	KUNZP	,	영업자ID			                             */
                  ,	KUNZPT			                         /*	KUNZPT	,	영업사원명                           		*/
                  ,	TELFZP			                         /*	TELFZP	,	영업사원 휴대폰 번호                 			*/
                  ,	J_1KFTIND			                     /*	J_1KFTIND	,	업태			                            */
                  ,	J_1KFTBUS			                     /*	J_1KFTBUS	,	업종			                            */
                  ,	CNAME			                         /*	CNAME	,	거래처 담당자명			                       */
                  ,	CPHON			                         /*	CPHON	,	거래처 담당자 휴대폰 번호1			              */
                  ,	PTNG01			                         /*	PTNG01	,	거래처메모			                          */
                  ,	PTNL01			                         /*	PTNL01	,	공급처구분 (원부자재,상품)			            */
                  ,	USE_YN			                         /*	USE_FLAG->USE_YN	,	사용유무			                         */
                  ,	REGDATE			                         /*	MAKE_DATE->REGDATE	,	등록일자			                         */
                  ,	REGID			                         /*	MAKER->REGID	,	등록자			                               */
                  ,	UPDDATE			                         /*	EDIT_DATE->UPDDATE	,	수정일자			                         */
                  ,	UPDID			                         /*	EDITOR->UPDID	,	수정자			                             */
                )
         SELECT   'C'			                                     /*	CUSTTYPE	,	거래처구분			                      */
                  ,	IFR009.KUNWE			                         /*	CUSTCODE	,	납품처			                         */
                  ,	IFR009.KUNWET			                         /*	CUSTNAME	,	납품처명			                       */
                  ,	IFR009.PSTLZ			                         /*	PSTLZ	,	우편번호			                           */
                  ,	IFR009.LAND1			                         /*	LAND1	,	국가키			                              */
                  ,	IFR009.TELF1			                         /*	TELF1	,	전화번호			                            */
                  ,	IFR009.TELF2			                         /*	TELF2	,	휴대폰번호			                           */
                  ,	IFR009.TELFX			                         /*	TELFX	,	팩스번호			                            */
                  ,	IFR009.SMTP_ADDR			                     /*	SMTP_ADDR	,	거래처담당자 email주소 (소속부서명)			*/
                  ,	IFR009.STCD2			                         /*	STCD2	,	사업자등록번호			                        */
                  ,	IFR009.J_1KFREPRE			                     /*	J_1KFREPRE	,	대표자명			                      */
                  ,	IFR009.LOEVM			                         /*	LOEVM	,	삭제여부			                            */
                  ,	IFR009.ORT01			                         /*	ORT01	,	도시			                                */
                  ,	IFR009.STRAS			                         /*	STRAS	,	번지 및 상세 주소			                     */
                  ,	IFR009.KUNNR			                         /*	KUNNR	,	판매처			                                */
                  ,	IFR009.KUNNRT			                         /*	KUNNRT	,	판매처명			                           */
                  ,	IFR009.KUNZP			                         /*	KUNZP	,	영업자ID			                              */
                  ,	IFR009.KUNZPT			                         /*	KUNZPT	,	영업사원명                           		*/
                  ,	IFR009.TELFZP			                         /*	TELFZP	,	영업사원 휴대폰 번호                 			*/
                  ,	IFR009.J_1KFTIND			                     /*	J_1KFTIND	,	업태			                            */
                  ,	IFR009.J_1KFTBUS			                     /*	J_1KFTBUS	,	업종			                            */
                  ,	null			                                 /*	CNAME	,	거래처 담당자명			                       */
                  ,	null			                                 /*	CPHON	,	거래처 담당자 휴대폰 번호1			               */
                  ,	null                                             /*	PTNG01	,	거래처메모			                            */
                  ,	null                                             /*	PTNL01	,	공급처구분 (원부자재,상품)			             */
                  , case when IFR009.LOEVM = 'Y' then 'N'            
                         when IFR009.LOEVM = 'N' then 'Y'
                         else 'Y'
                    end                                              /*	USE_FLAG	,	사용유무			                          */
                  , sysdate                                    /*	MAKE_DATE	,	등록일자			                          */
                  , 'sp_ifr009'                                /*	MAKER	,	등록자			                                */
                  , null                                       /*	EDIT_DATE	,	수정일자			                          */
                  , null                                       /*	EDITOR	,	수정자			                              */
         FROM   TB_IFR009 IFR009           
         WHERE  IFR009.IF_STATUS in ('N','E')            /*  I/F상태, N:신규, S:성공, E:오류                */
         AND    IFR009.KUNWE     =  i_KUNWE
         AND    IFR009.IF_IFR_NO =  i_IF_IFR_NO ;
    
    END IF;
       

    o_msg_MSG  :=  'TB_IFR009, 거래처(고객사) 마스터 데이터가 수신되었습니다.1'|| o_msg_MSG || ',' || SQLERRM ;

    UPDATE  TB_IFR009
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    KUNWE     =  i_KUNWE
    AND    IF_IFR_NO =  i_IF_IFR_NO    
    ;

    o_msg_MSG  :=  'TB_IFR009, 거래처(고객사) 마스터 데이터가 수신되었습니다.2'|| o_msg_MSG || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR009, 거래처(고객사) 마스터 수신 중 오류가 발생하였습니다.'|| SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              ROLLBACK;

              UPDATE  TB_IFR009
              SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                    , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                    , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
              WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
              AND    KUNWE     =  i_KUNWE
              AND    IF_IFR_NO =  i_IF_IFR_NO    
              ;

END  sp_ifr009 ;
/* ------- TB_IFR009 : 거래처(고객사) 마스터  End -------------------------------- */


/* ------- TB_IFR010 : 거래처(공급사) 마스터  Begin -------------------------------- */
PROCEDURE sp_ifr010 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_ZCODE          IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
                      
    V_CNT   NUMBER  DEFAULT 0;                                          
  
BEGIN

    --데이트량증가로 인한 속도저하 개선(2022-10-16 김성하)
    SELECT COUNT(CUST_CD) INTO V_CNT 
    FROM TB_MAS009 MAS009 
    WHERE MAS009.CUST_DIV   =  'V'
    AND   MAS009.CUST_CD    =  i_ZCODE;
    
    IF V_CNT > 0 THEN

         UPDATE  TB_MAS009 MAS009
            SET ( 	MAS009.CUST_NM		        		                /*	CUSTNAME	,	납품처명			                        */
                ,	MAS009.PSTLZ		        		                /*	PSTLZ	,	우편번호			                            */
                ,	MAS009.LAND1		        		                /*	LAND1	,	국가키			                              */
                ,	MAS009.TELF1		        		                /*	TELF1	,	전화번호			                            */
                ,	MAS009.TELF2		        		                /*	TELF2	,	휴대폰번호			                            */
                ,	MAS009.TELFX		        		                /*	TELFX	,	팩스번호			                            */
                ,	MAS009.SMTP_ADDR		    		                /*	SMTP_ADDR	,	거래처담당자 email주소 (소속부서명)			 */
                ,	MAS009.STCD2		        		                /*	STCD2	,	사업자등록번호			                         */
                ,	MAS009.J_1KFREPRE		    		                /*	J_1KFREPRE	,	대표자명			                        */
                ,	MAS009.DL_YN		        		                /*	LOEVM	,	삭제여부			                              */
                ,	MAS009.ADDR1		        		                /*	ORT01	,	도시			                                */
                ,	MAS009.ADDR2		        		                /*	STRAS	,	번지 및 상세 주소			                      */
                --,	MAS009.KUNNR		        		                /*	KUNNR	,	판매처			                                */
                --,	MAS009.KUNNRT		        		                /*	KUNNRT	,	판매처명			                            */
                --,	MAS009.KUNZP		        		                /*	KUNZP	,	영업자ID			                              */
                --,	MAS009.KUNZPT		        		                /*	KUNZPT	,	영업사원명                           		*/
                --,	MAS009.TELFZP		        		                /*	TELFZP	,	영업사원 휴대폰 번호                 			*/
                ,	MAS009.J_1KFTIND		    		                /*	J_1KFTIND	,	업태			                             */
                ,	MAS009.J_1KFTBUS		    		                /*	J_1KFTBUS	,	업종			                             */
                ,	MAS009.CNAME		        		                /*	CNAME	,	거래처 담당자명			                        */
                ,	MAS009.CPHON		        		                /*	CPHON	,	거래처 담당자 휴대폰 번호1			                */
                ,	MAS009.PTNG01		        		                /*	PTNG01	,	거래처메모			                            */
                ,	MAS009.PTNL01		        		                /*	PTNL01	,	공급처구분 (원부자재,상품)			              */
                ,   MAS009.REGIO                                --지역
                
                ,   MAS009.USE_YN                                      /*  사용유무              */ 
                ,   MAS009.UPDDATE                                     /*	EDIT_DATE	,	수정일자			                           */
                ,   MAS009.UPDID                                       /*	EDITOR	,	수정자			                                */
         ) =
         (SELECT IFR010.NAME1		                /*	CUSTNAME	,	납품처명			                        */
                ,IFR010.PSTLZ		                /*	PSTLZ	,	우편번호			                            */
                ,IFR010.LAND1		                /*	LAND1	,	국가키			                              */
                ,IFR010.TELF1		                /*	TELF1	,	전화번호			                            */
                ,IFR010.TELF2		                /*	TELF2	,	휴대폰번호			                            */
                ,IFR010.TELFX		                /*	TELFX	,	팩스번호			                            */
                ,IFR010.SMTP_ADDR		            /*	SMTP_ADDR	,	거래처담당자 email주소 (소속부서명)			 */
                ,IFR010.STCD2		                /*	STCD2	,	사업자등록번호			                         */
                ,IFR010.J_1KFREPRE		            /*	J_1KFREPRE	,	대표자명			                        */
                ,IFR010.LOEVM		                /*	LOEVM	,	삭제여부			                              */
                ,IFR010.ADDR1		                /*	ORT01	,	도시			                                */
                ,IFR010.ADDR2		                /*	STRAS	,	번지 및 상세 주소			                      */
                --,IFR010.KUNNR		                /*	KUNNR	,	판매처			                                */
                --,IFR010.KUNNRT		                /*	KUNNRT	,	판매처명			                            */
                --,IFR010.KUNZPH		                /*	KUNZP	,	영업자ID			                              */
                --,IFR010.KUNZPT		                /*	KUNZPT	,	영업사원명                           		*/
                --,IFR010.TELFZP		                /*	TELFZP	,	영업사원 휴대폰 번호                 			*/
                ,IFR010.PTNL03		                /*	J_1KFTIND	,	업태			                             */
                ,IFR010.PTNL04		                /*	J_1KFTBUS	,	업종			                             */
                ,IFR010.CNAME		                /*	CNAME	,	거래처 담당자명			                        */
                ,IFR010.CPHON		                /*	CPHON	,	거래처 담당자 휴대폰 번호1			                */
                ,IFR010.PTNG01		                /*	PTNG01	,	거래처메모			                            */
                ,IFR010.PTNL01		                /*	PTNL01	,	공급처구분 (원부자재,상품)			              */
                ,IFR010.REGIO                    --지역
                
                ,case when IFR010.LOEVM = 'Y' then 'N'
                      when IFR010.LOEVM = 'N' then 'Y' 
                      else 'Y'   
                 end                                 /*  사용유무              */ 
                ,sysdate                               /*	EDIT_DATE	,	수정일자			                           */
                ,'sp_ifr010'                           /*	EDITOR	,	수정자			                                */
            FROM TB_IFR010 IFR010
          WHERE IFR010.IF_STATUS  in ('N','E')           /*  I/F상태, N:신규, S:성공, E:오류                */
            AND IFR010.ZCODE      =  i_ZCODE
            AND IFR010.IF_IFR_NO  =  i_IF_IFR_NO    
          )
          WHERE  MAS009.CUST_CD   =  i_ZCODE
          AND    MAS009.CUST_DIV   =  'V'; 

    ELSE

         INSERT  INTO TB_MAS009 (
                    CUST_DIV	                        /*	CUSTTYPE	,	거래처구분                             */
                  , CUST_CD	                            /*	CUSTCODE	,	납품처			                           */
                  , CUST_NM	                            /*	CUSTNAME	,	납품처명			                         */
                  , PSTLZ	                            /*	PSTLZ	,	우편번호			                             */
                  , LAND1	                            /*	LAND1	,	국가키			                               */
                  , TELF1	                            /*	TELF1	,	전화번호			                             */
                  , TELF2	                            /*	TELF2	,	휴대폰번호			                             */
                  , TELFX	                            /*	TELFX	,	팩스번호			                             */
                  , SMTP_ADDR                           /*	SMTP_ADDR	,	거래처담당자 email주소 (소속부서명)			 */
                  , STCD2	                            /*	STCD2	,	사업자등록번호			                         */
                  , J_1KFREPRE                          /*	J_1KFREPRE	,	대표자명			                      */
                  , DL_YN	                            /*	LOEVM	,	삭제여부			                            */
                  , ADDR1	                            /*	ADDR1	,	도시			                               */
                  , ADDR2	                            /*	ADDR2	,	번지 및 상세 주소			                    */
                  , KUNNR	                            /*	KUNNR	,	판매처			                               */
                  , KUNNRT	                            /*	KUNNRT	,	판매처명			                           */
                  , KUNZP	                            /*	KUNZP	,	영업자ID			                             */
                  , KUNZPT	                            /*	KUNZPT	,	영업사원명                           		*/
                  , TELFZP	                            /*	TELFZP	,	영업사원 휴대폰 번호                 			*/
                  , J_1KFTIND                           /*	J_1KFTIND	,	업태			                            */
                  , J_1KFTBUS                           /*	J_1KFTBUS	,	업종			                            */
                  , CNAME	                            /*	CNAME	,	거래처 담당자명			                       */
                  , CPHON	                            /*	CPHON	,	거래처 담당자 휴대폰 번호1			              */
                  , PTNG01	                            /*	PTNG01	,	거래처메모			                          */
                  , PTNL01	                            /*	PTNL01	,	공급처구분 (원부자재,상품)			            */
                  , REGIO              --지역
                            
                  , USE_YN	                            /*	USE_FLAG	,	사용유무			                         */
                  , REGDATE	                            /*	MAKE_DATE	,	등록일자			                         */
                  , REGID	                            /*	MAKER	,	등록자			                               */
                  , UPDDATE	                            /*	EDIT_DATE	,	수정일자			                         */
                  , UPDID	                            /*	EDITOR	,	수정자			                             */
                    )
         SELECT   'V'			                        /*	CUSTTYPE	,	거래처구분			                      */
                  ,	IFR010.ZCODE			                         /*	CUSTCODE	,	납품처			                         */
                  ,	IFR010.NAME1			                         /*	CUSTNAME	,	납품처명			                       */
                  ,	IFR010.PSTLZ			                         /*	PSTLZ	,	우편번호			                           */
                  ,	IFR010.LAND1			                         /*	LAND1	,	국가키			                              */
                  ,	IFR010.TELF1			                         /*	TELF1	,	전화번호			                            */
                  ,	IFR010.TELF2			                         /*	TELF2	,	휴대폰번호			                           */
                  ,	IFR010.TELFX			                         /*	TELFX	,	팩스번호			                            */
                  ,	IFR010.SMTP_ADDR			                     /*	SMTP_ADDR	,	거래처담당자 email주소 (소속부서명)			*/
                  ,	IFR010.STCD2			                         /*	STCD2	,	사업자등록번호			                        */
                  ,	IFR010.J_1KFREPRE			                     /*	J_1KFREPRE	,	대표자명			                      */
                  ,	IFR010.LOEVM			                         /*	LOEVM	,	삭제여부			                            */
                  ,	IFR010.ADDR1			                         /*	ORT01	,	도시			                                */
                  ,	IFR010.ADDR2			                         /*	STRAS	,	번지 및 상세 주소			                     */
                  ,	null			                                 /*	KUNNR	,	판매처			                                */
                  ,	null			                                 /*	KUNNRT	,	판매처명			                           */
                  ,	null			                                 /*	KUNZP	,	영업자ID			                              */
                  ,	null			                                 /*	KUNZPT	,	영업사원명                           		*/
                  ,	null			                                 /*	TELFZP	,	영업사원 휴대폰 번호                 			*/
                  ,	IFR010.PTNL03			                         /*	J_1KFTIND	,	업태			                            */
                  ,	IFR010.PTNL04			                         /*	J_1KFTBUS	,	업종			                            */
                  ,	IFR010.CNAME			                         /*	CNAME	,	거래처 담당자명			                       */
                  ,	IFR010.CPHON			                         /*	CPHON	,	거래처 담당자 휴대폰 번호1			               */
                  ,	IFR010.PTNG01                              /*	PTNG01	,	거래처메모			                            */
                  ,	IFR010.PTNL01                              /*	PTNL01	,	공급처구분 (원부자재,상품)			             */
                  , IFR010.REGIO                               --지역
                  
                  , case when IFR010.LOEVM = 'Y' then 'N'            
                         when IFR010.LOEVM = 'N' then 'Y'
                         else 'Y'
                    end                                              /*	USE_FLAG	,	사용유무			                          */                  
                  , sysdate                                    /*	MAKE_DATE	,	등록일자			                          */
                  , 'sp_ifr010'                                /*	MAKER	,	등록자			                                */
                  , null                                       /*	EDIT_DATE	,	수정일자			                          */
                  , null                                       /*	EDITOR	,	수정자			                              */
         FROM   TB_IFR010 IFR010
         WHERE  IFR010.IF_STATUS in ('N','E')            /*  I/F상태, N:신규, S:성공, E:오류                */
         AND    IFR010.ZCODE     =  i_ZCODE
         AND    IFR010.IF_IFR_NO =  i_IF_IFR_NO           ;
    
    END IF;

    o_msg_MSG  :=  'TB_IFR010, 거래처(공급사) 마스터 데이터가 수신되었습니다.1'|| o_msg_MSG || ',' || SQLERRM ;

    UPDATE  TB_IFR010
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    ZCODE     =  i_ZCODE
    AND    IF_IFR_NO =  i_IF_IFR_NO           
    ;

    o_msg_MSG  :=  'TB_IFR010, 거래처(공급사) 마스터 데이터가 수신되었습니다.2'|| o_msg_MSG || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR010, 거래처(공급사) 마스터 수신 중 오류가 발생하였습니다.'|| SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              ROLLBACK;

              UPDATE  TB_IFR010
              SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                    , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                    , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
              WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
              AND    ZCODE     =  i_ZCODE
              AND    IF_IFR_NO =  i_IF_IFR_NO           
              ;

END  sp_ifr010 ;
/* ------- TB_IFR010 : 거래처(공급사) 마스터  End -------------------------------- */


/* ------- TB_IFR011 : 실적취소 가능한 월  Begin ---------------- */
PROCEDURE sp_ifr011 (  i_IF_IFR_NO      IN   NUMBER   /* MES Interface Sequence(수신번호)        */
                      ,i_WERKS          IN   VARCHAR2
                      ,i_YYMM           IN   VARCHAR2
                      ,o_msg_CODE       OUT  VARCHAR2
                      ,o_msg_MSG        OUT  VARCHAR2  ) is
BEGIN

    MERGE
    INTO  TB_MAS011 MAS011
    USING TB_IFR011 IFR011
    ON    ( MAS011.YYMM       =  IFR011.YYMM
    AND     MAS011.WERKS      =  IFR011.WERKS
    AND     IFR011.YYMM       =  i_YYMM
    AND     IFR011.WERKS      =  i_WERKS 
    AND     IFR011.IF_IFR_NO  =  i_IF_IFR_NO           )
    WHEN MATCHED THEN
         UPDATE
         SET     MAS011.YMCHK     = IFR011.YMCHK         /*  실행가능여부(Y/N)          */
               , MAS011.USE_YN  = 'Y'                  /*  사용유무                  */
               , MAS011.UPDDATE =  sysdate             /*  수정일자                  */
               , MAS011.UPDID    =  'sp_ifr011'         /*  수정자                    */
          WHERE  IFR011.IF_STATUS in ('N','E')           /*  I/F상태, N:신규, S:성공, E:오류                */
          AND    IFR011.YYMM      =  i_YYMM
          AND    IFR011.WERKS     =  i_WERKS
          AND    IFR011.IF_IFR_NO =  i_IF_IFR_NO           
    WHEN NOT MATCHED THEN
         INSERT (    MAS011.WERKS                          /*  플랜트                 */
                   , MAS011.YYMM                           /*  월(ex : 202203)        */
                   , MAS011.YMCHK                          /*  실행가능여부(Y/N)        */
                   , MAS011.USE_YN                         /*  사용유무                */
                   , MAS011.REGDATE                        /*  등록일자                */
                   , MAS011.REGID                          /*  등록자                 */
                   , MAS011.UPDDATE                        /*  수정일자                */
                   , MAS011.UPDID                          /*  수정자                  */
                    )
         VALUES (   IFR011.WERKS                          /*  플랜트                 */
                  , IFR011.YYMM                           /*  월(ex : 202203)        */
                  , IFR011.YMCHK                          /*  실행가능여부(Y/N)        */
                  , 'Y'                                   /*  사용유무                */
                  , sysdate                               /*  등록일자                */
                  , 'sp_ifr011'                           /*  등록자                 */
                  , null                                  /*  수정일자                */
                  , null                                  /*  수정자                  */
                    )
         WHERE  IFR011.IF_STATUS in ('N','E')            /*  I/F상태, N:신규, S:성공, E:오류                */
         AND    IFR011.YYMM      =  i_YYMM
         AND    IFR011.WERKS     =  i_WERKS
         AND    IFR011.IF_IFR_NO =  i_IF_IFR_NO           
           ;

    o_msg_MSG  :=  'TB_IFR011, 실적취소 가능한 월 데이터가 수신되었습니다.1'|| o_msg_MSG  || ',' || SQLERRM ;

    UPDATE  TB_IFR011
    SET     IF_STATUS   =  'S'                /*  I/F상태, N:신규, S:성공, E:오류               */
          , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
          , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
    WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
    AND    YYMM      =  i_YYMM
    AND    WERKS     =  i_WERKS
    AND    IF_IFR_NO =  i_IF_IFR_NO           
    ;

    o_msg_MSG  :=  'TB_IFR011, 실적취소 가능한 월 데이터가 수신되었습니다.2'|| o_msg_MSG  || ',' || SQLERRM ;
    o_msg_code := '0' ;

    EXCEPTION
          WHEN OTHERS THEN
              o_msg_msg       := 'TB_IFR011, 실적취소 가능한 월 수신 중 오류가 발생하였습니다.'|| SQLERRM ;
              o_msg_code      := '-1' ;
              DBMS_OUTPUT.PUT_LINE (o_msg_msg );
              ROLLBACK;

              UPDATE  TB_IFR011
              SET     IF_STATUS   =  'E'                /*  I/F상태, N:신규, S:성공, E:오류               */
                    , IF_SET_DATE =  sysdate            /*  데이터 처리시간(MES I/F 테이블 → MES 운영테이블) */
                    , IF_ERR_MESS =  o_msg_MSG          /*  데이터 처리 결과 Message(Oracle)              */
              WHERE  IF_STATUS in ('N','E')             /*  I/F상태, N:신규, S:성공, E:오류                */
              AND    YYMM      =  i_YYMM
              AND    WERKS     =  i_WERKS
              AND    IF_IFR_NO =  i_IF_IFR_NO           
              ;

END  sp_ifr011 ;

/* ------- TB_IFR011 : 실적취소 가능한 월  Begin ---------------- */




BEGIN

/* ------- TB_IFR001 : 자재기준정보 수신 (Interface)  Begin ---------------- */
    IF  i_IF_MES_ID  = 'MES_IF_101'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_101==>START');

        for ifr001 in cur_ifr001 loop
        
            --공통코드 구성하는것 속도개선하여 주석해제함. 22-06-28
            sp_com_set_cmcdv(   i_CMCDKY      => 'MTART'                       	-- 유형                 
                              , i_SHORTX      => '자재유형'                         -- 유형                 
                              , i_CMCDVL      => ifr001.mtart                   -- 유형                 
                              , i_CDESC1      => ifr001.mtbez                   -- 유형명                
                              , o_msg_CODE    => o_msg_CODE
                              , o_msg_MSG     => o_msg_MSG    ) ;
            sp_com_set_cmcdv(   i_CMCDKY      => 'MATKL'                        -- 자재그룹               
                              , i_SHORTX      => '자재그룹명'                        -- 자재그룹               
                              , i_CMCDVL      => ifr001.matkl                   -- 자재그룹               
                              , i_CDESC1      => ifr001.wgbez                   -- 자재그룹명             
                              , o_msg_CODE    => o_msg_CODE
                              , o_msg_MSG     => o_msg_MSG    ) ;
            sp_com_set_cmcdv(   i_CMCDKY      => 'SPART'                        -- 제품군                
                              , i_SHORTX      => '제품군명'                         -- 제품군                
                              , i_CMCDVL      => ifr001.spart                   -- 제품군                
                              , i_CDESC1      => ifr001.vtext                   -- 제품군명               
                              , o_msg_CODE    => o_msg_CODE
                              , o_msg_MSG     => o_msg_MSG    ) ;
            sp_com_set_cmcdv(   i_CMCDKY      => 'MMSTA'                        -- 플랜트고유자재상태       
                              , i_SHORTX      => '플랜트고유자재상태'                   -- 플랜트고유자재상태       
                              , i_CMCDVL      => ifr001.mmsta                   -- 플랜트고유자재상태       
                              , i_CDESC1      => ifr001.mmstatxt                -- 플랜트고유자재상태명     
                              , o_msg_CODE    => o_msg_CODE
                              , o_msg_MSG     => o_msg_MSG    ) ;
            sp_com_set_cmcdv(   i_CMCDKY      => 'MSTAE'                        -- 자재상태               
                              , i_SHORTX      => '자재상태'                         -- 자재상태               
                              , i_CMCDVL      => ifr001.mstae                   -- 자재상태               
                              , i_CDESC1      => ifr001.mstaetxt                -- 자재상태명              
                              , o_msg_CODE    => o_msg_CODE
                              , o_msg_MSG     => o_msg_MSG    ) ;
            sp_com_set_cmcdv(   i_CMCDKY      => 'MATTYPE'                      -- HL LOT 구분           
                              , i_SHORTX      => 'HL LOT 구분'                    -- HL LOT 구분           
                              , i_CMCDVL      => ifr001.mattype                 -- HL LOT 구분           
                              , i_CDESC1      => ifr001.mattptxt                -- HL LOT 구분명          
                              , o_msg_CODE    => o_msg_CODE
                              , o_msg_MSG     => o_msg_MSG    ) ;
            sp_com_set_cmcdv(   i_CMCDKY      => 'DIVISION'                     -- 사업부                 
                              , i_SHORTX      => '사업부'                          -- 사업부                 
                              , i_CMCDVL      => ifr001.division                -- 사업부                 
                              , i_CDESC1      => ifr001.dvtxt                   -- 사업부명               
                              , o_msg_CODE    => o_msg_CODE
                              , o_msg_MSG     => o_msg_MSG    ) ;
            sp_com_set_cmcdv(   i_CMCDKY      => 'BRAND_ID'                     -- 브랜드                
                              , i_SHORTX      => '브랜드'                          -- 브랜드                
                              , i_CMCDVL      => ifr001.brand_id                -- 브랜드                
                              , i_CDESC1      => ifr001.brand_descr             -- 브랜드명              
                              , o_msg_CODE    => o_msg_CODE
                              , o_msg_MSG     => o_msg_MSG    ) ;
            sp_com_set_cmcdv(   i_CMCDKY      => 'PCODE'                        -- 지종                 
                              , i_SHORTX      => '지종'                           -- 지종                 
                              , i_CMCDVL      => ifr001.pcode                   -- 지종                 
                              , i_CDESC1      => ifr001.pcodetxt                -- 지종명                
                              , o_msg_CODE    => o_msg_CODE
                              , o_msg_MSG     => o_msg_MSG    ) ;
            

            sp_ifr001( ifr001.if_ifr_no
                      --,ifr001.IF_MES_ID
                      --,ifr001.IF_MES_KEY
                      ,ifr001.matnr
                      ,ifr001.werks
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;
                      
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_101 개별처리중 ERROR==>'||to_char(ifr001.if_ifr_no) || ',' || ifr001.matnr || ',' || ifr001.werks || ',' ||o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;
        
        --처리후 P400은 제외 함.
        DELETE FROM TB_IFR001 WHERE WERKS = 'P400';        
        Commit ;
        

        DBMS_OUTPUT.PUT_LINE('MES_IF_101==>END');

    END IF ;
/* ------- TB_IFR001 : 자재기준정보 수신 (Interface)  End ---------------- */


/* ------- TB_IFR002 : 플랜트 마스터  Begin ---------------- */
    IF  i_IF_MES_ID  = 'MES_IF_102'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_102==>START');

        for ifr002 in cur_ifr002 loop

            sp_ifr002( ifr002.if_ifr_no
                      ,ifr002.WERKS
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_102 개별처리중 ERROR==>'||ifr002.werks || ',' ||o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;
        
        DBMS_OUTPUT.PUT_LINE('MES_IF_102==>END');        

    END IF ;
/* ------- TB_IFR002 : 플랜트 마스터  End ---------------- */



/* ------- TB_IFR003 : 저장위치 마스터  Begin ---------------- */
    IF  i_IF_MES_ID       = 'MES_IF_103'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_103==>START');
        
        for ifr003 in cur_ifr003 loop

            sp_ifr003( ifr003.IF_IFR_NO
                      ,ifr003.WERKS
                      ,ifr003.LGORT
                      ,ifr003.LGOBE
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_103 개별처리중 ERROR==>'||ifr003.werks || ',' ||  ifr003.lgort || ',' ||o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;
        
        DBMS_OUTPUT.PUT_LINE('MES_IF_103==>END');        

    END IF ;
/* ------- TB_IFR003 : 저장위치 마스터  End ---------------- */


/* ------- SAP와 협의 후 I/F 대상에서 제외
\* ------- TB_IFR004 : 저장위치 마스터  Begin ---------------- *\
    IF  i_IF_MES_ID       = ' '           OR
        i_IF_MES_ID       is null         THEN

        for ifr004 in cur_ifr004 loop

            sp_ifr004( ifr004.MSEHI
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE(ifr004.MSEHI || ',' ||  o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;

    END IF ;
\* ------- TB_IFR004 : 저장위치 마스터  End ---------------- *\
*/

/* ------- TB_IFR005 : 자재별 단위환산 마스터  Begin ---------------- */
    IF  i_IF_MES_ID  = 'MES_IF_105'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_105==>START');

        for ifr005 in cur_ifr005 loop

            sp_ifr005( ifr005.IF_IFR_NO
                      ,ifr005.MATNR
                      ,ifr005.MSEHI
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_105 개별처리중 ERROR==>'||ifr005.MATNR || ',' ||  ifr005.MSEHI || ',' ||o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;
        
        DBMS_OUTPUT.PUT_LINE('MES_IF_105==>END');        

    END IF ;
/* ------- TB_IFR005 : 자재별 단위환산 마스터  End ---------------- */


/* ------- TB_IFR006 : 작업장(WorkCenterCode) 마스터  Begin ---------------- */
    IF  i_IF_MES_ID  = 'MES_IF_106'  THEN


        DBMS_OUTPUT.PUT_LINE('MES_IF_106==>START');
        
        for ifr006 in cur_ifr006 loop

            sp_ifr006( ifr006.IF_IFR_NO
                      ,ifr006.WERKS
                      ,ifr006.ARBPL
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_106 개별처리중 ERROR==>'||ifr006.WERKS || ',' ||  ifr006.ARBPL || ',' ||o_msg_MSG) ;
            END IF ;

            Commit ;

        end loop;
        
        DBMS_OUTPUT.PUT_LINE('MES_IF_106==>END');        

    END IF ;
/* ------- TB_IFR006 : 작업장(WorkCenterCode) 마스터  End ---------------- */


/* ------- TB_IFR007 : 생산버전  Begin ---------------- */
    IF  i_IF_MES_ID  = 'MES_IF_107'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_107==>START');
        for ifr007 in cur_ifr007 loop

            sp_ifr007( ifr007.IF_IFR_NO
                      ,ifr007.MATNR
                      ,ifr007.WERKS
                      ,ifr007.VERID
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_107 개별처리중 ERROR==>'||ifr007.MATNR || ',' ||  ifr007.WERKS || ',' || ifr007.VERID || ',' ||o_msg_MSG ) ;
            END IF ;

            Commit ;

        end loop;
        DBMS_OUTPUT.PUT_LINE('MES_IF_107==>END');        

    END IF ;
/* ------- TB_IFR007 : 생산버전  End ---------------- */


/* ------- TB_IFR008 : BOM 마스터  Begin ---------------- */
    IF  i_IF_MES_ID  = 'MES_IF_110'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_110==>START');
        
        for ifr008 in cur_ifr008 loop

            sp_ifr008( ifr008.IF_IFR_NO
                      ,ifr008.MATNR
                      ,ifr008.WERKS
                      ,ifr008.STLNR
                      ,ifr008.STLAL
                      ,ifr008.POSNR
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;

            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_110 개별처리중 ERROR==>'||ifr008.MATNR || ',' ||  ifr008.WERKS || ',' || ifr008.STLNR || ',' || ifr008.STLAL || ',' || ifr008.STLAL || ',' || o_msg_MSG ) ;
            END IF ;

            Commit ;

        end loop;
        
        DBMS_OUTPUT.PUT_LINE('MES_IF_110==>END');        

    END IF ;
/* ------- TB_IFR008 : BOM 마스터  End ---------------- */


/* ------- TB_IFR009 : 거래처(고객사) 마스터  Begin -------------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_111'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_111==>START'); 
        
        for ifr009 in cur_ifr009 loop

            sp_ifr009( ifr009.IF_IFR_NO
                      ,ifr009.KUNWE
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;

            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_111 개별처리중 ERROR==>'||ifr009.KUNWE || o_msg_MSG ) ;
            END IF ;

            Commit ;

        end loop;
        
        DBMS_OUTPUT.PUT_LINE('MES_IF_111==>END');        

    END IF ;
/* ------- TB_IFR009 : 거래처(고객사) 마스터  End -------------------------------- */


/* ------- TB_IFR010 : 거래처(공급사) 마스터  Begin -------------------------------- */
    IF  i_IF_MES_ID  = 'MES_IF_112'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_112==>START'); 

        for ifr010 in cur_ifr010 loop

            sp_ifr010( ifr010.IF_IFR_NO
                      ,ifr010.ZCODE
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;

            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_112 개별처리중 ERROR==>'||ifr010.ZCODE || o_msg_MSG ) ;
            END IF ;

            Commit ;

        end loop;
        
        DBMS_OUTPUT.PUT_LINE('MES_IF_112==>END');         

    END IF ;
/* ------- TB_IFR010 : 거래처(공급사) 마스터  End -------------------------------- */


/* ------- TB_IFR011 : 실적취소 가능한 월  Begin ---------------- */
    IF  i_IF_MES_ID  = 'MES_IF_113'  THEN

        DBMS_OUTPUT.PUT_LINE('MES_IF_113==>START'); 

        for ifr011 in cur_ifr011 loop

            sp_ifr011( ifr011.IF_IFR_NO
                      ,ifr011.WERKS
                      ,ifr011.YYMM
                      ,o_msg_CODE
                      ,o_msg_MSG
                      ) ;
            IF o_msg_CODE <> '0' THEN
               DBMS_OUTPUT.PUT_LINE('MES_IF_113 개별처리중 ERROR==>'|| ifr011.WERKS || ',' || ifr011.YYMM || ',' || o_msg_MSG ) ;
            END IF ;

            Commit ;

        end loop;
        
        DBMS_OUTPUT.PUT_LINE('MES_IF_113==>END');        

    END IF ;
/* ------- TB_IFR011 : 실적취소 가능한 월  End ---------------- */



EXCEPTION
  WHEN OTHERS THEN
    o_msg_code      := '-1' ;
    o_msg_msg       := 'Error,기준정보 수신 중 MAIN에서 오류가 발생하였습니다.' ||
                       ',' || to_char(SQLCODE) || ',' || SQLERRM ;
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    rollback ;

END SP_MAS_GET_IFR ;
/
