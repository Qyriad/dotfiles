//this an initial implementation for Lightweight Metric processor

var $sessionId = "performanceSession"; //session is required by gwt, good enough for devs, but in production we might want something better
window.__gwtStatsEvent = function (e) {
  console.log(e.evtGroup + " | " + e.moduleName + " | " + e.subSystem + " | " + e.type + " | " + e.millis);
  return true;
};
