/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
var PLAYGROUND_WIDTH  = 700;
var PLAYGROUND_HEIGHT  = 250;
var REFRESH_RATE    = 15;

var GRACE    = 2000;
var MISSILE_SPEED = 10; 

var playerAnimation = new Array();
var missile = new Array();
var asteroid = new Array();
var playerHit = false;
var timeOfRespawn = 0;
var gameOver = false;

function restartgame(){
  window.location.reload();
};

function explodePlayer(playerNode){
  playerNode.children().hide();
  playerNode.addSprite("explosion",{animation: playerAnimation["explode"], width: 95, height: 22})
  playerHit = true;
};

function fireThruster(fire) {
  // thruster.mute seems to not work on Firefox
  if (fire) {
    thruster.volume(1);
  } else {
    thruster.volume(0);
  }
}

var sounds, thruster;
function initializeSound() {
  thruster = new Howl({
    urls: ['thruster.wav','thruster.mp3','thruster.ogg'],
    loop: true,
  });
  sounds = new Howl({
    urls: ['sounds.wav','sounds.mp3','sounds.ogg'],
    sprite: {
      asteroid: [0, 340],
      ship: [351, 1040],
      missile: [1400, 289]
    }
  });
  thruster.play();
  fireThruster(false);
};

$(function(){
  playerAnimation["idle"]    = new $.gQ.Animation({imageURL: "player_spaceship.png"});
  playerAnimation["explode"]  = new $.gQ.Animation({imageURL: "player_explode.png", numberOfFrame: 4, delta: 22, rate: 60, type: $.gQ.ANIMATION_VERTICAL | $.gQ.ANIMATION_CALLBACK});
  playerAnimation["up"]    = new $.gQ.Animation({imageURL: "boosterup.png", numberOfFrame: 6, delta: 14, rate: 60, type: $.gQ.ANIMATION_HORIZONTAL});
  playerAnimation["down"]    = new $.gQ.Animation({imageURL: "boosterdown.png", numberOfFrame: 6, delta: 14, rate: 60, type: $.gQ.ANIMATION_HORIZONTAL});
  playerAnimation["boost"]  = new $.gQ.Animation({imageURL: "booster1.png" , numberOfFrame: 6, delta: 14, rate: 60, type: $.gQ.ANIMATION_VERTICAL});
  playerAnimation["booster"]  = new $.gQ.Animation({imageURL: "booster2.png", numberOfFrame: 6, delta: 14, rate: 60, type: $.gQ.ANIMATION_VERTICAL});
  
  missile["player"] = new $.gQ.Animation({imageURL: "player_missile.png"});
  missile["explode"] = new $.gQ.Animation({imageURL: "player_missile_explode.png" , numberOfFrame: 4, delta: 22, rate: 90, type: $.gQ.ANIMATION_VERTICAL | $.gQ.ANIMATION_CALLBACK});

  asteroid["idle"]  = new $.gQ.Animation({imageURL: "asteroid.png", numberOfFrame: 3, delta: 48, rate: 300, type: $.gQ.ANIMATION_VERTICAL});
  asteroid["explode"]  = new $.gQ.Animation({imageURL: "asteroid_explosion.png", numberOfFrame: 3, delta: 48, rate: 40, type: $.gQ.ANIMATION_VERTICAL | $.gQ.ANIMATION_CALLBACK });
  
  $("#playground").playground({height: PLAYGROUND_HEIGHT, width: PLAYGROUND_WIDTH, keyTracker: true});
        
  $.playground().addGroup("actors", {width: PLAYGROUND_WIDTH, height: PLAYGROUND_HEIGHT})
            .addGroup("player", {posx: PLAYGROUND_WIDTH/2, posy: PLAYGROUND_HEIGHT/2, width: 95, height: 22})
              .addSprite("playerBoostUp", {posx:36, posy: 15, width: 14, height: 18})
              .addSprite("playerBody",{animation: playerAnimation["idle"], posx: 0, posy: 0, width: 95, height: 22})
              .addSprite("playerBooster", {animation:playerAnimation["boost"], posx:-32, posy: 12, width: 36, height: 14})
              .addSprite("playerBoostDown", {posx:36, posy: -2, width: 14, height: 18})
            .end()
          .end()
          .addGroup("playerMissileLayer",{width: PLAYGROUND_WIDTH, height: PLAYGROUND_HEIGHT}).end()
  
  $("#player")[0].player = new Player($("#player"));
  
  $("#startbutton").click(function(){
    $.playground().startGame(function(){
      $("#welcomeScreen").fadeTo(1000,0,function(){$(this).remove();});
    });
  })
  
  $.playground().registerCallback(function(){
    if(!gameOver){
      if(!playerHit){
        $("#player")[0].player.update();
        if(jQuery.gameQuery.keyTracker[65]){ 
          var nextpos = $("#player").x()-5;
          if(nextpos > 0){
            $("#player").x(nextpos);
          }
        }
        if(jQuery.gameQuery.keyTracker[68]){
          var nextpos = $("#player").x()+5;
          if(nextpos < PLAYGROUND_WIDTH - 100){
            $("#player").x(nextpos);
          }
        }
        if(jQuery.gameQuery.keyTracker[87]){
          var nextpos = $("#player").y()-3;
          if(nextpos > 0){
            $("#player").y(nextpos);
          }
        }
        if(jQuery.gameQuery.keyTracker[83]){ 
          var nextpos = $("#player").y()+3;
          if(nextpos < PLAYGROUND_HEIGHT - 30){
            $("#player").y(nextpos);
          }
        }
      } else {
        var posy = $("#player").y()+5;
        var posx = $("#player").x()-5;
        if(posy > PLAYGROUND_HEIGHT){
          if($("#player")[0].player.respawn()){
            gameOver = true;
            $("#playground").append('<div style="position: absolute; top: 50px; width: 700px; color: white; font-family: verdana, sans-serif;"><center><h1>Game Over</h1><br><a style="cursor: pointer;" id="restartbutton">Click here to restart the game!</a></center></div>');
            $("#restartbutton").click(restartgame);
            $("#actors,#playerMissileLayer").fadeTo(1000,0);
            $("#background").fadeTo(5000,0);
          } else {
            $("#explosion").remove();
            $("#player").children().show();
            $("#player").y(PLAYGROUND_HEIGHT / 2);
            $("#player").x(PLAYGROUND_WIDTH / 2);
            playerHit = false;
          }
        } else {
          $("#player").y(posy);
          $("#player").x(posx);
        }
      }

      $(".asteroid").each(function(){
        this.asteroid.update();
        var posx = $(this).x();
        if((posx + 100) < 0){
          $(this).remove();
          return;
        }
        var collided = $(this).collision("#playerBody,."+$.gQ.groupCssClass);
        if(collided.length > 0){
          $(this).setAnimation(asteroid["explode"], function(node){$(node).remove();});
          $(this).removeClass("asteroid");
          if($("#player")[0].player.damage()){
            explodePlayer($("#player"));
          }
          sounds.play('ship');
        }
      });

      $(".playerMissiles").each(function(){
        var posx = $(this).x();
        if(posx > PLAYGROUND_WIDTH){
          $(this).remove();
          return;
        }
        $(this).x(MISSILE_SPEED, true);
        var groupName = ".asteroid,." + $.gQ.groupCssClass;
        var collided = $(this).collision(groupName);
        if(collided.length > 0){
          collided.each(function(){
            $(this).setAnimation(asteroid["explode"],function(node){$(node).remove();});
            $(this).removeClass("asteroid");
          });
          $(this).setAnimation(missile["explode"],function(node){$(node).remove();});
          $(this).removeClass("playerMissiles");
          sounds.play('asteroid');
        }
      });
    }
  }, REFRESH_RATE);
  
  $.playground().registerCallback(function(){
    if(!gameOver){
      if (Math.random() < 0.8){
        var name = "asteroid_"+Math.ceil(Math.random()*1000);
        $("#actors").addSprite(name, {animation: asteroid["idle"], posx: PLAYGROUND_WIDTH, posy: Math.random()*PLAYGROUND_HEIGHT,width: 48, height: 48});
        $("#"+name).addClass("asteroid");
        $("#"+name)[0].asteroid = new Asteroid($("#"+name));
      }
    }
  }, 1000);
  
  $(document).keydown(function(e){
    if(!gameOver && !playerHit){
      switch(e.keyCode){
      case 75:
      case 32:
        var playerposx = $("#player").x();
        var playerposy = $("#player").y();
        var name = "playerMissile_"+Math.ceil(Math.random()*1000);
        var options = {
          animation: missile["player"],
          posx: playerposx + 90,
          posy: playerposy + 14,
          width: 22, height: 10
        };
        $("#playerMissileLayer").addSprite(name,options);
        $("#"+name).addClass("playerMissiles");
        sounds.play('missile');
        break;
      case 65: 
        $("#playerBooster").setAnimation();
        fireThruster(true);
        break;
      case 87:
        $("#playerBoostUp").setAnimation(playerAnimation["up"]);
        fireThruster(true);
        break;
      case 68:
        $("#playerBooster").setAnimation(playerAnimation["booster"]);
        fireThruster(true);
        break;
      case 83:
        $("#playerBoostDown").setAnimation(playerAnimation["down"]);
        fireThruster(true);
        break;
      }
    }
  });
  $(document).keyup(function(e){
    if(!gameOver && !playerHit){
      switch(e.keyCode){
        case 65:
          $("#playerBooster").setAnimation(playerAnimation["boost"]);
          fireThruster(false);
          break;
        case 87:
          $("#playerBoostUp").setAnimation();
          fireThruster(false);
          break;
        case 68:
          $("#playerBooster").setAnimation(playerAnimation["boost"]);
          fireThruster(false);
          break;
        case 83:
          $("#playerBoostDown").setAnimation();
          fireThruster(false);
          break;
      }
    }
  });

  initializeSound();
}); 
