// Per-window sidebar side for Firefox, as an autoconfig (mozilla.cfg) script.
// See README.md next to this file for installation and caveats.
//
// Firefox keeps the sidebar's side in one global pref, sidebar.position_start,
// and every window listens to it. This script gives each window an optional
// override on top of that pref: a window follows the pref until you move its
// sidebar to the other side, and follows it again once you move it back.
//
// The override lives only as long as the window does; nothing is persisted.

(() => {
	"use strict";

	const LOG_PREFIX = "sidebar-per-window:";
	const POSITION_PREF = "sidebar.position_start";

	// Firefox's own "Customize sidebar" menu items. Our item goes right after
	// each one, and is shown exactly when Firefox shows that item, so we never
	// have to duplicate Firefox's logic for when sidebar actions make sense.
	const MENU_ANCHORS = [
		{ popupId: "sidebar-context-menu", anchorId: "sidebar-context-menu-customize-sidebar" },
		{ popupId: "toolbar-context-menu", anchorId: "toolbar-context-customize-sidebar" },
	];

	// Firefox styles a few rounded corners with `@media -moz-pref("sidebar.position_start")`,
	// which can't differ between windows. These rules only match a window whose
	// side disagrees with the pref, and give it the corners it would have had if
	// the pref agreed with it. User-origin `!important` wins over Firefox's author
	// rules, same as userChrome.css would.
	//
	// Mirrors browser/themes/shared/tabbrowser/content-area.css as of Firefox 157.
	const CSS = `
		@media -moz-pref("sidebar.revamp") {
			@media not -moz-pref("browser.nova.enabled") {
				@media -moz-pref("sidebar.position_start") {
					:root:not([ai-window], [inDOMFullscreen]) #tabbrowser-tabbox[sidebar-shown][sidebar-positionend] .browserContainer {
						border-start-start-radius: 0 !important;
						border-start-end-radius: var(--border-radius-medium) !important;
					}
				}
				@media not -moz-pref("sidebar.position_start") {
					:root:not([ai-window], [inDOMFullscreen]) #tabbrowser-tabbox[sidebar-shown]:not([sidebar-positionend]) .browserContainer {
						border-start-start-radius: var(--border-radius-medium) !important;
						border-start-end-radius: 0 !important;
					}
				}
			}
		}

		@media not -moz-pref("browser.nova.enabled") {
			@media -moz-pref("sidebar.position_start") {
				:root:not([inDOMFullscreen]) #tabbrowser-tabbox[sidebar-shown][sidebar-positionend] .browserSidebarContainer:not(.responsive-mode) .dialogOverlay[topmost="true"] {
					border-start-start-radius: 0 !important;
					border-start-end-radius: var(--border-radius-medium) !important;
				}
			}
			@media not -moz-pref("sidebar.position_start") {
				:root:not([inDOMFullscreen]) #tabbrowser-tabbox[sidebar-shown]:not([sidebar-positionend]) .browserSidebarContainer:not(.responsive-mode) .dialogOverlay[topmost="true"] {
					border-start-start-radius: var(--border-radius-medium) !important;
					border-start-end-radius: 0 !important;
				}
			}
		}
	`;

	function prefPositionStart() {
		return Services.prefs.getBoolPref(POSITION_PREF, true);
	}

	/**
	 * Names of the Firefox internals we hook that this window lacks.
	 * If any are missing, Firefox has changed underneath us, and we'd rather
	 * leave the window alone than half-work.
	 */
	function missingHooks(win) {
		const sc = win.SidebarController;
		if (!sc) {
			return ["SidebarController"];
		}

		const missing = [];
		if (typeof sc.setPosition !== "function") {
			missing.push("SidebarController.setPosition()");
		}
		if (typeof sc.reversePosition !== "function") {
			missing.push("SidebarController.reversePosition()");
		}
		if (typeof Object.getOwnPropertyDescriptor(sc, "_positionStart")?.get !== "function") {
			missing.push("SidebarController._positionStart getter");
		}
		return missing;
	}

	/**
	 * Replace a lazy pref getter on `obj` with `makeGetter(originalGetter)`.
	 *
	 * XPCOMUtils.defineLazyPreferenceGetter registers its pref observer as a weak
	 * reference, which only its getter closure keeps alive. So we must keep
	 * calling the original getter rather than dropping it, or the pref's change
	 * callback (which is what moves every window when the pref changes) can be
	 * garbage collected out from under us.
	 */
	function wrapGetter(obj, name, makeGetter) {
		// The first access swaps in the real getter and registers the observer.
		// Do it now so that swap can't later overwrite our property.
		void obj[name];

		const originalGet = Object.getOwnPropertyDescriptor(obj, name).get;
		Object.defineProperty(obj, name, {
			configurable: true,
			enumerable: true,
			get: makeGetter(originalGet),
		});
	}

	function setUpWindow(win) {
		const missing = missingHooks(win);
		if (missing.length) {
			console.warn(
				`${LOG_PREFIX} Firefox internals have changed (missing: ${missing.join(", ")}). ` +
				`This window's sidebar will just follow ${POSITION_PREF}.`
			);
			return;
		}

		const doc = win.document;
		const sc = win.SidebarController;

		/** @type {boolean | null} null means "follow the pref". */
		let positionStartOverride = null;

		wrapGetter(sc, "_positionStart", originalGet => function () {
			return positionStartOverride ?? originalGet.call(this);
		});

		// Moving to the side the pref already says clears the override, so the
		// window goes back to following the pref.
		sc.reversePosition = function () {
			const newPositionStart = !this._positionStart;
			positionStartOverride = newPositionStart === prefPositionStart() ? null : newPositionStart;
			this.setPosition();
		};

		// Tab drag-and-drop keeps its own copy of the pref, to decide which way a
		// tab dragged off the vertical tab strip is going.
		const tabs = win.gBrowser?.tabContainer;
		if (tabs && Object.getOwnPropertyDescriptor(tabs, "_sidebarPositionStart")?.get) {
			wrapGetter(tabs, "_sidebarPositionStart", originalGet => function () {
				// Keep the original reachable for the same GC reason as above.
				void originalGet;
				return sc._positionStart;
			});
		} else {
			console.warn(`${LOG_PREFIX} gBrowser.tabContainer._sidebarPositionStart not found; tab drag direction will follow ${POSITION_PREF}.`);
		}

		// The Customize Sidebar panel's "Show sidebar on the right" checkbox reads
		// the pref directly. Keep it in sync with this window instead. Its own pref
		// observer may run after SidebarController's on a pref change, so sync in a
		// microtask, after every pref observer has had its turn.
		function syncCustomizePanel() {
			const customize = sc.browser?.contentDocument?.querySelector("sidebar-customize");
			if (customize && "isPositionStart" in customize) {
				customize.isPositionStart = sc._positionStart;
			}
		}
		const originalSetPosition = sc.setPosition;
		sc.setPosition = function (...args) {
			const result = originalSetPosition.apply(this, args);
			win.queueMicrotask(syncCustomizePanel);
			return result;
		};
		sc.browser?.addEventListener("load", syncCustomizePanel, true);

		for (const { popupId, anchorId } of MENU_ANCHORS) {
			const popup = doc.getElementById(popupId);
			const anchor = doc.getElementById(anchorId);
			if (!popup || !anchor) {
				console.warn(`${LOG_PREFIX} #${anchorId} not found in #${popupId}; not adding a menu item there.`);
				continue;
			}

			const item = doc.createXULElement("menuitem");
			item.id = `${anchorId}-per-window-move`;
			item.addEventListener("command", () => sc.reversePosition());
			anchor.after(item);

			// Firefox decides whether to show its item in its own popupshowing
			// handling, which may run before or after ours, so rather than peek
			// at it in popupshowing, follow every change to it.
			const mirrorAnchorVisibility = () => {
				item.hidden = anchor.hidden;
			};
			new win.MutationObserver(mirrorAnchorVisibility).observe(anchor, { attributes: true, attributeFilter: ["hidden"] });
			mirrorAnchorVisibility();

			popup.addEventListener("popupshowing", event => {
				if (event.target !== popup) {
					return;
				}
				const sidebarOnLeft = sc._positionStart !== win.RTL_UI;
				item.label = `Move sidebar to the ${sidebarOnLeft ? "right" : "left"} in this window`;
			});
		}

		win.windowUtils.loadSheetUsingURIString(
			`data:text/css;charset=utf-8,${encodeURIComponent(CSS)}`,
			win.windowUtils.USER_SHEET
		);
	}

	Services.obs.addObserver(win => {
		try {
			setUpWindow(win);
		} catch (error) {
			console.error(`${LOG_PREFIX} failed to set up a window; its sidebar will follow ${POSITION_PREF}.`, error);
		}
	}, "browser-delayed-startup-finished");
})();
