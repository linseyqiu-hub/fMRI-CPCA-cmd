function [ ftag fdsp ] = frequency_tag( FrequencyNo )
global scan_information

  ftag = '';
  fdsp = '';
  if scan_information.frequencies > 0 
    if ( length(char(scan_information.freq_names(FrequencyNo))) > 0 )  
      if ( ~strcmp( char(scan_information.freq_names(FrequencyNo)), '<na>') )  
        fdsp = char(scan_information.freq_names(FrequencyNo)); 
        ftag = ['_' fdsp]; 
      end;
    end;
  end;

