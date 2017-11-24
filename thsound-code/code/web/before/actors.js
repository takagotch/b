/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
function Player(node){

	this.node = node;

	this.grace = false;
	this.replay = 3; 
	this.shield = 3; 
	this.respawnTime = -1;
	
	this.damage = function(){
		if(!this.grace){
			this.shield--;
			if (this.shield == 0){
				return true;
			}
			return false;
		}
		return false;
	};
	
	this.respawn = function(){
		this.replay--;
		if(this.replay==0){
			return true;
		}
		
		this.grace 	= true;
		this.shield	= 3;
		
		this.respawnTime = (new Date()).getTime();
		$(this.node).fadeTo(0, 0.5); 
		return false;
	};
	
	this.update = function(){
		if((this.respawnTime > 0) && (((new Date()).getTime()-this.respawnTime) > 3000)){
			this.grace = false;
			$(this.node).fadeTo(500, 1); 
			this.respawnTime = -1;
		}
	}
	
	return true;
}

function Asteroid(node){

	this.speedx	= -5;
	this.speedy	= 0;
	this.node = $(node);

	this.update = function(){
		this.updateX();
		this.updateY();
	};	
	this.updateX = function(){
		this.node.x(this.speedx, true);
	};
	this.updateY= function(){
		var newpos = parseInt(this.node.css("top"))+this.speedy;
		this.node.y(this.speedy, true);
	};
  return true;
}

