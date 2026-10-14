--------------------------------------------------------
--  DDL for Procedure SP_COM_SET_CMCDV
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_COM_SET_CMCDV" (   i_CMCDKY           IN    VARCHAR2    /*  Common code key               */
                                                ,i_SHORTX	          IN    VARCHAR2    /*  Short text                    */
                                                ,i_CMCDVL	          IN    VARCHAR2    /*  Common code value             */
                                                ,i_CDESC1	          IN    VARCHAR2    /*  Code description              */
                                                ,o_msg_CODE         OUT   VARCHAR2
                                                ,o_msg_MSG          OUT   VARCHAR2
                                              ) is

/*==============================================================================
 * PROGRAM ID    : SP_COM_SET_CMCDV{호출 프로그램 ID 기술}
 * PROGRAM NAME  : 공통코드 저장 {호출 프로그램 명 기술}
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : SAP에서 넘어오는 공통코드를 저장한다.{프로그램에 대한 상세한 내용 기술}
 *                 
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : {최초 작성일자 기술}
 * SYSTEM NAME   : MES
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * yyyy/mm/dd    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블
 *        - [CMCDM] : (CRU.) 공통코드 헤더
 *        - [CMCDV] : (CRU.) 공통코드 상세                         
 *=============================================================================*/                                              
                                              
  V_CNT           NUMBER          := 0;      -- 카운트(작업지시존재여부)

BEGIN

/* ------- CMCDM : [MASTER] 공통코드 해더  Begin ---------------- */

    IF i_CMCDKY  is null    OR
       i_SHORTX  is null    THEN
       o_msg_code      := '0' ;
       o_msg_msg       := '코드 마스터에 공통코드 값이 없습니다.';
       Return ;
    END IF ;

    --공통코드MASTER존재유무 확인
    SELECT COUNT(CMCDKY) INTO V_CNT
    FROM CMCDM
    WHERE CMCDKY      =  i_CMCDKY;

    IF V_CNT > 0 THEN
        UPDATE CMCDM
        SET     SHORTX		=	i_SHORTX		                        /*	SHORTX		Short text			                      */
              ,	DBFILD		=	i_CMCDKY		                        /*	DBFILD		Database field name			              */
              ,	LMODAT		=	trim(to_char(sysdate,'yyyymmdd'))		/*	LMODAT		수정일자			                          */
              ,	LMOTIM		=	trim(to_char(sysdate,'hh24miss'))		/*	LMOTIM		수정시간			                          */
              ,	LMOUSR		=	'SP_COM_SET_CMCDV'		              /*	LMOUSR		수정자			                            */
        WHERE  CMCDKY     = i_CMCDKY;                              /*	CMCDKY		Common code key			                  */    
    ELSE
         INSERT INTO CMCDM(    	
                      CMCDKY				                                /*	CMCDKY		Common code key			                  */
                    ,	SHORTX				                                /*	SHORTX		Short text			                      */
                    ,	DBFILD				                                /*	DBFILD		Database field name			              */
                    ,	USARL1				                                /*	USARL1		User argument label 1		              */
                    ,	USARL2				                                /*	USARL2		User argument label 2		              */
                    ,	USARL3				                                /*	USARL3		User argument label 3		              */
                    ,	USARL4				                                /*	USARL4		User argument label 4		              */
                    ,	USARL5				                                /*	USARL5		User argument label 5		              */
                    ,	SYONLY				                                /*	SYONLY		System uses only			                */
                    ,	CREDAT				                                /*	CREDAT		생성일자			                          */
                    ,	CRETIM				                                /*	CRETIM		생성시간			                          */
                    ,	CREUSR				                                /*	CREUSR		생성자			                            */
                    ,	LMODAT				                                /*	LMODAT		수정일자			                          */
                    ,	LMOTIM				                                /*	LMOTIM		수정시간			                          */
                    ,	LMOUSR				                                /*	LMOUSR		수정자			                            */
                    ,	INDBZL				                                /*	INDBZL		Business logic indicator			        */
                    ,	INDARC				                                /*	INDARC		Archive indicator			                */
                    ,	UPDCHK				                                /*	UPDCHK		Update check			                    */
         )VALUES (    
                      i_CMCDKY			                                /*	CMCDKY		Common code key			                  */
                    ,	i_SHORTX			                                /*	SHORTX		Short text			                      */
                    ,	i_CMCDKY			                                /*	DBFILD		Database field name			              */
                    ,	null				                                  /*	USARL1		User argument label 1			            */
                    ,	null				                                  /*	USARL2		User argument label 2			            */
                    ,	null				                                  /*	USARL3		User argument label 3			            */
                    ,	null				                                  /*	USARL4		User argument label 4			            */
                    ,	null				                                  /*	USARL5		User argument label 5			            */
                    ,	null				                                  /*	SYONLY		System uses only			                */
                    ,	trim(to_char(sysdate,'yyyymmdd'))				      /*	CREDAT		생성일자			                          */
                    ,	trim(to_char(sysdate,'hh24miss'))				      /*	CRETIM		생성시간			                          */
                    ,	'SP_COM_SET_CMCDV'				                    /*	CREUSR		생성자			                            */
                    ,	null				                                  /*	LMODAT		수정일자			                          */
                    ,	null				                                  /*	LMOTIM		수정시간			                          */
                    ,	null				                                  /*	LMOUSR		수정자			                            */
                    ,	null				                                  /*	INDBZL		Business logic indicator			        */
                    ,	null				                                  /*	INDARC		Archive indicator			                */
                    ,	0				                                      /*	UPDCHK		Update check			                    */
                      )   ;    
    END IF;             
/* ------- CMCDM : [MASTER] 공통코드 해더  End ---------------- */


/* ------- CMCDV : [MASTER] 공통코드 아이템 Begin ---------------- */
    IF i_CMCDVL  is null    OR
       i_CDESC1  is null    THEN
       o_msg_code      := '0' ;
       o_msg_msg       := '코드 마스터에 공통코드 항목 값이 없습니다.';
       Return ;
    END IF ;

    --공통코드DETAIL존재유무 확인
    SELECT COUNT(CMCDKY) INTO V_CNT
    FROM CMCDV
    WHERE CMCDVL      =  i_CMCDVL
    AND   CMCDKY      =  i_CMCDKY;

    IF V_CNT > 0 THEN
         UPDATE CMCDV
         SET       	CDESC1		=	i_CDESC1		                        /*	CDESC1		Code description			                */
                  ,	LMODAT		=	trim(to_char(sysdate,'yyyymmdd'))		/*	LMODAT		수정일자			                          */
                  ,	LMOTIM		=	trim(to_char(sysdate,'hh24miss'))		/*	LMOTIM		수정시간			                          */
                  ,	LMOUSR		=	'SP_COM_SET_CMCDV'		              /*	LMOUSR		수정자			                            */
          WHERE   CMCDV.CMCDVL     = i_CMCDVL                       /*	CMCDVL		Common code value			                */
          AND     CMCDV.CMCDKY     = i_CMCDKY;                      /*	CMCDKY		Common code key			                  */    
    ELSE
         INSERT INTO CMCDV(    	
                      CMCDKY				                                /*	CMCDKY		Common code key			                  */
                    ,	CMCDVL				                                /*	CMCDVL		Common code value			                */
                    ,	CDESC1				                                /*	CDESC1		Code description			                */
                    ,	CDESC2				                                /*	CDESC2		Code description 2			              */
                    ,	USARG1				                                /*	USARG1		User argument 1			                  */
                    ,	USARG2				                                /*	USARG2		User argument 2			                  */
                    ,	USARG3				                                /*	USARG3		User argument 3			                  */
                    ,	USARG4				                                /*	USARG4		User argument 4			                  */
                    ,	USARG5				                                /*	USARG5		User argument 5			                  */
                    ,	CREDAT				                                /*	CREDAT		생성일자			                          */
                    ,	CRETIM				                                /*	CRETIM		생성시간			                          */
                    ,	CREUSR				                                /*	CREUSR		생성자			                             */
                    ,	LMODAT				                                /*	LMODAT		수정일자			                          */
                    ,	LMOTIM				                                /*	LMOTIM		수정시간			                          */
                    ,	LMOUSR				                                /*	LMOUSR		수정자			                             */
                    ,	INDBZL				                                /*	INDBZL		Business logic indicator			         */
                    ,	INDARC				                                /*	INDARC		Archive indicator			                 */
                    ,	UPDCHK				                                /*	UPDCHK		Update check			                     */
        )VALUES (     
                      i_CMCDKY				                              /*	CMCDKY		Common code key			                  */
                    ,	i_CMCDVL				                              /*	CMCDVL		Common code value			                */
                    ,	i_CDESC1				                              /*	CDESC1		Code description			                */
                    ,	null				                                  /*	CDESC2		Code description 2			              */
                    ,	null				                                  /*	USARG1		User argument 1			                  */
                    ,	null				                                  /*	USARG2		User argument 2			                  */
                    ,	null				                                  /*	USARG3		User argument 3			                  */
                    ,	null				                                  /*	USARG4		User argument 4			                  */
                    ,	null				                                  /*	USARG5		User argument 5			                  */
                    ,	trim(to_char(sysdate,'yyyymmdd'))				      /*	CREDAT		생성일자			                          */
                    ,	trim(to_char(sysdate,'hh24miss'))				      /*	CRETIM		생성시간			                          */
                    ,	'SP_COM_SET_CMCDV'				                    /*	CREUSR		생성자			                             */
                    ,	null				                                  /*	LMODAT		수정일자			                          */
                    ,	null				                                  /*	LMOTIM		수정시간			                          */
                    ,	null				                                  /*	LMOUSR		수정자			                             */
                    ,	null				                                  /*	INDBZL		Business logic indicator			         */
                    ,	null				                                  /*	INDARC		Archive indicator			                 */
                    ,	0				                                      /*	UPDCHK		Update check			                     */
        );    
    END IF;   

/* ------- CMCDV : [MASTER] 공통코드 아이템 End ---------------- */

EXCEPTION
  WHEN OTHERS THEN
    o_msg_code      := '-1' ;
    o_msg_msg       := 'Error,코드 마스터 저장 중 오류가 발생하였습니다.' ||
                       ',' || to_char(SQLCODE) || ',' || SQLERRM ;
    DBMS_OUTPUT.PUT_LINE(o_msg_msg);
    --rollback ;

END;

/
