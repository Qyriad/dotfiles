var xmlhttp = new XMLHttpRequest();
xmlhttp.onreadystatechange = function() {
	if (xmlhttp.readyState == 4) {
		if (xmlhttp.status == 200) {
			var text = xmlhttp.responseText;
			text = text.replace(/\{%.*%\}/gi, '');
			document.getElementById('ack-container').innerHTML = text;
		} else {
			document.getElementById('ack-container').innerHTML = 'Error: Unable to load acknowledgements';
		}
	}
}
xmlhttp.open("GET", "acknowledgements.htpp", true);
xmlhttp.send();
