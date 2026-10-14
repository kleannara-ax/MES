package project.mes.dao.quality;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;
import project.common.bean.DataMap;

import javax.xml.crypto.Data;

@Mapper
public interface QualityMapper {

    /* ==========================================================
     * 0. 공통
     * ========================================================== */

    // 검사항목 조회 (TB_MAS014)
    List<Map<String, Object>> selectInspItemList(DataMap map) throws SQLException;

    // CMCDVL
    DataMap selectCodeValueByText(DataMap map) throws SQLException;

    // prc_seqno 확인
    int getLastPrcSeqNo(DataMap map) throws SQLException;

    // 엑셀 업로드 임시 저장 (Temp)
    int insertStagingList(List<Map<String, Object>> resultList) throws SQLException;

    // 검사 헤더 저장 (TB_QLT020)
    int insertInspHeader(Map<String, Object> map) throws SQLException;

    // 검사 결과값 일괄 저장 (TB_QLT021 - Batch Insert 전용)
    int insertInspResult(List<Map<String, Object>> resultList) throws SQLException;

    // 검사 결과값 일괄 저장 (TB_QLT021 - Batch Insert 전용)
    int insertVisualCheck(List<Map<String, Object>> resultList) throws SQLException;

    // 검사 결과값 일괄 수정 (TB_QLT021 - Batch Update 전용)
    int updateVisualCheck(List<Map<String, Object>> resultList) throws SQLException;

    // 검사 결과값 일괄 삭제 (TB_QLT021 - Batch Delete 전용)
    int deleteVisualCheck(List<Map<String, Object>> resultList) throws SQLException;

    // 기존 수정 (Update)
//    int updateLamiRollInsp(DataMap map) throws SQLException;

    // inv001 판정상태 update
    int updateInventoryStatus(DataMap map) throws SQLException;

    // tb_qlt024 부적합 insert
    int insertNonConformityHistory(DataMap map) throws SQLException;

    // tb_qlt024 부적합 select
    int selectNonConformityCount(DataMap map) throws SQLException;

    // 검사 헤더 삭제 (TB_QLT020)
    int deleteInspHeader(Map<String, Object> map) throws SQLException;

    // 검사 결과값 삭제 (TB_QLT021)
    int deleteInspResult(Map<String, Object> map) throws SQLException;

    // tb_qlt024 부적합 DELETE
    int deleteNonConformityHistory(Map<String, Object> map) throws SQLException;

    // 자재코드 조회

    List<DataMap> selectMatnrList(List<DataMap> lotList) throws SQLException;

    /* ==========================================================
     * 1. 합지롤 검사 관련 (Lami Roll)
     * ========================================================== */

    // 합지롤 검사 조회
    List<DataMap> selectLamiRollInspList(DataMap map) throws SQLException;

    // 합지롤 존재여부
//    int selectLamiRollCount(DataMap map) throws SQLException;

    List<DataMap> selectInspectionSpec(DataMap map) throws SQLException;


    /* ==========================================================
     * 2. 완제품(물성) 검사 관련 (Fin Prod)
     * ========================================================== */

    // 완제품(물성) 검사 조회
    List<DataMap> selectFinProdInspList(DataMap map) throws SQLException;
    DataMap getFinProdInfo(DataMap map) throws SQLException;
    DataMap inspectionExistCheck(DataMap map) throws SQLException;


    /* ==========================================================
     * 3. 품질생산사양 관련 (Prod Spec)
     * ========================================================== */

    // 품질생산사양 조회
    List<DataMap> selectQltProdSpecList(DataMap map) throws SQLException;

    String selectMaxProdKeySeq(DataMap map) throws Exception;

    // 검사 결과값 일괄 저장 (TB_QLT021 - Batch Insert 전용)
    int insertQltProdSpec(List<DataMap> resultList) throws Exception;

    // 검사 결과값 일괄 저장 (TB_QLT021 - Batch Insert 전용)
    int updateQltProdSpec(List<DataMap> resultList) throws Exception;

    int deleteSingleProdSpec(DataMap resultList) throws Exception;

    int deleteProdSpec(List<DataMap> resultList) throws SQLException;

    /* ==========================================================
     * 4. 외관순회 불량검사 (Insp Visual Chk)
     * ========================================================== */

    List<DataMap> selectDefectDetailList(DataMap map) throws SQLException;

    //외관순회 불량검사 조회
    List<DataMap> selectVisualChecklList(DataMap map) throws SQLException;

    //갯수환산수량 조회
    DataMap getEaConvQty(DataMap map) throws SQLException;

    /* ==========================================================
     * 5. 추적성 (Lot Trace)
     * ========================================================== */

    // 추적성 조회
    List<DataMap> selectQltLotTraceList(DataMap map) throws SQLException;



    // 검사자 조회
    List<DataMap> selectQltUserList(DataMap map) throws SQLException;

    // 검사자 저장
    int insertQltUser(List<Map<String, Object>> resultList) throws SQLException;

    // 검사자 수정
    int updateQltUser(List<Map<String, Object>> resultList) throws SQLException;

    // 검사자 삭제
    int deleteQltUser(List<Map<String, Object>> resultList) throws SQLException;
}