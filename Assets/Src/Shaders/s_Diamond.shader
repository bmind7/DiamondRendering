Shader "Custom/Diamond"
{
	Properties
	{
		_Cubemap("Environment", CUBE) = "white" {}
		_CubeNormal("Noraml Cubemap", CUBE) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Transparent" }
		LOD 100
		//Cull Off
		//Zwrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 normal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				float3 objectCamera = mul(unity_WorldToObject, _WorldSpaceCameraPos);
				o.viewDir = normalize(v.vertex - objectCamera);
				o.normal = v.normal;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;

				return o;
			}
			
			samplerCUBE _Cubemap;
			samplerCUBE _CubeNormal;

			#define REFRACT_INDEX float3(2.407, 2.426, 2.451)
			#define REFRACT_SPREAD float3 (0.0, 0.02, 0.05)
			#define MAX_BOUNCE 5
			#define COS_CRITICAL_ANGLE 0.91

			float4 frag (v2f i) : SV_Target
			{
				float3 viewDir = normalize(i.viewDir);
				float3 normal = normalize(i.normal);
				float3 reflectDir = reflect(viewDir, normal);
				float fresnelFactor = pow(1 - abs(dot(viewDir, normal)), 2);

				float3 reflectDirW = mul(float4(reflectDir, 0.0), unity_WorldToObject);
				float4 col = texCUBE(_Cubemap, reflectDirW);
				col.rgb = col.rgb * fresnelFactor;

				// Divide 1 by refraction index, since we entering to diamond from air 
				float3 inDir = refract(viewDir, normal, 1.0/REFRACT_INDEX.r);
				// Direction to sample environment cubemap for different colors
				float3 inDirR, inDirG, inDirB;
				for (int bounce = 0; bounce < MAX_BOUNCE; bounce++)
				{
					// Convert normal to -1, 1 range
					float3 inN = texCUBE(_CubeNormal, inDir) * 2.0 - 1.0;
					if (abs(dot(-inDir, inN)) > COS_CRITICAL_ANGLE)
					{
						// The more bounces we have the heavier dispersion should be
						inDirR = refract(inDir, inN, REFRACT_INDEX.r);
						inDirG = refract(inDir, inN, REFRACT_INDEX.g + bounce * REFRACT_SPREAD.g);
						inDirB = refract(inDir, inN, REFRACT_INDEX.b + bounce * REFRACT_SPREAD.b);
						break;
					}

					// We didn't manage to exit diamond in MAX_BOUNCE
					// To be able exit from diamond to air we need fake our refraction 
					// index other way we'll get float3(0,0,0) as return
					if (bounce == MAX_BOUNCE-1)
					{
						inDirR = refract(inDir, inN, 1/ REFRACT_INDEX.r);
						inDirG = refract(inDir, inN, 1/ (REFRACT_INDEX.g + bounce * REFRACT_SPREAD.g));
						inDirB = refract(inDir, inN, 1/ (REFRACT_INDEX.b + bounce * REFRACT_SPREAD.b));
						break;
					}
					inDir = reflect(inDir, inN);
				}

				// Convert to world space
				inDirR = mul(float4(inDirR, 0.0), unity_WorldToObject);
				inDirG = mul(float4(inDirG, 0.0), unity_WorldToObject);
				inDirB = mul(float4(inDirB, 0.0), unity_WorldToObject);
				col.r += texCUBE(_Cubemap, inDirR).r;
				col.g += texCUBE(_Cubemap, inDirG).g;
				col.b +=  texCUBE(_Cubemap, inDirB).b;

				//	col = float4(bounce * 0.1, bounce * 0.1, bounce * 0.1, 1.0);

				return col;
			}
			ENDCG
		}
	}
}
