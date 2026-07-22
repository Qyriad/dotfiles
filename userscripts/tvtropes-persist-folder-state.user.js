// ==UserScript==
// @name				 TVTropes Persist Folder State and Scroll Position
// @match				 https://tvtropes.org/*
// @run-at			 document-end
// @grant				 none
// ==/UserScript==

(function () {
	const KEY = 'tropeFolders:' + location.pathname;
	const folders = () => [...document.querySelectorAll('div.folder[isfolder="true"]')];
	const isOpen = el => getComputedStyle(el).display !== 'none';

	function save() {
		const open = folders().filter(isOpen).map(el => el.id);
		sessionStorage.setItem(KEY, JSON.stringify({ y: scrollY, open }));
	}

	function restore() {
		console.log("restore()");
		const raw = sessionStorage.getItem(KEY);
		if (!raw) return;
		const { y, open } = JSON.parse(raw);
		const want = new Set(open);
		for (const el of folders()) {
			console.log(el);
			if (want.has(el.id) !== isOpen(el)) {
				// use the site's toggler so the label arrow/aria stay in sync
				if (typeof togglefolder === 'function') {
					console.log("Calling togglefolder: ", togglefolder, el);
					togglefolder(el.id);
				} else {
					el.style.display = want.has(el.id) ? 'block' : 'none';
				}
			}
		}
		if (typeof y === 'number') scrollTo(0, y);
	}
	//function save() {
	//	const open = folders().filter(isOpen).map(el => el.id);
	//	// spread existing state so we don't clobber anything the site stored
	//	history.replaceState({ ...history.state, tropeFolders: { y: scrollY, open } }, '');
	//}
	//
	//function restore() {
	//	const st = history.state?.tropeFolders;
	//	if (!st) return;
	//	const want = new Set(st.open);
	//	for (const el of folders()) {
	//		if (want.has(el.id) !== isOpen(el)) {
	//			if (typeof togglefolder === 'function') togglefolder(el.id);
	//			else el.style.display = want.has(el.id) ? 'block' : 'none';
	//		}
	//	}
	//	if (typeof st.y === 'number') scrollTo(0, st.y);
	//}

	history.scrollRestoration = 'manual';
	console.log("about to restore");
	restore();

	document.addEventListener('click', e => {
		if (e.target.closest('.folderlabel')) setTimeout(save, 0); // capture post-toggle state
	});
	addEventListener('pagehide', save); // bfcache-safe; don't use 'unload'
})();
