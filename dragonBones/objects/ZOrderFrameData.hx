package dragonBones.objects;
	
/**
 * @private
 */
@:allow(dragonBones) @:final class ZOrderFrameData extends FrameData
{
	public var zOrder:Array<Int> = new Array<Int>();
	
	@:keep private function new()
	{
		super();
	}
	
	override private function _onClear():Void 
	{
		super._onClear();
		
		zOrder.resize(0);
	}
}