function has_mat = has_component_directory( model, submodel, subprocess )
global Zheader scan_information 

  has_mat = 0;

  if nargin < 2  submodel = '';  end;
  if nargin < 3  subprocess = submodel;  end;

  noParms = struct( 'model', 'G' );
  
  if ~isempty( submodel )
    if strcmp(model, 'H') | ( size( submodel, 2 ) > 2 )	% only GMH files are different
%      sub_file = [ submodel char(42) '.mat'];
      sub_file = [ subprocess char(42) '.mat'];
      
      load( Zheader.Limits.path);
      H_ID = H_path_spec( Hheader, submodel );
      noParms = struct( 'model', 'H', 'mode', submodel, 'hindex',  H_ID );
      
    else
      sub_file = [ model subprocess char(42) '.mat'];
    end
  else
    sub_file = [ char(42) '.mat'];
  end

  [comp_list num_comps] = directory_list( [pwd filesep model filesep] );
   
  if num_comps > 0 

    for compcount = 1:size(comp_list, 1 )

      if ~isempty( strfind( char( comp_list(compcount) ), 'components' ) )

        xx = regexp( char( comp_list(compcount) ), '_', 'split' );
        nd = str2num( char(xx(1)));
        pth =  fs_path( 'unrotated', 'output', nd, 0, noParms );
        
        q = dir( [pth sub_file] );
        if ( size(q, 1) > 0 )
          has_mat = 1;
          return;
        end;		% --- mat files found in extraction/rotation directory ---
        
      end;  % if the directory name contains the text 'components'
        
    end;  % check each component count directory 
      
  end;  % -- no extracted component directories found for model type

