function hasZ = has_Z();
global Zheader scan_information

  hasZ = 0;

  ftag = frequency_tag( 1 );

  Normalized_Z_Dir = Z_Directory();
  ZName = [ Normalized_Z_Dir 'Z' filesep 'Z' num2str(Zheader.num_subjects) ftag '.mat'];

  d = dir( ZName );
  hasZ = size(d,1) == 1;

