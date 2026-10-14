package project.mes.controller;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import project.common.bean.CommonConfig;
import project.common.bean.DataMap;
import project.common.controller.BaseController;
import project.mes.service.Wrk10SapStockService;

import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.util.Map;

@Controller
public class Wrk10SapStockController extends BaseController {

    private static final Logger log =
            Logger.getLogger(Wrk10SapStockController.class);

    @Autowired
    private Wrk10SapStockService sapStockService;

    @RequestMapping("/mes/Work/WRK10/json/sapStock.*")
    public String sapStock(
            HttpServletRequest request,
            Map<String, Object> model) {

        DataMap param = (DataMap) request.getAttribute(
                CommonConfig.PARAM_ATT_KEY);

        try {
            BigDecimal sapStockQty = sapStockService.getSapStock(param);
            model.put("P_SUCCESS", "Y");
            model.put("SAP_STOCK_QTY", sapStockQty.toPlainString());
        } catch (Exception exception) {
            log.error("WRK10 SAP 재고 조회 실패", exception);
            model.put("P_SUCCESS", "N");
            model.put("ERR_MSG", getErrorMessage(exception));
        }

        return JSON_VIEW;
    }

    private String getErrorMessage(Exception exception) {
        String message = exception.getMessage();
        if (StringUtils.isBlank(message)) {
            message = "SAP 재고 조회 중 오류가 발생했습니다.";
        }
        return message.length() > 500 ? message.substring(0, 500) : message;
    }
}
