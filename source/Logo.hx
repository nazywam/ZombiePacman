import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;

class Logo extends FlxState {


	var logo:FlxSprite;

	override public function create(){
		super.create();


		logo = new FlxSprite(0, 0, "assets/images/logo.png");
		logo.alpha = 0;
		add(logo);


		FlxTween.tween(logo, {alpha:1}, 1);

		var t = new FlxTimer();
		t.start(2, function(_){
			FlxTween.tween(logo, {alpha:0}, 1);

			var t1 = new FlxTimer();
			t1.start(1, function(_){
				FlxG.switchState(new PlayState());

			});
		});
	}
}