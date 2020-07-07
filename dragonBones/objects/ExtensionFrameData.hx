package dragonBones.objects;

import openfl.Vector;
	
/**
 * @private
 */
@:allow(dragonBones) @:final class ExtensionFrameData extends TweenFrameData
{
	public var tweens:Array<Float> = new Array<Float>();
	
	@:keep private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		tweens.resize(0);
	}
}