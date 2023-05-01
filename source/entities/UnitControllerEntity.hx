package entities;

import UpgradeValue.CombatUnitUpgrade;
import UpgradeValue.DeliveryUnitUpgrade;
import UpgradeValue.CostChanceUpgrade;
import UpgradeValue.PickUpTimeUpgrade;
import haxepunk.math.MinMaxValue;
import haxepunk.HXP;
import unit_managment.Command.CommandType;
import haxepunk.math.Random;
import haxepunk.math.MathUtil;

class UnitControllerEntity extends GameEntity
{
    public static var uniqueOwnerIndex:Int = 0;

    public var ownerIndex:Int = 0;
    public var ownedUnits:Array<Unit>;
    public var deliveryUnits:Array<DeliveryUnit>;
    public var hoarderUnits:Array<DeliveryUnit>;
    public var combatUnits:Array<CombatUnit>;
    public var totalMoney:Int;

    public var deliveryUnitCount:Int = 0;
    public var horaderUnitCount:Int = 0;
    public var combatUnitCount:Int = 0;

    public var renderMoney:Float = 0;

    public var deliveryUnitCost:Int = 20;
    public var combatUnitCost:Int = 60;
    public var packageLord:Package;


    // UPGRADES
    public var pickupTimeUpgrade:PickUpTimeUpgrade;
    public var costChanceUpgrade:CostChanceUpgrade;
    public var deliveryUnitUpgrade:DeliveryUnitUpgrade;
    public var combatUnitUpgrade:CombatUnitUpgrade;

    public function new() 
    {
        super(0, 0, "");

        ownedUnits = new Array<Unit>();
        deliveryUnits = new Array<DeliveryUnit>();
        hoarderUnits = new Array<DeliveryUnit>();
        combatUnits = new Array<CombatUnit>();
        pickupTimeUpgrade = new PickUpTimeUpgrade();
        costChanceUpgrade = new CostChanceUpgrade();
        deliveryUnitUpgrade = new DeliveryUnitUpgrade();
        combatUnitUpgrade = new CombatUnitUpgrade();

        renderMoney = totalMoney = 0;

        this.ownerIndex = UnitControllerEntity.uniqueOwnerIndex;
        UnitControllerEntity.uniqueOwnerIndex++;
        



        deliveryUnitCost = 3;
        combatUnitCost = 10;
    }

    override function update() 
    {
        super.update();

        packageLord = cast HXP.scene.getInstance("packageLord");
        renderMoney = MathUtil.lerp(renderMoney, totalMoney, 0.02);
    }

    public function addOwnedUnit(unit:Unit) 
    {
        ownedUnits.push(unit);

        if(unit.type == "deliveryUnit")
        {

            deliveryUnitCount++;
            deliveryUnits.push(cast unit);
            
        }
        else
        {
            combatUnitCount++;
            combatUnits.push(cast unit);
        }
    }

    public function buyDeliveryUnit(x:Float) 
    {
        var newUnit:Unit = new DeliveryUnit(0, 0, this);
        newUnit.enterScene(x + Random.randFloat(100), 15 + Random.randFloat(10));
        ownedUnits.push(newUnit);
        Globals.gameScene.add(newUnit);

        deliveryUnitCount++;
        deliveryUnits.push(cast newUnit);

        totalMoney -= deliveryUnitCost;
    }

    public function buyCombatUnit(x:Float) 
    {
        var newUnit:Unit = new CombatUnit(0, 0, this);
        newUnit.enterScene(x + Random.randFloat(100), 15 + Random.randFloat(10));
        ownedUnits.push(newUnit);
        Globals.gameScene.add(newUnit);

        combatUnitCount++;
        combatUnits.push(cast newUnit);

        totalMoney -= combatUnitCost;
    }

    public function removeOwnedUnit(unit:Unit) 
    {
        ownedUnits.push(unit);
        
        if(unit.type == "deliveryUnit")
        {
            deliveryUnitCount--;
            deliveryUnits.remove(cast unit);
        }
        else
        {
            combatUnitCount--;
            combatUnits.remove(cast unit);
        }
    }

    public function addMoney(money:Int) 
    {
        totalMoney += money;
    }

    public function handleAIForDeliveryUnit(deliveryUnit:DeliveryUnit) 
    {
        if(deliveryUnit.currentCommand.commandType == CommandType.NONE || 
              deliveryUnit.currentCommand.commandType == CommandType.IDLE &&
              !deliveryUnit.isStunned())
        {
            //for (packageEnt in packages)
            //{
                //if(!packageEnt.removedFromScene && !packageEnt.assignedToEnt)
                //{
                    // Assign this unit to this package.
                    deliveryUnit.dispatchTakeDeliveryCommand(packageLord);
                    //break;
                //}
            //}
        }
    }
    
    public function handleAIForCombatUnit(combatUnit:CombatUnit) 
    {
      if(combatUnit.currentCommand.commandType == CommandType.NONE || 
         combatUnit.currentCommand.commandType == CommandType.IDLE &&
         !combatUnit.isStunned())
      {
            // The priority is to defeat combat units first
            var arrEnemyUnits:Array<CombatUnit> = new Array<CombatUnit>();
            HXP.scene.getType("combatUnit", arrEnemyUnits);

            var bFoundEnemyUnit:Bool = false;
            for (enemyUnit in arrEnemyUnits)
            {
                if(enemyUnit.ownerIndex != ownerIndex && !enemyUnit.removedFromScene && !enemyUnit.battlingCombatUnit)
                {
                    // ATTACK!
                    combatUnit.dispatchCommand(enemyUnit);
                    bFoundEnemyUnit = true;
                    break;
                }
            }

            if(!bFoundEnemyUnit)
            {
                // Then attack delivery ppl
                var arrDeliveryUnits:Array<DeliveryUnit> = new Array<DeliveryUnit>();
                HXP.scene.getType("deliveryUnit", arrDeliveryUnits);
    
                var bFoundEnemyUnit:Bool = false;
                for (deliveryUnit in arrDeliveryUnits)
                {
                    if(deliveryUnit.ownerIndex != ownerIndex && !deliveryUnit.isStunned() && !deliveryUnit.removedFromScene)
                    {
                        // ATTACK!
                        combatUnit.dispatchCommand(deliveryUnit);
                        break;
                    }
                }
            }
      }
    }

}