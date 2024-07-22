Texture2D<float4> ImageTexture_002_texread : register(t0);
SamplerState _ImageTexture_002_texread_sampler : register(s0);
Texture2D<float4> ImageTexture_001 : register(t1);
SamplerState _ImageTexture_001_sampler : register(s1);
Texture2D<float4> ImageTexture : register(t2);
SamplerState _ImageTexture_sampler : register(s2);

static float3 wnormal;
static float2 texCoord;
static float4 fragColor[3];

struct SPIRV_Cross_Input
{
    float2 texCoord : TEXCOORD0;
    float3 wnormal : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 fragColor[3] : SV_Target0;
};

float2 octahedronWrap(float2 v)
{
    return (1.0f.xx - abs(v.yx)) * float2((v.x >= 0.0f) ? 1.0f : (-1.0f), (v.y >= 0.0f) ? 1.0f : (-1.0f));
}

float packFloatInt16(float f, uint i)
{
    uint bitsInt = i << 12u;
    uint bitsFloat = uint(f * 4095.0f);
    return float(bitsInt | bitsFloat);
}

float packFloat2(float f1, float f2)
{
    return floor(f1 * 255.0f) + min(f2, 0.9900000095367431640625f);
}

void frag_main()
{
    float3 n = normalize(wnormal);
    float3 TextureCoordinate_texread_UV_res = float3(texCoord.x, 1.0f - texCoord.y, 0.0f);
    TextureCoordinate_texread_UV_res = TextureCoordinate_texread_UV_res;
    float SeparateXYZ_texread_X_res = TextureCoordinate_texread_UV_res.x;
    float SeparateXYZ_texread_Y_res = TextureCoordinate_texread_UV_res.y;
    float Math_003_texread_Value_res = 0.0f;
    float4 ImageTexture_002_texread_store = ImageTexture_002_texread.Sample(_ImageTexture_002_texread_sampler, texCoord);
    float3 _105 = pow(ImageTexture_002_texread_store.xyz, 2.2000000476837158203125f.xxx);
    ImageTexture_002_texread_store = float4(_105.x, _105.y, _105.z, ImageTexture_002_texread_store.w);
    float3 ImageTexture_002_texread_Color_res = ImageTexture_002_texread_store.xyz;
    float SeparateColor_texread_Blue_res = ImageTexture_002_texread_Color_res.z;
    float Math_002_texread_Value_res = Math_003_texread_Value_res * SeparateColor_texread_Blue_res;
    float Math_texread_Value_res = SeparateXYZ_texread_Y_res - Math_002_texread_Value_res;
    float SeparateXYZ_texread_Z_res = TextureCoordinate_texread_UV_res.z;
    float3 CombineXYZ_texread_Vector_res = float3(SeparateXYZ_texread_X_res, Math_texread_Value_res, SeparateXYZ_texread_Z_res);
    float4 ImageTexture_001_texread_store = ImageTexture_001.Sample(_ImageTexture_001_sampler, float2(CombineXYZ_texread_Vector_res.x, 1.0f - CombineXYZ_texread_Vector_res.y));
    float3 _143 = pow(ImageTexture_001_texread_store.xyz, 2.2000000476837158203125f.xxx);
    ImageTexture_001_texread_store = float4(_143.x, _143.y, _143.z, ImageTexture_001_texread_store.w);
    float4 ImageTexture_texread_store = ImageTexture.Sample(_ImageTexture_sampler, float2(CombineXYZ_texread_Vector_res.x, 1.0f - CombineXYZ_texread_Vector_res.y));
    float3 _158 = pow(ImageTexture_texread_store.xyz, 2.2000000476837158203125f.xxx);
    ImageTexture_texread_store = float4(_158.x, _158.y, _158.z, ImageTexture_texread_store.w);
    float3 ImageTexture_001_Color_res = ImageTexture_001_texread_store.xyz;
    float3 ImageTexture_Color_res = ImageTexture_texread_store.xyz;
    float3 ImageTexture_002_Color_res = ImageTexture_002_texread_store.xyz;
    float SeparateColor_Green_res = ImageTexture_002_Color_res.y;
    float Math_001_Value_res = 1.0f - SeparateColor_Green_res;
    float SeparateColor_Red_res = ImageTexture_002_Color_res.x;
    float3 basecol = ImageTexture_Color_res * (1.0f - clamp(dot(ImageTexture_001_Color_res, float3(0.2125999927520751953125f, 0.715200006961822509765625f, 0.072200000286102294921875f)), 0.0f, 1.0f));
    float roughness = Math_001_Value_res;
    float metallic = SeparateColor_Red_res;
    float occlusion = 1.0f;
    float specular = 1.0f;
    float3 emissionCol = ImageTexture_Color_res * clamp(dot(ImageTexture_001_Color_res, float3(0.2125999927520751953125f, 0.715200006961822509765625f, 0.072200000286102294921875f)), 0.0f, 1.0f);
    n /= ((abs(n.x) + abs(n.y)) + abs(n.z)).xxx;
    float2 _220;
    if (n.z >= 0.0f)
    {
        _220 = n.xy;
    }
    else
    {
        _220 = octahedronWrap(n.xy);
    }
    n = float3(_220.x, _220.y, n.z);
    fragColor[0] = float4(n.xy, roughness, packFloatInt16(metallic, 0u));
    fragColor[1] = float4(basecol, packFloat2(occlusion, specular));
    fragColor[2] = float4(emissionCol, 0.0f);
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    wnormal = stage_input.wnormal;
    texCoord = stage_input.texCoord;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
