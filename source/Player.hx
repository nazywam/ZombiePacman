import flixel.FlxG;
import flixel.FlxObject;

class Player extends Actor {

	override public function update(elapsed:Float){
		super.update(elapsed);

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

}