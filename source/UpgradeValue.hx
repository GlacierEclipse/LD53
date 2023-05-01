import haxepunk.math.MinMaxValue;

class UpgradeValue 
{
    public var cost:Int;
    public var upgradeLevel:MinMaxValue;
    public var rawValue:Float;

    public function new()
    {
        upgradeLevel = new MinMaxValue(0.0, 5, 0, 1);
    }

    public function getRawValue() : Float
    {
        return -1.0;
    }

    public function upgrade() 
    {
        if(canUpgrade())
        {
            upgradeLevel.currentValue++;
            upgradeLevel.clamp();
        }
    }

    public function canUpgrade() : Bool
    {
        return upgradeLevel.currentValue < upgradeLevel.maxValue;
    }

    public function canBuy(money:Int) : Bool
    {
        return money >= cost;
    }
}

class PickUpTimeUpgrade extends UpgradeValue
{
    public function new()
    {
        super();
        cost = 5;
    }

    override function getRawValue() : Float
    {
        switch(upgradeLevel.currentValue)
        {
            case 0:
            {
                return 3;
            }
            case 1:
            {
                return 2.5;
            }
            case 2:
            {
                return 2;
            }
            case 3:
            {
                return 1.5;
            }
            case 4:
            {
                return 1.0;
            }
            case 5:
            {
                return 0.1;
            }
        }
        return -1;
    }
}

class CostChanceUpgrade extends UpgradeValue
{
    public function new()
    {
        super();
        cost = 5;
    }

    override function getRawValue() : Float
    {
        switch(upgradeLevel.currentValue)
        {
            case 0:
            {
                return 3;
            }
            case 1:
            {
                return 5;
            }
            case 2:
            {
                return 8;
            }
            case 3:
            {
                return 10;
            }
            case 4:
            {
                return 12;
            }
            case 5:
            {
                return 15;
            }
        }
        return -1;
    }
}

class DeliveryUnitUpgrade extends UpgradeValue
{
    public function new()
    {
        super();
        cost = 5;
    }

    override function getRawValue() : Float
    {
        switch(upgradeLevel.currentValue)
        {
            case 0:
            {
                return 3;
            }
            case 1:
            {
                return 2.5;
            }
            case 2:
            {
                return 2;
            }
            case 3:
            {
                return 1.5;
            }
            case 4:
            {
                return 1.0;
            }
            case 5:
            {
                return 0.1;
            }
        }
        return -1;
    }
}

class CombatUnitUpgrade extends UpgradeValue
{
    public function new()
    {
        super();
        cost = 5;
    }

    override function getRawValue() : Float
    {
        switch(upgradeLevel.currentValue)
        {
            case 0:
            {
                return 3;
            }
            case 1:
            {
                return 2.5;
            }
            case 2:
            {
                return 2;
            }
            case 3:
            {
                return 1.5;
            }
            case 4:
            {
                return 1.0;
            }
            case 5:
            {
                return 0.1;
            }
        }
        return -1;
    }
}