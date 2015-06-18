component displayname="CF Form Protect Verify"
	output="false"
{
	public CFFPVerify function init(string configPath = expandPath("/cfformprotect"), string configFile = "config.json") {
		setConfig(arguments.configPath, arguments.configFile);
		this.configPath = arguments.configPath;
		this.configFile = arguments.configFile;
		
		return this;
	}

	public struct function getConfig() {
		return variables.config;
	}

	public void function setConfig(required string configPath, required string configFile) {
		variables.config = deserializeJson(fileRead(arguments.configPath & "/" & arguments.configFile));
	}

	public boolean function testSubmission(required struct fields) {
		var pass = true;
		// each time a test fails, totalPoints is incremented by the user specified amount
		var totalPoints = 0;
		// setup a variable to store a list of tests that failed, for informational purposes
		var testResults = {};

		// Test for mouse movement
		try {
			if (getConfig().mouseMovement) {
				testResults.MouseMovement = testMouseMovement(arguments.fields);
				if (!testResults.MouseMovement) {
					// The mouse did not move
					totalPoints = totalPoints + getConfig().mouseMovementPoints;
				}
			}
		}
		catch(any e) { /* an error occurred on this test, but we will move one */ }

		// Test for used keyboard
		try {
			if (getConfig().usedKeyboard) {
				testResults.usedKeyboard = testUsedKeyboard(arguments.fields);
				if (!testResults.usedKeyboard) {
					// No keyboard activity was detected
					totalPoints = totalPoints + getConfig().usedKeyboardPoints;
				}
			}
		}
		catch(any e) { /* an error occurred on this test, but we will move one */ }

		// Test for time taken on the fields
		try {
			if (getConfig().timedFormSubmission) {
				testResults.timedFormSubmission = testTimedFormSubmission(arguments.fields);
				if (!testResults.timedFormSubmission.pass) {
					// Time was either too short, too long, or the fields field was altered
					totalPoints = totalPoints + getConfig().timedFormPoints;
				}
			}
		}
		catch(any e) { /* an error occurred on this test, but we will move one */ }

		// Test for empty hidden fields field
		try {
			if (getConfig().hiddenFormField) {
				testResults.hiddenFormField = testHiddenFormField(arguments.fields);
				if (!testResults.hiddenFormField) {
					// The submitter filled in a fields field hidden via CSS
					totalPoints = totalPoints + getConfig().hiddenFieldPoints;
				}
			}
		}
		catch(any e) { /* an error occurred on this test, but we will move one */ }

		// Test Akismet
		try {
			if (getConfig().akismet) {
				testResults.akismet = testAkismet(arguments.fields);
				if (!testResults.akismet.pass) {
					// Akismet says this fields submission is spam
					totalPoints = totalPoints + getConfig().akismetPoints;
				}
			}
		}
		catch(any e) { /* an error occurred on this test, but we will move one */ }

		// Test LinkSleeve
		try {
			if (getConfig().linkSleeve) {
				testResults.linkSleeve = testLinkSleeve(arguments.fields);
				if (!testResults.linkSleeve.pass) {
					// LinkSleeve says this fields submission is spam
					totalPoints = totalPoints + getConfig().linkSleevePoints;
				}
			}
		}
		catch(any e) { /* an error occurred on this test, but we will move one */ }

		// Test tooManyUrls
		try {
			if (getConfig().tooManyUrls) {
				testResults.tooManyUrls = testTooManyUrls(arguments.fields);
				if (!testResults.tooManyUrls) {
					// Submitter has included too many urls in at least one fields field
					totalPoints = totalPoints + getConfig().tooManyUrlsPoints;
				}
			}
		}
		catch(any e) { /* an error occurred on this test, but we will move one */ }

		// Test spamStrings
		try {
			if (getConfig().teststrings) {
				testResults.SpamStrings = testSpamStrings(arguments.fields);
				if (!testResults.SpamStrings) {
					// Submitter has included a spam string in at least one fields field
					totalPoints = totalPoints + getConfig().spamStringPoints;
				}
			}
		}
		catch(any e) { /* an error occurred on this test, but we will move one */ }

		// Test Project Honey Pot
		try {
			if (getConfig().projectHoneyPot) {
				testResults.ProjHoneyPot = testProjHoneyPot(arguments.fields);
				if (!testResults.ProjHoneyPot) {
					// Submitter has included a spam string in at least one fields field
					totalPoints = totalPoints + getConfig().projectHoneyPotPoints;
				}
			}
		}
		catch(any e) { /* an error occurred on this test, but we will move one */ }

		// Compare the total points from the spam tests to the user specified failure limit
		if (totalPoints >= getConfig().failureLimit) {
			pass = false;
			try	{
				if (getConfig().emailFailedTests) {
					emailReport(testResults = testResults, fields = fields, totalPoints = totalPoints);
				}
			}
			catch(any e) { /* an error has occurred emailing the report, but we will move on */ }
			try	{
				if (getConfig().logFailedTests)	{
					logFailure(testResults = testResults, fields = fields, totalPoints = totalPoints, logFile = getConfig().logFile);
				}
			}
			catch(any e) { /* an error has occurred logging the spam, but we will move on */ }
		}

		return pass;
	}

	/**
	* @hint "I make sure this fields field exists, and it has a numeric value in it (the distance the mouse traveled)"
	*/
	public boolean function testMouseMovement(required struct fields) {
		return (
			structKeyExists(arguments.fields, "formfield1234567891") && isNumeric(arguments.fields.formfield1234567891)
			? true : false
		);
	}

	/**
	* @hint "I make sure this fields field exists, and it has a numeric value in it (the amount of keys pressed by the user)"
	*/
	public boolean function testUsedKeyboard(required struct fields) {
		return (
			structKeyExists(arguments.fields, "formfield1234567892") && isNumeric(arguments.fields.formfield1234567892)
			? true : false
		);
	}

	/**
	* @hint "I check the time elapsed from the begining of the fields load to the fields submission"
	*/
	public struct function testTimedFormSubmission(required struct fields) {
		var result = {pass: true, formTimeElapsed: ""};
		// Decrypt the initial fields load time
		if (structKeyExists(arguments.fields, "formfield1234567893") && listLen(arguments.fields.formfield1234567893) == 2)	{
			var formDate = listFirst(arguments.fields.formfield1234567893) - 19740206;
			if (len(formDate) == 7) { formDate = "0" & formDate; }
			var formTime = listLast(arguments.fields.formfield1234567893) - 19740206;
			if (len(formTime))	{
				// in original fields, formTime was always padded with a "0" below. In my testing, this
				// caused the timed test to fail consistantly after 9:59am due to the fact it was
				// shifting the time digits one place to the right with 2 digit hours.
				// To make this work I added numberFormat()
				formTime = numberFormat(formTime, '000000');
			}
			var formDateTime = createDateTime(left(formDate, 4), mid(formDate, 5, 2), right(formDate, 2), left(formTime, 2), mid(formTime, 3, 2), right(formTime, 2));
			// Calculate how many seconds elapsed
			result.formTimeElapsed = dateDiff("s", formDateTime, now());
			if (result.formTimeElapsed < getConfig().timedFormMinSeconds || result.formTimeElapsed > getConfig().timedFormMaxSeconds)	{
				result.pass = false;
			}
		} else {
			result.pass = false;
		}

		return result;
	}

	/**
	* @hint "I make sure the CSS hidden fields field doesn't have a value"
	*/
	public boolean function testHiddenFormField(required struct fields) {
		return (
			structKeyExists(arguments.fields, "formfield1234567894") && !len(arguments.fields.formfield1234567894)
			? true : false
		);
	}

	/**
	* @hint "I send fields contents to the public Akismet service to validate that it's not 'spammy'"
	*/
	public struct function testAkismet(required struct fields) {
		var result = {pass: true, validKey: false};
		var logFile = getConfig().logFile;
		try {
			// validate the Akismet API key
			var akismetVerify = new http(method = "post", timeout = 10, url = "http://rest.akismet.com/1.1/verify-key");
			akismetVerify.addParam(name = "key", type = "formfield", value = getConfig().akismetAPIKey);
			akismetVerify.addParam(name = "blog", type = "formfield", value = getConfig().akismetBlogURL);
			if (trim(akismetVerify.send().getPrefix().fileContent) == "valid") {
				result.validKey = true;
			}
		}
		catch(any e) {
			writeLog(file = logFile, text = "Akismet API key validation failed.");
		}
		if (result.validKey) {
			try {
				// send fields contents to Akismet API
				var akismetCommentCheck = new http(method = "post", timeout = 10, url = "http://#getConfig().akismetAPIKey#.rest.akismet.com/1.1/comment-check");
				akismetCommentCheck.addParam(name = "key", type = "formfield", value = getConfig().akismetAPIKey);
				akismetCommentCheck.addParam(name = "blog", type = "formfield", value = getConfig().akismetBlogURL);
				akismetCommentCheck.addParam(name = "user_ip", type = "formfield", value = cgi.remote_addr);
				akismetCommentCheck.addParam(name = "user_agent", type = "formfield", value = "CFFormProtect/1.0 | Akismet/1.11");
				akismetCommentCheck.addParam(name = "referrer", type = "formfield", value = cgi.http_referer);
				akismetCommentCheck.addParam(name = "comment_author", type = "formfield", value = arguments.fields[getConfig().akismetFormNameField]);
				if (len(getConfig().akismetFormEmailField)) {
					akismetCommentCheck.addParam(name = "comment_author_email", type = "formfield", value = arguments.fields[getConfig().akismetFormEmailField]);	
				}
				if (len(getConfig().akismetFormURLField)) {
					akismetCommentCheck.addParam(name = "comment_author_url", type = "formfield", value = arguments.fields[getConfig().akismetFormNameUrlField]);	
				}
				akismetCommentCheck.addParam(name = "comment_content", type = "formfield", value = arguments.fields[getConfig().akismetFormBodyField]);
				// check Akismet results
				if (trim(akismetCommentCheck.send().getPrefix().fileContent)) {
					// Akismet says this fields submission is spam
					result.pass = false;
				}
			}
			catch(any e) {
				akismetHTTPRequest = false;
				writeLog(file = logFile, text = "Akismet request failed");
			}
		} else {
			writeLog(file = logFile, text = "Akismet API Key is invalid");
		}

		return result;
	}

	/**
	* @hint "I send fields contents to the public LinkSleeve service to validate that it's not 'spammy'"
	*/
	public struct function testLinkSleeve(required struct fields) {
		var result = {pass: true};
		var linkSleeveHTTPRequest = true;
		var linkSleeveResult = 0;
		var formData = "";
		// lump all fields data together to send to the LinkSleeve service
		for (var formField in listToArray(arguments.fields.fieldNames)) {
			formData = formData & " " & arguments.fields[formField];
		}
		savecontent variable="linkSleeveXML" {
			writeOutput('
			<?xml version="1.0" encoding="UTF-8"?>
			<methodCall>
				<methodName>slv</methodName>
				<params>
					<param>
						<value><string>#formData#</string></value>
					</param>
				</params>
			</methodCall>
			');
		};
		try {
			// send fields contents to LinkSleeve API
			var linkSleeveResponse = new http(method = "post", timeout = 10, url = "http://www.linksleeve.org/slv.php");
			linkSleeveResponse.addParam(name = "Content-Type", type = "header", value = "text/xml; charset=utf-8");
			linkSleeveResponse.addParam(name = "Content-length", type = "header", value = len(trim(linkSleeveXML)));
			linkSleeveResponse.addParam(type = "body", value = trim(linkSleeveXML));
		}
		catch(any e) {
			linkSleeveHTTPRequest = false;
		}
		// check LinkSleeve results
		if (linkSleeveHTTPRequest) {
			try {
				responseXML = xmlParse(linkSleeveResponse.send().getPrefix().fileContent);
				linkSleeveResult = responseXML.methodResponse.params.param.value.int.xmlText;
				if (!linkSleeveResult) {
					// LinkSleeve says this fields submission is spam
					result.pass = false;
				}
			}
			catch(any e) { /* if there are any unforseen XML problems, just ignore. This should not happen :) */ }
		}

		return result;
	}

	/**
	* @hint "I test whether too many URLs have been submitted in fields"
	*/
	public boolean function testTooManyUrls(required struct fields) {
		var urlRegex = "(?i)\b((?:[a-z][\w-]+:(?:/{1,3}|[a-z0-9%])|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\(([^\s()<>]+|(\([^\s()<>]+\)))*\))+(?:\(([^\s()<>]+|(\([^\s()<>]+\)))*\)|[^\s`!()\[\]{};:'"".,<>?«»“”‘’]))";
		for (var checkField in arguments.fields)   {
			var urlCount = arrayLen(reMatch(urlRegex, arguments.fields[checkField])) - 1;
			if (urlCount >= getConfig().tooManyUrlsMaxUrls) {
				return false;
			}
		}

		return true;
	}

	/**
	* @hint "I test whether any of the configured spam strings are found in the fields submission"
	*/
	public boolean function testSpamStrings(required struct fields) {
		// Loop through the array of spam strings to see if they are found in the fields submission
		for (var field in arguments.fields) {
			if (isSimpleValue(arguments.fields[field]) && arrayFindNoCase(getConfig().spamstrings, arguments.fields[field])) {
				return false;
			}
		}

		return true;
	}

	/**
	* @hint "I send the user's IP address to the Project Honey Pot service to check if it's from a known spammer."
	*/
	public boolean function testProjHoneyPot(required struct fields) {
		var apiKey = getConfig().projectHoneyPotAPIKey;
		var visitorIP = cgi.remote_addr; // 93.174.93.221 is known to be bad
		var addressFound = true;
		var projHoneypotResult = "";
		// Setup the DNS query string
		var reversedIP = listToArray(visitorIP, ".");
		reversedIP = reversedIP[4] & "." & reversedIP[3] & "." & reversedIP[2] & "." & reversedIP[1];
		try {
			// Query Project Honeypot for this address
			var InetAddress = createObject("java", "java.net.InetAddress");
			var hostNameObj = InetAddress.getByName("#apiKey#.#reversedIP#.dnsbl.httpbl.org");
			projHoneypotResult = hostNameObj.getHostAddress();
		}
		catch(any UnknownHostException) {
			// The above Java code throws an exception when the address is not found in the Project Honey Pot database.
			addressFound = false;
		}
		if (addressFound) {
			var resultArray = listToArray(projHoneypotResult, ".");
			// resultArray[3] is the threat score for the address, rated from 0 to 255.
			// resultArray[4] is the classification for the address, anything higher than
			// 1 is either a harvester or comment spammer
			var threatScore = resultArray[3];
			var classification = resultArray[4];
			if (threatScore > 10 && classification > 1) {
				return false;
			}
		}

		return true;
	} 

	/**
	* @hint "I can be called to include the cffp.cfm content into 'view' files"
	* @output true
	*/
	public void function renderCFFP(string path = "/cfformprotect") {
		include "#arguments.path#/cffp.cfm";
	}

	/**
	* @hint "I email a report of spam activity from a given user"
	*/
	public void function emailReport(required struct testResults, required struct fields, required numeric totalPoints) {
		// Here is where you might want to make some changes, to customize what happens
		// if a spam message is found.  depending on your system, you can either just use
		// my code here, or email yourself the failed test, or plug into your system
		// in the best way for your needs
		savecontent variable="mailBody" {
			writeOutput("
				This message was marked as spam because:
				<ol>
			");
			if (structKeyExists(arguments.testResults, "mouseMovement") && !arguments.testResults.mouseMovement) {
				writeOutput("<li>No mouse movement was detected.</li>");
			}
			if (structKeyExists(arguments.testResults,"usedKeyboard") && !arguments.testResults.usedKeyboard) {
				writeOutput("<li>No keyboard activity was detected.</li>");
			}
			if (structKeyExists(arguments.testResults, "timedFormSubmission") && !arguments.testResults.timedFormSubmission.pass) {
				if (structKeyExists(arguments.fields, "formfield1234567893")) {
					writeOutput("<li>The time it took to fill out the fields was");
					if (arguments.fields.formfield1234567893 < getConfig().timedFormMinSeconds) {
						writeOutput("too short.");
					} else if (arguments.fields.formfield1234567893 > getConfig().timedFormMaxSeconds) {
						writeOutput("too long.");
					}
					writeOutput("It took them #arguments.fields.formfield1234567893# seconds to submit the fields, and your allowed threshold is #getConfig().timedFormMinSeconds#-#getConfig().timedFormMaxSeconds# seconds.</li>");
				} else {
					writeOutput("<li>The time it took to fill out the fields did not fall within your configured threshold of #getConfig().timedFormMinSeconds#-#getConfig().timedFormMaxSeconds# seconds. Also, I think the fields data for this field was tampered with by the spammer.</li>");
				}
			}
			if (structKeyExists(arguments.testResults, "hiddenFormField") && !arguments.testResults.hiddenFormField) {
				writeOutput("<li>The hidden fields field that is supposed to be blank contained data.</li>");
			}
			if (structKeyExists(arguments.testResults, "SpamStrings") && !arguments.testResults.SpamStrings) {
				writeOutput("<li>One of the configured spam strings was found in the fields submission.</li>");
			}
			if (structKeyExists(arguments.testResults, "akismet")) {
				var akismetURL = buildAkismetFailureURL(arguments.testResults, arguments.fields);
				if (!arguments.testResults.akismet.pass) {
					writeOutput("<li>Akisment thinks this is spam, if it's not please mark this as a false positive by <a href='#akismetURL#'>clicking here</a>.</li>");
				}
				if (arguments.testResults.akismet.validKey && arguments.testResults.akismet.pass) {
					writeOutput("Akismet did not think this message was spam. If it was, please <a href='#akismetURL#'>notify Akismet</a> that it missed one.");
				}
			}
			if (structKeyExists(arguments.testResults, "TooManyUrls") && !arguments.testResults.tooManyUrls) {
			    writeOutput("<li>There were too many URLs in the fields contents</li>");
			}
			if (structKeyExists(arguments.testResults, "ProjHoneyPot") && !arguments.testResults.ProjHoneyPot) {
				writeOutput("<li>The user's IP address has been flagged by Project Honey Pot.</li>");
			}
			writeOutput("
				</ol>
				Failure score: #totalPoints#<br>
				Your failure threshold: #getConfig().failureLimit#
				<br><br>
				IP address: #cgi.remote_addr#<br>
				User agent: #cgi.http_user_agent#<br>
				Previous page: #cgi.http_referer#<br>
				Form variables:
			");
			writeDump(fields);
		};
		new mail(
			to = getConfig().emailToAddress,
			from = getConfig().emailFromAddress,
			subject = getConfig().emailSubject,
			type = "html",
			server = getConfig().emailServer,
			username = getConfig().emailUserName,
			password = getConfig().emailpassword,
			body = mailBody
		).send();
	}

	/**
	* @hint "LOG ALL THE THINGS!!1"
	*/
	private void function logFailure(
		required struct testResults,
		required struct fields,
		required numeric totalPoints,
		required string logFile
	) {
		var logText = "Message marked as spam!";
		if (structKeyExists(arguments.testResults, "mouseMovement") && !arguments.testResults.mouseMovement) {
			logText = logText & "--- No mouse movement was detected.";
		}
		if (structKeyExists(arguments.testResults, "usedKeyboard") && !arguments.testResults.usedKeyboard) {
			logText = logText & "--- No keyboard activity was detected.";
		}
		if (structKeyExists(arguments.testResults, "timedFormSubmission") && !arguments.testResults.timedFormSubmission.pass) {
			if (structKeyExists(arguments.fields, "formfield1234567893")) {
				logText = logText & "--- The time it took to fill out the fields did not fall within your configured threshold of #getConfig().timedFormMinSeconds#-#getConfig().timedFormMaxSeconds# seconds.";
			} else {
				logText = logText & "The time it took to fill out the fields did not fall within your configured threshold of #getConfig().timedFormMinSeconds#-#getConfig().timedFormMaxSeconds# seconds.  Also, I think the fields data for this field was tampered with by the spammer.";
			}
		}
		if (structKeyExists(arguments.testResults, "hiddenFormField") && !arguments.testResults.hiddenFormField) {
			logText = logText & "--- The hidden fields field that is supposed to be blank contained data.";
		}
		if (structKeyExists(arguments.testResults, "spamStrings") && !arguments.testResults.SpamStrings) {
			logText = logText & "--- One of the configured spam strings was found in the fields submission.";
		}
		if (structKeyExists(arguments.testResults, "akismet")) {
			var akismetURL = buildAkismetFailureURL(arguments.testResults, arguments.fields);
			if (!arguments.testResults.akismet.pass) {
				logText = logText & "--- Akisment thinks this is spam, if it's not please mark this as a false positive by visiting: #akismetURL#";
			}
			if (arguments.testResults.akismet.validKey && arguments.testResults.akismet.pass) {
				logText = logText & "--- Akismet did not think this message was spam. If it was, please visit: #akismetURL#";
			}
		}
		if (structKeyExists(testResults, "TooManyUrls") && !arguments.testResults.tooManyUrls) {
			logText = logText & "--- There were too many URLs in the fields contents.";
		}
		if (structKeyExists(testResults, "ProjHoneyPot") && !arguments.testResults.ProjHoneyPot) {
			logText = logText & "--- The user's IP address has been flagged by Project Honey Pot.";
		}
		logText = logText & "--- Failure score: #totalPoints#. Your failure threshold: #getConfig().failureLimit#. IP address: #cgi.remote_addr# User agent: #cgi.http_user_agent# Previous page: #cgi.http_referer#";
		writeLog(file = "#arguments.logFile#", text = "#logText#");
	}
	
	/**
	* @hint "I am the remote function called through a URL to submit to Akismet."
	* @returnFormat "JSON"
	*/
	remote string function sendAkismetFailure(
		required string type = "",
		required string user_ip = "",
		required string user_agent = "",
		required string referrer = "",
		required string comment_author = "",
		required string comment_content = "",
		string comment_author_email = "",
		string comment_author_url = ""
	) {
		try {
			// Send fields contents to Akismet API
			var akismet = new http(method = "post", timeout = 10, url = "http://#getConfig().akismetAPIKey#.rest.akismet.com/1.1/submit-#arguments.type#");
			akismet.addParam(name = "key", type = "formfield", value = getConfig().akismetAPIKey);
			akismet.addParam(name = "blog", type = "formfield", value = getConfig().akismetBlogURL);
			akismet.addParam(name = "user_ip", type = "formfield", value = urlDecode(arguments.user_ip, 'utf-8'));
			akismet.addParam(name = "user_agent", type = "formfield", value = "CFFormProtect/1.0 | Akismet/1.11");
			akismet.addParam(name = "referrer", type = "formfield", value = urlDecode(arguments.referrer, 'utf-8'));
			akismet.addParam(name = "comment_author", type = "formfield", value = urlDecode(arguments.comment_author, 'utf-8'));
			akismet.addParam(name = "comment_content", type = "formfield", value = urlDecode(arguments.comment_content, 'utf-8'));
			if (getConfig().akismetFormEmailField != "") {
				akismet.addParam(name = "comment_author_email", type = "formfield", value = urlDecode(arguments.comment_author_email, 'utf-8'));	
			}
			if (getConfig().akismetFormURLField != "") {
				akismet.addParam(name = "comment_author_url", type = "formfield", value = urlDecode(arguments.comment_author_url, 'utf-8'));	
			}
			akismet.send();

			return "Thank you for submitting this data to Akismet.";
		}
		catch(any e) {
			return "Could not contact Akistmet server.";
		}
	}

	/**
	* @hint "I build a the URL for submitting to Akismet."
	*/
	private string function buildAkismetFailureURL(required struct testResults, required struct fields) {
		var type = "";
		if (!arguments.testResults.akismet.pass) { type = "ham"; }
		if (arguments.testResults.akismet.validKey && arguments.testResults.akismet.pass) { type = "spam"; }
		// The next few lines build the URL to submit to Akismet
		var akismetURL = replace("#getConfig().akismetBlogURL#cfformprotect/CFFPVerify.cfc?method=sendAkismetFailure&type=#type#", "://", "^^", "all");
		akismetURL = replace(akismetURL, "//", "/", "all");
		akismetURL = replace(akismetURL, "^^", "://", "all");
		akismetURL = akismetURL & "&user_ip=#urlEncodedFormat(cgi.remote_addr, 'utf-8')#";
		akismetURL = akismetURL&"&referrer=#urlEncodedFormat(cgi.http_referer, 'utf-8')#";
		akismetURL = akismetURL&"&comment_author=#urlEncodedFormat(arguments.fields[getConfig().akismetFormNameField], 'utf-8')#";
		if (getConfig().akismetFormEmailField != "") {
			akismetURL = akismetURL & "&comment_author_email=#urlEncodedFormat(arguments.fields[getConfig().akismetFormEmailField], 'utf-8')#";
		}
		if (getConfig().akismetFormURLField != "") {
			akismetURL = akismetURL & "&comment_author_url=#urlEncodedFormat(arguments.fields[getConfig().akismetFormURLField], 'utf-8')#";
		}
		akismetURL = akismetURL & "&comment_content=#urlEncodedFormat(arguments.fields[getConfig().akismetFormBodyField], 'utf-8')#";

		return akismetURL;
	}
}