function gh = adjust_hheader ( hdr )
% --- Adjust Hheader data structure to current structure

  gh = structure_define( 'HHEADER' );
  mdl = gh.model;

  if ispc
    this_from = '/';
    this_to = '\';
  else
    this_from = '\';
    this_to = '/';
  end;

  if ~isfield( hdr, 'model' )    		% --- old H model - set data into model(1)

    if isfield( hdr, 'unique_H' ) 		gh.model(1).unique_H = hdr.unique_H;		end;
    if isfield( hdr, 'use_VR' ) 		gh.model(1).use_VR = hdr.use_VR;		end;
    if isfield( hdr, 'path' )			gh.model(1).path = hdr.path;			end;
    if isfield( hdr, 'file' )			gh.model(1).file = hdr.file;			end;
    if isfield( hdr, 'var' ) 			gh.model(1).var = hdr.var;			end;
    if isfield( hdr, 'size' ) 			gh.model(1).size = hdr.size;			end;

    if isfield( hdr, 'path_to_segs' ) 		
       if strfind(hdr.path_to_segs, 'GMH')       
         gh.model(1).path_to_segs.GMH = hdr.path_to_segs;  
       else		
         if strfind(hdr.path_to_segs, 'BH')       
           gh.model(1).path_to_segs.BH = hdr.path_to_segs;  
         else		
           gh.model(1).path_to_segs.EH = hdr.path_to_segs;  
         end;		
       end;		
    end;

    if isfield( hdr, 'sum_diagonal' ) 		gh.sum_diagonal = hdr.sum_diagonal;		end;
    if isfield( hdr, 'options' ) 		gh.options = hdr.options;			end;

  else
    % ---  Hheader version 1.0 to Header version 1.2

    gh.model = [];
    gh.Hindex = hdr.Hindex;

    for ii = 1:size( hdr.model,1)

      hm = mdl;		% --- clean model structure

      % --- no changes in these fields
      if isfield( hdr.model(ii), 'id' )             hm.id = hdr.model(ii).id;                       end;
      if isfield( hdr.model(ii), 'unique_H' )       hm.unique_H = hdr.model(ii).unique_H;           end;
      if isfield( hdr.model(ii), 'use_VR' ) 		hm.use_VR = hdr.model(ii).use_VR;               end;
      if isfield( hdr.model(ii), 'path' )			hm.path = hdr.model(ii).path;                   end;
      if isfield( hdr.model(ii), 'file' )			hm.file = hdr.model(ii).file;                   end;
      if isfield( hdr.model(ii), 'var' ) 			hm.var = hdr.model(ii).var;                     end;
      if isfield( hdr.model(ii), 'size' )           hm.size = hdr.model(ii).size;                   end;
      if isfield( hdr.model(ii), 'sum_diagonal' )   hm.sum_diagonal = hdr.model(ii).sum_diagonal;	end;
      if isfield( hdr.model(ii), 'options' ) 		hm.options = hdr.model(ii).options;             end;

      if ~isfield( hdr.model(ii).path_to_segs', 'ZH' ) 		
        if strfind(hdr.model(ii).path_to_segs, 'GMH')       
          hm.path_to_segs.GMH = hdr.model(ii).path_to_segs;  
        else		
          if strfind(hdr.model(ii).path_to_segs, 'ZH')       
            hm.path_to_segs.ZH = hdr.model(ii).path_to_segs;  
          else		
            hm.path_to_segs.EH = hdr.model(ii).path_to_segs;  
          end;		
        end;		

      else
        hm.path_to_segs = hdr.model(ii).path_to_segs;  
      end;

      if isfield( hdr.model(ii), 'partitions' ) 
        if ~isempty( hdr.model(ii).partitions )
          hm.partitions = hdr.model(ii).partitions;
        else
          hm.partitions = calc_Qh_Blocksize( Zheader.total_columns, constant_define( 'PARTITION_MAX' ) );
        end;
      else
        hm.partitions = calc_Qh_Blocksize( Zheader.total_columns, constant_define( 'PARTITION_MAX' ) );
      end;
      
      gh.model = [gh.model; hm];

    end;  % --- each defined H model
    
  end;






