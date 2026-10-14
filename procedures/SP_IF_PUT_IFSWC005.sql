
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_IF_PUT_IFSWC005" (
   i_IF_MES_ID        IN    VARCHAR2
  ,i_IF_MES_KEY       IN    VARCHAR2
  ,o_msg_code         OUT   VARCHAR2
  ,o_msg_msg          OUT   VARCHAR2
)
/*==============================================================================
 * PROGRAM ID    : 
 * PROGRAM NAME  : 인터페이스-밀롤 바코드 삭제(폐기) 정보 (MES->WCS)
 * VERSION       : 1.0.0{최종 버전 기술}
 * DESCRIPTION   : 밀롤 바코드 삭제(폐기) 정보 (MES->WCS)
 *                  
 *                  
 * AUTHOR NAME   : 강현주{최초 작성자 명 기술}
 * CREATE DATE   : 2022/06/29 {최초 작성일자 기술}
 * SYSTEM NAME   : MES->WCS
 * MAIN PROCEDURE: {주(상위) 프로시저 명칭 기술}  <생략가능>
 * SUB PROCEDURE : {아휘 프로시저 명칭 기술}      <생략가능>
 * SUB PACKAGES  : {하위 패키지 기술}            <생략가능>
 * OLD PROGRAM ID: {이전 시스템 프로그램 명 기술} <생략가능>
 * REVERSION HISTORY
 * ------------ ------- ------------- ------------------------------------------
 *    Date        Ver       Name          Description      
 * ------------ ------- ------------- ------------------------------------------
 * 2022/06/29    1.0.0   강현주         Initial Version 
 *==============================================================================
 *  관련 테이블    
 *       - [TB_IFSWC005]  : (.RU.) 밀롤 바코드 삭제(폐기) 정보
 *=============================================================================*/
AS

  V_CNT       NUMBER  DEFAULT 0;
  V_IF_SEQ    NUMBER;  
  V_SYS_DT    VARCHAR2(20)  DEFAULT TO_CHAR(sysdate,'YYYYMMDD');  
BEGIN
  DECLARE
    CURSOR  cur_list IS
      SELECT   DOC_NO                        --문서번호
              ,DOC_NOSEQ                     --문서번호 순번
							,CAST(SUBSTR(DOC_NO,-5) AS NUMBER) IF_SEQ--WCS KEY               
              ,IND_BCD     									 --밀롤바코드      
							,LOT_NO                        --MRLOT NO   
							,DISCARD_CODE                  --취소/폐기 사유 구분
							,DISCARD_RMK                   --취소/폐기 사유   
							,REGDATE                       --등록일시       
							,REGID                         --등록자        
							,UPDDATE                       --수정일시       
							,UPDID                         --수정자        
							,REMARK1                       --비고1        
							,REMARK2                       --비고2        
							,REMARK3                       --비고3        
							,REMARK4                       --비고4        
							,REMARK5                       --비고5        
							,REMARK6                       --비고6        
							,REMARK7                       --비고7        
							,REMARK8                       --비고8        
							,REMARK9                       --비고9        
							,REMARK10                      --비고10                             
							,IF_STATUS                    	--WCS 결과값 Return( N: 대기, S:성공, E:오류 )
							,IF_GET_DATE                  	--MES 등록일시                           
							,IF_SET_DATE                  	--WCS 전송일시                           
							,IF_ERR_MESS                  	--WCS 결과 메시지                         
							,IF_MES_KEY                   	--MES Inserface Key(MES->WCS)         
      FROM    TB_IFSWC005
      WHERE   NVL(IF_STATUS,'N')  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */
      --WHERE   NVL(IF_STATUS,'N')  in  ( 'N','E' )           /*  I/F상태, N:신규, S:성공, E:오류            */      
      ORDER BY DOC_NO, DOC_NOSEQ;


  BEGIN
    FOR ifrrow in cur_list loop
      BEGIN
      --데이타전송
       --YSH 20221002
       SELECT WCS_3.NEXTVAL INTO V_IF_SEQ FROM DUAL;
       INSERT INTO T_IF_PIS_MILLROLL_DISCARD@LNK_WCS(
               IF_SEQ
							,BARCODE       																				--밀롤바코드        
							,LOT_ID       																				--MRLOT NO   
							,DISCARD_CODE 																				--취소/폐기 사유 구분
							,DISCARD_RMK  																				--취소/폐기 사유          
							,REMARK1      																				--비고1        
							,REMARK2      																				--비고2        
							,REMARK3      																				--비고3        
							,REMARK4      																				--비고4        
							,REMARK5      																				--비고5        
							,REMARK6      																				--비고6        
							,REMARK7      																				--비고7        
							,REMARK8      																				--비고8        
							,REMARK9      																				--비고9        
							,REMARK10     																				--비고10    

							,CRAT_DATE                                            --생성 일시                      
							,CRAT_ID                                              --생성 아이디                     
							,UPDT_DATE                                            --변경 일시                      
							,UPDT_ID                                              --변경 아이디 	
       )VALUES(
       				 V_IF_SEQ            														--KEY      
       				,ifrrow.IND_BCD            														--밀롤바코드          
							,ifrrow.LOT_NO                                        --MRLOT NO   
							,ifrrow.DISCARD_CODE                                  --취소/폐기 사유 구분
							,ifrrow.DISCARD_RMK                                   --취소/폐기 사유          
							,ifrrow.REMARK1                                       --비고1        
							,ifrrow.REMARK2                                       --비고2        
							,ifrrow.REMARK3                                       --비고3        
							,ifrrow.REMARK4                                       --비고4        
							,ifrrow.REMARK5                                       --비고5        
							,ifrrow.REMARK6                                       --비고6        
							,ifrrow.REMARK7                                       --비고7        
							,ifrrow.REMARK8                                       --비고8        
							,ifrrow.REMARK9                                       --비고9        
							,ifrrow.REMARK10                                      --비고10

              ,TO_DATE(V_SYS_DT,'YYYY-MM-DD')                         --생성일자
              ,'IFSWC005'                                             --생성자  
              ,null                                                 --수정일자
              ,null                                                 --수정자
      );
      COMMIT; --ODBC DBLINK일때는 건당 COMMIT을 해야한다.(Transaction 안됨)


      o_msg_msg  :=  '밀롤 바코드 삭제(폐기) 정보 전송되었습니다.';

      UPDATE  TB_IFSWC005
      SET     IF_STATUS   =  'S'                                                 --I/F상태, N:신규, S:성공, E:오류               
            , IF_SET_DATE =  sysdate                                              --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
            , IF_ERR_MESS =  o_msg_msg                                         --데이터 처리 결과 Message(Oracle)  
            , IF_MES_KEY  =  i_IF_MES_KEY              
      WHERE  DOC_NO  =  ifrrow.DOC_NO   
      AND  DOC_NOSEQ  =  ifrrow.DOC_NOSEQ;


      o_msg_msg       := '밀롤 바코드 삭제(폐기)정보 전송되었습니다.';
      o_msg_code      := '0' ;

      COMMIT;

      EXCEPTION
            WHEN OTHERS THEN
                  o_msg_msg  :=  'SP_IF_PUT_IFSWC005=>' || '밀롤 바코드 삭제(폐기)정보 전송 중 오류가 발생하였습니다.' || ',' || SQLERRM ;
                  o_msg_code      := '-1' ;
                  DBMS_OUTPUT.PUT_LINE (o_msg_msg );
                  ROLLBACK;


                  UPDATE  TB_IFSWC005
                  SET     IF_STATUS   =  'E'                                      --I/F상태, N:신규, S:성공, E:오류               
                        , IF_SET_DATE =  sysdate                                --데이터 처리시간(MES I/F 테이블 → MES 운영테이블) 
                        , IF_ERR_MESS =  o_msg_msg                              --데이터 처리 결과 Message(Oracle)  
                        , IF_MES_KEY  =  i_IF_MES_KEY              
                  WHERE  DOC_NO  =  ifrrow.DOC_NO   
                  AND  DOC_NOSEQ  =  ifrrow.DOC_NOSEQ;             

                  Commit ;
      END;
    END LOOP;

    o_msg_msg       := '실행완료';
    o_msg_code      := '0' ;

    EXCEPTION
      WHEN OTHERS THEN
        o_msg_code      := '-1' ;
        o_msg_msg       := 'SP_IF_PUT_IFSWC005=>' || '밀롤 바코드 삭제(폐기)정보 전송 중 MAIN에서 오류가 발생하였습니다.' || ',' || to_char(SQLCODE) || ',' || SQLERRM ;
        DBMS_OUTPUT.PUT_LINE(o_msg_msg);
        rollback ;

  END; 
END SP_IF_PUT_IFSWC005;
/
