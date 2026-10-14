
  CREATE OR REPLACE EDITIONABLE PROCEDURE "KNRAMES"."SP_INV_ZPL_PS" 
(
    P_TYPE          IN VARCHAR2 --이후 라벨 양식 구분시 사용예정
    ,P_GAP_X        IN NUMBER   --왼쪽 여백
    ,P_GAP_Y        IN NUMBER   --위쪽 여백
    ,P_PRT_SPEED    IN NUMBER   --속도
    ,P_PRT_STRENGTH IN NUMBER   --강도
    ,P_TITLE        IN VARCHAR2 --지종
    ,P_WEIGHT       IN VARCHAR2 --평량
    ,P_WVLEN        IN VARCHAR2 --규격
    ,P_REAM         IN VARCHAR2 --연수
    ,P_PGEWEW       IN VARCHAR2 --중량
    ,P_SCNT         IN VARCHAR2 --속
    ,P_MCNT         IN VARCHAR2 --매수
    ,P_LENGTH       IN VARCHAR2 --길이
    ,P_CORE         IN VARCHAR2 --지관
    ,P_SPITEMNO     IN VARCHAR2 --특별재고번호
    ,P_CUSTNM       IN VARCHAR2 --고객명
    ,P_CUSTEX       IN VARCHAR2 --고객추가정보
    ,P_LINECD       IN VARCHAR2 --생산호기
    ,P_LOTNO        IN VARCHAR2 --LOT NO
    ,P_WORKER       IN VARCHAR2 --작업자
    ,P_ORDERNO      IN VARCHAR2 --ORDERNO
    ,P_CINDBCD      IN VARCHAR2 --재단개별바코드
    ,P_INDBCD       IN VARCHAR2 --개별바코드
    ,P_ZPL          OUT VARCHAR2
    ,Lang           IN VARCHAR2 DEFAULT 'KO'
    ,RS_CODE        OUT VARCHAR2 
    ,RS_MSG         OUT VARCHAR2
)
AS    
    --반환값 작성(ZPL명령문)
    vReturn VARCHAR2(4000) := '';
    vGap_Y NUMBER := 0; --Y축 위치 조정
BEGIN
    --예외처리 시작(try)
    BEGIN
        BEGIN
            vGap_Y :=  (TO_NUMBER(P_GAP_Y) * -1);
            
            --포장 라벨 유형 -----------------
            --01 : 내수 페이퍼
            --02 : 내수 스티커
            --03 : 수출 페이퍼
            --04 : 수출 스티커
            IF P_TYPE = '01' OR P_TYPE = '03' THEN
                vGap_Y := vGap_Y + 200;  
            END IF;

            --출력문 시작
            vReturn := vReturn || '^XA ';
            --한글처리
            vReturn := vReturn || '^SEE:UHANGUL.DAT^FS ';
            vReturn := vReturn || '^CW1,E:KFONT3.FNT^CI26^FS ';
           
            --300 dpi
           /*
            --지종 평량 규격
            vReturn := vReturn || '^FO150,350 ^A1N,280,280 ^FD' || P_TITLE ||'^FS ';
            vReturn := vReturn || '^FO150,720 ^A0N,280,240 ^FD' || P_WEIGHT ||'^FS ';
            vReturn := vReturn || '^FO750,720 ^A0N,280,240 ^FD' || P_WVLEN ||'^FS ';
            --수량정보(연수,중량,속,매,길이,지관)
            vReturn := vReturn || '^FO200,1080 ^A0N,160,140 ^FD' || P_REAM ||'^FS ';
            vReturn := vReturn || '^FO620,1080 ^A0N,160,140 ^FD' || P_PGEWEW ||'^FS ';
            vReturn := vReturn || '^FO200,1300 ^A0N,160,140 ^FD' || P_SCNT ||'^FS ';
            vReturn := vReturn || '^FO800,1300 ^A0N,160,140 ^FD' || P_MCNT ||'^FS ';
            vReturn := vReturn || '^FO150,1540 ^A0N,130,120 ^FD' || P_LENGTH ||'^FS ';
            vReturn := vReturn || '^FO800,1540 ^A0N,130,120 ^FD' || P_CORE ||'^FS ';
            --제품정보(특별재고번호,(재단바코드),고객명,(고객추가정보),(생산호기),LotNo,(작업자),OrderNo)
            vReturn := vReturn || '^FO100,1780 ^A0N,140,140 ^FD' || P_SPITEMNO ||'^FS ';
            vReturn := vReturn || '^FO620,1910 ^A0N,60,60 ^FD' || P_CINDBCD ||'^FS ';
            vReturn := vReturn || '^FO100,2000 ^A1N,110,90 ^FD' || P_CUSTNM ||'^FS ';
            vReturn := vReturn || '^FO150,2060 ^A1N,60,60 ^FD' || P_CUSTEX ||'^FS ';
            vReturn := vReturn || '^FO800,2130 ^A0N,60,60 ^FD' || P_LINECD ||'^FS ';
            vReturn := vReturn || '^FO100,2210 ^A0N,140,140 ^FD' || P_LOTNO ||'^FS ';
            vReturn := vReturn || '^FO800,2350 ^A1N,50,50 ^FD' || P_WORKER ||'^FS ';
            vReturn := vReturn || '^FO100,2420 ^A0N,140,140 ^FD' || P_ORDERNO ||'^FS ';


            --바코드
            IF LENGTHB(P_INDBCD) > 10 THEN
                vReturn := vReturn || '^FO1300,1080 ';
                vReturn := vReturn || '^BY7,2,10 ';
                vReturn := vReturn || '^BCR,440,N,N,N ';
                vReturn := vReturn || '^FD' || P_INDBCD;
                vReturn := vReturn || '^FS ';
                vReturn := vReturn || '^FO1780,1300 ^A0B,110,120 ^FD' || P_INDBCD ||'^FS ';
            ELSE 
                vReturn := vReturn || '^FO1300,1250 ';
                vReturn := vReturn || '^BY7,2,10 ';
                vReturn := vReturn || '^BCR,440,N,N,N ';
                vReturn := vReturn || '^FD' || P_INDBCD;
                vReturn := vReturn || '^FS ';
                vReturn := vReturn || '^FO1780,1470 ^A0B,110,120 ^FD' || P_INDBCD ||'^FS ';
            END IF;
           */
           
--            --추가바코드(Size3)
--            vReturn := vReturn || '^FO150,50 ';
--            vReturn := vReturn || '^BY3,3,10 ';
--            vReturn := vReturn || '^BCN,200,N,N,N ';
--            vReturn := vReturn || '^FD' || P_INDBCD ||'^FS ';
--            --추가바코드(Size2)
--            vReturn := vReturn || '^FO150,50 ';
--            vReturn := vReturn || '^BY2,3,10 ';
--            vReturn := vReturn || '^BCN,200,N,N,N ';
--            vReturn := vReturn || '^FD' || P_INDBCD ||'^FS ';
           
           
            --203dpi
            --지종 평량 규격
--             vReturn := vReturn || '^FO100,' || TO_CHAR(235 + vGap_Y) || ' ^A1N,185,175 ^FD' || P_TITLE ||'^FS ';
            vReturn := vReturn || '^FO65,' || TO_CHAR(120 + vGap_Y) || ' ^A1N,185,175 ^FB1800,2,0,L,0 ^FD' || P_TITLE ||'^FS '; -- ^FBwidth(텍스트블록폭), lines(최대줄수), lineSpacing(줄간격 기본0), alignment(정렬), hangingIndent(첫줄둘여쓰기폭) -- 지종 두줄로보이기위함
            vReturn := vReturn || '^FO100,' || TO_CHAR(480 + vGap_Y) || ' ^A0N,195,170 ^FD' || P_WEIGHT ||'^FS ';
            vReturn := vReturn || '^FO500,' || TO_CHAR(480 + vGap_Y) || ' ^A0N,195,170 ^FD' || P_WVLEN ||'^FS ';
            --수량정보(연수,중량,속,매,길이,지관)
            vReturn := vReturn || '^FO65,' || TO_CHAR(690 + vGap_Y) || ' ^A0N,135,115 ^FD' || P_REAM ||'^FS ';
            vReturn := vReturn || '^FO420,' || TO_CHAR(700 + vGap_Y) || ' ^A0N,105,95 ^FD' || P_PGEWEW ||'^FS ';
            vReturn := vReturn || '^FO100,' || TO_CHAR(850 + vGap_Y) || ' ^A0N,135,115 ^FD' || P_SCNT ||'^FS ';
            vReturn := vReturn || '^FO535,' || TO_CHAR(850 + vGap_Y) || ' ^A0N,135,115 ^FD' || P_MCNT ||'^FS ';
            vReturn := vReturn || '^FO100,' || TO_CHAR(1015 + vGap_Y) || ' ^A0N,95,105 ^FD' || P_LENGTH ||'^FS ';
            vReturn := vReturn || '^FO535,' || TO_CHAR(1015 + vGap_Y) || ' ^A0N,95,105 ^FD' || P_CORE ||'^FS ';
            --제품정보(특별재고번호,(재단바코드),고객명,(고객추가정보),(재단,포장 - 생산호기/ 밀롤 - 지폭순서),LotNo,(작업자),OrderNo)
            vReturn := vReturn || '^FO65,' || TO_CHAR(1185 + vGap_Y) || ' ^A0N,95,95 ^FD' || P_SPITEMNO ||'^FS ';
            vReturn := vReturn || '^FO490,' || TO_CHAR(1235 + vGap_Y) || ' ^A0N,60,60 ^FD' || P_CINDBCD ||'^FS ';
            vReturn := vReturn || '^FO65,' || TO_CHAR(1335 + vGap_Y) || ' ^A1N,75,60 ^FD' || P_CUSTNM ||'^FS ';
            vReturn := vReturn || '^FO555,' || TO_CHAR(1385 + vGap_Y) || ' ^A0N,50,50 ^FD' || P_LINECD ||'^FS ';
            vReturn := vReturn || '^FO100,' || TO_CHAR(2060 + vGap_Y) || ' ^A1N,50,50 ^FD' || P_CUSTEX ||'^FS ';
            vReturn := vReturn || '^FO65,' || TO_CHAR(1455 + vGap_Y) || ' ^A0N,95,95 ^FD' || P_LOTNO ||'^FS ';
            vReturn := vReturn || '^FO490,' || TO_CHAR(1530 + vGap_Y) || ' ^A1N,50,50 ^FD' || P_WORKER ||'^FS ';
            vReturn := vReturn || '^FO65,' || TO_CHAR(1605 + vGap_Y) || ' ^A0N,95,95 ^FD' || P_ORDERNO ||'^FS ';

            --바코드
            IF LENGTHB(P_INDBCD) > 10 THEN
                vReturn := vReturn || '^FO865,' || TO_CHAR(630 + vGap_Y) || ' ';
                vReturn := vReturn || '^BY6,2,10 ';
                vReturn := vReturn || '^BCR,295,N,N,N ';
                vReturn := vReturn || '^FD' || P_INDBCD;
                vReturn := vReturn || '^FS ';
                vReturn := vReturn || '^FO1185,' || TO_CHAR(650 + vGap_Y) || ' ^A0B,120,180 ^FD' || P_INDBCD ||'^FS ';
            ELSE 
                vReturn := vReturn || '^FO865,' || TO_CHAR(740 + vGap_Y) || ' ';
                vReturn := vReturn || '^BY6,2,10 ';
                vReturn := vReturn || '^BCR,295,N,N,N ';
                vReturn := vReturn || '^FD' || P_INDBCD;
                vReturn := vReturn || '^FS ';
                vReturn := vReturn || '^FO1185,' || TO_CHAR(720 + vGap_Y) || ' ^A0B,120,180 ^FD' || P_INDBCD ||'^FS ';
            END IF;

            --추가바코드(Size3)
            vReturn := vReturn || '^FO840,' || TO_CHAR(1725 + vGap_Y);
            vReturn := vReturn || '^BY3,3,10 ';
            vReturn := vReturn || '^BCN,133,N,N,N ';
            vReturn := vReturn || '^FD' || P_INDBCD ||'^FS ';
            vReturn := vReturn || '^FO925,' || TO_CHAR(1860 + vGap_Y) || ' ^A1N,40,40 ^FD' || P_INDBCD ||'^FS ';
--            --추가바코드(Size2)
--            vReturn := vReturn || '^FO840,' || TO_CHAR(1725 + vGap_Y);
--            vReturn := vReturn || '^BY2,3,10 ';
--            vReturn := vReturn || '^BCN,133,N,N,N ';
--            vReturn := vReturn || '^FD' || P_INDBCD ||'^FS ';

            --출력문 종료
            vReturn := vReturn || '^XZ';
            RS_CODE := 'S';
            P_ZPL := vReturn;

            INSERT INTO PLLOG(LOGSEQ, CREDAT, CRETIM, MESSGE, DIV) VALUES (SEQ_PLLOG.NEXTVAL,to_char(sysdate, 'YYYYMMDD'), to_char(sysdate, 'HH24MISS'), P_LINECD || ' : ' || vReturn, 'ZPL_PS ' || P_INDBCD);
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
