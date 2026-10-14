package project.mes.service;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import project.common.bean.DataMap;
import project.common.dao.CommonDAO;
import project.common.util.RfcCallClient;
import project.common.util.RfcCallFunction;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@Service
public class Wrk10SapStockService {

    @Autowired
    private CommonDAO commonDao;

    public BigDecimal getSapStock(DataMap requestMap) throws Exception {
        String werks = requestMap.getString("WERKS");
        String matnr = requestMap.getString("MATNR");
        String lotNo = requestMap.getString("LOT_NO");

        if (StringUtils.isBlank(werks)
                || StringUtils.isBlank(matnr)
                || StringUtils.isBlank(lotNo)) {
            throw new IllegalArgumentException(
                    "SAP 재고 조회에 필요한 플랜트/자재/LOT가 없습니다.");
        }

        String lgort = getLgort(werks, matnr);
        if (StringUtils.isBlank(lgort)) {
            throw new IllegalArgumentException(
                    "SAP 저장위치가 등록되지 않았습니다. 자재: " + matnr);
        }

        DataMap sapParam = new DataMap();
        sapParam.put("I_IF_ID", "MES_IF_907");
        sapParam.put("I_IF_KEY", "WRK10" + System.currentTimeMillis());
        sapParam.put("I_WERKS", werks);
        sapParam.put("I_LOTNO", lotNo);
        sapParam.put("I_MATNR", matnr);
        sapParam.put("I_LGORT", lgort);

        RfcCallFunction sap = new RfcCallFunction();
        DataMap baseMap = sap.RfcCallConnSet();
        baseMap.put("IF_NAME", "Z_MES_SAP_INV_INFO");
        baseMap.put("IF_RETBL", "ET_DATA");
        baseMap.put("IF_RESTR", "ES_RETURN");

        RfcCallClient sapClient = new RfcCallClient();
        List<DataMap> sapRows =
                sapClient.flagToTableInbound(baseMap, sapParam);

        BigDecimal stockQty = BigDecimal.ZERO;
        for (DataMap sapRow : sapRows) {
            if (!StringUtils.isBlank(sapRow.getString("ERRMSG"))) {
                throw new IllegalStateException(sapRow.getString("ERRMSG"));
            }

            if (isSame(sapRow.getString("WERKS"), werks)
                    && isSame(sapRow.getString("LGORT"), lgort)
                    && isSame(sapRow.getString("MATNR"), matnr)
                    && isSame(sapRow.getString("CHARG"), lotNo)
                    && isNormalStock(sapRow.getString("SOBKZ"))) {
                stockQty = stockQty.add(toDecimal(sapRow.get("STQTY")));
            }
        }

        return stockQty;
    }

    private String getLgort(String werks, String matnr) throws SQLException {
        DataMap query = new DataMap();
        query.setModuleCommand("Work", "WRK10_SAP_LGORT");
        query.put("WERKS", werks);
        query.put("MATNR", matnr);

        DataMap result = commonDao.getMap(query);
        return result == null ? "" : result.getString("LGORT");
    }

    private boolean isSame(String first, String second) {
        return StringUtils.trimToEmpty(first)
                .equalsIgnoreCase(StringUtils.trimToEmpty(second));
    }

    private boolean isNormalStock(String sobkz) {
        String value = StringUtils.trimToEmpty(sobkz);
        return StringUtils.isBlank(value) || "-".equals(value);
    }

    private BigDecimal toDecimal(Object value) {
        if (value == null || StringUtils.isBlank(value.toString())) {
            return BigDecimal.ZERO;
        }
        return new BigDecimal(value.toString().replace(",", "").trim());
    }
}
