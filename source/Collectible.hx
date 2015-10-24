import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Collectible extends FlxSprite {
	
	public var gridPos:FlxPoint;
	public var taken:Bool = false;

	override public function new(gridX:Int, gridY:Int){
		super(0, 0);
		gridPos = new FlxPoint(gridX, gridY);
		loadGraphic("assets/images/points.png", true, Settings.TILE_WIDTH, Settings.TILE_HEIGHT);
		animation.add("default", [0]);
		animation.play("default");

		x = Settings.GRID_X + gridPos.x * Settings.TILE_WIDTH;
		y = Settings.GRID_Y + gridPos.y * Settings.TILE_HEIGHT;
	}

}