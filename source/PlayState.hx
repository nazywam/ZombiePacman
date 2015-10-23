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

class PlayState extends FlxState
{

	var actors : FlxTypedGroup<Actor>;
	var grid : Array<Array<Tile>>;

	override public function create():Void
	{
		super.create();

		loadMap("assets/data/level.txt");

		actors = new FlxTypedGroup<Actor>();
		add(actors);

		var player = new Player(1, 1);
		actors.add(player);

		tick();
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
			tick();
		});
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}	
}