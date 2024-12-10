function txt = center_text( thistext, sz )

  padding = sz - size(thistext,2);
  p = floor(padding/2);
  p = [p padding - p];

  txt = [];
  for ii = 1:p(1)
    txt = [txt ' '];
  end
  txt = [txt thistext];
  for ii = 1:p(2)
    txt = [txt ' '];
  end

