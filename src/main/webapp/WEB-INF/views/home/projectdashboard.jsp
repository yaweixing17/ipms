<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring"%>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
	
<link href="${pageContext.request.contextPath}/resources/fullcalendar/fullcalendar.min.css" rel="stylesheet" type="text/css" media="screen" />
<link href="${pageContext.request.contextPath}/resources/fullcalendar/fullcalendar.print.min.css" rel="stylesheet" type="text/css" media="print" />
	
<script src="${pageContext.request.contextPath}/resources/fullcalendar/lib/moment.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/fullcalendar/lib/jquery.min.js"></script>
<script src="${pageContext.request.contextPath}/resources/fullcalendar/fullcalendar.min.js"></script>

<script src="https://www.google.com/jsapi"></script>
<!-- <script src= "http://code.jquery.com/jquery-1.8.3.js"></script>
<script src="http://code.jquery.com/ui/1.9.2/jquery-ui.js"></script>
 -->
<script type="text/javascript">
	$(document).ready(function() {

		$('#dashboard ul li a').append('<span></span>');

		$('#dashboard ul li a').hover(function() {
			$(this).find('span').animate({
				opacity : 'show',
				top : '-70'
			}, 'slow');

			var hoverTexts = $(this).attr('title');
			$(this).find('span').text(hoverTexts);
		},

		function() {
			$(this).find('span').animate({
				opacity : 'hide',
				top : '-90'
			}, 'fast');
		});
		
		$('#calendar').fullCalendar({
			header: {
				left: 'prev,next today',
				right: 'title'
			},
			defaultDate: '2016-12-12',
			navLinks: true, // can click day/week names to navigate views
			editable: true,
			eventLimit: true, // allow "more" link when too many events
			events: [
				<c:forEach var="meeting" items="${meetings}">
				{
		            title: '${meeting.title}',
			        start: '${meeting.date}',
	                end: '${meeting.endDate}',
	                url: '${pageContext.request.contextPath}/app/meeting/${meeting.id}'
				},
				</c:forEach>
				{
					title: 'Click for Google',
					url: 'http://google.com/',
					start: '2016-12-28'
				}
			]
		});
	}); 
</script>

<script type='text/javascript' src='https://www.google.com/jsapi'></script>
<script type='text/javascript'>
	google.load("visualization", "1.0", {
		packages : [ "corechart" ]
	});
	google.setOnLoadCallback(drawChart);
	function drawChart() {
		var options = {
			cht : 'lc',
			chds : '0,160'
		};
		<c:forEach var='item' items='${projectEvmMap}'>
		<c:if test="${item.key == 10035 || item.key == 10039}">
		var dataTable = new google.visualization.DataTable();
		dataTable.addColumn('string', 'Date');
		dataTable.addColumn('number', 'PV');
		dataTable.addColumn('number', 'CV');
		dataTable.addColumn('number', 'EV');
		<c:forEach var='evm' items='${item.value}'>

		var date = '<fmt:formatDate type="date" dateStyle="short" value="${evm.date}"/>';
		var pv = <fmt:parseNumber type="number" value="${evm.bcws}"/>;
		var ac = <fmt:parseNumber type="number" value="${evm.acwp}"/>;
		var ev = <fmt:parseNumber type="number" value="${evm.bcwp}"/>;
		dataTable.addRow([ date, pv, ac, ev ]);
		</c:forEach>
		var id = 'chart_div_' + '<c:out value="${item.key}"/>';
		var chart = new google.visualization.LineChart(document
				.getElementById(id));
		chart.draw(dataTable, options);
		</c:if>
		</c:forEach>

	}
</script>
<style>
  #calendar {
		max-width: 900px;
		margin: 0 auto;
	}
</style>
<script type='text/javascript' src='https://www.google.com/jsapi'></script>

<style>
path {  stroke: #fff; }
path:hover {  opacity:0.9; }
rect:hover {  fill:blue; }
.axis {  font: 10px sans-serif; }
.legend tr{    border-bottom:1px solid grey; }
.legend tr:first-child{    border-top:1px solid grey; }

.axis path,
.axis line {
  fill: none;
  stroke: #000;
  shape-rendering: crispEdges;
}

.x.axis path {  display: none; }
.legend{
    margin-bottom:76px;
    display:inline-block;
    border-collapse: collapse;
    border-spacing: 0px;
}
.legend td{
    padding:4px 5px;
    vertical-align:bottom;
}
.legendFreq, .legendPerc{
    align:right;
    width:50px;
}
  #calendar {
		max-width: 900px;
		margin: 0 auto;
	}
</style>
<div id="content">
	<div class="grid_container">
	
	<!--  D3.js code starting -->
<h4 style="padding-left:450px;">Project Status</h4>
<div id='dashboard' style="padding-left:150px;"></div><div id='dashboard'>
</div>
<script src="http://d3js.org/d3.v3.min.js"></script>
<script>
function dashboard(id, fData){
    var barColor = 'steelblue';
    function segColor(c){ return {Tasks:"#41ab5d", Risks:"#e08214",Issues:"purple"}[c]; }
    
    // compute total for each state.
    fData.forEach(function(d){d.total=d.freq.Tasks+d.freq.Risks+d.freq.Issues;});
    
    // function to handle histogram.
    function histoGram(fD){
        var hG={},    hGDim = {t: 60, r: 0, b: 30, l: 0};
        hGDim.w = 500 - hGDim.l - hGDim.r, 
        hGDim.h = 300 - hGDim.t - hGDim.b;
            
        //create svg for histogram.
        var hGsvg = d3.select(id).append("svg")
            .attr("width", hGDim.w + hGDim.l + hGDim.r)
            .attr("height", hGDim.h + hGDim.t + hGDim.b).append("g")
            .attr("transform", "translate(" + hGDim.l + "," + hGDim.t + ")");

        // create function for x-axis mapping.
        var x = d3.scale.ordinal().rangeRoundBands([0, hGDim.w], 0.1)
                .domain(fD.map(function(d) { return d[0]; }));

        // Add x-axis to the histogram svg.
        hGsvg.append("g").attr("class", "x axis")
            .attr("transform", "translate(0," + hGDim.h + ")")
            .call(d3.svg.axis().scale(x).orient("bottom"));

        // Create function for y-axis map.
        var y = d3.scale.linear().range([hGDim.h, 0])
                .domain([0, d3.max(fD, function(d) { return d[1]; })]);

        // Create bars for histogram to contain rectangles and freq labels.
        var bars = hGsvg.selectAll(".bar").data(fD).enter()
                .append("g").attr("class", "bar");
        
        //create the rectangles.
        bars.append("rect")
            .attr("x", function(d) { return x(d[0]); })
            .attr("y", function(d) { return y(d[1]); })
            .attr("width", x.rangeBand())
            .attr("height", function(d) { return hGDim.h - y(d[1]); })
            .attr('fill',barColor)
            .on("mouseover",mouseover)// mouseover is defined below.
            .on("mouseout",mouseout);// mouseout is defined below.
            
        bars.append("text")      // text label for the x axis
            .attr("x", 265 )
            .attr("y",  240 )
            .style("text-anchor", "middle")
            .text("Model Name");
            // text label for y axis
         
         
        bars.append("text")
		    .attr("class", "y label")
		    .attr("text-anchor", "end")
		    .attr("y", -1)
		    .attr("dy", ".75em")
		    .attr("transform", "rotate(-90)")
		    .text("Number of Model Attributes");
        //Create the frequency labels above the rectangles.
        bars.append("text").text(function(d){ return d3.format(",")(d[1])})
            .attr("x", function(d) { return x(d[0])+x.rangeBand()/2; })
            .attr("y", function(d) { return y(d[1])-5; })
            .attr("text-anchor", "middle");
        
        function mouseover(d){  // utility function to be called on mouseover.
            // filter for selected state.
            var st = fData.filter(function(s){ return s.State == d[0];})[0],
                nD = d3.keys(st.freq).map(function(s){ return {type:s, freq:st.freq[s]};});
               
            // call update functions of pie-chart and legend.    
            pC.update(nD);
            leg.update(nD);
        }
        
        function mouseout(d){    // utility function to be called on mouseout.
            // reset the pie-chart and legend.    
            pC.update(tF);
            leg.update(tF);
        }
        
        // create function to update the bars. This will be used by pie-chart.
        hG.update = function(nD, color){
            // update the domain of the y-axis map to reflect change in frequencies.
            y.domain([0, d3.max(nD, function(d) { return d[1]; })]);
            
            // Attach the new data to the bars.
            var bars = hGsvg.selectAll(".bar").data(nD);
            
            // transition the height and color of rectangles.
            bars.select("rect").transition().duration(500)
                .attr("y", function(d) {return y(d[1]); })
                .attr("height", function(d) { return hGDim.h - y(d[1]); })
                .attr("fill", color);

            // transition the frequency labels location and change value.
            bars.select("text:last-child").transition().duration(500)
                .text(function(d){ return d3.format(",")(d[1])})
                .attr("x", function(d) { return x(d[0])+x.rangeBand()/2; })
                .attr("y", function(d) {return y(d[1])-5; });            
        }        
        return hG;
    }
    
    // function to handle pieChart.
    function pieChart(pD){
        var pC ={},    pieDim ={w:250, h: 250};
        pieDim.r = Math.min(pieDim.w, pieDim.h) / 2;
                
        // create svg for pie chart.
        var piesvg = d3.select(id).append("svg")
            .attr("width", pieDim.w).attr("height", pieDim.h).append("g")
            .attr("transform", "translate("+pieDim.w/2+","+pieDim.h/2+")");
        
        // create function to draw the arcs of the pie slices.
        var arc = d3.svg.arc().outerRadius(pieDim.r - 10).innerRadius(0);

        // create a function to compute the pie slice angles.
        var pie = d3.layout.pie().sort(null).value(function(d) { return d.freq; });

        // Draw the pie slices.
        piesvg.selectAll("path").data(pie(pD)).enter().append("path").attr("d", arc)
            .each(function(d) { this._current = d; })
            .style("fill", function(d) { return segColor(d.data.type); })
            .on("mouseover",mouseover).on("mouseout",mouseout);

        // create function to update pie-chart. This will be used by histogram.
        pC.update = function(nD){
            piesvg.selectAll("path").data(pie(nD)).transition().duration(500)
                .attrTween("d", arcTween);
        }        
        // Utility function to be called on mouseover a pie slice.
        function mouseover(d){
            // call the update function of histogram with new data.            
            hG.update(fData.map(function(v){ 
                return [v.State,v.freq[d.data.type]];}),segColor(d.data.type));
        }
        //Utility function to be called on mouseout a pie slice.
        function mouseout(d){
            // call the update function of histogram with all data.
            hG.update(fData.map(function(v){
                return [v.State,v.total];}), barColor);
        }
        // Animating the pie-slice requiring a custom function which specifies
        // how the intermediate paths should be drawn.
        function arcTween(a) {
            var i = d3.interpolate(this._current, a);
            this._current = i(0);
            return function(t) { return arc(i(t));    };
        }    
        return pC;
    }
    
    // function to handle legend.
    function legend(lD){
        var leg = {};
            
        // create table for legend.
        var legend = d3.select(id).append("table").attr('class','legend');
        
        // create one row per segment.
        var tr = legend.append("tbody").selectAll("tr").data(lD).enter().append("tr");
            
        // create the first column for each segment.
        tr.append("td").append("svg").attr("width", '16').attr("height", '16').append("rect")
            .attr("width", '16').attr("height", '16')
			.attr("fill",function(d){ return segColor(d.type); });
            
        // create the second column for each segment.
        tr.append("td").text(function(d){ return d.type;});

        // create the third column for each segment.
        tr.append("td").attr("class",'legendFreq')
            .text(function(d){ return d3.format(",")(d.freq);});

        // create the fourth column for each segment.
        tr.append("td").attr("class",'legendPerc')
            .text(function(d){ return getLegend(d,lD);});

        // Utility function to be used to update the legend.
        leg.update = function(nD){
            // update the data attached to the row elements.
            var l = legend.select("tbody").selectAll("tr").data(nD);

            // update the frequencies.
            l.select(".legendFreq").text(function(d){ return d3.format(",")(d.freq);});

            // update the percentage column.
            l.select(".legendPerc").text(function(d){ return getLegend(d,nD);});        
        }
        
        function getLegend(d,aD){ // Utility function to compute percentage.
            return d3.format("%")(d.freq/d3.sum(aD.map(function(v){ return v.freq; })));
        }

        return leg;
    }
    
    // calculate total frequency by segment for all state.
    var tF = ['Tasks','Risks','Issues'].map(function(d){ 
        return {type:d, freq: d3.sum(fData.map(function(t){ return t.freq[d];}))}; 
    });    
    
    // calculate total frequency by state for all segment.
    var sF = fData.map(function(d){return [d.State,d.total];});

    var hG = histoGram(sF), // create the histogram.
        pC = pieChart(tF), // create the pie-chart.
        leg= legend(tF);  // create the legend.
}
</script>

<script>
var freqData=[
{State:'Implentation Support (OCM)',freq:{Tasks:8, Issues:5, Risks:3}}
,{State:'Policy Support (OCM)',freq:{Tasks:5, Issues:4, Risks:6}}
,{State:'Evaluation Support (OCM)',freq:{Tasks:10, Issues:5, Risks:2}}
,{State:'Learning Support',freq:{Tasks:4, Issues:1, Risks:1}}
];

dashboard('#dashboard',freqData);
</script>
		
		
		<sec:authorize
			access="hasRole('ROLE_PROJECT_MANAGER') or hasRole('AdminOfSecurityService') or hasRole('ROLE_USER')">
			<div class="grid_12">
				<div class="widget_wrap">
					<div class="widget_top">
						<span class="h_icon documents"></span>
						<h6>Project Snapshot</h6>
					</div>
					<div class="widget_content">
						<table class="display data_tbl" id="dashboard">
							<thead>
								<tr>
									<th title="Project Name">Project</th>
									<th title="Manager Name">Manager Name</th>
									<th title="Model Assigned to Project">Model</th>
									<th title="No of Tasks"># of Tasks</th>
									<th title="No of Issues"># of Issues</th>
									<th title="No of Action Items"># of Action Items</th>
									<th title="No of Risks"># of Risks</th>
									<th title="Cost Variance">Cost Variance</th>
									<th title="Schedule Variance">Schedule Variance</th>
								</tr>
							</thead>
							<tbody>
								<c:forEach var="project" items="${projects}">
									<c:if test="${project.active }">
										<tr>
										<td><a class="${linkcolor }"
											href="${pageContext.request.contextPath}/app/project/${project.id}">
												<c:out value="${project.name }" />
										</a></td>
										<td><a class="${linkcolor }">
												<c:out value="${project.managerName }" />
										</a></td>
										<td><a class="${linkcolor }"><c:out
													value="${project.program.name}" /></a></td>
										<td><a class="${linkcolor }"><c:out
														value='${fn:length(project.tasks)}' /></a></td>
										<td><a class="${linkcolor }"><c:out
													value="${fn:length(project.issues) }" /></a></td>
										<td><a class="${linkcolor }"><c:out
													value="${fn:length(project.actionItems) }" /></a></td>
										<td><a class="${linkcolor }"><c:out
													value="${fn:length(project.risks) }" /></a></td>
										<td><c:forEach var="evmMap" items="${projectEvmMap}">

												<c:if test="${evmMap.key == project.id}">
													<c:forEach var="projectevm" items="${evmMap.value}"
														varStatus="loop">
														<c:if test="${loop.last}">
															<c:if
																test="${projectevm.cvPercent >= 0 && projectevm.cvPercent <= 4}">
																<img
																	src="${pageContext.request.contextPath}/resources/images/green_ball.gif"
																	alt="Green" />
															</c:if>
															<c:if
																test="${projectevm.cvPercent > 4 && projectevm.cvPercent <= 10}">
																<img
																	src="${pageContext.request.contextPath}/resources/images/yellow_ball.gif"
																	alt="Yellow" />
															</c:if>
															<c:if
																test="${projectevm.cvPercent > 10 || projectevm.cvPercent < 0}">
																<img
																	src="${pageContext.request.contextPath}/resources/images/red_ball.gif"
																	alt="Red" />
															</c:if>
														</c:if>
													</c:forEach>
												</c:if>
											</c:forEach></td>
										<td><c:forEach var="evmMap" items="${projectEvmMap}">

												<c:if test="${evmMap.key == project.id}">
													<c:forEach var="projectevm" items="${evmMap.value}"
														varStatus="loop">
														<c:if test="${loop.last}">
															<c:if
																test="${projectevm.svPercent >= 0 && projectevm.svPercent <= 4}">
																<img
																	src="${pageContext.request.contextPath}/resources/images/green_ball.gif"
																	alt="Green" />
															</c:if>
															<c:if
																test="${projectevm.svPercent > 4 && projectevm.svPercent <= 10}">
																<img
																	src="${pageContext.request.contextPath}/resources/images/yellow_ball.gif"
																	alt="Yellow" />
															</c:if>
															<c:if
																test="${projectevm.svPercent > 10 || projectevm.svPercent < 0}">
																<img
																	src="${pageContext.request.contextPath}/resources/images/red_ball.gif"
																	alt="Red" />
															</c:if>
														</c:if>
													</c:forEach>
												</c:if>
											</c:forEach></td>
									</tr>
									</c:if>
									
								</c:forEach>
							</tbody>							
							<tfoot>
								<tr>
							        <td colspan="12"><a
										href="${pageContext.request.contextPath}/app/projects">
											<button class="btn_small btn_blue">More</button>
									</a></td>								
								</tr>
							</tfoot>	
						</table>
					</div>
				</div>
			</div>
			<span class="clear"></span>
		</sec:authorize>		
				
		<div class="grid_12">
			<div class="widget_wrap">
				<div class="widget_top">
					<span class="h_icon list_images"></span>
					<h6>Task List</h6>
				</div>
				<div class="widget_content">
					<table class="display" id="action_tbl" id="dashboard">
						<thead>
							<tr>
								<th title="Task Names">Task</th>
								 <th>Model Name</th>
                            	<th>Project Name</th>								
								<th title="Task Start Date">Date Created</th>
								<th title="Task Status">Status</th>
								<th title="Task Due Date">Date Due</th>
								
							</tr>
						</thead>
						<tbody>
							<c:forEach var="task" items="${tasks}" end='4'>
								<tr>
									<td><a href="${pageContext.request.contextPath}/app/task/${task.id}"><c:out
												value="${task.name }" /></a></td>
									<td>${task.program.name}</td>
                                 	<td>${task.project.name}</td>
									
									<td><fmt:formatDate type="both" dateStyle="short"
											timeStyle="short" value="${task.dateCreated }" /></td>
									<td><span
										class="badge_style b_${fn:toLowerCase(task.status)}">${task.status}</span></td>
									<td><fmt:formatDate type="both" dateStyle="short"
											timeStyle="short" value="${task.dueDate }" /></td>									
								</tr>
							</c:forEach>
						</tbody>
						<tfoot>
							<tr>
						        <td colspan="12"><a
									href="${pageContext.request.contextPath}/app/tasks">
										<button class="btn_small btn_blue">More</button>
								</a></td>								
							</tr>
						</tfoot>
					</table>
				</div>
			</div>
		</div>		
	</div>
</div>

