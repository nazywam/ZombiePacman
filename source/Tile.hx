import flixel.FlxSprite;
import flixel.math.FlxPoint;


class Tile extends FlxSprite {

	var gridPos : FlxPoint;
	var tileId : Int;

	override public function new(boardX:Int, boardY:Int, t:Int){
		super();
		tileId = t;

		loadGraphic("assets/images/wall32.png", true, 32, 32);
		animation.add("default", [t], 0);
		animation.play("default");

		gridPos = new FlxPoint(boardX, boardY);

		x = Settings.GRID_X + gridPos.x * Settings.TILE_WIDTH;
		y = Settings.GRID_Y + gridPos.y * Settings.TILE_WIDTH;
	}

}