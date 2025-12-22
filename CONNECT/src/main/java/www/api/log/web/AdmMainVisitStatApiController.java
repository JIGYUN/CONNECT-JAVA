package www.api.log.web;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import www.com.util.CommonDao;

@Controller
public class AdmMainVisitStatApiController {

    private final String namespace = "www.api.log.VisitMain";

    @Autowired
    private CommonDao dao;

    @RequestMapping(value = "/api/adm/log/mainVisitStat", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public Map<String, Object> mainVisitStatApi(Map<String, Object> paramMap) {
        String fromDt = asString(paramMap.get("fromDt"));
        String toDt = asString(paramMap.get("toDt"));

        if (isBlank(fromDt) || isBlank(toDt)) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

            Calendar cal = Calendar.getInstance();
            String today = sdf.format(cal.getTime());

            cal.add(Calendar.DAY_OF_MONTH, -14);
            String from = sdf.format(cal.getTime());

            fromDt = from;
            toDt = today;
        }

        Map<String, Object> p = new HashMap<String, Object>();
        p.put("fromDt", fromDt);
        p.put("toDt", toDt);

        @SuppressWarnings("unchecked")
        Map<String, Object> todayRow = (Map<String, Object>) dao.selectOne(namespace + ".selectVisitMainTodayStat", new HashMap<String, Object>());

        @SuppressWarnings("unchecked")
        List<Map<String, Object>> rows = (List<Map<String, Object>>) dao.list(namespace + ".selectVisitMainDayStatList", p);

        int sumPc = 0;
        int sumReact = 0;
        int sumTotal = 0;

        if (rows != null) {
            for (Map<String, Object> r : rows) {
                sumPc += toInt(r.get("pcMainUv"));
                sumReact += toInt(r.get("reactMainUv"));
                sumTotal += toInt(r.get("totalUv"));
            }
        }

        Map<String, Object> sum = new HashMap<String, Object>();
        sum.put("pcMainUv", sumPc);
        sum.put("reactMainUv", sumReact);
        sum.put("totalUv", sumTotal);

        Map<String, Object> result = new HashMap<String, Object>();
        result.put("fromDt", fromDt);
        result.put("toDt", toDt);
        result.put("today", normalizeStat(todayRow));
        result.put("sum", sum);
        result.put("rows", normalizeRows(rows));

        Map<String, Object> res = new HashMap<String, Object>();
        res.put("ok", true);
        res.put("result", result);
        return res;
    }

    private static Map<String, Object> normalizeStat(Map<String, Object> row) {
        Map<String, Object> m = new HashMap<String, Object>();
        if (row == null) {
            m.put("pcMainUv", 0);
            m.put("reactMainUv", 0);
            m.put("totalUv", 0);
            return m;
        }
        m.put("pcMainUv", toInt(row.get("pcMainUv")));
        m.put("reactMainUv", toInt(row.get("reactMainUv")));
        m.put("totalUv", toInt(row.get("totalUv")));
        return m;
    }

    private static List<Map<String, Object>> normalizeRows(List<Map<String, Object>> rows) {
        if (rows == null) return null;
        for (Map<String, Object> r : rows) {
            r.put("pcMainUv", toInt(r.get("pcMainUv")));
            r.put("reactMainUv", toInt(r.get("reactMainUv")));
            r.put("totalUv", toInt(r.get("totalUv")));
            // visitDt는 SQL alias 그대로(yyyy-MM-dd 형태로 내려올 가능성 큼)
        }
        return rows;
    }

    private static String asString(Object v) {
        if (v == null) return null;
        return String.valueOf(v);
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static int toInt(Object v) {
        if (v == null) return 0;
        try {
            if (v instanceof Number) return ((Number) v).intValue();
            return Integer.parseInt(String.valueOf(v));
        } catch (Exception e) {
            return 0;
        }
    }
}
