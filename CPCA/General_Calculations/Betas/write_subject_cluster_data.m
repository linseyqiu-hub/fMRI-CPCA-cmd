function write_subject_cluster_data( rotation_params, subject_VR, MNI, subject_no, pop )
global Zheader  
% ----         cluster_vr = subject_VR(comp,MNI(comp).pos(index).Masks.Zindex);

  if ( nargin < 5 ),  pop = [];  end;
  if ~isa( pop, 'cpca_progress' ),     pop = [];   end

  if isfield( rotation_params, 'htype' ) 
    Hmodel = rotation_params.htype; 
  else
    Hmodel = 'G';
  end; 

  if isempty( rotation_params ) || ~isfield( rotation_params, 'method' )
    rotation_params.method = 'unrotated';
    rotation_params.defaults = struct( 'empty', 1 );
    rotation_params.fs = 'non_rotated';
  end;

%  Txt = [ rotation_params.method ' Subject VR''s for ' num2str(rotation_params.nd) ' components' ];
  Sts = 'mean stats';
  
%  rotation_params.nd = nd;

  if ~isfield( rotation_params, 'model' )
    rotation_params.model = 'G';
  else
    if isempty(rotation_params.model)
      rotation_params.model = 'G';
    end;
  end;

  [~, cp] = fs_create_path( 'subject', 'subject', rotation_params.nd, subject_no, rotation_params );
  iters = rotation_params.nd * size(MNI.component(1).threshold,1) * 2;

  if ~isempty(pop)
    pop.setIterations( iters, pop.SECONDARY );
    pop.setComment( Sts );
  end;
  
  for comp = 1:rotation_params.nd

    rotation_params.defaults.component = comp;
    
    for thr = 1:size(MNI.component(comp).threshold,1)
        
      if is_active_threshold(thr)
          
        thisMNI = MNI.component(comp).threshold(thr);

        filename = sprintf( '%s_Component_%02d_%.2dpct_Cluster_mean_median.txt', Hmodel, comp, Zheader.pct_value(thr) );
        [~, sp] = fs_create_path( 'subject', 'component', rotation_params.nd, subject_no, rotation_params );

        text_file = [sp filename];
        fid = fopen( text_file, 'w' );
        text_file_header( rotation_params.nd, fid, 0, cp, Zheader.total_columns );

        if (fid), fprintf( fid, '\n\nPositive Components\n------------------------------------------\nmni coordinates    mm3      mean  median\n' ); end;

   
        if ~isempty(thisMNI.pos)

          for clno = 1:size(thisMNI.pos, 1)
            if ( thisMNI.pos(clno).mm3 >= 500 )

              cluster_vr = subject_VR; %(comp,thisMNI.pos(clno).Masks.Zindex);
              mn = mean(cluster_vr);
              md = median(cluster_vr);

              op = sprintf( ' %4d %4d %4d (%5d):  %.4f  %.4f',thisMNI.pos(clno).peak.mni(1), thisMNI.pos(clno).peak.mni(2), thisMNI.pos(clno).peak.mni(3), thisMNI.pos(clno).mm3, mn, md );
          
              if (fid), fprintf( fid, '%s\n', op ); end;

            end;
          end;

        end;  % -- positive values

        if ~isempty(pop)
          pop.increment( pop.SECONDARY );
        end;

        if (fid), fprintf( fid, '\n\nNegative Components\n------------------------------------------\nmni coordinates    mm3      mean  median\n' ); end;

        if ~isempty(thisMNI.neg)

          for clno = 1:size(thisMNI.neg, 1)
            if ( thisMNI.neg(clno).mm3 >= 500 )

              cluster_vr = subject_VR; %(comp,thisMNI.neg(clno).Masks.Zindex);
              mn = mean(cluster_vr);
              md = median(cluster_vr);

              op = sprintf( ' %4d %4d %4d (%5d):  %.4f  %.4f', thisMNI.neg(clno).peak.mni(1), thisMNI.neg(clno).peak.mni(2), thisMNI.neg(clno).peak.mni(3), thisMNI.neg(clno).mm3, mn, md );
          
              if (fid), fprintf( fid, '%s\n', op ); end;

            end;
          end;

        end;  % -- negative values

        if ~isempty(pop)
          pop.increment( pop.SECONDARY );
        end;

        if fid,  fprintf( fid, '\n'); fclose(fid); end;

      end % -- threshold is active
      
    end % --- each threshold value

   
  end;

