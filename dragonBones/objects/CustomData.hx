package dragonBones.objects;

import openfl.Vector;
	
import dragonBones.core.BaseObject;

/**
 * @language zh_CN
 * 自定义数据。
 * @version DragonBones 5.0
 */
@:allow(dragonBones) @:final class CustomData extends BaseObject
{
	/**
	 * @language zh_CN
	 * 自定义整数。
	 * @version DragonBones 5.0
	 */
	public var ints: Array<Float> = new Array<Float>();
	/**
	 * @language zh_CN
	 * 自定义浮点数。
	 * @version DragonBones 5.0
	 */
	public var floats: Array<Float> = new Array<Float>();
	/**
	 * @language zh_CN
	 * 自定义字符串。
	 * @version DragonBones 5.0
	 */
	public var strings: Array<String> = new Array<String>();
	/**
	 * @private
	 */
	@:keep private function new()
	{
		super();
	}
	/**
	 * @private
	 */
	override private function _onClear():Void {
		ints.resize(0);
		floats.resize(0);
		strings.resize(0);
	}
	/**
	 * @language zh_CN
	 * 获取自定义整数。
	 * @version DragonBones 5.0
	 */
	public function getInt(index:Int = 0):Float 
	{
		return index >= 0 && index < ints.length ? ints[index] : 0;
	}
	/**
	 * @language zh_CN
	 * 获取自定义浮点数。
	 * @version DragonBones 5.0
	 */
	public function getFloat(index:Int = 0):Float 
	{
		return index >= 0 && index < floats.length ? floats[index] : 0;
	}
	/**
	 * @language zh_CN
	 * 获取自定义字符串。
	 * @version DragonBones 5.0
	 */
	public function getString(index:Int = 0): String 
	{
		return index >= 0 && index < strings.length ? strings[index] : null;
	}
}