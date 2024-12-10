function txt = get_control_text( ct, nm )

  txt = '';
  if isempty(nm)  return; end;

  if ( ~isempty(ct) )
    for ii = 1:size(ct, 1)
      if strcmp( ct(ii).control, nm )
        txt = ct(ii).text;
        return;
      end;
    end;
  end;

