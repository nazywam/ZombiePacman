import flixel.FlxSprite;
import flixel.math.FlxPoint;

class Actor extends FlxSprite {

	public var gridPos:FlxPoint;

	override public function new(gridX:Float, gridY:Float){
		super(100, 100);
		gridPos = new FlxPoint(gridX, gridY);

	}
}