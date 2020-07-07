package dragonBones.animation;

import openfl.Vector;
	
import dragonBones.Armature;
import dragonBones.Slot;
import dragonBones.core.DragonBones;
import dragonBones.objects.ExtensionFrameData;
import dragonBones.objects.FFDTimelineData;
import dragonBones.objects.TimelineData;


/**
 * @private
 */
@:allow(dragonBones) @:final class FFDTimelineState extends TweenTimelineState
{
	public var slot:Slot;
	
	private var _ffdDirty:Bool;
	private var _tweenFFD:Int;
	private var _ffdVertices:Array<Float> = new Array<Float>();
	private var _durationFFDVertices:Array<Float> = new Array<Float>();
	private var _slotFFDVertices:Array<Float>;
	
	@:keep private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		super._onClear();
		
		slot = null;
		
		_ffdDirty = false;
		_tweenFFD = TweenTimelineState.TWEEN_TYPE_NONE;
		_ffdVertices.resize(0);
		_durationFFDVertices.resize(0);
		_slotFFDVertices = null;
	}
	
	override private function _onArriveAtFrame():Void
	{
		super._onArriveAtFrame();
		
		if (slot.displayIndex >= 0 && _animationState._isDisabled(slot)) 
		{
			_tweenEasing = DragonBones.NO_TWEEN;
			_curve = null;
			_tweenFFD = TweenTimelineState.TWEEN_TYPE_NONE;
			return;
		}
		
		var currentFrame:ExtensionFrameData = cast _currentFrame;
		
		_tweenFFD = TweenTimelineState.TWEEN_TYPE_NONE;
		
		if (_tweenEasing != DragonBones.NO_TWEEN || _curve != null)
		{
			var currentFFDVertices:Array<Float> = currentFrame.tweens;
			var nextFFDVertices:Array<Float> = cast(currentFrame.next, ExtensionFrameData).tweens;
			var l:UInt = currentFFDVertices.length;
			var duration:Float;
			for (i in 0...l)
			{
				duration = nextFFDVertices[i] - currentFFDVertices[i];
				_durationFFDVertices[i] = duration;
				if (duration != 0.0) 
				{
					_tweenFFD = TweenTimelineState.TWEEN_TYPE_ALWAYS;
				}
			}
		}
		
		if (_tweenFFD == TweenTimelineState.TWEEN_TYPE_NONE)
		{
			_tweenFFD = TweenTimelineState.TWEEN_TYPE_ONCE;
			var l = _durationFFDVertices.length;
			for (i in 0...l)
			{
				_durationFFDVertices[i] = 0.0;
			}
		}
	}
	
	override private function _onUpdateFrame():Void
	{
		super._onUpdateFrame();
		
		var tweenProgress:Float = 0.0;
		
		if (_tweenFFD != TweenTimelineState.TWEEN_TYPE_NONE && slot.parent._blendLayer >= _animationState._layer)
		{
			if (_tweenFFD == TweenTimelineState.TWEEN_TYPE_ONCE)
			{
				_tweenFFD = TweenTimelineState.TWEEN_TYPE_NONE;
				tweenProgress = 0.0;
			}
			else
			{
				tweenProgress = _tweenProgress;
			}
			
			var currentFFDVertices:Array<Float> = cast(_currentFrame, ExtensionFrameData).tweens;
			var l:UInt = currentFFDVertices.length;
			for (i in 0...l)
			{
				_ffdVertices[i] = currentFFDVertices[i] + _durationFFDVertices[i] * tweenProgress;
			}
			
			_ffdDirty = true;
		}
	}
	
	override public function _init(armature:Armature, animationState:AnimationState, timelineData:TimelineData):Void
	{
		super._init(armature, animationState, timelineData);
		
		_slotFFDVertices = slot._ffdVertices;
		
		var l:UInt = cast(_timelineData.frames[0], ExtensionFrameData).tweens.length;
		for (i in 0...l)
		{
			_ffdVertices.push(0.0);
		}
		
		l = _ffdVertices.length;
		for (i in 0...l)
		{
			_durationFFDVertices[i] = 0.0;
		}
	}
	
	override public function fadeOut():Void
	{
		_tweenFFD = TweenTimelineState.TWEEN_TYPE_NONE;
	}
	
	override public function update(passedTime:Float):Void
	{
		super.update(passedTime);
		
		if (slot._meshData != cast(_timelineData, FFDTimelineData).display.mesh) 
		{
			return;
		}
		
		// Fade animation.
		if (_tweenFFD != TweenTimelineState.TWEEN_TYPE_NONE || _ffdDirty)
		{
			var l:UInt;
			if (_animationState._fadeState != 0 || _animationState._subFadeState != 0)
			{
				var fadeProgress:Float = Math.pow(_animationState._fadeProgress, 4.0);
				
				l = _ffdVertices.length;
				for (i in 0...l)
				{
					_slotFFDVertices[i] += (_ffdVertices[i] - _slotFFDVertices[i]) * fadeProgress;
				}
				
				slot._meshDirty = true;
			}
			else if (_ffdDirty)
			{
				_ffdDirty = false;
				
				l = _ffdVertices.length;
				for (i in 0...l)
				{
					_slotFFDVertices[i] = _ffdVertices[i];
				}
				
				slot._meshDirty = true;
			}
		}
	}
}