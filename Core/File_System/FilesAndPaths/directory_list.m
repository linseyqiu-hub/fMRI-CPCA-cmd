function [dir_list numdirs] = directory_list( from_dir )
% syntax: [dir_list dir_count] = directory_list( from_dir )
% returns the count and text list of directories
% contained in the from_dir location
  
  dir_list = [];
  numdirs = 0;

  d = dir( from_dir );
   
  if ( size(d,1) > 0 )

    for idx = 1:size(d,1)

      if d(idx).isdir

        if d(idx).name(1) ~= '.'
          dir_list = [dir_list; {char(d(idx).name)}];
        end;
      end;

    end;
  end;
 
  numdirs = size(dir_list,1);

