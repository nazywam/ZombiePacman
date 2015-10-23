package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class PlayState extends FlxState
{
	
	override public function create():Void
	{
		super.create();

		var a = new Actor(1, 1);
		add(a);
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