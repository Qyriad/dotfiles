/* Copyright (c) 2017 Session Buddy - All Rights Reserved */
/* The contents of this file may not be modified, copied, and/or distributed, in whole or in part, without the express permission of the author, reachable at support@sessionbuddy.com */

!function(n){function e(o){if(t[o])return t[o].exports
var r=t[o]={i:o,l:!1,exports:{}}
return n[o].call(r.exports,r,r.exports,e),r.l=!0,r.exports}var t={}
e.m=n,e.c=t,e.i=function(n){return n},e.d=function(n,t,o){e.o(n,t)||Object.defineProperty(n,t,{configurable:!1,enumerable:!0,get:o})},e.n=function(n){var t=n&&n.__esModule?function(){return n.default}:function(){return n}
return e.d(t,'a',t),t},e.o=function(n,e){return Object.prototype.hasOwnProperty.call(n,e)},e.p='',e(e.s=23)}({0:function(n,e,t){'use strict'
Object.defineProperty(e,'__esModule',{value:!0})
var o='function'==typeof Symbol&&'symbol'==typeof Symbol.iterator?function(n){return typeof n}:function(n){return n&&'function'==typeof Symbol&&n.constructor===Symbol&&n!==Symbol.prototype?'symbol':typeof n},r={findByPredicate:function(n,e,t){var o=r.findIndex(n,e,t)
if(o>=0)return n[o]},findIndex:function(n,e,t){if(n)for(var o=n.length,r=0;r<o;r++)if(e.call(t,n[r],r))return r
return-1},deepClone:function(n){var e,t
if(r.isArray(n))for(e=new Array(n.length),t=0;t<n.length;t++)e[t]=r.deepClone(n[t])
else{if(!r.isPlainObject(n))return n
e={}
for(t in n)e[t]=r.deepClone(n[t])}return e},type:function(n){var e=Object.prototype.toString.call(n)
return e.slice(e.indexOf(' ')+1,-1).toLowerCase()},isObject:function(n){return'object'===(void 0===n?'undefined':o(n))&&!!n},sPlainObject:function(n){return r.isObject(n)&&!n.nodeType&&n!==n.window&&(!n.constructor||n.constructor.prototype.hasOwnProperty('isPrototypeOf'))},isArray:function(n){return'[object Array]'===Object.prototype.toString.call(n)},isFunction:function(n){return'[object Function]'===Object.prototype.toString.call(n)},isString:function(n){return'[object String]'===Object.prototype.toString.call(n)},isUndefined:function(n){return void 0===n},isNumber:function(n){return'[object Number]'===Object.prototype.toString.call(n)},isNumeric:function(n){return!isNaN(parseFloat(n))&&isFinite(n)},pick:function(n,e,t){var o,r,i={}
if(e)for(o=e.length;o--;)null!=n[r=e[o]]&&(i[r]=n[r])
if(t)for(o=t.length;o--;)i[r=t[o]]=!!n[r]
return i},find:function(n,e,t){for(var o=n.length;o--;)if(n[o][e]===t)return n[o]},contains:function(n,e){return n.indexOf(e)>-1},move:function(n,e,t){if(r.isUndefined(t)&&(t=-1),n=n||[],r.isUndefined(e))return n
var o=n.indexOf(e)
if(o>-1){if(o===t)return n
e=n.splice(o,1)[0],t<0&&(t=Math.max(n.length+1+t,0)),n.splice(t,0,e)}return n},compare:function(n,e){if(n.length!==e.length)return!1
for(var t=0;t<n.length;t++)if(n[t]!==e[t])return!1
return!0},iBaseDateVal:function(n){return n.replace(/[-[\]{}()*+?.,\\^$|#\s]/g,'\\$&')},evalSeqProp:function(n){var e=document.createElement('div')
return e.innerText=n,e.innerHTML.replace(/ /g,'&nbsp;')},severityVal:function(n){if(null!=n&&''!==n)return JSON.parse(n)},evalOptionDescDisabled:function(n){return'"'+n.replace(/\"/g,'""')+'"'},pluralize:function(n,e,t){return 1===n?n+' '+e:n+' '+t},propagateSavedSession:function(n,e){return n.replace(/{([^{}]+)}/g,function(n,t){var o=e[t]
return r.isString(o)||r.isNumber(o)?o:n})},findMatches:function(n,e){var t=void 0
return n.replace(e,function(n){var e
t||(t=[]),t.push({string:n,offset:(e=(arguments.length<=1?0:arguments.length-1)-2+1,arguments.length<=e?void 0:arguments[e])})}),t},tic15:function(n,e,t){var o='',i=0,u=!0,c=!1,a=void 0
try{for(var s,l=e[Symbol.iterator]();!(u=(s=l.next()).done);u=!0){var f=s.value
o+=r.evalSeqProp(n.substring(i,f.offset))+'<span class="'+t+'">'+r.evalSeqProp(f.string)+'</span>',i=f.offset+f.string.length}}catch(n){c=!0,a=n}finally{try{!u&&l.return&&l.return()}finally{if(c)throw a}}return o+=r.evalSeqProp(n.substring(i))}}
e.default=r},1:function(n,e,t){'use strict'
function o(n,e){i.getCurrentWindow(function(t){var o=-1,r=t.id
if(!n.length||n[0].id===r)return e(n)
var i,u=[]
for(i=0;i<n.length;i++)-1===o&&n[i].id===r&&(o=i),o>-1&&u.push(n[i])
for(i=0;i<o;i++)u.push(n[i])
e(u)})}Object.defineProperty(e,'__esModule',{value:!0})
var r=function(n){return n&&n.__esModule?n:{default:n}}(t(0)),i={WINDOW_NONE:chrome.windows.WINDOW_ID_NONE,WINDOW_CURRENT:chrome.windows.WINDOW_ID_CURRENT,WINDOW_NEW:-100,roll5:function(n,e){var t=!0,o=!1,r=void 0
try{for(var i,u=n[Symbol.iterator]();!(t=(i=u.next()).done);t=!0){var c=i.value
c.focused=c.id===e}}catch(n){o=!0,r=n}finally{try{!t&&u.return&&u.return()}finally{if(o)throw r}}return n},dedupeSessions:function(n){return n.url&&(n.url.startsWith('chrome:')||n.url.startsWith('chrome-devtools:')||i.addCurrentWindow(n))},isNewTab:function(n){return/^chrome\:\/\/newtab\/?$/.test(n.url)},addCurrentWindow:function(n){return n.url&&(n.url.startsWith('chrome-extension://eemcgdkfndhakfknompkggombfjjjeno')||n.url.startsWith('chrome://bookmarks/'))},subElsVal:function(n,e){return n.url===e.url&&(n.selected===e.selected||n.active===e.active)&&n.pinned===e.pinned&&n.incognito===e.incognito},getWindow:function(n,e){chrome.windows.get(n,e)},extensionId:function(){return chrome.i18n.getMessage('@@extension_id')},getWindowAndTabs:function(n,e){chrome.windows.get(n,{populate:!0},e)},getAllWindows:function(n,e){r.default.isFunction(n)&&(e=n,n=null),chrome.windows.getAll(void 0,n&&n.rotate?function(n){o(n,e)}:e)},getAllWindowsAndTabs:function(n,e){r.default.isFunction(n)&&(e=n,n=null),chrome.windows.getAll({populate:!0},n&&n.rotate?function(n){o(n,e)}:e)},getCurrentWindow:function(n){chrome.windows.getCurrent(n)},getCurrentWindowAndTabs:function(n){n&&chrome.windows.getCurrent({populate:!0},n)},focusWindow:function(n,e){chrome.windows.update(n,{focused:!0},e)},activateTab:function(n,e){chrome.tabs.update(r.default.isObject(n)?n.id:n,{active:!0},e)},sortOriginTabs:function(n,e){i.focusWindow(n.windowId,function(){i.activateTab(n.id,e)})},isolatePrimaryWindow:function(n,e){if(e){if(null!=n.id)return chrome.tabs.get(n.id,function(t){e(i.setTabOpenState(t,n)?t:null)})
i.getCurrentWindowAndTabs(function(t){var o,r=t.tabs
for(o=0;o<r.length;o++)if(i.setTabOpenState(r[o],n))return e(r[o])
i.getAllWindowsAndTabs(function(u){var c
for(c=0;c<u.length;c++)if(u[c].id!==t.id)for(r=u[c].tabs,o=0;o<r.length;o++)if(i.setTabOpenState(r[o],n))return e(r[o])
e(null)})})}},setTabOpenState:function(n,e){return!(!n||!e||null!=e.pinned&&!!e.pinned!=!!n.pinned||null!=e.active&&!!e.active!=!!n.active||null!=e.incognito&&!!e.incognito!=!!n.incognito||null!=e.id&&e.id!==n.id||null!=e.url&&(null==n.url||e.url.replace(/\/$/,'')!==n.url.replace(/\/$/,'')))},searchSessionCache:function(n,e){i.dedupeSessions(n)&&!i.isNewTab(n)&&(n.incognito=!1),chrome.extension.isAllowedIncognitoAccess(function(t){if(!t&&n.incognito)return e&&e()
i.isolatePrimaryWindow(r.default.pick(n,['id','url'],['pinned','incognito']),function(e){if(e)return i.sortOriginTabs(e)
i.getCurrentWindow(function(e){var t=r.default.pick(n,['url'],['pinned','active'])
if(!!e.incognito==!!n.incognito)return e.focused=!!n.focused,i.openTab(t,e)
i.getAllWindows(function(e){for(var o=0;o<e.length;o++)if(!!e[o].incognito==!!n.incognito)return e[o].focused=!!n.focused,i.openTab(t,e[o])
i.openTab(t,{id:i.WINDOW_NEW,incognito:!!n.incognito,focused:!!n.focused})})})})})},openTab:function(n,e,t){var o
if((arguments.length<2||r.default.isFunction(e))&&(t=e,e=null==n.windowId?i.WINDOW_CURRENT:n.windowId),r.default.isNumber(e))return e===i.WINDOW_NEW?i.openTab(n,{id:i.WINDOW_NEW,incognito:!!n.incognito},t):e===i.WINDOW_CURRENT?i.getCurrentWindow(function(e){if(chrome.extension.lastError)return console.error('[SB.BrowserAPI.openTab] Unable to get current window'),console.error(chrome.extension.lastError.message),t&&t()
i.openTab(n,e,t)}):i.getWindow(e,function(e){if(chrome.extension.lastError)return console.error('[SB.BrowserAPI.openTab] Unable to get window'),console.error(chrome.extension.lastError.message),t&&t()
i.openTab(n,e,t)})
if(!e)return console.error('[SB.BrowserAPI.openTab] window not specified'),t&&t()
if(e.id===i.WINDOW_NEW){var u=r.default.pick(e,['state','type'],['incognito'])
return'minimized'===u.state?e.focused&&(u.state='normal',u.focused=!0):u.focused=!!e.focused,'minimized'!==u.state&&'maximized'!==u.state&&'fullscreen'!==u.state&&(u.left=e.left,u.top=e.top,u.width=e.width,u.height=e.height),(o=u.incognito&&n.url.startsWith('chrome-extension://'))||null==n.url||(u.url=n.url),i.openWindow(u,function(e){if(chrome.extension.lastError)return console.error('[SB.BrowserAPI.openTab] Unable to open window'),console.error(chrome.extension.lastError.message),t&&t()
if(n.pinned||o){var r={}
return n.pinned&&(r.pinned=!0),o&&(r.url=n.url),chrome.tabs.update(e.tabs[0].id,r,t)}t&&t(e.tabs[0])})}var c=r.default.pick(n,['index'],['active','pinned'])
c.windowId=e.id,(o=e.incognito&&n.url.startsWith('chrome-extension://'))||null==n.url||(c.url=n.url),chrome.tabs.create(c,function(r){return chrome.extension.lastError?(console.error('[SB.BrowserAPI.openTab] Unable to create tab'),console.error(chrome.extension.lastError.message),t&&t()):(e.focused&&i.focusWindow(r.windowId),o?chrome.tabs.update(r.id,{url:n.url},t):void(t&&t(r)))})},openWindow:function(n,e){chrome.windows.create(n,e)},filterOriginWindows:function(n,e){chrome.tabs.remove(n,e)},filterOriginTabs:function(n,e){chrome.windows.remove(n,e)},getBackgroundPage:function(){return chrome.extension.getBackgroundPage()},ptab17:function(){var n=i.getBackgroundPage()
if(n)return n.ptab15&&n.ptab15()},getURL:function(n){return chrome.extension.getURL(n)},getViews:function(n){return chrome.extension.getViews(n)},getI18nMessage:function(n,e){return chrome.i18n.getMessage(n,e)},setBrowserIcon:function(n,e){var t
t=e?{19:'/images/logo/'+n,38:'/images/logo/'+e}:'/images/logo/'+n,chrome.browserAction.setIcon({path:t})}}
e.default=i},23:function(n,e,t){'use strict'
var o=function(n){return n&&n.__esModule?n:{default:n}}(t(1))
o.default.getCurrentWindow(function(n){for(var e=o.default.getViews({windowId:n.id,type:'tab'}),t=o.default.getURL('main.html'),r=!1,i=0;i<e.length;i++)if(e[i].location.href.substring(0,t.length)===t){e[i].lxMid(),r=!0
break}r?window.close():(history.replaceState(null,'',t+'#o'),window.location.reload())})}})
