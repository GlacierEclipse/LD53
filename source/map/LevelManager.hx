package map;

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

        var buildings:Array<Building> = new Array<Building>();
        // Add buildings
        buildings.push(new Building(16 * 4, 16 * 3));


        for (building in buildings)
        {
            buildingsGrid.setTile(Std.int(building.x / 16.0), Std.int(building.y / 16.0));
            Globals.gameScene.add(building);
        }

        // Generate the node graph.
        nodeGraph = new NodeGraph();
        nodeGraph.fromGrid(buildingsGrid, true);
    }
}