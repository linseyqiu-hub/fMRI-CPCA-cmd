%truncates a path label into something that will fit into a text box
%the code performing <short path> is extracted from the programs written by mitenko david
% jp 11/18/09 I added the parameter to specify a length, which is passed to the subroutine to determine
% the maximum delimters to parse
function shorty=short_path(longpath, mx)

  if iscell(longpath)
    paths_n=size(longpath,2);
    if paths_n>5  %%truncate all the paths to make a summary
      for i=1:3
        shorty{i}=shorten(longpath{i}, mx);
      end;
      shorty{4}='...';
      shorty{5}=shorten(longpath{paths_n-1}, mx);
      shorty{6}=shorten(longpath{paths_n}, mx);
    else
      for i=1:paths_n
        shorty{i}=shorten(longpath{i}, mx);
      end;
    end;
  else
    shorty=shorten(longpath, mx);
  end;


  % --------------------------------------------------------
  % ---                 Inline function                  ---
  % --------------------------------------------------------
  function s=shorten(l, mx)

    idx = strfind(l, filesep);

    if size(idx,2) > mx
      start_point = mx - 1;
      use = size(idx,2) - start_point;  % only contain the closer directory
      s=['...' l(:,idx(:,use):size(l,2))];
    else
      s=l;
    end;

  end	% --- end inline shorten();


end
