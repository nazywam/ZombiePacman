package;

import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;
import openfl.Assets;
import openfl.utils.ByteArray;
import sys.net.Host;
import sys.net.Socket;
import flixel.text.FlxText.FlxTextAlign;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
class PlayState extends FlxState
{

	var actors : Array<Actor>;
	var grid : Array<Array<Tile>>;
	var collectibles : Array<Array<Collectible>>;

	var collectiblesG : FlxTypedGroup<Collectible>;

	var socket : Socket;
	var clientId : Int;
	var playersNumber : Int;


	var gameFinished:Bool = false;

	public static var ONLINE : Bool = true;

	public static var host:String;
	public static var port:Int;


	var scoreText : FlxText;
	var score : Int = 0;

	var coinsToCollect:Int = 0;

	var ghostsBlinks:Int = 0;

	var winnerText:FlxText;

	var bestActor:Actor;

	var items:String;

	override public function new(){
		super();
		host = "10.10.97.146";
		port = 9911;
	}

	override public function create():Void
	{
		super.create();
		//FlxG.log.redirectTraces = true;
		FlxG.autoPause = false;

		actors = new Array<Actor>();
		collectiblesG = new FlxTypedGroup<Collectible>();
		add(collectiblesG);

		if(ONLINE){

			socket = new Socket();
			socket.setTimeout(1);
			try {
				socket.connect(new Host(host), port);
			} 
			catch(e:Dynamic){
				trace("Couldn't connect to server");
			}
			socket.output.writeString("READY");
			socket.output.flush();

			var tmp = getLine().split(':');

			clientId = Std.parseInt(tmp[1]);
			var selectedMap = Std.parseInt(tmp[2]);

			var playerPos = getLine().split(":");
			for(i in 0...playerPos.length){
				var xy = playerPos[i].split("x");
				var a = new Actor(Std.parseInt(xy[0]), Std.parseInt(xy[1]), i);
				actors.push(a);
				add(a);
			} 

			items = getLine();

			loadMap("assets/data/level" + selectedMap + ".txt");

		} else {
			loadMap("assets/data/level"+Std.random(6)+".txt");
			clientId = 0;
			var a = new Actor(1, 1, 0);
			actors.push(a);
			add(a);
		}
		scoreText = new FlxText(0, 4, FlxG.width, getScore(), 16);
		scoreText.alignment = FlxTextAlign.CENTER;
		scoreText.color = 0xFFFFFF00;
		add(scoreText);

		actors[0].die();

		tick();
	}

	function getLine(){
		for(y in 0...123456789){
			var a = "";

			try {
				var tmp = socket.input.readLine();
				return  tmp;
			}
			catch (e:Dynamic){
			}
		}
		return "";
	}

	function getBestActor(){
		var maxPoints:Int = -1;
		var best:Actor = null;

		for(a in actors){
			if(a.score > maxPoints){
				maxPoints = a.score;
				best = a;
			}
		}

		return best;
	}

	function finishGame(){
		if(!gameFinished){
			bestActor = getBestActor();

			FlxG.camera.flash();
			FlxG.camera.follow(bestActor);

			winnerText = new FlxText(0, 0, FlxG.width, "WINNER", 16);
			winnerText.alignment = FlxTextAlign.CENTER;
			winnerText.color = 0xFFFFFF00; 
			winnerText.alpha = 0;
			add(winnerText);

			gameFinished = true;
		}
	}

	function blinkGhosts(i:Int){
		for(a in actors){
			if(a.isDead){
				if(i == 0){
					a.color = 0xFFFFFFFF;
				}else if(i%2==0){
					a.color = 0xFFFF00FF;
				} else {
					a.color = 0xFFFFFF00;
				}
			}
		}

		if(i > 0){
			var t = new FlxTimer();
			t.start(.5, function(_){
				blinkGhosts(i-1);
			});
		} else {
			ghostsBlinks--;
		}
	}

	function loadMap(mapPath:String){
		var _map = Assets.getText(mapPath);
		var _lines =_map.split('\n');

		collectibles = new Array<Array<Collectible>>();
		grid = new Array<Array<Tile>>();

		for(l in 0..._lines.length){
			grid[l] = new Array<Tile>();
			collectibles[l] = new Array<Collectible>();

			var _rows = _lines[l].split(',');
			for(r in 0..._rows.length){
				var t = new Tile(r, l, Std.parseInt(_rows[r]));
				add(t);
				if(Std.parseInt(_rows[r]) != 0){
					add(t.gibs);	
				}
				grid[l].push(t);

				collectibles.push(null);

				if(Std.parseInt(_rows[r]) == 0){

					var value = 0;

					switch(items.charAt(l * _rows.length + r)){
						case '0':
							coinsToCollect++;
						case '1':
							value = 1;
							coinsToCollect++;
						case '2':
							value = 2;
					}

					var c = new Collectible(r, l, value);
					collectiblesG.add(c);
					collectibles[l][r] = c;
				}
			}
		}
	}
	
	function getScore():String{
		var s = Std.string(actors[clientId].score);
		while(s.length < 8){
			s = '0'+s;
		}
		return s;
	}

	function getTile(_y:Float, _x:Float){
		return grid[Std.int(_y)][Std.int(_x)];
	}

	public function preTick(){
		if(ONLINE){
			socket.output.writeString(Std.string(clientId)+':'+Std.string(actors[clientId].pressedDirection));
			socket.output.flush();

			var d = getLine();
			var directions = d.split(":");
			for(i in 0...directions.length){
				actors[i].pressedDirection = Std.parseInt(directions[i]);
			}
		}
		tick();
	}

	function updateScore(){
		scoreText.text = getScore();

		FlxTween.tween(scoreText, {y:-1}, .1, {ease:FlxEase.bounceOut});

		var t = new FlxTimer();
		t.start(.1, function(_){
			FlxTween.tween(scoreText, {y:4}, .1, {ease:FlxEase.bounceInOut});
		});
	}

	function validMove(a:Actor, d:Int){

		var tmp = getDirectionTurn(d);
		if(getTile(a.gridPos.y + tmp[1], a.gridPos.x + tmp[0]).tileId != 0){
			return false;
		}
		return true;
	}

	function crossPaths(a:Actor, b:Actor):Bool{
		var tmpA = getDirectionTurn(a.pressedDirection);
		var tmpB = getDirectionTurn(b.pressedDirection);

		if(a.gridPos.x == b.gridPos.x && a.gridPos.y == b.gridPos.y){
			return true;
		}

		if(a.gridPos.x - tmpA[0] == b.gridPos.x - tmpB[0] && a.gridPos.y - tmpA[1] == b.gridPos.y - tmpB[1] && a.couldMove && b.couldMove){
			return true;	
		}		

		return false;
	}

	function getDirectionTurn(direction:Int){
		switch (direction) {
			case FlxObject.UP:
				return [0, -1];
			case FlxObject.RIGHT:
				return [1, 0];
			case FlxObject.DOWN:
				return [0, 1];
			case FlxObject.LEFT:
				return [-1, 0];
		}
		return [0, 0];
	}

	public function tick(){

		for(a in actors){
			if(!validMove(a, a.pressedDirection)){
				if(validMove(a, a.previousPressedDirection)){
					a.pressedDirection = a.previousPressedDirection;
				} else {
					a.canMove = false;
				}
			}
			a.tick();

			if(a.isDead){
				for(b in actors){
					if(a != b  && crossPaths(a, b) && !b.isDead){
						if(ghostsBlinks > 0){
							a.visible = false;
							a.solid = false;
							b.score += 10000;
							if(b.ID == clientId){
								updateScore();
							}
						} else {
							b.die();
							a.score += 10000;
							if(a.ID == clientId){
								updateScore();
							}	
						}
					}
				}
			}

			var gridY = Std.int(a.gridPos.y);
			var gridX = Std.int(a.gridPos.x);

			if(collectibles[gridY][gridX] != null && !collectibles[gridY][gridX].taken && !a.isDead){
				collectibles[gridY][gridX].taken = true;
				collectibles[gridY][gridX].visible = false;

				switch (collectibles[gridY][gridX].value) {
					case 0:
						a.score += 100;
						coinsToCollect--;

						if(a.ID == clientId){
							updateScore();
						}
					case 1:
						a.score += 5000;
						coinsToCollect--;
						ghostsBlinks++;
						blinkGhosts(12);

						if(a.ID == clientId){
							updateScore();
						}
					case 2:
						if(a.ID == clientId){
							FlxG.camera.color = 0xFFFAFAFA + Std.random(0x0050000) + Std.random(0x0000500) + Std.random(0x0000005);
						}
				}
			}
		}

		if(!anyPacmanAlive() || coinsToCollect == 0 || !morePacmanExist()){
			finishGame();
		}

		var t = new FlxTimer();
		t.start(Settings.TICK_TIME, function(_){
			preTick();
		});
	}

	function morePacmanExist(){
		var s:Int = 0;

		for(a in actors){
			if(a.visible){
				s++;
			}
		}
		return s > 1;
	}

	function anyPacmanAlive(){
		for(a in actors){
			if(!a.isDead){
				return true;
			}
		}
		return false;
	}


	function handleKeys(){
		if(FlxG.keys.justPressed.UP){
			actors[clientId].pressedDirection = FlxObject.UP;
		}
		if(FlxG.keys.justPressed.RIGHT){
			actors[clientId].pressedDirection = FlxObject.RIGHT;	
		}

		if(FlxG.keys.justPressed.DOWN){
			actors[clientId].pressedDirection = FlxObject.DOWN;
		}

		if(FlxG.keys.justPressed.LEFT){
			actors[clientId].pressedDirection = FlxObject.LEFT;
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		handleKeys();
		if(gameFinished){
			FlxG.camera.setScale(Math.min(3, FlxG.camera.scaleX + .01), Math.min(3, FlxG.camera.scaleY + .01));
			winnerText.x = bestActor.x + bestActor.width/2 - winnerText.width/2;
			winnerText.y = bestActor.y - bestActor.height - 4;
			winnerText.alpha = Math.min(1, winnerText.alpha += 0.01);
		}
	}	
}