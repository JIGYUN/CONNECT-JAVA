<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"  %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
  	<tiles:insertAttribute name="header" />
	<body>
  		<tiles:insertAttribute name="left"/>
		<div class="container">
		    <div class="row">
		        <div class="col-sm-12 blog-main">
		            <tiles:insertAttribute name="body"/>
		        </div>
		    </div>
		</div>
  		<tiles:insertAttribute name="foot" />
  </body>
</html>