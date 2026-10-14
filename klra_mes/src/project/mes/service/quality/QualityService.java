package project.mes.service.quality;

import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.*;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import org.springframework.transaction.annotation.Transactional;
import project.common.bean.DataMap;
import project.common.service.CommonService;
import project.mes.controller.MesController;
import project.mes.dao.quality.QualityMapper;

@Service
public class QualityService {
    private static Logger log = Logger.getLogger(MesController.class);

    @Autowired
    private CommonService commonService;

    @Autowired
    private QualityMapper qualityMapper;

    //자재코드 조회
    public List<DataMap> findMatnrList(DataMap dataMap) throws SQLException {

        List<DataMap> list = qualityMapper.selectMatnrList((List<DataMap>)dataMap.get("lotList"));

        return list;
    }
    //합지롤 검사 조회
    public List<DataMap> findLamiRollList(DataMap dataMap) throws SQLException {
        List<DataMap> list = qualityMapper.selectLamiRollInspList(dataMap);

        return list;
    }

    //검사항목 기준값 조회
    public DataMap findInspectionSpec(DataMap dataMap) throws SQLException {
        List<DataMap> list = qualityMapper.selectInspectionSpec(dataMap);

        // 동적 컬럼 데이터를 담을 Map
        DataMap pivotMap = new DataMap();

        if (list != null && list.size() > 0) {
            // 공통 정보(WERKS, MATNR 등)는 첫 번째 행에서 한 번만 설정
            pivotMap.put("WERKS", list.get(0).get("WERKS"));
            pivotMap.put("MATNR", list.get(0).get("MATNR"));

            for (DataMap row : list) {
                String colId = (String) row.get("MAP_COL_ID");

                // --- LOW_VAL 처리 (없으면 STD_SEL) ---
                Object lowVal = row.get("LOW_VAL");
                if (lowVal == null || "".equals(lowVal.toString().trim()) || "null".equalsIgnoreCase(lowVal.toString())) {
                    pivotMap.put(colId + "_MIN", row.get("STD_SEL"));
                } else {
                    pivotMap.put(colId + "_MIN", lowVal);
                }

                // --- UPP_VAL 처리 ---
                pivotMap.put(colId + "_MAX", row.get("UPP_VAL"));
            }
        }

        return pivotMap;
    }

    public List<DataMap> convertExcelData(List<DataMap> dataList, DataMap param, String targetCol) throws SQLException {
        if (dataList == null || dataList.isEmpty()) {
            return dataList;
        }

        for (int i = 0; i < dataList.size(); i++) {
            DataMap row = dataList.get(i);

            String colData = row.getString(targetCol).trim();
            if ("".equals(colData)) {
                continue;
            }

            DataMap codeParam = new DataMap();
            if("QLT05".equals(param.getString("menuId"))){
                codeParam.put("CMCDKY", "QLT_H3_MAT");   // 실제 공통코드 키 확인 필요
            } else if ("QLT03".equals(param.getString("menuId"))) {
                codeParam.put("CMCDKY", "QLT_H1_MAT");   // 실제 공통코드 키 확인 필요
            }
            codeParam.put("CDESC1", colData);

            DataMap codeMap = qualityMapper.selectCodeValueByText(codeParam);


            if (codeMap != null && !codeMap.isEmpty()) {
                String colVl = codeMap.getString("CMCDVL");

                if (!"".equals(colVl)) {
                    row.put(targetCol, colVl);
                } else {
                    row.put(targetCol, colData);
                }
            }
        }

        return dataList;
    }

    //엑셀업로드 임시 저장
    public boolean saveStaging(DataMap dataMap) throws SQLException {
        List<Map<String, Object>> rowList = (List<Map<String, Object>>) dataMap.get("rowData");
        List<String> cols = (List<String>) dataMap.get("cols");
        String menuId = dataMap.getString("menuId");
        String regId = dataMap.getString("regId");
        String batchId = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date());
        Boolean saveResult = false;

        for (int i = 0; i < rowList.size(); i++) {
            Map<String, Object> row = rowList.get(i);
            row.putAll((Map) row.get("map"));
            row.put("BATCH_ID", batchId);
            row.put("ROW_SEQ", i + 1);
            row.put("PROG_ID", menuId);
            row.put("REG_ID", regId);

            // ★ 엑셀 컬럼 수만큼 VAL01 ~ VAL30 순차 매핑
            for (int j = 0; j < cols.size(); j++) {
                if (j >= 40) break; // 40개 넘어가면 스탑

                String valKey = String.format("VAL%02d", j + 1);
                String colName = cols.get(j);
                row.put(valKey, row.get(colName));
            }
        }

        if (rowList.size() > 0) {
            // upload파일 자료 이력남기기위해 temp 테이블에 저장

            int totalSize = rowList.size();
            int batchSize = 500; // 오라클 바인드 변수 한계(65,535개)를 안전하게 안 넘기는 사이즈

            for (int i = 0; i < totalSize; i += batchSize) {
                // Math.min을 이용해 마지막 루프에서 남은 자투리 데이터까지 안전하게 subList 생성
                List<Map<String, Object>> subList = rowList.subList(i, Math.min(i + batchSize, totalSize));

                // 쪼개진 500개(또는 남은 자투리)만 쿼리로 전송
                int uploadCnt = qualityMapper.insertStagingList(subList);

                if (uploadCnt < 1) {
                    log.debug("Temp 테이블 이력 저장 실패 (Index: " + i + ")");
                    saveResult = false;
                    break; // 중간에 한 묶음이라도 인서트 실패하면 루프 탈출
                } else {
                    saveResult = true;
                }
            }
        }

        return saveResult;
    }

    //합지롤 검사 저장(insert, update, delete)
    @Transactional(rollbackFor = Exception.class) // 중요: 오류 시 자동 롤백
    public boolean saveInspection(DataMap dataMap) throws Exception {
        boolean isSuccess = false;

        List<Map<String, Object>> rowList = (List<Map<String, Object>>) dataMap.get("rowData");
        String regId = dataMap.getString("regId");
        String inspItemGrpCd = dataMap.getString("INSP_ITEM_GRP_CD");

        // 2. 검사항목 마스터 정보 조회(합지롤(H1) / 완제품(H3))
        List<Map<String, Object>> inspItemList = qualityMapper.selectInspItemList(dataMap);
        int totalRowCount = rowList.size();
        int processedCount = 0;

        log.debug("insert temp table 성공");

        for (Map<String, Object> tempMap : rowList) {
            DataMap row = new DataMap();
            row.putAll(tempMap);
            if (row.get("map") != null) {
                row.putAll((Map) row.get("map")); // 엑셀 실제 데이터 병합
            }

            row.put("WERKS", "P200");
            row.put("REG_ID", regId);
            row.put("INSP_ITEM_GRP_CD", inspItemGrpCd);

            // 🌟 1. 루프를 돌기 전, 최상단에서 현재 DB의 마지막 번호를 '딱 한 번만' 조회
            int currPrcSeqNo = qualityMapper.getLastPrcSeqNo(row);

            // 화면 그리드에서 넘겨주는 상태값 (C:신규/수정, D:삭제 등)
            String rowStatus = row.getString("GRowState");
            String currentMatnr = row.getString("MATNR"); //에러메세지용

            try {
                // 저장(C) 및 수정(U)
                if ("C".equals(rowStatus) || "U".equals(rowStatus)) {

                    if ("C".equals(rowStatus)) {
                        // 🌟 2. 신규 등록일 때는 자바단에서 안전하게 1씩 더해줌 (중복 절대 안 남)
                        row.put("PRC_SEQNO", currPrcSeqNo + 1);
                    } else {
                        row.put("PRC_SEQNO", row.getInt("PRC_SEQNO"));
                    }

                    //todo : QLT05 면 원지lotno 가 오기때문에 해당 lotno 로 생산 lotno 를 조회해서 qlt020에 넣어줘야함
                    //그게아니라면 ... 원지 lotno 그대로 넣고 ... inv001 ...에 .. update 를 하지말든가 .... 그럼 ...이상해짐 연관관계를 다시봐야할듯

                    if("H3".equals(inspItemGrpCd)){
                        //완제품검사 합지lotno - LOT_NO_AA / 가공lotno - LOT_NO_RA
                        row.put("LOT_NO_M", row.getString("LOT_NO_AA"));

                        DataMap finProdInfo = qualityMapper.getFinProdInfo(row);

                        if (finProdInfo == null || finProdInfo.isEmpty()) {
                            throw new Exception("\n\n완제품 정보(finProdInfo) 조회 실패: 해당 조건의 완제품 정보가 존재하지 않습니다.\n(입력 데이터: [LOT_NO_M] " + row.getString("LOT_NO_M") + " / [MATNR] " + row.getString("MATNR") + ")");
                        }

                        row.put("LOT_NO", finProdInfo.getString("LOT_NO"));
                        row.put("IND_BCD", finProdInfo.getString("IND_BCD"));
//                        DataMap inspectionExist = qualityMapper.inspectionExistCheck(row);
                    } else if("H1".equals(inspItemGrpCd)){
                        //합지롤 검사
                        row.put("IND_BCD", row.getString("LOT_NO"));
                    }

                    // 3. 검사항목별 마스터 INSERT( TB_QLT020 )
                    if (qualityMapper.insertInspHeader(row) > 0) {
                        // 4. 상세 내역을 Batch용 리스트로 변환
                        List<Map<String, Object>> resultList = new ArrayList<>();

                        for (Map<String, Object> itemMap : inspItemList) {
                            DataMap inspItem = new DataMap();
                            inspItem.putAll(itemMap);


                            String colId = inspItem.getString("MAP_COL_ID"); // Grid col - INSP_ITEM_CD 매핑
                            String itemCode = inspItem.getString("INSP_ITEM_CD");
                            String inpType = inspItem.getString("INPT_TYP"); //A - 선택, N - 숫자, S - 문자열

                            Object rawVal = row.get(colId);
                            String rstVal = (rawVal == null) ? "" : String.valueOf(rawVal).trim();

                            DataMap rstMap = new DataMap();
                            rstMap.putAll(row); // PK 및 기본정보 복사
                            rstMap.put("INSP_ITEM_CD", itemCode);

                            //A - 선택, N - 숫자, S - 문자열
                            if ("A".equals(inpType)) {
                                rstMap.put("RST_TXT", rstVal);
                            } else if ("N".equals(inpType)) {
                                String onlyNum = rstVal.replaceAll("[^0-9.]", "");
                                rstMap.put("RST_VAL", onlyNum.isEmpty() ? "0" : onlyNum);
                            } else if ("S".equals(inpType)) {
                                rstMap.put("RST_SEL", rstVal);
                            }
                            resultList.add(rstMap);
                        }

                        // 5. Batch 실행: 삭제 후 일괄 저장
                        if (!resultList.isEmpty()) {
                            if ("U".equals(rowStatus)){
                                qualityMapper.deleteInspResult(row); // 기존 내역 비움
                            }

                            //20260827 일단 ... INSERT 시에도 기존게 잇으면 날
                            //PRCSEQ 전걸 지워야함 ..
                            qualityMapper.deleteInspResult(row); // 기존 내역 비움
                            int insertCnt = qualityMapper.insertInspResult(resultList); // 일괄 저장

                            if (insertCnt > 0) {
//                                row.put("PRC_SEQNO", curPrcSeqNo);
                                String finalJudgement = row.getString("FNL_JDGM"); // FAIL 여부
                                if ("H1".equals(inspItemGrpCd)) {
                                    row.put("IND_BCD", row.getString("LOT_NO"));
                                }

                                if ("불합격".equals(finalJudgement) || "FAIL".equals(finalJudgement) || "부적합".equals(finalJudgement)) {

                                    row.put("STCK_STA", "40");
                                    qualityMapper.updateInventoryStatus(row);
                                    if ("C".equals(rowStatus)){
                                        row.put("PRC_SEQNO", currPrcSeqNo);
                                    }
                                    qualityMapper.deleteNonConformityHistory(row);
                                    if ("C".equals(rowStatus)){
                                        row.put("PRC_SEQNO", currPrcSeqNo + 1);
                                    }
                                    //합지롤만 부적합으로 insert / 완제품은 부적합이어도 tb_qlt024에 insert x
                                    if ("H1".equals(inspItemGrpCd)) {
                                        qualityMapper.insertNonConformityHistory(row);
                                    }
                                } else {
                                    row.put("STCK_STA", "00");
                                    qualityMapper.updateInventoryStatus(row);
                                    qualityMapper.deleteNonConformityHistory(row);
                                }

                                processedCount++; // 성공한 행(Row) 개수 증가
                            }
                        } else {
                            // 측정값이 없는 행도 헤더가 성공했다면 처리된 것으로 간주할지 결정 필요
                            // 음... 일단 성공 ... 260331
                            processedCount++;
                        }
                    }
                // 삭제(D)
                } else if ("D".equals(rowStatus)) {
                    DataMap rstMap = new DataMap();
                    rstMap.putAll(row); // PK 및 기본정보 복사

                    int resultDel = qualityMapper.deleteInspResult(rstMap); // 상세 삭제
                    if (resultDel > 0) {
                        qualityMapper.deleteNonConformityHistory(rstMap);
                        qualityMapper.deleteInspHeader(rstMap); // 헤더 삭제
                    }

                    processedCount++;
                // 상태값 x
                } else {
                    log.warn("상태값(GRowState)이 없는 행이 전달되었습니다.");
                    processedCount++;
                }

            } catch (Exception e) {
                // ORA-02291 또는 제약조건 이름(FK_TB_MAS015_TO_TB_QLT020)이 포함되었는지 확인
                String errorMsg = e.getMessage();
                if (errorMsg.contains("ORA-02291") || errorMsg.contains("FK_TB_MAS015")) {
                    throw new Exception("자재코드 [" + currentMatnr + "] 가 품질 마스터(TB_MAS015)에 등록되어 있지 않습니다. 마스터 등록 후 다시 시도하세요.");
                }
                throw e;
            }
        }

        // 모든 행이 정상적으로 처리되었는지 확인
        if (totalRowCount > 0 && totalRowCount == processedCount) {
            isSuccess = true;
            log.debug("전체 " + processedCount + "건 저장 성공!");
        }

        return isSuccess;
    }

    //외관순회검사 저장(insert, update, delete)
    @Transactional(rollbackFor = Exception.class) // 중요: 오류 시 자동 롤백
    public boolean saveVisualCheck(DataMap dataMap) throws Exception {
        boolean isSuccess = false;

        List<Map<String, Object>> rowList = (List<Map<String, Object>>) dataMap.get("list");
        List<Map<String, Object>> insertList = new ArrayList<>();
        List<Map<String, Object>> updateList = new ArrayList<>();
        List<Map<String, Object>> deleteList = new ArrayList<>();
        int processedCount = 0;
        int totalRowCount = rowList.size();
        for (Map<String, Object> tempMap : rowList) {
            Map<String, Object> innerMap = (Map<String, Object>) tempMap.get("map");
            if (innerMap == null) continue;

            // 상태값 확인 (N: 신규, U: 수정, C: 신규/수정 공통 등 화면 규격에 맞게)
            String rowStatus = String.valueOf(innerMap.get("GRowState"));

            if ("C".equals(rowStatus) || "N".equals(rowStatus)) {
                insertList.add(innerMap);
            } else if ("U".equals(rowStatus)) {
                updateList.add(innerMap);
            } else if ("D".equals(rowStatus)) {
                deleteList.add(innerMap);
            }
        }

        try {
            // 1. 신규 데이터 일괄 처리
            if (!insertList.isEmpty()) {
                processedCount += qualityMapper.insertVisualCheck(insertList);
            }

            // 2. 수정 데이터 일괄 처리 (아까 만든 MERGE INTO 쿼리 사용)
            if (!updateList.isEmpty()) {
                processedCount += qualityMapper.updateVisualCheck(updateList);
            }

            // 3. 삭제 데이터 일괄 처리
            if (!deleteList.isEmpty()) {
                processedCount += qualityMapper.deleteVisualCheck(deleteList);
            }
        } catch (Exception e) {
            // ORA-02291 또는 제약조건 이름(FK_TB_MAS015_TO_TB_QLT020)이 포함되었는지 확인
            String errorMsg = e.getMessage();
            throw e;
        }

        // ★ 검증 로직: 화면에서 보낸 총 개수와 DB에서 처리된 총 개수 비교
        if (totalRowCount > 0 && totalRowCount == processedCount) {
            isSuccess = true;
            log.debug("검증 완료! 전체 " + totalRowCount + "건 중 " + processedCount + "건 저장/수정 성공!");
        } else {
            // 개수가 일치하지 않을 경우 (필요 시 예외를 던져 롤백)
            log.warn("건수 불일치 발생! 요청: " + totalRowCount + "건, 처리: " + processedCount + "건");
            // throw new Exception("처리 건수가 일치하지 않습니다."); // 더 엄격한 관리가 필요할 때 사용
        }

        return isSuccess;
    }

    //완제품(물성) 검사 조회
    public List<DataMap> findFinProdList(DataMap dataMap) throws SQLException {
        List<DataMap> list = qualityMapper.selectFinProdInspList(dataMap);

        return list;
    }


    //품질생산사양 조회
    public List<DataMap> findQltProdSpecList(DataMap dataMap) throws SQLException {
        dataMap.put("WERKS", "P200");
        List<DataMap> list = qualityMapper.selectQltProdSpecList(dataMap);

        return list;
    }

    //품질생산사양 저장(insert, update, delete)
    @Transactional(rollbackFor = Exception.class) // 중요: 오류 시 자동 롤백
    public boolean saveQltProdSpec(DataMap dataMap) throws Exception {
        boolean isSuccess = false;

        List<Map<String, Object>> rowList = (List<Map<String, Object>>) dataMap.get("rowData");
        if (rowList == null || rowList.isEmpty()) {
            return false;
        }

        List<DataMap> insertList = new ArrayList<>();
        List<DataMap> updateList = new ArrayList<>();
        List<DataMap> deleteRowList = new ArrayList<>();
        List<DataMap> deleteMatList = new ArrayList<>();

        int totalChildRowCount = 0; // 💡 쪼개진 자재 레코드의 총 개수를 담을 변수
        int processedCount = 0;
        int totalRowCount = rowList.size();

        for (Map<String, Object> tempMap : rowList) {
            Map<String, Object> innerMap = (Map<String, Object>) tempMap.get("map");
            if (innerMap == null) continue;

            // 상태값 확인 (N: 신규, U: 수정, C: 신규/수정 공통 등 화면 규격에 맞게)
            DataMap row = new DataMap(innerMap);
            String rowStatus = row.getString("GRowState");

            // 💡 1. 현재 로우에 들어있는 'MAT_NM_X' 컬럼의 총 개수를 동적으로 파악 (하드코딩 제거)
            // String.valueOf()를 추가하여 Object 타입을 String으로 명시적 변환
            long totalMatCount = row.keySet().stream()
                    .filter(key -> String.valueOf(key).startsWith("MAT_NM_"))
                    .count();

            // 공통 정보 추출 및 정제
            String prodKey  = row.getString("PROD_KEY");
            String werks    = row.getString("WERKS");
            String machCd   = row.getString("MACH_CD");
            String msrmDate = row.getString("MSRM_DATE");
            if (werks == null || werks.trim().isEmpty()) werks = "P200";
            if (msrmDate != null) msrmDate = msrmDate.replace("-", "");

            // 💡 1. 신규 등록(INSERT)인데 PROD_KEY가 없거나 비어있는 경우 채번 시작
            if ("N".equals(rowStatus) || "C".equals(rowStatus) || prodKey == null || prodKey.trim().isEmpty()) {

                // DB에서 해당 설비와 날짜에 일치하는 마지막 순번(+1 처리된 문자열)을 가져옴 (ex: "01", "02")
                DataMap seqParam = new DataMap();
                seqParam.put("WERKS", werks);
                seqParam.put("MACH_CD", machCd);
                seqParam.put("MSRM_DATE", msrmDate);

                // 💡 품질 매퍼에서 MAX(순번) + 1 값을 '01' 두자리 포맷으로 받아옵니다.
                String nextSeq = qualityMapper.selectMaxProdKeySeq(seqParam);

                // 그룹 고유키 최종 조합 (설비코드-날짜-순번) -> 스냅샷 규칙 매핑 (ex: TAA03-20260305-01)
                prodKey = machCd + "-" + msrmDate + "-" + nextSeq;

                // 원본 로우에도 생성된 키를 다시 넣어줍니다 (나중에 디버깅 및 다른 연동 처리를 위해)
                row.put("PROD_KEY", prodKey);
            } else if ("D".equals(rowStatus)) {
                deleteRowList.add(row);
            }


            // 💡 2. 화면 자재 컬럼 개수만큼 돌면서 유효한 자재 데이터만 추출
            for (int i = 1; i <= totalMatCount; i++) {
                String matNm = row.getString("MAT_NM_" + i);

                // 활엽수/침엽수 구분 및 순번 유연 연산 (반반 기준)
                long half = totalMatCount / 2;
                String kpgbn = (i <= half) ? "LBKP" : "NBKP";

                // 💡 수정 상태('U')인데 화면 칸이 비어있다면? -> 사용자가 지운 것임! DB에서도 날려야 함
                if (matNm == null || matNm.trim().isEmpty() || "-".equals(matNm.trim())) {
                    if ("U".equals(rowStatus)) {
                        DataMap delRow = new DataMap();
                        delRow.put("PROD_KEY", prodKey);
                        delRow.put("MAT_SEQ", i);
                        delRow.put("KPGBN", kpgbn);
                        delRow.put("WERKS", werks);
                        deleteMatList.add(delRow);
                        totalChildRowCount++; // 이 녀석도 검증 카운트에 포함
                    }
                    continue;
                }

                // 자재별 세로 데이터 세팅
                DataMap specRow = new DataMap();
                specRow.put("PROD_KEY",  prodKey);
                specRow.put("WERKS",     werks != null ? werks : "P200");
                specRow.put("MACH_CD",   machCd);
                specRow.put("MSRM_DATE", msrmDate);
                specRow.put("MAT_NM",    matNm);
                specRow.put("USE_QTY",   row.getString("USE_QTY_" + i) != null ? row.getString("USE_QTY_" + i) : "0");

                String mixRate = row.getString("MIX_RATE_" + i);
                specRow.put("MIX_RATE",  mixRate != null ? mixRate.replace("%", "") : "0");
                specRow.put("KPGBN",     kpgbn);
                specRow.put("MAT_SEQ",   i);

                // 💡 3. 원본 로우 상태에 따라 각각의 자재 로우를 분배 배치 처리
                if ("C".equals(rowStatus) || "N".equals(rowStatus)) {
                    insertList.add(specRow);
                     // 실제 검증할 카운트 증가
                } else if ("U".equals(rowStatus)) {
                    updateList.add(specRow);
                }
                totalChildRowCount++;
            }
        }

        try {
            // 💡 4. 자재별로 쪼개진 대량 데이터를 일괄 처리 (MyBatis foreach 처리 권장)
            if (!deleteMatList.isEmpty()) {
                // 단건 루프를 돌리거나 PL/SQL 블록으로 지움
                for(DataMap del : deleteMatList) {
                    processedCount += qualityMapper.deleteSingleProdSpec(del); // 성공 시 1 리턴
                }
            }

            // 만약 매퍼가 List 파라미터를 단건 loop 돌리는 방식이면 매퍼 내부 구성을 따릅니다.
            if (!deleteRowList.isEmpty()) {
                processedCount += qualityMapper.deleteProdSpec(deleteRowList);
            }

            if (!insertList.isEmpty()) {
                processedCount += qualityMapper.insertQltProdSpec(insertList);
            }

            if (!updateList.isEmpty()) {
                // 💡 MERGE INTO가 포함된 PL/SQL 블록은 성공 시 -1을 반환할 수 있으므로 임시 변수에 저장
                int updateResult = qualityMapper.updateQltProdSpec(updateList);

                // 만약 결과가 -1(성공했으나 건수 알수없음)이면, 요청한 데이터 개수만큼 다 성공했다고 간주함
                if (updateResult == -1) {
                    processedCount += updateList.size();
                } else {
                    processedCount += updateResult;
                }
            }
        } catch (Exception e) {
            String errorMsg = e.getMessage();
            throw e;
        }

        // ★ 💡 검증 로직: 실제 DB에 들어가야 할 자재 총 개수(totalChildRowCount)와 처리된 수 비교
        if (totalChildRowCount > 0 && totalChildRowCount == processedCount) {
            isSuccess = true;
            log.debug("검증 완료! 전체 " + totalChildRowCount + "건 중 " + processedCount + "건 저장/수정 성공!");
        } else {
            log.warn("건수 불일치 발생! 요청(자재기준): " + totalChildRowCount + "건, 처리: " + processedCount + "건");
            // 확실한 데이터 정합성을 위해 불일치 시 강제 예외를 발생시켜 롤백시키는 것을 추천합니다.
            throw new Exception("생산사양 데이터 처리 건수가 일치하지 않아 저장에 실패했습니다.");
        }

        return isSuccess;
    }

    //부적합상세 조회
    public List<DataMap> findDefectDetailList(DataMap dataMap) throws SQLException {
        List<DataMap> list = qualityMapper.selectDefectDetailList(dataMap);

        return list;
    }

    //외관순회 불량검사 조회
    public List<DataMap> findVisualCheckList(DataMap dataMap) throws SQLException {
        List<DataMap> list = qualityMapper.selectVisualChecklList(dataMap);

        return list;
    }

    //갯수환산수량 조회
    public DataMap getEaConvQty(DataMap dataMap) throws SQLException {
        DataMap result = qualityMapper.getEaConvQty(dataMap);

        return result;
    }

    //추적성 조회
    public List<DataMap> findQltLotTraceList(DataMap dataMap) throws SQLException {
        dataMap.put("WERKS", "P200");

        // QualityService.java
        Map<String, Object> rangeMap = (Map<String, Object>) dataMap.get("RANGE_DATA_MAP");

        if (rangeMap != null) {
            // 1. PRFM_DT_AA 추출
//            List<Map<String, Object>> aaList = (List<Map<String, Object>>) rangeMap.get("PRFM_DT_AA_Range");
//            if (aaList != null && !aaList.isEmpty()) {
//                dataMap.put("AA_FROM", aaList.get(0).get("FROM"));
//                dataMap.put("AA_TO", aaList.get(0).get("TO"));
//            }
//
//            // 2. PRFM_DT_RA 추출
//            List<Map<String, Object>> raList = (List<Map<String, Object>>) rangeMap.get("PRFM_DT_RA_Range");
//            if (raList != null && !raList.isEmpty()) {
//                dataMap.put("RA_FROM", raList.get(0).get("FROM"));
//                dataMap.put("RA_TO", raList.get(0).get("TO"));
//            }

            // 3. SPEC_MSRM_DT 추출
            List<Map<String, Object>> msrmList = (List<Map<String, Object>>) rangeMap.get("SPEC_MSRM_DT_Range");
            if (msrmList != null && !msrmList.isEmpty()) {
                dataMap.put("SPEC_FROM", msrmList.get(0).get("FROM"));
                dataMap.put("SPEC_TO", msrmList.get(0).get("TO"));
            }
        }

        List<DataMap> list = qualityMapper.selectQltLotTraceList(dataMap);

        return list;
    }

    //검사자 조회
    public List<DataMap> findQltUserList(DataMap dataMap) throws SQLException {
        List<DataMap> list = qualityMapper.selectQltUserList(dataMap);

        return list;
    }

    //검사자 저장(insert, update, delete)
    @Transactional(rollbackFor = Exception.class) // 중요: 오류 시 자동 롤백
    public boolean saveQltUser(DataMap dataMap) throws Exception {
        boolean isSuccess = false;

        List<Map<String, Object>> rowList = (List<Map<String, Object>>) dataMap.get("list");
        List<Map<String, Object>> insertList = new ArrayList<>();
        List<Map<String, Object>> updateList = new ArrayList<>();
        List<Map<String, Object>> deleteList = new ArrayList<>();
        int processedCount = 0;
        int totalRowCount = rowList.size();
        for (Map<String, Object> tempMap : rowList) {
            Map<String, Object> innerMap = (Map<String, Object>) tempMap.get("map");
            if (innerMap == null) continue;

            innerMap.put("REGID", dataMap.get("REGID").toString());

            // 상태값 확인 (N: 신규, U: 수정, C: 신규/수정 공통 등 화면 규격에 맞게)
            String rowStatus = String.valueOf(innerMap.get("GRowState"));

            if ("C".equals(rowStatus) || "N".equals(rowStatus)) {
                insertList.add(innerMap);
            } else if ("U".equals(rowStatus)) {
                updateList.add(innerMap);
            } else if ("D".equals(rowStatus)) {
                deleteList.add(innerMap);
            }
        }

        try {
            // 1. 신규 데이터 일괄 처리
            if (!insertList.isEmpty()) {
                processedCount += qualityMapper.insertQltUser(insertList);
            }

            // 2. 수정 데이터 일괄 처리 (아까 만든 MERGE INTO 쿼리 사용)
            if (!updateList.isEmpty()) {
                qualityMapper.updateQltUser(updateList);
                processedCount += updateList.size();
            }

            // 3. 삭제 데이터 일괄 처리
            if (!deleteList.isEmpty()) {
                processedCount += qualityMapper.deleteQltUser(deleteList);
            }
        } catch (Exception e) {
            // ORA-02291 또는 제약조건 이름(FK_TB_MAS015_TO_TB_QLT020)이 포함되었는지 확인
            String errorMsg = e.getMessage();
            throw e;
        }

        // ★ 검증 로직: 화면에서 보낸 총 개수와 DB에서 처리된 총 개수 비교
        if (totalRowCount > 0 && totalRowCount == processedCount) {
            isSuccess = true;
            log.debug("검증 완료! 전체 " + totalRowCount + "건 중 " + processedCount + "건 저장/수정 성공!");
        } else {
            // 개수가 일치하지 않을 경우 (필요 시 예외를 던져 롤백)
            log.warn("건수 불일치 발생! 요청: " + totalRowCount + "건, 처리: " + processedCount + "건");
            // throw new Exception("처리 건수가 일치하지 않습니다."); // 더 엄격한 관리가 필요할 때 사용
        }

        return isSuccess;
    }
}
