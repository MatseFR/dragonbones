package dragonBones.objects;
	
/**
 * @private
 */
@:allow(dragonBones) @:final class AnimationFrameData extends FrameData
{
	
	public var actions:Array<ActionData> = new Array<ActionData>();
	public var events:Array<EventData> = new Array<EventData>();
	
	@:keep private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		var l:UInt = actions.length;
		for (i in 0...l)
		{
			actions[i].returnToPool();
		}
		
		l = events.length;
		for (i in 0...l)
		{
			events[i].returnToPool();
		}
		
		actions.resize(0);
		events.resize(0);
	}
}