package entities;

import haxepunk.graphics.Spritemap;

class Building extends GameEntity
{
    public var buildingParts:Array<Spritemap>;
    public function new(x:Float, y:Float) 
    {
        super(x, y, "graphics/sprites.png", 16, 16);

        spriteMap.setFrameColRow(0, 5);

        buildingParts = new Array<Spritemap>();

        for (i in 0...1)
        {
            var spriteMapBuildingPart:Spritemap = new Spritemap("graphics/sprites.png", 16, 16, 1, 1);
            spriteMapBuildingPart.setFrameColRow(0, 4 - i);
            addGraphic(spriteMapBuildingPart);
            spriteMapBuildingPart.y = -16 * (i + 1);
        }
    }
}