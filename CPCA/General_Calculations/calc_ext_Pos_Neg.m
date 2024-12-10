function epn = calc_ext_Pos_Neg(q, isReducedH) 
% --- 
% --- % Calculate the extreme 1%, 5% and 10% of positive and negative loadings
% Usage: calc_ext_Pos_Neg(VR)
%
% This function will calculate the absolute value of the threshold and number of loadings for each component in VR
% all data returned in the structure epn:
% --- 
% --- % vars = struct (
% --- %   minv, 0,          % Minimum loading for each component
% --- %   maxv, 0,          % Maximum loading for each component
% --- %   percentiles struct (  
% --- %     cutoff, 0,      % 1, 5 or 10 percent cutoff for each component
% --- %     threshold, 0,   % absolute value of threshold for most extreme loadings
% --- %     voxels, 0,      % number of voxels above threshold
% --- %     pos_voxels, 0,  % number of voxels with positive loadings above threshold
% --- %     neg_voxels, 0   % number of voxels with negative loadings below threshold
% --- 

  if nargin < 2  isReducedH = 0; end;
  
  vars = struct ( ...
    'nc', 0, ...
    'minv', 0, ...
    'maxv', 0, ...
    'percentiles', [] );

  pct_vars = struct ( ...
    'cutoff', 0, ...
    'threshold', 0, ...
    'voxels', 0, ...
    'pos_voxels', 0, ...
    'neg_voxels', 0 );

  epn = []; 
  
  % ---------------------------------------
  % calculate
  %----------------------------------------
  [nr nc]=size(q); 
  
  for k=1:nc 
    
    epn = [epn; vars]; 
    
    a = sort( abs( q(:,k) ) );	% --- % vr column sorted by abs value in ascending order
    qs = sort( q(:,k) );		% --- % vr column sorted by actual value in ascending order
%    if isReducedH
%      l = size(find(qs), 1 );	% ---  created H matrices may have most voxels unencoded   
%    else
      l = size(qs,1);			% --- % total number of values in column of V
%    end;
    
    pi = find (qs>0 );			% --- % find the positive values in column of V
    pil = size(pi,1);			% --- % number of positive values in column of V

% --- %    p = qs( (l-pil):l,:);	% this causes problems when l = pil
                                % --- %----------------------------------------
                                % --- % what is being attempted here is to obtain
                                % --- % a list of all the positive values from the 
                                % --- % bottom of the column.  If there are no negative 
                                % --- % values, then the size of l is equal to the size of pil
                                % --- % and the code attempts to access the variable from 
								% --- % (0:size(p1,1), :)
                                % --- %----------------------------------------
    idx = max( l-pil, 1 );		% --- % ensure a non zero index start                             
    p = qs(idx:l,:);			% --- % this will be a list of all the positive values

    ni = find(qs<=0);			% --- % find the negative values in column of V
    nil = size(ni,1);			% --- % number of negative values in column of V

    n = qs(1:nil,:);			% --- % this will be a list of all the negative values

    epn(k).maxv = max(qs);		% --- % the maximum value in column of V
    epn(k).minv = min(qs);		% --- % the minimum value in column of V	

    minimum_loading = epn(k).minv; % --- % which become our minimum
    maximum_loading = epn(k).maxv; % --- % and maximum loading cutoff vars

    for i=1:num_global_thresholds()
 
      epn(k).percentiles = [epn(k).percentiles; pct_vars];
      if is_active_threshold(i)
        epn(k).percentiles(i).cutoff = global_threshold_value(i); 

        if isReducedH
          epn(k).percentiles(i).voxels = round( size(find(qs),1) * (global_threshold_value(i)/100) ) ;
          epn(k).percentiles(i).threshold = a( size(a,1) - epn(k).percentiles(i).voxels); 
        else
          epn(k).percentiles(i).voxels = round( l * (global_threshold_value(i)/100) ) ;
          epn(k).percentiles(i).threshold = a( l - epn(k).percentiles(i).voxels); 
        end;
%        epn(k).percentiles(i).threshold = a( l - epn(k).percentiles(i).voxels); 
        epn(k).percentiles(i).pos_voxels=sum(abs(p)>epn(k).percentiles(i).threshold); 
        epn(k).percentiles(i).neg_voxels=sum(abs(n)>epn(k).percentiles(i).threshold);
      end;

    end; 
  end; 
 


