package dragonBones.objects;

import openfl.geom.Matrix;
import openfl.Vector;

import dragonBones.core.BaseObject;

/**
 * @private
 */
@:allow(dragonBones) @:final class MeshData extends BaseObject
{
	public var skinned:Bool;
	public var name:String;
	public var slotPose:Matrix = new Matrix();
	
	public var uvs:Array<Float> = new Array<Float>(); // vertices * 2
	public var vertices:Array<Float> = new Array<Float>(); // vertices * 2
	public var vertexIndices:Array<UInt> = new Array<UInt>(); // triangles * 3
	
	public var boneIndices:Array<Array<UInt>> = new Array<Array<UInt>>(); // vertices bones
	public var weights:Array<Array<Float>> = new Array<Array<Float>>(); // vertices bones
	public var boneVertices:Array<Array<Float>> = new Array<Array<Float>>(); // vertices bones * 2
	
	public var bones:Array<BoneData> = new Array<BoneData>(); // bones
	public var inverseBindPose:Array<Matrix> = new Array<Matrix>(); // bones
	
	@:keep private function new()
	{
		super();
	}
	
	override private function _onClear():Void
	{
		skinned = false;
		name = null;
		slotPose.identity();
		uvs.resize(0);
		vertices.resize(0);
		vertexIndices.resize(0);
		boneIndices.resize(0);
		weights.resize(0);
		boneVertices.resize(0);
		bones.resize(0);
		inverseBindPose.resize(0);
	}
}