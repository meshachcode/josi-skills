// Generated by CoffeeScript 1.6.3
(function(){var e;e=require("../class/skill.coffee");module.exports=function(t){var n,r=this;n="jokes";return t.brain.on("memories-loaded",function(r){if(r[n]&&t.skills)return t.skills[n]=new e(n,t)})}}).call(this);