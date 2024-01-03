<%@ page language="java" contentType="text/plain; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
	// sets the controlFlag only is part of the request query string params
	if(request.getParameter("controlFlag") != null ){
		session.setAttribute("controlFlag",request.getParameter("controlFlag"));
	}
%>
<%= session.getAttribute("controlFlag") %>