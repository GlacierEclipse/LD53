package entities.ui;

import haxepunk.math.MathUtil;
import haxepunk.Signal.Signal0;
import haxepunk.input.Mouse;

class UIButton extends GameEntity
{
    public var canClick:Bool = true;
    public var clickCallback:Signal0;

    public function new(x:Float, y:Float, asset:String, width:Int, height:Int, clickFunc:() -> Void)
    {
        super(x, y, asset, width, height);
        setHitbox(width, height);

        clickCallback = new Signal0();
        clickCallback.bind(clickFunc);

        spriteMapMask.scrollX = spriteMap.scrollX;
        spriteMapMask.scrollY = spriteMap.scrollY;
        
    }

    override function update() 
    {
        super.update();

        spriteMapMask.scrollX = spriteMap.scrollX;
        spriteMapMask.scrollY = spriteMap.scrollY;

        var hover:Bool = false;
        if(canClick)
        {
            if(collidePoint(x, y, Mouse.mouseX, Mouse.mouseY))
            {
                hover = true;
                //spriteMap.alpha = MathUtil.lerp(spriteMap.alpha, 0.4, 0.05);
                if(alphaTween.tweenDuration == 0.1 || !alphaTween.active)
                    startMask(0.1, 0xFFFFFF, 0.4);
            }
        }

        if(!canClick)
            spriteMap.alpha = MathUtil.lerp(spriteMap.alpha, 0.4, 0.04);
        else
            spriteMap.alpha = MathUtil.lerp(spriteMap.alpha, 1.0, 0.04);

        if(hover && Mouse.mousePressed && canClick)
        {
            clickCallback.invoke();
            startMask(0.8, 0xFFFFFF, 1.0);
        }
    }
}