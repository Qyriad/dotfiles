// ==UserScript==
// @name    TVTropes Persist Folder State and Scroll Position
// @match   https://tvtropes.org/*
// @run-at  document-end
// @grant   none
// ==/UserScript==

(function() {
	// skip ad/embed frames
	if (window.top !== window.self) return;

	const STORAGE_KEY = 'tropeFolders:' + location.pathname;

	// A folder is driven by a `.folderlabel` whose `is-open` class is the entire state;
	// its content is the next-sibling `.folder` div, whose id we use as the folder's key.
	// This predicate also drops the "open/close all" label — its sibling isn't a .folder.
	const folderLabels = () => [...document.querySelectorAll('.folderlabel')]
		.filter(label => {
			const content = label.nextElementSibling;
			//return content && content.classList.contains('folder') && content.id;
			return content?.classList.contains('folder') && content.id;
		});

	const folderId = label => label.nextElementSibling.id;
	const isOpen   = label => label.classList.contains('is-open');

	const storage = {
		read: () => {
			try {
				return JSON.parse(sessionStorage.getItem(STORAGE_KEY));
			} catch { return null; }
		},
		write: state => {
			try {
				sessionStorage.setItem(STORAGE_KEY, JSON.stringify(state));
			} catch {}
		},
	};

	// Keep storage's failure modes (private mode, quota, corrupt JSON) out of the logic below.
	const read = () => {
		try {
			return JSON.parse(sessionStorage.getItem(STORAGE_KEY));
		} catch { return null; }
	};
	const write = state => {
		try {
			sessionStorage.setItem(STORAGE_KEY, JSON.stringify(state));
		} catch {}
	};

	function save() {
		const open = folderLabels().filter(isOpen).map(folderId);
		write({ scrollY, open });
	}

	function restore() {
		const state = read();
		if (!state) {
			return
		};

		const shouldBeOpen = new Set(state.open);

		for (const label of folderLabels()) {
			if (shouldBeOpen.has(folderId(label)) !== isOpen(label)) {
				label.classList.toggle('is-open');
			}
		}

		if (typeof state.scrollY === 'number') {
			scrollTo(0, state.scrollY)
		};
	}

	const debounce = (fn, ms) => {
		let timer;
		return () => {
			clearTimeout(timer);
			timer = setTimeout(fn, ms);
		};
	};
	//const saveSoon = debounce(save, 150);

	history.scrollRestoration = 'manual';
	restore();

	// Their handler runs in the capture phase and flips `is-open`; defer our save one tick
	// so we read the state *after* it has toggled.
	document.addEventListener('click', event => {
		if (event.target.closest('.folderlabel')) {
			setTimeout(save, 0)
		};
	});

	addEventListener('scroll', debounce(save, 150), { passive: true });
	addEventListener('pagehide', save);
	addEventListener('visibilitychange', () => { if (document.hidden) save(); });
})()
