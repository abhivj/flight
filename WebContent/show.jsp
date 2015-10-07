
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

     function adjustVertices(graph, cell) {

    	    // If the cell is a view, find its model.
    	    cell = cell.model || cell;

    	    if (cell instanceof joint.dia.Element) {

    	        _.chain(graph.getConnectedLinks(cell)).groupBy(function(link) {
    	            // the key of the group is the model id of the link's source or target, but not our cell id.
    	            return _.omit([link.get('source').id, link.get('target').id], cell.id)[0];
    	        }).each(function(group, key) {
    	            // If the member of the group has both source and target model adjust vertices.
    	            if (key !== 'undefined') adjustVertices(graph, _.first(group));
    	        });

    	        return;
    	    }

    	    // The cell is a link. Let's find its source and target models.
    	    var srcId = cell.get('source').id || cell.previous('source').id;
    	    var trgId = cell.get('target').id || cell.previous('target').id;

    	    // If one of the ends is not a model, the link has no siblings.
    	    if (!srcId || !trgId) return;

    	    var siblings = _.filter(graph.getLinks(), function(sibling) {

    	        var _srcId = sibling.get('source').id;
    	        var _trgId = sibling.get('target').id;

    	        return (_srcId === srcId && _trgId === trgId) || (_srcId === trgId && _trgId === srcId);
    	    });

    	    switch (siblings.length) {

    	    case 0:
    	        // The link was removed and had no siblings.
    	        break;

    	    case 1:
    	        // There is only one link between the source and target. No vertices needed.
    	        cell.unset('vertices');
    	        break;

    	    default:

    	        // There is more than one siblings. We need to create vertices.

    	        // First of all we'll find the middle point of the link.
    	        var srcCenter = graph.getCell(srcId).getBBox().center();
    	        var trgCenter = graph.getCell(trgId).getBBox().center();
    	        var midPoint = g.line(srcCenter, trgCenter).midpoint();

    	        // Then find the angle it forms.
    	        var theta = srcCenter.theta(trgCenter);

    	        // This is the maximum distance between links
    	        var gap = 20;

    	        _.each(siblings, function(sibling, index) {

    	            // We want the offset values to be calculated as follows 0, 20, 20, 40, 40, 60, 60 ..
    	            var offset = gap * Math.ceil(index / 2);

    	            // Now we need the vertices to be placed at points which are 'offset' pixels distant
    	            // from the first link and forms a perpendicular angle to it. And as index goes up
    	            // alternate left and right.
    	            //
    	            //  ^  odd indexes 
    	            //  |
    	            //  |---->  index 0 line (straight line between a source center and a target center.
    	            //  |
    	            //  v  even indexes
    	            var sign = index % 2 ? 1 : -1;
    	            var angle = g.toRad(theta + sign * 90);

    	            // We found the vertex.
    	            var vertex = g.point.fromPolar(offset, angle, midPoint);

    	            sibling.set('vertices', [{ x: vertex.x, y: vertex.y }]);
    	        });
    	    }
    	};

  
  function generateGraph(jsons)
  {
	 
	  var graph = new joint.dia.Graph;

	  var js = JSON.parse(jsons);
	  var relationship = js.Relationship;
	
	  var city = js.City;
	  var paperSize = js.paperSize;

	  	rect = new Array(city.length);
		
	    var paper = new joint.dia.Paper({
	        el: $('#myholder'),
	        //width: 600,
	        //height: 200,
	        width: (paperSize+1)*250 ,
	        height: (paperSize+1)*250 ,
	        model: graph,
	        gridSize: 1
	    });
 
	   
	    for (var i=0; i<city.length; i++)
	    	{
		    rect[i] = new joint.shapes.basic.Rect({
		        position: { x: city[i].dim_x, y: city[i].dim_y },
		        size: { width: 120, height: 50 },
		        attrs: { rect: { fill: 'blue' }, text: { text: city[i].city, fill: 'white' } }
		    });

	    	}
	    links = new Array(relationship.length);
	    for(var i=0;i<relationship.length;i++)
	    	{
	    		var source = relationship[i].arr;
	    		var destination = relationship[i].dep;
	    		var flightID = relationship[i].flt;
	    		var sourceID;
	    		var destID;
	    		for(var j=0;j<city.length;j++)
	    			{
	    			//alert(city[j].valueOf())
	    			if(source.valueOf()==city[j].city.valueOf())
	    				{
	    					sourceID = rect[j].id;
	    				}
	    			else if(destination.valueOf()==city[j].city.valueOf())
    				{
    					destID = rect[j].id;
    				}
 
	    			}
	    		links[i] = new joint.dia.Link({
	    	        source: { id: sourceID },
	    	        target: { id: destID },
	    	        router: { name: 'manhattan' },
	    		    connector: { name: 'rounded' },
	    		    attrs: {
	    		        rect: { fill: 'white' },
	    		        text: { fill: 'blue', text: relationship[i].flt },
	    		        '.connection': { stroke: 'blue' },
	    		        //'.marker-source': { fill: 'black', d: 'M 10 0 L 0 5 L 10 10 z' },
	    		        '.marker-target': { fill: 'black', d: 'M 10 0 L 0 5 L 10 10 z' },
	    		    }
	    	    });
	    		
	    		
	    		links[i].label(0, {
	    		    position: .5,
	    		    attrs: {
	    		        rect: { fill: 'white' },
	    		        text: { fill: 'blue', text: relationship[i].flt }}
	    		});
	    		
	    	}
	    for (var i=0; i<city.length; i++)
    	{
    	graph.addCells([rect[i]]);
    	}
	    for (var i=0; i<relationship.length; i++)
    	{
	    	graph.addCells([links[i]]);
    	}
	    for(var i=0;i<links.length;i++)
		{
	    links[i].toBack();
		}
	    

	    
	    graph.on('change:position', function(cell) {

	        // has an obstacle been moved? Then reroute the link.
	        		for(var i=0;i<links.length;i++)
	        			{
	        			  if (_.contains(rect, cell)) paper.findViewByModel(links[i]).update();
	        			}
	        		 adjustVertices(graph,cell);
	      
	    });
	   

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

Set st = new HashSet();


while(result.next()) {
	int numColumns = rsmd.getColumnCount();
    JSONObject obj = new JSONObject();

    for (int i=1; i<numColumns+1; i++) {
      String column_name = rsmd.getColumnName(i);
      
      if(rsmd.getColumnType(i)==java.sql.Types.INTEGER){
          obj.put(column_name, result.getInt(column_name));
         }
         else if(rsmd.getColumnType(i)==java.sql.Types.NVARCHAR){ 
        	 String city = result.getNString(column_name);
          	 obj.put(column_name, city);
          	 System.out.println(city);
          	 st.add(city);
         }
         else
         {
        	 Object oc = result.getObject(column_name);
        	 obj.put(column_name, oc);
        	 System.out.println(oc);
        	 st.add(oc);
         }
    }
    json.add(obj);
    
}

JSONObject data = new JSONObject();
data.put("Relationship", json);

JSONArray listArray = new JSONArray();
int numberOfCities = st.size();
int dim_x[] = new int[numberOfCities];
int dim_y[] = new int[numberOfCities];
//double rootValue = Math.sqrt(numberOfCities);
int rootInt = 1;//(int)rootValue;
while ((rootInt*(rootInt+1))/2<numberOfCities)
{
	rootInt++;
}
int paperSize = rootInt;
System.out.println("Cities count "+numberOfCities);
System.out.println(rootInt);
int base_x = 200;
int base_y = 200;
int incr_x = 250;
int incr_y = 250;
int i= 0 ;
int j = 0;
while(i<numberOfCities)
{
	
	for(int k=0;k<rootInt;k++)
	{
		dim_x[i] = base_x+k*incr_x;
		dim_y[i] = base_y+j*incr_y;
		//System.out.println(i + " %" + dim_x[i]+" :#: "+ dim_y[i]);
		i++;
	}
	j++;
	rootInt--;
	
}
for(int t=0;t<numberOfCities;t++)
{
	//System.out.println(dim_x[t]+" : "+ dim_y[t]);
}

int count = 0;
for(Object oo:st)
{
	JSONObject cityGroup = new JSONObject();
	cityGroup.put("city", oo);
	cityGroup.put("dim_x", dim_x[count]);
	cityGroup.put("dim_y", dim_y[count]);
	listArray.add(cityGroup);
	count++;
}
data.put("City", listArray);
data.put("paperSize",paperSize);
System.out.println(data.toString());



%>
  <div id="myholder"></div>
 
  <script>
  generateGraph('<%= data %>');
</script>
</body>
</html>