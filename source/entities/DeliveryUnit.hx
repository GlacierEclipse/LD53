package entities;

import unit_managment.Command;
import unit_managment.Command.CommandType;
import haxepunk.Entity;

class DeliveryUnit extends Unit
{
    public function new(x:Float, y:Float, ownerController:UnitControllerEntity, hoarder:Bool = false) 
    {
        super(x, y, "graphics/sprites.png", ownerController);
        spriteMap.index = 0;

        hp = 2;

        type = "deliveryUnit";

        spriteMap.setFrameColRow(6, 11 + ownerIndex);

        //this.hoarder = hoarder;

        //if(hoarder)
        //{
        //    spriteMap.setFrameColRow(8, 11 + ownerIndex);
        //    speed = 20;
        //}

        pickedUpPackage = false;
    }
    
    override function initVarsBasedOnVeterancy() 
    {
        switch(unitVeterancy)
        {
            case 0:
            {
                hp = 2;
                speed = 80;
                hoarderNumPackages = 1;
            }

            case 1:
            {
                hp = 3;
                speed = 90;
                hoarderNumPackages = 1;
            }

            case 2:
            {
                hp = 2;
                speed = 40;
                hoarderNumPackages = 1;
            }

            case 3:
            {
                hp = 2;
                speed = 40;
                hoarderNumPackages = 1;
            }

            case 4:
            {
                hp = 2;
                speed = 40;
                hoarderNumPackages = 1;
            }

            case 5:
            {
                hp = 2;
                speed = 40;
                hoarderNumPackages = 1;
            }

            case 6:
            {
                hp = 2;
                speed = 40;
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
            if(Std.is(interactWithEntity, DeliveryUnit))
            {
                // Do nothing?? 
            }

            if(Std.is(interactWithEntity, Package) && !pickedUpPackage)
            {
                // Dispatch start delivery.
                dispatchTakeDeliveryCommand(interactWithEntity);
            }

            if(Std.is(interactWithEntity, Building) && pickedUpPackage && 
               currentPickedPackage.destinationEntity.buildingNum == cast(interactWithEntity, Building).buildingNum)
            {
                // Dispatch start delivery.
                dispatchDeliverCommand(currentPickedPackage);
            }
        }
        
    }

    override function handleDeliver(command:Command) 
    {
        super.handleDeliver(command);
    }

    override function dispatchDeliverCommand(interactWithEntity:Entity) 
    {
        super.dispatchDeliverCommand(interactWithEntity);
    }
}