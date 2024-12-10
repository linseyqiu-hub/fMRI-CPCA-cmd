function mean_beta_images_cmd( Gheader, Zheader,scan_information, log_fid )
%  create the images of the mean betas


if ( nargin < 1 ) return; end
if ( nargin < 4 ) log_fid = 0; end

[has_dir dcomponent_directory] = fs_create_path( 'beta', 'root', 0, 0,  struct( 'model', 'GZsegs')  );

if ( has_dir )

    disp( 'Creating mean beta images . . .' );


    component_directory = [ pwd filesep dcomponent_directory ];
    component_loadings = [];

    MC = [];
    for SubjectNo = 1:Zheader.num_subjects

        C = [];
        for FrequencyNo_main=1:max(scan_information.frequencies, 1)
            ftag = frequency_tag_cmd(FrequencyNo_main, scan_information) ;
            C = [C load_subject_C_cmd( Gheader,Zheader, SubjectNo, ftag ) ];
        end

        [has_dir subject_directory] = fs_create_path( 'beta', 'subjects', 0, SubjectNo,  struct( 'model', 'GZsegs')  );

        er = 0;
        for condition = 1:Gheader.conditions
            if isEncoded_cmd(Zheader, scan_information, SubjectNo, condition )
                sr = er + 1;
                er = sr + Gheader.bins - 1;

                mean_condition = mean( C(sr:er,:) );
                img_name = [ 'Cnd_' num2str(condition) '_' fs_filename( 'img', '', 'mean_betas', [] ) ];
                write_images( mean_condition, subject_directory, img_name );
                %          write_images( mean_condition, subject_directory, ['mean_betas_subject_' num2str(SubjectNo) '_condition_' num2str(condition) ] );
            end
        end

        mean_subj = mean( C );
        img_name = [ fs_filename( 'img', '', 'mean_betas', [] ) ];
        write_images( mean_subj, subject_directory, img_name );
        %      write_images( mean_subj, subject_directory, ['mean_betas_Subject_' num2str(SubjectNo) ] );

        MC = [MC; mean_subj];

    end

    write_images( vectored_mean(MC), component_directory, 'mean_betas' );

end  % output directory exists



    function write_images( VR, component_directory, fn )


        for FrequencyNo = 1:scan_information.frequencies
            start_col = (FrequencyNo - 1) * Zheader.total_columns + 1;
            end_col = start_col + Zheader.total_columns - 1;
            ftag = frequency_tag_cmd(FrequencyNo, scan_information) ;

            thisVR = VR(:,start_col:end_col);
            component_image = scan_information.mask;

            filename = [component_directory fn ftag '.img'] ;
            if scan_information.mask.niiSingle   filename = strrep( filename, '.img', '.nii' );  end

            component_image.image = zeros( prod( component_image.vol.dim ), 1);		% --- storage area for finale written image --
            component_image.image( component_image.ind ) = thisVR;		  	% --- placing data vector into proper positions of mask ---
            component_image.image = reshape( component_image.image ,component_image.vol.dim);	% --- and reshaping the result to the mask volume dimensions ---

            dtyp = cpca_data_type( 'double' );
            src_prec = dtyp.analyse;
            if length( src_prec ) == 0
                src_prec = dtyp.nifti;
            end
            if isBigendian()  en = 'LE'; else en = 'BE'; end
            dtype = [src_prec '-' en];

            component_image.vol.dt = [dtyp.conversion isBigendian()];			% we default data type to signed double (float 64 )
            component_image.header.datatype = dtyp.conversion;
            component_image.header.bitpix = dtyp.bits;
            component_image.vol.fname = filename;

            if isfield( component_image.header, 'scl_slope')
                component_image.header.scl_slope = 1;
            end

            component_image.vol.pinfo(1) = 1;
            %    component_image.vol.private.dat.dtype = dtype;

            err = cpca_write_vols( component_image );
            if ( ~isempty( err ) )
                fprintf( 'Error Writing Image: %s \n', err );
                return;
            end

            if ( isunix ) & constant_define( 'PREFERENCES', 'general.duplicate_images' )

                x = exist( [ component_directory 'duplicates/'] , 'dir' );
                if ( x ~= 7 )  % the directory does not exist
                    eval( [ 'mkdir ''' component_directory 'duplicates'''] );
                end

                component_image.vol.fname = [component_directory 'duplicates/' fn ftag '.img'];
                err = cpca_write_vols( component_image );
                if ( ~isempty( err ) )
                    fprintf( 'Error Writing Image: %s \n', err );
                end
            end

        end

    end

end

