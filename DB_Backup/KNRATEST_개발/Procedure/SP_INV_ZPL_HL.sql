--------------------------------------------------------
--  DDL for Procedure SP_INV_ZPL_HL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV_ZPL_HL" 
(
    P_TYPE          IN VARCHAR2 --이후 라벨 양식 구분시 사용예정
    ,P_TITLE        IN VARCHAR2
    ,P_PRD_DT       IN VARCHAR2
    ,P_MACH_NM      IN VARCHAR2
    ,P_MATNR_DIV    IN VARCHAR2
    ,P_MATNR        IN VARCHAR2
    ,P_MATNR_NM     IN VARCHAR2
    ,P_KAN_CD       IN VARCHAR2
    ,P_BS_UNIT      IN VARCHAR2
    ,P_PLT_UNIT     IN VARCHAR2
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
    V_PRD_DT VARCHAR2(10) := FN_DT_FORMAT(P_PRD_DT, 'YYYY-MM-DD');
    V_BASE_LOC NUMBER := 1110; -- HL제품라벨 중앙위치
    V_MATNR_LRN	NUMBER := LENGTH(P_MATNR_NM); --품목명 전체길이
    V_CHAR_SIZE NUMBER := 100 - CASE WHEN (V_MATNR_LRN - 12) <= 0 THEN 0 ELSE (V_MATNR_LRN - 12) * 4 END; -- 품목명 글자크기
    V_MATNR_NM1 VARCHAR2(100);
    V_MATNR_NM2 VARCHAR2(100);
    
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
	        --V_CHAR_SIZE := CASE WHEN V_CHAR_SIZE < 30 THEN 30 ELSE V_CHAR_SIZE END;
	        IF V_MATNR_LRN > 20 THEN
	        	V_MATNR_NM1 := SUBSTR(P_MATNR_NM,1,20);
	        	V_MATNR_NM2 := SUBSTR(P_MATNR_NM,21,length(P_MATNR_NM) - 20);
	        ELSE
	        	V_MATNR_NM1 := P_MATNR_NM;
	        END IF;
            --출력문 시작
            vReturn := vReturn || '^XA ';
            vReturn := vReturn || '^PW2000 ';
            --한글처리
            vReturn := vReturn || '^SEE:UHANGUL.DAT^FS ';
            vReturn := vReturn || '^CW1,E:KFONT3.FNT^CI26^FS ';
            --vReturn := vReturn || '^CW1,E:MALGUNBDT.FNT^FS ';
            vReturn := vReturn || '^CI26 ';
            vReturn := vReturn || '^FO1650,300 ^A0N,50,50 ^FDM^FS ';
            
           --300 DPI
            IF P_TYPE LIKE '%300%' THEN
				--생산정보(일자, 호기)
	            vReturn := vReturn || '^FO750,365 ^A1N,130,130 ^FD' || V_PRD_DT ||'^FS ';
	            vReturn := vReturn || '^FO' || TO_CHAR(V_BASE_LOC - (LENGTH(P_MACH_NM)/2 * 60)) || ',525 ^A1N,80,80 ^FD' || P_MACH_NM ||'^FS ';
	            --제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
	            vReturn := vReturn || '^FO1000,665 ^A1N,80,80 ^FD' || P_MATNR_DIV ||'^FS ';
	            vReturn := vReturn || '^FO800,810 ^A1N,80,80 ^FD' || P_MATNR ||'^FS ';
	            --vReturn := vReturn || '^FO650,940 ^A1N,100,100 ^FD' || P_MATNR_NM ||'^FS ';
	            --vReturn := vReturn || '^FO' || TO_CHAR(V_BASE_LOC - (V_MATNR_LRN/2 * (V_CHAR_SIZE * (8/10)))) || ',940 ^A1N,'||TO_CHAR(V_CHAR_SIZE)||','||TO_CHAR(V_CHAR_SIZE)||' ^FD' || P_MATNR_NM ||'^FS ';
	            IF V_MATNR_NM2 IS NULL THEN
	            	vReturn := vReturn || '^FO' || TO_CHAR(V_BASE_LOC - (LENGTH(V_MATNR_NM1)/2 * 50)) || ',940 ^A1N,60,60 ^FD' || V_MATNR_NM1 ||'^FS ';
	            ELSE
	            	vReturn := vReturn || '^FO' || TO_CHAR(V_BASE_LOC - (LENGTH(V_MATNR_NM1)/2 * 50)) || ',930 ^A1N,60,60 ^FD' || V_MATNR_NM1 ||'^FS ';
	            	vReturn := vReturn || '^FO' || TO_CHAR(V_BASE_LOC - (LENGTH(V_MATNR_NM2)/2 * 50)) || ',980 ^A1N,60,60 ^FD' || V_MATNR_NM2 ||'^FS ';
	            END IF;
	            vReturn := vReturn || '^FO800,1075 ^A1N,90,90 ^FD' || P_KAN_CD ||'^FS ';
	            vReturn := vReturn || '^FO990,1210 ^A1N,140,140 ^FD' || P_BS_UNIT ||'^FS ';
	            vReturn := vReturn || '^FO1075,1400 ^A1N,140,140 ^FD' || P_PLT_UNIT ||'^FS ';
	            vReturn := vReturn || '^FO1075,1580 ^A1N,140,140 ^FD' || P_PRFM_QTY ||'^FS ';
	            vReturn := vReturn || '^FO880,1770 ^A1N,90,90 ^FD' || P_LOT_NO ||'^FS ';
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
	            vReturn := vReturn || '^FO750,365 ^A1N,130,130 ^FD' || V_PRD_DT ||'^FS ';
	            vReturn := vReturn || '^FO' || TO_CHAR(V_BASE_LOC - (LENGTH(P_MACH_NM)/2 * 60)) || ',525 ^A1N,80,80 ^FD' || P_MACH_NM ||'^FS ';
	            --제품정보(종류, 코드, 명, KAN, 기본단위, 파렛트단위, LOT)
	            vReturn := vReturn || '^FO1000,665 ^A1N,80,80 ^FD' || P_MATNR_DIV ||'^FS ';
	            vReturn := vReturn || '^FO800,810 ^A1N,80,80 ^FD' || P_MATNR ||'^FS ';
	            --vReturn := vReturn || '^FO650,940 ^A1N,100,100 ^FD' || P_MATNR_NM ||'^FS ';
	            vReturn := vReturn || '^FO' || TO_CHAR(V_BASE_LOC - (V_MATNR_LRN/2 * (V_CHAR_SIZE * (8/10)))) || ',940 ^A1N,'||TO_CHAR(V_CHAR_SIZE)||','||TO_CHAR(V_CHAR_SIZE)||' ^FD' || P_MATNR_NM ||'^FS ';
	            vReturn := vReturn || '^FO800,1075 ^A1N,90,90 ^FD' || P_KAN_CD ||'^FS ';
	            vReturn := vReturn || '^FO990,1210 ^A1N,140,140 ^FD' || P_BS_UNIT ||'^FS ';
	            vReturn := vReturn || '^FO1075,1400 ^A1N,140,140 ^FD' || P_PLT_UNIT ||'^FS ';
	            vReturn := vReturn || '^FO1075,1580 ^A1N,140,140 ^FD' || P_PRFM_QTY ||'^FS ';
	            vReturn := vReturn || '^FO880,1770 ^A1N,90,90 ^FD' || P_LOT_NO ||'^FS ';
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
END SP_INV_ZPL_HL;

/
