package www.com.spring;
import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.validator.Form;
import org.apache.commons.validator.Validator;
import org.apache.commons.validator.ValidatorResources;
import org.springframework.beans.FatalBeanException;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.core.io.Resource;
import org.springframework.util.StringUtils;
import org.springframework.validation.Errors;
import org.springmodules.validation.commons.ValidatorFactory;
import org.xml.sax.SAXException;


/**
 * custom apache commons validator 
 * validator.xml, validator_rules.xml 파일 변경을 실시간 체크하여 
 * was 재기동 없이 바로 반영하는 클래스
 * 
 * org.springmodules.validation.commons.DefaultValidatorFactory (0.8a ver) 클래스를 참고하여 작성함.
 * 
 * @author cmj
 *
 */
public class RelodableValidatorFactory implements ValidatorFactory, InitializingBean {
	
	private static Log logger = LogFactory.getLog(RelodableValidatorFactory.class);
	
	public static final String ERRORS_KEY = "org.springframework.validation.Errors";
	
	private Resource[] resources;
	
	private ValidatorResources validatorResources;
	
	// load된 validator xml resource파일의 마지막 수정일자
	private long[] loadedResourceLastModified;
	
	public void afterPropertiesSet() throws Exception {
		if (this.validatorResources == null) {
            throw new FatalBeanException("Unable to locate validation configuration. Property [validationLocations] is required.");
        }
	}
	
	public void setValidationConfigLocations(Resource[] validationConfigLocations) {
		//this.resources = validationConfigLocations;
		//캡슐화 데이터 할당
		this.resources = new Resource[validationConfigLocations.length];
		
		for(int i = 0; i < validationConfigLocations.length; i++) {
			this.resources[i] = validationConfigLocations[i];
		}
		
		initValidatorResources();		
	}
	
	public Validator getValidator(String beanName, Object bean, Errors errors) {
		
		Validator validator = new Validator(getValidatorResources(), beanName);
        validator.setParameter(ERRORS_KEY, errors);
        validator.setParameter(Validator.BEAN_PARAM, bean);
        
        return validator;
	}
	
	public boolean hasRulesForBean(String beanName, Locale locale) {
		Form form = getValidatorResources().getForm(locale, beanName);
        return (form != null);
	}

	public ValidatorResources getValidatorResources() {
		
		try {
				
			// validator xml resource가 하나라도 수정되었으면 
			// xml resource를 다시 로딩한다.
			if(isResourceModified()){
				
				// double check resource changed
				synchronized (this) {
					if(isResourceModified()){
						initValidatorResources();
						
						logger.info("@>>> Validator resources reload success.");
					}
				}
			}
			
		} catch (IOException e) {
			throw new RuntimeException(e);
		}
		
		return validatorResources;
	}
	
	/**
	 * validator.xml, validator_rules.xml resource가 수정되었는지 체크
	 * @return 수정되었으면 true
	 * @throws IOException
	 */
	private boolean isResourceModified()throws IOException{
		boolean isChanged = false;
		
		for(int i=0; i<resources.length; i++){
			
			long targetResourceLastModified = resources[i].lastModified();
			
			// load된 resource와 현재 resource의 최종 수정일 비교
			if(targetResourceLastModified != loadedResourceLastModified[i]){
				logger.info("@>>> Validator resource is changed. resource file name : " + resources[i].getFilename());
				
				isChanged = true;
			}
		}
		
		return isChanged;
	}
	
	/**
	 * validator.xml, validator_rules.xml 로딩 
	 */
	private void initValidatorResources(){
		
		if (logger.isInfoEnabled()) {
            logger.info("Loading validation configurations from [" + StringUtils.arrayToCommaDelimitedString(resources) + "]");
        }

        try {
        	
        	if(loadedResourceLastModified == null){
        		loadedResourceLastModified = new long[resources.length];
        	}
        	
            InputStream[] inputStreams = new InputStream[resources.length];

            for (int i = 0; i < inputStreams.length; i++) {
            	
            	// resource 파일 최종수정일 정보 저장
            	loadedResourceLastModified[i] = resources[i].lastModified();
            	
                inputStreams[i] = resources[i].getInputStream();
            }
            
            this.validatorResources = null;
            
            this.validatorResources = new ValidatorResources(inputStreams);
        }
        catch (IOException e) {
            throw new FatalBeanException("Unable to read validation configuration due to IOException.", e);
        }
        catch (SAXException e) {
            throw new FatalBeanException("Unable to parse validation configuration XML", e);
        }
	}
}
