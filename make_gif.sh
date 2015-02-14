#!/bin/bash

###################################################
# Make animated gif file from fMRI 4D image
#
# (c) DOHMATOB [Elvis] Dopgima <gmdopp@gmail.com
###################################################

: {FSL_VERS=5.0}

function usage {
    printf "\tUsage: bash $0 <input_4D_image> [scaling] [xslice] [yslice] [zslice]\n\n"
    exit 1
}

if [ "$1" = "" ]; then
    printf "\n\tERROR: Too few arguments!\n"
    usage
fi

# configure FSL
if [ ! -e /etc/fsl/${FSL_VERS}/fsl.sh ]; then
    echo "ERROR: FSL config file /etc/fsl/${FSL_VERS}/fsl.sh doesn't exist!"
    echo "Set FSL_VERS (current value if ${FSL_VERS} according to your FSL version, and rerun."
    exit 1
fi
source /etc/fsl/${FSL_VERS}/fsl.sh

# full verbose: report everythx happenx
set -e
set -xv

# get input
input_4D_img=`remove_ext $1`
scaling=${2:-4}
xslice=${3:-0.5}
yslice=${4:-0.5}
zslice=${5:-0.5}

# split input 4d image into seperate 3d images, and walk them
fslsplit ${input_4D_img} ${input_4D_img}_DEADBEEF -t
for vol in `imglob ${input_4D_img}_DEADBEEF????.nii.gz`; do
    # generate a plot per dimension
    slicer ${vol} -s ${scaling} -x ${xslice} ${vol}_x.png
    slicer ${vol} -s ${scaling} -y ${yslice} ${vol}_y.png
    slicer ${vol} -s ${scaling} -z ${zslice} ${vol}_z.png

    # merge all per-dimension plots into a single thumbnail
    pngappend ${vol}_y.png + ${vol}_x.png - ${vol}_z.png ${vol}_xyz.png
done

# merge all per-volume thumbnails into an animated gif mivie
convert -delay 10 ${input_4D_img}_DEADBEEF????_xyz.png ${input_4D_img}_movie.gif
echo "Done. Output movie written to ${input_4D_img}_movie.gif"

# cleanup
rm -f ${input_4D_img}_DEADBEEF????.nii.gz
rm -f ${input_4D_img}_DEADBEEF????.png
