package map;

import scenes.GameCompleteScene;
import scenes.GameOverScene;
import entities.UnitControllerEntity;
import scenes.EndDayScene;
import entities.FadeScreen;
import haxepunk.input.Input;
import UpgradeValue.PickUpTimeUpgrade;
import haxepunk.math.MathUtil;
import haxepunk.HXP;
import entities.ui.UICanvas;
import entities.EnemyAI;
import entities.CombatUnit;
import entities.Package;
import haxepunk.math.Random;
import haxepunk.math.Vector2;
import haxepunk.Entity;
import entities.DeliveryUnit;
import entities.Player;
import haxepunk.utils.Draw;
import haxepunk.ai.path.PathNode;
import entities.Building;
import haxepunk.masks.Grid;
import entities.TilemapEntity;
import haxepunk.ai.path.NodeGraph;

class LevelManager
{
    public static var mapWidthTiles:Int;
    public static var mapHeightTiles:Int;
    public static var mapWidth:Int;
    public static var mapHeight:Int;

    public var groundTileMap:TilemapEntity;
    //public var buildingsGrid:Grid;

    public static var player:Player;
    public var uiCanvas:UICanvas;

    public static var levelEndTimerCost:Int;
    public static var levelEndTimer:Float;

    public static var enemies:Array<EnemyAI>;

    public static var buildings:Array<Building> = new Array<Building>();

    public var pickedPosBuildingsArray:Array<Vector2> = new Array<Vector2>();
    var freePackagesPositions:Array<Vector2> = new Array<Vector2>();

    public static var pauseSimulation:Bool = false;
    public static var targetMoney:Int = 0;
    public static var currentLevel:Int = 1;
    
    public static var noSufficientFunds:Bool = false;
   

    public function new() 
    {
        generateLevel(1);
    }

    public function update() 
    {
        if(!Globals.gameScene.fadeScreen.alphaTween.active && !Globals.gameScene.startGame)
        {
            Globals.gameScene.startGame = true;
            pauseSimulation = false;
            Globals.gameScene.fadeScreen.imageRect.color = 0x000000;
        }

        if(!Globals.gameScene.startGame)
        {
            pauseSimulation = true;
            return;
        }

        //if(pauseSimulation)
        //{
        //    HXP.rate = 0;
        //}
        //else
        //{
        //    HXP.rate = 1;
        //}
        if(!pauseSimulation)
            levelEndTimer -= HXP.elapsed;
        if(levelEndTimer <= 0 || player.totalMoney >= targetMoney || 
            (player.totalMoney < targetMoney && player.totalMoney < player.combatUnitCost && enemies[0].combatUnits.length > 0 && player.deliveryUnits.length <= 0))
        {
            if(player.totalMoney < targetMoney && player.totalMoney < player.combatUnitCost && enemies[0].combatUnits.length > 0 && player.deliveryUnits.length <= 0)
            {
                noSufficientFunds = true;
            }
            endLevel();
            levelEndTimer = 0;
        }

        if(Input.pressed("pauseSimulation"))
        {
            //cleanAll();
            //buildNextLevel();
            pauseSimulation = !pauseSimulation;
            if(pauseSimulation)
            {
                Globals.gameScene.fadeScreen.startFadeTo(0.2, 0.0, 0.5);
            }
            else
            {
                Globals.gameScene.fadeScreen.startFadeTo(0.2, Globals.gameScene.fadeScreen.imageRect.alpha, 0.0);
            }
        }
    }

    public function cleanAll() 
    {
        Globals.gameScene.removeAll();
        Globals.gameScene.updateLists();
        //Globals.gameScene.updateTweens();
    }

    public function buildNextLevel() 
    {
        currentLevel++;
        generateLevel(currentLevel);
        Globals.gameScene.updateLists();
    }

    public function buildNewGame() 
    {
        currentLevel = 1;
        generateLevel(currentLevel);
        Globals.gameScene.updateLists();
    }

    public function render() 
    {

    }

    public function endLevel() 
    {
        if(player.totalMoney < targetMoney)
        {
            HXP.engine.pushScene(new GameOverScene());
        }
        else
        {
            if(currentLevel == 5)
                HXP.engine.pushScene(new GameCompleteScene());
            else
                HXP.engine.pushScene(new EndDayScene());
        }
    }

    public function generateLevel(level:Int)
    {
        UnitControllerEntity.uniqueOwnerIndex = 0;
        currentLevel = level;
        levelEndTimer = 5 * 60; // Seconds
        //levelEndTimer = 2;
        targetMoney = level * 1000;
        noSufficientFunds = false;
        switch(level)
        {
            case 1:
            {
                targetMoney = 100;
                levelEndTimerCost = 15;
            }
            case 2:
            {
                targetMoney = 200;
                levelEndTimerCost = 20;
            }
            case 3:
            {
                targetMoney = 350;
                levelEndTimerCost = 30;
            }
            case 4:
            {
                targetMoney = 450;
                levelEndTimerCost = 30;
            }
            case 5:
            {
                targetMoney = 600;
                levelEndTimerCost = 30;
            }
        }

        Globals.gameScene.fadeScreen = new FadeScreen();
        Globals.gameScene.fadeScreen.layer = -100;
        Globals.gameScene.add(Globals.gameScene.fadeScreen);

        


        enemies = new Array<EnemyAI>();




        mapWidthTiles = (20 + Random.randInt(5));
        mapHeightTiles = (20 + Random.randInt(5));

        mapWidth = mapWidthTiles * 16;
        mapHeight = mapHeightTiles * 16;


        player = new Player();
        Globals.gameScene.add(player);

       for (i in 0...1)
       {
           var unit = new DeliveryUnit(i * 18, 20, player);
           Globals.gameScene.add(unit);
           player.addOwnedUnit(unit);
       }

       //for (i in 0...2)
       //{
       //    var unit = new CombatUnit(i * 18, 40, player);
       //    Globals.gameScene.add(unit);
       //    player.addOwnedUnit(unit);
       //}

       //for (i in 0...2)
       //{
       //    var unit = new DeliveryUnit(i * 18, 60, player, true);
       //    Globals.gameScene.add(unit);
       //    player.addOwnedUnit(unit);
       //}

        var enemyAINum = 1;
        for(enemyAIInd in 0...enemyAINum)
        {
            addEnemyAI(level);
        }


        //buildingsGrid = new Grid(mapWidth, mapHeight, 16, 16);
        //buildingsGrid.setRect(0, 0, 15, 16, false);
        
        buildings = new Array<Building>();
        // Add buildings
        addBuildingsAndTerrain();
        


        // DEBUG SHIT
        //Globals.gameScene.add(new Entity(0, 0, null, buildingsGrid));
            
        // Generate the node graph.
        //nodeGraph = new NodeGraph();
        //nodeGraph.fromGrid(buildingsGrid, true);

        freePackagesPositions = new Array<Vector2>();
        generatePackagesPositions();
        addPackages(7);



        uiCanvas = new UICanvas();
        Globals.gameScene.add(uiCanvas);
    }

    public function addBuildingsAndTerrain() 
    {
        pickedPosBuildingsArray = new Array<Vector2>();

        groundTileMap = new TilemapEntity();
        groundTileMap.setTilemap(mapWidth, mapHeight);
        groundTileMap.tilemap.setRect(0, 0, Std.int(mapWidth / 16), Std.int(mapHeight / 16), 1 + 8 * 16);
        Globals.gameScene.add(groundTileMap);
        groundTileMap.layer = 20;

        var buildingsNum:Int = 5 + Random.randInt(4);

        var colOffset:Int = 7;
        var rowOffset:Int = 7;
        for (i in 0...buildingsNum)
        {
            var randCol = colOffset + Random.randInt(mapWidthTiles - colOffset - 2);
            var randRow = rowOffset + Random.randInt(mapHeightTiles - rowOffset - 2);
            var uniquePosBool:Bool = false;

            while(!uniquePosBool)
            {
                randCol = colOffset + Random.randInt(mapWidthTiles - colOffset - 2);
                randRow = rowOffset + Random.randInt(mapHeightTiles - rowOffset - 2);

                uniquePosBool = true;
                for (pickedPos in pickedPosBuildingsArray)
                {
                    if(MathUtil.abs(pickedPos.x - randCol) < 3 && MathUtil.abs(pickedPos.y - randRow) < 4)
                    {
                        uniquePosBool = false;
                        break;
                    }
                }
            }
            pickedPosBuildingsArray.push(new Vector2(randCol, randRow));
            buildings.push(new Building(16 * randCol, 16 * randRow, i));
        }
        
        
        for (pickedPos in pickedPosBuildingsArray)
        {
            // Top
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x - 1), Std.int(pickedPos.y - 2), 0 + 7 * 16);
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x), Std.int(pickedPos.y - 2), 1 + 7 * 16);
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x + 1), Std.int(pickedPos.y - 2), 2 + 7 * 16);

            // Mid
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x - 1), Std.int(pickedPos.y), 0 + 8 * 16);
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x), Std.int(pickedPos.y), 1 + 8 * 16);
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x + 1), Std.int(pickedPos.y), 2 + 8 * 16);
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x - 1), Std.int(pickedPos.y-1), 0 + 8 * 16);
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x), Std.int(pickedPos.y-1), 1 + 8 * 16);
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x + 1), Std.int(pickedPos.y-1), 2 + 8 * 16);

            // Bot
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x - 1), Std.int(pickedPos.y + 1), 0 + 9 * 16);
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x), Std.int(pickedPos.y + 1), 1 + 9 * 16);
            groundTileMap.tilemap.setTile(Std.int(pickedPos.x + 1), Std.int(pickedPos.y + 1), 2 + 9 * 16);
        }

        for (building in buildings)
        {
            Globals.gameScene.add(building);
        }
    }

    public function generatePackagesPositions() 
    {
        for (col in 0...(Std.int(mapWidth / 16)))
        {
            for (row in 0...(Std.int(mapHeight / 16)))
            {
                var uniquePosBool:Bool = true;

                for (pickedPos in pickedPosBuildingsArray)
                {
                    if(MathUtil.abs(pickedPos.x - col) < 2 && MathUtil.abs(pickedPos.y - row) < 3)
                    {
                        uniquePosBool = false;
                        break;
                    }
                }

                if(uniquePosBool)
                    freePackagesPositions.push(new Vector2(col, row));
            }
        }
    }

    public function addPackages(numPackages:Int)
    {
        var packageEnt:Package = new Package(160, 15, null, 1 + Random.randInt(5), -1);
        Globals.gameScene.add(packageEnt);


        // Take a random pos from the packages free pos.
        //for (packageInd in 0...numPackages)
        //{
        //    var randPosInd:Int = Random.randInt(freePackagesPositions.length);
        //    var posPicked:Vector2 = freePackagesPositions[randPosInd];
        //    
//
        //    var packageEnt:Package = new Package(posPicked.x * 16, posPicked.y * 16, 
        //                                         buildings[Random.randInt(buildings.length)],
        //                                          1 + Random.randInt(5), 1 + Random.randInt(8));
        //    Globals.gameScene.add(packageEnt);
//
//
        //    freePackagesPositions.remove(posPicked);
        //}
    }
    
    public function addEnemyAI(levelNum:Int) 
    {
        var enemy = new EnemyAI(levelNum);
        Globals.gameScene.add(enemy);

        //for (i in 0...1)
        //{
        //    var unit = new DeliveryUnit(i * 18, 90, enemy);
        //    Globals.gameScene.add(unit);
        //    enemy.addOwnedUnit(unit);
        //}
//
        //for (i in 0...4)
        //{
        //    var unit = new CombatUnit(i * 18, 140, enemy);
        //    Globals.gameScene.add(unit);
        //    enemy.addOwnedUnit(unit);
        //}

        enemies.push(enemy);
    }
}