package entities;

import haxepunk.graphics.tile.Tilemap;
import haxepunk.Entity;

class TilemapEntity extends Entity
{
    public var tilemap:Tilemap;

    public function new() 
    {
        super(0, 0);
    }

    public function setTilemap(mapWidth:Int, mapHeight:Int, tileWidth:Int = 16, tileHeight:Int = 16)
    {
        tilemap = new Tilemap("graphics/sprites.png", mapWidth, mapHeight, tileWidth, tileHeight);
        graphic = tilemap;
        
    }
}