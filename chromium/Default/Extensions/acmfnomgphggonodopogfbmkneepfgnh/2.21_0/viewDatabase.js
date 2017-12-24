//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


document.addEventListener("DOMContentLoaded", function() {
	chrome.runtime.getBackgroundPage(function(backgroundPage) {
		var backgroundWin = backgroundPage;
		var dataTable = document.getElementById("dataTable");
		for (var i=0; i < backgroundWin.data.pageURL.length; i++) {
			var tr = document.createElement("tr");
			var tdPageCustomFavicon = document.createElement("td");
			tdPageCustomFavicon.setAttribute("align", "center");
			var imgPageCustomFavicon = document.createElement("img");
			imgPageCustomFavicon.src = backgroundWin.data.pageCustomFavicon[i];
			tdPageCustomFavicon.appendChild(imgPageCustomFavicon);
			tr.appendChild(tdPageCustomFavicon);
			var tdPageOriginalFavicon = document.createElement("td");
			tdPageOriginalFavicon.setAttribute("align", "center");
			var imgPageOriginalFavicon = document.createElement("img");
			imgPageOriginalFavicon.src = backgroundWin.data.pageOriginalFavicon[i];
			tdPageOriginalFavicon.appendChild(imgPageOriginalFavicon);
			tr.appendChild(tdPageOriginalFavicon);
			var tdPageURL = document.createElement("td");
			tdPageURL.appendChild(document.createTextNode(backgroundWin.data.pageURL[i]));
			tr.appendChild(tdPageURL);
			dataTable.appendChild(tr);
		}
		chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
			if (request.command === "updateList") {
				window.location.reload(true);
			}
		});
	});
});
