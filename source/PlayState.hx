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

	var player : Player;
	var actors : Array<Actor>;
	var grid : Array<Array<Tile>>;

	var socket : Socket;
	var clientId : Int;
	var playersNumber : Int;

	public static var ONLINE : Bool = true;

	override public function create():Void
	{
		super.create();
		//FlxG.log.redirectTraces = true;
		

		actors = new Array<Actor>();

		if(ONLINE){

			socket = new Socket();
			socket.setTimeout(1);
			try {
				socket.connect(new Host("10.10.97.84"), 6659);
			} 
			catch(e:Dynamic){
				trace("Couldn't connect to server");
			}
			socket.output.writeString("READY");
			socket.output.flush();

			while(true){
				players = getLine();
				if(players == "START"){
					break;
				} else if (players != ""){
					trace(players, " player ready");
				}
			}
			var tmp = getLine().split(" ");

			var selectedMap:Int = Std.parseInt(tmp[0]);
			loadMap("assets/data/level" + selectedMap + ".txt");
			trace("Map: ", selectedMap);

			clientId = Std.parseInt(tmp[1]);
			trace("Client Id: ", clientId);

			var playerPos = getLine().split(" ");
			for(i in playerPos.length){
				var xy = playerPos[i].split("x");

				var player = new Player(Std.int(xy[0]), Std.int(xy[1]));
				actors.push(player);
				add(player);
			}
		}

		player = actors[clientId];
		tick();
	}

	function getLine(){
		for(y in 0...123456789){
			var a = "";

			try {
				a = socket.input.readLine();
			}
			catch (e:Dynamic){

			}

			return a;
		}
	}

	public function loadMap(mapPath:String){
		var _map = Assets.getText(mapPath);
		var _lines =_map.split('\n');

		grid = new Array<Array<Tile>>();

		for(l in 0..._lines.length){
			grid[l] = new Array<Tile>();

			var _rows = _lines[l].split(',');
			for(r in 0..._rows.length){
				var t = new Tile(r, l, Std.parseInt(_rows[r])-1);
				add(t);
				grid[l].push(t);
			}
		}
	}
	
	function getTile(_y:Float, _x:Float){
		return grid[Std.int(_y)][Std.int(_x)];
	}

	public function preTick(){
		if(ONLINE){
			socket.output.writeInt32(player.pressedDirection);
			socket.output.flush();

			var directions = getLine().split(" ");
			for(i in 0...directions.length){
				actors[i].pressedDirection = directions[i];
			}
		}

		tick();
	}

	public function tick(){
		for(a in actors){
			switch (a.pressedDirection) {
				case FlxObject.UP:
					if(getTile(a.gridPos.y-1, a.gridPos.x).tileId !=  0){
						if(a.previousPressedDirection != a.pressedDirection){
							a.pressedDirection = a.previousPressedDirection;
						} else {
							a.canMove = false;
							
						}
					}
				case FlxObject.RIGHT:
					if(getTile(a.gridPos.y, a.gridPos.x+1).tileId !=  0){
						if(a.previousPressedDirection != a.pressedDirection){
							a.pressedDirection = a.previousPressedDirection;
						} else {
							a.canMove = false;
							
						}
					}
				case FlxObject.DOWN:
					if(getTile(a.gridPos.y+1, a.gridPos.x).tileId !=  0){
						if(a.previousPressedDirection != a.pressedDirection){
							a.pressedDirection = a.previousPressedDirection;
						} else {
							a.canMove = false;
							
						}
					}
				case FlxObject.LEFT:
					if(getTile(a.gridPos.y, a.gridPos.x-1).tileId !=  0){
						if(a.previousPressedDirection != a.pressedDirection){
							a.pressedDirection = a.previousPressedDirection;
						} else {
							a.canMove = false;
							
						}
					}
			}
			a.tick();
		}

		var t = new FlxTimer();
		t.start(Settings.TICK_TIME, function(_){
			preTick();
		});
	}
		
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}	
}