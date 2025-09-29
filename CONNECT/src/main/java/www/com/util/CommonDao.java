package www.com.util;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository("CommonDAO")
public class CommonDao {
	
	@Autowired
	protected SqlSessionTemplate template;
	
	public void setSqlSessionTemplate(SqlSessionTemplate template) {
		this.template = template;
	}
	
	public Object insert(String queryId, Object parameterObject)
	{
		return template.insert(queryId, parameterObject);
	}

	public int update(String queryId, Object parameterObject)
	{
		return template.update(queryId, parameterObject);
	}

	public int delete(String queryId, Object parameterObject)
	{
		return template.delete(queryId, parameterObject);
	}

	public Map<String, Object> selectOne(String queryId, Object parameterObject)
	{
		return template.selectOne(queryId, parameterObject);
	}
	
    /** 숫자 결과(COUNT 등)를 int로 안전 변환 */
    public int selectOneInt(String queryId, Object parameterObject) {
        return ((Number) template.selectOne(queryId, parameterObject)).intValue();
    }

	public List<Map<String, Object>> list(String queryId, Object parameterObject)
	{
		return template.selectList(queryId, parameterObject);
	}
}