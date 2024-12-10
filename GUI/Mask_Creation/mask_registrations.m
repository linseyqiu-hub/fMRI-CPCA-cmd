function [reg_data ind] = mask_registrations( msk, reg )

  ind = [];
  
  if nargin < 2,  reg = 0;  end
  
  reg_data.count = [ 0 0 0 0 0 ];
  reg_data.ind = [];
  
  reg_data.ind(1).zref = find( msk.image( msk.ind) == 1 );
  reg_data.count(1)    = numel(  reg_data.ind(1).zref );
  
  reg_data.ind(2).zref = find( msk.image( msk.ind) == 2 );
  reg_data.count(2)    = numel(  reg_data.ind(2).zref );

  reg_data.ind(3).zref = find( msk.image( msk.ind) == 3 );
  reg_data.count(3)    = numel(  reg_data.ind(3).zref );

  reg_data.ind(4).zref = find( msk.image( msk.ind) == 4 );
  reg_data.count(4)    = numel(  reg_data.ind(4).zref );

  reg_data.ind(5).zref = find( msk.image( msk.ind) == 5 );
  reg_data.count(5)    = numel(  reg_data.ind(5).zref );

  switch reg
    case 1,           % Gray Matter includes Brain Stem and Cerebellum
        ind = unique( [ reg_data.ind(1).zref; reg_data.ind(4).zref; reg_data.ind(5).zref ] );
    case 2,           % White Matter only
        ind = reg_data.ind(2).zref;
  end
  
end

