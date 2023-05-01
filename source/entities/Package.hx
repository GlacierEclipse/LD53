package entities;

import haxepunk.math.Random;
import map.LevelManager;
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
    public var breakTween:VarTween;
    public var highlightSprite:Spritemap;
    public var removedFromScene:Bool;
    public var assignedToEnt:Bool;
    public var cache:Bool;

    public function new(x:Float, y:Float, destinationEntity:Building, cost:Int, numPackages:Int)
    {
        super(x, y);

        if(numPackages == -1)
            cache = true;


        this.destinationEntity = destinationEntity;
        highlightSprite = new Spritemap("graphics/sprites.png", 16, 16, 1, 1);
        highlightSprite.setFrameColRow(0, 3);

        highlightSprite.alpha = 0;
        addGraphic(highlightSprite);

        highlightTween = new VarTween();
        addTween(highlightTween);

        breakTween = new VarTween();
        breakTween.onComplete.bind(function() {
            Globals.gameScene.remove(this);
        });
        addTween(breakTween);

        this.numOfPackages = numPackages;

        this.cost = cost;
        if(!cache)
        {
            buildingNumText = new TextEntity(0, 0, "#" + Std.string(destinationEntity.buildingNum), 8);
            numPackagesText = new TextEntity(0, 0, Std.string(numOfPackages), 10);
            numPackagesText.textBitmap.color = 0x493721;
            costText = new TextEntity(0, 0, Std.string(cost) + "$", 8);
        }

        spriteMap.setFrameColRow(0, 2);

        if(!cache)
        {
            buildingNumText.graphic.x = 2;
            buildingNumText.graphic.y = 18;
            addGraphic(buildingNumText.graphic);
        }

        if(!cache)
        {
            costText.graphic.x = 3;
            costText.graphic.y = -2;
            addGraphic(costText.graphic);
        }

        if(numOfPackages > 1)
        {
            numPackagesText.graphic.x = 5;
            numPackagesText.graphic.y = 9;
            addGraphic(numPackagesText.graphic);
        }

        setHitbox(16, 16);
        type = "package";

        removedFromScene = false;

        layer = 2;

        if(cache)
        {
            name = "packageLord";
            spriteMap.scaleX = 3;
            spriteMap.scaleY = 2;
            setHitbox(16 * 3, 32);
            spriteMap.centerOrigin();
            centerOrigin();
        }
    }

    public function pickUp(pickedByEntity:Unit) : Package
    {
        layer = 0;
        
        if(cache)
        {
            return createNewPackage(pickedByEntity);
        }
        if(numOfPackages > 1)
        {
            if(numOfPackages - pickedByEntity.hoarderNumPackages > 0)
            {
                // Pick only the amount the hoarder can and drop the rest.
                numOfPackages -= pickedByEntity.hoarderNumPackages;
                drop();
                // Split the package.
                return splitPackage(pickedByEntity, pickedByEntity.hoarderNumPackages);
                
            }
        }

        // Hoarder unit can pick this up.

        highlightSprite.color = 0xFFFFFF;
        pickedByUnit = pickedByEntity;
        
        //highlightTween.tween(highlightSprite, "alpha", 1.0, 1.0, Ease.circOut);
        return this;
    }

    public function assigned() 
    {
        if(cache)
            return;
        assignedToEnt = true;
        highlightSprite.color = 0xFFD5A5;
        highlightTween.tween(highlightSprite, "alpha", 1.0, 1.0, Ease.circOut);
    }

    public function drop() 
    {
        assignedToEnt = false;
        highlightSprite.color = 0xFFFFFF;
        pickedByUnit = null;

        highlightTween.tween(highlightSprite, "alpha", 0.0, 1.0, Ease.circOut);


    }

    public function delivered() 
    {
        removedFromScene = true;
        HXP.scene.remove(this);
    }

    public function splitPackage(pickedByEntity:Unit, amountOfPackages:Int) : Package
    {
        var packageEnt:Package = new Package(x, y, destinationEntity, cost, amountOfPackages);
        Globals.gameScene.add(packageEnt);
        // auto pick it and set the unit on it.
        packageEnt.pickUp(pickedByEntity);
        return packageEnt;
    }

    public function createNewPackage(pickedByEntity:Unit) : Package
    {
        var packageEnt:Package = new Package(x, y, LevelManager.buildings[Random.randInt(LevelManager.buildings.length)], 
                                            1 + Random.randInt(Std.int(LevelManager.player.costChanceUpgrade.getRawValue())),
                                            1);
        Globals.gameScene.add(packageEnt);
        // auto pick it and set the unit on it.
        packageEnt.pickUp(pickedByEntity);
        return packageEnt;
    }

    override function update() 
    {
        super.update();

        if(pickedByUnit != null)
        {
            x = pickedByUnit.x;
            y = pickedByUnit.y - 10;
        }

        if(!cache)
        {
        numPackagesText.currentText = Std.string(numOfPackages);
        if(numOfPackages <= 1)
            numPackagesText.currentText = "";
    }
        
    }
}