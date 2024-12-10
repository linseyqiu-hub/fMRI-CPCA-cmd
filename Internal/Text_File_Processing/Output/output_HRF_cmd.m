function output_HRF_cmd(Zheader, scan_information, out_dir, out_file, HRFvar, Gheader, apnd, nvox )

  if nargin < 7,  apnd = 0; end
  if nargin < 8,  nvox = Zheader.total_columns; end

  if isempty( HRFvar ), return; end
  if isempty( Gheader ),  output_H_HRF(out_dir, out_file, HRFvar, apnd);  return; end

  file_mode = 'w';
%   alt_text = '';
%   if apnd file_mode = 'a'; alt_text = 'Alternate '; end;


  %----------------------------------------
  % output HRFvar set to intial 0 per component
  %----------------------------------------

  nconds = scan_information.processing.model.parameters.conditions;
  nbins = scan_information.processing.model.parameters.bins;

  condition_ne = [];
  for ii = 1:nbins
    condition_ne = [condition_ne constant_define( 'NON_ENCODED_COND_FLAG' ) ];
  end
  
  for comp = 1:size(HRFvar,2)

    hrf_subj = [];
    for subj = 1:Zheader.num_subjects

      hrf_cond = subj;
      for cond = 1:nconds 

        [encoded, sr, er] = PR_condition_position_cmd(Zheader, scan_information,  subj, cond, Gheader );
        if encoded
          hrf_cond = [hrf_cond HRFvar(sr:er,comp)'];
        else
          hrf_cond = [hrf_cond condition_ne ];
        end
        
      end	% --- each condition ---

      hrf_subj = [hrf_subj; hrf_cond];

    end	% --- each subject ---


    this_file = strrep( out_file, '999', num2str(comp) );

    lbl = [];
    for ii = 1:size( Zheader.conditions.Names, 2 )
      txt = center_text( char(Zheader.conditions.Names(ii)), Gheader.bins * 7 + Gheader.bins );
      lbl = [lbl txt];
    end

    vals = rand( Gheader.bins, 1 );
    [ ~, ~, c, d] = format_float_output( vals, 2, 4 );
    hdr = [];
    sep = [];
    for ii = 1:Gheader.conditions
      hdr = [hdr c];
      sep = [sep d];
    end
    
    fid = 0;
    eval( [ 'fid = fopen( ''' out_dir this_file ''', ''' file_mode ''' );' ] );
    if ( fid )

      if ~apnd
        fprintf('\n\n' );
        text_file_header_cmd(Zheader, scan_information, size(HRFvar,2), fid, 0, out_dir, this_file, 0, nvox );
      end

      fprintf( fid, '\n\n' );
      for grp = 1:size( scan_information.GroupList, 1 )
        fprintf( fid,  '%s = %d\n', char(scan_information.GroupList(grp).name), grp ); 
      end
%      fprintf( fid, '\n%sHRF\n------------------------------------------\n', alt_text );
%      fprintf( fid, '\n%sHRF\n', alt_text );

      % --- 7 char (+1 pad) for subject label, 2 char for group index, 1 char pad )
      fprintf( fid, '           %s\n', lbl );
      fprintf( fid, 'id     grp %s\n', hdr );
      fprintf( fid, '-----------%s\n', sep );
      
      for ii=1:size(hrf_subj,1) 
        sid = subject_id_cmd( ii,scan_information );
        fprintf( fid,  '%-7s ', sid ); 
        grp_idx = ' ';

        idx_start = 1;
        if ( size( scan_information.GroupList, 1 ) > 1 )
          for grp = 1:size( scan_information.GroupList, 1 )
            x = any( str2num( scan_information.GroupList(grp).subjectlist ) == hrf_subj(ii,1) );
            if x > 0 grp_idx = num2str(grp); end
          end
          idx_start = 2;
        end

        fprintf( fid,  '%-2s ', grp_idx ); 
        a = format_float_output( hrf_subj(ii,2:end), 2, 5);
        a = strrep( a, '-99999.99', ' ----- ' );
        fprintf( fid, '%s\n', a );
        

      end
    end
  
    fclose( fid );

  end		% --- each component ---


