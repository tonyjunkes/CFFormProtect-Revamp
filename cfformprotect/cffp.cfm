<!--- Path to CFFormProtect from Web Root --->
<cfset cffpPath = "/app/modules/cfformprotect/framework/cfformprotect">
<!--- Load config --->
<cfset cffpConfig = deserializeJSON(fileRead("#getDirectoryFromPath(getCurrentTemplatePath())#/config.json"))>
<!---
Bas van der Graaf (bvdgraaf@e-dynamics.nl): Make sure JS is only included once when securing multiple forms with cfformprotect.
--->
<cfif NOT structKeyExists(request, "cffpJS")>
	<cfhtmlhead text="<script type='text/javascript' src='#cffpPath#/js/cffp.js'></script>">
	<cfset request.cffpJS = true>
</cfif>
<cfif cffpConfig.mouseMovement>
	<!---
	If the user moves their mouse, put the distance in this field (JavaScript function handles this).--->
	<input id="fp<cfoutput>#createUUID()#</cfoutput>" type="hidden" name="formfield1234567891" class="cffp_mm" value="">
</cfif>
<cfif cffpConfig.usedKeyboard>
	<!---
	If the user types on their keyboard, put the amount of keys pressed in this field. cffpVerify.cfm will make sure the user at least used their keyboard. A spam bot won't trigger this
	--->
	<input id="fp<cfoutput>#createUUID()#</cfoutput>" type="hidden" name="formfield1234567892" class="cffp_kp" value="">
</cfif>
<cfif cffpConfig.timedFormSubmission>
	<!---
	Verify that the amount of time it took to fill out this form is 'normal' (the time limits are set in the .json file)
	--->
	<!--- get the current time, obfuscate it and load it to this hidden field --->
	<cfset currentDate = dateFormat(now(),'yyyymmdd')>
	<cfset currentTime = timeFormat(now(),'HHmmss')>
	<!--- Add an arbitrary number to the date/time values to mask them from prying eyes --->
	<cfset blurredDate = currentDate+19740206>
	<cfset blurredTime = currentTime+19740206>
	<input id="fp<cfoutput>#createUUID()#</cfoutput>" type="hidden" name="formfield1234567893" value="<cfoutput>#blurredDate#,#blurredTime#</cfoutput>">
</cfif>
<cfif cffpConfig.hiddenFormField>
	<!---
	A lot of spam bots automatically fill in all form fields. Test to see if this field is blank. The "leave this empty" text is there for blind people, who might see this hidden field
	--->
	<span style="display:none">Leave this field empty <input id="fp<cfoutput>#createUUID()#</cfoutput>" type="text" name="formfield1234567894" value=""></span>
</cfif>