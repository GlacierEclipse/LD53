package entities;

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
    public var hp:Int;
    public var currentCommand:Command = null;
    public var motionTween:LinearMotion;
    public var highlightTween:VarTween;
    public var unitHighlightSprite:Spritemap;

    public var selected:Bool;

    public var pathArray:Array<PathNode>;

    public var randLastPos:Vector2;

    public function new(x:Float, y:Float, asset:String) 
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

        addTween(motionTween);
        addTween(highlightTween);

        setHitbox(16, 16);

        currentCommand = new Command(CommandType.NONE);

        type = "unit";

        pathArray = new Array<PathNode>();

        randLastPos = new Vector2();
    }

    override function update() 
    {
        super.update();

        handleCommand();
        handleKnockback();
        handleCollisionDetection();
        applyVelocity();
    }

    public function handleCollisionDetection() 
    {
        var collidedEntity:GameEntity = cast collide("unit", x, y);
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
        currentCommand.targetEntity = interactWithEntity;
    }

    public function dispatchIdleCommand()
    {
        currentCommand.commandType = IDLE;
        currentCommand.targetEntity = null;
    }

    public function dispatchGotoCommand(posX:Float, posY:Float)
    {
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
        if(pathArray != null)
            pathArray.splice(0, pathArray.length);

        var startX:Int = MathUtil.floor(x / 16);
        var startY:Int = MathUtil.floor(y / 16);
        var destX:Int = MathUtil.floor(destX / 16);
        var destY:Int = MathUtil.floor(destY / 16);
        pathArray = LevelManager.nodeGraph.search(startX, startY, 
                                                  destX, destY);
        
        if(pathArray == null)
        {
            // why the fuck
            Log.debug("Couldn't A* some shit startX:" + startX + 
                          ", startY: " + startY  + ", destX: " + destX +
                          ", destY: " + destY);
            return;
        }
        else
            pathArray.shift();
    }

    public function dispatchTakeDeliveryCommand(interactWithEntity:Entity)
    {

        cast(interactWithEntity, Package).assigned();

        currentCommand.commandType = CommandType.TAKEDELIVERY;        

        // A* To the package.
        createPathToDestination(interactWithEntity.x, interactWithEntity.y);

    }

    public function dispatchDeliverCommand(interactWithEntity:Entity)
    {

        cast(interactWithEntity, Package).pickUp(this);

        currentCommand.commandType = CommandType.DELIVER;

        var packageToDeliver:Package = cast interactWithEntity;
        
        // A* To the building.
        createPathToDestination(packageToDeliver.destinationEntity.x + 16, packageToDeliver.destinationEntity.y);


    }

    public function dispatchAttackCommand(interactWithEntity:Entity)
    {
        currentCommand.commandType = CommandType.ATTACK;
    }

    public function dispatchDefendCommand(interactWithEntity:Entity)
    {
        currentCommand.commandType = CommandType.DEFEND;
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
        // Once package is acquired we need to deliver it.
        if(pathArray == null || pathArray.length == 0)
        {
            velocity.setToZero();
            dispatchDeliverCommand(command.targetEntity);
            return;
        }
            
        var targetNode:PathNode = pathArray[0];
    
        var targetX:Float = targetNode.x * 16;
        var targetY:Float = targetNode.y * 16;
        if(pathArray.length == 1)
        {
            targetX += randLastPos.x;
            targetY += randLastPos.y;
        }
        velocity.setTo(targetX - x, targetY - y);
        velocity.normalize();
        velocity.scale(150);
    
        if(Math.abs(targetX - x) < 1.0 && Math.abs(targetY - y) < 1.0)
        {
            pathArray.shift();
        }

    }

    public function handleDeliver(command:Command)
    {
        // Once package is acquired we need to deliver it.
        if(pathArray == null || pathArray.length == 0)
        {
            cast(command.targetEntity, Package).delivered();
            velocity.setToZero();
            dispatchIdleCommand();
            return;
        }
            
        var targetNode:PathNode = pathArray[0];
    
        var targetX:Float = targetNode.x * 16;
        var targetY:Float = targetNode.y * 16;
        if(pathArray.length == 1)
        {
            targetX += randLastPos.x;
            targetY += randLastPos.y;
        }
        velocity.setTo(targetX - x, targetY - y);
        velocity.normalize();
        velocity.scale(150);
    
        if(Math.abs(targetX - x) < 1.0 && Math.abs(targetY - y) < 1.0)
        {
            pathArray.shift();
        }

    }
    
    public function handleGoto(command:Command)
    {
        if(pathArray == null || pathArray.length == 0)
        {
            velocity.setToZero();
            command.commandType = CommandType.IDLE;
            return;
        }
            
        var targetNode:PathNode = pathArray[0];

        var targetX:Float = targetNode.x * 16;
        var targetY:Float = targetNode.y * 16;
        if(pathArray.length == 1)
        {
            targetX += randLastPos.x;
            targetY += randLastPos.y;
        }
        velocity.setTo(targetX - x, targetY - y);
        velocity.normalize();
        velocity.scale(150);

        if(Math.abs(targetX - x) < 1.0 && Math.abs(targetY - y) < 1.0)
        {
            pathArray.shift();
        }
    }
    
    public function handleAttack(command:Command)
    {
        
    }
    

    public function handleDefend(command:Command)
    {

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