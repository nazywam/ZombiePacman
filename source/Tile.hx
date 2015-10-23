import flixel.FlxSprite;
import flixel.math.FlxPoint;


class Tile extends FlxSprite {

	var gridPos : FlxPoint;

	override public function new(boardX:Int, boardY:Int){
		super();
		gridPos = new FlxPoint(boardX, boardY);

		x = Settings.GRID_X + gridPos.x * Settings.TILE_WIDTH;
		y = Settings.GRID_Y + gridPos.y * Settings.TILE_WIDTH;
	}

}