function R = defined_rule( Rclass, Rlabel, Rname, isProc )
% ---
% ---  process a file containing logical rule calculation definitions
% ---
% ---  Parameters:
% ---      Rclass  : name of the rules class          ( file: Rclass.rul )
% ---      Rlabel  : name of the rules class section  ( [GUI: Panel] )
% ---      Rname   : cell of rule names to parse.  empty cell parses all rules
% ---      isProc  : optional flag indicating to turn all rules off
% ---
% ---  eg:   x = defined_rule( 'Activations', 'Main GUI: System Panel', {} );

  if nargin < 4
    isProc = 0;
  end;
  
  pth = constant_define( 'RULES_PATH' );
  fn = [Rclass '.rul'];
  
  R = read_definition_data( [ pth fn], Rname, Rlabel );

  R = parse_rule( R, isProc );
  

