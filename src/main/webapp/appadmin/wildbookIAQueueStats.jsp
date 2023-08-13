<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@ page contentType="text/html; charset=utf-8" language="java" import="org.joda.time.LocalDateTime,org.ecocean.servlet.importer.*,
org.joda.time.format.DateTimeFormatter,
org.joda.time.format.ISODateTimeFormat,java.net.*,
org.ecocean.grid.*,
org.ecocean.media.MediaAsset,org.ecocean.servlet.importer.ImportTask,
java.io.*,java.util.*, java.io.FileInputStream, 
java.text.SimpleDateFormat,
java.util.Date,org.ecocean.ia.*,org.json.JSONObject,
org.ecocean.identity.IBEISIA,org.ecocean.social.*,org.ecocean.ia.Task,
org.apache.poi.ss.usermodel.DateUtil,org.ecocean.identity.*,org.ecocean.queue.*,
java.io.File, java.io.FileNotFoundException, org.ecocean.*,org.ecocean.servlet.*,javax.jdo.*, java.lang.StringBuffer, java.util.Vector, 
java.util.Iterator, java.lang.NumberFormatException"%>



<%

String context="context0";
context=ServletUtilities.getContext(request);

Shepherd myShepherd=new Shepherd(context);



%>



<jsp:include page="../header.jsp" flush="true"/>
<div class="container maincontent">

<h1>Wildbook Machine Learning Queue Monitoring</h1>


<%

myShepherd.beginDBTransaction();



try{

	long TwoFourHours=1000*60*60*24;
  	String filter= "select from org.ecocean.ia.Task where created > "+(System.currentTimeMillis()-TwoFourHours);
	
	Query q=myShepherd.getPM().newQuery(filter);
	q.setOrdering("created desc");
	
    Collection c=(Collection) (q.execute());
   	ArrayList<Task> allTasks = new ArrayList<Task>(c);
	q.closeAll();
	int count=0;
	
	int numParents=0;
	int numChildTasks=0;
	int hasUsername=0;
	int numDetectionTasks=0;
	int numIDTasks = 0;
	int numFastlaneTasks = 0;
	
	HashMap<String, Integer> userDistribution = new HashMap<String,Integer>();
	HashMap<String, Integer> algorithms = new HashMap<String,Integer>();
	HashMap<String, Integer> species = new HashMap<String,Integer>();
	HashMap<String, Integer> bulkImports = new HashMap<String,Integer>();
	HashMap<String, Integer> idTaskStatus = new HashMap<String,Integer>();
	
	
	for(Task task:allTasks){
		count++;
		JSONObject params=task.getParameters();
		if(task.hasChildren()){numParents++;}
		else{

			if(params!=null && !params.optString("ibeis.detection").equals("")){
				numDetectionTasks++;
			}
			else if(params!=null && params.optJSONObject("ibeis.identification")!=null){
				numIDTasks++;
				String algo = params.optJSONObject("ibeis.identification").optJSONObject("query_config_dict").optString("pipeline_root");
				if(algo!=null && !algo.equals("")){
					if(!algorithms.containsKey(algo)){algorithms.put(algo, new Integer(1));}
					else{
						int distribCount=algorithms.get(algo).intValue();
						distribCount++;
						algorithms.put(algo, distribCount);
					}
				}
				
				//lets get status
				String idState=task.getStatus(myShepherd);
				if(idState!=null){
					if(!idTaskStatus.containsKey(idState)){idTaskStatus.put(idState, new Integer(1));}
					else{
						int distribCount=idTaskStatus.get(idState).intValue();
						distribCount++;
						idTaskStatus.put(idState, distribCount);
					}
				}
				
				//fastlane
				if(task.isFastlane(myShepherd))numFastlaneTasks++;
			}
			
			numChildTasks++;
			
			List<Annotation> annots=task.getObjectAnnotations();
			if(annots!=null && annots.size()>0){
				Annotation annot=annots.get(0);
				Encounter enc=annot.findEncounter(myShepherd);
				if(enc!=null){
					if(enc.getImportTask(myShepherd)!=null){
						ImportTask tasky=enc.getImportTask(myShepherd);
						if(!bulkImports.containsKey(tasky.getId())){bulkImports.put(tasky.getId(), new Integer(1));}
						else{
							int distribCount=bulkImports.get(tasky.getId()).intValue();
							distribCount++;
							bulkImports.put(tasky.getId(), distribCount);
						}
						
					}
					Taxonomy taxy=enc.getTaxonomy(myShepherd);
					if(taxy!=null){
						if(!species.containsKey(taxy.getScientificName())){species.put(taxy.getScientificName(), new Integer(1));}
						else{
							int distribCount=species.get(taxy.getScientificName()).intValue();
							distribCount++;
							species.put(taxy.getScientificName(), distribCount);
						}
					}
					if(enc.getSubmitterID()!=null){
						
						hasUsername++;
						String username = enc.getSubmitterID();
						if(!userDistribution.containsKey(username)){userDistribution.put(username, new Integer(1));}
						else{
							int distribCount=userDistribution.get(username).intValue();
							distribCount++;
							userDistribution.put(username, distribCount);
						}
						
					}
				}
			}


		}
		
	}
	%>
	
	
	<h2>Current Queue Status</h2>
	<ul>
		<li>Wildbook Image Analysis (WBIA) Machine Learning Server
			<ul>
				<li>There are currently <%=WbiaQueueUtil.getSizeDetectionJobQueue(false) %> detection jobs waiting to complete in WBIA.</li>
				<li>There are currently <%=WbiaQueueUtil.getSizeIDJobQueue(false) %> ID jobs waiting to complete in WBIA.</li>
			</ul>
		</li>
		<li>Queuing in line for WBIA
		<%
		org.ecocean.queue.Queue iaQueue = QueueUtil.getBest(context, "IA");
		org.ecocean.queue.Queue detectionQueue = QueueUtil.getBest(context, "detection");
		long iaQueueSize=iaQueue.getQueueSize();	
		long detectionQueueSize=detectionQueue.getQueueSize();
		%>
			<ul>
				<li>There are currently <%=iaQueueSize %> slow lane ID jobs waiting to go to WBIA in the slow lane.</li>
				<li>There are currently <%=detectionQueueSize %> detection and ID jobs waiting to go to WBIA in the fast lane.</li>
				
			</ul>
		</li>
	</ul>
	
	<h2>Tasks Created in the Last 24 Hours</h2>
	<ul>
	
	<li>Num parent tasks: <%=numParents %></li>
	<li>Num child tasks: <%=numChildTasks %>
		<ul>
			<li>Num detection tasks: <%=numDetectionTasks %></li>
			<li>Num ID tasks created: <%=numChildTasks %>
				<ul>
					<li>By queue
						<ul>
							<li>Num fastlane ID tasks: <%=numFastlaneTasks %></li>
							<li>Num bulk import/project ID tasks: <%=(numChildTasks-numFastlaneTasks) %></li>
						</ul>
					</li>
					<li>By current queue state
						<ul>
						<%
						for(String status:idTaskStatus.keySet()){
						%>
							<li><%=status %>: <%=idTaskStatus.get(status) %></li>
						<%
						}
						%>
						</ul>
					</li>
					<li>By user
						<ul>
						<%
						for(String status:userDistribution.keySet()){
						%>
							<li><%=status %>: <%=userDistribution.get(status) %></li>
						<%
						}
						%>
						</ul>
					</li>
					<li>By species
						<ul>
						<%
						for(String status:species.keySet()){
						%>
							<li><%=status %>: <%=species.get(status) %></li>
						<%
						}
						%>
						</ul>
					</li>
					<li>By algorithm
						<ul>
						<%
						for(String status:algorithms.keySet()){
						%>
							<li><%=status %>: <%=algorithms.get(status) %></li>
						<%
						}
						%>
						</ul>
					</li>
					<li>By bulk imports
						<ul>
						<%
						for(String status:bulkImports.keySet()){
						%>
							<li><a target="_blank" href="../import.jsp?taskId=<%=status %>"><%=status %></a>: <%=bulkImports.get(status) %></li>
						<%
						}
						%>
						</ul>
					</li>
				</ul>
			</li>
		</ul>
	</li>


	
	<%
	


}
catch(Exception e){
	e.printStackTrace();
}
finally{
	myShepherd.rollbackDBTransaction();
	myShepherd.closeDBTransaction();

}


%>

</ul>
</div>
<jsp:include page="../footer.jsp" flush="true"/>
