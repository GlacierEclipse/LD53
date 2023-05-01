package scenes;

import haxepunk.HXP;
import entities.FadeScreen;
import map.LevelManager;
import entities.DeliveryUnit;
import entities.Player;
import haxepunk.Scene;

class GameScene extends Scene
{
    public var levelManager:LevelManager;

    public var fadeScreen:FadeScreen;

    public var startGame:Bool = false;
    
	override public function begin()
    {
        Globals.gameScene = this;

        levelManager = new LevelManager();

        fadeScreen.startFadeTo(1.0, 1, 0);
        fadeScreen.imageRect.color = 0x333333;
        HXP.screen.color = 0x000000;

    }

    override function update() 
    {
        super.update();

        levelManager.update();
    }

    override function render() 
    {
        super.render();

        levelManager.render();
    }

}