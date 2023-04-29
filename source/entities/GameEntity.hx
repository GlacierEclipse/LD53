package entities;

import haxepunk.math.MathUtil;
import haxepunk.math.Vector2;
import haxepunk.HXP;
import haxepunk.graphics.Spritemap;
import haxepunk.Entity;

class GameEntity extends Entity
{
    public var spriteMap:Spritemap;
    public var knockbackVec:Vector2;

    public function new(x:Float, y:Float, asset:String = "graphics/sprites.png", width:Int = 16, height:Int = 16, spacingX:Int = 1, spacingY:Int = 1) 
    {
        if(asset != "")
            spriteMap = new Spritemap(asset, width, height, spacingX, spacingY);
        super(x, y, spriteMap);

        knockbackVec = new Vector2();
        
    }

    

    public function handleKnockback() 
    {
        //knockbackVec.x = MathUtil.lerp(knockbackVec.x, 0.0, 0.5);
        //knockbackVec.y = MathUtil.lerp(knockbackVec.y, 0.0, 0.5);
//
        //if(Math.abs(knockbackVec.x) < 0.01)
        //    knockbackVec.x = 0;
//
        //if(Math.abs(knockbackVec.y) < 0.01)
        //    knockbackVec.y = 0;

        velocity.x += knockbackVec.x;
        velocity.y += knockbackVec.y;

        knockbackVec.setToZero();
    }

    public function applyVelocity() 
    {
        x += velocity.x * HXP.elapsed;
        y += velocity.y * HXP.elapsed;
    }
}