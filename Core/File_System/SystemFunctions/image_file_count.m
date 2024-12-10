function [nii img] = image_file_count( from_dir )
% syntax: [nii img] = image_file_count( from_dir )
% returns the count of image files (.nii and .img) contained in specified directory
global scan_information 

  d = dir( [from_dir filesep '*.img'] );
  img = size(d,1);

  d = dir( [from_dir filesep '*.nii'] );
  nii = size(d,1);
 
