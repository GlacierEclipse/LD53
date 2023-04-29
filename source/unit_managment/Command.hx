package unit_managment;

import haxepunk.math.Vector2;
import haxepunk.Entity;

enum CommandType 
{
    NONE;
    IDLE;
    GOTO;
    DELIVER;
    ATTACK;
    DEFEND;
}

class Command
{
    public var commandType:CommandType = IDLE;
    public var targetPos:Vector2 = new Vector2();
    public var targetEntity:Entity = null;

    public function new(commandType:CommandType) 
    {
        this.commandType = commandType;
    }


}