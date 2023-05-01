package entities;

import haxepunk.tweens.misc.VarTween;
import haxepunk.graphics.Image;
import haxepunk.Tween.TweenType;
import haxepunk.tweens.misc.NumTween;
import haxepunk.Entity;

class FadeScreen extends Entity 
{
    public var alphaTween:VarTween;
    public var imageRect:Image;
    public function new() 
    {
        imageRect = Image.createRect(320, 240, 0xFFFFFF, 1);
        super(0, 0, imageRect);
        imageRect.color = 0x000000;
        alphaTween = new VarTween(TweenType.Persist);

        addTween(alphaTween, false);

        imageRect.scrollX = imageRect.scrollY = 0;
        
        imageRect.alpha = 0;
        
    }

    
    public function startFadeTo(duration:Float, start:Float, target:Float)
    {
        imageRect.alpha = start;
        alphaTween.tween(imageRect, "alpha", target, duration);
        alphaTween.start();
    }
}