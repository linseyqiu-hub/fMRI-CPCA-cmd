function text_file_header( nd, fid, log_fid, base_path, filename, withA, nvox, thr)
% --- pass Aheader.Aindex value as index to use
global Zheader scan_information 

  if nargin < 5,        filename = '';  end;
  if nargin < 6,        withA = 0;      end;
  if nargin < 7,        nvox = Zheader.total_columns;      end;
  if nargin < 8,        thr = 0;    end;
  if ~isnumeric( withA),    withA = 0;      end;
  measurement = [{'seconds'} {'scans'}];

  base_directory = pwd; % passed parm for secondary files


  cpca_ver = cpca_revision_number( Zheader.cpca_version );
  edit_ver = cpca_revision_number( Zheader.edit_version );
  
  if ~isempty( filename )
    if log_fid print_and_log( log_fid, 'filename: %s\n', filename ); end;
    if ( fid )  fprintf( fid, 'filename: %s\n', filename ); end;
  end;

  if log_fid print_and_log( log_fid, 'original location: %s\n', base_path ); end;
  if ( fid )  fprintf( fid, 'original location: %s\n', base_path ); end;


  if log_fid print_and_log( log_fid, 'date created: %s\n', date ); end;
  if ( fid )  fprintf( fid, 'date created: %s\n', date ); end;
  if log_fid print_and_log( log_fid, 'created version: %s\n', cpca_ver ); end;
  if ( fid )  fprintf( fid, 'created version: %s\n', cpca_ver ); end;
  if log_fid print_and_log( log_fid, ' edited version: %s\n', edit_ver ); end;
  if ( fid )  fprintf( fid, 'edited version: %s\n', edit_ver ); end;
  if (thr > 0)
    if log_fid print_and_log( log_fid, ' displaying top %d%%\n', global_threshold_value(thr) ); end;
    if ( fid )  fprintf( fid, 'displaying top %d%%\n', global_threshold_value( thr )); end;
  end
  if log_fid print_and_log( log_fid, '\n------------------------------------------\n' ); end;
  if ( fid )  fprintf( fid, '\n------------------------------------------\n' ); end;

  if log_fid print_and_log( log_fid, 'General Information\n------------------------------------------\n' ); end;
  if ( fid )  fprintf( fid, 'General Information\n------------------------------------------\n' ); end;

  if log_fid print_and_log( log_fid, '  Subjects: \t %d\n', Zheader.num_subjects ); end;
  if ( fid )  fprintf( fid, '  Subjects: \t %d\n', Zheader.num_subjects ); end;
  if log_fid print_and_log( log_fid, '  Runs: \t %d\n', Zheader.num_runs ); end;
  if ( fid )  fprintf( fid, '  Runs: \t %d\n', Zheader.num_runs ); end;
  if log_fid print_and_log( log_fid, '  Total Scans: \t %d\n', Zheader.total_scans ); end;
  if ( fid )  fprintf( fid, '  Total Scans: \t %d\n', Zheader.total_scans ); end;
  if log_fid print_and_log( log_fid, '  Voxel Width: \t %d\n', nvox ); end;
  if ( fid )  fprintf( fid, '  Voxel Width: \t %d\n', nvox ); end;

  dim = scan_information.mask.header.pixdim(2:4);
  if log_fid print_and_log( log_fid, '  Pix Dim: \t %d x %d x %d\n', dim(1), dim(2), dim(3) ); end;
  if ( fid )  fprintf( fid, '  Pix Dim: \t %d x %d x %d\n', dim(1), dim(2), dim(3) ); end;
  
  if ( scan_information.isMulFreq )
    freqs = '';
    for ii = 1:scan_information.frequencies
      if length(freqs) > 0   freqs = [freqs ', ']; end;
      freqs = [freqs char(scan_information.freq_names(ii))];
    end;
    if log_fid print_and_log( log_fid, '  Frequencies: \t %s\n', freqs ); end;
    if ( fid )  fprintf( fid, '  Frequencies: \t %s\n', freqs ); end;
  end;

  
  if ~isempty( scan_information.GroupList )

    if log_fid print_and_log( log_fid, '  Groups \n' ); end;
    if ( fid )  fprintf( fid, '  Groups \n' ); end;
      
    for ii = 1:size( scan_information.GroupList, 1 )
      txt = [scan_information.GroupList(ii).name ':'];
      if log_fid print_and_log( log_fid, '%14s\t %d\n', txt, scan_information.GroupList(ii).subjectcount ); end;
      if ( fid )  fprintf( fid, '%14s\t %d\n', txt, scan_information.GroupList(ii).subjectcount ); end;
    end;

  end
  
  model_type = [{'FIR'} {'HRF'}];
  if log_fid print_and_log( log_fid, '\n  Model Type: \t %s\n', char(model_type( scan_information.processing.model.parameters.model_type + 1 ) ) ); end;
  if ( fid )  fprintf( fid, '\n  Model Type: \t %s\n', char(model_type( scan_information.processing.model.parameters.model_type + 1 ) ) ); end;
  if log_fid print_and_log( log_fid, '  Onsets measured in %s\n', ...
    char( measurement( scan_information.processing.model.parameters.inScans + 1) ) ); end;
  if ( fid )  fprintf( fid, '  Onsets measured in %s\n', ...
    char( measurement( scan_information.processing.model.parameters.inScans + 1) ) ); end;

  if log_fid print_and_log( log_fid, '  Conditions: \t %d\n', scan_information.processing.model.parameters.conditions ); end;
  if ( fid )  fprintf( fid, '  Conditions: \t %d\n', scan_information.processing.model.parameters.conditions ); end;
  if log_fid print_and_log( log_fid, '  Bins: \t %d\n', scan_information.processing.model.parameters.bins ); end;
  if ( fid )  fprintf( fid, '  Bins: \t %d\n', scan_information.processing.model.parameters.bins ); end;
  strsz = sprintf( '%d x %d', Zheader.Model.mat_x, Zheader.Model.mat_y );
  if log_fid print_and_log( log_fid, '  Size:   \t %s\n', strsz ); end;
  if ( fid )  fprintf( fid, '  Size: \t %s\n', strsz ); end;
  if log_fid print_and_log( log_fid, '  TR:   \t %.2f\n', scan_information.processing.model.parameters.TR ); end;
  if ( fid )  fprintf( fid, '  TR:   \t %.2f\n', scan_information.processing.model.parameters.TR ); end;

  if withA
    load( Zheader.Contrast.path );
    if ~(withA > size( Aheader.model, 1 ))
      if log_fid print_and_log( log_fid, '\n    A Matrix: \t %s\n', Aheader.model(withA).id ); end;
      if ( fid )  fprintf( fid, '\n    A Matrix: \t %s\n', Aheader.model(withA).id ); end;

      if log_fid print_and_log( log_fid, '            : \t %s\n',   Aheader.model(withA).descr ); end;
      if ( fid )  fprintf( fid, '            : \t %s\n',   Aheader.model(withA).descr ); end;

      if log_fid print_and_log( log_fid, '   contrasts: \t %d\n',   Aheader.model(withA).contrasts ); end;
      if ( fid )  fprintf( fid, '   contrasts: \t %d\n',   Aheader.model(withA).contrasts ); end;

      if log_fid print_and_log( log_fid, '        bins: \t %d\n',   Aheader.model(withA).bins ); end;
      if ( fid )  fprintf( fid, '        bins: \t %d\n',   Aheader.model(withA).bins ); end;
    end
    
  end;
  
  nr = Zheader.total_scans;
  nremoved = Zheader.tsum_linear_trends + Zheader.tsum_quadratic_trends + Zheader.tsum_hm_trends + Zheader.tsum_user_trends;
  nremoved = [nremoved Zheader.tsum_linear_trends];
  nremoved = [nremoved Zheader.tsum_quadratic_trends];
  nremoved = [nremoved Zheader.tsum_hm_trends];		% --- head movement values
  nremoved = [nremoved Zheader.tsum_user_trends];	% --- user defined values
  premoved = [sum(Zheader.rfac) Zheader.rfac];

  dsp_txt = [ {'  Total Removed'} {'   Linear Trend'} {'Quadratic Trend'} {'  Head Movement'} {'   User Defined'} ];

  if log_fid print_and_log( log_fid, '\n------------------------------------------\n' ); end;
  if ( fid )  fprintf( fid, '\n------------------------------------------\n' ); end;
  if log_fid print_and_log( log_fid, '%% of variance in original BOLD signal regressed out in CPCA preprocessing\n' ); end;
  if ( fid )  fprintf( fid,  '%% of variance in original BOLD signal regressed out in CPCA preprocessing\n' ); end;
  if log_fid print_and_log( log_fid, '------------------------------------------\n' ); end;
  if ( fid )  fprintf( fid, '------------------------------------------\n' ); end;

  for ii = 1:5

    pval = sprintf( num2str( constant_define( 'PREFERENCES', 'precision.log') ) , premoved(ii) );
    rval = sprintf( '%14.2f', nremoved(ii) );

    if log_fid print_and_log( log_fid,    '       %s: \t %6s%% (%14s)\n', char(dsp_txt(ii)), pval, rval ); end;
    if (fid )        fprintf(     fid,    '       %s: \t %6s%% (%14s)\n', char(dsp_txt(ii)), pval, rval ); end;

  end

%   if ~isempty( scan_information.GroupList )
% 
%   if log_fid print_and_log( log_fid, '\n------------------------------------------\n' ); end;
%   if ( fid )  fprintf( fid, '\n------------------------------------------\n' ); end;
%     if log_fid print_and_log( log_fid, 'Group Information\n------------------------------------------\n' ); end;
%     if ( fid )  fprintf( fid, 'Group Information\n------------------------------------------\n' ); end;
%       
%     for ii = 1:size( scan_information.GroupList, 1 )
%       txt = [scan_information.GroupList(ii).name ':'];
% %      fprintf( '%12s %d\n', txt, scan_information.GroupList(ii).subjectcount );
%       if log_fid print_and_log( log_fid, '%12s %d\n', txt, scan_information.GroupList(ii).subjectcount ); end;
%       if ( fid )  fprintf( fid, '%12s %d\n', txt, scan_information.GroupList(ii).subjectcount ); end;
%     end;
% 
%     if log_fid print_and_log( log_fid, '------------------------------------------\n' ); end;
%     if ( fid )  fprintf( fid, '------------------------------------------\n' ); end;
%     
%   end
