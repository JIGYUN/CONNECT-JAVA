package www.api.usr.user.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import www.com.util.CommonDao;
import www.com.util.Sha256;

@Service
public class UserService {

    private final String namespace = "www.api.usr.user.User";

    @Autowired
    private CommonDao dao;

    /**
     * 템플릿 목록 조회
     */
    public List<Map<String, Object>> selectUserList(Map<String, Object> paramMap) {
        return dao.list(namespace + ".selectUserList", paramMap);
    }

    /**
     * 템플릿 목록 수 조회
     */
    public int selectUserListCount(Map<String, Object> paramMap) {
        Map<String, Object> resultMap = dao.selectOne(namespace + ".selectUserListCount", paramMap);
        if (resultMap != null && resultMap.get("cnt") != null) {
            return Integer.parseInt(resultMap.get("cnt").toString());
        }
        return 0;
    }

    /**
     * 템플릿 단건 조회
     */
    public Map<String, Object> selectUserDetail(Map<String, Object> paramMap) {
        return dao.selectOne(namespace + ".selectUserDetail", paramMap);
    }

    /**
     * 템플릿 등록
     */
    @Transactional
    public void insertUser(Map<String, Object> paramMap) {
    	Sha256 sha256 = new Sha256();
    	paramMap.put("passwordHash", sha256.encrypt(String.valueOf(paramMap.get("passwordHash"))));
        dao.insert(namespace + ".insertUser", paramMap);
    }

    /**
     * 템플릿 수정
     */
    @Transactional
    public void updateUser(Map<String, Object> paramMap) {
    	Sha256 sha256 = new Sha256();
    	paramMap.put("passwordHash", sha256.encrypt(String.valueOf(paramMap.get("passwordHash"))));
        dao.update(namespace + ".updateUser", paramMap);
    }

    /**
     * 템플릿 삭제
     */
    @Transactional
    public void deleteUser(Map<String, Object> paramMap) {
        dao.delete(namespace + ".deleteUser", paramMap);
    }
}
