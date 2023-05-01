package entities;

import haxepunk.input.Input;
import map.LevelManager;
import haxepunk.math.Vector2;
import haxepunk.math.Random;
import haxepunk.Entity;
import haxepunk.HXP;
import unit_managment.Command.CommandType;
import haxepunk.math.MathUtil;
import haxepunk.utils.Draw;
import haxepunk.Camera;
import haxepunk.math.Rectangle;
import haxepunk.input.Mouse;

class Player extends UnitControllerEntity
{
    public var selectedUnits:Array<Unit>;
    public var selectionRect:Rectangle;
    public var clampedSelectionRect:Rectangle;
    public var packages:Array<Package>;
    public var cameraPos:Vector2;

    public function new() 
    {
        super();

        selectedUnits = new Array<Unit>();

        selectionRect = new Rectangle(-1, 0, 0, 0);
        clampedSelectionRect = new Rectangle(-1);
        cameraPos = new Vector2();

        //visible = false;
    }
    
    override function update() 
    {
        super.update();

        handleInput();
    }

    public function handleInput()
    {
        var mouseDown:Bool = Mouse.mouseDown;
        var middleMousePressed:Bool = Mouse.middleMousePressed;

        //handleHoverUnits();


        handleCamera();

        // Multiple selection
        //if(mouseDown)
        //{
        //    if(selectionRect.x < 0)
        //    {
        //        selectionRect.x = Mouse.mouseX;
        //        selectionRect.y = Mouse.mouseY;
        //    }
//
//
        //    selectionRect.width = Mouse.mouseX - selectionRect.x;
        //    selectionRect.height = Mouse.mouseY - selectionRect.y;
        //    
        //    clampedSelectionRect.setTo(selectionRect.x, selectionRect.y, selectionRect.width, selectionRect.height);
        //    clampSelectionRect(clampedSelectionRect);
        //}
//
        //if(Mouse.mouseReleased)
        //{
//
        //    // Select all the units in the selection region.
        //    handleMultipleSelectUnit();
//
        //    // Reset the selection rect.
        //    selectionRect.x = -1;
        //    clampedSelectionRect.x = -1;
        //}
//
        //if(middleMousePressed && selectedUnits.length > 0)
        //{
        //    handleDispatchCommand();
        //}


        // Find a random package to take.
        packages = new Array<Package>();
        HXP.scene.getType("package", packages);
    
        // Sort packages by price.
    
        packages.sort(function(packageA:Package, packageB:Package) :Int {
            if(packageA.cost * packageA.numOfPackages > packageB.cost * packageB.numOfPackages)
                return 1;
            else if (packageA.cost * packageA.numOfPackages < packageB.cost * packageB.numOfPackages)
                return -1;
            return 0;
        });
    
        // Man this is gonna be fun..
    
        // Then delivery
        for(deliveryUnit in deliveryUnits)
        {
            handleAIForDeliveryUnit(cast deliveryUnit);
        }
    
        // Then combat
        for(combatUnit in combatUnits)
        {
            handleAIForCombatUnit(cast combatUnit);
        }
    }

    public function handleCamera() 
    {
        var cameraSpeed:Float = 2;
        if(Input.check("moveLeft"))
        {
            cameraPos.x -= cameraSpeed;
        }

        if(Input.check("moveRight"))
        {
            cameraPos.x += cameraSpeed;
        }

        if(Input.check("moveDown"))
        {
            cameraPos.y += cameraSpeed;
        }

        if(Input.check("moveUp"))
        {
            cameraPos.y -= cameraSpeed;
        }

        cameraPos.x = MathUtil.clamp(cameraPos.x, 0, LevelManager.mapWidth - 320);
        cameraPos.y = MathUtil.clamp(cameraPos.y, 0, LevelManager.mapHeight - 240);

        HXP.camera.x = MathUtil.lerp(HXP.camera.x, cameraPos.x, 0.08);
        HXP.camera.y = MathUtil.lerp(HXP.camera.y, cameraPos.y, 0.08);

        //HXP.camera.x = MathUtil.clamp(HXP.camera.x, 0, LevelManager.mapWidth - 320);
        //HXP.camera.y = MathUtil.clamp(HXP.camera.y, 0, LevelManager.mapHeight - 240);


    }

    public function handleDispatchCommand()
    {
        // Figure out what command to send.
        var commandType:CommandType = CommandType.NONE;

        // Find what entities the mouse collides with here.
        var collidedEntity:Entity = null;
        collidedEntity = HXP.scene.collidePoint("interactable", Mouse.mouseX, Mouse.mouseY);

        if(collidedEntity == null)
            collidedEntity = HXP.scene.collidePoint("unit", Mouse.mouseX, Mouse.mouseY);

        if(collidedEntity == null)
            collidedEntity = HXP.scene.collidePoint("deliveryUnit", Mouse.mouseX, Mouse.mouseY);

        if(collidedEntity == null)
            collidedEntity = HXP.scene.collidePoint("combatUnit", Mouse.mouseX, Mouse.mouseY);

        if(collidedEntity == null)
            collidedEntity = HXP.scene.collidePoint("building", Mouse.mouseX, Mouse.mouseY);

        if(collidedEntity == null)
            collidedEntity = HXP.scene.collidePoint("package", Mouse.mouseX, Mouse.mouseY);

        for (selectedUnit in selectedUnits)
        {
            selectedUnit.dispatchCommand(collidedEntity, Mouse.mouseX, Mouse.mouseY);
        }
    }

    public function clampSelectionRect(selectionRect:Rectangle) 
    {
        // Clamp the selection rect
        if(selectionRect.width < 0)
        {
            selectionRect.x = selectionRect.x + selectionRect.width;
            selectionRect.width = MathUtil.abs(selectionRect.width);
        }
        
        if(selectionRect.height < 0)
        {
            selectionRect.y = selectionRect.y + selectionRect.height;
            selectionRect.height = MathUtil.abs(selectionRect.height);
        }
    }

    public function handleHoverUnits()
    {
        var highlight:Bool = true;

        for (unit in ownedUnits)
        {
            if(clampedSelectionRect.x < 0)
            {
                if(!unit.selected && unit.collidePoint(unit.x, unit.y, Mouse.mouseX, Mouse.mouseY))
                {
                    unit.highlight();
                    break;
                }
            }
            else
            {
                if(unit.collideRect(unit.x, unit.y, clampedSelectionRect.x, clampedSelectionRect.y, clampedSelectionRect.width, clampedSelectionRect.height))
                {
                    unit.highlight();
                }
            }
        }
    }

    public function handleMultipleSelectUnit()
    {
        // Clear selected units and add this one.
        // Add to selected units.

        unselectUnits();

        for (unit in ownedUnits)
        {
            if(unit.collideRect(unit.x, unit.y, clampedSelectionRect.x, clampedSelectionRect.y, clampedSelectionRect.width, clampedSelectionRect.height))
            {
                selectedUnits.push(unit);
                unit.select();
            }
        }
    }

    public function unselectUnits() 
    {
        for (selectedUnit in selectedUnits)
        {
            selectedUnit.unSelect();
        }
        selectedUnits.splice(0, selectedUnits.length);
    }

    override function render(camera:Camera) 
    {
        super.render(camera);

        if(selectionRect.x > 0)
            Draw.rect(selectionRect.x, selectionRect.y, selectionRect.width, selectionRect.height);
    }
}