<%@ page contentType="text/html; charset=utf-8" language="java"
     import="org.ecocean.*,
              org.ecocean.servlet.ServletUtilities,
              java.util.ArrayList,
              java.util.List,
              java.util.Map,
              java.util.Iterator,
              java.util.Properties,
              java.util.StringTokenizer,
              org.ecocean.cache.*
              "
%>



<jsp:include page="header.jsp" flush="true"/>

<%
String context=ServletUtilities.getContext(request);

//set up our Shepherd

Shepherd myShepherd=null;
myShepherd=new Shepherd(context);
myShepherd.setAction("index.jsp");


String langCode=ServletUtilities.getLanguageCode(request);

//check for and inject a default user 'tomcat' if none exists
// Make a properties object for lang support.
Properties props = new Properties();
// Grab the properties file with the correct language strings.
props = ShepherdProperties.getProperties("index.properties", langCode,context);


//check for and inject a default user 'tomcat' if none exists
if (!CommonConfiguration.isWildbookInitialized(myShepherd)) {
  System.out.println("WARNING: index.jsp has determined that CommonConfiguration.isWildbookInitialized()==false!");
  %>
    <script type="text/javascript">
      console.log("Wildbook is not initialized!");
    </script>
  <%
  StartupWildbook.initializeWildbook(request, myShepherd);
}






//let's quickly get the data we need from Shepherd

int numMarkedIndividuals=0;
int numEncounters=0;
int numDataContributors=0;
int numUsersWithRoles=0;
int numUsers=0;
//Shepherd myShepherd=new Shepherd(context);
myShepherd.beginDBTransaction();
QueryCache qc=QueryCacheFactory.getQueryCache(context);

//String url = "login.jsp";
//response.sendRedirect(url);
//RequestDispatcher dispatcher = getServletContext().getRequestDispatcher(url);
//dispatcher.forward(request, response);


try{


    //numMarkedIndividuals=myShepherd.getNumMarkedIndividuals();
    numMarkedIndividuals=qc.getQueryByName("numMarkedIndividuals", context).executeCountQuery(myShepherd).intValue();
    numEncounters=myShepherd.getNumEncounters();
    //numEncounters=qc.getQueryByName("numEncounters", context).executeCountQuery(myShepherd).intValue();
    //numDataContributors=myShepherd.getAllUsernamesWithRoles().size();
    numDataContributors=qc.getQueryByName("numUsersWithRoles", context).executeCountQuery(myShepherd).intValue();
    numUsers=qc.getQueryByName("numUsers", context).executeCountQuery(myShepherd).intValue();
    numUsersWithRoles = numUsers-numDataContributors;


}
catch(Exception e){
    e.printStackTrace();
}
finally{
   myShepherd.rollbackDBTransaction();
   myShepherd.closeDBTransaction();
}
%>

<section class="hero container-fluid main-section relative">
    <div class="container relative">
        <div class="col-xs-12 col-sm-10 col-md-8 col-lg-6">
            <h1 class="hidden">Wildbook</h1>
            <h2>Flukebook helps you study identify, and protect cetacean populations!</h2>
            <!--
            <button id="watch-movie" class="large light">
				Watch the movie
				<span class="button-icon" aria-hidden="true">
			</button>
			-->
            <a href="submit.jsp">
                <button class="large"><%= props.getProperty("reportEncounter") %><span class="button-icon" aria-hidden="true"></button>
            </a>
        </div>

	</div>


</section>

<section class="container text-center main-section">

	<h2 class="section-header"><%=props.getProperty("howItWorksH") %></h2>

  <!-- All carousel text can be modified in the index properties files -->

	<div id="howtocarousel" class="carousel slide" data-ride="carousel">
		<ol class="list-inline carousel-indicators slide-nav">
	        <li data-target="#howtocarousel" data-slide-to="0" class="active">1. <%=props.getProperty("carouselPhoto") %><span class="caret"></span></li>
	        <li data-target="#howtocarousel" data-slide-to="1" class="">2. <%=props.getProperty("carouselSubmit") %><span class="caret"></span></li>
	        <li data-target="#howtocarousel" data-slide-to="2" class="">3. <%=props.getProperty("carouselVerify") %><span class="caret"></span></li>
	        <li data-target="#howtocarousel" data-slide-to="3" class="">4. <%=props.getProperty("carouselMatching") %><span class="caret"></span></li>
	        <li data-target="#howtocarousel" data-slide-to="4" class="">5. <%=props.getProperty("carouselResult") %><span class="caret"></span></li>
	    </ol>
		<div class="carousel-inner text-left">
			<div class="item active">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
					<h3><%=props.getProperty("innerPhotoH3") %></h3>
					<p class="lead">
						<%=props.getProperty("innerPhotoP") %>
					</p>

				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="images/how_it_works_bellyshot_of_manta.jpg" alt=""  />
				</div>
			</div>
			<div class="item">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
          <h3><%=props.getProperty("innerSubmitH3") %></h3>
          <p class="lead">
            <%=props.getProperty("innerSubmitP") %>
          </p>
				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="images/how_it_works_submit.jpg" alt=""  />
				</div>
			</div>
			<div class="item">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
          <h3><%=props.getProperty("innerVerifyH3") %></h3>
          <p class="lead">
            <%=props.getProperty("innerVerifyP") %>
          </p>
				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="images/how_it_works_researcher_verification.jpg" alt=""  />
				</div>
			</div>
			<div class="item">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
          <h3><%=props.getProperty("innerMatchingH3") %></h3>
          <p class="lead">
            <%=props.getProperty("innerMatchingP") %>
          </p>
				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="images/how_it_works_matching_process.jpg" alt=""  />
				</div>
			</div>
			<div class="item">
				<div class="col-xs-12 col-sm-6 col-md-6 col-lg-6">
          <h3><%=props.getProperty("innerResultH3") %></h3>
          <p class="lead">
            <%=props.getProperty("innerResultP") %>
          </p>
				</div>
				<div class="col-xs-12 col-sm-4 col-sm-offset-2 col-md-4 col-md-offset-2 col-lg-4 col-lg-offset-2">
					<img class="pull-right" src="images/how_it_works_match_result.jpg" alt=""  />
				</div>
			</div>
		</div>
	</div>
</section>

<div class="container-fluid relative data-section">

    <aside class="container main-section">
        <div class="row">

            <!-- Random user profile to select -->
            <%
            myShepherd.beginDBTransaction();
            try{
								User featuredUser=myShepherd.getRandomUserWithPhotoAndStatement();
            if(featuredUser!=null){
                String profilePhotoURL="images/empty_profile.jpg";
                if(featuredUser.getUserImage()!=null){
                	profilePhotoURL="/"+CommonConfiguration.getDataDirectoryName(context)+"/users/"+featuredUser.getUsername()+"/"+featuredUser.getUserImage().getFilename();
                }

            %>
                <section class="col-xs-12 col-sm-6 col-md-4 col-lg-4 padding focusbox">
                    <div class="focusbox-inner opec">
                        <h2><%=props.getProperty("ourContributors") %></h2>
                        <div>
                            <img src="<%=profilePhotoURL %>" width="80px" height="*" alt="" class="pull-left" />
                            <p><%=featuredUser.getFullName() %>
                                <%
                                if(featuredUser.getAffiliation()!=null){
                                %>
                                <i><%=featuredUser.getAffiliation() %></i>
                                <%
                                }
                                %>
                            </p>
                            <p><%=featuredUser.getUserStatement() %></p>
                        </div>
                        <a href="whoAreWe.jsp" title="" class="cta">Show me all the contributors</a>
                    </div>
                </section>
            <%
            } // end if

            }
            catch(Exception e){e.printStackTrace();}
            finally{

            	myShepherd.rollbackDBTransaction();
            }
            %>


            <section class="col-xs-12 col-sm-6 col-md-4 col-lg-4 padding focusbox">
                <div class="focusbox-inner opec">
                    <h2>Latest animal encounters</h2>
                    <ul class="encounter-list list-unstyled">

                       <%
                       List<Encounter> latestIndividuals=myShepherd.getMostRecentIdentifiedEncountersByDate(3);
                       int numResults=latestIndividuals.size();
                       myShepherd.beginDBTransaction();
                       try{
	                       for(int i=0;i<numResults;i++){
	                           Encounter thisEnc=latestIndividuals.get(i);
	                           %>
	                            <li>
	                                <img src="cust/mantamatcher/img/manta-silhouette.png" alt="" width="85px" height="75px" class="pull-left" />
	                                <small>
	                                    <time>
	                                        <%=thisEnc.getDate() %>
	                                        <%
	                                        if((thisEnc.getLocationID()!=null)&&(!thisEnc.getLocationID().trim().equals(""))){
	                                        %>/ <%=thisEnc.getLocationID() %>
	                                        <%
	                                           }
	                                        %>
	                                    </time>
	                                </small>
	                                <p><a href="encounters/encounter.jsp?number=<%=thisEnc.getCatalogNumber() %>" title=""><%=thisEnc.getIndividualID() %></a></p>


	                            </li>
	                        <%
	                        }
						}
                       catch(Exception e){e.printStackTrace();}
                       finally{
                    	   myShepherd.rollbackDBTransaction();

                       }

                        %>

                    </ul>
                    <a href="encounters/searchResults.jsp?state=approved" title="" class="cta"><%=props.getProperty("seeMoreEncs") %></a>
                </div>
            </section>
            <section class="col-xs-12 col-sm-6 col-md-4 col-lg-4 padding focusbox">
                <div class="focusbox-inner opec">
                    <h2><%=props.getProperty("topSpotters")%></h2>
                    <ul class="encounter-list list-unstyled">
                    <%
                    myShepherd.beginDBTransaction();
                    try{
	                    //System.out.println("Date in millis is:"+(new org.joda.time.DateTime()).getMillis());
	                    long startTime=(new org.joda.time.DateTime()).getMillis()+(1000*60*60*24*30);

	                    System.out.println("  I think my startTime is: "+startTime);

	                    Map<String,Integer> spotters = myShepherd.getTopUsersSubmittingEncountersSinceTimeInDescendingOrder(startTime);
	                    int numUsersToDisplay=3;
	                    if(spotters.size()<numUsersToDisplay){numUsersToDisplay=spotters.size();}
	                    Iterator<String> keys=spotters.keySet().iterator();
	                    Iterator<Integer> values=spotters.values().iterator();
	                    while((keys.hasNext())&&(numUsersToDisplay>0)){
	                          String spotter=keys.next();
	                          int numUserEncs=values.next().intValue();
	                          if(myShepherd.getUser(spotter)!=null){
	                        	  String profilePhotoURL="images/empty_profile.jpg";
	                              User thisUser=myShepherd.getUser(spotter);
	                              if(thisUser.getUserImage()!=null){
	                              	profilePhotoURL="/"+CommonConfiguration.getDataDirectoryName(context)+"/users/"+thisUser.getUsername()+"/"+thisUser.getUserImage().getFilename();
	                              }
	                              //System.out.println(spotters.values().toString());
	                            Integer myInt=spotters.get(spotter);
	                            //System.out.println(spotters);

	                          %>
	                                <li>
	                                    <img src="<%=profilePhotoURL %>" width="80px" height="*" alt="" class="pull-left" />
	                                    <%
	                                    if(thisUser.getAffiliation()!=null){
	                                    %>
	                                    <small><%=thisUser.getAffiliation() %></small>
	                                    <%
	                                      }
	                                    %>
	                                    <p><a href="#" title=""><%=spotter %></a>, <span><%=numUserEncs %> <%=props.getProperty("encounters") %><span></p>
	                                </li>

	                           <%
	                           numUsersToDisplay--;
	                    }
	                   } //end while
                    }
                    catch(Exception e){e.printStackTrace();}
                    finally{myShepherd.rollbackDBTransaction();}

                   %>

                    </ul>
                    <a href="whoAreWe.jsp" title="" class="cta"><%=props.getProperty("allSpotters") %></a>
                </div>
            </section>
        </div>
    </aside>
</div>

<div class="container-fluid">
    <section class="container text-center  main-section">
       <div class="row">
            <section class="col-xs-12 col-sm-3 col-md-3 col-lg-3 padding">
                <p class="brand-primary"><i><span class="massive"><%=numMarkedIndividuals %></span> identified whales and dolphins</i></p>
            </section>
            <section class="col-xs-12 col-sm-3 col-md-3 col-lg-3 padding">
                <p class="brand-primary"><i><span class="massive"><%=numEncounters %></span> reported sightings</i></p>
            </section>
            <section class="col-xs-12 col-sm-3 col-md-3 col-lg-3 padding">

                <p class="brand-primary"><i><span class="massive"><%=numUsersWithRoles %></span> citizen scientists</i></p>
            </section>
            <section class="col-xs-12 col-sm-3 col-md-3 col-lg-3 padding">

                <p class="brand-primary"><i><span class="massive"><%=numDataContributors %></span> researchers and volunteers</i></p>
            </section>
        </div>

        <hr/>

        <main class="container">
            <article class="text-center">
                <div class="row">
                    <img src="cust/mantamatcher/img/why-we-do-this.png" alt="" class="pull-left col-xs-7 col-sm-4 col-md-4 col-lg-4 col-xs-offset-2 col-sm-offset-1 col-md-offset-1 col-lg-offset-1" />
                    <div class="col-xs-12 col-sm-6 col-md-6 col-lg-6 text-left">
                        <h1><%=props.getProperty("whyWeDoThis") %></h1>
                        <p class="lead"><%=props.getProperty("contributors") %></p>
                        <a href="#" title=""><%=props.getProperty("contributors") %></a>
                    </div>
                </div>
            </article>
        <main>

    </section>
</div>


<%
if((CommonConfiguration.getProperty("allowAdoptions", context)!=null)&&(CommonConfiguration.getProperty("allowAdoptions", context).equals("true"))){
%>
<div class="container-fluid">
    <section class="container main-section">

        <!-- Complete header for adoption section in index properties file -->
        <%=props.getProperty("adoptionHeader") %>
        <section class="adopt-section row">

            <!-- Complete text body for adoption section in index properties file -->
            <div class=" col-xs-12 col-sm-6 col-md-6 col-lg-6">
              <%=props.getProperty("adoptionBody") %>
            </div>
            <%
            myShepherd.beginDBTransaction();
            try{
	            Adoption adopt=myShepherd.getRandomAdoptionWithPhotoAndStatement();
	            if(adopt!=null){
	            %>
	            	<div class="adopter-badge focusbox col-xs-12 col-sm-6 col-md-6 col-lg-6">
		                <div class="focusbox-inner" style="overflow: hidden;">
		                	<%
		                    String profilePhotoURL="/"+CommonConfiguration.getDataDirectoryName(context)+"/adoptions/"+adopt.getID()+"/thumb.jpg";

		                	%>
		                    <img src="<%=profilePhotoURL %>" alt="" class="pull-right round">
		                    <h2><small>Meet an adopter:</small><%=adopt.getAdopterName() %></h2>
		                    <%
		                    if(adopt.getAdopterQuote()!=null){
		                    %>
			                    <blockquote>
			                        <%=adopt.getAdopterQuote() %>
			                    </blockquote>
		                    <%
		                    }
		                    %>
		                </div>
		            </div>

	            <%
				}
            }
            catch(Exception e){e.printStackTrace();}
            finally{myShepherd.rollbackDBTransaction();}

            %>


        </section>

        <hr/>
        <%= props.getProperty("donationText") %>
    </section>
</div>
<%
}
%>

<jsp:include page="footer.jsp" flush="true"/>


<%
myShepherd.closeDBTransaction();
myShepherd=null;
%>
