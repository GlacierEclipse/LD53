package entities;

import haxepunk.tweens.misc.Alarm;
import haxepunk.tweens.misc.MultiVarTween;
import haxepunk.math.MinMaxValue;
import haxepunk.HXP;
import haxepunk.utils.Log;
import haxepunk.math.Vector2;
import haxepunk.utils.Draw;
import haxepunk.Camera;
import haxepunk.math.Random;
import haxepunk.math.MathUtil;
import map.LevelManager;
import haxepunk.ai.path.PathNode;
import haxepunk.Entity;
import haxepunk.graphics.Spritemap;
import haxepunk.tweens.misc.VarTween;
import haxepunk.utils.Ease;
import haxepunk.utils.Ease.EaseFunction;
import haxepunk.Tween.TweenType;
import haxepunk.tweens.motion.LinearMotion;
import unit_managment.Command;

class Unit extends GameEntity
{
    public var speed:Float;
    public var hp:Int;

    public var currentCommand:Command = null;
    public var motionTween:LinearMotion;
    public var highlightTween:VarTween;
    public var unitHighlightSprite:Spritemap;

    public var selected:Bool;

    public var pathArray:Array<PathNode>;

    public var randLastPos:Vector2;

    public var ownerIndex:Int;

    public var stunnedMinMaxVal:MinMaxValue;

    public var ownerController:UnitControllerEntity;

    public var stunnedTween:VarTween;

    public var pickedUpPackage:Bool = false;
    public var currentPickedPackage:Package;
    //public var hoarder:Bool = false;
    public var hoarderNumPackages:Int = 3;

    public var unitVeterancy:Int;

    public var removedFromScene:Bool;

    public var enteringSceneTween:MultiVarTween;

    public var timeToPickUpPackage:Alarm;

    public function new(x:Float, y:Float, asset:String, ownerController:UnitControllerEntity) 
    {
        super(x, y, asset);
        motionTween = new LinearMotion(TweenType.Persist);
        motionTween.onUpdate.bind(function() {
            this.x = motionTween.x;
            this.y = motionTween.y;
        }

        );

        unitHighlightSprite = new Spritemap(asset, 16, 16, 1, 1);
        unitHighlightSprite.setFrameColRow(0, 1);

        unitHighlightSprite.alpha = 0;
        addGraphic(unitHighlightSprite);
        
        highlightTween = new VarTween();

        stunnedTween = new VarTween(TweenType.Persist);
        enteringSceneTween = new MultiVarTween();
        

        timeToPickUpPackage = new Alarm(5.2);
        addTween(enteringSceneTween);
        addTween(stunnedTween);
        addTween(motionTween);
        addTween(highlightTween);
        addTween(timeToPickUpPackage);

        setHitbox(16, 16);

        currentCommand = new Command(CommandType.NONE);

        type = "unit";

        pathArray = new Array<PathNode>();

        randLastPos = new Vector2();

        this.ownerController = ownerController;
        this.ownerIndex = ownerController.ownerIndex;

        stunnedMinMaxVal = new MinMaxValue(0, 0, 0, 0);


        spriteMap.centerOrigin();
        spriteMapMask.centerOrigin();
        unitHighlightSprite.centerOrigin();
        centerGraphicInRect();

        this.speed = 30;

        unitVeterancy = 0;

        removedFromScene = false;

        initVarsBasedOnVeterancy();
    }

    public function enterScene(targetX:Float, targetY:Float) 
    {
        x = targetX;
        y = -50;
        enteringSceneTween.tween(this, {x: targetX, y: targetY}, 1.5, Ease.circOut);
        enteringSceneTween.start();
    }

    public function enteredScene() 
    {
        return !enteringSceneTween.active;
    }

    public function initVarsBasedOnVeterancy() 
    {
        
    }

    public function increaseVeterancy() 
    {
        unitVeterancy++;
        if(unitVeterancy > 6)
            unitVeterancy = 6;
    }

    override function update() 
    {
        super.update();

        if(LevelManager.pauseSimulation)
            return;

        spriteMapMask.angle = unitHighlightSprite.angle = spriteMap.angle;
        updateTimers();
        handleCommand();
        handleKnockback();
        handleCollisionDetection();
        applyVelocity();
    }

    public function updateTimers() 
    {
        stunnedMinMaxVal.currentValue -= HXP.elapsed;
        stunnedMinMaxVal.clamp();
    }

    public function isStunned() : Bool
    {
        return stunnedTween.active;
    }

    override function damageThisEnt(dmg:Int) 
    {
        super.damageThisEnt(dmg);

        hp -= dmg;
        
        if(hp <= 0)
        {
            // Drop packages / switch to idle.
            //unitStunned();
            unitDead();
        }
    }

    public function unitStunned() 
    {
        dispatchIdleCommand();

        stunnedMinMaxVal.initToMax();
        stunnedTween.tween(spriteMap, "angle", 90, 2.0, Ease.bounceOut);
        stunnedTween.onComplete.bind(function() {
            stunnedTween.onComplete.clear();
            stunnedTween.onComplete.bind(recoveredFromStun);
            stunnedTween.tween(spriteMap, "angle", 0, 2.0, Ease.bounceIn);
        });
    }

    public function unitDead() 
    {
        //dispatchIdleCommand();
        if(currentCommand.commandType == DELIVER || currentCommand.commandType == TAKEDELIVERY)
            dispatchIdleCommand();
        removedFromScene = true;
        if(pickedUpPackage)
        {
            currentPickedPackage.breakTween.tween(currentPickedPackage.spriteMap, "alpha", 0, 0.8, Ease.bounceInOut);
            currentPickedPackage.breakTween.start();
            currentPickedPackage.drop();
            currentPickedPackage = null;
            pickedUpPackage = false;
        }

        stunnedMinMaxVal.initToMax();
        stunnedTween.tween(spriteMap, "angle", 90, 2.0, Ease.bounceOut);
        stunnedTween.onComplete.bind(function() {
            stunnedTween.onComplete.clear();
            stunnedTween.onComplete.bind(function() {
                
                HXP.scene.remove(this);
            });
            stunnedTween.tween(spriteMap, "alpha", 0, 8.0, Ease.circOut);
            removedFromScene = true;
            ownerController.removeOwnedUnit(this);

        });
    }

    public function recoveredFromStun() 
    {
        hp = 2;
    }

    public function handleCollisionDetection() 
    {
        var collidedEntity:GameEntity = cast collide("deliveryUnit", x, y);
        if(collidedEntity != null && velocity.x == 0 && velocity.y == 0 && distanceFrom(collidedEntity) < 15.0 && 
                                      collidedEntity.knockbackVec.x == 0 && 
                                      collidedEntity.knockbackVec.y == 0 && 
                                      knockbackVec.x == 0 && 
                                      knockbackVec.y == 0)
        {
            collidedEntity.knockbackVec.setTo(collidedEntity.x - x, collidedEntity.y - y);
            collidedEntity.knockbackVec.normalize();
            collidedEntity.knockbackVec.scale(50);

            knockbackVec.setTo(-collidedEntity.velocity.x, -collidedEntity.velocity.y);
        }

        collidedEntity = cast collide("building", x + (velocity.x * HXP.elapsed), 
                                                  y + (velocity.y * HXP.elapsed));
        if(collidedEntity != null)
        {
            //knockbackVec.setTo(-collidedEntity.velocity.x, -collidedEntity.velocity.y);
            velocity.perpendicular();
        }
    }

    public function highlight()
    {
        unitHighlightSprite.color = 0xFFFFFF;
        unitHighlightSprite.alpha = 1;
        highlightTween.tween(unitHighlightSprite, "alpha", 0.0, 1.0, Ease.circOut);
    }

    public function select()
    {
        unitHighlightSprite.alpha = 1;
        unitHighlightSprite.color = 0xFF0000;
        highlightTween.active = false;
        //highlightTween.tween(unitHighlightSprite, "alpha", 0.0, 0.5, Ease.circOut);

        selected = true;
    }

    public function unSelect()
    {
        //unitHighlightSprite.alpha = 0;
        //unitHighlightSprite.alpha = 1;
        //unitHighlightSprite.color = 0xFF0000;
        highlightTween.tween(unitHighlightSprite, "alpha", 0.0, 0.5, Ease.circOut);

        selected = false;
    }

    public function dispatchCommand(interactWithEntity:Entity, mouseX:Float = 0, mouseY:Float = 0)
    {
        //currentCommand.targetEntity = interactWithEntity;
    }

    public function dispatchIdleCommand()
    {
        currentCommand.commandType = IDLE;
        currentCommand.targetEntity = null;
    }

    public function dispatchGotoCommand(posX:Float, posY:Float)
    {
        // Check if the position is valid
        var collidedEntity:Entity = cast collide("building", posX, posY);
                                          
        if(collidedEntity != null)
        {
            
            // invalid position can collide with building.
            return;
        }

        currentCommand.commandType = CommandType.GOTO;
        currentCommand.targetPos.setTo(posX, posY);



        //motionTween.setMotionSpeed(x, y, posX, posY, 150, Ease.quartIn);

        // A* pathfind here.
        // Create the path array for the unit to follow.
        createPathToDestination(posX, posY);

        // convert to world pos
        //for (path in pathArray)
        //{
        //    path.x *= 16.0;
        //    path.y *= 16.0;
        //}

        // rand the last pos
        randLastPos.x = -20.0 + Random.randFloat(40);
        randLastPos.y = -20.0 + Random.randFloat(40);
    }

    public function createPathToDestination(destX:Float, destY:Float) 
    {
        //if(pathArray != null)
        //    pathArray.splice(0, pathArray.length);
//
        //var startX:Int = MathUtil.floor(x / 16);
        //var startY:Int = MathUtil.floor(y / 16);
        //var destX:Int = MathUtil.floor(destX / 16);
        //var destY:Int = MathUtil.floor(destY / 16);
        //pathArray = LevelManager.nodeGraph.search(startX, startY, 
        //                                          destX, destY);
        //
        //if(pathArray == null)
        //{
        //    // why the fuck
        //    Log.debug("Couldn't A* some shit startX:" + startX + 
        //                  ", startY: " + startY  + ", destX: " + destX +
        //                  ", destY: " + destY);
        //    return;
        //}
        //else
        //    pathArray.shift();
    }

    public function setVelToTarget(targetX:Float, targetY:Float) 
    {
        velocity.setTo(targetX - x, targetY - y);
        velocity.normalize();
        velocity.scale(speed);
    }

    public function dispatchTakeDeliveryCommand(interactWithEntity:Entity)
    {
        currentCommand.targetEntity = interactWithEntity;
        cast(interactWithEntity, Package).assigned();

        currentCommand.commandType = CommandType.TAKEDELIVERY;        

        // A* To the package.
        //createPathToDestination(interactWithEntity.x, interactWithEntity.y);

    }

    public function dispatchDeliverCommand(interactWithEntity:Entity)
    {
        if(isStunned() || removedFromScene)
        {
            return;
        }
        currentCommand.targetEntity = cast(interactWithEntity, Package).pickUp(this);

        currentCommand.commandType = CommandType.DELIVER;
        
        var packageToDeliver:Package = cast currentCommand.targetEntity;
        //currentCommand.targetEntity = packageToDeliver.destinationEntity;
        
        // A* To the building.
        //createPathToDestination(packageToDeliver.destinationEntity.x, packageToDeliver.destinationEntity.y);

        pickedUpPackage = true;
        currentPickedPackage = packageToDeliver;
    }

    public function dispatchAttackCommand(interactWithEntity:Entity)
    {
        currentCommand.commandType = CommandType.ATTACK;
        currentCommand.targetEntity = interactWithEntity;
    }

    public function dispatchFollowCommand(interactWithEntity:Entity)
    {
        currentCommand.commandType = CommandType.FOLLOW;
        currentCommand.targetEntity = interactWithEntity;
    }

    public function dispatchDefendCommand(interactWithEntity:Entity)
    {
        currentCommand.commandType = CommandType.DEFEND;
        currentCommand.targetEntity = interactWithEntity;
    }

    public function handleCommand()
    {
        velocity.setToZero();
        if(currentCommand != null)
        {
            switch(currentCommand.commandType)
            {
                case NONE:
                {

                }
                case IDLE:
                {
                    handleIdle(currentCommand);
                }
                case GOTO:
                {
                    handleGoto(currentCommand);
                }
                case FOLLOW:
                {
                    handleFollow(currentCommand);
                }
                case TAKEDELIVERY:
                {
                    handleTakeDelivery(currentCommand);
                }
                case DELIVER:
                {
                    handleDeliver(currentCommand);
                }
                case ATTACK:
                {
                    handleAttack(currentCommand);
                }
                case DEFEND:
                {
                    handleDefend(currentCommand);
                }
            }
        }
    }

    public function handleIdle(command:Command)
    {

    }

    public function handleTakeDelivery(command:Command)
    {
        var targetX:Float = command.targetEntity.x;
        var targetY:Float = command.targetEntity.y;

        // Once package is acquired we need to deliver it.
        if(command.targetEntity.collideWith(this, command.targetEntity.x, command.targetEntity.y) != null)
        {
            velocity.setToZero();
            if(!timeToPickUpPackage.active)
            {
                timeToPickUpPackage.initTween(0.1 + Random.randFloat(ownerController.pickupTimeUpgrade.getRawValue()));
                timeToPickUpPackage.start();
                timeToPickUpPackage.onComplete.bind(function() {
                    dispatchDeliverCommand(command.targetEntity);    
                });
            }
            
            return;
        }
            
        setVelToTarget(targetX, targetY);

    }

    public function handleDeliver(command:Command)
    {
        var packageEnt = cast(command.targetEntity, Package);
        var targetX:Float = packageEnt.destinationEntity.x;
        var targetY:Float = packageEnt.destinationEntity.y;

        // Once package is acquired we need to deliver it.
        if(command.targetEntity.collideWith(this, packageEnt.destinationEntity.x, packageEnt.destinationEntity.y) != null)
        {
            ownerController.addMoney(packageEnt.cost * packageEnt.numOfPackages);
            currentPickedPackage = null;
            pickedUpPackage = false;
            packageEnt.delivered();
            velocity.setToZero();
            dispatchIdleCommand();
            return;
        }
        
        setVelToTarget(targetX, targetY);
    }
    
    public function handleGoto(command:Command)
    {
        var targetX:Float = command.targetPos.x;// * 16;
        var targetY:Float = command.targetPos.y;// * 16;

        //if(pathArray == null || pathArray.length == 0)
        if(Math.abs(targetX - x) < 1.0 && Math.abs(targetY - y) < 1.0)
        {
            velocity.setToZero();
            command.commandType = CommandType.IDLE;
            return;
        }
        
        setVelToTarget(targetX, targetY);
    }

    public function handleFollow(command:Command)
    {
        var targetX:Float = command.targetEntity.x;
        var targetY:Float = command.targetEntity.y;

        if(Math.abs(targetX - x) < 15.0 && Math.abs(targetY - y) < 15.0)
        {
            velocity.setToZero();
        }
        else
            setVelToTarget(targetX, targetY);
    }
    
    public function handleAttack(command:Command)
    {
        var targetX:Float = command.targetEntity.x;
        var targetY:Float = command.targetEntity.y;

        //if(this.collideWith(command.targetEntity, x, y) != null)
        //{
        //    // Attack!
        //    velocity.setToZero();
        //    command.commandType = CommandType.IDLE;
        //    return;
        //}
        var unitEnt:Unit = cast command.targetEntity;

        if(!unitEnt.isStunned() && !isKnockedBack())
            setVelToTarget(targetX, targetY);
        if(unitEnt.removedFromScene)
            dispatchIdleCommand();
    }
    

    public function handleDefend(command:Command)
    {
        var targetX:Float = command.targetEntity.x;
        var targetY:Float = command.targetEntity.y;

        if(Math.abs(targetX - x) < 15.0 && Math.abs(targetY - y) < 15.0)
        {
            velocity.setToZero();
        }
        else
            setVelToTarget(targetX, targetY);


        // If there is an enemy in the proximity he'll attack
        var enemiesInProximity:Array<CombatUnit> = new Array<CombatUnit>();
        HXP.scene.collideCircleInto("combatUnit", x, y, 40, enemiesInProximity);

        for(enemyInProximity in enemiesInProximity)
        {
            if(enemyInProximity.ownerIndex != ownerIndex)
            {
                // Found enemy unit
                // Dispatch attack command
                dispatchAttackCommand(enemyInProximity);
            }
        }
    }

    override function render(camera:Camera) 
    {
        super.render(camera);

        if(pathArray != null)
        for (path in pathArray)
        {
            Draw.rect(path.x * 16, path.y * 16, 16, 16);
        }
    }
}