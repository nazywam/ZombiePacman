import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;

class Collectible extends FlxSprite {
	
	public var gridPos:FlxPoint;
	public var taken:Bool = false;
	public var value:Int;

	override public function new(gridX:Int, gridY:Int, v:Int){
		super(0, 0);
		value = v;
		gridPos = new FlxPoint(gridX, gridY);
		loadGraphic("assets/images/points.png", true, Settings.TILE_WIDTH, Settings.TILE_HEIGHT);
		animation.add("default", [v]);
		animation.play("default");

		x = Settings.GRID_X + gridPos.x * Settings.TILE_WIDTH;
		y = Settings.GRID_Y + gridPos.y * Settings.TILE_HEIGHT;

		if(value == 2){
			FlxTween.linearMotion(this, this.x, this.y, this.x, this.y-10, 1, true, {type:FlxTween.PINGPONG});
		}
	}

}