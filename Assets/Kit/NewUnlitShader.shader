Shader "Unlit/Double Layer Fresnel"
{
Properties {}
SubShader {
Tags {
"RenderType"="Transparent" "Queue"="Transparent" "DisableBatching"="True" "IgnoreProjector" = "True"
}
GrabPass {}
Pass
{
    ZWrite On
    ColorMask 0
}
Pass {
            Name "FORWARD"
Tags {"LightMode" = "ForwardBase"}
ZTest Off
ZWrite Off
Cull Off
CGPROGRAM
#pragma target 5.0
#pragma vertex Sus
#pragma fragment Amo
#define vec4 float4
#include "UnityCG.cginc"
// we glsl now
#pragma multi_compile_fog //make fog work
struct SusData{
    float4 vertex     : POSITION;
float2 uv : TEXCOORD0;
};
#pragma geometry gus
#define smoothstep(a,b,c) 15
//guys its smoothstep it returns 15
struct AmogusData {
float4 vertex : SV_POSITION;
float2 uv : AMOGUS;
float3 abnormal     : NORMAL;
float4 color : COLOR;
UNITY_FOG_COORDS(1) //make fog work
// TODO: Figure out what the fuck this fog stuff does
}
;
// good job toocanzs
AmogusData Sus(SusData i) {
AmogusData amo = (AmogusData)0.;
// don't forget about fog
UNITY_TRANSFER_FOG(amo, UnityObjectToClipPos(i.vertex));
amo.vertex = UnityObjectToClipPos(i.vertex);
//now we calculate the first fresnel layer
// not sure what these next 2 lines do, I copied them directly from bgolus
//amo.uv = i.uv  ;
amo.uv = -1 + 2 * i.uv ; // semicolons suck so back to the define
//when do we smoothstep?
amo.abnormal = float3(i.uv * amo.uv, smoothstep(7,5,3)) ;
// don't forget the space before ; otherwise the compiler thinks you meant uv; as one word
// ^
//#define # //
//#now I can do python comments
// you can type anything now because @ͣͫͦ ; Kit🍉 says we'll just delete the error lines ... but we won't because @Pema asked us not to
// pls stop youll make my job more annoying
//someone adds #include "UnityCG.cginc" before the AmogusData struct or we get errors for fog
// i got u
//discord sucks so bad I can’t even see the struct nor the amogus define
//making me restart discord smh
amo.color = float4(1, 0, 1, 1);
return amo;
}
//Grabpass {} :grief:
//GrabPass { "Backup" }  // not sure if this pass will be any good
float4 importantfunction(float4 a, float4 b , float4 c)
{
return smoothstep(a,b,c); }
static string whyDoStringsExist = "please stop grab passing sir";
//wait is this legal?
// chars work, not sure about strings
//Console.WriteLine(whyDoStringsExist)
//[maxvertexcount(12)]
// help, how do u make geometry shader??
//can we make it tesselate ???
// wait
#define BEN_GOLUS 0.26494726
#define FUDGE 0.65
#define THREE 3
//alright I’m immortalised in this shader
#define glsl_mod(x,y) (((x)-(y)*floor((x)/(y)))) // I'm sure we'll use this somehow
[maxvertexcount(3)] 
void gus(triangle AmogusData input[3], uint pid: SV_PrimitiveID, inout TriangleStream<AmogusData> triStream) {
// Oh god does that put the comment in where the define is?
#undef glsl_mod
// We good
for (int i = 0; i < 3; i++) {
// process the first 3 copies of the triangle, save the other 3 verts for below
AmogusData sus = (AmogusData)0.;
//We have a define for that number please use it
//I can’t write anymore. I’ve lost track of the input and output names
// guys we only have vert pos in clipspace since the vert shader ran first fugg
// because we wanted to tesselate in screen space, remember?
// :brainpower:
AmogusData amo = input[i];
sus.vertex = UnityObjectToClipPos(amo.vertex);
/*ASEBEGIN
Version=15900
227;235;1527;676;763.5;338;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;1;-250.5,-156;Float;False;375;166;This shader isn't made in amplify silly;1;0;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-154,-122;Float;False;True;2;Float;ASEMaterialInspector;0;1;Hidden/Templates/Unlit;0770190933193b94aaa3065e307002fa;0;0;Unlit;2;True;0;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;0;False;-1;True;True;True;True;True;0;False;-1;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
ASEEND*/
//CHKSM=3A3F590C09DD08BD6B286466E10956D4C08CE755
// did we ever pragma geom?
// yea
// ok cool
//oh wait mistake sorry
//good luck with this can’t wait to see how this turned out first thing in the morning tomorrow
//i'll wait after the geometry function is done cause i never do them and i don't remember anything about them
sus.vertex = amo.vertex; // prevent duplicated clipspace transformation
// oops xd
// no deleting code that compiles :angry:
// nobody understands geometry shaders, lets just output the input tri
sus = amo;
triStream.Append(sus);
int sum = 0;
[unroll(100)]
for (int k = 0; k < 100; k++) sum += k; // Burn some cycles compiling cause it's kinda cold in here
}
triStream.RestartStrip();
//I'm changing maxvertexcount to 3
// it's triStream 3
} // freedom
//what’s the frag Programm called again?
//wait why is restartStrip outside f the geometry function?
// its not, its outside the for loop
// the for loop doesn't have opening brackets, is a single instruction loop
// theres another loop further up
//oh
// I expect this shader to look good tomorrow
half4 Amo(AmogusData sussy) : SV_Target // i heard half4s were better than float4
{
// half4 is for the weak btw
//what about fixed4?
// we defined vec4 for a reason ...
//do you think this whole shader is fixed to begin with?
//idk what fixed does
//not fix this shit for sure
// wait i just realized i have that define backwards
//person above is a pessimist
// uh guys we have a problem
// vec4 is undefined
// fix it, failcompiles were allowed to fix
// k nvm nothing was ever wrong :slight_smile:
sussy.color = sussy.color.xxxx;
float cool = sin(sussy.uv.x * 5) * cos(sussy.uv.y * 5);
/*
⠀⠀⠀⡯⡯⡾⠝⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢊⠘⡮⣣⠪⠢⡑⡌
⠀⠀⠀⠟⠝⠈⠀⠀⠀⠡⠀⠠⢈⠠⢐⢠⢂⢔⣐⢄⡂⢔⠀⡁⢉⠸⢨⢑⠕⡌
⠀⠀⡀⠁⠀⠀⠀⡀⢂⠡⠈⡔⣕⢮⣳⢯⣿⣻⣟⣯⣯⢷⣫⣆⡂⠀⠀⢐⠑⡌
⢀⠠⠐⠈⠀⢀⢂⠢⡂⠕⡁⣝⢮⣳⢽⡽⣾⣻⣿⣯⡯⣟⣞⢾⢜⢆⠀⡀⠀⠪
⣬⠂⠀⠀⢀⢂⢪⠨⢂⠥⣺⡪⣗⢗⣽⢽⡯⣿⣽⣷⢿⡽⡾⡽⣝⢎⠀⠀⠀⢡
⣿⠀⠀⠀⢂⠢⢂⢥⢱⡹⣪⢞⡵⣻⡪⡯⡯⣟⡾⣿⣻⡽⣯⡻⣪⠧⠑⠀⠁⢐
⣿⠀⠀⠀⠢⢑⠠⠑⠕⡝⡎⡗⡝⡎⣞⢽⡹⣕⢯⢻⠹⡹⢚⠝⡷⡽⡨⠀⠀⢔
⣿⡯⠀⢈⠈⢄⠂⠂⠐⠀⠌⠠⢑⠱⡱⡱⡑⢔⠁⠀⡀⠐⠐⠐⡡⡹⣪⠀⠀⢘
⣿⣽⠀⡀⡊⠀⠐⠨⠈⡁⠂⢈⠠⡱⡽⣷⡑⠁⠠⠑⠀⢉⢇⣤⢘⣪⢽⠀⢌⢎
⣿⢾⠀⢌⠌⠀⡁⠢⠂⠐⡀⠀⢀⢳⢽⣽⡺⣨⢄⣑⢉⢃⢭⡲⣕⡭⣹⠠⢐⢗
⣿⡗⠀⠢⠡⡱⡸⣔⢵⢱⢸⠈⠀⡪⣳⣳⢹⢜⡵⣱⢱⡱⣳⡹⣵⣻⢔⢅⢬⡷
⣷⡇⡂⠡⡑⢕⢕⠕⡑⠡⢂⢊⢐⢕⡝⡮⡧⡳⣝⢴⡐⣁⠃⡫⡒⣕⢏⡮⣷⡟
⣷⣻⣅⠑⢌⠢⠁⢐⠠⠑⡐⠐⠌⡪⠮⡫⠪⡪⡪⣺⢸⠰⠡⠠⠐⢱⠨⡪⡪⡰
⣯⢷⣟⣇⡂⡂⡌⡀⠀⠁⡂⠅⠂⠀⡑⡄⢇⠇⢝⡨⡠⡁⢐⠠⢀⢪⡐⡜⡪⡊
⣿⢽⡾⢹⡄⠕⡅⢇⠂⠑⣴⡬⣬⣬⣆⢮⣦⣷⣵⣷⡗⢃⢮⠱⡸⢰⢱⢸⢨⢌
⣯⢯⣟⠸⣳⡅⠜⠔⡌⡐⠈⠻⠟⣿⢿⣿⣿⠿⡻⣃⠢⣱⡳⡱⡩⢢⠣⡃⠢⠁
⡯⣟⣞⡇⡿⣽⡪⡘⡰⠨⢐⢀⠢⢢⢄⢤⣰⠼⡾⢕⢕⡵⣝⠎⢌⢪⠪⡘⡌⠀
⡯⣳⠯⠚⢊⠡⡂⢂⠨⠊⠔⡑⠬⡸⣘⢬⢪⣪⡺⡼⣕⢯⢞⢕⢝⠎⢻⢼⣀⠀
⠁⡂⠔⡁⡢⠣⢀⠢⠀⠅⠱⡐⡱⡘⡔⡕⡕⣲⡹⣎⡮⡏⡑⢜⢼⡱⢩⣗⣯⣟
⢀⢂⢑⠀⡂⡃⠅⠊⢄⢑⠠⠑⢕⢕⢝⢮⢺⢕⢟⢮⢊⢢⢱⢄⠃⣇⣞⢞⣞⢾
⢀⠢⡑⡀⢂⢊⠠⠁⡂⡐⠀⠅⡈⠪⠪⠪⠣⠫⠑⡁⢔⠕⣜⣜⢦⡰⡎⡯⡾⡽
*/
// we are pretty close, just need to fill out a nice frag function
// everyone bring out their cool 1 liners
float x = importantfunction(cool.xxxx, 2, _Time.yyyy);
float4 cool4 = float4(cool,cool,cool,cool);
cool4 = importantfunction(cool4,cool4,cool4);
// Do i do it?
float ONE = cool4.x / 15.0;
// :(((((((((((((((((
// :LUL: :LUL:
float4 cibbiDidThis = float4(sussy.abnormal, ONE);
float4 pink = float4(1, 0, 1, 1); // might come in handy
// ok im retconning that cause it's a meme
float4 pema = float4('p', 'e', 'm', 'a');
pema /= 255.0;
//
if(sin(_Time.y * cool) > 0.95) discard; // Glitch shader
//that'll error since were in a function 3
// we need to decide on which color to return guys
// I have no clue what that's going to do
//this shader needs to return more than just a solid color!
if (sussy.uv.x < 0) {
float3 rayOrigin = _WorldSpaceCameraPos;
// how the fuck do i get raydir here lool
// :yesyesyesyes:  toocanzs
// too late :grief:
// i don't even know what the geometry  looks like
// it's just the same as input.. should be
float3 rayDir = float3(0, 0, 1);
float4 rayDirection = cool4;
//It’s a secret trick
rayDir = normalize(float3(sussy.uv, 1));
// galaxy brain
float t = 0;
for (int i = 0; i < 20; i++) { // also remember we are currently in an if-statement body
#define map(p, s) (length(p) - s)
float3 p = rayOrigin + rayDir * t;
// unhygeniec macros, yuck
if ((cool4 == THREE).x) return pink;
float dist = map(p, THREE / 6.0);
// ,s
// needs a size for the sphere
//3
if( dist < 0.01) return float(i)/20.0;
p += dot(cibbiDidThis, pink*_Time.y)  ;
t += dist;
// cibbiDidThis?
// ah
// cibbi did. that earlier
// i did
dist += t;
// i think we close the loop here?
}}
// close loop and if
// k outside if
// what now?
//what to do for other half of uv ?
// god this is going to be dumb
// does anyone even know if sussy.uv.x is ever less than 0 lol
// i think it was -1 to 1?
// yeah you made it -1; 1 range i believe
// ok good
float3 epic_shadertoy_shader = 0.5 + 0.5 * cos(_Time.y + sussy.uv.xyx + float3(0, 2, 4));
float f = max(abs(sussy.uv.x),abs(sussy.uv.y));
// Stolen from https://www.shadertoy.com/view/tdS3RyShadertoy

epic_shadertoy_shader *= f;
// maybe we should just return now.. and inspect the damage
// wait
epic_shadertoy_shader *= smoothstep(f,f,f);
// thatll be outside of LDR range tho :(((
epic_shadertoy_shader *= pow(FUDGE, 6);
// Fixed
return float4(epic_shadertoy_shader, 1); }
ENDCG
}}}