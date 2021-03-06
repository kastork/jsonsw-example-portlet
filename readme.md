# JSON API Examples for Liferay 6.1

This little project demonstrates how the documentation and available info on the web says the JSON Web Service APIs created by Liferay Service Builder should work.

WARNING: This is how it is *supposed* to work, as best I can tell.  As you will see, it doesn't really work.

My hope is that this will inspire knowledgeable people (Listening Liferay?) to fork this repository and turn it into an actual working example.  I imagine some of this will be fixing my misperceptions of how it is supposed to be, and some will be fixing documentation, and maybe even fixing Service Builder.

The use-cases I have here now are just the ones I'm looking to use.  There are others, and the documentation in the [Liferay Developer Guide, Chapter 9](https://github.com/liferay/liferay-docs/blob/master/devGuide/en/chapters/09-apis.markdown) is pretty good -- except where it isn't.

I'll happily incorporate any pull request that corrects something or adds a functioning example or use-case. (as long as it has to do with Service Builder generated Web Services.)

The project is a standard Liferay SDK project generated by Liferay Developer Studio.  My environment is Liferay 6.1 EE (6110), but it should (er) work on 6.1 CE too.  I'm running Liferay in Tomcat 7.

The basic steps are:

1. Create a service builder entity with remote service attribute set to true and generate the service.
2. Configure your portlet with a servlet descriptor that wires in your api.  This occurs in web.xml.
3. Make sure the service builder javascript is included in your portlet, this occurs in the javascript elements of the portlet element of your liferay-portlet.xml file.
4. Build and deploy the portlet
5. Place the portlet on a page

The repo _should_ cover the first 3 steps unless there's a mistake somewhere.

Some people seem to think you need to unpack your war file, extract the service jar and put it in Tomcat's globally privileged lib/ext.  I havne't been able to confirm this, and I don't see any difference in the behavior when I try.  So this topic is another one where I'd love to have a good explanation in the documentation.

Dev Guide Chapter 9 tells you how to configure your web.xml file for the portlet.  However, it appears that there are some missing parts.  When I follow the instructions there, I get 404 errors.  The correction appears to be to add another servlet (thanks Oleg for figuring this out).  In addition to the elements described in chapter 9, you also appear to need these:

    <servlet>
      <servlet-name>JSON Servlet</servlet-name>
      <servlet-class>com.liferay.portal.kernel.servlet.PortalClassLoaderServlet</servlet-class>
      <init-param>
        <param-name>servlet-class</param-name>
        <param-value>com.liferay.portal.servlet.JSONServlet</param-value>
      </init-param>
      <load-on-startup>0</load-on-startup>
    </servlet>
    
    <servlet-mapping>
      <servlet-name>JSON Servlet</servlet-name>
      <url-pattern>/api/json/*</url-pattern>
    </servlet-mapping>
    
    <servlet-mapping>
      <servlet-name>JSON Servlet</servlet-name>
      <url-pattern>/api/secure/json/*</url-pattern>
    </servlet-mapping>


Now given the portlet in this project, theoretically you should be able to do all of the following things.

## Make ajax calls directly to the service from inside your portlet.

Like this,

    Liferay.Service.jsonswexample.Foo.print(
        data = {msg:'Hey'},
        successCallback = function(m) {
          result2.text('Success: '+ m);
        },
        exceptionCallback = function(m) {
          result2.text('Exception: '+ m);
        }
    );

Which works.

or this,

    Liferay.Service(
        service = 'jsonsw-example-portlet/Foo/print',
        data = {msg:'Foo'},
        successCallback = function(m) {
          result1.text('Success: '+ m);
        },
        exceptionCallback = function(m) {
          result1.text('Exception: '+ m);
        }
    );

Which doesn't work.  Note that this second approach is the one that comes up as a JavaScript example when you load the JSON API page for the portlet after it is deployed.  So either that example template is incorrect in Liferay, or things are not working as intended.
  
## Make authenticated calls from elsewhere.

Like this,

    curl http://localhost:8080/jsonsw-example-portlet/api/secure/jsonws/foo/print \
          -utest@liferay.com:test \
          -d msg='I want my Foo!'

    # reply
    # "{\"Message\":\"I want my Foo!\"}"%

    
which seems to work.  Unauthenticated calls should not work

    curl http://localhost:8080/jsonsw-example-portlet/api/secure/jsonws/foo/print \
          -d msg='I want my Foo!'

    # reply
    # "{\"Message\":\"I want my Foo!\"}"%


or
  
    curl http://localhost:8080/jsonsw-example-portlet/api/jsonws/foo/print \
          -d msg='I want my Foo!'

    # reply
    # "{\"Message\":\"I want my Foo!\"}"%

but they do.  So this appears to be a bug.


## Visit your portal's API page

    http://localhost:8080/jsonsw-example-portlet/api/jsonws
    
or

    http://localhost:8080/jsonsw-example-portlet/api/secure/jsonws
    
On my system the second one just redirects to the first.

Clicking on the 'print' link takes you to a test page where you can invoke the method. Strangely, though, the page you go to is filled with the standard API's in the left-hand navigation column, not your custom one.  

Using the form to invoke the method with a string in the input box results in an exception as a reply, and an Array Out of Bounds Exception in Catalina.out.


So it looks like the URL is backwards when that page tries to execute the form.   It produces

    http://localhost:8080/api/jsonws/jsonsw-example-portlet/foo/print;<querystring>
    
when it should be (according to the Dev Guide, Chapter 9) producing

    http://localhost:8080/jsonsw-example-portlet/api/jsonws/foo/print;<querystring>

The page also provides links to examples for JavaScript and curl.

The JavaScript example does not work -- you once again get the ArrayIndexOutOfBounds Exception.

    Liferay.Service(
        service = 'jsonsw-example-portlet/Foo/print',
        data = {msg:'Foo'},
        successCallback = function(m) {
          result1.text('Success: '+ m);
        },
        exceptionCallback = function(m) {
          result1.text('Exception: '+ m);
        }
    );


Invoking the example curl command doesn't work either.  But if you reverese the URL as described above it does:

Fail

    curl http://localhost:8080/api/secure/jsonws/jsonsw-example-portlet/foo/print \
      -u test@liferay.com:test \
      -d formDate=1336338170038 \
      -d msg='hey there'

    # Reply
    # {"exception":"1"}

Succeed
    
    curl http://localhost:8080/jsonsw-example-portlet/api/secure/jsonws/foo/print \
          -utest@liferay.com:test \
          -d msg='I want my Foo!'

    # reply
    # "{\"Message\":\"I want my Foo!\"}"%
