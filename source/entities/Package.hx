package entities;

class Package extends GameEntity
{
    public var destinationEntity:Building;
    public function new(x:Float, y:Float) 
    {
        super(x, y);

        spriteMap.setFrameColRow(0, 2);
    }
}