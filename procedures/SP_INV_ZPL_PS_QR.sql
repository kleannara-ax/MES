
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV_ZPL_PS_QR" 
(
    P_GAP_Y        IN NUMBER   --위쪽 여백
    ,P_TITLE        IN VARCHAR2 --지종
    ,P_WEIGHT       IN VARCHAR2 --평량
    ,P_WVLEN        IN VARCHAR2 --규격
    ,P_WIDTH_SL     IN VARCHAR2 --지폭(슬리터)
    ,P_PGEWEW       IN VARCHAR2 --중량
    ,P_LENGTH       IN VARCHAR2 --길이
    ,P_CORE         IN VARCHAR2 --지관
    ,P_WIDTH_NO     IN VARCHAR2 --지폭순서
    ,P_MACH_NM      IN VARCHAR2 --설비명
    ,P_LOTNO        IN VARCHAR2 --LOT NO
    ,P_WRK_NM       IN VARCHAR2 --작업자
    ,P_ROUTE        IN VARCHAR2 --항차번호
    ,P_INDBCD       IN VARCHAR2 --개별바코드
    ,P_INDBCD_QR    IN CLOB     --개별바코드 QR코드 이미지
    ,P_ZPL          OUT CLOB
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2
    ,RS_MSG         OUT VARCHAR2
)
AS
    --반환값 작성(ZPL명령문)
    vReturn clob := '';
    vGap_Y NUMBER := 0; --Y축 위치 조정
    vParens_R VARCHAR2(5) := '';
    vParens_L VARCHAR2(5) := '';
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            vGap_Y :=  (TO_NUMBER(P_GAP_Y) * -1);

            if P_WIDTH_SL <> ' ' then
                vParens_R := '(';
                vParens_L := ')';
            end if;

            --300 dpi
            --출력문 시작
--             vReturn := vReturn || '^XA ';
--             vReturn := vReturn || '^PW2366 ';    -- 1600 → 2366 (300 DPI 보정)
--             vReturn := vReturn || '^LL1331 ';    -- 900 → 1331 (300 DPI 보정)
--             vReturn := vReturn || '^LS0 ';
--
--             --한글처리
--             vReturn := vReturn || '^SEE:UHANGUL.DAT^FS ';
--             vReturn := vReturn || '^CW1,E:KFONT3.FNT^CI26^FS ';
--
--             --바코드
--             vReturn := vReturn || '^FO660,100 ';                                         -- QR코드 설정
--             vReturn := vReturn || '^BQ,2,36 ';                                           -- QR코드 설정(100mm)
--             vReturn := vReturn || '^FDQA' || P_INDBCD || ',27^FS ';                      -- QR코드 설정
--             vReturn := vReturn || '^FO500,380 ^A0N,110,120 ^FD' || P_INDBCD ||'^FS ';    -- QR코드 설정
--
-- --             vReturn := vReturn || '^FO250,100 ';                                            -- CODE128 설정
-- --             vReturn := vReturn || '^BY7,2,10 ';                                             -- CODE128 설정
-- --             vReturn := vReturn || '^BCN,260,N,N,N ';                                        -- CODE128 설정
-- --             vReturn := vReturn || '^FD' || P_INDBCD || '^FS ';                              -- CODE128 설정
-- --             vReturn := vReturn || '^FO450,380 ^A0N,110,120 ^FD' || P_INDBCD ||'^FS ';       -- CODE128 설정
--
--             -- 지종(P_TITLE) / 거래처(P_CUSTNM)
--             vReturn := vReturn || '^FO35,'  || TO_CHAR(710 + vGap_Y) || ' ^A0N,140,148 ^FD ' || P_TITLE  || '^FS ';
--             vReturn := vReturn || '^FO850,' || TO_CHAR(710 + vGap_Y) || ' ^A1N,140,148 ^FD 깨끗한나라 테스트입니다.' || P_CUSTNM || '^FS ';
--
--             -- 평량(P_WEIGHT) / 규격(P_WVLEN)
--             vReturn := vReturn || '^FO35,'  || TO_CHAR(829 + vGap_Y) || ' ^A0N,140,148 ^FD ' || P_WEIGHT || '^FS ';
--             vReturn := vReturn || '^FO850,' || TO_CHAR(829 + vGap_Y) || ' ^A0N,140,148 ^FD ' || P_WVLEN  || '^FS ';
--
--             -- 길이(P_LENGTH) / 중량(P_PGEWEW)
--             vReturn := vReturn || '^FO35,'  || TO_CHAR(947 + vGap_Y) || ' ^A0N,140,148 ^FD ' || P_LENGTH || '^FS ';
--             vReturn := vReturn || '^FO850,' || TO_CHAR(947 + vGap_Y) || ' ^A0N,140,148 ^FD ' || P_PGEWEW || '^FS ';
--
--             -- LOTNO(P_LOTNO)
--             vReturn := vReturn || '^FO35,'  || TO_CHAR(1065 + vGap_Y) || ' ^A0N,140,148 ^FD ' || P_LOTNO || '^FS ';
--             vReturn := vReturn || '^FO850,' || TO_CHAR(1065 + vGap_Y) || ' ^A0N,140,148 ^FD ' || P_CORE ||'^FS ';

--             vReturn := '';

            --203dpi
            --출력문 시작
            vReturn := vReturn || '^XA ';
            vReturn := vReturn || '^PW1600 ';
            vReturn := vReturn || '^LL1450 ';
            vReturn := vReturn || '^LS0 ';

            --한글처리
            vReturn := vReturn || '^SEE:UHANGUL.DAT^FS ';
            vReturn := vReturn || '^CW1,E:KFONT3.FNT^CI26^FS ';

            -- ZT42162-T0P0000Z 203 DPI
            -- ZM600-2004-0000T 203 DPI

            --QR코드(100mm 기준)
            vReturn := vReturn || '^FO350,' || TO_CHAR(40  + vGap_Y) || ' ';                                        -- QR코드 설정(100mm 기준)
--             vReturn := vReturn || '^BQ,3,39 ';                                                                      -- QR코드 설정(100mm 기준)
--             vReturn := vReturn || '^FDQA' || P_INDBCD || '^FS ';                                                    -- QR코드 설정(100mm 기준)
            vReturn := vReturn || P_INDBCD_QR;
            vReturn := vReturn || '^FO450,' || TO_CHAR(910 + vGap_Y) || ' ^A0N,110,110 ^FD' || P_INDBCD ||'^FS ';    -- QR코드 설정(100mm 기준)

            -- 지종(P_TITLE) / 항차번호(P_ROUTE) - QR코드(100mm 기준)
            vReturn := vReturn || '^FO35,' || TO_CHAR(1000 + vGap_Y) || ' ^A0N,70,70 ^FD ' || P_TITLE ||'^FS ';
            vReturn := vReturn || '^FO800,' || TO_CHAR(1000 + vGap_Y) || ' ^A0N,70,70 ^FD ' || P_ROUTE ||'^FS ';

            -- 거래처(P_CUSTNM) - QR코드(100mm 기준)
            -- 출고시에 찍힌 거래처랑 다르게 가능 경우가 있기때문에 보여지면 안됨
            -- vReturn := vReturn || '^FO35,' || TO_CHAR(1055 + vGap_Y) || ' ^A1N,70,70 ^FD ' || P_CUSTNM ||'^FS ';

            -- 설비명(P_MACH_NM) / 작업자(P_WORKER_NM) - QR코드(100mm 기준)
            vReturn := vReturn || '^FO35,' || TO_CHAR(1055 + vGap_Y) || ' ^A1N,70,70 ^FD ' || P_MACH_NM ||'^FS ';
            vReturn := vReturn || '^FO800,' || TO_CHAR(1055 + vGap_Y) || ' ^A1N,70,70 ^FD ' || P_WRK_NM ||'^FS ';

            -- 평량(P_WEIGHT) / 규격(P_WVLEN) / 슬리팅지폭(P_WIDTH_SL) - QR코드(100mm 기준)
            vReturn := vReturn || '^FO35,' || TO_CHAR(1120 + vGap_Y) || ' ^A0N,70,70 ^FD ' || P_WEIGHT ||'^FS ';
            vReturn := vReturn || '^FO800,' || TO_CHAR(1120 + vGap_Y) || ' ^A0N,70,70 ^FD ' || P_WVLEN ||'^FS ';
            -- 볼드처리기능이 없어서 dot 을 옮겨서 볼드처리된거처럼 보이게 처리
            vReturn := vReturn || '^FO1050,' || TO_CHAR(1120 + vGap_Y) || ' ^A0N,70,70 ^FD ' || vParens_R || P_WIDTH_SL || vParens_L || '^FS '; -- 원래 텍스트
            vReturn := vReturn || '^FO1052,' || TO_CHAR(1120 + vGap_Y) || ' ^A0N,70,70 ^FD ' || vParens_R || P_WIDTH_SL || vParens_L || '^FS '; -- 오른쪽으로 2dot 옮겨서 덧쓰기
            vReturn := vReturn || '^FO1050,' || TO_CHAR(1122 + vGap_Y) || ' ^A0N,70,70 ^FD ' || vParens_R || P_WIDTH_SL || vParens_L || '^FS '; -- 왼쪽으로 2dot 옮겨서 덧쓰기

            -- 길이(P_LENGTH) / 중량(P_PGEWEW) - QR코드(100mm 기준)
            vReturn := vReturn || '^FO35,' || TO_CHAR(1175 + vGap_Y) || ' ^A0N,70,70 ^FD ' || P_LENGTH ||'^FS ';
            vReturn := vReturn || '^FO800,' || TO_CHAR(1175 + vGap_Y) || ' ^A0N,70,70 ^FD ' || P_PGEWEW ||'^FS ';

            -- LOTNO(P_LOTNO) / 지관(P_CORE) / 지폭순서(P_WIDTH_NO) - QR코드(100mm 기준)
            vReturn := vReturn || '^FO35,' || TO_CHAR(1230 + vGap_Y) || ' ^A0N,70,70 ^FD ' || P_LOTNO ||'^FS ';
            vReturn := vReturn || '^FO800,' || TO_CHAR(1230 + vGap_Y) || ' ^A0N,70,70 ^FD ' || P_CORE ||'^FS ';
            vReturn := vReturn || '^FO1050,' || TO_CHAR(1230 + vGap_Y) || ' ^A0N,70,70 ^FD ' || P_WIDTH_NO ||'^FS ';

--             --QR코드(50mm 기준)
--             vReturn := vReturn || '^FO550,' || TO_CHAR(50  + vGap_Y) || ' ';                                        -- QR코드 설정(50mm 기준)
--             vReturn := vReturn || P_INDBCD_QR;
--             vReturn := vReturn || '^FO525,' || TO_CHAR(520 + vGap_Y) || ' ^A0N,110,110 ^FD' || P_INDBCD ||'^FS ';    -- QR코드 설정(50mm 기준)
--
--             -- 지종(P_TITLE) - QR코드(50mm 기준)
--             vReturn := vReturn || '^FO55,' || TO_CHAR(610 + vGap_Y) || ' ^A0N,95,100 ^FD ' || P_TITLE ||'^FS ';
--
--             -- 거래처(P_CUSTNM) - QR코드(50mm 기준)
--             vReturn := vReturn || '^FO55,' || TO_CHAR(690 + vGap_Y) || ' ^A1N,95,100 ^FD ' || P_CUSTNM ||'^FS ';
--
--             -- 평량(P_WEIGHT) / 규격(P_WVLEN) - QR코드(50mm 기준)
--             vReturn := vReturn || '^FO55,' || TO_CHAR(770 + vGap_Y) || ' ^A0N,95,100 ^FD ' || P_WEIGHT ||'^FS ';
--             vReturn := vReturn || '^FO800,' || TO_CHAR(770 + vGap_Y) || ' ^A0N,95,100 ^FD ' || P_WVLEN ||'^FS ';
--
--             -- 길이(P_LENGTH) / 중량(P_PGEWEW) - QR코드(50mm 기준)
--             vReturn := vReturn || '^FO55,' || TO_CHAR(850 + vGap_Y) || ' ^A0N,95,100 ^FD ' || P_LENGTH ||'^FS ';
--             vReturn := vReturn || '^FO800,' || TO_CHAR(850 + vGap_Y) || ' ^A0N,95,100 ^FD ' || P_PGEWEW ||'^FS ';
--
--             -- LOTNO(P_LOTNO) / 지관(P_CORE) - QR코드(50mm 기준)
--             vReturn := vReturn || '^FO55,' || TO_CHAR(930 + vGap_Y) || ' ^A0N,95,100 ^FD ' || P_LOTNO ||'^FS ';
--             vReturn := vReturn || '^FO800,' || TO_CHAR(930 + vGap_Y) || ' ^A0N,95,100 ^FD ' || P_CORE ||'^FS ';

            --출력문 종료
            vReturn := vReturn || '^XZ';
            RS_CODE := 'S';
            P_ZPL := vReturn;

--             INSERT INTO PLLOG(MESSGE, DIV) VALUES (P_CUSTNM, 'ZPL_PS_TEST P_CUSTNM');
--             INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1) VALUES (P_INDBCD_QR, 'ZPL_PS_QR P_INDBCD_QR');
            INSERT INTO PROC_LOG(SQL_STR, SQL_PARAM1, SQL_PARAM2) VALUES (vReturn, 'ZPL_PS_QR 203dpi QR코드 이미지', P_INDBCD);
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
END;
/
