function [ hdr, info] = adjust_headers( zh, si, pth )
% --- Adjust legacy data structure to last defined legacy structure

    % ----------------------------------
    % update the main Z Header structure
    % ----------------------------------

% - indicates field phased out, but not yet deleted from structure definition
    info = legacy_define( 'scan_information' );
    hdr  = legacy_define( 'ZHeader' );

    if isfield( zh, 'cpca_version' )	
      if ( ~isempty( zh.cpca_version ) )
        hdr.cpca_version = zh.cpca_version; 
      else
        hdr.cpca_version = constant_define( 'REVISION' );			
      end;
    else 
      hdr.cpca_version = constant_define( 'REVISION' );	
    end;

    last_revision = revision_value( hdr.cpca_version );
    if ~isempty( zh.edit_version )
      last_revision = str2num( zh.edit_version );
    end;
    if size(zh.cpca_version.release, 2) > 0
      isPublic = zh.cpca_version.release(1) == 'p';
    else
      isPublic = 1;
    end;
    
    hdr.edit_version =  constant_define( 'VERSION_NUMBER' );

    if isfield( zh, 'num_subjects' )		hdr.num_subjects = zh.num_subjects;			end;
    if isfield( zh, 'num_runs' )		hdr.num_runs = zh.num_runs;				end;
    if isfield( zh, 'memory_limit' )		hdr.memory_limit = zh.memory_limit;			end;
    if isfield( zh, 'total_scans' )		hdr.total_scans = zh.total_scans;			end;
    if isfield( zh, 'total_columns' )		hdr.total_columns = zh.total_columns;			end;

    if isfield( zh, 'num_Z_arrays' )		hdr.num_Z_arrays = zh.num_Z_arrays;			end;	% --- [2.93]
    if isfield( zh, 'Z_array_names' )		hdr.Z_array_names = zh.Z_array_names;			end;	% --- [2.93]
   
    if isfield( zh, 'partitions' )		
      if isfield( zh.partitions, 'partitioned' ) hdr.partitions.partitioned = zh.partitions.partitioned; else hdr.partitions.partitioned = 0; end;
      if isfield( zh.partitions, 'count' )	hdr.partitions.count = zh.partitions.count;		else hdr.partitions.count = 0;end;
      if isfield( zh.partitions, 'width' )	hdr.partitions.width = zh.partitions.width;		else hdr.partitions.width = 0;end;
      if isfield( zh.partitions, 'columns' )  	hdr.partitions.columns = zh.partitions.columns; 	else hdr.partitions.columns = [];end;
      if isfield( zh.partitions, 'last' )	hdr.partitions.last = zh.partitions.last;		else hdr.partitions.last = 0;end;
      if isfield( zh.partitions, 'mem' )	hdr.partitions.mem = zh.partitions.mem;			else hdr.partitions.mem = 0;end;
    end;

    if isfield( zh, 'original_partitions' )		
      if isfield( zh.original_partitions, 'partitioned' ) 	hdr.partitions.original_partitioned = zh.original_partitions.partitioned;	end;
      if isfield( zh.original_partitions, 'count' )		hdr.original_partitions.count = zh.original_partitions.count;			end;
      if isfield( zh.original_partitions, 'width' )		hdr.original_partitions.width = zh.original_partitions.width;			end;
      if isfield( zh.original_partitions, 'columns' )  	hdr.original_partitions.columns = zh.original_partitions.columns;		end;
      if isfield( zh.original_partitions, 'last' )		hdr.original_partitions.last = zh.original_partitions.last;			end;
      if isfield( zh.original_partitions, 'mem' )		hdr.original_partitions.mem = zh.original_partitions.mem;			end;
    end;

%    if isfield( zh, 'partition_max' ) hdr.partition_max = zh.partition_max; 				end;

%    hdr.partitions.mem = array_sizes( [hdr.total_scans hdr.partitions.width ] );
    
   
%    if isfield( zh, 'min_columns' )		hdr.min_columns = zh.min_columns;			end;
%    if isfield( zh, 'column_count' )		hdr.column_count = zh.column_count;			end;
    if isfield( zh, 'max_scans' )		hdr.max_scans = zh.max_scans;				end;
    if isfield( zh, 'min_scans' )		hdr.min_scans = zh.min_scans;				end;
    if isfield( zh, 'timeseries' )		hdr.timeseries = zh.timeseries;				end;
    if isfield( zh, 'cluster_data' )		hdr.cluster_data = zh.cluster_data;			end;

    if isfield( zh, 'rfac' )			hdr.rfac = zh.rfac;					end;
    if isfield( zh, 'tsum_with_trends' )	hdr.tsum_with_trends = zh.tsum_with_trends;		end;  % --- 8.0.0 [3.0.0]
    if isfield( zh, 'tsum_linear_trends' )	hdr.tsum_linear_trends = zh.tsum_linear_trends;		end;  % --- 8.0.0 [3.0.0]
    if isfield( zh, 'tsum_quadratic_trends' )	hdr.tsum_quadratic_trends = zh.tsum_quadratic_trends;	end;  % --- 8.0.0 [3.0.0]
    if isfield( zh, 'tsum_user_trends' )	hdr.tsum_user_trends = zh.tsum_user_trends;		end;  % --- 8.0.19 [3.0.0]
    if isfield( zh, 'tsum_hm_trends' )		hdr.tsum_hm_trends = zh.tsum_hm_trends;			end;  % --- 8.0.20 [3.0.0]
    if isfield( zh, 'tsum_trends' )		hdr.tsum_trends = zh.tsum_trends;			end;  % --- post 5.4.0 (4.4.0)
    if isfield( zh, 'tsum' )			hdr.tsum = zh.tsum;					end;  % ---  pre 5.4.0 (4.4.0)
    if isfield( zh, 'rsum' )			hdr.rsum = zh.rsum;					end;  % ---  Apr 2014
    if isfield( zh, 'tsum_E' )			hdr.tsum_E = zh.tsum_E;					end;
    if isfield( zh, 'tsum_HE' )			hdr.tsum_HE = zh.tsum_HE;				end;  % --- 8.1.03 [3.0.2]
    if isfield( zh, 'tsum_clusters' )		hdr.tsum_clusters = zh.tsum_clusters;			end;  % --- post 5.4.0 (4.4.0)
 
    if isfield( zh, 'tsum_removed' )		hdr.tsum_trends = zh.tsum_removed;			end;  % ---  pre 5.4.0 (4.4.0)
    if isfield( zh, 'ts_vector' )		hdr.ts_vector = zh.ts_vector;				end;

    if isfield( zh, 'MeanCentered' )		hdr.MeanCentered = zh.MeanCentered;			end;
    if isfield( zh, 'Normalized' )		hdr.Normalized = zh.Normalized;				end;

    if isfield( zh, 'older_Z' )		hdr.older_Z = zh.older_Z;				end;
    if isfield( zh, 'Z_File' )			% ensure all declarations exists
      if isfield( zh.Z_File, 'name' )		hdr.Z_File.name = zh.Z_File.name;			end;
      if isfield( zh.Z_File, 'directory' )	hdr.Z_File.directory = zh.Z_File.directory;		end;
      if isfield( zh.Z_File, 'variable' )	
        if isfield( zh.Z_File.variable, 'name' ) hdr.Z_File.variable.name = zh.Z_File.variable.name;	end;
        if isfield( zh.Z_File.variable, 'sz_x' ) hdr.Z_File.variable.sz_x = zh.Z_File.variable.sz_x;	end;
        if isfield( zh.Z_File.variable, 'sz_y' ) hdr.Z_File.variable.sz_y = zh.Z_File.variable.sz_y;	end;
      end;					% --- isfield( zh.Z_File, 'variable' ) ---

      if isfield( zh.Z_File, 'mean_centered' )	hdr.Z_File.mean_centered = zh.Z_File.mean_centered;	end;
      if isfield( zh.Z_File, 'normalized' )	hdr.Z_File.normalized = zh.Z_File.normalized;		end;
    end;					% --- isfield( zh, 'Z_File' ) ---

%    hdr.Z_Directory = pth;			% we force the Z location to it's path
    if ~isempty( zh.Z_Directory' )		hdr.Z_Directory = zh.Z_Directory;  else hdr.Z_Directory = pth; 	end;
    if isfield( zh, 'Z_Original' )		hdr.Z_Original = zh.Z_Original;				end;
    if isfield( zh, 'Description' )		hdr.Description = zh.Description;			end;
    if isfield( zh, 'Model' )			hdr.Model = zh.Model;					end;
    if ~isfield( hdr.Model, 'hdr_exists' )	hdr.Model.hdr_exists = 0;				end;

    if isfield( zh, 'conditions' )		
      if isfield( zh.conditions, 'Names' )	hdr.conditions.Names = zh.conditions.Names;		end;
      if isfield( zh.conditions, 'subject' )	hdr.conditions.subject = zh.conditions.subject;		end;
      if isfield( zh.conditions, 'encoded' )	hdr.conditions.encoded = zh.conditions.encoded;		end;
      if isfield( zh.conditions, 'sp' )		hdr.conditions.sp = zh.conditions.sp;			end;
      if isfield( zh.conditions, 'allEncoded' )	hdr.conditions.allEncoded = zh.conditions.allEncoded;	end;
      if isfield( zh.conditions, 'nonEncoded' )	hdr.conditions.nonEncoded = zh.conditions.nonEncoded;	end;

      if ~isfield( zh.conditions, 'allEncoded' )	% -- calculate conditione encoding valuse
        for SubjectNo = 1:zh.num_subjects

          for ii = 1:size( zh.conditions.Names,2)
            for runno = 1:zh.num_runs
              if any ( zh.conditions.subject(SubjectNo).Run(runno).conditions == ii )
                hdr.conditions.allEncoded = hdr.conditions.allEncoded + 1;
              else
                hdr.conditions.nonEncoded = hdr.conditions.nonEncoded + 1;
              end;
            end;  % --- each run
          end; % --- each condition
        end;  % --- each subject
      end;

    end;

    if isfield( zh, 'P' )			hdr.P = zh.P;						end;
    if isfield( zh, 'D' )			hdr.D = zh.D;						end;
    if isfield( zh, 'Contrast' )		hdr.Contrast = zh.Contrast;				end;

    if isfield( zh, 'Limits' )			hdr.Limits = zh.Limits;					end;
    if isfield( zh, 'NumComponents_GA' )	hdr.NumComponents_GA = zh.NumComponents_GA;		end;
    if isfield( zh, 'NumComponents_H' )		hdr.NumComponents_H = zh.NumComponents_H;		end;
    if isfield( zh, 'ZZ' )			hdr.ZZ = zh.ZZ;						end;
    if isfield( zh, 'summaries' )		hdr.summaries = zh.summaries;				end;
    if isfield( zh, 'GAZ' )			hdr.GAZ = zh.GAZ;					end;


    % ----------------------------------
    % if missing threshold variables, default to original specs
    % ----------------------------------
    if isfield( zh, 'pct_threshold' )		hdr.pct_threshold = zh.pct_threshold;	
       else 					hdr.pct_threshold = 2;					end;
    if isfield( zh, 'pct_value' )		hdr.pct_value = zh.pct_value;	
       else 					hdr.pct_value = [ 1 5 10];				end;

    if isfield( zh, 'active_runs' )	
      if hdr.active_runs == 0 
        if hdr.num_runs > 1
          for ii = 1:hdr.num_subjects
            hdr.active_runs = hdr.active_runs + size(hdr.timeseries.subject(ii).run, 1 );
          end;
        else
          hdr.active_runs = hdr.num_subjects;
        end;
      else
        hdr.active_runs = zh.active_runs;		
      end;
    else
      if hdr.num_runs > 1
        for ii = 1:hdr.num_subjects
          hdr.active_runs = hdr.active_runs + size(hdr.timeseries.subject(ii).run, 1 );
        end;
      else
        hdr.active_runs = hdr.num_subjects;
      end;
    end;
       
    % ----------------------------------
    % update the main Z scan and process structure
    % ----------------------------------

    if isfield( si, 'NumSubjects' )		info.NumSubjects = si.NumSubjects;			end;
    if isfield( si, 'NumRuns' )			info.NumRuns = si.NumRuns;				end;
    if isfield( si, 'MinRuns' )			info.MinRuns = si.MinRuns; else info.MinRuns = 	info.NumRuns; 	end;  	% [3.01]
    if info.MinRuns == 0  info.MinRuns = 	info.NumRuns;  						end;
    if isfield( si, 'NumGroups' )		info.NumGroups = si.NumGroups;				end;
    if isfield( si, 'BaseDir' )			info.BaseDir = si.BaseDir;				end;
    if isfield( si, 'ListSpec' )		info.ListSpec = si.ListSpec;				end;
    if isfield( si, 'FileList' )		info.FileList = si.FileList;				end;
    if isfield( si, 'DirChar' )			info.DirChar = si.DirChar;				end;
    if isfield( si, 'SubjDir' )			info.SubjDir = si.SubjDir;				end;
    if isfield( si, 'SubjectID' )		info.SubjectID = si.SubjectID;				end;
    if isfield( si, 'duplicate_IDs' )		info.duplicate_IDs = si.duplicate_IDs;			end;	% [2.96]
    if isfield( si, 'GroupList' )		info.GroupList = si.GroupList;				end;
    if isfield( si, 'isMulFreq' )		info.isMulFreq = si.isMulFreq;				end;	% [2.93]
    if isfield( si, 'frequencies' )		info.frequencies = si.frequencies;			end;	% [2.93]
    if isfield( si, 'freq_names' )		info.freq_names = si.freq_names;			end;	% [2.93]
    if isfield( si, 'freq_dirs' )		info.freq_dirs = si.freq_dirs;				end;	% [2.93]
    if isfield( si, 'SubjDir' )			info.SubjectDirs = si.SubjDir;				end;	% [2.93]
    if isfield( si, 'SubjectDirs' )		info.SubjectDirs = si.SubjectDirs;			end;	% [2.93]
    if isfield( si, 'run_dirs' )		info.run_dirs = si.run_dirs;				end;	% [2.93]
    if isfield( si, 'scandir_format' )		info.scandir_format = si.scandir_format;		end;	% [2.93]

    nmgrp = 0;
    grps = [];
    for ii = 1:size(info.GroupList,1)  
      if  length(info.GroupList(ii).subjectlist) > 0 nmgrp = nmgrp + 1;  grps = [grps; info.GroupList(ii)]; end;
    end;
    info.NumGroups = nmgrp;
    info.GroupList = grps;

    % ----------------------------------
    % the info processing flags will be left as defaults
    % ----------------------------------

    if isfield( si, 'scan_subjects' )           info.scan_subjects = si.scan_subjects;			end;
    if isfield( si, 'read_subject_images' )     info.read_subject_images = si.read_subject_images;	end;
    if isfield( si, 'mean_center_subjects' )	info.mean_center_subjects = si.mean_center_subjects;	end;
    if isfield( si, 'normalize_subjects' )      info.normalize_subjects = si.normalize_subjects;	end;
    if isfield( si, 'ZZ_process' )		info.ZZ_process = si.ZZ_process;			end;
    if isfield( si, 'apply_ga' )		info.apply_ga = si.apply_ga;				end;
    if isfield( si, 'apply_pd' )		info.apply_pd = si.apply_pd;				end;
    if isfield( si, 'apply_h' )			info.apply_h = si.apply_h;				end;
    if isfield( si, 'raw_data' )		info.raw_data = si.raw_data;				end;
    if isfield( si, 'mask' )   
      if isfield( si.mask, 'header' )		info.mask.header = si.mask.header;			end;
      if isfield( si.mask, 'image' )		info.mask.image = si.mask.image;			end;
      if isfield( si.mask, 'vol' )		info.mask.vol = si.mask.vol;				end;
      if isfield( si.mask, 'ind' ) 		info.mask.ind = si.mask.ind;				end;
      if isfield( si.mask, 'x' ) 		info.mask.x = si.mask.x;				end;
      if isfield( si.mask, 'y' ) 		info.mask.y = si.mask.y;				end;
      if isfield( si.mask, 'file' ) 		info.mask.file = si.mask.file;				end;
      if isfield( si.mask, 'niiSingle' ) 	info.mask.niiSingle = si.mask.niiSingle;		end;
      if isfield( si.mask, 'tal_index' ) 	info.mask.tal_index = si.mask.tal_index;		end;
      if isfield( si.mask, 'isRegistered' ) info.mask.isRegistered = si.mask.isRegistered;		end;
      if isfield( si.mask, 'MNI' ) 		info.mask.MNI = si.mask.MNI;				end;

    end;

    % --- retest mask registration flag if mask exists
    if ~isempty( info.mask.file )

      info.mask.isRegistered = ...
        numel(unique( info.mask.image(info.mask.ind) )') > 1 & ...
        numel(find(info.mask.image(info.mask.ind) == 1) ) > 0 & ...
        numel(find(info.mask.image(info.mask.ind) == 2) ) > 0 ;
    end
    

    if isfield( si, 'hm_regress_dir' )		info.hm_regress_dir = si.hm_regress_dir;		end;

    % ----------------------------------
    % the current model processing information
    % ----------------------------------

    if isfield( si, 'processing' )			% ensure all declarations exists

      if isfield( si.processing, 'subjects' )		% subject application settings

        if isfield( si.processing.subjects, 'apply' )	info.processing.subjects.apply = si.processing.subjects.apply;	end;
        if isfield( si.processing.subjects, 'normalized' ) 
          info.processing.subjects.normalized = si.processing.subjects.normalized;	
        end;
        if isfield( si.processing.subjects, 'rp_count' )	info.processing.subjects.rp_count = si.processing.subjects.rp_count;	end;
        if isfield( si.processing.subjects, 'rp_width' )	info.processing.subjects.rp_width = si.processing.subjects.rp_width;	end;
        if isfield( si.processing.subjects, 'run_count' )	info.processing.subjects.run_count = si.processing.subjects.run_count; end; % --- [3.03]
        if isfield( si.processing.subjects, 'tt_count' )	info.processing.subjects.tt_count = si.processing.subjects.tt_count;	end;% --- [3.41]

        if ( info.processing.subjects.run_count == 0 & ~isempty(info.SubjectDirs)  )
          info.processing.subjects.run_count = calc_run_count( zh.num_Z_arrays, zh.num_subjects, zh.num_runs );
        end

        if isfield( si.processing.subjects, 'process' )	

          if isfield( si.processing.subjects.process, 'create_Z' )	
             info.processing.subjects.process.create_Z = si.processing.subjects.process.create_Z;	end;

          if isfield( si.processing.subjects.process, 'mean_center' )	
             info.processing.subjects.process.mean_center = si.processing.subjects.process.mean_center;	end;

          if isfield( si.processing.subjects.process, 'standardize' )	
             info.processing.subjects.process.standardize = si.processing.subjects.process.standardize;	end;

          if isfield( si.processing.subjects.process, 'extract_clusters' )	
             info.processing.subjects.process.extract_clusters = si.processing.subjects.process.extract_clusters;	end;

          if isfield( si.processing.subjects.process, 'apply_regression' )	
             info.processing.subjects.process.apply_regression = si.processing.subjects.process.apply_regression;	end;

          if isfield( si.processing.subjects.process, 'movement_regress' )	
             info.processing.subjects.process.movement_regress = si.processing.subjects.process.movement_regress;	end;

          if isfield( si.processing.subjects.process, 'linear_regress' )	
             info.processing.subjects.process.linear_regress = si.processing.subjects.process.linear_regress;	end;

          if isfield( si.processing.subjects.process, 'quadratic_regress' )	
             info.processing.subjects.process.quadratic_regress = si.processing.subjects.process.quadratic_regress;	end;

          if isfield( si.processing.subjects.process, 'user_covariants' )	
             info.processing.subjects.process.user_covariants = si.processing.subjects.process.user_covariants;	end;

          if isfield( si.processing.subjects.process, 'user_covariants_file' )	
             info.processing.subjects.process.user_covariants_file = si.processing.subjects.process.user_covariants_file;	end;

          if isfield( si.processing.subjects.process, 'create_ZZ' )	
             info.processing.subjects.process.create_ZZ = si.processing.subjects.process.create_ZZ;	end;

 
          if isfield( si.processing.subjects.process, 'resume' )	
             info.processing.subjects.process.resume = si.processing.subjects.process.resume;	end;

          if isfield( si.processing.subjects.process, 'last_subject' )	
             info.processing.subjects.process.last_subject = si.processing.subjects.process.last_subject;	end;


        end;		% --- isfield( si.processing.subjects, 'process' ) ---


      end;		% --- isfield( si.processing, 'subjects' ) ---

      if isfield( si.processing, 'model' )		% our selected G model


        if isfield( si.processing.model, 'apply' )	
           info.processing.model.apply = si.processing.model.apply;	end;

        if isfield( si.processing.model, 'parameters' )	% the G header information

          if isfield( si.processing.model.parameters, 'model_type' )	
             info.processing.model.parameters.model_type = si.processing.model.parameters.model_type;	end;

          if isfield( si.processing.model.parameters, 'conditions' )	
             info.processing.model.parameters.conditions = si.processing.model.parameters.conditions;	end;

          if isfield( si.processing.model.parameters, 'bins' )	
             info.processing.model.parameters.bins = si.processing.model.parameters.bins;		end;

          if isfield( si.processing.model.parameters, 'TR' )	
             info.processing.model.parameters.TR = si.processing.model.parameters.TR;			end;

          if isfield( si.processing.model.parameters, 'inScans' )	
             info.processing.model.parameters.inScans = si.processing.model.parameters.inScans;		end;

          if isfield( si.processing.model.parameters, 'path_to_segs' )	
             info.processing.model.parameters.path_to_segs = si.processing.model.parameters.path_to_segs; end;

          if isfield( si.processing.model.parameters, 'prefix' )	
             info.processing.model.parameters.prefix = si.processing.model.parameters.prefix;		end;

          if isfield( si.processing.model.parameters, 'raw' )	
             info.processing.model.parameters.raw = si.processing.model.parameters.raw;			end;

          if isfield( si.processing.model.parameters, 'norm' )	
             info.processing.model.parameters.norm = si.processing.model.parameters.norm;		end;

          if isfield( si.processing.model.parameters, 'condition_name' )	
             info.processing.model.parameters.condition_name = si.processing.model.parameters.condition_name; end;

          if isfield( si.processing.model.parameters, 'plotting' )	
             info.processing.model.parameters.plotting = si.processing.model.parameters.plotting;	end;

        end;	% --- isfield( si.processing.model, 'parameters' ) ---


        if isfield( si.processing.model, 'process' )	

          if isfield( si.processing.model.process, 'group_index' )	
             info.processing.model.process.group_index = si.processing.model.process.group_index;	end;

          if isfield( si.processing.model.process, 'apply_g' )	
             info.processing.model.process.apply_g = si.processing.model.process.apply_g;		end;

          if isfield( si.processing.model.process, 'apply_ga' )	
             info.processing.model.process.apply_ga = si.processing.model.process.apply_ga;		end;

          if isfield( si.processing.model.process, 'apply_gaa' )	
             info.processing.model.process.apply_gaa = si.processing.model.process.apply_gaa;		end;

          if isfield( si.processing.model.process, 'extract_g' )	
             info.processing.model.process.extract_g = si.processing.model.process.extract_g;		end;

          if isfield( si.processing.model.process, 'subject_specific' )	
             info.processing.model.process.subject_specific = si.processing.model.process.subject_specific;	end;

          if isfield( si.processing.model.process, 'subject_specific_rotated' )	
             info.processing.model.process.subject_specific_rotated = si.processing.model.process.subject_specific_rotated;	end;

          if isfield( si.processing.model.process, 'rotate_g' )	
             info.processing.model.process.rotate_g = si.processing.model.process.rotate_g;		end;

          if isfield( si.processing.model.process, 'components' )	
             info.processing.model.process.components = si.processing.model.process.components;		end;

          if isfield( si.processing.model.process, 'component_name' )	
             info.processing.model.process.component_name = si.processing.model.process.component_name;	end;

        end;	% --- isfield( si.processing.model, 'process' ) ---

        if isfield( si.processing.model, 'applied' )	

          if isfield( si.processing.model.applied, 'apply_gaa' )	
             info.processing.model.applied.apply_gaa = si.processing.model.applied.apply_gaa;		end;

          if isfield( si.processing.model.applied, 'apply_g' )	
             info.processing.model.applied.apply_g = si.processing.model.applied.apply_g;		end;

          if isfield( si.processing.model.applied, 'apply_ga' )	
             info.processing.model.applied.apply_ga = si.processing.model.applied.apply_ga;		end;

          if isfield( si.processing.model.applied, 'apply_gaa' )	
             info.processing.model.applied.apply_gaa = si.processing.model.applied.apply_gaa;		end;

          if isfield( si.processing.model.applied, 'extract_g' )	
             info.processing.model.applied.extract_g = si.processing.model.applied.extract_g;		end;

          if isfield( si.processing.model.applied, 'rotate_g' )	
             info.processing.model.applied.rotate_g = si.processing.model.applied.rotate_g;		end;

          if isfield( si.processing.model.applied, 'extract_ga' )	
             info.processing.model.applied.extract_ga = si.processing.model.applied.extract_ga;		end;

          if isfield( si.processing.model.applied, 'resume_g' )	

            if isfield( si.processing.model.applied.resume_g, 'resume' )	
               info.processing.model.applied.resume_g.resume = si.processing.model.applied.resume_g.resume;	end;

            if isfield( si.processing.model.applied.resume_g, 'last_subject' )	
               info.processing.model.applied.resume_g.last_subject = si.processing.model.applied.resume_g.last_subject;	end;

%            if isfield( si.processing.model.applied.resume_g, 'B_calculated' )	
%               info.processing.model.applied.resume_g.B_calculated = si.processing.model.applied.resume_g.B_calculated;	end;

            if isfield( si.processing.model.applied.resume_g, 'BB_created' )	
               info.processing.model.applied.resume_g.CC = si.processing.model.applied.resume_g.BB_created;	
               info.processing.model.applied.resume_g.Eigs = si.processing.model.applied.resume_g.BB_created;	
            end;

          end;	% --- isfield( si.processing.model.applied, 'resume_g' ) ---

        end;	% --- isfield( si.processing.model, 'applied' ) ---



        rotation_struct = structure_define( 'ROTATIONS' );

        if isfield( si.processing.model, 'rotation' )	
          info.processing.model.rotation = [];

          for ( ii = 1:size(si.processing.model.rotation, 1 ) )

            info.processing.model.rotation = [info.processing.model.rotation; rotation_struct ];

            if isfield( si.processing.model.rotation(ii), 'method' )	
              info.processing.model.rotation(ii).method = si.processing.model.rotation(ii).method;		end;

            if isfield( si.processing.model.rotation(ii), 'description' )	
              info.processing.model.rotation(ii).description = si.processing.model.rotation(ii).description;	end;

            if isfield( si.processing.model.rotation(ii), 'defaults' )	

              if isfield( si.processing.model.rotation(ii).defaults, 'power' )	
                info.processing.model.rotation(ii).defaults.power = si.processing.model.rotation(ii).defaults.power;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'iterations' )	
                info.processing.model.rotation(ii).defaults.iterations = si.processing.model.rotation(ii).defaults.iterations;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'oblique' )	
                info.processing.model.rotation(ii).defaults.oblique = si.processing.model.rotation(ii).defaults.oblique;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'gamma' )	
                info.processing.model.rotation(ii).defaults.gamma = si.processing.model.rotation(ii).defaults.gamma;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'orthogonal_output' )	
                info.processing.model.rotation(ii).defaults.orthogonal_output = si.processing.model.rotation(ii).defaults.orthogonal_output;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'apply_to_ur' )	
                info.processing.model.rotation(ii).defaults.apply_to_ur = si.processing.model.rotation(ii).defaults.apply_to_ur;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'alternate_ur' )	
                info.processing.model.rotation(ii).defaults.alternate_ur = si.processing.model.rotation(ii).defaults.alternate_ur;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'subject_stats' )	
                info.processing.model.rotation(ii).defaults.subject_stats = si.processing.model.rotation(ii).defaults.subject_stats;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'normalize' )	
                info.processing.model.rotation(ii).defaults.normalize = si.processing.model.rotation(ii).defaults.normalize;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'calc_variance' )	
                info.processing.model.rotation(ii).defaults.calc_variance = si.processing.model.rotation(ii).defaults.calc_variance;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'T_mat' )	
                info.processing.model.rotation(ii).defaults.T_mat = si.processing.model.rotation(ii).defaults.T_mat;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'T_orient' )	
                info.processing.model.rotation(ii).defaults.T_orient = si.processing.model.rotation(ii).defaults.T_orient;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'ofn' )	
                info.processing.model.rotation(ii).defaults.text = si.processing.model.rotation(ii).defaults.ofn;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'text' )	
                info.processing.model.rotation(ii).defaults.text = si.processing.model.rotation(ii).defaults.text;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'hrf_file' )	
                info.processing.model.rotation(ii).defaults.hrf_file = si.processing.model.rotation(ii).defaults.hrf_file;	end;

              if isfield( si.processing.model.rotation(ii).defaults, 'hrf_mat' )	
                info.processing.model.rotation(ii).defaults.hrf_mat = si.processing.model.rotation(ii).defaults.hrf_mat;	end;

            end;	% --- isfield( si.processing.model.rotation(ii), 'defaults' ) ---

            if isfield( si.processing.model.rotation(ii), 'parameters' )	

              if isfield( si.processing.model.rotation(ii).parameters, 'power' )	
                info.processing.model.rotation(ii).parameters.power = si.processing.model.rotation(ii).parameters.power;	end;

              if isfield( si.processing.model.rotation(ii).parameters, 'iterations' )	
                info.processing.model.rotation(ii).parameters.iterations = si.processing.model.rotation(ii).parameters.iterations;	end;

              if isfield( si.processing.model.rotation(ii).parameters, 'oblique' )	
                info.processing.model.rotation(ii).parameters.oblique = si.processing.model.rotation(ii).parameters.oblique;	end;

              if isfield( si.processing.model.rotation(ii).parameters, 'gamma' )	
                info.processing.model.rotation(ii).parameters.gamma = si.processing.model.rotation(ii).parameters.gamma;	end;

              if isfield( si.processing.model.rotation(ii).parameters, 'orthogonal_output' )	
                info.processing.model.rotation(ii).parameters.orthogonal_output = si.processing.model.rotation(ii).parameters.orthogonal_output;	end;

              if isfield( si.processing.model.rotation(ii).parameters, 'apply_to_ur' )	
                info.processing.model.rotation(ii).parameters.apply_to_ur = si.processing.model.rotation(ii).parameters.apply_to_ur;	end;

             if isfield( si.processing.model.rotation(ii).parameters, 'alternate_ur' )	
                info.processing.model.rotation(ii).parameters.alternate_ur = si.processing.model.rotation(ii).parameters.alternate_ur;	end;

              if isfield( si.processing.model.rotation(ii).parameters, 'normalize' )	
                info.processing.model.rotation(ii).parameters.normalize = si.processing.model.rotation(ii).parameters.normalize;	end;

              if isfield( si.processing.model.rotation(ii).parameters, 'HRF' )	
                info.processing.model.rotation(ii).parameters.HRF = si.processing.model.rotation(ii).parameters.HRF;	end;

              if isfield( si.processing.model.rotation(ii).parameters, 'load_state' )	
                info.processing.model.rotation(ii).parameters.load_state = si.processing.model.rotation(ii).parameters.load_state;	end;

            end;	% --- isfield( si.processing.model.rotation(ii), 'parameters' ) ---

          end;	% --- each defined rotation ---

        end;	% --- isfield( si.processing.model, 'rotation' ) ---

      end;	% --- isfield( si.processing, 'model' ) ---

      if isfield( si.processing, 'H_model' )		% our selected H model

       if isfield( si.processing.H_model, 'apply' )	
         info.processing.H_model.apply = si.processing.H_model.apply;				end;

       if isfield( si.processing.H_model, 'extract' )	
         info.processing.H_model.apply = si.processing.H_model.apply;				end;

       if isfield( si.processing.H_model, 'rotate' )	
         info.processing.H_model.apply = si.processing.H_model.apply;				end;

       if isfield( si.processing.H_model, 'path_to_segs' )	
         info.processing.H_model.path_to_segs = si.processing.H_model.path_to_segs;		end;

       if isfield( si.processing.H_model, 'process' )	


          if isfield( si.processing.H_model.process, 'hz' )	
             info.processing.H_model.process.hz = si.processing.H_model.process.hz;				end;   % [3.1.0]

          if isfield( si.processing.H_model.process, 'he' )	
             info.processing.H_model.process.he = si.processing.H_model.process.he;				end;   % [3.1.0]

          if isfield( si.processing.H_model.process, 'components' )	
             info.processing.H_model.process.components = si.processing.H_model.process.components;		end;

          if isfield( si.processing.H_model.process, 'component_name' )	
             info.processing.H_model.process.component_name = si.processing.H_model.process.component_name;	end;

        end;	% --- isfield( si.processing.H_model, 'process' ) ---

        if isfield( si.processing.H_model, 'applied' )	

          if isfield( si.processing.H_model.applied, 'apply_hz' )	
             info.processing.H_model.applied.apply_hz = si.processing.H_model.applied.apply_hz;			end;   % [3.1.0]

          if isfield( si.processing.H_model.applied, 'apply_he' )	
             info.processing.H_model.applied.apply_he = si.processing.H_model.applied.apply_he;			end;   % [3.1.0]

          if isfield( si.processing.H_model.applied, 'extract_hz' )	
             info.processing.H_model.applied.extract_hz = si.processing.H_model.applied.extract_hz;			end;   % [3.1.0]

          if isfield( si.processing.H_model.applied, 'extract_he' )	
             info.processing.H_model.applied.extract_he = si.processing.H_model.applied.extract_he;			end;   % [3.1.0]

          if isfield( si.processing.H_model.applied, 'rotate_hz' )	
             info.processing.H_model.applied.rotate_hz = si.processing.H_model.applied.rotate_hz;			end;   % [3.1.0]

          if isfield( si.processing.H_model.applied, 'rotate_he' )	
             info.processing.H_model.applied.rotate_he = si.processing.H_model.applied.rotate_he;			end;   % [3.1.0]

          if isfield( si.processing.H_model.applied, 'resume_h' )	

            if isfield( si.processing.H_model.applied.resume_h, 'resume' )	
               info.processing.H_model.applied.resume_h.resume = si.processing.H_model.applied.resume_h.resume;			end;

            if isfield( si.processing.H_model.applied.resume_h, 'last_subject' )	
               info.processing.H_model.applied.resume_h.last_subject = si.processing.H_model.applied.resume_h.last_subject;	end;

            if isfield( si.processing.H_model.applied.resume_h, 'B_calculated' )	
               info.processing.H_model.applied.resume_h.B_calculated = si.processing.H_model.applied.resume_h.B_calculated;	end;

            if isfield( si.processing.H_model.applied.resume_h, 'BB_created' )	
               info.processing.H_model.applied.resume_h.BB_created = si.processing.H_model.applied.resume_h.BB_created;		end;

          end;	% --- isfield( si.processing.H_model.applied, 'resume_h' ) ---

        end;	% --- isfield( si.processing.H_model, 'applied' ) ---

        rotation_struct = structure_define( 'ROTATIONS' );

        if isfield( si.processing.H_model, 'rotation' )	
          info.processing.H_model.rotation = [];

          for ( ii = 1:size(si.processing.H_model.rotation, 1 ) )

            info.processing.H_model.rotation = [info.processing.H_model.rotation; rotation_struct ];

            if isfield( si.processing.H_model.rotation(ii), 'method' )	
              info.processing.H_model.rotation(ii).method = si.processing.H_model.rotation(ii).method;		end;

            if isfield( si.processing.H_model.rotation(ii), 'description' )	
              info.processing.H_model.rotation(ii).description = si.processing.H_model.rotation(ii).description;	end;

            if isfield( si.processing.H_model.rotation(ii), 'defaults' )	


              if isfield( si.processing.H_model.rotation(ii).defaults, 'power' )	
                info.processing.H_model.rotation(ii).defaults.power = si.processing.H_model.rotation(ii).defaults.power;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'iterations' )	
                info.processing.H_model.rotation(ii).defaults.iterations = si.processing.H_model.rotation(ii).defaults.iterations;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'oblique' )	
                info.processing.H_model.rotation(ii).defaults.oblique = si.processing.H_model.rotation(ii).defaults.oblique;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'gamma' )	
                info.processing.H_model.rotation(ii).defaults.gamma = si.processing.H_model.rotation(ii).defaults.gamma;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'orthogonal_output' )	
                info.processing.H_model.rotation(ii).defaults.orthogonal_output = si.processing.H_model.rotation(ii).defaults.orthogonal_output;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'apply_to_ur' )	
                info.processing.H_model.rotation(ii).defaults.apply_to_ur = si.processing.H_model.rotation(ii).defaults.apply_to_ur;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'alternate_ur' )	
                info.processing.H_model.rotation(ii).defaults.alternate_ur = si.processing.H_model.rotation(ii).defaults.alternate_ur;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'subject_stats' )	
                info.processing.H_model.rotation(ii).defaults.subject_stats = si.processing.H_model.rotation(ii).defaults.subject_stats;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'normalize' )	
                info.processing.H_model.rotation(ii).defaults.normalize = si.processing.H_model.rotation(ii).defaults.normalize;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'calc_variance' )	
                info.processing.H_model.rotation(ii).defaults.calc_variance = si.processing.H_model.rotation(ii).defaults.calc_variance;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'T_mat' )	
                info.processing.H_model.rotation(ii).defaults.T_mat = si.processing.H_model.rotation(ii).defaults.T_mat;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'ofn' )	
                info.processing.H_model.rotation(ii).defaults.ofn = si.processing.H_model.rotation(ii).defaults.ofn;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'hrf_file' )	
                info.processing.H_model.rotation(ii).defaults.hrf_file = si.processing.H_model.rotation(ii).defaults.hrf_file;	end;

              if isfield( si.processing.H_model.rotation(ii).defaults, 'hrf_mat' )	
                info.processing.H_model.rotation(ii).defaults.hrf_mat = si.processing.H_model.rotation(ii).defaults.hrf_mat;	end;

            end;	% --- isfield( si.processing.H_model.rotation(ii), 'defaults' ) ---

            if isfield( si.processing.H_model.rotation(ii), 'parameters' )	

              if isfield( si.processing.H_model.rotation(ii).parameters, 'power' )	
                info.processing.H_model.rotation(ii).parameters.power = si.processing.H_model.rotation(ii).parameters.power;	end;

              if isfield( si.processing.H_model.rotation(ii).parameters, 'iterations' )	
                info.processing.H_model.rotation(ii).parameters.iterations = si.processing.H_model.rotation(ii).parameters.iterations;	end;

              if isfield( si.processing.H_model.rotation(ii).parameters, 'oblique' )	
                info.processing.H_model.rotation(ii).parameters.oblique = si.processing.H_model.rotation(ii).parameters.oblique;	end;

              if isfield( si.processing.H_model.rotation(ii).parameters, 'gamma' )	
                info.processing.H_model.rotation(ii).parameters.gamma = si.processing.H_model.rotation(ii).parameters.gamma;	end;

              if isfield( si.processing.H_model.rotation(ii).parameters, 'orthogonal_output' )	
                info.processing.H_model.rotation(ii).parameters.orthogonal_output = si.processing.H_model.rotation(ii).parameters.orthogonal_output;	end;

              if isfield( si.processing.H_model.rotation(ii).parameters, 'apply_to_ur' )	
                info.processing.H_model.rotation(ii).parameters.apply_to_ur = si.processing.H_model.rotation(ii).parameters.apply_to_ur;	end;

             if isfield( si.processing.H_model.rotation(ii).parameters, 'alternate_ur' )	
                info.processing.H_model.rotation(ii).parameters.alternate_ur = si.processing.H_model.rotation(ii).parameters.alternate_ur;	end;

              if isfield( si.processing.H_model.rotation(ii).parameters, 'normalize' )	
                info.processing.H_model.rotation(ii).parameters.normalize = si.processing.H_model.rotation(ii).parameters.normalize;	end;

              if isfield( si.processing.H_model.rotation(ii).parameters, 'HRF' )	
                info.processing.H_model.rotation(ii).parameters.HRF = si.processing.H_model.rotation(ii).parameters.HRF;	end;

            end;	% --- isfield( si.processing.H_model.rotation(ii), 'parameters' ) ---

          end;	% --- each defined rotation ---

        end;	% --- isfield( si.processing.H_model, 'rotation' ) ---

      end;	% --- isfield( si.processing, 'H_model' ) ---


      if isfield( si.processing, 'GMH_model' )	

        if isfield( si.processing.GMH_model, 'apply' )	
          info.processing.GMH_model.apply = si.processing.GMH_model.apply;			end;

        if isfield( si.processing.GMH_model, 'extract' )	
          info.processing.GMH_model.extract = si.processing.GMH_model.extract;			end;

        if isfield( si.processing.GMH_model, 'subject_specific' )	
          info.processing.GMH_model.subject_specific = si.processing.GMH_model.subject_specific;			end;

        if isfield( si.processing.GMH_model, 'subject_specific_rotated' )	
          info.processing.GMH_model.subject_specific_rotated = si.processing.GMH_model.subject_specific_rotated;			end;

        if isfield( si.processing.GMH_model, 'rotate' )	
          info.processing.GMH_model.rotate = si.processing.GMH_model.rotate;			end;

        if isfield( si.processing.GMH_model, 'path_to_segs' )	
          info.processing.GMH_model.path_to_segs = si.processing.GMH_model.path_to_segs;	end;

        if isfield( si.processing.GMH_model, 'options' )

          if ~isfield( si.processing.GMH_model.options, 'output' ) 
            info.processing.GMH_model.options = si.processing.GMH_model.options;	
          end;  % [ 3.3.2 ]

          if isfield( si.processing.GMH_model.options, 'GMH' )   
              if ~isfield( si.processing.GMH_model.options.GMH, 'apply' )
                  info.processing.GMH_model.options.GMH.apply = 0;
              end;  % Wayne
          end
          if isfield( si.processing.GMH_model.options, 'GC' )   
              if ~isfield( si.processing.GMH_model.options.GC, 'apply' )
                  info.processing.GMH_model.options.GC.apply = 0;
              end;  % Wayne
          end
          if isfield( si.processing.GMH_model.options, 'BH' )   
              if ~isfield( si.processing.GMH_model.options.BH, 'apply' )
                  info.processing.GMH_model.options.BH.apply = 0;
              end;  % Wayne
          end

        end;  % [ 3.3.1 ]

        if isfield( si.processing.GMH_model, 'applied' )	

          if isfield( si.processing.GMH_model.applied, 'started' )	
            info.processing.GMH_model.applied.started = si.processing.GMH_model.applied.started;		end;

          if isfield( si.processing.GMH_model.applied, 'completed' )	
            info.processing.GMH_model.applied.completed = si.processing.GMH_model.applied.completed;		end;

          if isfield( si.processing.GMH_model.applied, 'resume' )	
            info.processing.GMH_model.applied.resume = si.processing.GMH_model.applied.resume;			end;

          if isfield( si.processing.GMH_model.applied, 'var_prep' )	
            info.processing.GMH_model.applied.var_prep = si.processing.GMH_model.applied.var_prep;		end;

          if isfield( si.processing.GMH_model.applied, 'regression' )	
            info.processing.GMH_model.applied.regression = si.processing.GMH_model.applied.regression;		end;

          if isfield( si.processing.GMH_model.applied, 'gmh' )	
            info.processing.GMH_model.applied.gmh = si.processing.GMH_model.applied.gmh;			end;

          if isfield( si.processing.GMH_model.applied, 'extract' )	
            info.processing.GMH_model.applied.extract = si.processing.GMH_model.applied.extract;		end;

          if isfield( si.processing.GMH_model.applied, 'rotate' )	
            info.processing.GMH_model.applied.rotate = si.processing.GMH_model.applied.rotate;			end;


        end;  % --- isfield( si.processing.GMH_model, 'applied' ) ---


        if isfield( si.processing.GMH_model, 'rotation' )	
          info.processing.GMH_model.rotation = [];

          for ( ii = 1:size(si.processing.GMH_model.rotation, 1 ) )

            info.processing.GMH_model.rotation = [info.processing.GMH_model.rotation; rotation_struct ];

            if isfield( si.processing.GMH_model.rotation(ii), 'method' )	
              info.processing.GMH_model.rotation(ii).method = si.processing.GMH_model.rotation(ii).method;		end;

            if isfield( si.processing.GMH_model.rotation(ii), 'description' )	
              info.processing.GMH_model.rotation(ii).description = si.processing.GMH_model.rotation(ii).description;	end;

            if isfield( si.processing.GMH_model.rotation(ii), 'defaults' )	


              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'power' )	
                info.processing.GMH_model.rotation(ii).defaults.power = si.processing.GMH_model.rotation(ii).defaults.power;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'iterations' )	
                info.processing.GMH_model.rotation(ii).defaults.iterations = si.processing.GMH_model.rotation(ii).defaults.iterations;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'oblique' )	
                info.processing.GMH_model.rotation(ii).defaults.oblique = si.processing.GMH_model.rotation(ii).defaults.oblique;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'gamma' )	
                info.processing.GMH_model.rotation(ii).defaults.gamma = si.processing.GMH_model.rotation(ii).defaults.gamma;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'orthogonal_output' )	
                info.processing.GMH_model.rotation(ii).defaults.orthogonal_output = si.processing.GMH_model.rotation(ii).defaults.orthogonal_output;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'apply_to_ur' )	
                info.processing.GMH_model.rotation(ii).defaults.apply_to_ur = si.processing.GMH_model.rotation(ii).defaults.apply_to_ur;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'alternate_ur' )	
                info.processing.GMH_model.rotation(ii).defaults.alternate_ur = si.processing.GMH_model.rotation(ii).defaults.alternate_ur;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'subject_stats' )	
                info.processing.GMH_model.rotation(ii).defaults.subject_stats = si.processing.GMH_model.rotation(ii).defaults.subject_stats;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'normalize' )	
                info.processing.GMH_model.rotation(ii).defaults.normalize = si.processing.GMH_model.rotation(ii).defaults.normalize;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'calc_variance' )	
                info.processing.GMH_model.rotation(ii).defaults.calc_variance = si.processing.GMH_model.rotation(ii).defaults.calc_variance;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'T_mat' )	
                info.processing.GMH_model.rotation(ii).defaults.T_mat = si.processing.GMH_model.rotation(ii).defaults.T_mat;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'ofn' )	
                info.processing.GMH_model.rotation(ii).defaults.ofn = si.processing.GMH_model.rotation(ii).defaults.ofn;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'hrf_file' )	
                info.processing.GMH_model.rotation(ii).defaults.hrf_file = si.processing.GMH_model.rotation(ii).defaults.hrf_file;	end;

              if isfield( si.processing.GMH_model.rotation(ii).defaults, 'hrf_mat' )	
                info.processing.GMH_model.rotation(ii).defaults.hrf_mat = si.processing.GMH_model.rotation(ii).defaults.hrf_mat;	end;

            end;	% --- isfield( si.processing.GMH_model.rotation(ii), 'defaults' ) ---

            if isfield( si.processing.GMH_model.rotation(ii), 'parameters' )	

              if isfield( si.processing.GMH_model.rotation(ii).parameters, 'power' )	
                info.processing.GMH_model.rotation(ii).parameters.power = si.processing.GMH_model.rotation(ii).parameters.power;	end;

              if isfield( si.processing.GMH_model.rotation(ii).parameters, 'iterations' )	
                info.processing.GMH_model.rotation(ii).parameters.iterations = si.processing.GMH_model.rotation(ii).parameters.iterations;	end;

              if isfield( si.processing.GMH_model.rotation(ii).parameters, 'oblique' )	
                info.processing.GMH_model.rotation(ii).parameters.oblique = si.processing.GMH_model.rotation(ii).parameters.oblique;	end;

              if isfield( si.processing.GMH_model.rotation(ii).parameters, 'gamma' )	
                info.processing.GMH_model.rotation(ii).parameters.gamma = si.processing.GMH_model.rotation(ii).parameters.gamma;	end;

              if isfield( si.processing.GMH_model.rotation(ii).parameters, 'orthogonal_output' )	
                info.processing.GMH_model.rotation(ii).parameters.orthogonal_output = si.processing.GMH_model.rotation(ii).parameters.orthogonal_output;	end;

              if isfield( si.processing.GMH_model.rotation(ii).parameters, 'apply_to_ur' )	
                info.processing.GMH_model.rotation(ii).parameters.apply_to_ur = si.processing.GMH_model.rotation(ii).parameters.apply_to_ur;	end;

             if isfield( si.processing.GMH_model.rotation(ii).parameters, 'alternate_ur' )	
                info.processing.GMH_model.rotation(ii).parameters.alternate_ur = si.processing.GMH_model.rotation(ii).parameters.alternate_ur;	end;

              if isfield( si.processing.GMH_model.rotation(ii).parameters, 'normalize' )	
                info.processing.GMH_model.rotation(ii).parameters.normalize = si.processing.GMH_model.rotation(ii).parameters.normalize;	end;

              if isfield( si.processing.GMH_model.rotation(ii).parameters, 'HRF' )	
                info.processing.GMH_model.rotation(ii).parameters.HRF = si.processing.GMH_model.rotation(ii).parameters.HRF;	end;

            end;	% --- isfield( si.processing.GMH_model.rotation(ii), 'parameters' ) ---

          end;	% --- each defined rotation ---

        end;	% --- isfield( si.processing.GMH_model, 'rotation' ) ---

      end;	% --- isfield( si.processing, 'GMH_model' ) ---

    end;	% --- isfield( si, 'processing' ) ---

  % ------------------------------------------
  % --- adjust DirChar in case data run on other system
  % ------------------------------------------

  if ispc
    si.DirChar = '\';
    this_from = '/';
    this_to = '\';
  else
    si.DirChar = '/';
    this_to = '/';
    this_from = '\';
  end;

  hdr.Z_File.directory = strrep( hdr.Z_File.directory, this_from, this_to);	
  hdr.Z_Directory      = strrep( hdr.Z_Directory, this_from, this_to);
  hdr.Z_Original       = strrep( hdr.Z_Original, this_from, this_to);
  hdr.Model.path       = strrep( hdr.Model.path, this_from, this_to);
  hdr.P.path           = strrep( hdr.P.path, this_from, this_to);
  hdr.D.path           = strrep( hdr.D.path, this_from, this_to);
  hdr.Contrast.path    = strrep( hdr.Contrast.path, this_from, this_to);
  hdr.Limits.path      = strrep( hdr.Limits.path, this_from, this_to);

