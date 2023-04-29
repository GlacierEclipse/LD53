package scenes;

import map.LevelManager;
import entities.DeliveryUnit;
import entities.Player;
import haxepunk.Scene;

class GameScene extends Scene
{
    public var levelManager:LevelManager;

	override public function begin()
    {
        Globals.gameScene = this;

        levelManager = new LevelManager();

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