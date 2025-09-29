<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"  %>
<!DOCTYPE html>
<html>
  <tiles:insertAttribute name="header" />
  <body class="admin-body">
    <tiles:insertAttribute name="left"/>
    <div class="container admin-main">
      <div class="row">
        <div class="col-sm-12">
          <tiles:insertAttribute name="body"/>
        </div>
      </div>
    </div>
    <tiles:insertAttribute name="foot" />
  </body>
</html>