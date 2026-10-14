package project.mes.controller.quality;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.mes.controller.MesController;
import project.mes.service.quality.QualityService;

@Controller
public class QualityController extends BaseController{

    private static Logger log = Logger.getLogger(MesController.class);

    @Autowired
    private QualityService qualityService;

    // raw data 저장
    @RequestMapping("/mes/quality/json/saveStaging.data")
    public String saveStaging(HttpServletRequest request, Map model) throws SQLException {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
        map.put("regId", request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY));

        model.put("result", qualityService.saveStaging(map));

        return JSON_VIEW;
    }

//    @RequestMapping("/mes/quality/json/getMatnrList.data")
//    public String getMatnrList(HttpServletRequest request, Map model) throws SQLException{
//        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);
//
//        DataMap dataMap = new DataMap();
//        List<DataMap> lotNosList = (List<DataMap>) map.get("lotList");
//        dataMap.put("lotList", lotNosList);
//        List<DataMap> list = qualityService.findMatnrList(dataMap);
//
//        map.clear();
//        model.put("data", list);
//
//        return JSON_VIEW;
//    }

    /* =========================================================================
     * 1. [QLT03] 합지롤 품질검사 (LamiRoll)
     * ========================================================================= */

    //합지롤 검사 조회
    @RequestMapping("/mes/quality/qlt03/json/list.data")
    public String getLamiRollList(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        List<DataMap> list = qualityService.findLamiRollList(map);

        map.clear();
        model.put("data", list);

        return JSON_VIEW;
    }

    //검사항목 기준값 조회
    @RequestMapping("/mes/quality/json/spec.data")
    public String getInspectionSpec(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        DataMap specMap = qualityService.findInspectionSpec(map);

        map.clear();
        model.put("data", specMap);

        return JSON_VIEW;
    }

    //합지롤/완제품 검사 저장(insert)
    @RequestMapping("/mes/quality/json/save.data")
    public String saveInspection(HttpServletRequest request, Map model){
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        map.put("regId", request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY));

        try {
            boolean result = qualityService.saveInspection(map);

            model.put("isSuccess", result); // 화면단 판단용 변수 추가
        } catch (Exception e) {
            // 3. 서비스에서 throw한 커스텀 메시지(자재코드 없음 등)를 잡아서 리턴
            log.error("저장 오류: " + e.getMessage());

            model.put("isSuccess", false);
            model.put("errMsg", e.getMessage()); // 이 메시지가 "자재코드 [XXX]가 없습니다"가 됩니다.
        }
        return JSON_VIEW;
    }

    @RequestMapping("/mes/quality/json/getMatnrList.data")
    public String getMatnrList(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        List<DataMap> list = qualityService.findMatnrList(map);

        map.clear();
        model.put("data", list);
        model.put("isSuccess", true);

        return JSON_VIEW;
    }
    /* =========================================================================
     * 2. 완제품 품질검사 (FinProd)
     * ========================================================================= */

    //완제품 검사(물성) 조회
    @RequestMapping("/mes/quality/qlt05/json/list.data")
    public String getFinProdList(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        List<DataMap> list = qualityService.findFinProdList(map);

        map.clear();
        model.put("data", list);

        return JSON_VIEW;
    }


    /* =========================================================================
     * 3. [QLT_prod_spec] 품질생산사양
     * ========================================================================= */

    //품질생산사양 조회
    @RequestMapping("/mes/quality/prod_spec/json/list.data")
    public String getQltProdSpecList(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        List<DataMap> list = qualityService.findQltProdSpecList(map);

        map.clear();
        model.put("data", list);


        return JSON_VIEW;
    }

    //품질생산사양 저장 및 수정 (신규/수정 공용)
    @RequestMapping("/mes/quality/prod_spec/json/save.data")
    public String saveQltProdSpec(HttpServletRequest request, Map model) throws Exception {
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        try {
            boolean result = qualityService.saveQltProdSpec(map);
            model.put("isSuccess", result); // 화면단 판단용 변수 추가
        } catch (Exception e) {
            log.error("저장 오류: " + e.getMessage());

            model.put("isSuccess", false);
            model.put("errMsg", e.getMessage());
        }
        return JSON_VIEW;
    }

    /* =========================================================================
     * 4. [QLT_insp_visual_chk] 외관순회검사
     * ========================================================================= */
    //외관순회 불량검사 조회
    @RequestMapping("/mes/quality/insp_visual_chk/json/defectList.data")
    public String getDefectDetailList(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        List<DataMap> list = qualityService.findDefectDetailList(map);

        map.clear();
        model.put("data", list);

        return JSON_VIEW;
    }

    //외관순회 불량검사 조회
    @RequestMapping("/mes/quality/insp_visual_chk/json/list.data")
    public String getVisualCheckList(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        List<DataMap> list = qualityService.findVisualCheckList(map);

        map.clear();
        model.put("data", list);

        return JSON_VIEW;
    }

    //외관순회 불량검사 저장(insert)
    @RequestMapping("/mes/quality/json/visualSave.data")
    public String saveVisualCheck(HttpServletRequest request, Map model){
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        map.put("REG_ID", request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY));

        try {
            boolean result = qualityService.saveVisualCheck(map);

            model.put("isSuccess", result); // 화면단 판단용 변수 추가
        } catch (Exception e) {
            // 3. 서비스에서 throw한 커스텀 메시지(자재코드 없음 등)를 잡아서 리턴
            log.error("저장 오류: " + e.getMessage());

            model.put("isSuccess", false);
            model.put("errMsg", e.getMessage()); // 이 메시지가 "자재코드 [XXX]가 없습니다"가 됩니다.
        }
        return JSON_VIEW;
    }

    //갯수환산수량 조회
    @RequestMapping("/mes/quality/insp_visual_chk/json/getEaConvQty.data")
    public String getEaConvQty(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap)request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        DataMap data = qualityService.getEaConvQty(map);

        map.clear();
        model.put("data", data);

        return JSON_VIEW;
    }

    /* =========================================================================
     * 5. [QLT_lot_trace] 추적성
     * ========================================================================= */

    //추적성 조회
    @RequestMapping("/mes/quality/lot_trace/json/datalist.data")
    public String getQltLotTraceList(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        List<DataMap> list = qualityService.findQltLotTraceList(map);

        map.clear();
        model.put("data", list);

        return JSON_VIEW;
    }

    //검사자 조회
    @RequestMapping("/mes/quality/MAS_QLT_USER/json/datalist.data")
    public String getQltUserList(HttpServletRequest request, Map model) throws SQLException{
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        List<DataMap> list = qualityService.findQltUserList(map);

        map.clear();
        model.put("data", list);
        model.put("isSuccess", true);

        return JSON_VIEW;
    }

    //검사자 저장(insert)
    @RequestMapping("/mes/quality/MAS_QLT_USER/json/save.data")
    public String saveQltUser(HttpServletRequest request, Map model){
        DataMap map = (DataMap) request.getAttribute(CommonConfig.PARAM_ATT_KEY);

        map.put("REGID", request.getSession().getAttribute(CommonConfig.SES_USER_ID_KEY));

        try {
            boolean result = qualityService.saveQltUser(map);

            model.put("isSuccess", result); // 화면단 판단용 변수 추가
        } catch (Exception e) {
            // 3. 서비스에서 throw한 커스텀 메시지(자재코드 없음 등)를 잡아서 리턴
            log.debug("저장 오류: " + e.getMessage());

            model.put("isSuccess", false);
            model.put("errMsg", e.getMessage()); // 이 메시지가 "자재코드 [XXX]가 없습니다"가 됩니다.
        }
        return JSON_VIEW;
    }

}
