package www.api.prd.product.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;

@Service
public class ProductService {

    private final String namespace = "www.api.prd.product.Product";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectProductList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectProductList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectProductListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectProductListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectProductDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectProductDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertProduct(Map<String, Object> paramMap) {
        dao.insert(namespace + ".insertProduct", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateProduct(Map<String, Object> paramMap) {
        dao.update(namespace + ".updateProduct", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteProduct(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteProduct", paramMap);
    }
}
