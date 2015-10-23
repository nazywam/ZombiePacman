package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{

	var actors : FlxTypedGroup<Actor>;
	var grid : FlxTypedGroup<Tile>;

	override public function create():Void
	{
		super.create();


		for(y in 0...Settings.GRID_HEIGHT){
			for(x in 0...Settings.GRID_WIDTH){
				var t = new Tile(Settings.GRID_X + Settings.TILE_WIDTH * x, Settings.GRID_Y + Settings.TILE_WIDTH * y, Std.random(2));
			}
		}

		actors = new FlxTypedGroup<Actor>();
		add(actors);

		var player = new Player(1, 1);
		actors.add(player);

		tick();
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