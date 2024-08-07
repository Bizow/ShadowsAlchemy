TextureCube<float4> shadowMapPoint[1] : register(t0);
SamplerComparisonState _shadowMapPoint_sampler[1] : register(s0);
uniform float2 lightProj;
Texture2D<float4> gbuffer0 : register(t1);
SamplerState _gbuffer0_sampler : register(s1);
Texture2D<float4> gbuffer1 : register(t2);
SamplerState _gbuffer1_sampler : register(s2);
Texture2D<float4> gbufferD : register(t3);
SamplerState _gbufferD_sampler : register(s3);
uniform float3 eye;
uniform float3 eyeLook;
uniform float2 cameraProj;
Texture2D<float4> senvmapBrdf : register(t4);
SamplerState _senvmapBrdf_sampler : register(s4);
uniform float4 shirr[7];
uniform int envmapNumMipmaps;
Texture2D<float4> senvmapRadiance : register(t5);
SamplerState _senvmapRadiance_sampler : register(s5);
uniform float envmapStrength;
Texture2D<float4> ssaotex : register(t6);
SamplerState _ssaotex_sampler : register(s6);
Texture2D<float4> gbufferEmission : register(t7);
SamplerState _gbufferEmission_sampler : register(s7);
uniform float3 pointPos;
uniform float3 pointCol;
uniform float pointBias;
uniform float4 casData[20];

static float2 texCoord;
static float3 viewRay;
static float4 fragColor;

struct SPIRV_Cross_Input
{
    float2 texCoord : TEXCOORD0;
    float3 viewRay : TEXCOORD1;
};

struct SPIRV_Cross_Output
{
    float4 fragColor : SV_Target0;
};

float2 octahedronWrap(float2 v)
{
    return (1.0f.xx - abs(v.yx)) * float2((v.x >= 0.0f) ? 1.0f : (-1.0f), (v.y >= 0.0f) ? 1.0f : (-1.0f));
}

void unpackFloatInt16(float val, out float f, out uint i)
{
    uint bitsValue = uint(val);
    i = bitsValue >> 12u;
    f = float(bitsValue & 4294905855u) / 4095.0f;
}

float2 unpackFloat2(float f)
{
    return float2(floor(f) / 255.0f, frac(f));
}

float3 surfaceAlbedo(float3 baseColor, float metalness)
{
    return lerp(baseColor, 0.0f.xxx, metalness.xxx);
}

float3 surfaceF0(float3 baseColor, float metalness)
{
    return lerp(0.039999999105930328369140625f.xxx, baseColor, metalness.xxx);
}

float3 getPos(float3 eye_1, float3 eyeLook_1, float3 viewRay_1, float depth, float2 cameraProj_1)
{
    float linearDepth = cameraProj_1.y / (((depth * 0.5f) + 0.5f) - cameraProj_1.x);
    float viewZDist = dot(eyeLook_1, viewRay_1);
    float3 wposition = eye_1 + (viewRay_1 * (linearDepth / viewZDist));
    return wposition;
}

float3 shIrradiance(float3 nor, float4 shirr_1[7])
{
    float3 cl00 = float3(shirr_1[0].x, shirr_1[0].y, shirr_1[0].z);
    float3 cl1m1 = float3(shirr_1[0].w, shirr_1[1].x, shirr_1[1].y);
    float3 cl10 = float3(shirr_1[1].z, shirr_1[1].w, shirr_1[2].x);
    float3 cl11 = float3(shirr_1[2].y, shirr_1[2].z, shirr_1[2].w);
    float3 cl2m2 = float3(shirr_1[3].x, shirr_1[3].y, shirr_1[3].z);
    float3 cl2m1 = float3(shirr_1[3].w, shirr_1[4].x, shirr_1[4].y);
    float3 cl20 = float3(shirr_1[4].z, shirr_1[4].w, shirr_1[5].x);
    float3 cl21 = float3(shirr_1[5].y, shirr_1[5].z, shirr_1[5].w);
    float3 cl22 = float3(shirr_1[6].x, shirr_1[6].y, shirr_1[6].z);
    return ((((((((((cl22 * 0.429042994976043701171875f) * ((nor.y * nor.y) - ((-nor.z) * (-nor.z)))) + (((cl20 * 0.743125021457672119140625f) * nor.x) * nor.x)) + (cl00 * 0.88622701168060302734375f)) - (cl20 * 0.2477079927921295166015625f)) + (((cl2m2 * 0.85808598995208740234375f) * nor.y) * (-nor.z))) + (((cl21 * 0.85808598995208740234375f) * nor.y) * nor.x)) + (((cl2m1 * 0.85808598995208740234375f) * (-nor.z)) * nor.x)) + ((cl11 * 1.02332794666290283203125f) * nor.y)) + ((cl1m1 * 1.02332794666290283203125f) * (-nor.z))) + ((cl10 * 1.02332794666290283203125f) * nor.x);
}

float getMipFromRoughness(float roughness, float numMipmaps)
{
    return roughness * numMipmaps;
}

float2 envMapEquirect(float3 normal)
{
    float phi = acos(normal.z);
    float theta = atan2(-normal.y, normal.x) + 3.1415927410125732421875f;
    return float2(theta / 6.283185482025146484375f, phi / 3.1415927410125732421875f);
}

float3 lambertDiffuseBRDF(float3 albedo, float nl)
{
    return albedo * nl;
}

float d_ggx(float nh, float a)
{
    float a2 = a * a;
    float denom = ((nh * nh) * (a2 - 1.0f)) + 1.0f;
    denom = max(denom * denom, 6.103515625e-05f);
    return (a2 * 0.3183098733425140380859375f) / denom;
}

float g2_approx(float NdotL, float NdotV, float alpha)
{
    float2 helper = (float2(NdotL, NdotV) * 2.0f) * (1.0f.xx / ((float2(NdotL, NdotV) * (2.0f - alpha)) + alpha.xx));
    return max(helper.x * helper.y, 0.0f);
}

float3 f_schlick(float3 f0, float vh)
{
    return f0 + ((1.0f.xxx - f0) * exp2((((-5.554729938507080078125f) * vh) - 6.9831600189208984375f) * vh));
}

float3 specularBRDF(float3 f0, float roughness, float nl, float nh, float nv, float vh)
{
    float a = roughness * roughness;
    return (f_schlick(f0, vh) * (d_ggx(nh, a) * g2_approx(nl, nv, a))) / max(4.0f * nv, 9.9999997473787516355514526367188e-06f).xxx;
}

float attenuate(float dist)
{
    return 1.0f / (dist * dist);
}

float lpToDepth(inout float3 lp, float2 lightProj_1)
{
    lp = abs(lp);
    float zcomp = max(lp.x, max(lp.y, lp.z));
    zcomp = lightProj_1.x - (lightProj_1.y / zcomp);
    return (zcomp * 0.5f) + 0.5f;
}

float PCFCube(TextureCube<float4> shadowMapCube, SamplerComparisonState _shadowMapCube_sampler, float3 lp, inout float3 ml, float bias, float2 lightProj_1, float3 n)
{
    float3 param = lp;
    float _443 = lpToDepth(param, lightProj_1);
    float compare = _443 - (bias * 1.5f);
    ml += ((n * bias) * 20.0f);
    ml.y = -ml.y;
    float4 _463 = float4(ml, compare);
    float result = shadowMapCube.SampleCmp(_shadowMapCube_sampler, _463.xyz, _463.w);
    float4 _475 = float4(ml + 0.001000000047497451305389404296875f.xxx, compare);
    result += shadowMapCube.SampleCmp(_shadowMapCube_sampler, _475.xyz, _475.w);
    float4 _489 = float4(ml + float3(-0.001000000047497451305389404296875f, 0.001000000047497451305389404296875f, 0.001000000047497451305389404296875f), compare);
    result += shadowMapCube.SampleCmp(_shadowMapCube_sampler, _489.xyz, _489.w);
    float4 _502 = float4(ml + float3(0.001000000047497451305389404296875f, -0.001000000047497451305389404296875f, 0.001000000047497451305389404296875f), compare);
    result += shadowMapCube.SampleCmp(_shadowMapCube_sampler, _502.xyz, _502.w);
    float4 _515 = float4(ml + float3(0.001000000047497451305389404296875f, 0.001000000047497451305389404296875f, -0.001000000047497451305389404296875f), compare);
    result += shadowMapCube.SampleCmp(_shadowMapCube_sampler, _515.xyz, _515.w);
    float4 _528 = float4(ml + float3(-0.001000000047497451305389404296875f, -0.001000000047497451305389404296875f, 0.001000000047497451305389404296875f), compare);
    result += shadowMapCube.SampleCmp(_shadowMapCube_sampler, _528.xyz, _528.w);
    float4 _541 = float4(ml + float3(0.001000000047497451305389404296875f, -0.001000000047497451305389404296875f, -0.001000000047497451305389404296875f), compare);
    result += shadowMapCube.SampleCmp(_shadowMapCube_sampler, _541.xyz, _541.w);
    float4 _554 = float4(ml + float3(-0.001000000047497451305389404296875f, 0.001000000047497451305389404296875f, -0.001000000047497451305389404296875f), compare);
    result += shadowMapCube.SampleCmp(_shadowMapCube_sampler, _554.xyz, _554.w);
    float4 _567 = float4(ml + (-0.001000000047497451305389404296875f).xxx, compare);
    result += shadowMapCube.SampleCmp(_shadowMapCube_sampler, _567.xyz, _567.w);
    return result / 9.0f;
}

float3 sampleLight(float3 p, float3 n, float3 v, float dotNV, float3 lp, float3 lightCol, float3 albedo, float rough, float spec, float3 f0, int index, float bias, bool receiveShadow)
{
    float3 ld = lp - p;
    float3 l = normalize(ld);
    float3 h = normalize(v + l);
    float dotNH = max(0.0f, dot(n, h));
    float dotVH = max(0.0f, dot(v, h));
    float dotNL = max(0.0f, dot(n, l));
    float3 direct = lambertDiffuseBRDF(albedo, dotNL) + (specularBRDF(f0, rough, dotNL, dotNH, dotNV, dotVH) * spec);
    direct *= attenuate(distance(p, lp));
    direct *= lightCol;
    if (receiveShadow)
    {
        float3 param = -l;
        float _628 = PCFCube(shadowMapPoint[0], _shadowMapPoint_sampler[0], ld, param, bias, lightProj, n);
        direct *= _628;
    }
    return direct;
}

void frag_main()
{
    float4 g0 = gbuffer0.SampleLevel(_gbuffer0_sampler, texCoord, 0.0f);
    float3 n;
    n.z = (1.0f - abs(g0.x)) - abs(g0.y);
    float2 _658;
    if (n.z >= 0.0f)
    {
        _658 = g0.xy;
    }
    else
    {
        _658 = octahedronWrap(g0.xy);
    }
    n = float3(_658.x, _658.y, n.z);
    n = normalize(n);
    float roughness = g0.z;
    float param;
    uint param_1;
    unpackFloatInt16(g0.w, param, param_1);
    float metallic = param;
    uint matid = param_1;
    float4 g1 = gbuffer1.SampleLevel(_gbuffer1_sampler, texCoord, 0.0f);
    float2 occspec = unpackFloat2(g1.w);
    float3 albedo = surfaceAlbedo(g1.xyz, metallic);
    float3 f0 = surfaceF0(g1.xyz, metallic);
    float depth = (gbufferD.SampleLevel(_gbufferD_sampler, texCoord, 0.0f).x * 2.0f) - 1.0f;
    float3 p = getPos(eye, eyeLook, normalize(viewRay), depth, cameraProj);
    float3 v = normalize(eye - p);
    float dotNV = max(dot(n, v), 0.0f);
    float2 envBRDF = senvmapBrdf.Load(int3(int2(float2(dotNV, 1.0f - roughness) * 256.0f), 0)).xy;
    float3 envl = shIrradiance(n, shirr);
    float3 reflectionWorld = reflect(-v, n);
    float lod = getMipFromRoughness(roughness, float(envmapNumMipmaps));
    float3 prefilteredColor = senvmapRadiance.SampleLevel(_senvmapRadiance_sampler, envMapEquirect(reflectionWorld), lod).xyz;
    envl *= albedo;
    envl *= (1.0f.xxx - ((f0 * envBRDF.x) + envBRDF.y.xxx));
    envl += (prefilteredColor * ((f0 * envBRDF.x) + envBRDF.y.xxx));
    envl *= (envmapStrength * occspec.x);
    fragColor = float4(envl.x, envl.y, envl.z, fragColor.w);
    float3 _822 = fragColor.xyz * ssaotex.SampleLevel(_ssaotex_sampler, texCoord, 0.0f).x;
    fragColor = float4(_822.x, _822.y, _822.z, fragColor.w);
    float3 emission = gbufferEmission.SampleLevel(_gbufferEmission_sampler, texCoord, 0.0f).xyz;
    float3 _834 = fragColor.xyz + emission;
    fragColor = float4(_834.x, _834.y, _834.z, fragColor.w);
    int param_2 = 0;
    float param_3 = pointBias;
    bool param_4 = true;
    float3 _859 = fragColor.xyz + sampleLight(p, n, v, dotNV, pointPos, pointCol, albedo, roughness, occspec.y, f0, param_2, param_3, param_4);
    fragColor = float4(_859.x, _859.y, _859.z, fragColor.w);
    fragColor.w = 1.0f;
}

SPIRV_Cross_Output main(SPIRV_Cross_Input stage_input)
{
    texCoord = stage_input.texCoord;
    viewRay = stage_input.viewRay;
    frag_main();
    SPIRV_Cross_Output stage_output;
    stage_output.fragColor = fragColor;
    return stage_output;
}
