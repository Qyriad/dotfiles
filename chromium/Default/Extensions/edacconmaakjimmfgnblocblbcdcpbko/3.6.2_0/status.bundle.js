/* Copyright (c) 2017 Session Buddy - All Rights Reserved */
/* The contents of this file may not be modified, copied, and/or distributed, in whole or in part, without the express permission of the author, reachable at support@sessionbuddy.com */

!function(e){function t(n){if(o[n])return o[n].exports
var i=o[n]={i:n,l:!1,exports:{}}
return e[n].call(i.exports,i,i.exports,t),i.l=!0,i.exports}var o={}
t.m=e,t.c=o,t.i=function(e){return e},t.d=function(e,o,n){t.o(e,o)||Object.defineProperty(e,o,{configurable:!1,enumerable:!0,get:n})},t.n=function(e){var o=e&&e.__esModule?function(){return e.default}:function(){return e}
return t.d(o,'a',o),o},t.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},t.p='',t(t.s=24)}({0:function(e,t,o){'use strict'
Object.defineProperty(t,'__esModule',{value:!0})
var n='function'==typeof Symbol&&'symbol'==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&'function'==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?'symbol':typeof e},i={findByPredicate:function(e,t,o){var n=i.findIndex(e,t,o)
if(n>=0)return e[n]},findIndex:function(e,t,o){if(e)for(var n=e.length,i=0;i<n;i++)if(t.call(o,e[i],i))return i
return-1},deepClone:function(e){var t,o
if(i.isArray(e))for(t=new Array(e.length),o=0;o<e.length;o++)t[o]=i.deepClone(e[o])
else{if(!i.isPlainObject(e))return e
t={}
for(o in e)t[o]=i.deepClone(e[o])}return t},type:function(e){var t=Object.prototype.toString.call(e)
return t.slice(t.indexOf(' ')+1,-1).toLowerCase()},isObject:function(e){return'object'===(void 0===e?'undefined':n(e))&&!!e},sPlainObject:function(e){return i.isObject(e)&&!e.nodeType&&e!==e.window&&(!e.constructor||e.constructor.prototype.hasOwnProperty('isPrototypeOf'))},isArray:function(e){return'[object Array]'===Object.prototype.toString.call(e)},isFunction:function(e){return'[object Function]'===Object.prototype.toString.call(e)},isString:function(e){return'[object String]'===Object.prototype.toString.call(e)},isUndefined:function(e){return void 0===e},isNumber:function(e){return'[object Number]'===Object.prototype.toString.call(e)},isNumeric:function(e){return!isNaN(parseFloat(e))&&isFinite(e)},pick:function(e,t,o){var n,i,r={}
if(t)for(n=t.length;n--;)null!=e[i=t[n]]&&(r[i]=e[i])
if(o)for(n=o.length;n--;)r[i=o[n]]=!!e[i]
return r},find:function(e,t,o){for(var n=e.length;n--;)if(e[n][t]===o)return e[n]},contains:function(e,t){return e.indexOf(t)>-1},move:function(e,t,o){if(i.isUndefined(o)&&(o=-1),e=e||[],i.isUndefined(t))return e
var n=e.indexOf(t)
if(n>-1){if(n===o)return e
t=e.splice(n,1)[0],o<0&&(o=Math.max(e.length+1+o,0)),e.splice(o,0,t)}return e},compare:function(e,t){if(e.length!==t.length)return!1
for(var o=0;o<e.length;o++)if(e[o]!==t[o])return!1
return!0},iBaseDateVal:function(e){return e.replace(/[-[\]{}()*+?.,\\^$|#\s]/g,'\\$&')},evalSeqProp:function(e){var t=document.createElement('div')
return t.innerText=e,t.innerHTML.replace(/ /g,'&nbsp;')},severityVal:function(e){if(null!=e&&''!==e)return JSON.parse(e)},evalOptionDescDisabled:function(e){return'"'+e.replace(/\"/g,'""')+'"'},pluralize:function(e,t,o){return 1===e?e+' '+t:e+' '+o},propagateSavedSession:function(e,t){return e.replace(/{([^{}]+)}/g,function(e,o){var n=t[o]
return i.isString(n)||i.isNumber(n)?n:e})},findMatches:function(e,t){var o=void 0
return e.replace(t,function(e){var t
o||(o=[]),o.push({string:e,offset:(t=(arguments.length<=1?0:arguments.length-1)-2+1,arguments.length<=t?void 0:arguments[t])})}),o},tic15:function(e,t,o){var n='',r=0,a=!0,d=!1,l=void 0
try{for(var s,c=t[Symbol.iterator]();!(a=(s=c.next()).done);a=!0){var u=s.value
n+=i.evalSeqProp(e.substring(r,u.offset))+'<span class="'+o+'">'+i.evalSeqProp(u.string)+'</span>',r=u.offset+u.string.length}}catch(e){d=!0,l=e}finally{try{!a&&c.return&&c.return()}finally{if(d)throw l}}return n+=i.evalSeqProp(e.substring(r))}}
t.default=i},1:function(e,t,o){'use strict'
function n(e,t){r.getCurrentWindow(function(o){var n=-1,i=o.id
if(!e.length||e[0].id===i)return t(e)
var r,a=[]
for(r=0;r<e.length;r++)-1===n&&e[r].id===i&&(n=r),n>-1&&a.push(e[r])
for(r=0;r<n;r++)a.push(e[r])
t(a)})}Object.defineProperty(t,'__esModule',{value:!0})
var i=function(e){return e&&e.__esModule?e:{default:e}}(o(0)),r={WINDOW_NONE:chrome.windows.WINDOW_ID_NONE,WINDOW_CURRENT:chrome.windows.WINDOW_ID_CURRENT,WINDOW_NEW:-100,roll5:function(e,t){var o=!0,n=!1,i=void 0
try{for(var r,a=e[Symbol.iterator]();!(o=(r=a.next()).done);o=!0){var d=r.value
d.focused=d.id===t}}catch(e){n=!0,i=e}finally{try{!o&&a.return&&a.return()}finally{if(n)throw i}}return e},dedupeSessions:function(e){return e.url&&(e.url.startsWith('chrome:')||e.url.startsWith('chrome-devtools:')||r.addCurrentWindow(e))},isNewTab:function(e){return/^chrome\:\/\/newtab\/?$/.test(e.url)},addCurrentWindow:function(e){return e.url&&(e.url.startsWith('chrome-extension://eemcgdkfndhakfknompkggombfjjjeno')||e.url.startsWith('chrome://bookmarks/'))},subElsVal:function(e,t){return e.url===t.url&&(e.selected===t.selected||e.active===t.active)&&e.pinned===t.pinned&&e.incognito===t.incognito},getWindow:function(e,t){chrome.windows.get(e,t)},extensionId:function(){return chrome.i18n.getMessage('@@extension_id')},getWindowAndTabs:function(e,t){chrome.windows.get(e,{populate:!0},t)},getAllWindows:function(e,t){i.default.isFunction(e)&&(t=e,e=null),chrome.windows.getAll(void 0,e&&e.rotate?function(e){n(e,t)}:t)},getAllWindowsAndTabs:function(e,t){i.default.isFunction(e)&&(t=e,e=null),chrome.windows.getAll({populate:!0},e&&e.rotate?function(e){n(e,t)}:t)},getCurrentWindow:function(e){chrome.windows.getCurrent(e)},getCurrentWindowAndTabs:function(e){e&&chrome.windows.getCurrent({populate:!0},e)},focusWindow:function(e,t){chrome.windows.update(e,{focused:!0},t)},activateTab:function(e,t){chrome.tabs.update(i.default.isObject(e)?e.id:e,{active:!0},t)},sortOriginTabs:function(e,t){r.focusWindow(e.windowId,function(){r.activateTab(e.id,t)})},isolatePrimaryWindow:function(e,t){if(t){if(null!=e.id)return chrome.tabs.get(e.id,function(o){t(r.setTabOpenState(o,e)?o:null)})
r.getCurrentWindowAndTabs(function(o){var n,i=o.tabs
for(n=0;n<i.length;n++)if(r.setTabOpenState(i[n],e))return t(i[n])
r.getAllWindowsAndTabs(function(a){var d
for(d=0;d<a.length;d++)if(a[d].id!==o.id)for(i=a[d].tabs,n=0;n<i.length;n++)if(r.setTabOpenState(i[n],e))return t(i[n])
t(null)})})}},setTabOpenState:function(e,t){return!(!e||!t||null!=t.pinned&&!!t.pinned!=!!e.pinned||null!=t.active&&!!t.active!=!!e.active||null!=t.incognito&&!!t.incognito!=!!e.incognito||null!=t.id&&t.id!==e.id||null!=t.url&&(null==e.url||t.url.replace(/\/$/,'')!==e.url.replace(/\/$/,'')))},searchSessionCache:function(e,t){r.dedupeSessions(e)&&!r.isNewTab(e)&&(e.incognito=!1),chrome.extension.isAllowedIncognitoAccess(function(o){if(!o&&e.incognito)return t&&t()
r.isolatePrimaryWindow(i.default.pick(e,['id','url'],['pinned','incognito']),function(t){if(t)return r.sortOriginTabs(t)
r.getCurrentWindow(function(t){var o=i.default.pick(e,['url'],['pinned','active'])
if(!!t.incognito==!!e.incognito)return t.focused=!!e.focused,r.openTab(o,t)
r.getAllWindows(function(t){for(var n=0;n<t.length;n++)if(!!t[n].incognito==!!e.incognito)return t[n].focused=!!e.focused,r.openTab(o,t[n])
r.openTab(o,{id:r.WINDOW_NEW,incognito:!!e.incognito,focused:!!e.focused})})})})})},openTab:function(e,t,o){var n
if((arguments.length<2||i.default.isFunction(t))&&(o=t,t=null==e.windowId?r.WINDOW_CURRENT:e.windowId),i.default.isNumber(t))return t===r.WINDOW_NEW?r.openTab(e,{id:r.WINDOW_NEW,incognito:!!e.incognito},o):t===r.WINDOW_CURRENT?r.getCurrentWindow(function(t){if(chrome.extension.lastError)return console.error('[SB.BrowserAPI.openTab] Unable to get current window'),console.error(chrome.extension.lastError.message),o&&o()
r.openTab(e,t,o)}):r.getWindow(t,function(t){if(chrome.extension.lastError)return console.error('[SB.BrowserAPI.openTab] Unable to get window'),console.error(chrome.extension.lastError.message),o&&o()
r.openTab(e,t,o)})
if(!t)return console.error('[SB.BrowserAPI.openTab] window not specified'),o&&o()
if(t.id===r.WINDOW_NEW){var a=i.default.pick(t,['state','type'],['incognito'])
return'minimized'===a.state?t.focused&&(a.state='normal',a.focused=!0):a.focused=!!t.focused,'minimized'!==a.state&&'maximized'!==a.state&&'fullscreen'!==a.state&&(a.left=t.left,a.top=t.top,a.width=t.width,a.height=t.height),(n=a.incognito&&e.url.startsWith('chrome-extension://'))||null==e.url||(a.url=e.url),r.openWindow(a,function(t){if(chrome.extension.lastError)return console.error('[SB.BrowserAPI.openTab] Unable to open window'),console.error(chrome.extension.lastError.message),o&&o()
if(e.pinned||n){var i={}
return e.pinned&&(i.pinned=!0),n&&(i.url=e.url),chrome.tabs.update(t.tabs[0].id,i,o)}o&&o(t.tabs[0])})}var d=i.default.pick(e,['index'],['active','pinned'])
d.windowId=t.id,(n=t.incognito&&e.url.startsWith('chrome-extension://'))||null==e.url||(d.url=e.url),chrome.tabs.create(d,function(i){return chrome.extension.lastError?(console.error('[SB.BrowserAPI.openTab] Unable to create tab'),console.error(chrome.extension.lastError.message),o&&o()):(t.focused&&r.focusWindow(i.windowId),n?chrome.tabs.update(i.id,{url:e.url},o):void(o&&o(i)))})},openWindow:function(e,t){chrome.windows.create(e,t)},filterOriginWindows:function(e,t){chrome.tabs.remove(e,t)},filterOriginTabs:function(e,t){chrome.windows.remove(e,t)},getBackgroundPage:function(){return chrome.extension.getBackgroundPage()},ptab17:function(){var e=r.getBackgroundPage()
if(e)return e.ptab15&&e.ptab15()},getURL:function(e){return chrome.extension.getURL(e)},getViews:function(e){return chrome.extension.getViews(e)},getI18nMessage:function(e,t){return chrome.i18n.getMessage(e,t)},setBrowserIcon:function(e,t){var o
o=t?{19:'/images/logo/'+e,38:'/images/logo/'+t}:'/images/logo/'+e,chrome.browserAction.setIcon({path:o})}}
t.default=r},2:function(e,t,o){'use strict'
Object.defineProperty(t,'__esModule',{value:!0})
var n=function(e){return e&&e.__esModule?e:{default:e}}(o(0)),i={toggleClass:function(e,t,o){e.classList[o?'add':'remove'](t)},txAltVal:function(e){return null===e.getAttribute('disabled')},disable:function(e){if(e)return n.default.isArray(e)?e.forEach(function(e){return i.disable(e)}):void e.setAttribute('disabled','disabled')},enable:function(e){if(e)return n.default.isArray(e)?e.forEach(function(e){return i.enable(e)}):void e.removeAttribute('disabled')},toggleEnable:function(e,t){t?i.enable(e):i.disable(e)},qlift7:function(e){e.focus()
var t=document.createRange()
t.selectNodeContents(e)
var o=window.getSelection()
o.removeAllRanges(),o.addRange(t)},addTitle:function(){return window.devicePixelRatio||1},os:function(){var e=navigator.appVersion
return e.includes('Win')&&'Windows'||e.includes('Mac')&&'MacOS'||e.includes('X11')&&'UNIX'||e.includes('Linux')&&'Linux'||'(unknown)'}(),win9:function(e){return e=e||window,function t(o,n){if(o){if(!n)return e.document.getElementById(o)
if(n.hasChildNodes()){var i=void 0,r=!0,a=!1,d=void 0
try{for(var l,s=n.children[Symbol.iterator]();!(r=(l=s.next()).done);r=!0){var c=l.value
if(c.id===o)return c
if(i=t(o,c))return i}}catch(e){a=!0,d=e}finally{try{!r&&s.return&&s.return()}finally{if(a)throw d}}}}}},createElement:function(e,t,o,i){var r=document.createElement(e)
return t&&(r.id=t),n.default.isString(o)&&(o.includes(':')?r.setAttribute('style',o):o.trim()&&(r.className=o)),(n.default.isString(i)||n.default.isNumber(i))&&(r.innerHTML=i),r},isChildOf:function(e,t){for(;e;){if(e===t)return!0
e=e.parentNode}return!1},iApplicationExVal:function(e,t){return i.isChildOf(e,t||document)},isControlEl:function(e){switch(n.default.type(e)){case'htmlinputelement':case'htmltextareaelement':case'htmlselectelement':return!0}return!1},iWindows1:function(e,t){if('checkbox'===e.type)e.checked=t
else if('radio'===e.type){var o=!0,n=!1,i=void 0
try{for(var r,a=document.getElementsByName(e.name)[Symbol.iterator]();!(o=(r=a.next()).done);o=!0){var d=r.value
if(d.value==t){d.checked=!0
break}}}catch(e){n=!0,i=e}finally{try{!o&&a.return&&a.return()}finally{if(n)throw i}}}else e.value=t
e.dataset.init=t},tabOpenState:function(e){if(i.isControlEl(e)){if('checkbox'===e.type)return e.checked
if('radio'!==e.type)return e.value
var t=!0,o=!1,n=void 0
try{for(var r,a=e.ownerDocument.getElementsByName(e.name)[Symbol.iterator]();!(t=(r=a.next()).done);t=!0){var d=r.value
if(d.checked)return d.value}}catch(e){o=!0,n=e}finally{try{!t&&a.return&&a.return()}finally{if(o)throw n}}}},adjustWindow:function(e,t){if(e){t||(t=i.iApplicationExVal(e)?e.parentNode:document.body),t.appendChild(e=e.cloneNode(!0))
var o=e.style.paddingTop,n=e.style.paddingBottom,r=e.style.borderTopWidth,a=e.style.borderBottomWidth,d=e.getBoundingClientRect().height
e.style.paddingTop='0'
var l=d-e.getBoundingClientRect().height
e.style.borderTopWidth='0'
var s=d-e.getBoundingClientRect().height-l
e.style.paddingBottom='0'
var c=d-e.getBoundingClientRect().height-l-s
e.style.borderBottomWidth='0'
var u=d-e.getBoundingClientRect().height-l-s-c
return e.style.paddingTop=o,e.style.paddingBottom=n,e.style.borderTopWidth=r,e.style.borderBottomWidth=a,t.removeChild(e),{totalHeight:d,height:d-l-c-s-u,paddingTop:l,paddingBottom:c,borderTopWidth:s,borderBottomWidth:u}}},txtComponentMainVal:function(e,t){if(e){var o=+new Date
!function n(i){i-o<=0||e(i-o)?(window.requestAnimationFrame(n),o=i):t&&t()}(o)}else t&&t()},iWindow:function(e,t,o,n,r,a){if(e&&e.length){t=t||250,o=o||'pop',document.webkitHidden&&(n=!1,o='none')
for(var d=void 0,l=void 0,s=[],c=0,u=0;u<e.length;u++)for(var p=0;p<e[u].length;p++)(d=e[u][p])&&i.iApplicationExVal(d)&&((l=i.adjustWindow(d)).totalHeight>0?(s.push({element:d,height:d.style.height,paddingTop:d.style.paddingTop,paddingBottom:d.style.paddingBottom,borderTopWidth:d.style.borderTopWidth,borderBottomWidth:d.style.borderBottomWidth,overflowY:d.style.getPropertyValue('overflow-y'),opacity:d.style.opacity,metrics:l,speed:t/l.totalHeight,totalElementHeight:l.totalHeight,resetActiveWindow:!1}),r&&r.length&&(s[s.length-1].syncCurrentTab=r[c],c+1<r.length&&c++),d.style.setProperty('overflow-y','hidden'),d.style.borderTopWidth=l.borderTopWidth+'px',d.style.borderBottomWidth=l.borderBottomWidth+'px',d.style.paddingTop=l.paddingTop+'px',d.style.paddingBottom=l.paddingBottom+'px',d.style.height=l.height+'px','pop'==o&&d.classList.add('headerDataSaved')):d.parentNode.removeChild(d))
if(s.length){var f=!0,g=0
if(n){for(u=0;u<s.length;u++)g+=s[u].metrics.totalHeight
g=t/g}return function(e){var t=void 0
n?t=e/g:f=!0
for(var i=void 0,r=void 0,d=0,l=0;l<s.length&&((i=s[l]).resetActiveWindow||(n||(t=e/i.speed),t=parseFloat(t.toFixed(10))+d,i.totalElementHeight-=t,r=i.element.style,(i.resetActiveWindow=i.totalElementHeight<=0)||document.webkitHidden?i.syncCurrentTab?(r.height=i.height,r.paddingTop=i.paddingTop,r.paddingBottom=i.paddingBottom,r.borderTopWidth=i.borderTopWidth,r.borderBottomWidth=i.borderBottomWidth,r.setProperty('overflow-y',i.overflowY),r.opacity=i.opacity,i.element.classList.add(i.syncCurrentTab)):i.element.parentNode.removeChild(i.element):('fade'==o&&(r.opacity=(''===i.opacity?1:i.opacity)*i.totalElementHeight/i.metrics.totalHeight),t>0&&parseFloat(r.borderBottomWidth)>0&&(t>=parseFloat(r.borderBottomWidth)?(t-=parseFloat(r.borderBottomWidth),r.borderBottomWidth='0'):(r.borderBottomWidth=parseFloat(r.borderBottomWidth)-t+'px',t=0)),t>0&&parseFloat(r.paddingBottom)>0&&(t>=parseFloat(r.paddingBottom)?(t-=parseFloat(r.paddingBottom),r.paddingBottom='0'):(r.paddingBottom=parseFloat(r.paddingBottom)-t+'px',t=0)),t>0&&parseFloat(r.height)>0&&(t>=parseFloat(r.height)?(t-=parseFloat(r.height),r.height='0'):(r.height=parseFloat(r.height)-t+'px',t=0)),t>0&&parseFloat(r.paddingTop)>0&&(t>=parseFloat(r.paddingTop)?(t-=parseFloat(r.paddingTop),r.paddingTop='0'):(r.paddingTop=parseFloat(r.paddingTop)-t+'px',t=0)),t>0&&parseFloat(r.borderTopWidth)>0&&(t>=parseFloat(r.borderTopWidth)?(t-=parseFloat(r.borderTopWidth),r.borderTopWidth='0'):(r.borderTopWidth=parseFloat(r.borderTopWidth)-t+'px',t=0)),d=t),!n));l++)n||(f=f&&i.resetActiveWindow)
if(document.webkitHidden||n&&l===s.length||!n&&f)return a&&a(),!1}}a&&a()}else a&&a()},iObject:function(e,t,o,n,r,a,d){if(e&&e.length&&t){o=o||150,r=r||'pop',document.webkitHidden&&(a=!1,r='none')
for(var l=void 0,s=void 0,c=void 0,u=[],p=0,f=0;f<e.length;f++)for(var g=0;g<e[f].length;g++)(l=e[f][g])&&(s=i.adjustWindow(l,t),c=i.iApplicationExVal(l),s.totalHeight>0&&(u.push({element:l,height:l.style.height,paddingTop:l.style.paddingTop,paddingBottom:l.style.paddingBottom,borderTopWidth:l.style.borderTopWidth,borderBottomWidth:l.style.borderBottomWidth,overflowY:l.style.getPropertyValue('overflow-y'),opacity:l.style.opacity,metrics:s,speed:o/s.totalHeight,isDOMElement:c,totalElementHeight:0,resetActiveWindow:!1}),l.style.setProperty('overflow-y','hidden'),l.style.height='0',l.style.paddingTop='0',l.style.paddingBottom='0',l.style.borderTopWidth='0',l.style.borderBottomWidth='0','fade'!=r&&'pop'!=r||(l.style.opacity='0')),c||(n&&n.length?(t.insertBefore(l,n[p]),p+1<n.length&&p++):t.appendChild(l)))
if(u.length){var h=!0,m=0
if(a){for(f=0;f<u.length;f++)m+=u[f].metrics.totalHeight
m=o/m}return function(e){var t=void 0
a?t=e/m:h=!0
for(var o=void 0,n=void 0,i=0,l=0;l<u.length&&((o=u[l]).resetActiveWindow||(a||(t=e/o.speed),t=parseFloat(t.toFixed(10))+i,o.totalElementHeight+=t,n=o.element.style,(o.resetActiveWindow=o.totalElementHeight>o.metrics.totalHeight)||document.webkitHidden?(n.height=o.height,n.paddingTop=o.paddingTop,n.paddingBottom=o.paddingBottom,n.borderTopWidth=o.borderTopWidth,n.borderBottomWidth=o.borderBottomWidth,n.setProperty('overflow-y',o.overflowY),n.opacity=o.opacity):('fade'==r&&(n.opacity=(''===o.opacity?1:o.opacity)*o.totalElementHeight/o.metrics.totalHeight),t>0&&parseFloat(n.borderTopWidth)<o.metrics.borderTopWidth&&(t>=o.metrics.borderTopWidth-parseFloat(n.borderTopWidth)?(t-=o.metrics.borderTopWidth-parseFloat(n.borderTopWidth),n.borderTopWidth=o.metrics.borderTopWidth+'px'):(n.borderTopWidth=parseFloat(n.borderTopWidth)+t+'px',t=0)),t>0&&parseFloat(n.paddingTop)<o.metrics.paddingTop&&(t>=o.metrics.paddingTop-parseFloat(n.paddingTop)?(t-=o.metrics.paddingTop-parseFloat(n.paddingTop),n.paddingTop=o.metrics.paddingTop+'px'):(n.paddingTop=parseFloat(n.paddingTop)+t+'px',t=0)),t>0&&parseFloat(n.height)<o.metrics.height&&(t>=o.metrics.height-parseFloat(n.height)?(t-=o.metrics.height-parseFloat(n.height),n.height=o.metrics.height+'px'):(n.height=parseFloat(n.height)+t+'px',t=0)),t>0&&parseFloat(n.paddingBottom)<o.metrics.paddingBottom&&(t>=o.metrics.paddingBottom-parseFloat(n.paddingBottom)?(t-=o.metrics.paddingBottom-parseFloat(n.paddingBottom),n.paddingBottom=o.metrics.paddingBottom+'px'):(n.paddingBottom=parseFloat(n.paddingBottom)+t+'px',t=0)),t>0&&parseFloat(n.borderBottomWidth)<o.metrics.borderBottomWidth&&(t>=o.metrics.borderBottomWidth-parseFloat(n.borderBottomWidth)?(t-=o.metrics.borderBottomWidth-parseFloat(n.borderBottomWidth),n.borderBottomWidth=o.metrics.borderBottomWidth+'px'):(n.borderBottomWidth=parseFloat(n.borderBottomWidth)+t+'px',t=0)),i=t),!a));l++)a||(h=h&&o.resetActiveWindow)
if(document.webkitHidden||a&&l===u.length||!a&&h)return d&&d(),!1}}d&&d()}else d&&d()}}
t.default=i},24:function(e,t,o){'use strict'
function n(e){return e&&e.__esModule?e:{default:e}}function i(e,t,o){return t?(o?'; \n':'')+e+': '+t:''}function r(e){switch(e){case 0:return'UNKNOWN_ERR'
case 1:return'DATABASE_ERR'
case 2:return'VERSION_ERR'
case 3:return'TOO_LARGE_ERR'
case 4:return'QUOTA_ERR'
case 5:return'SYNTAX_ERR'
case 6:return'CONSTRAINT_ERR'
case 7:return'TIMEOUT_ERR'}return'(unknown)'}var a=n(o(2)),d=n(o(1)).default.ptab17(),l=a.default.win9()
if(d){var s=d.ptab16(),c=void 0,u=void 0,p=void 0
p=a.default.addTitle()>1?s.iExpectStatusVal?'logo_32x32_err.png':'logo_32x32.png':s.iExpectStatusVal?'logo_16x16_err.png':'logo_16x16.png',document.write('<link id="favIcon" rel="icon" href="images/logo/'+p+'" />'),l('refresh').style.display='none',l('iOrderStringVal').addEventListener('click',function(){d.matchTextVal(c)&&(l('tabDataInject').classList.add('transposeTab'),clearTimeout(u),u=setTimeout(function(){l('tabDataInject').classList.remove('transposeTab')},300))}),s.iExpectStatusVal?(c=function(e){var t=''
if(t+=i('Date',e?e.dateTime:new Date,t),t+=i('Platform',navigator.platform,t),t+=i('OS',a.default.os,t),t+=i('User Agent',navigator.userAgent,t),t+=i('Pixel Ratio',a.default.addTitle(),t),t+=i('Language',navigator.language,t),t+=i('SB ID',chrome.app.getDetails().id,t),t+=i('SB Version',chrome.app.getDetails().version,t),e){if(t+=i('Source',e.source,t),e.exception){var o
e.exception.DATABASE_ERR?(t+=i('Type','SQLError',t),e.exception.code&&(o=' ['+r(e.exception.code)+']')):e.exception.type&&(t+=i('Type',e.exception.type,t)),t+=i('Code',(e.exception.code||'')+(o||''),t),t+=i('Message',e.exception.message,t),t+=i('Name',e.exception.name,t),t+=i('Stack',e.exception.stack,t)}e.exception&&e.exception.stack||(t+=i('Stack',e.trace,t)),console.log('Application Exception',e)}return t}(s.iExpectStatusVal),l('body').classList.add('error'),l('header').classList.add('handleExceptions'),l('iRegisterValue2Val').src='images/logo/logo_38x38_err.png',l('evalRequestHonored').textContent='Session Buddy seems to have encountered an error'+(d.updateTabUrl()?'':' preventing it from starting')+'.',l('augmentActiveSessionTab').textContent='To get help with this error, try the following:',l('bd').style.display='none',l('rDetail').style.display='none',l('bnd').style.display='inline',l('tatePanel').style.display='block',l('l1').href=l('l2').href='mailto:support@sessionbuddy.com?subject=Session Buddy Error&body='+escape('Please include a description of the problem to help us troubleshoot it.\n\n\n------------ Diagnostic Details Follow ------------\n')+escape(c)):(l('evalRequestHonored').textContent='Good news. Session Buddy seems to be running fine.',l('augmentActiveSessionTab').textContent='If you ever experience a technical problem with Session Buddy, try the following:',l('bd').style.display='inline',l('rDetail').style.display='inline',l('bnd').style.display='none'),d.updateTabUrl()&&(s.iExpectStatusVal=null,d.showTab())}else l('bAppImport').addEventListener('click',function(){return window.location.reload()})}})
