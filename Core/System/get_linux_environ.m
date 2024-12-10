function env = get_linux_environ()
% ---
% --- retrieve Linux environment variables for root checks, sudo operations etc...

env = structure_define( 'env_struct' );
envcmd = 'set';

a = evalc( '!set | grep tcsh' );  % --- determine if running csh
if ~isempty(a),   envcmd = 'env'; end

a = evalc( ['!' envcmd ' | grep USERNAME= | grep -v BASH' ] );
if ~isempty(a)
  a = regexp( a(1:length(a)-1), '=', 'split') ;
  env.username = char(a(2));
end;

a = evalc( ['!' envcmd ' | grep USER= | grep -v BASH | grep -v SUDO' ] );
if ~isempty(a)
  a = regexp( a(1:length(a)-1), '=', 'split') ;
  env.user = char(a(2));
end;

a = evalc( ['!' envcmd ' | grep SUDO_USER= | grep -v BASH' ]) ;
if ~isempty(a)
  a = regexp( a(1:length(a)-1), '=', 'split') ;
  env.sudouser = char(a(2));
end;

env.isSudo = ~isempty( env.sudouser ) || ...
  ~isempty( env.user ) && ~isempty( env.username ) && ~strcmp( env.username, env.user );

env.isRoot = strcmp( env.username, 'root' ) || strcmp( env.user, 'root' );

if isempty( env.sudouser ) && env.isSudo
  if ~strcmp( env.user, 'root' )
    env.sudouser = env.user;
  else
    env.sudouser = env.username;
  end;
end;


