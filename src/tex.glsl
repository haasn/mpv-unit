//!HOOK MAIN
//!BIND HOOKED
//!BIND DISCO
//!COMPONENTS 3

vec4 hook()
{
    return vec4(texture(DISCO, HOOKED_pos * 3).rgb, 1);
}

//!TEXTURE DISCO
//!SIZE 3 3
//!COMPONENTS 3
//!FORMAT 32f
//!FILTER NEAREST
//!BORDER REPEAT

00 00 80 3f
00 00 00 00
00 00 00 00

00 00 00 00
00 00 80 3f
00 00 00 00

00 00 00 00
00 00 00 00
00 00 80 3f

00 00 00 00
00 00 80 3f
00 00 80 3f

00 00 80 3f
00 00 00 00
00 00 80 3f

00 00 80 3f
00 00 80 3f
00 00 00 00

9a 99 99 3e
9a 99 99 3e
9a 99 99 3e

9a 99 19 3f
9a 99 19 3f
9a 99 19 3f

00 00 80 3f
00 00 80 3f
00 00 80 3f
