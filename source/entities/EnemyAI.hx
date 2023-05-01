package entities;

import haxepunk.math.Random;
import haxepunk.tweens.misc.Alarm;
import map.LevelManager;
import haxepunk.HXP;
import unit_managment.Command.CommandType;

class EnemyAI extends UnitControllerEntity
{
    //public var packages:Array<Package>;
    public var alarmSpawnEnemy:Alarm;

    public var difficulty:Int;
    
    public function new(difficulty:Int)
    {
        super();
        alarmSpawnEnemy = new Alarm(2, buyCombatUnitEnemyAI);
        addTween(alarmSpawnEnemy, false);
        this.difficulty = difficulty;
    }

    override function addOwnedUnit(unit:Unit) 
    {
        super.addOwnedUnit(unit);
    }

    override function update() 
    {
        super.update();

        if(!alarmSpawnEnemy.active)
        {
            //alarmSpawnEnemy.start();
            switch(difficulty)
            {
                case 1:
                {
                    if(combatUnits.length < 3 && LevelManager.player.totalMoney > 10)
                        alarmSpawnEnemy.start();
                }
                case 2:
                {
                    if(combatUnits.length < 4 && LevelManager.player.totalMoney > 10)
                        alarmSpawnEnemy.start();
                }
                case 3:
                {
                    if(combatUnits.length < 5 && LevelManager.player.totalMoney > 10)
                        alarmSpawnEnemy.start();
                }
                case 4:
                {
                    if(combatUnits.length < 6 && LevelManager.player.totalMoney > 10)
                        alarmSpawnEnemy.start();
                }
                case 5:
                {
                    if(combatUnits.length < 7 && LevelManager.player.totalMoney > 10)
                        alarmSpawnEnemy.start();
                }
            }
            
        }
        // Find a random package to take.

        // Sort packages by price.

        // Man this is gonna be fun..
        // Then delivery
        //for(deliveryUnit in deliveryUnits)
        //{
        //    handleAIForDeliveryUnit(cast deliveryUnit);
        //}
//
        //// Then combat
        for(combatUnit in combatUnits)
        {
            handleAIForCombatUnit(cast combatUnit);
        }
//
        //handleMoneySpending();


    }

    public function buyCombatUnitEnemyAI() 
    {
        switch(difficulty)
        {
            case 1:
            {
                alarmSpawnEnemy.initTween(15.0 + Random.randFloat(20));
            }
            case 2:
            {
                alarmSpawnEnemy.initTween(15.0 + Random.randFloat(20));
            }
            case 3:
            {
                alarmSpawnEnemy.initTween(15.0 + Random.randFloat(10));
            }
            case 4:
            {
                alarmSpawnEnemy.initTween(15.0 + Random.randFloat(10));
            }
            case 5:
            {
                alarmSpawnEnemy.initTween(15.0 + Random.randFloat(10));
            }
        }

        super.buyCombatUnit(170);

    }

    public function handleMoneySpending() 
    {
        // Only buy combat if the player has combat and can affort obv..
        if(LevelManager.player.combatUnits.length > combatUnits.length)
        {
            if(totalMoney >= combatUnitCost)
            {
                buyCombatUnitEnemyAI();
            }
            return;
        }

        if(LevelManager.player.deliveryUnits.length + 2> deliveryUnits.length)
        {
            if(totalMoney >= deliveryUnitCost)
            {
                buyDeliveryUnit(170);
            }
            return;
        }
    }


}