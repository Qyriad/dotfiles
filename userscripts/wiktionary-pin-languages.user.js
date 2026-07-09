// ==UserScript==
// @name         Wiktionary — pin preferred languages
// @namespace    qyriad.wiktionary.langorder
// @version      1.1
// @description  Hoist chosen language sections to the top of a Wiktionary entry.
// @author       Qyriad
// @license      EUPL
// @match        https://en.wiktionary.org/wiki/*
// @match        https://en.m.wiktionary.org/wiki/*
// @run-at       document-end
// @grant        none
// ==/UserScript==
/*
 * Based on an implementation by Claude Opus 4.8.
 *
 */
(() => {
	'use strict';

	/** [start, end) */
	function* siblingsBetween(start, end) {
		let current = start;
		while (current && current !== end) {
			yield current;
			current = current.nextSibling;
		}
	}

	function headToSection(head, nextHead) {
		const id = head.querySelector("h2[id]")?.id ?? '';
		const nodes = [...siblingsBetween(head, nextHead)];
		return { id, nodes };
	}

	// Languages to hoist, in this order. Anything not listed keeps its original
	// relative position, below all of these. Values must match the <h2> id,
	// which is the language's displayed name in the heading, but with spaces
	// replaced by underscores.
	// e.g., "English", "Dutch", "Norwegian_Bokmål", etc.
	const PINNED = [
		'Translingual',
		'English',
		'Dutch',
		'Spanish',
		'Japanese',
	];

	// Each language section starts with a `div.mw-heading.mw-heading2 > h2`.
	// The h2's id is the language's name in Upper_Snake_Case.
	// On mobile, the contents are in the very next sibling `section.mf-section-N`.
	// NOTE: "very next" is load-bearing: the expansion toggle uses `.previousSibling`.
	//
	// On desktop, the contents are in a flat run of siblings until the next section.
	//
	// In either case, we traverse siblings until the next section (or the end of the page).

	const container = document.querySelector('.mw-parser-output');
	if (!container) {
		return;
	};

	// Each of these should have an `h2#The_Language`.
	const heads = [...container.querySelectorAll(':scope > .mw-heading.mw-heading2')];
	if (heads.length === 0) {
		return;
	};

	const sections = heads.map((head, i) => {
		const nextHead = heads[i + 1];
		return headToSection(head, nextHead);
	});

	// Bail on pages with no languages to pin.
	if (!sections.some(section => PINNED.includes(section.id))) {
		return;
	};

	// Pinned sections sort by index in PINNED; everything else sorts after them,
	// original order preserved via the positional tiebreaker (stable regardless
	// of engine sort stability, since the tiebreak is explicit).
	const rank = id => {
		const i = PINNED.indexOf(id);
		return i === -1 ? PINNED.length : i;
	};
	const ordered = sections
		.map((section, i) => ({ originalOrder: i, ...section }))
		.sort((lhs, rhs) => {
			return rank(lhs.id) - rank(rhs.id) || lhs.originalOrder - rhs.originalOrder;
		});

	const beforeFirstSection = document.createComment('lang-reorder');
	container.insertBefore(beforeFirstSection, sections[0].nodes[0]);

	// Node.appendChild() on an existing node moves it,
	// which should preserve listeners from gadgets and whatnot.
	const frag = document.createDocumentFragment();
	for (const section of ordered) {
		for (const node of section.nodes) {
			frag.appendChild(node);
		}
	}
	container.replaceChild(frag, beforeFirstSection);

	// Now onto the desktop sidebar table of contents, if present.
	// It's is a `ul#mw-panel-toc-list`, and each language is an `li#toc-The_Language`.
	// Not all list elements are languages though.
	const toc = document.querySelector("#mw-panel-toc-list");
	if (!toc) {
		// Mobile doesn't have one anyway.
		return;
	}

	// The very first one is the "Beginning" link (`li#toc-mw-content-text`),
	// which is not a language, but it is a handy place we can put things.
	const tocBeginning = toc.querySelector(":scope > #toc-mw-content-text");
	if (!tocBeginning) {
		// The layout probably changed.
		console.error("wiktionary-pin-languages: we seem to have a ToC but no #toc-mw-content-text");
		return;
	}

	const tocEntries = [...toc.querySelectorAll(":scope > li:not(#toc-mw-content-text)")];

	const rankTocEntry = tocId => {
		const lang = tocId.replace(/^toc-/, "");
		return rank(lang);
	};
	const tocOrdered = tocEntries
		.map((entry, i) => ({ id: entry.id, originalOrder: i, entry }))
		.sort((lhs, rhs) => {
			return rankTocEntry(lhs.id) - rankTocEntry(rhs.id) || lhs.originalOrder - rhs.originalOrder;
		});

	const afterBeginning = document.createComment("toc-lang-reorder");
	toc.insertBefore(afterBeginning, tocBeginning.nextSibling);

	const tocFrag = document.createDocumentFragment();
	for (const entry of tocOrdered) {
		tocFrag.appendChild(entry.entry);
	}
	toc.replaceChild(tocFrag, afterBeginning);
})();
