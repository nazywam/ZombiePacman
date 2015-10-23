import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxG;

class Actor extends FlxSprite {

	public var gridPos:FlxPoint;
	public var pressedDirection:Int;

	override public function new(gridX:Float, gridY:Float){
		super(100, 100, "assets/images/player.png");
		gridPos = new FlxPoint(gridX, gridY);
	}

	override public function update(elapsed:Float){
		super.update(elapsed);

		x = Settings.GRID_X + gridPos.x * Settings.TILE_WIDTH;
		y = Settings.GRID_Y + gridPos.y * Settings.TILE_WIDTH;


		if(FlxG.keys.justPressed.UP){
			pressedDirection = FlxObject.UP;
		}
		if(FlxG.keys.justPressed.RIGHT){
			pressedDirection = FlxObject.RIGHT;	
		}

		if(FlxG.keys.justPressed.DOWN){
			pressedDirection = FlxObject.DOWN;
		}

		if(FlxG.keys.justPressed.LEFT){
			pressedDirection = FlxObject.LEFT;
		}

	}
	public function tick(){
		switch (pressedDirection) {
			case FlxObject.UP:
				gridPos.y--;
			case FlxObject.RIGHT:
				gridPos.x++;
			case FlxObject.DOWN:
				gridPos.y++;
			case FlxObject.LEFT:
				gridPos.x--;
		}
	}
}