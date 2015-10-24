package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;

class MenuState extends FlxState
{

	var ipWindow:FlxInputText;
	var portWindow:FlxInputText;

	var connectButton:FlxSprite;

	override public function create():Void
	{
		super.create();
		var server = new FlxText("Server IP:");
		server.size = 48;
		server.x = (FlxG.width - server.width)/2;

		ipWindow = new FlxInputText(FlxG.width/2, server.y + server.height, 196, "", 24);
		ipWindow.x -= ipWindow.width/2;
		add(ipWindow);

		var port = new FlxText("Server Port");
		port.size = 48;
		port.x = (FlxG.width - port.width)/2;
		port.y = ipWindow.y + ipWindow.height + 10;
		add(port);

		portWindow = new FlxInputText(FlxG.width/2, port.y + port.height, 192, "", 24);
		portWindow.x -= portWindow.width/2;
		add(portWindow);

		server.color = 0xFFFFFFFF;
		add(server);

		connectButton = new FlxSprite(FlxG.width/2, portWindow.y + portWindow.height + 32);
		connectButton.makeGraphic(200, 50);
		connectButton.x -= connectButton.width/2;
		add(connectButton);
	}	

	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if(FlxG.mouse.justPressed){
			if(FlxG.mouse.overlaps(connectButton)){
				FlxG.switchState(new PlayState(ipWindow.text, portWindow.text));
			}
		}
	}	
}