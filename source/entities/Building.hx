package entities;

import haxepunk.graphics.TextEntity;
import haxepunk.graphics.Spritemap;

class Building extends GameEntity
{
    public var buildingNumText:TextEntity;
    public var buildingParts:Array<Spritemap>;
    public var buildingNum:Int;

    public function new(x:Float, y:Float, buildingNum:Int)
    {
        super(x, y, "graphics/sprites.png", 16, 16);

        buildingNumText = new TextEntity(0, 0, "#" + Std.string(buildingNum), 8);

        
        buildingNumText.graphic.x = 2;
        buildingNumText.graphic.y = -26;
        addGraphic(buildingNumText.graphic);

        this.buildingNum = buildingNum;

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