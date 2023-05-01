package entities;

import unit_managment.Command.CommandType;
import haxepunk.Tween.TweenType;
import haxepunk.tweens.misc.Alarm;
import haxepunk.math.MinMaxValue;
import haxepunk.HXP;
import haxepunk.Entity;

class CombatUnit extends Unit
{
    public var dmg:Int;
    public var attackAlarm:Alarm;

    public var originalRow:Int = 0;
    public var battlingCombatUnit:Bool = false;

    public function new(x:Float, y:Float, ownerController:UnitControllerEntity) 
    {
        super(x, y, "graphics/sprites.png", ownerController);

        originalRow = 11 + ownerIndex;

        spriteMap.setFrameColRow(0, 11 + ownerIndex);

        dmg = 1;
        unitHighlightSprite.setFrameColRow(1, 1);
        attackAlarm = new Alarm(0.5, attack, TweenType.Persist);

        addTween(attackAlarm);

        setHitbox(12,12);

        type = "combatUnit";

        speed = 80;
    }

    override function initVarsBasedOnVeterancy() 
    {
        super.initVarsBasedOnVeterancy();
        switch(unitVeterancy)
        {
            case 0:
            {
                hp = 2;
                speed = 30;
                hoarderNumPackages = 1;
                dmg = 1;
            }

            case 1:
            {
                hp = 3;
                speed = 30;
                hoarderNumPackages = 1;
            }

            case 2:
            {
                hp = 3;
                speed = 40;
                hoarderNumPackages = 1;
            }

            case 3:
            {
                hp = 4;
                speed = 50;
                hoarderNumPackages = 1;
            }

            case 4:
            {
                hp = 5;
                speed = 60;
                hoarderNumPackages = 1;
            }

            case 5:
            {
                hp = 5;
                speed = 70;
                hoarderNumPackages = 1;
            }
        }
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
            if(Std.is(interactWithEntity, DeliveryUnit) && !pickedUpPackage)
            {
                var deliveryUnit:DeliveryUnit = cast interactWithEntity;
                // Should be protected/attacked
                //if(deliveryUnit.ownerIndex == ownerIndex)
                //    dispatchDefendCommand(interactWithEntity);
                //else
                if(!deliveryUnit.isStunned())
                    dispatchAttackCommand(interactWithEntity);
            }

            if(Std.is(interactWithEntity, CombatUnit))
            {
                var combatUnit:CombatUnit = cast interactWithEntity;
                // Should be protected/attacked
                if(combatUnit.ownerIndex == ownerIndex)
                    dispatchFollowCommand(interactWithEntity);
                else
                    dispatchAttackCommand(interactWithEntity);

                battlingCombatUnit = true;
                combatUnit.battlingCombatUnit = true;

                // Dispatch battle command to the other combat unit
                combatUnit.dispatchAttackCommand(this);
            }

            if(Std.is(interactWithEntity, Package) && !pickedUpPackage)
            {
                // Dispatch start delivery.
                dispatchTakeDeliveryCommand(interactWithEntity);
            }
        }
        
    }

    override function updateTimers() 
    {
        super.updateTimers();


    }
    override function handleCollisionDetection() 
    {
        super.handleCollisionDetection();

        if(currentCommand != null && currentCommand.commandType == ATTACK)
        {
            var collidedEntity:GameEntity = cast collideWith(currentCommand.targetEntity, 
                                                             x + (velocity.x * HXP.elapsed), 
                                                             y + (velocity.y * HXP.elapsed));

            if(collidedEntity != null)
            {
                //collidedEntity.knockbackVec.setTo(collidedEntity.x - x, collidedEntity.y - y);
                //collidedEntity.knockbackVec.normalize();
                //collidedEntity.knockbackVec.scale(50);

                velocity.setToZero();

                //collidedEntity.damageThisEnt(dmg);

                // Start attack
                if(!attackAlarm.active)
                    startAttack();
            }
        }
    }

    public function startAttack() 
    {
        spriteMap.setFrameColRow(1, originalRow);
        attackAlarm.initTween(0.5);
        attackAlarm.start();
    }

    
    public function attack() 
    {
        if(currentCommand.targetEntity == null)
        {
            dispatchIdleCommand();
            return;
        }
        velocity.x = x - currentCommand.targetEntity.x;
        velocity.y = y - currentCommand.targetEntity.y;
        velocity.normalize();
        velocity.scale(50);
        knockbackVec.setTo(velocity.x, velocity.y);
        velocity.setToZero();

        if(currentCommand.commandType == CommandType.ATTACK)
        {
            var unitEnt:Unit = cast(currentCommand.targetEntity, Unit);

            if(unitEnt.type == "combatUnit")
            {
                damageThisEnt(cast(unitEnt, CombatUnit).dmg);
                cast(unitEnt, CombatUnit).attackAlarm.active = false;
                cast(unitEnt, CombatUnit).stopAttack();
            }
            cast(currentCommand.targetEntity, GameEntity).damageThisEnt(dmg);
        }
        spriteMap.setFrameColRow(2, originalRow);
        // Small cooldown
        attackAlarm.initTween(0.2);
        attackAlarm.start();

        attackAlarm.onComplete.clear();
        attackAlarm.onComplete.bind(stopAttack);
    }

    public function stopAttack() 
    {
        spriteMap.setFrameColRow(0, originalRow);
        attackAlarm.onComplete.clear();
        attackAlarm.onComplete.bind(attack);

        if(currentCommand.targetEntity == null)
        {
            dispatchIdleCommand();
            return;
        }
        if(cast(currentCommand.targetEntity, Unit).isStunned() || cast(currentCommand.targetEntity, Unit).removedFromScene)
            dispatchIdleCommand();
    }
}