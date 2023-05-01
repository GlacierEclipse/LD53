package scenes;

import haxepunk.HXP;
import haxepunk.input.Input;
import haxepunk.utils.Ease;
import haxepunk.tweens.misc.VarTween;
import map.LevelManager;
import haxepunk.graphics.TextEntity;
import haxepunk.Scene;

class GameCompleteScene extends Scene
{
    public var tweenAlpha:VarTween = new VarTween();
    public var texts:Array<TextEntity> = new Array<TextEntity>();
    public var posTweens:Array<VarTween> = new Array<VarTween>();
    public function new() 
    {
        super();

        texts.push(new TextEntity(0, 80, "Congratulations you've finished the game!"));
        texts.push(new TextEntity(0, 100, "Created for LD53!"));
        texts.push(new TextEntity(0, 110, "By GlacierEclipse"));
        texts.push(new TextEntity(0, 200, "Enter to start a new game"));

        for (text in texts)
        {
            var targetY = text.y;
            text.x = 160 - text.textBitmap.textWidth / 2;
            text.y = -20;

            var varTween:VarTween = new VarTween();
            varTween.tween(text, "y", targetY, 0.5, Ease.circOut);
            addTween(varTween, true);

            
            add(text);
        }

        bgColor = 0x333333;
        bgAlpha = 0;
        tweenAlpha.tween(this, "bgAlpha", 0.8, 1.0);
        addTween(tweenAlpha, true);
    }

    override function update() 
    {
        super.update();

        
        
        for (text in texts)
        {
            text.textBitmap.alpha = bgAlpha;
        }
        
            
        if(Input.pressed("enter") && !tweenAlpha.active)
        {
            tweenAlpha.tween(this, "bgAlpha", 1, 0.5);
            tweenAlpha.start();
            tweenAlpha.onComplete.bind(function() {
                tweenAlpha.tween(this, "bgAlpha", 0, 0.5);
                tweenAlpha.start();
                tweenAlpha.onComplete.clear();

                Globals.gameScene.levelManager.cleanAll();
                Globals.gameScene.levelManager.buildNewGame();

                tweenAlpha.onComplete.bind(function() {
                    HXP.engine.popScene();
                }

                );
            });
        }
    }
}