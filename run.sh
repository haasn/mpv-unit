#!/bin/bash
set -e
cd "${0%/*}"

# Configuration
MPV_OPTS="--no-config --no-osc --idle --pause --geometry 500x500 \
    --title mpv_test --video-unscaled --video-osd=no --dither=no \
    --opengl-dumb-mode=no -v"

MPV="../../build/mpv"

# Generate command FIFO
command_fifo=/tmp/mpv-test-fifo-$$-$RANDOM
trap 'rm -f "$command_fifo"' EXIT INT TERM HUP
mkfifo -m 600 "$command_fifo"

# Start MPV
$MPV $MPV_OPTS --input-file="$command_fifo" &
mpv_pid=$!
sleep 1

cmd() {
    echo "$*" >>"$command_fifo"
}

## Run tests

load() {
    cmd loadfile "$*"
    sleep 0.2
}

save() {
    sleep 0.2
    cmd screenshot-to-file out/$1.png window
}

# clean up old outputs
find ./out -type f -delete

cmd print-text '${vo-passes}' # shouldn't crash

## Test upscaling

SCALERS="bilinear bicubic_fast oversample ewa_lanczos spline36"

load src/dot.ppm
cmd set video-unscaled no
for scale in $SCALERS; do
    cmd set scale $scale
    save up-$scale
done
cmd set video-unscaled yes

load src/rings_sm_orig.gif
cmd set video-zoom 3.14159
cmd set linear-upscaling yes
save up-linear
cmd set linear-upscaling no
cmd set sigmoid-upscaling yes
save up-sigmoid
cmd set sigmoid-upscaling no
cmd set scale-antiring 1
save up-antiring
cmd set scale-antiring 0
cmd set video-zoom 0
cmd set scale bilinear

## Test downscaling

load src/rings_lg_orig.png
cmd set video-zoom -1.5
for scale in $SCALERS; do
    cmd set dscale $scale
    save down-$scale
done

cmd set linear-scaling yes
save down-linear
cmd set linear-scaling no
cmd set correct-downscaling yes
save down-correct
cmd set correct-downscaling no
cmd set video-zoom 0
cmd set dscale bilinear

## Test chroma scaling + rotation

cmd set video-zoom 6
cmd set scale spline36
cmd set cscale spline36

for file in odd odd-rect; do
    load src/small-chroma-$file.jpg
    for rot in 0 90 180 270; do
        cmd set video-rotate $rot
        save chroma-$file-$rot
    done
done

cmd set scale bilinear
cmd set cscale bilinear
cmd set video-rotate 0

cmd set opengl-dumb-mode yes
save chroma-dumb
cmd set opengl-dumb-mode no
cmd set video-zoom 0

## Test color management

cmd set target-trc bt.1886
cmd set video-zoom -1
for file in 709_709 709_2020nc 709_2020c 2020_2020nc; do
    load src/$file.mkv
    for prim in bt.709 bt.2020; do
        cmd set target-prim $prim
        save cms-$prim-$file
    done
done

load src/circles.jpg
cmd set video-zoom 2
cmd set target-prim bt.709
for trc in bt.1886 srgb linear pq hlg v-log s-log1 s-log2; do
    cmd set target-trc $trc
    save cms-$trc
done
cmd set target-trc srgb
for ootf in display hlg 709-1886 gamma1.2; do
    cmd vf set format=light=$ootf
    save ootf-$ootf
done
cmd vf set format=gamma=hlg
for mode in clip mobius reinhard hable gamma linear; do
    cmd set hdr-tone-mapping $mode
    save hdr-$mode
done
cmd set hdr-compute-peak yes
save hdr-compute-peak
cmd set hdr-compute-peak no
cmd vf clr '""'
cmd set hdr-tone-mapping mobius
cmd set target-trc auto
cmd set target-prim auto
cmd set video-zoom 0

## Test misc stuff

load src/circles.jpg
cmd set video-zoom 2
cmd set dither ordered
cmd set dither-depth 2
save dither
cmd set dither no

cmd set linear-scaling yes
for shader in gray tex offset compute; do
    cmd set opengl-shaders src/$shader.glsl
    save glsl_$shader
done
cmd set opengl-shaders '""'
cmd set linear-scaling no
cmd print-text '${vo-passes}' # shouldn't crash

## Cleanup

cmd quit
wait $mpv_pid
colordiff -r out ref
