package entities;

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

    public function dispatchGotoCommand(posX:Float, posY:Float)
    {
        currentCommand.commandType = CommandType.GOTO;
        currentCommand.targetPos.setTo(posX, posY);

        //motionTween.setMotionSpeed(x, y, posX, posY, 150, Ease.quartIn);

        // A* pathfind here.
        // Create the path array for the unit to follow.
        pathArray = LevelManager.nodeGraph.search(MathUtil.floor(x / 16), MathUtil.floor(y / 16), 
                                                  MathUtil.floor(posX / 16), MathUtil.floor(posY / 16));
        
        if(pathArray == null)
        {
            // why the fuck
        }
        else
            pathArray.shift();
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
                case DELIVER:
                {

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
    
    public function handleGoto(command:Command)
    {
        if(pathArray == null || pathArray.length == 0)
        {
            velocity.setToZero();
            command.commandType = CommandType.IDLE;
            return;
        }
            
        var targetNode:PathNode = pathArray[0];

        velocity.setTo(targetNode.x * 16 - x, targetNode.y * 16 - y);
        velocity.normalize();
        velocity.scale(150);

        if(Math.abs(targetNode.x * 16 - x) < 1.0 && Math.abs(targetNode.y * 16 - y) < 1.0)
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
}