function betas = calc_c_betas_cmd(Zheader, scan_information, fn, Gheader, pos, pop, model, reg )

if ( nargin < 5 ) pos = 0; end	% --- send pos = 1 to calculate positive values ---
if ( nargin < 6 ) pop = []; end
if ( nargin < 7 ) model = 'G'; end
if ( nargin < 8 ) reg = 0; end

pop = [];

evalc( ['load( ''' fn ''')'] );
GZheader = Gheader;

isROI = strcmp( model, 'ROI' );

if isROI
	load G_ROI
	indexes = load( [ 'ROI' filesep 'data' filesep 'ROI_' num2str(G_ROI.Rindex, '%02d') '_' strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) ] );
	nconds = [];
	nbins =  1;
else
	
	if strcmp( model, 'GA' )
		load( Zheader.Contrast.path );
		nconds =  Aheader.model( Aheader.Aindex).contrasts;
		nbins =  Aheader.model( Aheader.Aindex).bins;
		eval( [ 'GZheader.' model 'Zheader.path_to_segs = Aheader.model( Aheader.Aindex).path_to_' model ';' ] );
	else
		nconds = Gheader.conditions;
		nbins = Gheader.bins;
	end
end


ind = [];
if reg > 0
	R = mask_registrations( scan_information.mask );
	switch reg
		case 1           % Gray Matter includes Brain Stem and Cerebellum
			ind = unique( [ R.ind(1).zref; R.ind(4).zref; R.ind(5).zref ] );
		case 2           % White Matter only
			ind = R.ind(2).zref;
	end
end

	ncomps = size(VR,2);

if nbins > 2
	bin_start = 3;	% --- cut off the first 2 bins in beta calcs
else
	bin_start = 1;
end

% --- to restore full bin length, set this var to 1
% ---------------------------------------------------------
% --- as of V 4.0 C matrix saved as C in GC.mat,        ---
% --- previously B in GB.mat                            ---
% --- B = gg * GZ        = the betas matrix             ---
% --- C = gg * gg * GZ   = for revised svd(C'*C)        ---
% ---------------------------------------------------------

% --= % -----------------------------------
% --= % betas - pos/neg voxels for component flip checking
% --= % -----------------------------------
betas = [];
thrbetas = struct( 'betas', [] );
compbetas = struct( 'threshold', [] );

SubjectVector =  1:Zheader.num_subjects ;

x = exist( 'ep' );
if ( x ~= 1 )   % --= % variable ep does not exist
	ep = calc_ext_Pos_Neg( VR ); % --= % recalculate extreme pos/neg values
end

% if ~isempty(pop)
% 	pop.setIterations( ncomps * size( ep(1).percentiles, 1 ) * Zheader.num_subjects, pop.SECONDARY );
% end

for comp = 1:ncomps

	compbetas.threshold = [];
	
	for thr = 1:size( ep(comp).percentiles, 1 )
		
		thrbetas.betas = [];
		
		threshold = ep(comp).percentiles( thr ).threshold; % --= % top 5% of component weights
		voxels = ep(comp).percentiles( thr).voxels; % --=
		
		% --= ------------------------------------------------
		% --= load the single component
		% --= ------------------------------------------------
		vr_cmp = VR(:,comp);
		
		if ( pos == 1 )
			x = find( vr_cmp > threshold );
		else
			x = find( vr_cmp < ( threshold * -1 ) );
        end
		
		if ( size(x,1) > 1 ) % --= % ensure that there are loadings
			
			Cn = [];
			
			for sn = 1:Zheader.num_subjects
				

				if ~scan_information.isMulFreq	% --- different C retrieval fo meg and fMri sets
					retrieve_subject_C_cmd( Zheader, sn, '', 'Cs', model );
				else
					retrieve_full_subject_C_cmd(Zheader, scan_information, GZheader, sn, 'Cs' );
                end
				
				if ~isempty( ind )
					Cs = Cs( :, ind);
				end
				
				if isempty( nconds )
					nconds = size( Cs, 1 );  % --- set ROI conditions to reduced voxles of ROI
                end
				
				C = Cs(:,x);
				C = mean(C,2 );
				
				if strcmp( model, 'GA' ) | isROI
					msk = 1:size(C,1);
					Cn = [Cn zeros( size(C,1), 1 )];
				else
					msk = encodedIndex_cmd(Zheader, scan_information,  sn );
					Cn = [Cn zeros( nconds*nbins, 1 )];
				end
				Cn(msk(:), size(Cn,2) ) = C;
				
            end
			
			Cn = sum( Cn,2);
			
			if strcmp( model, 'GA' )
				Cn = reshape( Cn, Aheader.model( Aheader.Aindex).bins, Aheader.model( Aheader.Aindex).contrasts ) ./ Zheader.num_subjects ;
				thrbetas.betas = [thrbetas.betas Cn ];
			else
				er = 0;
				for ii = 1:nconds
					sr = er + 1;
					er = sr + nbins - 1;
					ns = encodedCount_cmd(Zheader,scan_information, ii );   %% count of subjects with this condition encoded
					thrbetas.betas = [thrbetas.betas (Cn(sr:er)/ns)];  % mean of the condition for subjects encoded
				end
			end
			
		else  % --= % --- there are no loadings ---
			
			%         if strcmp( model, 'GA' )
			%           thrbetas.betas = zeros( Gheader.contrast_bins,  Gheader.contrasts );
			%         else
			thrbetas.betas = zeros( nbins, nconds );
			%         end
			
        end
		
		compbetas.threshold = [compbetas.threshold; thrbetas ];
		
    end
	
	betas = [betas; compbetas ];
	
end	% --- each component ---


