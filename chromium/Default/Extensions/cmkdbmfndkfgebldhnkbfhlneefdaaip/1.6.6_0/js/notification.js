var WRS_BROWSER = (chrome || browser);
var IS_DEBUG = false;
var GET_NOTIFICATION_MESSAGE = "getNotificationMessage"; // Dependecy 
var createTags = {
	hostname : null,
	notificationName : null,
	templateSettings : null,
	containerTag : null,
	init : function(hostname, notificationName, templateSettings){
		this.hostname = hostname;
		this.notificationName = notificationName;
		this.templateSettings = templateSettings;
		this.appendNotificationCssFile();
		var bodyTag = this.getBodyTag();
		var containerTag = this.getContainerTag();
		containerTag.className = "fade-in";
		containerTag.style.visibility = "hidden";
		var containerHeaderTag = this.getContainerHeaderTag();
		var containerBodyTag = this.getContainerBodyTag();
		var containerFooterTag = this.getContainerFooterTag();
		containerTag.appendChild(containerHeaderTag);
		containerTag.appendChild(containerBodyTag);
		containerTag.appendChild(containerFooterTag);
		bodyTag.appendChild(containerTag);
		
		var self = this;
		self.containerTag = containerTag;
		self.applyTemplateSettings();
		self.appendClickEvent();
		setTimeout( function(){
			containerTag.style.visibility = 'visible';
			containerTag.className  += " md-show";
			self.hide();
		}, 2500);
	},
	applyTemplateSettings : function(){
		try{
			console.log(createTags.templateSettings);
			var settings = (typeof createTags.templateSettings != "object") ? JSON.parse(createTags.templateSettings) || {} : createTags.templateSettings;
			
			if(typeof settings.color != "undefined") createTags.containerTag.style.border = "1px solid "+settings.color;
		}catch(e){
			if(IS_DEBUG) console.log(e);
		}
	},
	appendClickEvent : function(){ 
		try{
			var element = document.getElementById('wrs-close');
			if(window.addEventListener)
				element.addEventListener('click', createTags.hideContainerTag , false);
			else if(window.attachEvent) 
				element.attachEvent('onclick', createTags.hideContainerTag);
		}catch(e){
			if(IS_DEBUG) console.log(e);
		}
	},
	hide : function(containerTag){
		setTimeout( function(){
			createTags.hideContainerTag();
		}, 7000);
	},
	hideContainerTag : function(){
		createTags.containerTag.className = "fade-in";
	},
	appendNotificationCssFile : function(){
		var head  = document.getElementsByTagName('head')[0];
    	var link  = document.createElement('link');
    	link.rel  = 'stylesheet';
    	link.type = 'text/css';
    	link.href = WRS_BROWSER.extension.getURL('css/notification.css');
    	link.media = 'all';
    	head.appendChild(link);
	},
	createDivTag : function(className){
		var tag = document.createElement("div");
		if(typeof className != "undefined") tag.className = className; 
		return tag;
	},
	assignId : function(tag, id){
		tag.id = id;
		return tag;
	},
	getBodyTag : function(){
		return document.getElementsByTagName('body')[0];
	},
	createTextNode : function(text){
		return document.createTextNode(text);
	},
	getContainerTag : function(){
		var tag = this.createDivTag();
		return this.assignId(tag, "wrs-container");
	},
	getContainerHeaderTag : function(){
		var headerTag = this.createDivTag("wrs-container-header");
		var imageDivTag = this.createDivTag("wrs-logo");
		var imageTag = document.createElement('img');
		imageTag.setAttribute("src", WRS_BROWSER.extension.getURL('images/Logo.png'));
		imageDivTag.appendChild(imageTag)
		headerTag.appendChild(imageDivTag);
		var closeDivTag = this.createDivTag("wrs-close");
		closeDivTag = this.assignId(closeDivTag, "wrs-close");
		var closeTag = document.createElement('img');
		closeTag.setAttribute("src", WRS_BROWSER.extension.getURL('images/close.svg'));
		closeDivTag.appendChild(closeTag);
		headerTag.appendChild(closeDivTag);
		return headerTag;
	},
	getContainerBodyTag : function(){
		var bodyTag = this.createDivTag("wrs-container-body");
		var bodyHeaderTag = this.createDivTag("wrs-container-body-header");
		var appTag = this.createDivTag('wrs-app');
		// var NotificationTextNode = this.createTextNode(this.notificationName);
		var notificationTag = this.createDivTag('wrs-notification-name');
		//notificationTag.appendChild(NotificationTextNode);
		var textNode = this.createTextNode("Yeah!! that's a lead.");
		var domainTag = this.createDivTag("wrs-domain-name");
		domainTag.appendChild(textNode);
		bodyHeaderTag.appendChild(notificationTag);
		bodyHeaderTag.appendChild(domainTag);
		bodyTag.appendChild(bodyHeaderTag)
		return bodyTag;
	},
	beautifyHostName : function(hostname){
		var arr = hostname.split(".");
		return arr.shift();
	},
	getContainerFooterTag : function(){
		var tag = this.createDivTag("wrs-container-footer");
		return tag;
	}
}


var Notification = function(){
	
}
Notification.prototype  =  {
	constructor : Notification,
	init : function(){
		self = this;
		this.getNotificationMessage()
	},
	strToJson : function(str){
		try{
			return JSON.parse(str);
		}catch(e){
		}
		return null;
	},
	getNotificationMessage : function(){
		
		try{	
			WRS_BROWSER.runtime.sendMessage({ id: GET_NOTIFICATION_MESSAGE }, function(res){
				self.processResponse(res);
			});
		}catch(e){
			if(IS_DEBUG) console.log(e);
		}
	},
	processResponse : function(responseData){
		try{
			if(responseData == null) return; 
			var siteResponse = self.strToJson( responseData.response );
			if(siteResponse && typeof siteResponse.notification_name != "undefined"){
				var data = responseData.data;
				var hostname = data.hostname;
				 
				self.createNotification(hostname, siteResponse.notification_name, siteResponse.template_settings);
			}
		}catch(e){
			if(IS_DEBUG) console.log(e);
		}
	},
	createNotification : function(hostname, notificationName, templateSettings){
		createTags.init(hostname, notificationName, templateSettings);
	}
	
}

var notificationInstance = new Notification();
notificationInstance.init();