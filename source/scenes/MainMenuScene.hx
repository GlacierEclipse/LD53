package scenes;

import haxepunk.tweens.misc.NumTween;
import entities.FadeScreen;
import haxepunk.Entity;
import haxepunk.graphics.Image;
import haxepunk.HXP;
import haxepunk.input.Input;
import haxepunk.utils.Ease;
import haxepunk.tweens.misc.VarTween;
import map.LevelManager;
import haxepunk.graphics.TextEntity;
import haxepunk.Scene;

class MainMenuScene extends Scene
{
    public var mainMenuImage:Image;
	public var tweenAlpha:NumTween = new NumTween();
	public var fadeScreen:FadeScreen;
    public function new() 
    {
        super();

		mainMenuImage = new Image("graphics/main_menu.png");
		mainMenuImage.smooth = false;
        add(new Entity(mainMenuImage));

        bgColor = 0x000000;
        bgAlpha = 1;
        tweenAlpha.tween(1.0, 0.0, 1.0);
		addTween(tweenAlpha);

		fadeScreen = new FadeScreen();
		fadeScreen.imageRect.color = 0x333333;
		add(fadeScreen);
		bgColor = 0x000000;
		HXP.screen.color = 0x000000;

		//bgAlpha = 0.;
    }

    override function update() 
    {
        super.update();
        
        fadeScreen.imageRect.alpha = 1.0 - tweenAlpha.value;
        if(Input.pressed("enter") && !tweenAlpha.active)
        {
			//tweenAlpha.tween(this, "bgAlpha", 0.0, 1.0);
            tweenAlpha.start();
            tweenAlpha.onComplete.bind(function() {
                HXP.scene = new GameScene();
				//bgAlpha = 0;
            });
        }
    }

	override function render() 
	{
		super.render();
	}
}