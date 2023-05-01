package entities;

import map.LevelManager;
import haxepunk.utils.Color;
import haxepunk.Tween.TweenType;
import haxepunk.tweens.misc.NumTween;
import haxepunk.math.MathUtil;
import haxepunk.math.Vector2;
import haxepunk.HXP;
import haxepunk.graphics.Spritemap;
import haxepunk.Entity;

class GameEntity extends Entity
{
    public var spriteMap:Spritemap;
    public var knockbackVec:Vector2;

    public var spriteMapMask:Spritemap;
    private var alphaTween:NumTween;

    public function new(x:Float, y:Float, asset:String = "graphics/sprites.png", width:Int = 16, height:Int = 16, spacingX:Int = 1, spacingY:Int = 1) 
    {
        if(asset != "")
        {
            spriteMap = new Spritemap(asset, width, height, spacingX, spacingY);
            spriteMapMask = new Spritemap(asset, width, height, spacingX, spacingY);
        }
        super(x, y, spriteMap);

        knockbackVec = new Vector2();
        
        addGraphic(spriteMapMask);

        alphaTween = new NumTween(TweenType.Persist);

        addTween(alphaTween, false);
    }

    public function damageThisEnt(dmg:Int)
    {
        startMask(1);
    }

    public function startMask(duration:Float, color:Color = 0xFF0000, startAlpha:Float = 1)
    {
        spriteMapMask.color = color;
        if(duration != alphaTween.tweenDuration)
            alphaTween.tween(startAlpha, 0.0, duration);
        alphaTween.start();
    }

    public function startMaskOnce(duration:Float, color:Color = 0xFF0000)
    {
        if(alphaTween.active)
            return;
        spriteMapMask.color = color;
        if(duration != alphaTween.tweenDuration)
            alphaTween.tween(1.0, 0.0, duration);
        alphaTween.start();
    }

    override function update() 
    {
        super.update();

        //if(LevelManager.pauseSimulation)
        //    return;
        if(spriteMapMask != null)
        {
            spriteMapMask.frame = spriteMap.frame;
            spriteMapMask.maskAlpha = 1;
            spriteMapMask.alpha = alphaTween.value;
        }
    }

    public function handleKnockback() 
    {
        knockbackVec.x = MathUtil.lerp(knockbackVec.x, 0.0, 0.1);
        knockbackVec.y = MathUtil.lerp(knockbackVec.y, 0.0, 0.1);
//
        if(Math.abs(knockbackVec.x) < 0.01)
            knockbackVec.x = 0;
//
        if(Math.abs(knockbackVec.y) < 0.01)
            knockbackVec.y = 0;

        velocity.x += knockbackVec.x;
        velocity.y += knockbackVec.y;

        //knockbackVec.setToZero();
    }

    public function isKnockedBack() 
    {
        if(Math.abs(knockbackVec.x) < 0.01 && Math.abs(knockbackVec.y) < 0.01)
            return false;
        return true;
    }

    public function applyVelocity() 
    {
        x += velocity.x * HXP.elapsed;
        y += velocity.y * HXP.elapsed;
    }
}