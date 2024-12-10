function output_H_HRF( out_dir, out_file, HRFvar, apnd )

  if nargin < 4  apnd = 0; end;

  file_mode = 'w';
  alt_text = '';

  if apnd file_mode = 'a'; alt_text = 'Alternate '; end;

  %----------------------------------------
  % output HRFvar set to intial 0 per component
  %----------------------------------------

  nconds = size(HRFvar,1);
  nbins = 1;

  for comp = 1:size(HRFvar,2)

    hrf_subj = [];
    start_row = 1;

      hrf_cond = [];
      for cond = 1:nconds 

        end_row = start_row + nbins - 1;
        tmp = HRFvar(start_row:end_row,comp);

        hrf_cond = [hrf_cond tmp];

        start_row = end_row + 1;

      end;	% --- each condition ---

      hrf_subj = [hrf_subj; hrf_cond'];


    this_file = strrep( out_file, '999', num2str(comp) );

    fid = 0;
    eval( [ 'fid = fopen( ''' out_dir this_file ''', ''' file_mode ''' );' ] );
    if ( fid )

      if ~apnd
        text_file_header( size(HRFvar,2), fid, 0, out_dir );
      end;

      fprintf( fid, '\n\n' );

      fprintf( fid, '\n%sHRF\n------------------------------------------\n', alt_text );

      for ii=1:size(hrf_subj,1) 

        z=[]; 
        for jj = 1:size(hrf_subj,2) 
          y = sprintf( '\t%.4f', hrf_subj(ii,jj) ); 
          z = [z y];
        end; 
        fprintf( fid, '%s\n', z );

      end;
    end;
  
    fclose( fid );

  end;		% --- each component ---


