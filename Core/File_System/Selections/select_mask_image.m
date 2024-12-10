function [msk cancelled] = select_mask_image( filespec, title )
% show a select file dialog box
%
% select_image will also check for the existance of an
% associated .hdr file.  Without an .hdr file in the same directory
% SPM functions will abort with errors.
%
% return filename as full path
global scan_information

std_hdr_size = 348;
std_hdr_flag = 344;

m = struct( ...
    'file', '', ...			% mask filename
    'header', '', ...			% mask header filename
    'x', 0, ...				% mask dimension x
    'y', 0, ...				% mask dimension y
    'volume', struct ( ...		% mask volume data
    'dimensions', [], ...		% dimension x y z
    'data_type', '', ...		% data type ( in text uint8/16 etc..)
    'nan_rep', 0, ...			% data type as nan representation
    'transform_matrix', [], ...	% mask transform matrix
    'plane_info', [] ) ...		% mask slice/plane info
    );

cancelled = 0;
image = 0;
msk = [];

[fn, path] = uigetfile(filespec, title );

if isequal(fn,0) || isequal(path,0)
    cancelled = 1;
else
    
    m.file = [path fn];
    
    msk = cpca_read_vol( m.file );
    if ( isempty( image ) )
        show_message( 'Image Read Error', hdr.error );
        cancelled = 1;
        return;
    end;
    
    msk.file = [path fn];
    
end;



