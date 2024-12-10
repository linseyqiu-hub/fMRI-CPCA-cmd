function hasE = has_E();
global Zheader scan_information

  hasE = 0;

  ftag = frequency_tag( 1 );

  Normalized_Z_Dir = Z_Directory();
  ZName = [ Normalized_Z_Dir 'Z' filesep 'E' num2str(Zheader.num_subjects) ftag '.mat'];

  d = dir( ZName );
  hasE = size(d,1) == 1;
