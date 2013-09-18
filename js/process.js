// Generated by CoffeeScript 1.6.3
(function(){var e,t,n;n=require("../class/tasks");t=require("../class/promises");e=require("../class/process");module.exports=function(r){var i,s;s=function(e,t,n){var r;r=t.replace(/\s/,"_");n=n.replace(/\s/,"_");return""+e.user.id+"_"+n+"_"+r};i=function(e,t,n){return e.skills[t]&&e.brain.get(t)?e.brain.get(t)[n]:!1};r.Response.prototype.process=function(o,u){var a,f,l,c,h,p;try{h=new t.Promise;(l=i(r,o,u))||h.reject("Could not validate skills");l.message=this.message;l.skill=o;l.topic=u;r.brain.tasks=r.brain.tasks||new n(r);f=s(this.message,u,o);(p=r.brain.tasks.get(f))||(p=r.brain.tasks.add(f,l));c=new e;c.init(p,r,this).done(function(e){r.brain.tasks.remove(f);return h.resolve(e)}).fail(function(e){return h.reject(e)});return h}catch(d){a=d;a.locale=__dirname;this.chatty("Trying to process "+o+" "+u);throw a}};r.respond(/show tasks$/i,function(e){var t;try{if(!r.brain.tasks)return e.send("I would love to, but there are none.");r.logger.info(r.brain.tasks.list());return e.send("Here you go.")}catch(n){t=n;t.locale=__dirname;e.chatty("Trying to run "+e.message.text);throw t}});r.respond(/clear tasks$/i,function(e){var t;try{if(!r.brain.tasks)return e.send("I would love to, but there are none.");r.logger.info(r.brain.tasks.clear().list());return e.send("Here you go.")}catch(n){t=n;t.locale=__dirname;e.chatty("Trying to run "+e.message.text);throw t}});return r.respond(/test process$/i,function(e){return e.send("I don't know how to do that yet. Care to teach me? ("+__dirname+")")})}}).call(this);