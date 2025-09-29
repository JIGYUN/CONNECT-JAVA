package www.com.pag;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import www.com.util.CommonDao;

/**
 * SQL은 그대로 두고, 파라미터에 limit/offset만 깔끔히 주입 + 결과를 공통 포맷으로 래핑.
 * - listStatement : 목록 SQL id (예: "www.api.brd.boardPost.BoardPost.selectBoardPostList")
 * - countStatement: 카운트 SQL id (예: "www.api.brd.boardPost.BoardPost.selectBoardPostListCount")
 * - baseParams    : 검색 파라미터(그대로 전달됨). page/size만 분리해서 limit/offset 주입.
 */
public class PagingHelper {

    public static final int DEFAULT_PAGE = 1;
    public static final int DEFAULT_SIZE = 20;
    public static final int MAX_SIZE = 200;

    /**
     * 공통 실행.
     */
    @SuppressWarnings("unchecked")
    public static Map<String, Object> run(CommonDao dao,
                                          String listStatement,
                                          String countStatement,
                                          Map<String, Object> baseParams) {
        Map<String, Object> p = baseParams == null ? new HashMap<>() : new HashMap<>(baseParams);

        int page = parseInt(p.get("page"), DEFAULT_PAGE);
        int size = parseInt(p.get("size"), DEFAULT_SIZE);

        if (page < 1) page = 1;
        if (size < 1) size = DEFAULT_SIZE;
        if (size > MAX_SIZE) size = MAX_SIZE;

        int offset = (page - 1) * size;

        // SQL에 그대로 들어갈 페이징 파라미터만 주입
        p.put("limit", size);
        p.put("offset", offset);

        // 데이터 조회
        List<Map<String, Object>> list = dao.list(listStatement, p);

        // total count 조회(옵션: countStatement 없으면 생략 가능)
        long total = 0;
        if (countStatement != null && !countStatement.trim().isEmpty()) {
            Number n = dao.selectOneInt(countStatement, p);
            if (n != null) total = n.longValue();
        } else {
            // count 쿼리를 안 주는 경우, 결과만 내려주고 total은 -1로 표시
            total = -1;
        }

        long totalPages = (total >= 0) ? ((total + size - 1) / size) : -1;
        boolean hasNext = (total >= 0) ? (page * size < total) : (list != null && list.size() == size);
        boolean hasPrev = page > 1;

        Map<String, Object> meta = new HashMap<>();
        meta.put("page", page);
        meta.put("size", size);
        meta.put("total", total);
        meta.put("totalPages", totalPages);
        meta.put("hasNext", hasNext);
        meta.put("hasPrev", hasPrev);

        Map<String, Object> out = new HashMap<>();
        out.put("list", list);
        out.put("page", meta);        // 메타를 page 키로 묶음(가볍게)
        return out;
    }

    private static int parseInt(Object v, int def) {
        if (v == null) return def;
        if (v instanceof Number) return ((Number) v).intValue();
        try { return Integer.parseInt(String.valueOf(v)); } catch (Exception e) { return def; }
    }
}