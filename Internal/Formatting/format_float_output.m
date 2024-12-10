function [res ttl bns lin] = format_float_output( vals, dec, sz, txt)
  % --- to precalculate the section size, ie to set up multiple section titles
  % --- numvars * strlen per var  + numvars (single char pad)

  if nargin < 2  dec = 2; end;
  if nargin < 3  sz =  8; end;
  if nargin < 4  txt = ''; end;

  if size( vals,2) > size(vals,1)
    vals = vals';
  end;

  op = '';
  res = [];	% --- the  formatted values
  ttl = [];	% --- any centered section title
  bns = [];	% --- bin numbers as column headers
  lin = [];	% --- separator line '----'

  fmtnum = ['%.' num2str(dec) 'f'];
  fmtstr = ['\t%' num2str(sz) 's'];

  for ii = 1:size(vals,1)
    x = num2str( vals(ii), fmtnum);
    op = sprintf( fmtstr, x );
    res = [res op ' '];
  end;

  sectionSz = size(res,2);
  ttl = center_text( txt, sectionSz );

  for ii = 1:size(vals,1)
    x = num2str(ii);
    op = sprintf( fmtstr, num2str(ii) );
    bns = [bns op ' '];
  end;

  for ii = 1:sectionSz
    lin = [lin '-'];
  end

