import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.FlxG;

class Actor extends FlxSprite {

	public var gridPos:FlxPoint;

	public var pressedDirection:Int = FlxObject.UP;
	public var previousPressedDirection:Int = FlxObject.UP;

	public var canMove:Bool = true;

	public var isDead:Bool = false;

	override public function new(gridX:Int, gridY:Int){
		super(100, 100);
		loadGraphic("assets/images/player.png", true, 32, 32);
		animation.add("default", [0, 1, 2, 3, 4, 3, 2, 1], 10);
		animation.add("dead0", [8, 9], 2);
		animation.add("dead1", [10, 11], 2);
		animation.add("dead2", [12, 13], 2);
		animation.add("dead3", [14, 15], 2);

		animation.play("default");
		gridPos = new FlxPoint(gridX, gridY);
	}

	override public function update(elapsed:Float){
		super.update(elapsed);

		x = Settings.GRID_X + gridPos.x * Settings.TILE_WIDTH;
		y = Settings.GRID_Y + gridPos.y * Settings.TILE_WIDTH;
	}

	function updateRotation(){

		switch (pressedDirection) {
			case FlxObject.UP:
				angle = 270;
				flipX = false;
			case FlxObject.RIGHT:
				angle = 0;
				flipX = false;
			case FlxObject.DOWN:
				angle = 90;
				flipX = false;
			case FlxObject.LEFT:
				angle = 0;
				flipX = true;
		}
	}

	public function tick(){
		if(!isDead){
			updateRotation();	
		} else {
			angle = 0;
			flipX = false;
		}
		

		if(canMove){
			switch (pressedDirection) {
				case FlxObject.UP:
					gridPos.y--;
				case FlxObject.RIGHT:
					gridPos.x++;
				case FlxObject.DOWN:
					gridPos.y++;
				case FlxObject.LEFT:
					gridPos.x--;
			}
		}

		canMove = true;
		previousPressedDirection = pressedDirection;
	}
}