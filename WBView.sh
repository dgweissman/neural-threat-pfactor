#!/bin/bash

# Usage (from parent dir):
# bash ./WBView.sh <file path to image you want to project>

ScriptDir=/mnt/stressdevlab/scripts/Figures/ConnectomeWB
GroupDir="/mnt/stressdevlab/"
Project=`pwd | awk -F "stressdevlab/" '{print $2}' | awk -F "/" '{print $1}'`
ProjectDir=${GroupDir}/${Project}

iFile=$1
iFilePath=`dirname ${iFile}`



#Threshold iFile with fslmaths
if [[ `basename ${iFile}` == *voxelwise* ]] || [[ `basename ${iFile}` == *X-M-Y* ]]; then
	echo "Image already thresholded with fslmaths. Not thresholding again!"
	NIFTINAME=`basename ${iFile} .nii.gz`
else
	fslmaths ${iFile} -thr 2.3 ${iFilePath}/voxelwise_`basename ${iFile}`
	NIFTINAME="voxelwise_"`basename ${iFile} .nii.gz`
fi

for side in LEFT RIGHT ; do

	#Add the Conte atlas to spec file
	wb_command -add-to-spec-file ${iFilePath}/${NIFTINAME}.spec CORTEX_${side} ${ScriptDir}/Conte69.${side}.midthickness.164k_fs_LR.surf.gii

	#Convert NIFTI to GIFTI
	wb_command -volume-to-surface-mapping ${iFilePath}/${NIFTINAME}.nii.gz ${ScriptDir}/Conte69.${side}.midthickness.164k_fs_LR.surf.gii ${iFilePath}/Conte69_164k_${side}_${NIFTINAME}.shape.gii -trilinear

	#Add GIFTI to spec file iFile with fslmaths
#if [[ ${NIFTINAME} == *voxelwise* ]] || [[ ${NIFTINAME} == *X-M-Y* ]]; then
#	echo "Image already thresholded with fslmaths. Not thresholding again!"
#else
	wb_command -add-to-spec-file ${iFilePath}/${NIFTINAME}.spec CORTEX_${side} ${iFilePath}/Conte69_164k_${side}_${NIFTINAME}.shape.gii
#fi
done

#Load Files
wb_view ${iFilePath}/${NIFTINAME}.spec -spec-load-all -no-splash
