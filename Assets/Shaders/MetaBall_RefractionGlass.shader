Shader "MetaBall/RefractionGlass"
{
	Properties
	{	
		// ******************************************************************************************** //
		// VARIABLE NAME		NAME IN PROPERTY WINDOW			EDITOR BOX			DEFAULT VALUE		//
		// ******************************************************************************************** //

		// Diffuse
		_Color 					("Tint", 						Color)			= 	(0.2, 0.3, 0.4, 1)
		_DiffusePower 			("Diffuse Power", 				Float) 			= 	3
		// Specular
		_SpecColor 				("Specular", 					Color) 			=	(0.4, 0.5, 0.6, 1)
		_SpecPower 				("Specular Power", 				Float) 			=	3
		_SpecAtten 				("Specular Attenuation", 		Range(0,1)) 	= 	1
		// Fresnel
		_FresnelBias	 		("Fresnel Bias", 				Range(0,1)) 	= 	1
		_FresnelScale	 		("Fresnel Scale", 				Range(0,2)) 	= 	1
		_FresnelPower		 	("Fresnel Power", 				Range(1,10)) 	=	3
		// Reflection
		[NoScaleOffset]
		_EnvCUBE				("Environment Map",				CUBE)			=	"cube" {}
		_EtaRatio				("Refraction Ratio",			Range(0,1))		= 	0.8
		// Radial Basis Function
		_K		 				("RadialBasis Constant", 		Float) 			= 	7
		_Threshold 				("Isosurface Threshold",		Range(0,1)) 	= 	0.5
		_Epsilon 				("Normal Epsilon", 				Range(0,1)) 	= 	0.1
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Cull Off
		ZWrite Off 			// Don't write on the ZBuffer.
		Lighting Off		// Don't let unity do lighting calculations.

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 worldPosition : TEXCOORD0;
			};

			uniform float3 _ParticlesPos[10];	// The world position of all particles, feeded with c# script.

			float4 _Color;						// Diffuse Color.
			float  _DiffusePower;				// Diffuse Power.

			float4 _SpecColor;					// Specular Color.
			float _SpecPower;					// Specular Power.
			fixed _SpecAtten;					// Specular Scale.

			fixed _FresnelBias;					// Fresnel Bias (shift).
			fixed _FresnelScale;				// Fresnel Scale.
			float _FresnelPower;				// Fresnel Power.

			float _K;							// Radial basis function constant.
			fixed _Threshold;					// Isosurface threshold.
			fixed _Epsilon;						// Epsilon to approximate normal on isosurface.

			samplerCUBE _EnvCUBE;
			fixed _EtaRatio;

			float scalarField(float3 pos){
				float density = 0;
				for(int i = 0; i < 10; i++){
					float dis = distance(pos, _ParticlesPos[i].xyz);
					density += exp(-_K * (dis));
				}
				return density;
			}

			float scalarField(float x, float y, float z){
				float3 pos = float3(x,y,z);
				return scalarField(pos);
			}

			float3 calcNormal(float3 p){
				float3 N;
				N.x = scalarField(p.x + _Epsilon, p.y, p.z) - scalarField(p.x - _Epsilon, p.y, p.z);
				N.y = scalarField(p.x, p.y + _Epsilon, p.z) - scalarField(p.x, p.y - _Epsilon, p.z);
				N.z = scalarField(p.x, p.y, p.z + _Epsilon) - scalarField(p.x, p.y, p.z - _Epsilon);
				return -N;
			}

			float3 blinnPhongRefraction(float3 V, float3 N, float3 L){
				float3 H = normalize(V + L);
				float3 R = reflect(-V, N);
				float3 T = refract(-V, N, _EtaRatio);
				T = reflect(-T, -V);

				float NdotH = saturate(dot(N, H)); // for specular.
				float NdotV = saturate(dot(N, V)); // for fresnel.
				float LdotN = saturate(dot(L, N)); // for diffuse.

				// Compute reflected color
				float3 rc0 = texCUBE(_EnvCUBE, R);
				float3 rc1 = texCUBElod(_EnvCUBE, float4(R, 6.0));
				float3 reflectedColor = 0.8 * rc0 + 0.2 * rc1;

				// Compute refracted color.
				rc0 = texCUBE(_EnvCUBE, T);
				rc1 = texCUBElod(_EnvCUBE, float4(T, 5.0));
				float3 refractedColor = 0.2 * rc0 + 0.8 * rc1;

				float fresnel = _FresnelBias + _FresnelScale * pow(1 - NdotV, _FresnelPower);
				float3 col = lerp(refractedColor, reflectedColor, fresnel);


				float3 diffuseTerm = col * clamp(LdotN, 0.2, 1);
				float3 specularTerm = pow(NdotH, _SpecPower) * _SpecAtten * _SpecColor ;

				return _DiffusePower * _Color * (diffuseTerm + specularTerm);
			}

			v2f vert (appdata v)
			{
				v2f o;
				o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				return o;
			}

			float4 frag (v2f i) : SV_Target
			{
				// initial color of the fragment.
				float4 col = _Color;
				col.a = 0;

				// prepare to raycast.
				float3 viewDir = normalize(i.worldPosition - _WorldSpaceCameraPos.xyz); // World space direction from cam to fragment.
				float3 start = i.worldPosition - 2.0 * viewDir; // Start sampling two units before the fragment along the viewDir.
				float3 p; // The sampled point.

				// We now start sampling on the ray. We will be sampling each 0.2 points along the ray for a maximum length of 3 units.
				// And once we find an intersection with the isosurface, we sample again with a smaller step till we can pinpoint the
				// exact point of intersection.
				for(float i = 0; i < 3.0; i+=0.2){
					p = start + i * viewDir;

					if(scalarField(p) > _Threshold){
						// now, sample each 0.05 from (p - 0.2, p + 0.2)
						float3 start2 = p - 0.2 * viewDir;
						for(float i = 0.05; i < 0.4; i+=0.05){
							p = start2 + i * viewDir;

							if(scalarField(p) > _Threshold){
								// finally, sample each 0.01 from (p - 0.05, p + 0.05)
								float3 start3 = p - 0.05 * viewDir;
								for(float i = 0.01; i < 0.1; i+=0.01){
									p = start3 + i * viewDir;
									if(scalarField(p) > _Threshold){
										break;
									}
								}
								break;
							}
						}

						// ... calculate its normal.
						float3 N = normalize(calcNormal(p));
						// ... calculate the lightDir.
						float3 L = normalize(UnityWorldSpaceLightDir(p.xyz)); // the same as normalize(_WorldSpaceLightPos0 - p.xyz);
						// ... illuminate with blinnPhong
						col.xyz = blinnPhongRefraction(-viewDir, N, L);
						// ... make it visible.
						col.a = 1;
						break;
					}
				}

				return col;
			}

			ENDCG
		}
	}
}
