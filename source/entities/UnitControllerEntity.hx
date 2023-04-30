package entities;

class UnitControllerEntity extends GameEntity
{
    public var ownedUnits:Array<Unit>;
    public var totalMoney:Int;

    public function new() 
    {
        super(0, 0, "");

        ownedUnits = new Array<Unit>();

        totalMoney = 20;
    }

    public function addOwnedUnit(unit:Unit) 
    {
        ownedUnits.push(unit);
    }
}