package entities;

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

    public function new() 
    {
        super();

        selectedUnits = new Array<Unit>();

        selectionRect = new Rectangle(-1, 0, 0, 0);
        clampedSelectionRect = new Rectangle(-1);

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

        handleHoverUnits();

        // Multiple selection
        if(mouseDown)
        {
            if(selectionRect.x < 0)
            {
                selectionRect.x = Mouse.mouseX;
                selectionRect.y = Mouse.mouseY;
            }


            selectionRect.width = Mouse.mouseX - selectionRect.x;
            selectionRect.height = Mouse.mouseY - selectionRect.y;
            
            clampedSelectionRect.setTo(selectionRect.x, selectionRect.y, selectionRect.width, selectionRect.height);
            clampSelectionRect(clampedSelectionRect);
        }

        if(Mouse.mouseReleased)
        {

            // Select all the units in the selection region.
            handleMultipleSelectUnit();

            // Reset the selection rect.
            selectionRect.x = -1;
            clampedSelectionRect.x = -1;
        }

        if(middleMousePressed && selectedUnits.length > 0)
        {
            handleDispatchCommand();
        }
    }

    public function handleDispatchCommand()
    {
        // Figure out what command to send.
        var commandType:CommandType = CommandType.NONE;

        // Find what entities the mouse collides with here.
        var collidedEntity:Entity = null;
        collidedEntity = HXP.scene.collidePoint("interactable", Mouse.mouseX, Mouse.mouseY);

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