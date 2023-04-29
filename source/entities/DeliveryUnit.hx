package entities;

import haxepunk.Entity;

class DeliveryUnit extends Unit
{
    public function new(x:Float, y:Float) 
    {
        super(x, y, "graphics/sprites.png");
        spriteMap.index = 0;
    }

    override function dispatchCommand(interactWithEntity:Entity, mouseX:Float = 0, mouseY:Float = 0) 
    {
        super.dispatchCommand(interactWithEntity);

        if(interactWithEntity == null)
        {
            dispatchGotoCommand(mouseX, mouseY);
        }
        else
        {
            // This can be performance heavy, profile this shit.
            if(Std.is(interactWithEntity, DeliveryUnit))
            {
                // Do nothing?? 
            }
        }
        
    }
}