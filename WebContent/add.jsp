<%@page import="java.sql.*" %>
 
<%@page import="java.io.*" %>
 
<%@page import="javax.sql.*" %>
 
<%@page import="java.sql.Connection" %>
 
<%
 
String source=request.getParameter("source");
 
String destination=request.getParameter("destination");
 
String flight=request.getParameter("flight");
int flightNumber = Integer.parseInt(flight); 
Class.forName("com.mysql.jdbc.Driver");
 
Connection con=DriverManager.getConnection
("jdbc:mysql://localhost:3306/flight","root","root");
 
Statement st=con.createStatement();
 
String sql="insert into routes(dep,arr,flt) values('"+source+"','"+destination+"','"+flightNumber+"')";
 
int flag=st.executeUpdate(sql);
 
if(flag==1)
 
{
 
out.println("Added!");
 
}
 
else
 
{
 
out.println("Failed");
 
}
 
response.sendRedirect("index.jsp");
 
%>