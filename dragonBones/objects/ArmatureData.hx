package dragonBones.objects;

import openfl.errors.ArgumentError;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

import dragonBones.core.BaseObject;
import dragonBones.enums.ArmatureType;
import dragonBones.geom.Transform;

/**
 * @language zh_CN
 * 骨架数据。
 * @see dragonBones.Armature
 * @version DragonBones 3.0
 */
@:allow(dragonBones) class ArmatureData extends BaseObject
{
	private static function _onSortSlots(a:SlotData, b:SlotData):Int
	{
		return a.zOrder > b.zOrder? 1: -1;
	}
	/**
	 * @language zh_CN
	 * 动画帧率。
	 * @version DragonBones 3.0
	 */
	public var frameRate:UInt;
	/**
	 * @private
	 */
	private var type:Int;
	/**
	 * @private
	 */
	private var cacheFrameRate:UInt;
	/**
	 * @private
	 */
	private var scale:Float;
	/**
	 * @language zh_CN
	 * 数据名称。
	 * @version DragonBones 3.0
	 */
	public var name:String;
	/**
	 * @private
	 */
	private var aabb:Rectangle = new Rectangle();
	/**
	 * @language zh_CN
	 * 所有骨骼数据。
	 * @see dragonBones.objects.BoneData
	 * @version DragonBones 3.0
	 */
	public var bones:Map<String, BoneData> = new Map<String, BoneData>();
	/**
	 * @language zh_CN
	 * 所有插槽数据。
	 * @see dragonBones.objects.SlotData
	 * @version DragonBones 3.0
	 */
	public var slots:Map<String, SlotData> = new Map<String, SlotData>();
	/**
	 * @language zh_CN
	 * 所有皮肤数据。
	 * @see dragonBones.objects.SkinData
	 * @version DragonBones 3.0
	 */
	public var skins:Map<String, SkinData> = new Map<String, SkinData>();
	/**
	 * @language zh_CN
	 * 所有动画数据。
	 * @see dragonBones.objects.AnimationData
	 * @version DragonBones 3.0
	 */
	public var animations:Map<String, AnimationData> = new Map<String, AnimationData>();
	/**
	 * @private
	 */
	private var actions: Array<ActionData> = new Array<ActionData>();
	/**
	 * @language zh_CN
	 * 所属的龙骨数据。
	 * @see dragonBones.DragonBonesData
	 * @version DragonBones 4.5
	 */
	public var parent:DragonBonesData;
	/**
	 * @private
	 */
	private var userData: CustomData;
	
	private var _boneDirty:Bool;
	private var _slotDirty:Bool;
	private var _animationNames:Array<String> = new Array<String>();
	private var _sortedBones:Array<BoneData> = new Array<BoneData>();
	private var _sortedSlots:Array<SlotData> = new Array<SlotData>();
	private var _bonesChildren:Map<String, Array<BoneData>> = new Map<String, Array<BoneData>>();
	private var _defaultSkin:SkinData;
	private var _defaultAnimation:AnimationData;
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
	override private function _onClear():Void
	{
		for (k in bones.keys())
		{
			bones[k].returnToPool();
		}
		
		for (k in slots.keys())
		{
			slots[k].returnToPool();
		}
		
		for (k in skins.keys())
		{
			skins[k].returnToPool();
		}
		
		for (k in animations.keys())
		{
			animations[k].returnToPool();
		}
		
		var l:UInt = actions.length;
		for (i in 0...l)
		{
			actions[i].returnToPool();
		}
		
		if (userData != null) 
		{
			userData.returnToPool();
		}
		
		frameRate = 0;
		type = ArmatureType.None;
		cacheFrameRate = 0;
		scale = 1.0;
		name = null;
		aabb.x = 0.0;
		aabb.y = 0.0;
		aabb.width = 0.0;
		aabb.height = 0.0;
		bones.clear();
		slots.clear();
		skins.clear();
		animations.clear();
		actions.resize(0);
		parent = null;
		userData = null;
		
		_boneDirty = false;
		_slotDirty = false;
		_animationNames.resize(0);
		_sortedBones.resize(0);
		_sortedSlots.resize(0);
		_bonesChildren.clear();
		_defaultSkin = null;
		_defaultAnimation = null;
	}
	
	private function _sortBones():Void
	{
		var total:UInt = _sortedBones.length;
		if (total == 0)
		{
			return;
		}
		
		var sortHelper:Array<BoneData> = _sortedBones.copy();
		var index:UInt = 0;
		var count:UInt = 0;
		
		_sortedBones.resize(0);
		var bone:BoneData;
		
		while(count < total)
		{
			bone = sortHelper[index++];
			
			if (index >= total)
			{
				index = 0;
			}
			
			if (_sortedBones.indexOf(bone) >= 0)
			{
				continue;
			}
			
			if (bone.parent != null && _sortedBones.indexOf(bone.parent) < 0)
			{
				continue;
			}
			
			if (bone.ik != null && _sortedBones.indexOf(bone.ik) < 0)
			{
				continue;
			}
			
			if (bone.ik != null && bone.chain > 0 && bone.chainIndex == bone.chain)
			{
				_sortedBones.insert(_sortedBones.indexOf(bone.parent) + 1, bone);
			}
			else
			{
				_sortedBones.push(bone);
			}
			
			count++;
		}
	}
	
	private function _sortSlots():Void
	{
		_sortedSlots.sort(_onSortSlots);
	}
	/**
	 * @private
	 */
	private function cacheFrames(value:UInt):Void
	{
		if (cacheFrameRate > 0) 
		{
			return;
		}
		
		cacheFrameRate = frameRate;
		
		for (animation in animations) 
		{
			animation.cacheFrames(cacheFrameRate);
		}
	}
	/**
	 * @private
	 */
	private function setCacheFrame(globalTransformMatrix: Matrix, transform: Transform):Int {
		var dataArray:Array<Float> = parent.cachedFrames;
		var arrayOffset:UInt = dataArray.length;
		
		dataArray.push(globalTransformMatrix.a);
		dataArray.push(globalTransformMatrix.b);
		dataArray.push(globalTransformMatrix.c);
		dataArray.push(globalTransformMatrix.d);
		dataArray.push(globalTransformMatrix.tx);
		dataArray.push(globalTransformMatrix.ty);
		dataArray.push(transform.skewX);
		dataArray.push(transform.skewY);
		dataArray.push(transform.scaleX);
		dataArray.push(transform.scaleY);
		
		return arrayOffset;
	}
	/**
	 * @private
	 */
	private function getCacheFrame(globalTransformMatrix: Matrix, transform: Transform, arrayOffset:Int):Void {
		var dataArray:Array<Float> = parent.cachedFrames;
		
		globalTransformMatrix.a = dataArray[arrayOffset];
		globalTransformMatrix.b = dataArray[arrayOffset + 1];
		globalTransformMatrix.c = dataArray[arrayOffset + 2];
		globalTransformMatrix.d = dataArray[arrayOffset + 3];
		globalTransformMatrix.tx = dataArray[arrayOffset + 4];
		globalTransformMatrix.ty = dataArray[arrayOffset + 5];
		transform.skewX = dataArray[arrayOffset + 6];
		transform.skewY = dataArray[arrayOffset + 7];
		transform.scaleX = dataArray[arrayOffset + 8];
		transform.scaleY = dataArray[arrayOffset + 9];
	}
	/**
	 * @private
	 */
	private function addBone(value:BoneData, parentName:String):Void
	{
		if (value != null && value.name != null && !bones.exists(value.name))
		{
			if (parentName != null)
			{
				var parent:BoneData = getBone(parentName);
				if (parent != null)
				{
					value.parent = parent;
				}
				
				if (_bonesChildren[parentName] == null)
				{
					_bonesChildren[parentName] = new Array<BoneData>();
				}
				
				_bonesChildren[parentName].push(value);
			}
			
			var children:Array<BoneData> = _bonesChildren[value.name];
			if (children != null)
			{
				var l :UInt= children.length;
				for (i in 0...l)
				{
					children[i].parent = value;
				}
				
				_bonesChildren.remove(value.name);
			}
			
			bones[value.name] = value;
			_sortedBones.push(value);
			
			_boneDirty = true;
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @private
	 */
	private function addSlot(value:SlotData):Void
	{
		if (value != null && value.name != null && slots[value.name] == null)
		{
			slots[value.name] = value;
			_sortedSlots.push(value);
			
			_slotDirty = true;
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @private
	 */
	private function addSkin(value:SkinData):Void
	{
		if (value != null && value.name != null && skins[value.name] == null)
		{
			skins[value.name] = value;
			
			if (_defaultSkin == null)
			{
				_defaultSkin = value;
			}
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @private
	 */
	private function addAnimation(value:AnimationData):Void
	{
		if (value != null && value.name != null && animations[value.name] == null)
		{
			animations[value.name] = value;
			_animationNames.push(value.name);
			
			if (_defaultAnimation == null)
			{
				_defaultAnimation = value;
			}
		}
		else
		{
			throw new ArgumentError();
		}
	}
	/**
	 * @language zh_CN
	 * 获取骨骼数据。
	 * @param name 骨骼数据名称。
	 * @see dragonBones.objects.BoneData
	 * @version DragonBones 3.0
	 */
	public function getBone(name:String):BoneData
	{
		return bones[name];
	}
	/**
	 * @language zh_CN
	 * 获取插槽数据。
	 * @param name 插槽数据名称。
	 * @see dragonBones.objects.SlotData
	 * @version DragonBones 3.0
	 */
	public function getSlot(name:String):SlotData
	{
		return slots[name];
	}
	/**
	 * @private
	 */
	private function getSkin(name:String):SkinData
	{
		return name != null? skins[name]: _defaultSkin;
	}
	/**
	 * @language zh_CN
	 * 获取动画数据。
	 * @param name 动画数据名称。
	 * @see dragonBones.objects.AnimationData
	 * @version DragonBones 3.0
	 */
	public function getAnimation(name:String):AnimationData
	{
		return name != null? animations[name]: _defaultAnimation;
	}
	/**
	 * @language zh_CN
	 * 所有动画数据名称。
	 * @see #armatures
	 * @version DragonBones 3.0
	 */
	public var animationNames(get, never):Array<String>;
	private function get_animationNames():Array<String> 
	{
		return _animationNames;
	}
	/**
	 * @private
	 */
	private var sortedBones(get, never):Array<BoneData>;
	private function get_sortedBones():Array<BoneData>
	{
		if (_boneDirty)
		{
			_boneDirty = false;
			_sortBones();
		}
		
		return _sortedBones;
	}
	/**
	 * @private
	 */
	private var sortedSlots(get, never):Array<SlotData>;
	private function get_sortedSlots():Array<SlotData>
	{
		if (_slotDirty)
		{
			_slotDirty = false;
			_sortSlots();
		}
		
		return _sortedSlots;
	}
	/**
	 * @private
	 */
	private var defaultSkin(get, never):SkinData;
	private function get_defaultSkin():SkinData
	{
		return _defaultSkin;
	}
	/**
	 * @language zh_CN
	 * 获取默认的动画数据。
	 * @see dragonBones.objects.AnimationData
	 * @version DragonBones 4.5
	 */
	public var defaultAnimation(get, never):AnimationData;
	private function get_defaultAnimation():AnimationData
	{
		return _defaultAnimation;
	}
}