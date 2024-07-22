#version 450
#include "compiled.inc"
#include "std/gbuffer.glsl"
in vec3 wnormal;
in vec2 texCoord;
out vec4 fragColor[GBUF_SIZE];
uniform sampler2D ImageTexture_001;
uniform sampler2D ImageTexture_002_texread;
uniform sampler2D ImageTexture;
const float Value_texread_Value_res = 0.0;
void main() {
	vec3 n = normalize(wnormal);
	vec3 TextureCoordinate_texread_UV_res = vec3(texCoord.x, 1.0 - texCoord.y, 0.0);
	TextureCoordinate_texread_UV_res = (TextureCoordinate_texread_UV_res);
	float SeparateXYZ_texread_X_res = TextureCoordinate_texread_UV_res.x;
	float SeparateXYZ_texread_Y_res = TextureCoordinate_texread_UV_res.y;
	float Math_003_texread_Value_res = (Value_texread_Value_res / 36.0);
	vec4 ImageTexture_002_texread_store = texture(ImageTexture_002_texread, texCoord.xy);
	ImageTexture_002_texread_store.rgb = pow(ImageTexture_002_texread_store.rgb, vec3(2.2));
	vec3 ImageTexture_002_texread_Color_res = ImageTexture_002_texread_store.rgb;
	float SeparateColor_texread_Blue_res = ImageTexture_002_texread_Color_res.b;
	float Math_002_texread_Value_res = (Math_003_texread_Value_res * SeparateColor_texread_Blue_res);
	float Math_texread_Value_res = (SeparateXYZ_texread_Y_res - Math_002_texread_Value_res);
	float SeparateXYZ_texread_Z_res = TextureCoordinate_texread_UV_res.z;
	vec3 CombineXYZ_texread_Vector_res = vec3(SeparateXYZ_texread_X_res, Math_texread_Value_res, SeparateXYZ_texread_Z_res);
	vec4 ImageTexture_001_texread_store = texture(ImageTexture_001, vec2(CombineXYZ_texread_Vector_res.x, 1.0 - CombineXYZ_texread_Vector_res.y).xy);
	ImageTexture_001_texread_store.rgb = pow(ImageTexture_001_texread_store.rgb, vec3(2.2));
	vec4 ImageTexture_texread_store = texture(ImageTexture, vec2(CombineXYZ_texread_Vector_res.x, 1.0 - CombineXYZ_texread_Vector_res.y).xy);
	ImageTexture_texread_store.rgb = pow(ImageTexture_texread_store.rgb, vec3(2.2));
	vec3 basecol;
	float roughness;
	float metallic;
	float occlusion;
	float specular;
	vec3 emissionCol;
	vec3 ImageTexture_001_Color_res = ImageTexture_001_texread_store.rgb;
	vec3 ImageTexture_Color_res = ImageTexture_texread_store.rgb;
	vec3 ImageTexture_002_Color_res = ImageTexture_002_texread_store.rgb;
	float SeparateColor_Green_res = ImageTexture_002_Color_res.g;
	float Math_001_Value_res = (1.0 - SeparateColor_Green_res);
	float SeparateColor_Red_res = ImageTexture_002_Color_res.r;
	basecol = (ImageTexture_Color_res * (1 - clamp(dot(ImageTexture_001_Color_res, vec3(0.2126, 0.7152, 0.0722)), 0.0, 1.0)));
	roughness = Math_001_Value_res;
	metallic = SeparateColor_Red_res;
	occlusion = 1.0;
	specular = 1.0;
	emissionCol = (ImageTexture_Color_res * clamp(dot(ImageTexture_001_Color_res, vec3(0.2126, 0.7152, 0.0722)), 0.0, 1.0));
	n /= (abs(n.x) + abs(n.y) + abs(n.z));
	n.xy = n.z >= 0.0 ? n.xy : octahedronWrap(n.xy);
	const uint matid = 0;
	fragColor[GBUF_IDX_0] = vec4(n.xy, roughness, packFloatInt16(metallic, matid));
	fragColor[GBUF_IDX_1] = vec4(basecol, packFloat2(occlusion, specular));
	#ifdef _EmissionShaded
	fragColor[GBUF_IDX_EMISSION] = vec4(emissionCol, 0.0);
	#endif
}
