CFFormProtect :: Revamp
=======================
##### A modern conversion of the original CFFormProtect into full CFScript & then some. . .

## What is CFFormProtect?

CFFormProtect is a fully accessible, invisible to users form protection system to stop spam bots, and even human spammers. CFFormProtect works like some email spam protection systems, in that it uses a series of tests to find out if a form submission is from a spammer or not. Each test is given an amount of points, and each test that is failed accumulates points. Once a form submission passes the threshold of 'spamminess', the message is flagged as spam and is not posted. The points assigned to each test and the failure limit are easily configurable by you.

##### CFFormProtect uses these tests to stop spam:

- Mouse movement: Did the user move their mouse? If not, it might be a spammer. This test is not very strong because lots of people, including the blind, don't use a mouse when filling out forms. Thus I give this test a low point level by default.

- Keyboard used: Did the user type on their keyboard? This is a fairly strong test, because almost everybody will need to use their keyboard when filling out a form (unless they have one of those form filler browser plugins)

- Timed form submission: How long did it take to fill out the form? A spam bot will usually fail this test because it's automated. Also, sometimes spam bot software will have cached form contents, so the form will look like it took days to fill out. This test checks for an upper and lower time limit, and these values can be easily changed to suit your needs.

- Hidden form field: Most spam bots just fill out all form fields and submit them. This test uses a form field that is hidden by CSS, and tests to make sure that field is empty. If a blind person's screen reader sees this hidden field, there is a field label telling them not to fill it out.

- Too many URLs: This function was added by Dave Shuck. Many spammers like to submit a ton of URLs in their posts, so you can configure CFFormProtect to count how many URLs are in the form contents, and raise a flag if the number is above a configured limit.

- Spam keyword list: This function was added by Mary Jo Sminkey. This test allows you to configure a list of spammy words and phrases that will be used to weed out spam. For example, if you use the phrase 'free music', a message containing that phrase might get tagged as spam while just the word 'music' will pass the test. There is a default list of words/phrases included in the `config.json` file.

- Akismet: Most of the above tests can be easily bypassed if a spammer hires cheap labor to manually fill out forms. However, Akismet attempts to stop that as well. Akismet is a service provided by the folks that run WordPress (http://akismet.com/). The free service (for personal use) takes form contents as input, and returns a yes/no value to tell you if the submission is spam. This test is disabled by default because you have to obtain an API key. This is easy to do, and CFFormProtect is easy to configure if you want to use Akismet.

- LinkSleeve: LinkSleeve is similar to Akismet, but it is free for everybody including commercial use. No API key is required. I don't think LinkSleeve is as popular as Akisment (yet), but in my testing it worked pretty well. Unlike Akismet, I turned this test on by default because it is free and you don't have to do anything special to configure it for your site.

- Project Honey Pot: Like Akismet, Proj. Honey Pot can stop manual spammers as well. Project Honey Pot is a free web service that identifies spammers by their IP address. They maintain a huge database of known spammer IP addresses. If you chose to use this service, CFFP will verify the IP address of your site's visitors before it will allow them to submit data through your forms.

The beauty of CFFormProtect is that any of the above tests can fail, and the spam bot can still be stopped. And all of this is possible without making your users type in hard to read text, and your forms are accessible. And you don't have to maintain a black list or use an approval queue.

## Getting Started:

1. Copy the cfformprotect folder into your web root.
2. On your form page, add this line of code: `<cfset cffp = createObject("component", "cfformprotect.CFFPVerify").init()>`.
3. Put `<cfinclude template="/cfformprotect/cffp.cfm">` somewhere between your form tags. You could also include this instead: `<cfoutput>#cffp.renderCFFP()#</cfoutput>`
4. In your processing page include the following code:
	```
	cffp = createObject("component", "cfformprotect.CFFPVerify").init();
	// Now we can test the form submission.
	if (cffp.testSubmission(form)) {
    		// The submission has passed the form test. Place processing here.
	} else {
    		// The test failed. Take appropriate failure action here.
	}
	```
5. Setup your email settings and Akismet in `config.json`, if you want to use those features (if you leave the email settings blank, you won't receive an email when spammer tries to attack your forms).

## Customization:

- You can change the values in `config.json` if you want to tweak how CFFormProtect operates. Descriptions of the values are below.
- If you want to use Project Honey Pot, sign up for an API key at http://www.projecthoneypot.org/, and then configure the Project Honey Pot directives according to the directions below.
- You can specify a different config file than the default (`config.json`) in your init code. Check out the init function in `CFFPVerify.cfc` to see how to do this.

### Config File Settings (config.json):

<TABLE WIDTH=949 BORDER=1 BORDERCOLOR="#000000" CELLPADDING=5 CELLSPACING=1 STYLE="page-break-before: always">
	<COL WIDTH=154>
	<COL WIDTH=128>
	<COL WIDTH=73>
	<COL WIDTH=193>
	<COL WIDTH=344>
	<TR>
		<TD WIDTH=154 BGCOLOR="#e6e6e6">
			<P ALIGN=CENTER><FONT COLOR="#000000"><B>Config
			</B></FONT><FONT COLOR="#000000"><B>Name</B></FONT></P>
		</TD>
		<TD WIDTH=128 BGCOLOR="#e6e6e6">
			<P ALIGN=CENTER><B>Default</B></P>
		</TD>
		<TD WIDTH=73 BGCOLOR="#e6e6e6">
			<P ALIGN=CENTER><B>Type</B></P>
		</TD>
		<TD WIDTH=193 BGCOLOR="#e6e6e6">
			<P ALIGN=CENTER><B>Accepted Values</B></P>
		</TD>
		<TD WIDTH=344 BGCOLOR="#e6e6e6">
			<P ALIGN=CENTER><B>Description</B></P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>mouseMovement</P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P STYLE="margin-bottom: 0in">Enable/disable
			the mouse test.</P>
			<P>This test makes sure the user moved their
			mouse.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>usedKeyboard</P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P STYLE="margin-bottom: 0in">Enable/disable
			the keyboard test.</P>
			<P>This test makes sure the user
			used their keyboard.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>timedFormSubmission</P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P STYLE="margin-bottom: 0in">Enable/disable
			the timed form test.</P>
			<P>This test check how long the form
			entry and submission took.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>hiddenFormField</P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P STYLE="margin-bottom: 0in">Enable/disable
			hidden form field test.</P>
			<P>This test makes sure a CSS hidden
			form field is empty.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>akismet</P>
		</TD>
		<TD WIDTH=128>
			<P>0</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P STYLE="margin-bottom: 0in">Enable/disable
			the akismet test.</P>
			<P>Uses the public Akismet service to test if
			form contents are spam. This is off by default, because you have
			to provide the details in the second section for Akistmet to
			work. Akistmet is not a free service and require the application
			to exchange data with the outside world.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>LinkSleeve</P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P STYLE="margin-bottom: 0in">Enable/disable
			the LinkSleeve test.</P>
			<P>Uses the public <a href="http://www.linksleeve.org/">LinkSleeve</a> service to test if
			form contents are spam.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>tooManyUrls</P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P STYLE="margin-bottom: 0in">Enable/disable
			the tooManyUrls test.</P>
			<P>This test will add up the number of URLs that
			are found in all of the submitted form fields, and mark the
			submission as spam if the total exceeds the limit configured by
			the tooManyUrlsMaxUrls variable in the ini file. 
			</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>teststrings</P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P STYLE="margin-bottom: 0in">Enable/disable
			the teststrings test</P>
			<P>This test will compare the words in the form
			submission to a list of configurable &quot;spammy&quot; words,
			and mark the submission as spam if one of these words is found.
			The list can be edited by editing the spamstrings variable in the
			ini file. 
			</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>projectHoneyPot</P>
		</TD>
		<TD WIDTH=128>
			<P>0</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P STYLE="margin-bottom: 0in">Enable/disable
			the Project Honey Pot test.</P>
			<P>Project Honey Pot is a free web service that
				will check the IP address of your site's visitor.
				they maintain a huge database of known Spammer
				IP addresses, and when a user submits your form, 
				this test will check their IP address. This is off 
				by default, because you have to provide the API key 
				in the second section.
			</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154 BGCOLOR="#e6e6e6">
			<P><B>Individual Test Config</B></P>
		</TD>
		<TD WIDTH=128 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
		<TD WIDTH=73 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
		<TD WIDTH=193 BGCOLOR="#e6e6e6">
			<P STYLE="margin-left: 0.25in; text-indent: -0.2in">
			<BR>
			</P>
		</TD>
		<TD WIDTH=344 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>timedFormMinSeconds</P>
		</TD>
		<TD WIDTH=128>
			<P>5</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>The minimum seconds allowed for a
			user to fill out the form.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>timedFormMaxSeconds</P>
		</TD>
		<TD WIDTH=128>
			<P>3600</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>The
			maximum seconds allowed for a user to fill out the form.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>encryptionKey</P>
		</TD>
		<TD WIDTH=128>
			<P>JacobMunsOn</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>longest is better</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Used in
			the timedForm test, to encrypt the time so it can be stored in a
			hidden form field (to help fool the spammers).</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>akismetAPIKey</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid Akismet key</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>This is the api key that you
			received from Akismet.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>akismetBlogURL</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid URL</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>The
			URL for your site here, it's a required value for the Akismet
			service.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>akismetFormNameField</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid field name</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>The
			name of your &quot;Name&quot; form field.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>akismetFormEmailField</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid field name</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>The
			name of your &quot;Email address&quot; form field (optional).</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>akismetFormURLField</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid field name</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>The
			name of your &quot;URL&quot; form field (optional).</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>akismetFormBodyField</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid field name</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>The
			name of your &quot;Comment&quot; form field.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>tooManyUrlsMaxUrls</P>
		</TD>
		<TD WIDTH=128>
			<P>6</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>The
			maximum amount of URLs that can be passed in the form contents.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>spamstrings</P>
		</TD>
		<TD WIDTH=128>
			<P ALIGN=JUSTIFY><FONT FACE="Courier New, monospace"><FONT SIZE=1 STYLE="font-size: 8pt">free
			music, download music, music downloads, viagra, phentermine,
			viagra, tramadol, ultram, prescription soma, cheap soma, cialis,
			levitra, weight loss, buy cheap</FONT></FONT></P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>coma separated list</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>A list
			of strings that form contents will be compared to.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>projectHoneyPotAPIKey</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid Project Honey Pot key</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>This is the api key that you
			received from Project Honey Pot at <a href="http://www.projecthoneypot.org/">
			http://www.projecthoneypot.org/</a>.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154 BGCOLOR="#e6e6e6">
			<P><EM><B>Failure Limit</B></EM></P>
		</TD>
		<TD WIDTH=128 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
		<TD WIDTH=73 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
		<TD WIDTH=193 BGCOLOR="#e6e6e6">
			<P STYLE="margin-left: 0.05in"><BR>
			</P>
		</TD>
		<TD WIDTH=344 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>mouseMovementPoints</P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Points given for the mouse movement test.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>usedKeyboardPoints</P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Points given for the used keyboard test.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>timedFormPoints</P>
		</TD>
		<TD WIDTH=128>
			<P>2</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Points given for the timed form test.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>hiddenFieldPoints</P>
		</TD>
		<TD WIDTH=128>
			<P>3</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Points given for the hidden field test.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>akismetPoints</P>
		</TD>
		<TD WIDTH=128>
			<P>3</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Points given for the Akismet test (if used).</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>linkSleevePoints</P>
		</TD>
		<TD WIDTH=128>
			<P>3</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Points given for the LinkSleeve test.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>tooManyUrlsPoints</P>
		</TD>
		<TD WIDTH=128>
			<P>3</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Points given for the URL count test.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>spamStringPoints</P>
		</TD>
		<TD WIDTH=128>
			<P>2</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Points given for the spam string test.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>projectHoneyPotPoints</P>
		</TD>
		<TD WIDTH=128>
			<P>3</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Points given for the Project Honey Pot test (if used).</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>failureLimit</P>
		</TD>
		<TD WIDTH=128>
			<P>3</P>
		</TD>
		<TD WIDTH=73>
			<P>numeric</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>whole number only</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>The
			total amount of points you will allow before flagging a message
			as spam. Each test that fails will assign &quot;failure points&quot;
			to the form submission. If the total point exceeds the
			failureLimit, the message will not be sent.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154 BGCOLOR="#e6e6e6">
			<P><B>Email Settings</B></P>
		</TD>
		<TD WIDTH=128 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
		<TD WIDTH=73 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
		<TD WIDTH=193 BGCOLOR="#e6e6e6">
			<P STYLE="margin-left: 0.25in; text-indent: -0.2in">
			<BR>
			</P>
		</TD>
		<TD WIDTH=344 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>emailFailedTests</P>
		</TD>
		<TD WIDTH=128>
			<P>0</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Enable/disable
			emailFailedTests to receive email
			reports in case of spam detection.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>emailServer</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid address</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Email sever address.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>emailUserName</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid username</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Email account user name.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>emailPassword</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid password</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Email account password.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>emailFromAddress</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid email address</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P><FONT COLOR="#000000">Email
			address used for the </FONT>&quot;<FONT COLOR="#000000">from</FONT>&quot;<FONT COLOR="#000000">
			field.</FONT></P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>emailToAddress</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid email address</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P><FONT COLOR="#000000">Email
			address used for the </FONT>&quot;<FONT COLOR="#000000">to</FONT>&quot;<FONT COLOR="#000000">
			field.</FONT></P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P>emailSubject</P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>valid email subject</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Email subject.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154 BGCOLOR="#e6e6e6">
			<P><EM><B>Logging</B></EM></P>
		</TD>
		<TD WIDTH=128 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
		<TD WIDTH=73 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
		<TD WIDTH=193 BGCOLOR="#e6e6e6">
			<P STYLE="margin-left: 0.25in; text-indent: -0.2in">
			<BR>
			</P>
		</TD>
		<TD WIDTH=344 BGCOLOR="#e6e6e6">
			<P><BR>
			</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P><EM>logFailedTests</EM></P>
		</TD>
		<TD WIDTH=128>
			<P>1</P>
		</TD>
		<TD WIDTH=73>
			<P>boolean</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>1, 0</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>Enable/disable
			logging of spam submissions.</P>
		</TD>
	</TR>
	<TR>
		<TD WIDTH=154>
			<P><EM>logFile</EM></P>
		</TD>
		<TD WIDTH=128>
			<P>[null]</P>
		</TD>
		<TD WIDTH=73>
			<P>string</P>
		</TD>
		<TD WIDTH=193>
			<UL>
				<P>Valid file name</P>
			</UL>
		</TD>
		<TD WIDTH=344>
			<P>To specify
			a different log file name.</P>
		</TD>
	</TR>
</TABLE>

## TODOs / Notes:

There's no true direction with this conversion except to bring some of the code up to speed in script a bit and possibly make some of the functionality simpler.

There are some minor changes that will be documented as time allows. For the most part, general code based on the original version of CFFormProtect is more or less compatible. In this variation though, `cffp.ini.cfm` is now `config.json`.

## Contributors:

> CFFormProtect was created by Jake Munson with the CFC implementation by Dave Shuck. Other contributors include Mary Jo Sminkey, Ben Elliott & Bas van der Graaf. For more info & details on the original project, see: http://cfformprotect.riaforge.org/. A PHP port of CFFormProtect was created by Dan McCarthy which can be found here: https://github.com/mccarthy/phpFormProtect.

> Conversion to CFScript and various other modifications found in this repo by Tony Junkes (@cfchef).
