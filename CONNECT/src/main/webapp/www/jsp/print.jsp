<%@page import="jini.com.NodeType"%>
<%@page import="jini.com.node.service.NodeServiceDelegator"%>
<%@page import="jini.men.content.service.ContentService"%>
<%@page import="org.w3c.dom.Node"%>
<%@page import="org.w3c.dom.NodeList"%>
<%@page import="org.w3c.dom.Element"%>
<%@page import="org.w3c.dom.Document"%>
<%@page import="jini.core.util.XMLUtil"%>
<%@page import="java.io.File"%>
<%@page pageEncoding="utf-8"%>
<%@include file="/WEB-INF/jsp/www/com/inc/common_top.jsp" %>
<%@include file="/WEB-INF/jsp/www/com/inc/frontmenu_util.jsp" %>
<%
	String menuIdx = StringUtil.nullConvert(request.getParameter("menuIdx"));
	FrontMenuHelper.setCurrentFrontMenuVoToRequest(request, menuIdx);
	
	NodeServiceDelegator nodeServiceDelegator = getApplicationContext(request).getBean(NodeServiceDelegator.class);
	MenuVO rootMenuVO = (MenuVO)nodeServiceDelegator.getNode(NodeType.MENU.getValue(), menuIdx);
	
	String site = rootMenuVO.getSite();
	request.setAttribute("site", site);
%>
<!DOCTYPE html>
<html lang="ko">
	<head>
		<c:import url="/WEB-INF/jsp/www/cms/template/site/${site }/head_resource.jsp"/>
	</head>
	
	<body>
		<div id="printArea">
<%
	FrontMenuVO frontMenuVO = FrontMenuHelper.getCurrentFrontMenuVO(request);
	
	if("C".equals(frontMenuVO.getType())) {
		int suffixNum = 0;
		String ccIdx = frontMenuVO.getIdx();
		
		if(ccIdx.length() > 1){
			suffixNum = Integer.parseInt(ccIdx.substring(ccIdx.length() - 2));			
		}else{
			suffixNum = Integer.parseInt(ccIdx.substring(ccIdx.length() - 1));
		}
	
		//배포 콘텐츠 경로 가져오기
		String contentPath = getConfiguration(request).getString("deploy.content.dir");
		contentPath = session.getServletContext().getRealPath("/") 
				+ contentPath + "/" + suffixNum 
				+ "/" + ccIdx + ".xml";
		
		File contentFile = new File(contentPath);
		
		if(!contentFile.exists() || !contentFile.isFile()){
%>
<script type="text/javascript">
	
	//alert('삭제 되었거나 없는 콘텐츠 입니다.');

</script>
<%		
		}else{
			String contentText = "";
			String kogl = "";
			String editDate = "";
	
			try {
				Document doc = XMLUtil.getDocument(contentFile);
				Element rootEl = doc.getDocumentElement();
				NodeList nodeList = rootEl.getChildNodes();			
				
				for(int i=0; i<nodeList.getLength(); i++){
					Node node = nodeList.item(i);
					
					if(node.getNodeName().equals("content")){
						contentText = node.getTextContent();
					}
					
					if(node.getNodeName().equals("kogl")){
						kogl = node.getTextContent();
					}
					
					if(node.getNodeName().equals("editDate")){
						editDate = node.getTextContent();
						setArticleEditDate(request, editDate);
					}
				}
				out.println(contentText);
			}catch(Exception e){
	
				out.println("<script>alert(\"웹 페이지 조회중 오류가 발생하였습니다.\");</script>");
				e.printStackTrace();
			}
	
			if(kogl != null){
				request.setAttribute("_kogl", kogl);
				request.setAttribute("_kogl_title", frontMenuVO.getName());
			}//if kogl
		}//else
	}
%>
		</div>
	</body>

	<script type="text/javascript">
<%
	if(!"C".equals(frontMenuVO.getType())) {
%>
		var html = window.opener.$('#print').html();
		$('#printArea').html(html);
<%
	}
%>
		window.print();
		setTimeout("window.close();", 500);
	</script>
</html>
