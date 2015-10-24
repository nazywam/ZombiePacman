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

class PlayState extends FlxState
{

	var actors : Array<Actor>;
	var grid : Array<Array<Tile>>;
	var collectibles : Array<Array<Collectible>>;

	var socket : Socket;
	var clientId : Int;
	var playersNumber : Int;

	public static var ONLINE : Bool = false;

	public static var host:String;
	public static var port:Int;

	override public function new(){
		super();
		host = "10.10.97.146";
		port = 8888;
	}

	override public function create():Void
	{
		super.create();
		//FlxG.log.redirectTraces = true;
		FlxG.autoPause = false;

		actors = new Array<Actor>();

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
			loadMap("assets/data/level" + selectedMap + ".txt");
			trace("Map: ", selectedMap);

			var playerPos = getLine().split(":");
			for(i in 0...playerPos.length){
				var xy = playerPos[i].split("x");
				var a = new Actor(Std.parseInt(xy[0]), Std.parseInt(xy[1]));
				actors.push(a);
				add(a);
			} 
		} else {
			loadMap("assets/data/level"+Std.string(Std.random(10))+".txt");
			clientId = 0;
			var a = new Actor(1, 1);
			actors.push(a);
			add(a);
		}
		tick();


		actors[0].die();
	}

	function getLine(){
		for(y in 0...123456789){
			var a = "";

			try {
				var tmp = socket.input.readLine();
				trace(tmp);
				return  tmp;
			}
			catch (e:Dynamic){
			}
		}
		return "";
	}

	public function loadMap(mapPath:String){
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
					if(Std.random(10) == 0){
						value = 1;
					}
					if(Std.random(20) == 0){
						value = 2;
					}

					var c = new Collectible(r, l, value);
					add(c);
					collectibles[l][r] = c;
				}
			}
		}
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

	function validMove(a:Actor, d:Int){

		var tmp = getDirectionTurn(d);
		if(getTile(a.gridPos.y + tmp[1], a.gridPos.x + tmp[0]).tileId != 0){
			return false;
		}
		return true;

		/*
		switch (d) {
			case FlxObject.UP:
				if(getTile(a.gridPos.y-1, a.gridPos.x).tileId !=  0){
					return false;
				}
			case FlxObject.RIGHT:
				if(getTile(a.gridPos.y, a.gridPos.x+1).tileId !=  0){
					return false;
				}
			case FlxObject.DOWN:
				if(getTile(a.gridPos.y+1, a.gridPos.x).tileId !=  0){
					return false;
				}
			case FlxObject.LEFT:
				if(getTile(a.gridPos.y, a.gridPos.x-1).tileId !=  0){
					return false;
				}
		}
		return true;
		*/
	}

	function crossPaths(a:Actor, b:Actor):Bool{
		var tmpA = getDirectionTurn(a.pressedDirection);
		var tmpB = getDirectionTurn(b.pressedDirection);

		return((a.gridPos.x + tmpA[0]) == (b.gridPos.x + tmpB[0]) && (a.gridPos.y + tmpA[1]) == (b.gridPos.y + tmpB[1]));
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

			if(a.isDead){
				for(b in actors){
					if(a != b && !b.isDead && crossPaths(a, b)){
						b.die();
					}
				}
			}

			a.tick();

			var gridY = Std.int(a.gridPos.y);
			var gridX = Std.int(a.gridPos.x);

			if(collectibles[gridY][gridX] != null && !collectibles[gridY][gridX].taken && !a.isDead){
				collectibles[gridY][gridX].taken = true;
				collectibles[gridY][gridX].visible = false;

				if(collectibles[gridY][gridX].value == 2){
					FlxG.camera.color = 0xFF000000 + Std.random(0xFFFFFF);
				}
			}


		}

		var t = new FlxTimer();
		t.start(Settings.TICK_TIME, function(_){
			preTick();
		});
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
	}	
}