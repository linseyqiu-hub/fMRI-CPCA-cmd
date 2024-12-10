function create_ROIGC_as_Images( handles)
global Zheader scan_information process_information

  load G_ROI
  if ~exist( 'G_ROI', 'var' )
    return
  end
  
  ROIGC = [ 'GZsegs' filesep 'ROI' filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep ];
  x = matfile_vars( ROIGC, [ 'GC_S' num2str( Zheader.num_subjects ) '.mat'], [ 'C_S' num2str( Zheader.num_subjects )] );
  if isempty(x)
    return
  end

  ROIG  = [ 'ROI' filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep 'Gsegs'  filesep ];
  indexes = load( [ 'ROI' filesep 'data' filesep 'ROI_' num2str(G_ROI.Rindex, '%02d') '_' strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) ] );

  nSubs = Zheader.num_subjects;
  nFreqs = max(scan_information.frequencies, 1);
  nRuns  = Zheader.num_runs;
  nvox = str2num(get( handles.txt_GROI_num_voxels, 'String' ));
 
  
  mask                       = scan_information.mask; 
  
  dest = ['ROIGC_Images' filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) ];
  if ~exist( dest, 'dir' )
    mkdir( dest );
  end
  
  if ~isempty(handles.progressBar)
    handles.progressBar.setWindowTitle( 'ROI GC Images' );
    handles.progressBar.setMessages( 'Creating ROI GC images', '', '' );
    iters = iteration_rule( 'Iterations', 'Residual Images', {'primary'} );
    handles.progressBar.setIterations( iters.primary, handles.progressBar.PRIMARY );    
    handles.progressBar.show();
  end

  
  for subjectNo = 1:nSubs

    grp = '';
    run = '';
    sid = subject_id( subjectNo );
    ftag = '';

    if ~isempty(handles.progressBar)
      iters = iteration_rule( 'Iterations', 'Residual Images', {'secondary'}, ...
                 struct( 'Subj', subjectNo ) );
      handles.progressBar.setIterations( iters.secondary, handles.progressBar.SECONDARY );    
      handles.progressBar.setParticipant( subjectNo, Zheader.num_subjects, sid );
    end
    
    for FrequencyNo = 1:nFreqs
        
      ftag = frequency_tag(FrequencyNo) ;
      fdir = strrep( ftag, '_', '' );

      if ~isempty(handles.progressBar)
        if scan_information.isMulFreq
          handles.progressBar.setFrequency( FrequencyNo, scan_information.frequencies, fdir );
        end
      end
      
%       sdest = 'Residual_Images';

      eval( ['load( ''' ROIGC 'GC_S' num2str( subjectNo ) '.mat'', ''C_S' num2str( subjectNo )  ''' ); ' ] );
      eval( ['load( ''' ROIG   'G_S' num2str( subjectNo ) '.mat'', ''G'' ); ' ] );

%      G = G(:, indexes.Gindex);
      [u d v] = svd( G );
      
      G = u(:,1:nvox);
      
      GC = [];
      eval( [' GC = G * C_S' num2str( subjectNo ) ';' ] );
      
      clear GC_S* C_S*

      scans = size(GC, 1);

      str = scan_information.scandir_format;
      str = strrep( str, '{run_dir}', run );
      str = strrep( str, '{group_dir}', grp );
      str = strrep( str, '{frequency_dir}', fdir );
      str = strrep( str, '{subject_dir}', sid );

      output_path = [ dest filesep str filesep ];
      
      mkdir( output_path );
        
      if ~isempty(handles.progressBar)
        handles.progressBar.setIterations( scans );
      end
        
      for scanidx = 1:scans

        if ~isempty(handles.progressBar)
          handles.progressBar.increment();
        end
          
        scanno = sprintf( '_%04d', scanidx );
        filename = [ 'GCROI_' sid run ftag scanno '.img' ] ;

        scan_image = zeros( size(mask.ind) );
        scan_image(indexes.Zindex) = GC(scanidx,:);
        
        err = write_cpca_image( output_path, filename, scan_image, mask );
        if ( ~isempty( err ) )
          disp( [ 'Error Writing Image: ' output_path filename ] );
        end;

      end
    
    end  % --- each frequency

  end  % --- each subject
 
  scan_image = zeros( size(mask.ind) );
  scan_image(indexes.Zindex) = 1;
  err = write_cpca_image( [ dest filesep], 'mask.img', scan_image, mask );
  
  if ~isempty(handles.progressBar)
    handles.progressBar.hide();
  end
  
  if size(process_information.sudo.user, 2) > 0 && process_information.sudo.confirmed == 1
    cmd = ['!chown -R ' process_information.sudo.user '.' process_information.sudo.group ' *' ];
    eval( cmd );
  end
 
