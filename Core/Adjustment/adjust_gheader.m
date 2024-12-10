function gh = adjust_gheader ( hdr )
% --- Adjust Gheader data structure to current structure

global Zheader

  gh = structure_define( 'GHEADER' );

  if ispc
    this_from = '/';
  else
    this_from = '\';
  end;

  if isfield( hdr, 'model_type' )           gh.model_type = hdr.model_type;			end;
  if isfield( hdr, 'conditions' )           gh.conditions = hdr.conditions;			end;
  if isfield( hdr, 'bins' )                 gh.bins = hdr.bins;				end;
  if isfield( hdr, 'TR' )                   gh.TR = hdr.TR;					end;
  if isfield( hdr, 'displacement' )         gh.displacement = hdr.displacement;		end;
  if isfield( hdr, 'mean_tr' )              gh.mean_tr = hdr.mean_tr;			end;
  if isfield( hdr, 'prefix' )               gh.prefix = hdr.prefix;				end;
  if isfield( hdr, 'inScans' )              gh.inScans = hdr.inScans;			end;
  if isfield( hdr, 'isHRF' )                gh.isHRF = hdr.isHRF;				end;
  if isfield( hdr, 'condition_name' )       gh.condition_name = hdr.condition_name;		end;
  if isfield( hdr, 'path_to_segs' ) 		
		gh.path_to_segs = strrep( hdr.path_to_segs , this_from, filesep);		end;
  if isfield( hdr, 'applied_to' ) 		
		gh.applied_to = strrep( hdr.applied_to, this_from, filesep);			end;
  if isfield( hdr, 'source' ) 			
		gh.source = strrep( hdr.source, this_from, filesep);				end;
  if isfield( hdr, 'illformed' )            gh.illformed = hdr.illformed;			end;
  if isfield( hdr, 'subjects' )             gh.subjects = hdr.subjects;			end;
  if isfield( hdr, 'date_applied' )         gh.date_applied = hdr.date_applied;		end;
  if isfield( hdr, 'subject_encoded' )      gh.subject_encoded = hdr.subject_encoded;	end;

  if isempty( gh.subject_encoded )          gh.subject_encoded = ones( 1, Zheader.num_subjects ) * gh.conditions;	end;

  if isfield( hdr, 'GZheader' ) 	

    if ~isempty( hdr.GZheader )
      if isfield( hdr.GZheader, 'prefix' ) 	gh.GZheader.prefix = hdr.GZheader.prefix;		end;
      if isfield( hdr.GZheader, 'columns' ) gh.GZheader.columns = hdr.GZheader.columns;		end;
      if isfield( hdr.GZheader, 'runs' ) 	gh.GZheader.runs = hdr.GZheader.runs;			end;
      if isfield( hdr.GZheader, 'rsum' ) 	gh.GZheader.rsum = hdr.GZheader.rsum;			end;
      if isfield( hdr.GZheader, 'subjects' ) gh.GZheader.subjects = hdr.GZheader.subjects;		end;
      if isfield( hdr.GZheader, 'sum_diagonal' ) 	gh.GZheader.sum_diagonal = hdr.GZheader.sum_diagonal;	end;
      if isfield( hdr.GZheader, 'path_to_segs' ) 	
		gh.GZheader.path_to_segs = strrep( hdr.GZheader.path_to_segs, this_from, filesep);	end;
    end;

  else
    gh.GZHeader = structure_define( 'GZHEADER' );
  end;

  if isfield( hdr, 'GAZheader' ) 	

    if ~isempty( hdr.GAZheader )
      if isfield( hdr.GAZheader, 'prefix' ) 	gh.GAZheader.prefix = hdr.GAZheader.prefix;		end;
      if isfield( hdr.GAZheader, 'columns' ) 	gh.GAZheader.columns = hdr.GAZheader.columns;		end;
      if isfield( hdr.GAZheader, 'runs' ) 		gh.GAZheader.runs = hdr.GAZheader.runs;			end;
      if isfield( hdr.GAZheader, 'subjects' ) 	gh.GAZheader.subjects = hdr.GAZheader.subjects;		end;
      if isfield( hdr.GAZheader, 'sum_diagonal' ) 	gh.GAZheader.sum_diagonal = hdr.GAZheader.sum_diagonal;	end;
      if isfield( hdr.GAZheader, 'path_to_segs' ) 	
		gh.GAZheader.path_to_segs = strrep( hdr.GAZheader.path_to_segs, this_from, filesep);	end;
    end;
  end
  
  gh.prefix = 'G';
  if isfield( hdr, 'raw' )              gh.raw = hdr.raw;				end;
  if isfield( hdr, 'norm' ) 			gh.norm = hdr.norm;				end;
  if isfield( hdr, 'Description' )		gh.Description = hdr.Description;		end;
  if isfield( hdr, 'Import_File' )		gh.Import_File = hdr.Import_File;		end;


  if isfield( hdr, 'has_ROI' )          gh.has_ROI = hdr.has_ROI;               end;
  if isfield( hdr, 'use_ROI' )          gh.use_ROI = hdr.use_ROI;               end;



