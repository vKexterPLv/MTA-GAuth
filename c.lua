local authim
local w,h = 0,0
local authimbfr
local authimF
local removeShdr2
local circleShdr
local removeShdr = [[
	texture sourceTexture;
	float3 filterRGB = 0;
	float filterRange = 0;
	bool isPixelated = false;

	SamplerState sourceSampler{
		Texture = sourceTexture;
		MinFilter = 2;
		MagFilter = 2;
		MipFilter = 2;
		AddressU = Wrap;
		AddressV = Wrap;
	};

	SamplerState sourceSamplerPixelated{
		Texture = sourceTexture;
		MinFilter = 1;
		MagFilter = 1;
		MipFilter = 1;
		AddressU = Wrap;
		AddressV = Wrap;
	};

	float4 maskBGFilter(float2 tex:TEXCOORD0,float4 color:COLOR0):COLOR0{
		float4 sampledTexture = isPixelated?tex2D(sourceSamplerPixelated,tex):tex2D(sourceSampler,tex);
		float diffRGB = distance(sampledTexture.rgb,filterRGB);
		sampledTexture.a *= (diffRGB-filterRange)/filterRange;
		return sampledTexture*color;
	}

	technique maskTech{
		pass P0	{
			//Solve Render Issues
			SeparateAlphaBlendEnable = true;
			SrcBlendAlpha = One;
			DestBlendAlpha = InvSrcAlpha;
			PixelShader = compile ps_2_0 maskBGFilter();
		}
	}
]]

function dxDrawGAuth(x,y,w,h)
	if isElement(authim) and w >= 110 and h >= 110 then
		-- dxDrawRectangle(x,y,w,h,tocolor(255,255,255,100))
		return dxDrawImage(x,y,w,h,authim)
		-- dxDrawImage(x,y,w,h,authimF)
	else
		return false
	end
end

function rtDrw()
	dxSetRenderTarget(authim, true)
	dxSetBlendMode("blend")
	dxDrawRectangle(0+30,0+30,w-60,h-60,tocolor(255,255,255,200))
	dxDrawImage(0,0,w,h,removeShdr2)
	dxSetBlendMode("blend")  
	dxSetRenderTarget()  
end

addEvent("gotAuthIm",true)
addEventHandler("gotAuthIm",resourceRoot,function(pix,plr)
	if plr ~= localPlayer then return end
	if isElement(authim) then
		destroyElement(authim)
	end
	if isElement(authimbfr) then
		destroyElement(authimbfr)
	end
	if isElement(removeShdr2) then
		destroyElement(removeShdr2)
	end
	authimbfr = dxCreateTexture(pix)
	w,h = dxGetMaterialSize(authimbfr)
	authim = dxCreateRenderTarget(w+110,h+110,true)
	removeShdr2 = dxCreateShader(removeShdr,0,0,true)
	dxSetShaderValue(removeShdr2,"sourceTexture",authimbfr)
	dxSetShaderValue(removeShdr2,"filterRGB",1,1,1)
	dxSetShaderValue(removeShdr2,"filterRange",0.85)
	rtDrw()
end)