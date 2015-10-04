
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,org.json.simple.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" type="text/css" href="joint.css" />
<script src="jquery.min.js"></script>
<script src="lodash.min.js"></script>
<script src="backbone-min.js"></script>
<script src="joint.js"></script>

    <link rel="stylesheet" href="joint.css" />
    <script src="jquery.js"></script>
    <script src="lodash.js"></script>
    <script src="backbone.js"></script>
    <script src="joint.js"></script>
    
     <script type="text/javascript">

  function generateGraph(json)
  {
	 
	  var graph = new joint.dia.Graph;

	    var paper = new joint.dia.Paper({
	        el: $('#myholder'),
	        width: 600,
	        height: 200,
	        model: graph,
	        gridSize: 1
	    });

	    var rect = new joint.shapes.basic.Rect({
	        position: { x: 200, y: 30 },
	        size: { width: 100, height: 30 },
	        attrs: { rect: { fill: 'blue' }, text: { text: 'my box', fill: 'white' } }
	    });

	    var rect2 = rect.clone();
	    rect2.translate(300);

	    var link = new joint.dia.Link({
	        source: { id: rect.id },
	        target: { id: rect2.id }
	    });

	    graph.addCells([rect, rect2, link]);

  }
    
  </script>
  
</head>
<body>
<%

Connection connection = null;

String query = "Select * from routes;";
Class.forName("com.mysql.jdbc.Driver");
Connection con=DriverManager.getConnection
("jdbc:mysql://localhost:3306/flight","root","root");

PreparedStatement Statement = con.prepareStatement("Select * from routes;");
ResultSet result = Statement.executeQuery();

JSONArray json = new JSONArray();
ResultSetMetaData rsmd = result.getMetaData();



while(result.next()) {
	int numColumns = rsmd.getColumnCount();
    JSONObject obj = new JSONObject();

    for (int i=1; i<numColumns+1; i++) {
      String column_name = rsmd.getColumnName(i);
      
      if(rsmd.getColumnType(i)==java.sql.Types.INTEGER){
          obj.put(column_name, result.getInt(column_name));
         }
         else if(rsmd.getColumnType(i)==java.sql.Types.NVARCHAR){
          obj.put(column_name, result.getNString(column_name));
         }
         else
         {
        	 obj.put(column_name, result.getObject(column_name));
         }
    }
    json.add(obj);
    
}

JSONObject nj = new JSONObject();
nj.put("Result", json);
System.out.println(nj.toString());

%>
  <div id="myholder"></div>
 
  <script>
  generateGraph('<%= nj %>');
</script>
</body>
</html>