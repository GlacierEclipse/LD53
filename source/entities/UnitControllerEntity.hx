package entities;

class UnitControllerEntity extends GameEntity
{
    public var ownedUnits:Array<Unit>;
    
    public function new() 
    {
        super(0, 0, "");

        ownedUnits = new Array<Unit>();
    }

    public function addOwnedUnit(unit:Unit) 
    {
        ownedUnits.push(unit);
    }
}