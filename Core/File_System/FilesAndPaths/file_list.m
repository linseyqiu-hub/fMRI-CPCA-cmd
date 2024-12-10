function [file_list numfiles] = file_list( from_dir )
% syntax: [file_list numfiles] = file_list( from_dir )
% returns the count and text list of files
% contained in the from_dir location
  
  file_list = [];
  numfiles = 0;

  d = dir( from_dir );
   
  if ( size(d,1) > 0 )

    for idx = 1:size(d,1)

      if ~d(idx).isdir

        if d(idx).name(1) ~= '.'
          file_list = [file_list; {char(d(idx).name)}];
        end;
      end;

    end;
  end;
 
  numfiles = size(file_list,1);

