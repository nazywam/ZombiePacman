import flixel.FlxSprite;
import flixel.math.FlxPoint;

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
	}
	public function tick(){
		
	}
}