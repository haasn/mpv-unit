# Unit tests for mpv

I mostly wrote this for myself, so I can more easily verify the output of mpv
is still correct after making changes to `vo_opengl` - but feel free to use it
yourself if you want to.

## Usage

```bash
$ cd path_to_mpv_dir
$ git clone https://github.com/haasn/mpv-unit test/unit
$ # make changes and recompile
$ ./test/unit/run.sh
```

Any differing files will get listed. If you want, you can inspect them
manually to assess the extent of the error. If you're positive that the new
file is correct, or if this is your first time running the tests, you can copy
over the results using the equivalent of

```bash
$ rsync -r --del ./test/unit/{out,ref}/
```

## Notes

This is an extremely shitty hack, that relies on a few properties:

1. the `sleep` commands in the test script are long enough to give mpv time to
   render the thing
2. my window manager automatically floats the mpv window to respect --geometry

Since these assumptions, and the specific behavior of OpenGL drivers is not
really portable, I won't commit the `reference` screenshots into the repo, you
have to produce your own on your own machine.

And yes, I'm aware that some of these test cases actually produce incorrect
output currently. The status quo is that chroma planes are squished by a
half-pixel when playing back oddly-sized non-square subsampled files with
irregular chroma position. If you care, go deal with it.
