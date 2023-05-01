package entities.ui;

import haxepunk.math.MathUtil;
import map.LevelManager;
import haxepunk.graphics.TextEntity;
import haxepunk.graphics.Image;
import haxepunk.Entity;

enum UpgradeUIElementType 
{
    DELIVERY_UNIT_AMOUNT;
    COMBAT_UNIT_AMOUNT;
    PICKUP_TIME;
    TIME_ADD;
    COST_CHANCE;
    DELIVERY_UPGRADE;
    COMBAT_UPGRADE;
}
class UpgradeUIElement
{
    public var uiBuyButton:UIBuyButton;
    public var uiCostText:TextEntity;
    public var uiStatusText:TextEntity;
    public var upgradeValue:UpgradeValue;
    public var upgradeType:UpgradeUIElementType;

    public function new() 
    {
        
    }
}

class UICanvas extends Entity
{
    public var uiRectPlayer:Image;
    public var uiRectEnemy:Image;

    public var uiPlayerTextTotalMoney:TextEntity;
    public var uiTimeLeftText:TextEntity;
    public var uiTargetMoney:TextEntity;


    public var uiUpgradeElements:Array<UpgradeUIElement>;

    public var elements:Int = 6;
    public var targetYUI = 240 - 34;


    public function new() 
    {
        super(0, 0);

        targetYUI = 240 - 34 - Std.int(elements * 12.7);

        layer = -120;
        uiRectPlayer = new Image("graphics/UIRect.png");
        uiRectPlayer.x = -15;
        uiRectPlayer.y = targetYUI;
        addGraphic(uiRectPlayer);

 
        uiTimeLeftText = new TextEntity(0, 0, "Time Left: ", 8);
        uiTimeLeftText.graphic.x = 2;
        uiTimeLeftText.graphic.y = targetYUI - 4;
        addGraphic(uiTimeLeftText.graphic);

        uiTargetMoney = new TextEntity(0, 0, "Target: " + LevelManager.targetMoney + "$", 8);
        uiTargetMoney.graphic.x = 95;
        uiTargetMoney.graphic.y = 240 - 10;

        addGraphic(uiTargetMoney.graphic);



                
        uiPlayerTextTotalMoney = new TextEntity(0, 0, "", 8);
        uiPlayerTextTotalMoney.graphic.x = 2;
        uiPlayerTextTotalMoney.graphic.y = 240 - 10;
        addGraphic(uiPlayerTextTotalMoney.graphic);



        uiUpgradeElements = new Array<UpgradeUIElement>();
        var rowYY:Float = 240 - 25;
        var rowYYY:Float = 12;
        addUpgradeRow(2, rowYY, DELIVERY_UNIT_AMOUNT);
        rowYY -= rowYYY;
        addUpgradeRow(2, rowYY, COMBAT_UNIT_AMOUNT);
        rowYY -= rowYYY;
        addUpgradeRow(2, rowYY, PICKUP_TIME);
        rowYY -= rowYYY;
        addUpgradeRow(2, rowYY, TIME_ADD);
        rowYY -= rowYYY;
        addUpgradeRow(2, rowYY, COST_CHANCE);
        rowYY -= rowYYY;
        addUpgradeRow(2, rowYY, DELIVERY_UPGRADE);
        rowYY -= rowYYY;
        addUpgradeRow(2, rowYY, COMBAT_UPGRADE);

        uiRectEnemy = new Image("graphics/UIRect.png");
        uiRectEnemy.x = 230;
        uiRectEnemy.y = 240 - 65;
        //addGraphic(uiRectEnemy);



        

        graphic.scrollX = 0;
        graphic.scrollY = 0;

        // Run a single update to update texts.
        update();
    }

    public function addUpgradeRow(x:Float, y:Float, upgradeType:UpgradeUIElementType)
    {
        var newElem = new UpgradeUIElement();

        newElem.upgradeType = upgradeType;

        newElem.uiStatusText = new TextEntity(0, 0, "", 8);
        newElem.uiStatusText.graphic.x = x;
        newElem.uiStatusText.graphic.y = y;
        addGraphic(newElem.uiStatusText.graphic);

        if(upgradeType == DELIVERY_UNIT_AMOUNT)
            newElem.uiBuyButton = new UIBuyButton(x + 110, y - 3, buyDeliveryUnit);

        if(upgradeType == COMBAT_UNIT_AMOUNT)
            newElem.uiBuyButton = new UIBuyButton(x + 110, y - 3, buyCombatUnit);

        if(upgradeType == TIME_ADD)
            newElem.uiBuyButton = new UIBuyButton(x + 110, y - 3, buyCombatUnit);

        if(upgradeType == PICKUP_TIME)
        {
            newElem.uiBuyButton = new UIBuyButton(x + 110, y - 3, buyPickUpTime);
            newElem.upgradeValue = LevelManager.player.pickupTimeUpgrade;
        }

        if(upgradeType == COST_CHANCE)
        {
            newElem.uiBuyButton = new UIBuyButton(x + 110, y - 3, buyPickUpTime);
            newElem.upgradeValue = LevelManager.player.costChanceUpgrade;
        }

        if(upgradeType == DELIVERY_UPGRADE)
        {
            newElem.uiBuyButton = new UIBuyButton(x + 110, y - 3, buyPickUpTime);
            newElem.upgradeValue = LevelManager.player.deliveryUnitUpgrade;
        }

        if(upgradeType == COMBAT_UPGRADE)
        {
            newElem.uiBuyButton = new UIBuyButton(x + 110, y - 3, buyPickUpTime);
            newElem.upgradeValue = LevelManager.player.combatUnitUpgrade;
        }

        newElem.uiBuyButton.layer = layer;
        newElem.uiBuyButton.spriteMap.scrollX = newElem.uiBuyButton.spriteMap.scrollY = 0;
        Globals.gameScene.add(newElem.uiBuyButton);

        // Cost
        newElem.uiCostText = new TextEntity(0, 0, "", 8);
        newElem.uiCostText.graphic.x = x + 125;
        newElem.uiCostText.graphic.y = y;
        addGraphic(newElem.uiCostText.graphic);


        uiUpgradeElements.push(newElem);
    }

    override function update() 
    {
        super.update();

        uiPlayerTextTotalMoney.currentText = "Total: " + Std.string(MathUtil.round(LevelManager.player.renderMoney)) + "$";

        for (uiUpgradeElement in uiUpgradeElements)
        {
            if(uiUpgradeElement.upgradeType == DELIVERY_UNIT_AMOUNT)
            {
                uiUpgradeElement.uiStatusText.currentText = "Delivery Units: " + Std.string(LevelManager.player.deliveryUnits.length);
                uiUpgradeElement.uiCostText.currentText = "-" + Std.string(LevelManager.player.deliveryUnitCost) + "$";

                uiUpgradeElement.uiBuyButton.canClick = LevelManager.player.totalMoney >= LevelManager.player.deliveryUnitCost;
            }
    
            else if(uiUpgradeElement.upgradeType == COMBAT_UNIT_AMOUNT)
            {
                uiUpgradeElement.uiStatusText.currentText = "Combat Units: " + Std.string(LevelManager.player.combatUnits.length);
                uiUpgradeElement.uiCostText.currentText = "-" + Std.string(LevelManager.player.combatUnitCost) + "$";
                uiUpgradeElement.uiBuyButton.canClick = LevelManager.player.totalMoney >= LevelManager.player.combatUnitCost;
            }
    
            else if(uiUpgradeElement.upgradeType == TIME_ADD)
            {
                uiUpgradeElement.uiStatusText.currentText = "Add 45s";
                uiUpgradeElement.uiCostText.currentText = "-" + Std.string(LevelManager.levelEndTimerCost) + "$";
                uiUpgradeElement.uiBuyButton.canClick = LevelManager.player.totalMoney >= LevelManager.levelEndTimerCost;
            }
            else
            {
                if(uiUpgradeElement.upgradeType == PICKUP_TIME)
                    uiUpgradeElement.uiStatusText.currentText = "Pick up Speed: ";
                
                else if(uiUpgradeElement.upgradeType == COST_CHANCE)
                    uiUpgradeElement.uiStatusText.currentText = "Cost Chance: ";

                else if(uiUpgradeElement.upgradeType == DELIVERY_UPGRADE)
                    uiUpgradeElement.uiStatusText.currentText = "Delivery Upgrade: ";
                
                else if(uiUpgradeElement.upgradeType == COMBAT_UPGRADE)
                    uiUpgradeElement.uiStatusText.currentText = "Combat Upgrade: ";
                


                uiUpgradeElement.uiStatusText.currentText += Std.string(uiUpgradeElement.upgradeValue.upgradeLevel.currentValue) + "/" + Std.string(uiUpgradeElement.upgradeValue.upgradeLevel.maxValue);

                uiUpgradeElement.uiCostText.currentText = "-" + Std.string(uiUpgradeElement.upgradeValue.cost) + "$";
            }

            if(uiUpgradeElement.upgradeValue != null)
            {
                if(uiUpgradeElement.upgradeValue.canBuy(LevelManager.player.totalMoney))
                {
                    uiUpgradeElement.uiBuyButton.canClick = true;
                }
                else
                {
                    uiUpgradeElement.uiBuyButton.canClick = false;
                }
            }
        }

        
        var mins:Int = Std.int(LevelManager.levelEndTimer / 60.0);
        var seconds:Int = Std.int(LevelManager.levelEndTimer - mins * 60);
        uiTimeLeftText.currentText = "Time Left: " + "0" + Std.string(mins) + ":" + ((seconds < 10) ? "0" : "") + Std.string(seconds);

    }

    public function buyDeliveryUnit() 
    {
        LevelManager.player.buyDeliveryUnit(20);
    }

    public function buyCombatUnit() 
    {
        LevelManager.player.buyCombatUnit(20);
    }

    public function buyPickUpTime() 
    {
        LevelManager.player.pickupTimeUpgrade.upgrade();
        LevelManager.player.totalMoney -= LevelManager.player.pickupTimeUpgrade.cost;
    }

    public function buyTimeAdd() 
    {
        LevelManager.levelEndTimer += 45;
        LevelManager.player.totalMoney -= LevelManager.levelEndTimerCost;
    }

    public function buyCostChance() 
    {
        LevelManager.player.costChanceUpgrade.upgrade();
        LevelManager.player.totalMoney -= LevelManager.player.costChanceUpgrade.cost;
    }

    public function buyDeliveryUpgrade() 
    {
        LevelManager.player.deliveryUnitUpgrade.upgrade();
        LevelManager.player.totalMoney -= LevelManager.player.deliveryUnitUpgrade.cost;

        for (unit in LevelManager.player.deliveryUnits)
        {
            unit.unitVeterancy = Std.int(LevelManager.player.deliveryUnitUpgrade.upgradeLevel.currentValue);
            unit.initVarsBasedOnVeterancy();
        }
    }

    public function buyCombatUpgrade() 
    {
        LevelManager.player.combatUnitUpgrade.upgrade();
        LevelManager.player.totalMoney -= LevelManager.player.combatUnitUpgrade.cost;

        for (unit in LevelManager.player.combatUnits)
        {
            unit.unitVeterancy = Std.int(LevelManager.player.deliveryUnitUpgrade.upgradeLevel.currentValue);
            unit.initVarsBasedOnVeterancy();
        }
    }
}