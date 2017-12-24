(function() {
	try {
		var i, environmentVars, envObj = {},e = document.createEvent('Events');

		e.initEvent('globalVarsEvent', true, false);
		
		var j = 0;
		for ( i in window ) {
			environmentVars += i + ' ';
			j++;
			if(j>500) break;
		}
		envObj.environmentVars = environmentVars;

		var element = document.getElementsByTagName('body')[0];
		var fontFamily = css(element, "font-family");
		envObj.fontFamily = fontFamily;
		var finalJson = JSON.stringify(envObj);
		document.getElementById('divScriptsUsed').appendChild(document.createComment(finalJson));
		document.getElementById('divScriptsUsed').dispatchEvent(e);
	} catch(e) { console.log(e);}
	function css( element, property ) {
    	return window.getComputedStyle( element, "" ).getPropertyValue( property );
	}
}());
