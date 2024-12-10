function pth = study_regression_path( module, mode, src )
% --- determine the path to the GZ data directory for the study module 
% --- 
% ---  module:   the processing model type, G ROI BH GMH
% ---  mode:      secondary processing type
% ---  src:       additional info for final determination
% ---
% ---        module    mode              src
% ---           G:  [ A | AA ]          [n/a]
% ---           BH: [ A | AA ]          data source: [ Z | E ]
% ---          GMH: [ GMH | BH | GC ]   [n/a]
% ---          ROI: [n/a                [n/a]
% ---               
global Zheader

  if nargin < 1,     module = 'G';   end;
  if nargin < 2,     mode = '';      end;
  if nargin < 3,     src = '';       end;
  
  pth = [];
  load( Zheader.Model.path, 'Gheader' );
  
  switch module
      
      case 'G', 
          if isempty( mode )
            pth = Gheader.GZheader.path_to_segs;  
          else
            load( Zheader.Contrast.path );
            eval( [ 'pth = Gheader.' model 'Zheader.path_to_segs;' ] );
          end
          return;  

      case 'BH', 
           if isempty( mode )
            eval( [ 'pth = Hheader.model( Hheader.Hindex).path_to_segs.' module ';' ] );
            pth = Gheader.GZheader.path_to_segs;  return;  
            
          else
            load( Zheader.Contrast.path );
            eval( [ 'pth = Aheader.model( Aheader.Aindex).path_to_' [ src 'H'] ';' ] );
          end
          return;  

      case 'GMH', 
          load( Zheader.Limits.path );
          eval( [ 'pth = Hheader.model( Hheader.Hindex).path_to_segs.' mode ';' ] );
          return;  

      case 'ROI', 
          load G_ROI
          pth = [ 'G' filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep 'GZsegs'];
          return;  

  end
  
  
% % --- start   
%   if strcmp( module, 'ROI' )
%     Gpath = Gheader;
%     
% % ---
%   noParms = struct( 'model', 'G', 'reg', reg, 'regTag', char( regTags(reg+1)  ) );
%   if isROI
%     load G_ROI
%     noParms.hindex = strrep( [ filesep 'ROI' filesep G_ROI.mask( G_ROI.Rindex).id ], ' ', '_' );
%     noParms.model = 'G';
%     noParms.ROIGZ = [ noParms.model filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep 'GZsegs'];
% 
%     indexes = load( [ 'ROI' filesep 'data' filesep 'ROI_' num2str(G_ROI.Rindex, '%02d') '_' strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) ] );
% 
%   [has_dir component_directory] = fs_create_path( 'unrotated', 'output', nd, 0, noParms );
%        Gheader.ROIZheader.path_to_segs = [ 'GZsegs' filesep 'ROI' filesep strrep( G_ROI.mask( G_ROI.Rindex).id, ' ', '_' ) filesep ];
%    
%   end;
% 
% % ---
%   else
%     if ~strcmp( model, 'G' )
%       load( Zheader.Contrast.path );
%       eval( [ 'Gpath = Aheader.model( Aheader.Aindex).path_to_' model ';' ] );
%     else
%       eval( [ 'Gpath = Gheader.' model 'Zheader.path_to_segs;' ] );
%     end
%   end
%   
% % --- BH
%   if strcmp( module, 'BH' ) || strcmp( module, 'GC' ) 
%     p = 'GMH';
%     if strcmp( module, 'BH' )
%       module = 'HnotG';
%     end
%   else
%     p = module;
%   end;
% 
%   % --- non module name files will be passed as optional variable
%   % --- module path will retain original module definition in pth
%   if nargin == 5
%     module = ex_var;
%   end;
%   
% % --- GMH  
%   eval( [ 'pth = Hheader.model( Hheader.Hindex).path_to_segs.' p ';' ] );
% 

end


