package entities;

import haxepunk.HXP;
import haxepunk.utils.Ease;
import haxepunk.graphics.Spritemap;
import haxepunk.tweens.misc.VarTween;
import haxepunk.Entity;
import haxepunk.graphics.TextEntity;

class Package extends GameEntity
{
    public var destinationEntity:Building;
    public var buildingNumText:TextEntity;
    public var numPackagesText:TextEntity;
    public var costText:TextEntity;
    public var cost:Int;
    public var numOfPackages:Int;
    public var pickedByUnit:Unit;
    public var highlightTween:VarTween;
    public var highlightSprite:Spritemap;

    public function new(x:Float, y:Float, destinationEntity:Building, cost:Int)
    {
        super(x, y);

        this.destinationEntity = destinationEntity;
        highlightSprite = new Spritemap("graphics/sprites.png", 16, 16, 1, 1);
        highlightSprite.setFrameColRow(0, 3);

        highlightSprite.alpha = 0;
        addGraphic(highlightSprite);

        highlightTween = new VarTween();
        addTween(highlightTween);


        this.cost = cost;
        buildingNumText = new TextEntity(0, 0, "#" + Std.string(destinationEntity.buildingNum), 8);
        numPackagesText = new TextEntity(0, 0, "x1", 10);
        costText = new TextEntity(0, 0, Std.string(cost) + "$", 8);

        spriteMap.setFrameColRow(0, 2);

        buildingNumText.graphic.x = 2;
        buildingNumText.graphic.y = -3;
        addGraphic(buildingNumText.graphic);

        costText.graphic.x = 0;
        costText.graphic.y = 16;
        addGraphic(costText.graphic);

        setHitbox(16, 16);
        type = "interactable";
    }

    public function pickUp(pickedByEntity:Unit) 
    {
        pickedByUnit = pickedByEntity;

        //highlightTween.tween(highlightSprite, "alpha", 1.0, 1.0, Ease.circOut);
    }

    public function assigned() 
    {
        highlightTween.tween(highlightSprite, "alpha", 1.0, 1.0, Ease.circOut);
    }

    public function dropped() 
    {
        pickedByUnit = null;

        highlightTween.tween(highlightSprite, "alpha", 0.0, 1.0, Ease.circOut);
    }

    public function delivered() 
    {
        HXP.scene.remove(this);
    }

    override function update() 
    {
        super.update();

        if(pickedByUnit != null)
        {
            x = pickedByUnit.x;
            y = pickedByUnit.y - 10;
        }
        
    }
}