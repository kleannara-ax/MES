/*
  목적: 2022년 전체 이력을 읽지 않고, WMS 현재 재고 바코드별로 1차 판정한다.
  기준일을 임의로 자르지 않는다. 현재 WMS 재고에 존재하는 바코드의 '마지막 확정 이력'만 사용한다.

  WMS 매핑(소스 코드 기준)
    SKUKEY = 자재, LOTA02 = 플랜트, LOTA01 = 저장위치,
    LOTA14 = 개별바코드, LOTA15 = LOT/배치, USEQTY = 가용수량
*/
WITH
target (matnr, lot_no) AS (
    SELECT '1400092','2512140006' FROM dual UNION ALL SELECT '1400191','22930PH001' FROM dual UNION ALL
    SELECT '1400208','22930PH001' FROM dual UNION ALL SELECT '1400216','2605130015' FROM dual UNION ALL
    SELECT '1400243','2603300013' FROM dual UNION ALL SELECT '1401048','250804A005' FROM dual UNION ALL
    SELECT '1401048','250807A009' FROM dual UNION ALL SELECT '1401048','250929A001' FROM dual UNION ALL
    SELECT '1401048','250929A005' FROM dual UNION ALL SELECT '1401048','251001A009' FROM dual UNION ALL
    SELECT '1401048','251012A010' FROM dual UNION ALL SELECT '1401048','251013A006' FROM dual UNION ALL
    SELECT '1401048','251013A008' FROM dual UNION ALL SELECT '1401071','2602260014' FROM dual UNION ALL
    SELECT '1410032','2604140045' FROM dual
),
wms AS (
    SELECT s.LOTA02 werks, s.SKUKEY matnr, s.LOTA15 lot_no, TRIM(s.LOTA14) ind_bcd,
           MAX(m.UNIT) base_unit,
           SUM(FN_CHG_UNIT(s.SKUKEY, s.LOTA02, s.UOMKEY, m.UNIT, s.USEQTY)) wms_qty
      FROM V_WMS_STKKY@KNRAWMSLINK s
      JOIN target t ON t.matnr=s.SKUKEY AND t.lot_no=s.LOTA15
      JOIN TB_MAS001 m ON m.WERKS=s.LOTA02 AND m.MATNR=s.SKUKEY
     WHERE s.LOTA02='P300'
       AND s.LOTA01='2300'
       AND NVL(s.USEQTY,0) > 0
     GROUP BY s.LOTA02, s.SKUKEY, s.LOTA15, TRIM(s.LOTA14)
),
mes_wh AS (
    SELECT WERKS, MATNR, LOT_NO, TRIM(IND_BCD) ind_bcd,
           COUNT(*) mes_row_cnt, SUM(NVL(STCK_QTY,0)) mes_wh_qty,
           SUM(NVL(RET_REQ_QTY,0)) return_req_qty
      FROM TB_INV001
     WHERE WERKS='P300'
     GROUP BY WERKS, MATNR, LOT_NO, TRIM(IND_BCD)
),
mes_input AS (
    SELECT WERKS, MATNR, LOT_NO, TRIM(IND_BCD) ind_bcd,
           SUM(NVL(STCK_QTY,0)) mes_input_qty,
           SUM(NVL(IN_QTY,0)) input_qty,
           SUM(NVL(USE_QTY,0)) use_qty
      FROM TB_INV003
     WHERE WERKS='P300'
     GROUP BY WERKS, MATNR, LOT_NO, TRIM(IND_BCD)
),
hist AS (
    SELECT x.*
      FROM (
        SELECT i.WERKS, i.MATNR, i.LOT_NO, TRIM(i.IND_BCD) ind_bcd,
               i.REQ_DIV, i.DLFL, i.QTY hist_qty, i.UNIT hist_unit,
               i.DOC_NO, i.DOC_SEQNO, i.WDOC_NO, i.WDOC_SEQNO,
               NVL(i.UPDDATE,i.REGDATE) event_dt,
               ROW_NUMBER() OVER (
                   PARTITION BY i.WERKS,i.MATNR,i.LOT_NO,TRIM(i.IND_BCD)
                   ORDER BY NVL(i.UPDDATE,i.REGDATE) DESC, i.IF_IFR_NO DESC
               ) rn
          FROM TB_INV007 i
         WHERE i.WERKS='P300'
      ) x
     WHERE x.rn=1
),
if_problem AS (
    SELECT WERKS,MATNR,LOT_NO,TRIM(IND_BCD) ind_bcd,
           SUM(CASE WHEN src='불출요청' AND IF_STATUS='N' THEN 1 ELSE 0 END) issue_req_n,
           SUM(CASE WHEN src='불출요청' AND IF_STATUS='E' THEN 1 ELSE 0 END) issue_req_e,
           SUM(CASE WHEN src='불출응답' AND IF_STATUS IN ('N','E') THEN 1 ELSE 0 END) issue_rsp_bad,
           SUM(CASE WHEN src='반납요청' AND IF_STATUS IN ('N','E') THEN 1 ELSE 0 END) return_req_bad,
           SUM(CASE WHEN src='반납응답' AND IF_STATUS IN ('N','E') THEN 1 ELSE 0 END) return_rsp_bad
      FROM (
        SELECT '불출요청' src,WERKS,MATNR,LOT_NO,IND_BCD,IF_STATUS FROM TB_IFSWM002
        UNION ALL SELECT '불출응답',WERKS,MATNR,LOT_NO,IND_BCD,IF_STATUS FROM TB_IFRWM002
        UNION ALL SELECT '반납요청',WERKS,MATNR,LOT_NO,IND_BCD,IF_STATUS FROM TB_IFSWM004
        UNION ALL SELECT '반납응답',WERKS,MATNR,LOT_NO,IND_BCD,IF_STATUS FROM TB_IFRWM005
      )
     WHERE WERKS='P300' AND IF_STATUS IN ('N','E')
     GROUP BY WERKS,MATNR,LOT_NO,TRIM(IND_BCD)
)
SELECT w.MATNR 자재, w.LOT_NO 배치, w.IND_BCD 개별바코드, w.BASE_UNIT 단위,
       w.WMS_QTY WMS현재수량,
       NVL(m.MES_WH_QTY,0) MES창고수량,
       NVL(p.MES_INPUT_QTY,0) MES투입잔량,
       NVL(m.RETURN_REQ_QTY,0) 반납요청중수량,
       h.EVENT_DT 마지막확정일시,
       CASE h.REQ_DIV WHEN '10' THEN '불출' WHEN '20' THEN '반납' ELSE h.REQ_DIV END 마지막구분,
       h.DLFL 취소여부,
       CASE
         WHEN w.IND_BCD IS NULL THEN '판단불가-현재 WMS 재고에 개별바코드 없음'
         WHEN NVL(f.ISSUE_REQ_E,0)+NVL(f.ISSUE_RSP_BAD,0)+NVL(f.RETURN_REQ_BAD,0)+NVL(f.RETURN_RSP_BAD,0) > 0
           THEN '오류-인터페이스 E 또는 응답 미처리'
         WHEN NVL(f.ISSUE_REQ_N,0) > 0 THEN '진행중-불출요청 N'
         WHEN NVL(m.MES_ROW_CNT,0) > 1 THEN '오류-MES 동일바코드 중복'
         WHEN h.IND_BCD IS NULL THEN '판단불가-MES 불출/반납 확정이력 없음'
         WHEN h.DLFL='D' THEN '확인필요-마지막 확정이 취소 건'
         WHEN h.REQ_DIV='20' AND NVL(m.MES_WH_QTY,0)=0 AND NVL(p.MES_INPUT_QTY,0)=0
           THEN '정상후보-반납 완료 후 WMS 보유'
         WHEN h.REQ_DIV='10' AND (NVL(m.MES_WH_QTY,0)>0 OR NVL(p.MES_INPUT_QTY,0)>0)
           THEN '강한의심-WMS와 MES가 동일바코드 동시 보유'
         WHEN h.REQ_DIV='10' THEN '의심-WMS에 있는데 마지막 확정은 불출'
         WHEN NVL(m.RETURN_REQ_QTY,0)>0 THEN '진행중-반납 요청 수량 잔존'
         ELSE '확인필요'
       END 판정,
       NVL(f.ISSUE_REQ_N,0) 불출요청N,
       NVL(f.ISSUE_REQ_E,0) 불출요청E,
       NVL(f.ISSUE_RSP_BAD,0) 불출응답NE,
       NVL(f.RETURN_REQ_BAD,0) 반납요청NE,
       NVL(f.RETURN_RSP_BAD,0) 반납응답NE
  FROM wms w
  LEFT JOIN mes_wh m
    ON m.WERKS=w.WERKS AND m.MATNR=w.MATNR AND m.LOT_NO=w.LOT_NO AND m.IND_BCD=w.IND_BCD
  LEFT JOIN mes_input p
    ON p.WERKS=w.WERKS AND p.MATNR=w.MATNR AND p.LOT_NO=w.LOT_NO AND p.IND_BCD=w.IND_BCD
  LEFT JOIN hist h
    ON h.WERKS=w.WERKS AND h.MATNR=w.MATNR AND h.LOT_NO=w.LOT_NO AND h.IND_BCD=w.IND_BCD
  LEFT JOIN if_problem f
    ON f.WERKS=w.WERKS AND f.MATNR=w.MATNR AND f.LOT_NO=w.LOT_NO AND f.IND_BCD=w.IND_BCD
 ORDER BY
       CASE
         WHEN NVL(f.ISSUE_REQ_E,0)+NVL(f.ISSUE_RSP_BAD,0)+NVL(f.RETURN_REQ_BAD,0)+NVL(f.RETURN_RSP_BAD,0)>0 THEN 1
         WHEN NVL(m.MES_ROW_CNT,0)>1 THEN 2
         WHEN h.REQ_DIV='10' THEN 3
         WHEN h.IND_BCD IS NULL THEN 4
         ELSE 9
       END,
       w.MATNR,w.LOT_NO,w.IND_BCD;

/*
  결과 해석:
  - '강한의심': 동일 바코드가 WMS 현재재고와 MES 현재재고에 동시에 존재. 우선 조사 대상.
  - '오류': 해당 N/E 원문 행의 IF_ERR_MESS 확인 후 인터페이스 담당자와 재처리 판단.
  - '정상후보': 마지막 확정이 반납이고 MES 잔량이 0이므로 WMS 재고가 있는 것이 논리상 정상.
  - '판단불가': 과거 이력이 없거나 WMS 개별바코드가 없어 DB만으로 귀책 판정 불가.
  최종 '허수' 확정은 WMS 로케이션 실사와 대조해야 한다. DB 수량만으로 물리적 부재를 증명할 수 없다.
*/
