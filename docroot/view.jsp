<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@ taglib uri="http://java.sun.com/jstl/core_rt" prefix="c"%>
<%@ taglib uri="http://liferay.com/tld/portlet" prefix="liferay-portlet"%>
<%@ taglib uri="http://liferay.com/tld/security"
	prefix="liferay-security"%>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme"%>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui"%>
<%@ taglib uri="http://liferay.com/tld/util" prefix="liferay-util"%>
<%@ taglib uri="http://alloy.liferay.com/tld/aui" prefix="aui"%>

<%@ page import="java.util.List"%>
<%@ page import="java.text.SimpleDateFormat"%>

<%@ page import="javax.portlet.PortletPreferences"%>

<%@ page import="com.liferay.portal.kernel.dao.search.ResultRow"%>
<%@ page import="com.liferay.portal.kernel.util.GetterUtil"%>
<%@ page import="com.liferay.portal.kernel.util.HtmlUtil"%>
<%@ page import="com.liferay.portal.kernel.util.ParamUtil"%>
<%@ page import="com.liferay.portal.kernel.util.WebKeys"%>
<%@ page import="com.liferay.portal.model.Group"%>
<%@ page import="com.liferay.portal.security.permission.ActionKeys"%>
<%@ page import="com.liferay.portal.util.PortalUtil"%>


<liferay-theme:defineObjects />

<portlet:defineObjects />


This is the
<b>jsonsw-example</b>
portlet.

<h4>Call Liferay.Service (GET) with string path</h4>
<p>
	This follows the example given on the JSONWS API page, but it doesn't
	work. For example, go to <a
		href="http://localhost:8080/jsonsw-example-portlet/api/jsonws">
		the API page</a>, try a msg on the print function, and then have a look at
	the link to the JavaScript example.
</p>

<p>The javascript it tells you to use looks like this:</p>
<code> Liferay.Service( '/jsonsw-example-portlet/foo/print',
	data: { formDate: 1340144591093, msg: 'kazam' }, function(obj) {
	console.log(obj); } );</code>
<p>Which isn't even syntactically correct.</p>
<p>the result:</p>
<div id='result1'>Static text.</div>

<h4>Call Liferay.Service.jsonsw_example.Foo.print (PUT) with data =
	{msg:'Hey'}</h4>
<div id='result2'>Static text.</div>

<h4>Call Liferay.Service.jsonsw_example.Foo.print (PUT) with data =
	'Ho'</h4>
<div id='result3'>Static text.</div>

<h4>Call a portal service.</h4>
<div id='result4'>Static text.</div>

<script type="text/javascript">
	AUI().ready('aui-node', function(A) {

		var result1 = A.one('#result1');
		var result2 = A.one('#result2');
		var result3 = A.one('#result3');
		var result4 = A.one('#result4');

		result1.text("Alloy inserted text 1.");
		result2.text("Alloy inserted text 2.");
		result3.text("Alloy inserted text 3.");
		result4.text("Alloy inserted text 4.");


		// this is how the example page in Liferay tells you to call the method...
		
		Liferay.Service('/jsonsw-example-portlet/foo/print', data = {
			formDate : 1340144591093,
			msg : 'kazam'
		}, function(obj) {
			console.log(obj);
		});

//		Liferay.Service(service = 'jsonsw-example-portlet/foo/print', data = {
//			msg : "Foo"
//		}, successCallback = function(m) {
//			result1.text('Success: ' + m);
//		}, exceptionCallback = function(m) {
//			result1.text('Exception: ' + m);
//		}).start();

		Liferay.Service.jsonswexample.Foo.print(
			data = {msg : "Hey" },
			successCallback = function(m) {
				result2.text('Success: ' + m);
			},
			exceptionCallback = function(m) {
				result2.text('Exception: ' + m);
			}
		);

		Liferay.Service.jsonswexample.Foo.print(
			{ msg : "Ho"},
			function(m) {
				result3.text('Success: ' + m);
			},
			function(m) {
				result3.text('Exception: ' + m);
			}
		);

		var theUser = Liferay.ThemeDisplay.getUserId();
		Liferay.Service.Portal.User.getUserById(
			{userId : theUser},
			successCallback = function(m) {
				result4.text('Success: ' + m.firstName);
			},
			exceptionCallback = function(m) {
				result4.text('Exception: ' + m);
			}
		);
	});
</script>