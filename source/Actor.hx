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



	override public function new(gridX:Int, gridY:Int, i:Int){
		super(100, 100);

		ID = i;

		loadGraphic("assets/images/Player"+Std.string(i%3)+".png", true, 32, 32);
		animation.add("default", [0, 1, 2, 3, 4, 3, 2, 1], 10);
		animation.add("dead", [5, 6], 2);
		animation.play("default");

		gridPos = new FlxPoint(gridX, gridY);
	}

	override public function update(elapsed:Float){
		super.update(elapsed);

		x = Settings.GRID_X + gridPos.x * Settings.TILE_WIDTH;
		y = Settings.GRID_Y + gridPos.y * Settings.TILE_WIDTH;
	}

	public function die(){
		isDead = true;
		animation.play("dead");
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