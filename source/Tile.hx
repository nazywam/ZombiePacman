import flixel.FlxSprite;
import flixel.math.FlxPoint;


class Tile extends FlxSprite {

	public var gridPos : FlxPoint;
	public var tileId : Int;

	override public function new(gridX:Int, gridY:Int, t:Int){
		super();
		tileId = t;

		loadGraphic("assets/images/wall32thin.png", true, 32, 32);
		animation.add("default", [t], 1);
		animation.play("default");

		gridPos = new FlxPoint(gridX, gridY);

		x = Settings.GRID_X + gridPos.x * Settings.TILE_WIDTH;
		y = Settings.GRID_Y + gridPos.y * Settings.TILE_WIDTH;
	}

}