<%--
  ~ The Shepherd Project - A Mark-Recapture Framework
  ~ Copyright (C) 2011 Jason Holmberg
  ~
  ~ This program is free software; you can redistribute it and/or
  ~ modify it under the terms of the GNU General Public License
  ~ as published by the Free Software Foundation; either version 2
  ~ of the License, or (at your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
  --%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ page contentType="text/html; charset=utf-8" language="java"
         import="org.dom4j.Document,org.dom4j.DocumentHelper, org.dom4j.Element, org.ecocean.*, java.io.File,java.io.FileWriter, java.util.Properties, java.util.Vector" %>


<html>
<head>


  <%


    //let's load encounterSearch.properties
    String langCode = "en";
    if (session.getAttribute("langCode") != null) {
      langCode = (String) session.getAttribute("langCode");
    }

    Properties encprops = new Properties();
    encprops.load(getClass().getResourceAsStream("/bundles/" + langCode + "/mappedSearchResults.properties"));


    Shepherd myShepherd = new Shepherd();


    int startNum = 1;
    int endNum = 10;

    String kmlFilename = "KMLExport_" + request.getRemoteUser() + ".kml";


//setup the KML output
    Document document = DocumentHelper.createDocument();
    Element root = document.addElement("kml");
    root.addAttribute("xmlns", "http://www.opengis.net/kml/2.2");
    root.addAttribute("xmlns:gx", "http://www.google.com/kml/ext/2.2");
    Element docElement = root.addElement("Document");

    boolean addTimeStamp = false;
    boolean generateKML = false;
    if (request.getParameter("generateKML") != null) {
      generateKML = true;
    }
    if (request.getParameter("addTimeStamp") != null) {
      addTimeStamp = true;
    }

//add styles first if necessary
//Element styleElement1 = docElement.addElement( "Style" );


    try {

      if (request.getParameter("startNum") != null) {
        startNum = (new Integer(request.getParameter("startNum"))).intValue();
      }
      if (request.getParameter("endNum") != null) {
        endNum = (new Integer(request.getParameter("endNum"))).intValue();
      }

    } catch (NumberFormatException nfe) {
      startNum = 1;
      endNum = 10;
    }

    int numResults = 0;


    Vector rEncounters = new Vector();

    myShepherd.beginDBTransaction();
    String order = "";

    EncounterQueryResult queryResult = EncounterQueryProcessor.processQuery(myShepherd, request, order);
    rEncounters = queryResult.getResult();
    //rEncounters = EncounterQueryProcessor.processQuery(myShepherd, request, order);


  %>

  <title><%=CommonConfiguration.getHTMLTitle()%>
  </title>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
  <meta name="Description" content="<%=CommonConfiguration.getHTMLDescription()%>"/>
  <meta name="Keywords" content="<%=CommonConfiguration.getHTMLKeywords()%>"/>
  <meta name="Author" content="<%=CommonConfiguration.getHTMLAuthor()%>"/>
  <link href="<%=CommonConfiguration.getCSSURLLocation(request)%>" rel="stylesheet" type="text/css"/>
  <link rel="shortcut icon" href="<%=CommonConfiguration.getHTMLShortcutIcon()%>"/>

  <script>
    function getQueryParameter(name) {
      name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
      var regexS = "[\\?&]" + name + "=([^&#]*)";
      var regex = new RegExp(regexS);
      var results = regex.exec(window.location.href);
      if (results == null)
        return "";
      else
        return results[1];
    }
  </script>


</head>


<style type="text/css">
  #tabmenu {
    color: #000;
    border-bottom: 2px solid black;
    margin: 12px 0px 0px 0px;
    padding: 0px;
    z-index: 1;
    padding-left: 10px
  }

  #tabmenu li {
    display: inline;
    overflow: hidden;
    list-style-type: none;
  }

  #tabmenu a, a.active {
    color: #DEDECF;
    background: #000;
    font: bold 1em "Trebuchet MS", Arial, sans-serif;
    border: 2px solid black;
    padding: 2px 5px 0px 5px;
    margin: 0;
    text-decoration: none;
    border-bottom: 0px solid #FFFFFF;
  }

  #tabmenu a.active {
    background: #FFFFFF;
    color: #000000;
    border-bottom: 2px solid #FFFFFF;
  }

  #tabmenu a:hover {
    color: #ffffff;
    background: #7484ad;
  }

  #tabmenu a:visited {
    color: #E8E9BE;
  }

  #tabmenu a.active:hover {
    background: #7484ad;
    color: #DEDECF;
    border-bottom: 2px solid #000000;
  }
</style>


<body onload="initialize()" onunload="GUnload()">
<div id="wrapper">
<div id="page">
<jsp:include page="../header.jsp" flush="true">
  <jsp:param name="isAdmin" value="<%=request.isUserInRole(\"admin\")%>" />
</jsp:include>
<div id="main">

<ul id="tabmenu">

  <li><a href="searchResults.jsp?<%=request.getQueryString() %>"><%=encprops.getProperty("table")%>
  </a></li>
  <li><a
    href="thumbnailSearchResults.jsp?<%=request.getQueryString() %>"><%=encprops.getProperty("matchingImages")%>
  </a></li>
  <li><a class="active"><%=encprops.getProperty("mappedResults")%>
  </a></li>
  <li><a
    href="../xcalendar/calendar2.jsp?<%=request.getQueryString() %>"><%=encprops.getProperty("resultsCalendar")%>
  </a></li>

</ul>
<table width="810px" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>
      <br/>

      <h1 class="intro"><%=encprops.getProperty("title")%>
      </h1>
    </td>
  </tr>
</table>
<p><%=encprops.getProperty("exportedKML")%>: <a
  href="http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/<%=kmlFilename%>"><%=kmlFilename%>
</a><br>
  <em><%=encprops.getProperty("rightClickLink")%>
  </em>
</p>


<%
  Vector haveGPSData = new Vector();
  int count = 0;

  for (int f = 0; f < rEncounters.size(); f++) {

    //Encounter enc=(Encounter)allEncounters.next();
    Encounter enc = (Encounter) rEncounters.get(f);
    count++;
    numResults++;
    if ((enc.getDWCDecimalLatitude() != null) && (enc.getDWCDecimalLongitude() != null)) {
      haveGPSData.add(enc);
    }

    //populate KML file ====================================================

    if ((enc.getDWCDecimalLongitude() != null) && (enc.getDWCDecimalLatitude() != null)) {
      Element placeMark = docElement.addElement("Placemark");
      Element name = placeMark.addElement("name");
      String nameText = "";

      //add the name
      if (enc.isAssignedToMarkedIndividual().equals("Unassigned")) {
        nameText = "Encounter " + enc.getEncounterNumber();
      } else {
        nameText = enc.isAssignedToMarkedIndividual() + ": Encounter " + enc.getEncounterNumber();
      }
      name.setText(nameText);

      //add the visibility element
      Element viz = placeMark.addElement("visibility");
      viz.setText("1");

      //add the descriptive HTML
      Element description = placeMark.addElement("description");

      String descHTML = "<p><a href=\"http://" + CommonConfiguration.getURLLocation(request) + "/encounters/encounter.jsp?noscript=true&number=" + enc.getEncounterNumber() + "\">Direct Link</a></p>";
      descHTML += "<p> <strong>Date:</strong> " + enc.getDate() + "</p>";
      descHTML += "<p> <strong>Location:</strong><br>" + enc.getLocation() + "</p>";
      if (enc.getSize() > 0) {
        descHTML += "<p> <strong>Size:</strong> " + enc.getSize() + " meters</p>";
      }
      descHTML += "<p> <strong>Sex:</strong> " + enc.getSex() + "</p>";
      if (!enc.getComments().equals("")) {
        descHTML += "<p> <strong>Comments:</strong> " + enc.getComments() + "</p>";
      }

      descHTML += "<strong>Images</strong><br>";
      Vector imgs = enc.getAdditionalImageNames();
      int imgsNum = enc.getAdditionalImageNames().size();
      for (int imgNum = 0; imgNum < imgsNum; imgNum++) {
        descHTML += ("<br>" + "<a href=\"http://" + CommonConfiguration.getURLLocation(request) + "/encounters/encounter.jsp?noscript=true&number=" + enc.getEncounterNumber() + "\"><img src=\"http://" + CommonConfiguration.getURLLocation(request) + "/encounters/" + enc.getEncounterNumber() + "/" + (imgNum + 1) + ".jpg\"></a>");
      }

      description.addCDATA(descHTML);

      if (addTimeStamp) {
        //add the timestamp
        String stampString = "";
        if (enc.getYear() != -1) {
          stampString += enc.getYear();
          if (enc.getMonth() != -1) {
            String tsMonth = Integer.toString(enc.getMonth());
            if (tsMonth.length() == 1) {
              tsMonth = "0" + tsMonth;
            }
            stampString += ("-" + tsMonth);
            if (enc.getDay() != -1) {
              String tsDay = Integer.toString(enc.getDay());
              if (tsDay.length() == 1) {
                tsDay = "0" + tsDay;
              }
              stampString += ("-" + tsDay);
            }
          }
        }

        if (!stampString.equals("")) {
          Element timeStamp = placeMark.addElement("TimeStamp");
          timeStamp.addNamespace("gx", "http://www.google.com/kml/ext/2.2");
          Element when = timeStamp.addElement("when");
          when.setText(stampString);
        }
      }

      //add the actual lat-long points
      Element point = placeMark.addElement("Point");
      Element coords = point.addElement("coordinates");
      String coordsString = enc.getDWCDecimalLongitude() + "," + enc.getDWCDecimalLatitude();
      if (enc.getMaximumElevationInMeters() != 0.0) {
        coordsString += "," + enc.getMaximumElevationInMeters();
      } else {
        coordsString += ",0";
      }
      coords.setText(coordsString);


    }
  }
  //end KML ==============================================================


  // end KML export =========================================================


  myShepherd.rollbackDBTransaction();

  startNum = startNum + 10;
  endNum = endNum + 10;

  if (endNum > numResults) {
    endNum = numResults;
  }
  String numberResights = "";
  if (request.getParameter("numResights") != null) {
    numberResights = "&numResights=" + request.getParameter("numResights");
  }
  String qString = request.getQueryString();
  int startNumIndex = qString.indexOf("&startNum");
  if (startNumIndex > -1) {
    qString = qString.substring(0, startNumIndex);
  }


%>


<br>

<%


  File kmlFile = new File(getServletContext().getRealPath(("/encounters/" + kmlFilename)));

  FileWriter kmlWriter = new FileWriter(kmlFile);
  org.dom4j.io.OutputFormat format = org.dom4j.io.OutputFormat.createPrettyPrint();
  format.setLineSeparator(System.getProperty("line.separator"));
  org.dom4j.io.XMLWriter writer = new org.dom4j.io.XMLWriter(kmlWriter, format);
  writer.write(document);
  writer.close();

%>


<p><strong><img src="../images/2globe_128.gif" width="64" height="64"
                align="absmiddle"/> <%=encprops.getProperty("mappedResults")%>
</strong></p>
<%
  if (haveGPSData.size() > 0) {
    myShepherd.beginDBTransaction();
    try {
%>

<p><%=encprops.getProperty("mapNote")%>
</p>
<script
  src="http://maps.google.com/maps?file=api&amp;v=3.2&amp;key=<%=CommonConfiguration.getGoogleMapsKey() %>"
  type="text/javascript"></script>
<script type="text/javascript">
  function initialize() {
    if (GBrowserIsCompatible()) {


      var map = new GMap2(document.getElementById("map_canvas"));
      var bounds = new GLatLngBounds();


      var ne_lat = parseFloat(getQueryParameter("ne_lat"));
      var ne_long = parseFloat(getQueryParameter('ne_long'));
      var sw_lat = parseFloat(getQueryParameter('sw_lat'));
      var sw_long = parseFloat(getQueryParameter('sw_long'));
      //if((ne_lat.length>0)&&(ne_long.length>0)&&(sw_lat.length>0)&&(sw_long.length>0)){
      //}


    <%
        double centroidX=0;
        int countPoints=0;
        double centroidY=0;
        for(int c=0;c<haveGPSData.size();c++) {
          Encounter mapEnc=(Encounter)haveGPSData.get(c);
          countPoints++;
          centroidX+=mapEnc.getDecimalLatitudeAsDouble();
          centroidY+=mapEnc.getDecimalLongitudeAsDouble();
        }
        centroidX=centroidX/countPoints;
        centroidY=centroidY/countPoints;
      %>

      //map.setCenter(new GLatLng(
    <%=centroidX%>,
    <%=centroidY%>), 1);
      map.addControl(new GSmallMapControl());
      map.addControl(new GMapTypeControl());
      map.setMapType(G_HYBRID_MAP);
    <%for(int t=0;t<haveGPSData.size();t++) {
          if(t<101){
          Encounter mapEnc=(Encounter)haveGPSData.get(t);
          double myLat=mapEnc.getDecimalLatitudeAsDouble();
          double myLong=mapEnc.getDecimalLongitudeAsDouble();
          %>
      var point<%=t%> = new GLatLng(<%=myLat%>, <%=myLong%>, false);
      bounds.extend(point<%=t%>);

      var marker<%=t%> = new GMarker(point<%=t%>);
      GEvent.addListener(marker<%=t%>, "click", function() {
        window.location = "http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/encounter.jsp?number=<%=mapEnc.getEncounterNumber()%>";
      });
      GEvent.addListener(marker<%=t%>, "mouseover", function() {
        marker<%=t%>.openInfoWindowHtml("<%=encprops.getProperty("markedIndividual")%>: <strong><a target=\"_blank\" href=\"http://<%=CommonConfiguration.getURLLocation(request)%>/individuals.jsp?number=<%=mapEnc.isAssignedToMarkedIndividual()%>\"><%=mapEnc.isAssignedToMarkedIndividual()%></a></strong><br><table><tr><td><img align=\"top\" border=\"1\" src=\"http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/<%=mapEnc.getEncounterNumber()%>/thumb.jpg\"></td><td><%=encprops.getProperty("date")%>: <%=mapEnc.getDate()%><br><%=encprops.getProperty("sex")%>: <%=mapEnc.getSex()%><br><br><a target=\"_blank\" href=\"http://<%=CommonConfiguration.getURLLocation(request)%>/encounters/encounter.jsp?number=<%=mapEnc.getEncounterNumber()%>\" ><%=encprops.getProperty("go2encounter")%></a></td></tr></table>");
      });


      map.addOverlay(marker<%=t%>);

    <%
        }
      }
      %>
      if (!bounds.isEmpty()) {
        //map.setZoom();
        map.setCenter(bounds.getCenter(), map.getBoundsZoomLevel(bounds));
      }
      else {
        map.setCenter(new GLatLng(<%=centroidX%>, <%=centroidY%>), 1);
      }
    }
  }
</script>


<div id="map_canvas" style="width: 510px; height: 340px"></div>

<table>
  <tr>
    <td align="left">

      <p><strong><%=encprops.getProperty("queryDetails")%>
      </strong></p>

      <p class="caption"><strong><%=encprops.getProperty("prettyPrintResults") %>
      </strong><br/>
        <%=queryResult.getQueryPrettyPrint().replaceAll("locationField", encprops.getProperty("location")).replaceAll("locationCodeField", encprops.getProperty("locationID")).replaceAll("verbatimEventDateField", encprops.getProperty("verbatimEventDate")).replaceAll("alternateIDField", encprops.getProperty("alternateID")).replaceAll("behaviorField", encprops.getProperty("behavior")).replaceAll("Sex", encprops.getProperty("sex")).replaceAll("nameField", encprops.getProperty("nameField")).replaceAll("selectLength", encprops.getProperty("selectLength")).replaceAll("numResights", encprops.getProperty("numResights")).replaceAll("vesselField", encprops.getProperty("vesselField"))%>
      </p>

      <p class="caption"><strong><%=encprops.getProperty("jdoql")%>
      </strong><br/>
        <%=queryResult.getJDOQLRepresentation()%>
      </p>

    </td>
  </tr>
</table>

<%

    } catch (Exception e) {
      e.printStackTrace();
    }

  }
  myShepherd.rollbackDBTransaction();
  myShepherd.closeDBTransaction();
  rEncounters = null;
  haveGPSData = null;

%>
<jsp:include page="../footer.jsp" flush="true"/>
</div>
</div>
<!-- end page --></div>
<!--end wrapper -->

</body>
</html>




