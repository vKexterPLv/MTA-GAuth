//
// Example shader - hud_mask.fx
//

#include "tex_matrix.fx"

///////////////////////////////////////////////////////////////////////////////
// Global variables
///////////////////////////////////////////////////////////////////////////////
texture sPicTexture;
texture sMaskTexture;

float2 gUVPrePosition = float2( 0, 0 );
float2 gUVScale = float( 1 );                     // UV scale
float2 gUVScaleCenter = float2( 0.5, 0.5 );
float gUVRotAngle = float( 0 );                   // UV Rotation
float2 gUVRotCenter = float2( 0.5, 0.5 );
float2 gUVPosition = float2( 0, 0 );              // UV position
float3 filterRGB = 0;
float filterRange = 0.05;
bool isPixelated = false;

///////////////////////////////////////////////////////////////////////////////
// Samplers
///////////////////////////////////////////////////////////////////////////////


SamplerState sourceSampler{
	Texture = sPicTexture;
	MinFilter = 2;
	MagFilter = 2;
	MipFilter = 2;
	AddressU = Wrap;
	AddressV = Wrap;
};

SamplerState sourceSamplerPixelated{
	Texture = sPicTexture;
	MinFilter = 1;
	MagFilter = 1;
	MipFilter = 1;
	AddressU = Wrap;
	AddressV = Wrap;
};

///////////////////////////////////////////////////////////////////////////////
// Functions
///////////////////////////////////////////////////////////////////////////////

//-------------------------------------------
// Removes some RGB color
//-------------------------------------------

float4 maskBGFilter(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
	float4 sampledTexture = isPixelated?tex2D(sourceSamplerPixelated,tex):tex2D(sourceSampler,tex);
	float diffRGB = distance(sampledTexture.rgb,filterRGB);
	sampledTexture.a *= (diffRGB-filterRange)/filterRange;
	return sampledTexture*color;
}

//-------------------------------------------
// Returns UV transform using external settings
//-------------------------------------------
float3x3 getTextureTransform()
{
		// maskBGFilter(sPicTexture,float4( 0, 0, 0, 0 ))
    return makeTextureTransform( gUVPrePosition, gUVScale, gUVScaleCenter, gUVRotAngle, gUVRotCenter, gUVPosition );
}

///////////////////////////////////////////////////////////////////////////////
// Techniques
///////////////////////////////////////////////////////////////////////////////
technique hello
{
    pass P0
    {
        // Set up texture stage 0
        Texture[0] = sPicTexture;
        TextureTransform[0] = getTextureTransform();
				// TextureTransform[0] = maskBGFilter(sPicTexture,float4(1.0f, 0.0f, 0.0f, 1.0f));
        TextureTransformFlags[0] = Count2;
        AddressU[0] = Clamp;
        AddressV[0] = Clamp;
        // Color mix texture and diffuse
        ColorOp[0] = Modulate;
        ColorArg1[0] = Texture;
        ColorArg2[0] = Diffuse;
        // Alpha mix texture and diffuse
        AlphaOp[0] = Modulate;
        AlphaArg1[0] = Texture;
        AlphaArg2[0] = Diffuse;
				// maskBGFilter(TexCoordIndex[0],ColorOp[0])
     

        // Set up texture stage 1
        Texture[1] = sMaskTexture;
				// Texture[1] = maskBGFilter();
        TexCoordIndex[1] = 0;
        AddressU[1] = Clamp;
        AddressV[1] = Clamp;
        // Color pass through from stage 0
        ColorOp[1] = SelectArg1;
        ColorArg1[1] = Current;
        // Alpha modulate mask texture with stage 0
        AlphaOp[1] = Modulate;
        AlphaArg1[1] = Current;
        AlphaArg2[1] = Texture;


        // Disable texture stage 2
        ColorOp[2] = Disable;
        AlphaOp[2] = Disable;
				// maskBGFilter(sPicTexture,{0,0,2,1});
    }
}

// technique maskTech{
// 	pass P0	{
// 		//Solve Render Issues
// 		SeparateAlphaBlendEnable = true;
// 		SrcBlendAlpha = One;
// 		DestBlendAlpha = InvSrcAlpha;
// 		PixelShader = compile ps_2_0 maskBGFilter();
// 	}
// }