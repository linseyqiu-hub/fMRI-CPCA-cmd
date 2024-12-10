function y = has_valid_analysis( model )

  lst = '';

  % ---------------------------
  % add the files from valid subdirectories (n_components)
  % ---------------------------
  rotations = define_rotations();
  valid_dirs = {'unrotated'};
  for ii = 1:size(rotations)  
    valid_dirs = [valid_dirs {rotations(ii).method}]; 
  end;
  
  [comp_list num_comps] = directory_list( [pwd filesep model filesep] );
   
  if num_comps > 0 

    for compcount = 1:size(comp_list, 1 )
      comp_dir = [pwd filesep model filesep char( comp_list(compcount) ) filesep];

      [sub_list sub_count] = directory_list( comp_dir );
      if sub_count > 0 
          
        for cdir = 1:sub_count
            
          if any( strcmp( char(sub_list(cdir)), valid_dirs)) 

            nc = num2str( validate_numeric_entry ( char( comp_list(compcount) ) ) );
            
            p = [comp_dir char(sub_list(cdir)) filesep ];
            q = [p char(42) '.mat' ];

            q = dir(q);
            if ( size(q, 1) > 0 )
              for jj = 1:size(q,1)
                if strfind( q(jj).name, model )
                  hrft = who_stats( p, q(jj).name, 'cpca_version' );
                  if hrft.mat_exists
                    lst = horzcat( lst, {q(jj).name});
                  end;
                end;	% --- not the hrfmax T variable
              end;
            end;
            
          end % -- valid data directory

        end % -- check if valid
      end;  % --- extraction directory found
        
    end;  % check each component count directory 
      
  end;  % -- no extracted component directories found for model type
  
  y = size(lst,1) > 0;

