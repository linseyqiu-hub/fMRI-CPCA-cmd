function create_mask_cmd(scan_information,Zheader,mask_file, option )
%--- create common mask for all scans
%--- option 1: Global mean threshold
%--- option 2: Harvard Oxform MNI template 
%--- 
  switch(option)
      case 1
          handles.chk_calc_MNI.Value = 0 ;
          handles.mask_threshold = 0.8;
      case 2
          handles.chk_calc_MNI.Value = 1 ; % Harvard Oxford MNI coordinates
             
      otherwise
          disp('wrong option for mask creation!')
          return
  end

  handles.chk_no_ventricles.Value = 1;  % Remove Ventricles 

  % set recreate existing masks
  handles.chk_recreate_masks.Value = 0;
  % Use Global Mean Threshold
  handles.mask_threshold = 0.8;
  handles.txt_Thresh.String =  num2str( handles.mask_threshold, '%.2f' ) ;
  % Flag precentage Loss over, 5
  handles.txt_flag_reduction_value.String = num2str( constant_define( 'MASK_REDUCTION' ) );
  % handles.chk_from_global_mean.Value = 0;

  % handles.txt_Thresh.Enable = 'on';

  % Destination
  handles.txt_destination_folder.String= pwd;  % pwd or basedir??
  % File Name, default mask.img
  handles.txt_mask_name.String = mask_file;

  % image Filter, from files.txt
  str = char(scan_information.ListSpec);
  if ( length(str) == 0 )  str = '*.img'; end
  handles.txt_image_filter.String = str;

  x = scan_information.NumSubjects > 0;  
  % handles.chk_all_subjects.Enable = char(handles.onoff(x+1));
  handles.chk_all_subjects.Value = x;

  lst = [];
  if ( x > 0 )
    for ( ii = 1:size(scan_information.SubjectID,2) )
      lst = [lst; {char(scan_information.SubjectID(ii))}];
    end
  end
  handles.lst_subjects.String = lst;
  handles.lst_subjects.Value = 1;

  x = scan_information.NumRuns > 1;  
  % handles.chk_all_runs.Enable = char(handles.onoff(x+1));
  handles.chk_all_runs.Value = x;
  % handles.lst_subject_runs.Enable = char(handles.onoff(x+1));

  lst = [];
  if ( x )
    for ( ii = 1:scan_information.NumRuns)
      str = sprintf( 'Run %d', ii );
      lst = [lst; {str}];
    end
  end

  handles.lst_subject_runs.String= lst;
  handles.lst_subject_runs.Value = 1;

  mask_threshold =  str2double( handles.txt_Thresh.String ); 
  flag_threshold = str2double( handles.txt_flag_reduction_value.String );
  % flag_issues = handles.chk_flag_reductions.Value;
  use_HO_MNI = handles.chk_calc_MNI.Value;
%  resume_calculation = get( handles.chk_resume_create, 'Value' );

  % --- destination file name
  % ------------------------------------------
  dest_dir = handles.txt_destination_folder.String;
  dest_file = handles.txt_mask_name.String;

  destination = [ dest_dir filesep dest_file ];

  % ------------------------------------------
  % --- image list filespec filter
  % ------------------------------------------
  filter = handles.txt_image_filter.String;

  % ------------------------------------------
  % --- create a subject vector for selected subjects
  % ------------------------------------------
  x = handles.chk_all_subjects.Value;
  SubjectVector = [];

  if ( x )
    SubjectVector =  1:Zheader.num_subjects ;
  else

    subjectList = handles.lst_subjects.String;

    for ii = 1:size(subjectList,1)
      for jj = 1:size(scan_information.SubjectID,2)
        if ( strcmp( char(subjectList(ii)), char(scan_information.SubjectID(jj)) ) )
          SubjectVector = [SubjectVector jj];
        end
      end
    end

  end


  % ------------------------------------------
  % --- create a run vector for selected runs 
  % ------------------------------------------
  x = handles.chk_all_runs.Value;
  RunVector = 1:Zheader.num_runs ;
  
  if (Zheader.num_runs > 1) && ~x
    RunList = handles.lst_subject_runs.String;
    RunVector = [];
    for ( ii = 1:size(RunList,1) )
      x = char(RunList(ii));
      x = strrep( x, 'Run', '' );
      RunVector = [RunVector char(x)];
    end
    RunVector = str2num( RunVector );
  end


  % ------------------------------------------
  % --- create the individual subject/run mask images
  % ------------------------------------------

  Txt = 'Creating Mask';
  Sts = '';

  original_dir = pwd;

  msk = [];   % --- maximum mask from all subjects
  smsk = [];  % --- loaded current subject/run mask
  nmsk = [];  % --- working mask for adjustment to new mask
  fmsk = [];  % --- final mask as accumulated
  adjustments = [];
 
  x = exist( 'mask_logs', 'dir' );
  if ~x
    mkdir 'mask_logs';
  end

  x = exist( 'subject_masks', 'dir' );
  if ~x
    mkdir 'subject_masks';
  end

  sfmt = full_dec_format(Zheader.num_subjects);
  rfmt = full_dec_format(Zheader.num_runs);
  dfmt = strrep( sfmt, 'd', 's' );
  drfmt = strrep( rfmt, 'd', 's' );

  mask_stats = [];  % --- [ subject #,  run #,   image size,  removed, remain ]

  use_current_subject_masks = handles.chk_recreate_masks.Value;

  hdr = sprintf( [dfmt ' ' drfmt ' %-32s  %6s  %6s %15s  %15s %15s %15s %15s %15s %15s %15s %15s  %s'], ...
               'S', 'R', 'Identifier', 'voxels', 'common', '-ref',  ... 
               '   RSA', '   LSA', '   RSP', '   LSP', '   RIA', '   LIA', '   RIP', '   LIP', '  flags');

  if use_HO_MNI

    D = dir( ['subject_masks' filesep 'whole_brain_template_mask.img' ] );

    if isempty(D)  % --- create MNI template mask

      % subject_dir = subject_scan_directory_cmd( 1, 1, 1, scan_information );
      
      selected_subject = handles.lst_subjects.Value;
      selected_run = handles.lst_subject_runs.Value;
      subject_dir = subject_scan_directory_cmd( selected_subject, selected_run, 1, scan_information );
      
      filespec = [subject_dir filesep char(scan_information.ListSpec)];
      D=dir(filespec);
      if size(D,1) > 0 

        img = cpca_read_vol( [subject_dir filesep D(1).name ] );

        fmsk = MNI_mask_calculation_cmd( img );
        
        fmsk.vol.fname = ['subject_masks' filesep 'whole_brain_template_mask.img'];

        fmsk.x = size( fmsk.ind,1 );

        
        D = dir( ['subject_masks' filesep 'whole_brain_template_mask.img' ] );
      else
% --- WTF???
        return
      end
    end
  
    if size(D,1) == 1
      rmsk = cpca_read_vol( ['subject_masks' filesep D(1).name ] );
      rvbr = voxels_by_region(  rmsk );
      ln = sprintf( [dfmt ' ' drfmt ' %-32s  %6s %6s %6s %-15s  %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s  %s'], ...
                ' ', ' ', 'Base Reference Mask', num2str(rmsk.x), ' ', ' ', ... 
                format_value( rvbr(1), '%6d' ), ...
                format_value( rvbr(2), '%6d' ), ...
                format_value( rvbr(3), '%6d' ), ...
                format_value( rvbr(4), '%6d' ), ...
                format_value( rvbr(5), '%6d' ), ...
                format_value( rvbr(6), '%6d' ), ...
                format_value( rvbr(7), '%6d' ), ...
                format_value( rvbr(8), '%6d' ), ...
                '' );

      fprintf( 1, '%s\n', hdr );
      fprintf( 1, '%s\n', ln );

    end
  
  end
  if (use_current_subject_masks && isdir([pwd filesep 'subject_masks']))
	for i = 1:size(SubjectVector, 2)
		if(exist([pwd filesep 'subject_masks' filesep ['subject_' num2str(SubjectVector(i)) '_' subject_id_cmd( SubjectVector(i),scan_information ) '_mask.img']], 'file')) 
			SubjectVector(i) = -1;
		end
	end
  end
  SubjectVector(find(SubjectVector==-1)) = [];
			
		

  if size(SubjectVector)>0

    disp('Creating Subject Masks' );
      
    fidsum = fopen( [ 'mask_logs' filesep 'mask_creation_summary.log'], 'w' );
    fiderr = fopen( [ 'mask_logs' filesep 'mask_creation_errors.log'], 'w' );

    if fidsum
      fprintf( fidsum, '%s\n', 'sample summary line' );
      fprintf( fidsum, '%s\n', '% S R Identifier                        voxels   -ref       RSA    LSA    RSP    LSP    RIA    LIA    RIP    LIP  flags ' );
      fprintf( fidsum, '%s\n', '% 2 1 aoP_269784_run1                    67207   6185       562    334    738    335   1112    877   1708    519    [ > 500]' );
      fprintf( fidsum, '%s\n', '%   definitions:' );
      fprintf( fidsum, '%s\n', '%     S          :  Subject Number - may not correspond to original subject number' );
      fprintf( fidsum, '%s\n', '%     R          :  Run Number - may not correspond to original session number' );
      fprintf( fidsum, '%s\n', '%     Identifier :  unique identifier for subject mask selection' );
      fprintf( fidsum, '%s\n', '%     voxels     :  size of this subject mask' );
      fprintf( fidsum, '%s\n', '%     -ref       :  number of voxels removed from base reference mask' );
%      fprintf( fidsum, '%s\n', '%     -mask      :  number of voxels removed from current adjusted mask' );
%      fprintf( fidsum, '%s\n', '%     result     :  size of current mask after adjusting for this subject' );
      fprintf( fidsum, '%s\n', '%     Regions    :  indicates amount of voxels removed by region' );
      fprintf( fidsum, '%s\n', '%                :    RSA = Right Superior Anterior' );
      fprintf( fidsum, '%s\n', '%                :    LSA = Left  Superior Anterior' );
      fprintf( fidsum, '%s\n', '%                :    RSP = Right Superior Posterior' );
      fprintf( fidsum, '%s\n', '%                :    LSP = Left  Superior Posterior' );
      fprintf( fidsum, '%s\n', '%                :    RIA = Right Inferior Anterior' );
      fprintf( fidsum, '%s\n', '%                :    LIA = Left  Inferior Anterior' );
      fprintf( fidsum, '%s\n', '%                :    RIP = Right Inferior Posterior' );
      fprintf( fidsum, '%s\n', '%                :    LIP = Left  Inferior Posterior' );
      fprintf( fidsum, '%s\n', '%     flag       :  message flags - self explanatory, blank if no anomaly or error');
      fprintf( fidsum, '%%\n\n' );

    end
    
    % --- for each subject
    for sidx = 1:size( SubjectVector, 2 )
    
       
      SubjectNo = SubjectVector( sidx );
      sid = subject_id_cmd( SubjectNo,scan_information );
      handles.lst_subjects.Value =sidx;

      msk = [];
      max_mask = [];

      if use_HO_MNI
        fmsk = cpca_read_vol( ['subject_masks' filesep 'whole_brain_template_mask.img'] );
        fmsk.ind = find( fmsk.image );
        fmsk.MNI = MNI_coords( fmsk );
      end
      
      % ---   for each run
      for ridx = 1:size( RunVector, 2 )
        RunNo = RunVector( ridx );

        if iscellstr( scan_information.SubjDir( SubjectNo, RunNo ) )
          
          handles.lst_subject_runs.Value=ridx;

          if use_HO_MNI
            mask_by_variance();
          else
            produce_subject_masks();
          end

 
          
        end  % --- Subject contains run ---

      end

    end  % --- each subject ---

    x = find( mask_stats(:,5) == max(mask_stats(:,5) ) );
    max_mask = mask_stats( x(1), 1:2 );
    mask_id = 'whole_brain_template';
    save mask_stats mask_stats max_mask mask_id flag_threshold;

    if fiderr
      fclose( fiderr );
    end

    if fidsum
      fclose( fidsum );
    end
  
    subjects_masked = 1;
    save mask_stats subjects_masked '-append'
    
  end  % -- perform subject mask creation
  
  % ------------------------------------------
  % --- accummulate all common voxels in single mask
  % ------------------------------------------
  
  load mask_stats max_mask mask_id
  if use_HO_MNI
    mid = 'whole_brain_template';
  else
    mid = mask_identifier_cmd( max_mask(1), max_mask(2),scan_information );  
  end
  

  fidsum = fopen( [ 'mask_logs' filesep 'mask_creation_summary.log'], 'a' );
  fiderr = fopen( [ 'mask_logs' filesep 'mask_creation_errors.log'], 'a' );
 
  if fidsum
    fprintf( fidsum, '\n%% -------------- %s --------------\n', datestr( now ) );
    fprintf( fidsum, '%s\n', hdr);
  end
  
  if fiderr
    fprintf( fiderr, '\n%% -------------- %s --------------\n', datestr( now ) );
    fprintf( fiderr, '%s\n', hdr);
  end
  
  D = dir( ['subject_masks' filesep '*' mid '_mask.img' ] );
  if size(D,1) == 1
    rmsk = cpca_read_vol( ['subject_masks' filesep D(1).name ] );
    
    rvbr = voxels_by_region(  rmsk );
    ln = sprintf( [dfmt ' ' drfmt ' %-32s  %6s %-15s  %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s  %s'], ...
                ' ', ' ', 'Base Reference Mask', num2str(rmsk.x), ' ',  ... 
                format_value( rvbr(1), '%6d' ), ...
                format_value( rvbr(2), '%6d' ), ...
                format_value( rvbr(3), '%6d' ), ...
                format_value( rvbr(4), '%6d' ), ...
                format_value( rvbr(5), '%6d' ), ...
                format_value( rvbr(6), '%6d' ), ...
                format_value( rvbr(7), '%6d' ), ...
                format_value( rvbr(8), '%6d' ), ...
                '' );

    fprintf( 1, '%s\n', hdr );
    fprintf( 1, '%s\n', ln );

    if fidsum
      fprintf( fidsum, '%s\n', ln );
    end
    if fiderr
      fprintf( fiderr, '%s\n', ln );
    end
    
  else
    fprintf( 1, '%% --- %s\n', [ '% --- Unable to find base reference mask: ' mid ] );
    if fiderr
      fprintf( fiderr, '%% --- %s\n', [ '% --- Unable to find base reference mask: ' mid ] );
      fclose( fiderr );
    end
    
    if fidsum
      fclose( fidsum );
    end
    return;
  end
  
  fmsk = rmsk;
  initial_max = rmsk.x;
  final_mask_size = rmsk.x;

       
  % --- for each subject
  for SubjectNo = 1:Zheader.num_subjects

    sid = subject_id_cmd( SubjectNo, scan_information );

    % ---   for each run
    for RunNo = 1:Zheader.num_runs

        
      if iscellstr( scan_information.SubjDir( SubjectNo, RunNo ) )

         mid = mask_identifier_cmd( SubjectNo, RunNo,scan_information);
         D = dir( ['subject_masks' filesep '*' mid '_*.img'] ) ;
         if size(D,1) == 1
           smsk = cpca_read_vol( ['subject_masks' filesep D.name ] );

           nmsk = smsk;
           nmsk.image = sum([ rmsk.image'; smsk.image' ] )';
          
           nmsk.ind = find( nmsk.image == 2 );
           [nmsk.x nmsk.y] = size( nmsk.ind );
           nmsk.image = zeros( prod(nmsk.vol.dim), 1 );
           nmsk.image( nmsk.ind ) = 1;
           nvbr = voxels_by_region(  nmsk );
           
           removed_from_max = rmsk.x - nmsk.x;
           removed_from_self = smsk.x - nmsk.x;
           
           image = sum([ fmsk.image'>0; smsk.image'>0 ] )';

           ind = find( image == 2 );
           if ~isempty( ind )
             fmsk.ind = ind;
             [fmsk.x fmsk.y] = size( fmsk.ind );
             image = zeros( prod(fmsk.vol.dim), 1 );
             image( fmsk.ind ) = fmsk.image( fmsk.ind );
             fmsk.image = image;
           end
           
           removed_from_final = final_mask_size - fmsk.x;
           final_mask_size = fmsk.x;

           vbr = rvbr - nvbr ;     
           adjustments = [adjustments; [ SubjectNo, RunNo, prod(smsk.vol.dim), smsk.x, ...
                                         removed_from_max,  removed_from_self, ...
                                         removed_from_final, fmsk.x, vbr ] ];
            
           sumtag = '';  
           if size(ind,1) == 0
             sumtag = '   [MASK ZEROED]';
           else
             x = removed_from_max / rmsk.x * 100;
             if x > flag_threshold || any(vbr./nvbr * 100 > flag_threshold )
               sumtag = ['   [ ' num2str(x, '%5.1f') '% Removed]' ];
             end
           end

           % -- number of voxles included in base reference mask
           x = [rmsk.image nmsk.image * 2];
           y = sum( x');
           x = find( y == 3 );
            
           ln = sprintf( [sfmt ' ' rfmt ' %-32s  %6d  %6d %15s  %15s %15s %15s %15s %15s %15s %15s %15s %s'], ...
                SubjectNo, RunNo, mid, smsk.x, size(x,2), ... 
                format_percentages( rmsk.x, removed_from_max, '%d (%5.1f%%)' ), ...
                format_percentages( rvbr(1), vbr(1), '%d (%5.1f%%)' ), ...
                format_percentages( rvbr(2), vbr(2), '%d (%5.1f%%)' ), ...
                format_percentages( rvbr(3), vbr(3), '%d (%5.1f%%)' ), ...
                format_percentages( rvbr(4), vbr(4), '%d (%5.1f%%)' ), ...
                format_percentages( rvbr(5), vbr(5), '%d (%5.1f%%)' ), ...
                format_percentages( rvbr(6), vbr(6), '%d (%5.1f%%)' ), ...
                format_percentages( rvbr(7), vbr(7), '%d (%5.1f%%)' ), ...
                format_percentages( rvbr(8), vbr(8), '%d (%5.1f%%)' ), ...
                sumtag);
%fprintf( 1, '%s\n', ln );
           
           if ~isempty( sumtag )
             fprintf( 1, '%s\n', ln );
             if fiderr
               fprintf( fiderr, '%s\n', ln );
             end
           end             

           if fidsum
               fprintf( fidsum, '%s\n', ln );
           end

         
         else
           if size(D,1) == 0
             str = ' no mask found using identifer ';
           else
             str = ' more than 1 mask using identifer ';
           end

           fprintf( 1, '%s [%s]\n', str, mid );
           if fiderr
             fprintf( fiderr, '%s [%s]\n', str, mid );
           end
  
         end
         
      end % --- run encoded in subject
        
    end % --- each run
    

  end % --- each subject
 
  if fiderr
    fclose( fiderr );
  end
  
  if fidsum
    fclose( fidsum );
  end
  
  if ~isempty( adjustments )
    adjustments  = [ adjustments sum(adjustments(:,7:8)')'];
    save mask_stats adjustments '-append'
  end

  
  % --= 
  dt = cpca_data_type( 'FLOAT32' );   
  fmsk.vol.fname = dest_file;	 
  fmsk.vol.pinfo = [1;0;0]; 
  fmsk.vol.dt = double( [dt.code isBigendian()] ); 			
  fmsk.header.datatype = dt.code; 
  fmsk.header.bitpix = dt.bits; 
  fmsk.header.scl_slope = 1; 
  
  % ensure n+1 images read are produced in ni1 format 
  fmsk.header.vox_offset = 0; 
  fmsk.header.magic = 'ni1'; 
  
  % set the fields used by other applications
  fmsk.header.regular = 'r';
  fmsk.header.glmax = max(fmsk.image); 
  fmsk.header.glmin = min(fmsk.image); 
  
  % by default, mask will not include Ventricles
  if  handles.chk_no_ventricles.Value ==1
    x = find( fmsk.image == constant_define( 'MASK_VENTRICLES') );
    if ~isempty(x)
      fmsk.image(x) = 0;
      fmsk.ind = find( fmsk.image ) ;
    end
  end

% % --- White Matter removal from analysis
% % --- default position will be to remove white matter form an analysis
% % --- creation of Z will still retain white matter voxels, but all
% % --- subsequent calulation will strip white matter if required
% % --- this will allow for rapid fallback to whole brain analysis

%     x = find( fmsk.image == constant_define( 'MASK_WHITE_MATTER') );
%     if ~isempty(x)
%       fmsk.image(x) = 0;
%       fmsk.ind = find( fmsk.image ) ;
%     end
%     
% %    fmsk.image(fmsk.ind) = 1;           % -- no white so no need to maintain registration
%   end
  
  fmsk.image = reshape( fmsk.image, fmsk.vol.dim);

  n = cpca_write_vols( fmsk ); % --= 


  vector = sort(adjustments(:,4), 'descend');
  h = figure('visible','off'); plot( vector, '-*' );
  title( {'mask size scree plot'} );
  saveas( h, 'mask_size_scree_plot.png' );
  close(h)


  if use_HO_MNI
    handles.output = [ destination '~tal' ];

    vbr = voxels_by_region(  fmsk );
    ln = sprintf( [sfmt ' ' rfmt ' %-32s  %6s %-15s  %-15s %-15s %-15s %-15s %-15s %-15s %-15s %-15s  %s'], ...
                ' ', ' ', 'Final Mask', num2str(fmsk.x), ' ',  ... 
                format_value( vbr(1), '%6d' ), ...
                format_value( vbr(2), '%6d' ), ...
                format_value( vbr(3), '%6d' ), ...
                format_value( vbr(4), '%6d' ), ...
                format_value( vbr(5), '%6d' ), ...
                format_value( vbr(6), '%6d' ), ...
                format_value( vbr(7), '%6d' ), ...
                format_value( vbr(8), '%6d' ), ...
                '' );

    fprintf( 1, '%s\n', hdr );
    fprintf( 1, '%s\n', ln );
    
  else  
    handles.output = destination;
  end



%% --- nested functon produce_subject_masks()
  function mask_by_variance()
  % --- this nested funtion only produces the individual run masks for current subject
  
    subject_dir = subject_scan_directory_cmd( SubjectNo, RunNo,1,scan_information);
    these_stats = [ SubjectNo, RunNo, 0 0 0 ];
    
    D = dir([ subject_dir filesep filter ]);
    if size(D,1) == 0
      fprintf( 1, '%s\n', [ 'No Files: ' subject_dir ] );
      if fiderr
        fprintf( fiderr, '%s\n', [ 'No Files: ' subject_dir ] );
      end
      mask_stats = [mask_stats; these_stats];
      return;
    end
        
    fn = [ subject_dir filesep D(1).name ];

    Z = zeros( size(D,1), rmsk.x );

%    GX = [];
    
    for fi = 1:size(D,1)

      fn = [ subject_dir filesep D(fi).name ];
      img = cpca_read_vol(fn);
      if isfield( img.header, 'error' ) 
        fprintf( 1, '%s\n', [ 'IMAGE ERROR: ' fn ] );
        if fiderr
          fprintf( fiderr, '%s\n', [ 'IMAGE ERROR: ' fn ] );
        end
        rem_vox = [];
        mask_stats = [mask_stats; these_stats];
        return;

      end

      Z(fi,:) = img.image( rmsk.ind );
%      GX = [ GX; calc_global_mean(img) ]; % --= 
      
      if isempty( msk )
        msk = img; % --= 
        msk.image = ones( size(msk.image(:) ) ); % --= 
      end   % --- initialize the volume header and img data % --= 

      if ( fi == 1 )
        subject_mask = msk.image;
      end;
          
      mask_size = find( subject_mask);

      
    end % --= each scan image in subject run directory

    clear D;


    SD = samp_dev( Z );
    problematic = find( isnan( sum(Z ) ) );
    problematic = [problematic find( isinf( sum(Z ) ) )];
    problematic = unique( [problematic find( SD == 0 )] );
    column_mean = mean( Z );

    disp( 'Processing Subject Masks --> Calculating Variance');
    
    if ~isempty( problematic )
      SD(problematic) = 0;
    end
    x = find( SD > 0 );

    msk.ind = rmsk.ind(x);
    [msk.x msk.y] = size( msk.ind);
%    mask_VR = ones( 1, msk.y );
    mask_VR = fmsk.image( msk.ind);
      
    mid = mask_identifier_cmd( SubjectNo, RunNo,scan_information );
    mask_name = ['subject_' num2str(SubjectNo, sfmt ) '_' mid '_mask.img' ];
    err = write_cpca_image( ['subject_masks' filesep], mask_name, mask_VR, msk );

    x = size(msk.image);
    if size(x,2 ) < 3
      dim = msk.vol.dim;
      D = reshape( msk.image, dim);
    else
      D = msk.image;
    end

    ind = 1:prod(dim);

    [msk.I, msk.J, msk.K] = ind2sub(size(D), ind);
    msk.IJK = [msk.I; msk.J; msk.K];
    if ~isempty(msk.IJK)
      msk.MNI = msk.vol.mat(1:3,:)*[msk.IJK; ones(1,size(msk.IJK,2))];
    end

    vbr = voxels_by_region(  msk );
    % --- vbr = [ RSA LSA RSP LSP RIA LIA RIP LIP ]
    
%    msk.image = subject_mask;  % --- adjust the final mask if subject processed fully
%    mask_stats = [mask_stats; [ SubjectNo RunNo size(mask_size,1) size(mask_size,1) - size(msk.ind,2)  size(msk.ind,2) vbr ] ];
    mask_stats = [mask_stats; [ SubjectNo RunNo size(mask_size,1) size(mask_size,1) - size(msk.ind,1)  size(msk.ind,2) vbr ] ];

    if isempty( max_mask ) || size( msk.ind,2) > size( max_mask.ind, 2 )
      max_mask = msk;
    end
    
  end  % --- nested function mask_by_variance()

  %% --- nested function produce_subject_masks()
  function produce_subject_masks()
  % --- this nested funtion only produces the individual run masks for current subject
  
    subject_dir = subject_scan_directory_cmd( SubjectNo, RunNo,1,scan_information);
    these_stats = [ SubjectNo, RunNo, 0 0 0 ];
    
    D = dir([ subject_dir filesep filter ]);
    if size(D,1) == 0
      fprintf( 1, '%s\n', [ 'No Files: ' subject_dir ] );
      if fiderr
        fprintf( fiderr, '%s\n', [ 'No Files: ' subject_dir ] );
      end
      mask_stats = [mask_stats; these_stats];
      return;
    end
        
    fn = [ subject_dir filesep D(1).name ];

    for fi = 1:size(D,1)

      fn = [ subject_dir filesep D(fi).name ];
      img = cpca_read_vol(fn);
      if isfield( img.header, 'error' ) 
        fprintf( 1, '%s\n', [ 'IMAGE ERROR: ' fn ] );
        if fiderr
          fprintf( fiderr, '%s\n', [ 'IMAGE ERROR: ' fn ] );
        end
        rem_vox = [];
        mask_stats = [mask_stats; these_stats];
        return;

      end

      if isempty( msk )
        msk = img; % --= 
        msk.image = ones( size(msk.image(:) ) ); % --= 
      end   % --- initialize the volume header and img data % --= 

      if ( fi == 1 )
        subject_mask = msk.image;
        Z = logical( zeros( size(D,1), size( img.image, 1 ) ) );
      end
          
      mask_size = find( subject_mask);

      GX = calc_global_mean(img); % --= 
      if GX > 0
        M = img.image./ GX > mask_threshold; % --= 
      else
        M = zeros(1, size(Z,2) );
      end
      Z( fi,:) = M;

      image = subject_mask.*double(M(:)); % --= 
      rem_vox = find( image );
      if isempty(rem_vox)
        fprintf( 1, '%s\n', [ 'MASK ZERO: ' fn ] );
        if fiderr
          fprintf( fiderr, '%s\n', [ 'MASK ZERO: ' fn ] );
        end
        mask_stats = [mask_stats; these_stats];
        return;
      end

      
    end % --= each scan image in subject run directory

    clear D;

    if isempty(rem_vox)  % scan image zero's the mask
      return;
    end

    x = sum(Z);				% --- sum the voxel inclusions
    msk.ind = find( x == size(Z,1) );		% --- locating voxels common to all scans
    [msk.x, msk.y] = size( msk.ind);
    mask_VR = ones( 1, msk.y );
      
    mid = mask_identifier_cmd( SubjectNo, RunNo, scan_information );
    mask_name = ['subject_' num2str(SubjectNo, sfmt ) '_' mid '_mask.img' ];
    err = write_cpca_image( ['subject_masks' filesep], mask_name, mask_VR, msk );

    x = size(msk.image);
    if size(x,2 ) < 3
      D = reshape( msk.image, msk.vol.dim);
    else
      D = msk.image;
    end

    ind = 1:prod(msk.vol.dim);

    [msk.I, msk.J, msk.K] = ind2sub(size(D), ind);
    msk.IJK = [msk.I; msk.J; msk.K];
    if ~isempty(msk.IJK)
      msk.MNI = msk.vol.mat(1:3,:)*[msk.IJK; ones(1,size(msk.IJK,2))];
    end

    vbr = voxels_by_region(  msk );
    % --- vbr = [ RSA LSA RSP LSP RIA LIA RIP LIP ]
    
    msk.image = subject_mask;  % --- adjust the final mask if subject processed fully
    mask_stats = [mask_stats; [ SubjectNo RunNo size(mask_size,1) size(mask_size,1) - size(msk.ind,2)  size(msk.ind,2) vbr ] ];

    if isempty( max_mask ) || size( msk.ind,2) > size( max_mask.ind, 2 )
      max_mask = msk;
    end
    
  end  % --- nested function produce_subject_masks()

end
