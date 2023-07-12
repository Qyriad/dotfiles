/* ==UserStyle==
@name        ssbwiki table images
@description Add text to ssbwiki tier list
@match       *://*.ssbwiki.com/*
==/UserStyle== */

// Look for <td> elements which contain a single <a> which themselves contain an <img>
for (const td of document.querySelectorAll("table.wikitable td:has(> a > img)").values()) {
	// Verify that we indeed only have 1 <a> in this <td>.
	const link = td.firstElementChild;
	if (td.childElementCount !== 1 && link.tagName != "A") {
		continue;
	}

	// Verify that the <a> has an <img>.
	const img = link.firstElementChild;
	if (link.childElementCount !== 1 && img.tagName != "IMG") {
		continue;
	}

	// Get the "title" attribute of the <a>, which we will use to generate the label text.
	const title = link.getAttribute("title");
	if (!title) {
		console.info("Note: no title for table.wikitable td > a %o", link);
		continue;
	}

	// Strip information we don't need for display from the title.
	const prettyTitle = title.replace(/ \(SSB.?\)/, "").trim();

	// Normalize the title for usage as a CSS class.
	const titleClass = title.toLowerCase().replace(/[ _]/, "-").replace(/[()]/, "");

	// Now wrap the <img> in a <figure>.
	const figureElement = document.createElement("figure");
	const figcaptionElement = document.createElement("figcaption");
	const figcaptionText = document.createTextNode(prettyTitle);
	figcaptionElement.appendChild(figcaptionText);
	figureElement.setAttribute("class", `table-link table-link-${titleClass}`);

	figureElement.appendChild(img);
	figureElement.appendChild(figcaptionElement);

	link.appendChild(figureElement);
}
