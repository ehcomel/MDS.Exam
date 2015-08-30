<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Exam: Vessels</title>
	<!-- Latest compiled and minified CSS -->
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css">
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap-theme.min.css">
	<link rel="stylesheet" type="text/css" href="css/exam.css">
	<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
	<script src="js/sort.js"></script>
	<script src="js/jquery-2.1.4.js"></script>
</head>
<body>
	<div align="center">
		<h1>This is the Vessels page.</h1>
	</div>
	<div align="center">
		<label>Filter: </label>
		<input style="padding-left: 20px;" id="searchInput" value="Type To Filter" >
	</div>
	<div id="vessels"></div>
	<div id="map"></div>
	
	<script type="text/javascript">
		var json_vessels = JSON.parse('${vessels}');
		var json_backup = json_vessels;
		var markers = [];
		var map;
		//backup will be used to recover the original json_vessels var for the map filter upgrade
	</script>
	
	<script type="text/javascript">
		function fillTable(){
			var data = JSON.parse('${vessels}');
			//alert('${vessels}');
			var table = "<table class=" + '"table table-striped"' + " id=" + '"indextable"' + ">";
			var header = '<thead>'
				   + '<tr>'
							+ '<th>' + "<a href=\"javascript:SortTable(0,'T');\">" + "Name"      + '</a>'+ '</th>'
							+ '<th>' + "<a href=\"javascript:SortTable(1,'T');\">" + "IMO"       + '</a>'+ '</th>'
							+ '<th>' + "<a href=\"javascript:SortTable(2,'T');\">" + "MMSI"      + '</a>'+ '</th>'
							+ '<th>' + "<a href=\"javascript:SortTable(3,'T');\">" + "Type"      + '</a>'+ '</th>'
							+ '<th>' + "<a href=\"javascript:SortTable(4,'N');\">" + "Longitude" + '</a>'+ '</th>'
							+ '<th>' + "<a href=\"javascript:SortTable(5,'N');\">" + "Latitude"  + '</a>'+ '</th>'
				   + '</tr>'
				   + '</thead>';
			table += header;
			table += '<tbody id='+ '"fbody"'+ '>';
			for(i=0;i<data.length;i++){
				var row = '<tr>' 
								+ '<td class="name">' + data[i].name + '</td>'
								+ '<td>' + data[i].imo + '</td>'
								+ '<td>' + data[i].mmsi + '</td>'
								+ '<td>' + data[i].type + '</td>'
								+ '<td>' + data[i].longitude + '</td>'
								+ '<td>' + data[i].latitude + '</td>' 
						+ '</tr>';
				table += row;	
			}
			table += '</tbody>';
			table += "</table>";
			document.getElementById("vessels").innerHTML = table;
		}
		function initMap() 
		{
			var data = JSON.parse('${vessels}');
			fillMap(data);
		}
		function fillMap(data){
			map = new google.maps.Map(document.getElementById('map'), {
			    center: {lat: 0.00, lng: 0.00},
			    zoom: 2
			});
			//from vessels get all latitudes and longitudes
			for(i=0;i<data.length;i++){
				var lng  = parseFloat(data[i].longitude);
				var lat  = parseFloat(data[i].latitude);
				var name = data[i].name[0];
				var point = new google.maps.LatLng(lat,lng);
				var marker = new google.maps.Marker({ 
					position: point, 
					title: name, 
					map: map 
				});
				markers.push(marker);
			}
		}
		// Sets the map on all markers in the array.
		function setMapOnAll(_map) {
			for (var i = 0; i < markers.length; i++) {
				markers[i].setMap(_map);
		  	}
		}
		//removes markers from map but doesn't delete them
		function clearMarkers(){
			setMapOnAll(null);
		}
		//used to show filtered markers on map
		function setMapOnMarkers(_map, _markers){
			for(var i = 0; i < _markers.length; i++){
				_markers[i].setMap(_map);
			}
		}
		function getMarkerByName(name){
			for(i = 0; i < markers.length; i++){
				if(markers[i].getTitle() == name){
					return markers[i];
				}				
			}
		}
	</script>

	<script type="text/javascript">
		//this is the filter script
		//
		//		UPGRADE: filter shows only markers of rows filtered
		//		if row showed with .show(): update json_vessels
		//		at the beginning, set json_vessels to original json_backup 
		//
		$("#searchInput").keyup(function () {
			//use original data for json_vessels
			json_vessels = json_backup;
		    //split the current value of searchInput
		    var data = this.value.split(" ");
		    //create a jquery object of the rows
		    var jo = $("#fbody").find("tr");
		    if (this.value == "") {
		        jo.show();
		        setMapOnMarkers(map, markers);
		        return;
		    }
		    //hide all the rows
		    jo.hide();
		  	//hide all markers
		    clearMarkers();
	
		    //override :contains filter to become case insensitive
		    jQuery.expr[':'].contains = function(a, i, m) {
			  return jQuery(a).text().toUpperCase()
			      .indexOf(m[3].toUpperCase()) >= 0;
			};
		    
		    //Recusively filter the jquery object to get results.
		    var filtered = jo.filter(function (i, v) {
		        var $t = $(this);
		        for (var d = 0; d < data.length; ++d) {
		            if ($t.is(":contains('" + data[d] + "')")) {
		                return true;
		            }
		        }
		        return false;
		    });
		    //show the filtered rows that match.
		    filtered.show();
		    var temp_markers = [];
		  	//get from jo the "name" column (first element)
		    for(i = 0; i < filtered.length; i++){
		    	var n = jo[i].firstElementChild.innerHTML;
		    	temp_markers.push(getMarkerByName(n));
		    }
		    //show the filtered markers on the map
		    setMapOnMarkers(map, temp_markers);
		}).focus(function () {
		    this.value = "";
		    $(this).css({
		        "color": "black"
		    });
		    $(this).unbind('focus');
		}).css({
		    "color": "#C0C0C0"
		});
	</script>
	<script>
		fillTable(json_vessels);
	</script>
	<script async defer src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAN95zqq0jR-rPfKZOt9unut1oG0Bcy6Ik&callback=initMap"></script>
	
</body>
</html>