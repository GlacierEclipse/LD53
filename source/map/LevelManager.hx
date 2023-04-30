package map;

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
    public static var mapWidth:Int;
    public static var mapHeight:Int;

    public var buildingsGrid:Grid;

    public static var nodeGraph:NodeGraph;

    public var player:Player;

    public function new() 
    {
        generateLevel(1);
    }

    public function update() 
    {
        
    }

    public function render() 
    {

    }

    public function generateLevel(level:Int)
    {
        mapWidth = 320;
        mapHeight = 240;


        player = new Player();
        Globals.gameScene.add(player);

        for (i in 0...10)
        {
            var unit = new DeliveryUnit(i * 18, 20);
            Globals.gameScene.add(unit);
            player.addOwnedUnit(unit);
        }


        buildingsGrid = new Grid(mapWidth, mapHeight, 16, 16);
        buildingsGrid.setRect(0, 0, 15, 16, false);
        
        var buildings:Array<Building> = new Array<Building>();
        // Add buildings

        
        var pickedPosArray:Array<Vector2> = new Array<Vector2>();


        for (i in 0...5)
        {
            var randCol = Random.randInt(20);
            var randRow = Random.randInt(15);
            var uniquePosBool:Bool = false;

            while(!uniquePosBool)
            {
                randCol = Random.randInt(20);
                randRow = Random.randInt(15);

                uniquePosBool = true;
                for (pickedPos in pickedPosArray)
                {
                    if(pickedPos.x == randCol && pickedPos.y == randRow)
                    {
                        uniquePosBool = false;
                        break;
                    }
                }
            }
            pickedPosArray.push(new Vector2(randCol, randRow));
            buildings.push(new Building(16 * randCol, 16 * randRow, i));
        }
        
        
        for (building in buildings)
        {
            buildingsGrid.setTile(Std.int(building.x / 16.0), Std.int(building.y / 16.0));
            Globals.gameScene.add(building);
        }

        // DEBUG SHIT
        Globals.gameScene.add(new Entity(0, 0, null, buildingsGrid));
            
        // Generate the node graph.
        nodeGraph = new NodeGraph();
        nodeGraph.fromGrid(buildingsGrid, true);


        for (i in 0...5)
        {
            var packageEnt:Package = new Package(Random.randFloat(320), Random.randFloat(160), 
                                              buildings[Random.randInt(buildings.length)],
                                              20);
            Globals.gameScene.add(packageEnt);
        }
    }
}