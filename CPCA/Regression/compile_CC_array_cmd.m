function compile_CC_array_cmd( Zheader, scan_information, model,reg )
% --- compile a the CC array from the individual subject B matrices
% --- 
% --- in order to simulate a full B * B' calculation, which may not be 
% --- small enough to fit into memory, we need to pre-create an empty CC
% --- matrix, which is a square matrix sized on the 2nd dimension of G.
% --- 
% ---  the process is 
% ---  for each subject
% ---     load the B matrix as primary diagonal block
% ---     for each consecutive subject
% ---        load the B matrix as secondary vertical/horizontal block
% --- and fit the pieces in place 
% --- eg  CC:
% ---    +-----+-----+-----+
% ---    | P*P | P*S | P*S |
% ---    +-----+-----+-----+
% ---    | S*P |     |     |
% ---    +-----+-----+-----+
% ---    | S*P |     |     |
% ---    +-----+-----+-----+

  if ( nargin < 4 ),  reg = 0;  end;

  out_dir = [ model 'Zsegs'];
  out_CC_file = [ out_dir filesep 'GCC' ];

  R = mask_registrations( scan_information.mask );
  ind = [];
  CC_var = 'CC';
  
  switch reg
      case 1           % Gray Matter includes Brain Stem and Cerebellum
        ind = unique( [ R.ind(1).zref; R.ind(4).zref; R.ind(5).zref ] );
        CC_var = 'CCG';
      case 2           % White Matter only
        ind = R.ind(2).zref;
        CC_var = 'CCW';
  end
  
  load( Zheader.Model.path, 'Gheader' );
  
  disp( 'creating C * C'' Matrix . . .' );

  if strcmp( model, 'G' )
    CCw = sum(Gheader.subject_encoded) * Gheader.bins; % *scan_information.NumRuns
  else
    CCw = Zheader.Contrast.mat_y * Zheader.num_subjects;
  end          
    
  eval( [ CC_var ' = zeros( ' num2str(CCw) ', ' num2str(CCw) ' );' ] );

  %  primary row/column positions
  pr_start = 0;
  pr_end = 0;
  pc_start = 0;
  pc_end = 0;

  %  secondary row/column positions
  sr_start = 0;
  sr_end = 0;
  sc_start = 0;
  sc_end = 0;

  subject_minus = 1;        % our single subject test data dies on this 
  if ( Zheader.num_subjects == 1 )   
    subject_minus = 0;  
  end  
    

  for SubjectNo = 1:Zheader.num_subjects - subject_minus
        
    sid = subject_id_cmd( SubjectNo, scan_information );
    
    % pop up window progress update

      % pop.setParticipant( SubjectNo, Zheader.num_subjects, sid );
      disp( 'Loading Primary Segment . . .' );
      % iters = iteration_rule( 'Iterations', 'G Regression', {} , ...
      %             struct( 'Subj', SubjectNo ) );


    % if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end


    if strcmp( model, 'G' )
      PrimDepth = Gheader.subject_encoded(SubjectNo) * Gheader.bins;
    else
      PrimDepth = Zheader.Contrast.mat_y;
    end
    
    if isempty( ind )    
      Primary = zeros( PrimDepth, Zheader.total_columns * max( 1, Zheader.num_Z_arrays ) );
      ebc = 0;
      for FrequencyNo = 1:max(scan_information.frequencies, 1)
        ftag = frequency_tag_cmd(FrequencyNo, scan_information) ;
        sbc = ebc + 1;
        ebc = sbc + Zheader.total_columns - 1;
        Primary( :,sbc:ebc) = load_subject_B_cmd(Gheader, SubjectNo,Zheader, ftag, model );
      end
      
    else
      Primary = [];
      for FrequencyNo = 1:max(scan_information.frequencies, 1)
        ftag = frequency_tag_cmd(FrequencyNo, scan_information) ;
        B = load_subject_B_cmd(Gheader, SubjectNo,Zheader,ftag, model );
        B = B(:, ind );
        Primary = [Primary B ];
      end
      clear B
    end
    
    % 
    % if ( ~isempty( funcs.memory_stats ) ) funcs.memory_stats(); end

    if ( Zheader.num_subjects > 1 )
      
      % block diagonal
      pr_start = pr_end + 1;
      eval( [ 'pr_end = min(pr_start + size(Primary,1) - 1, CCw ); ' ] );
  
      pr = [ num2str(pr_start) ':' num2str(pr_end) ];
      pc = [ num2str(pr_start) ':' num2str(pr_end) ];
      eval( [ CC_var '( ' pr ',' pc ' ) = Primary * Primary'';' ] );

      % % --- clear previous calculation buffers if necessary
      % if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 

      % initialize the secondary row positioning
      sr_end = pr_end;
      thisone = 0;

      for SNo = SubjectNo+1:Zheader.num_subjects
          
        sid = subject_id_cmd( SNo,scan_information );
        thisone = thisone + 1;
        theseones = Zheader.num_subjects - (SubjectNo + 1) + 1;

          % pop.setSecondaryParticipant( thisone, theseones, sid );
        disp( 'Loading Secondary Segment . . .' );

        if strcmp( model, 'G' )
          SecDepth = Gheader.subject_encoded(SubjectNo) * Gheader.bins;
        else
          SecDepth = Zheader.Contrast.mat_y;
        end          

        if isempty( ind )    
          ebc = 0;
          for SubFrequency=1:max(scan_information.frequencies, 1)
            subtag = frequency_tag_cmd(SubFrequency,scan_information) ;
            sbc = ebc + 1;
            ebc = sbc + Zheader.total_columns - 1;
            Secondary( :,sbc:ebc) = load_subject_B_cmd(Gheader, SNo,Zheader, subtag, model );
          end  % --- each sub frequency
        else
          Secondary = [];
          for SubFrequency = 1:max(scan_information.frequencies, 1)
            subtag = frequency_tag_cmd(SubFrequency,scan_information) ;
            B = load_subject_B_cmd(Gheader, SNo,Zheader, subtag, model );
            B = B(:, ind );
            Secondary = [Secondary B ];
          end
          clear B
        end
          
        disp( 'Calculating . . .' );
        
        sr_start = sr_end + 1;
        eval( [ 'sr_end = min(sr_start + size(Secondary,1) - 1, CCw ); ' ] );
        sr = [ num2str(sr_start) ':' num2str(sr_end) ];
        sc = [ num2str(sr_start) ':' num2str(sr_end) ];

        eval( [ CC_var '( ' pr ',' sc ' ) = Primary * Secondary'';' ] );
        % --- clear previous calculation buffers if necessary
        % if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
        % 
        eval ( [ CC_var '( ' sr ',' pc ' ) = Secondary * Primary'';' ] );


        if ( SNo == Zheader.num_subjects & SubjectNo == Zheader.num_subjects - 1 )    % place final block diagonal

          % % --- clear previous calculation buffers if necessary
          % if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 
          % 
          sc = [ num2str(sr_start) ':' num2str(sr_end) ];
          eval( [ CC_var '( ' sr ',' sc ' ) = Secondary * Secondary'';' ] );
        end

        
        clear Secondary;
        % 
        % if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 

      end % --- each secondary subject

      clear Primary;
      
    else
      eval ( [ CC_var ' = Primary * Primary'';' ] );
      clear Primary;
    end  % --- more than 1 subject

  end
    

  disp( 'Saving . . .' );


  initialize_non_existing_file( out_CC_file );
  save( [out_CC_file '.mat'], CC_var, '-append', '-v7.3');
  clear CC*
  % if ( ~isempty( funcs.clear_cache ) )  funcs.clear_cache(); end; funcs.memory_stats(); 

  % scan_information.processing.model.applied.resume_g.CC = 1;  % need it
  % or not?
    
end
