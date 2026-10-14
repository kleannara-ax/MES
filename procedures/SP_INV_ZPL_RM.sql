
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV_ZPL_RM" 
(
    P_TYPE          IN VARCHAR2 --이후 라벨 양식 구분시 사용예정
    ,P_PRD_DT       IN VARCHAR2
    ,P_MATNR        IN VARCHAR2
    ,P_MATNR_NM     IN VARCHAR2
    ,P_UNIT			IN VARCHAR2
    ,P_LOT_NO       IN VARCHAR2
    ,P_INDBCD       IN VARCHAR2
    ,P_PRFM_QTY		IN VARCHAR2
    ,P_ZPL          OUT VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
)
AS    
    --반환값 작성(ZPL명령문)
    vReturn VARCHAR2(4000) := '';
    --V_PRD_DT VARCHAR2(10) := FN_DT_FORMAT(P_PRD_DT, 'YYYY-MM-DD');
    V_BASE_LOC NUMBER := 1110; -- HL제품라벨 중앙위치
    V_MATNR_LRN	NUMBER := LENGTH(P_MATNR_NM); --품목명 전체길이
    V_CHAR_SIZE NUMBER := 100 - CASE WHEN (V_MATNR_LRN - 12) <= 0 THEN 0 ELSE (V_MATNR_LRN - 12) * 4 END; -- 품목명 글자크기

    V_WERKS		VARCHAR2(10);
    V_PRFM_QTY	VARCHAR2(20);
   
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
                    
--            SZP_MES_PLSQL_LOG(V_PRFM_QTY, 'SP_INV_ZPL_RM V_PRFM_QTY');
--            SZP_MES_PLSQL_LOG(P_PRFM_QTY, 'SP_INV_ZPL_RM P_PRFM_QTY');
            
	        SELECT	WERKS INTO V_WERKS
	        FROM	TB_INV001
	        WHERE 	IND_BCD = P_INDBCD;

--SZP_MES_PLSQL_LOG(V_WERKS, 'SP_INV_ZPL_RM V_WERKS');
DBMS_OUTPUT.PUT_LINE('V_WERKS = ' || V_WERKS);

	        IF V_WERKS = 'P300'	AND P_UNIT = 'BAG'	THEN
	        	SELECT FN_CHG_UNIT(P_MATNR, V_WERKS, P_UNIT, 'BOX', REPLACE(P_PRFM_QTY, ',' , '')) INTO V_PRFM_QTY FROM DUAL;
	        END IF;
	       
DBMS_OUTPUT.PUT_LINE('V_PRFM_QTY = ' || V_PRFM_QTY);

	        V_CHAR_SIZE := CASE WHEN V_CHAR_SIZE < 30 THEN 30 ELSE V_CHAR_SIZE END;
            --출력문 시작
            vReturn := vReturn || '^XA ';
            vReturn := vReturn || '^PW2000 ';
            --한글처리
            vReturn := vReturn || '^SEE:UHANGUL.DAT^FS ';
            vReturn := vReturn || '^CW1,E:KFONT3.FNT^CI26^FS ';
            vReturn := vReturn || '^CI26 ';
            vReturn := vReturn || '^FO1650,300 ^A0N,50,50 ^FDM^FS ';

            
            
           --300 DPI
            IF P_TYPE LIKE '%300%' THEN
				--생산정보(일자, 호기)
	            --vReturn := vReturn || '^FO750,365 ^A1N,130,130 ^FD' || V_PRD_DT ||'^FS ';
	            --제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
	            IF V_WERKS = 'P300'	AND P_UNIT = 'BAG'	THEN
		            vReturn := vReturn || '^FO700,980 ^A1N,100,100 ^FD' || P_MATNR ||'^FS ';
		            vReturn := vReturn || '^FO700,1090 ^A1N,70,70 ^FD' || P_MATNR_NM ||'^FS ';
		            vReturn := vReturn || '^FO1000,1190 ^A1N,90,90 ^FD' || V_PRFM_QTY ||'^FS '; 
--		            vReturn := vReturn || '^FO990,1300 ^A1N,90,90 ^FD' || P_UNIT || ' / ' || 'BOX' ||'^FS ';
--		            vReturn := vReturn || '^FO800,1560 ^A1N,90,90 ^FD' || P_PRFM_QTY || ' / ' || V_PRFM_QTY ||'^FS ';
		            vReturn := vReturn || '^FO1000,1300 ^A1N,90,90 ^FD' || 'BOX' ||'^FS ';
		            vReturn := vReturn || '^FO1000,1560 ^A1N,90,90 ^FD' || V_PRFM_QTY ||'^FS ';
	            ELSE
		            vReturn := vReturn || '^FO900,980 ^A1N,100,100 ^FD' || P_MATNR ||'^FS ';
		            vReturn := vReturn || '^FO720,1090 ^A1N,70,70 ^FD' || P_MATNR_NM ||'^FS ';
		            vReturn := vReturn || '^FO800,1190 ^A1N,90,90 ^FD' || P_PRFM_QTY ||'^FS '; 
		            vReturn := vReturn || '^FO990,1300 ^A1N,90,90 ^FD' || P_UNIT ||'^FS ';
		            vReturn := vReturn || '^FO800,1560 ^A1N,90,90 ^FD' || P_PRFM_QTY ||'^FS ';
	            END IF;
	            vReturn := vReturn || '^FO880,1800 ^A1N,90,90 ^FD' || P_LOT_NO ||'^FS ';
	            vReturn := vReturn || '^FO720,1910 ^A1N,90,90 ^FD' || P_INDBCD ||'^FS ';
	            --바코드
	            vReturn := vReturn || '^FO640,2030 ';
	            vReturn := vReturn || '^BY5,2,10 ';
	            vReturn := vReturn || '^BCN,400,N,N,N ';
	            vReturn := vReturn || '^FD' || P_INDBCD;
	            vReturn := vReturn || '^FS ';
	        --기본 설정(완제품 300dpi)
	        ELSE
	        	--생산정보(일자, 호기)
	            --vReturn := vReturn || '^FO750,365 ^A1N,130,130 ^FD' || V_PRD_DT ||'^FS ';
	            --제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
	            vReturn := vReturn || '^FO800,950 ^A1N,80,80 ^FD' || P_MATNR ||'^FS ';
	            vReturn := vReturn || '^FO' || TO_CHAR(V_BASE_LOC - (V_MATNR_LRN/2 * (V_CHAR_SIZE * (8/10)))) || ',1075 ^A1N,'||TO_CHAR(V_CHAR_SIZE)||','||TO_CHAR(V_CHAR_SIZE)||' ^FD' || P_MATNR_NM ||'^FS ';
	            IF V_WERKS = 'P300'	AND P_UNIT = 'BAG'	THEN
--		            vReturn := vReturn || '^FO990,1300 ^A1N,90,90 ^FD' || P_UNIT || ' / ' || 'BOX'  ||'^FS ';
--		            vReturn := vReturn || '^FO1075,1560 ^A1N,90,90 ^FD' || P_PRFM_QTY || ' / ' || V_PRFM_QTY ||'^FS ';
		            vReturn := vReturn || '^FO990,1300 ^A1N,90,90 ^FD' || 'BOX' ||'^FS ';
		            vReturn := vReturn || '^FO1075,1560 ^A1N,90,90 ^FD' || V_PRFM_QTY ||'^FS ';
	            ELSE
		            vReturn := vReturn || '^FO990,1300 ^A1N,90,90 ^FD' || P_UNIT ||'^FS ';
		            vReturn := vReturn || '^FO1075,1560 ^A1N,90,90 ^FD' || P_PRFM_QTY ||'^FS ';
	            END IF;
	            vReturn := vReturn || '^FO880,1800 ^A1N,90,90 ^FD' || P_LOT_NO ||'^FS ';
	            vReturn := vReturn || '^FO720,1910 ^A1N,90,90 ^FD' || P_INDBCD ||'^FS ';
	            --바코드
	            vReturn := vReturn || '^FO640,2030 ';
	            vReturn := vReturn || '^BY5,2,10 ';
	            vReturn := vReturn || '^BCN,400,N,N,N ';
	            vReturn := vReturn || '^FD' || P_INDBCD;
	            vReturn := vReturn || '^FS ';
			END IF;
            --출력문 종료
            vReturn := vReturn || '^XZ';
            RS_CODE := 'S';
            P_ZPL := vReturn;
        END;
    --예외처리(catch)
    EXCEPTION
        WHEN OTHERS THEN
            BEGIN   
                --작업 실패 코드 등록
                RS_CODE := 'E';
                --에러 메세지 전송
                RS_MSG  := sqlerrm;
                return;
            END;
    --예외처리 종료
    END;
END SP_INV_ZPL_RM;
/
