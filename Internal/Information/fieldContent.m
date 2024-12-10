function v = fieldContent( structure, fld, def)
% --- return the content of an existing filed in a structure, or a default
% --- value if the field is not present
% ---  structure:  the structure data - eg S.public
% ---  fld      : name of the field   - eg 'putNumber'
% ---  def      : default value for return

  v = def;
  
  if isfield( structure, fld )
      eval( [ 'v = structure. ' fld ';' ] );
  end
  

end

