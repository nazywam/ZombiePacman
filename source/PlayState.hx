package;

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
	var grid : FlxTypedGroup<Tile>;

	override public function create():Void
	{
		super.create();

		grid = new FlxTypedGroup<Tile>();
		add(grid);

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

		for(l in 0..._lines.length){
			var _rows = _lines[l].split(',');
			for(r in 0..._rows.length){
				var t = new Tile(r, l, Std.parseInt(_rows[r])-1);
				grid.add(t);
			}
		}
	}
	

	public  function tick(){
		for(a in actors){
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