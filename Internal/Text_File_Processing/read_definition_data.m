function [ out_vars ] = read_definition_data( def_file, vars, section )
%[ out_vars ] = read_definition_data( def_file, vars, section )
% read a textual data definition file
% if section is empty or not given  will default to 
%   first discovered section definition in file or 
%   entire file if no section definitions contained in file 
%   section definitions defined by [ name ]
%
%  vars:
% an array of cells will locate only specified variable within section
% an empty varlist will locate all valid variable in section
%

  % --- if no section to read clarified, set as null
  if nargin < 3
    section = '';
  end
  
  comment = '%#';                   % --- list of line comment characters
%  section_delimiter = '[';
  
  out_vars = struct( 'nvars', 0, 'vars', [] );
  % --- variable names to read must be an array of cells
  if ~isempty( vars )
    if ~iscell( vars )    
      out_vars = [];
      return;
    end;
  end
  
  num2read = max( size( vars ) );

  for ii = 1:num2read
    eval( [ 'out_vars.vars.' strrep( char(vars(ii) ), ' ', '_' ) ' = [];' ] );
  end
  
  input = fopen(def_file, 'r');

  if input
    
    in_section = 0;                 % --- flag to set when section found
    
    if isempty( section )           % --- determine if sections defined in file
      section_found = 0;
      while ~feof( input )
        ln = strtrim( fgetl( input ) );
        if ~isempty( ln )
          if iscell(ln)
            ln = char(ln);
          end;
          
          if ln(1) == '['
            section_found = 1;  
            section = strtrim( ln(2:end-1) );
            break;
          end
        end  % --- input line length > 0
      end  % --- ?? feof() ??
      
      frewind( input );
      in_section = ~section_found;    
    end
    
    
    while ~feof( input )

      def = '';
      val = '';
      
      ln = strtrim( fgetl( input ) );
      
      if ~isempty( ln )
        if iscell(ln)
          ln = char(ln);
        end;
          
        if isempty(strfind( comment, ln(1) ))

          if ~in_section            % --- locate section
            if ln(1) == '[';
              in_section = strcmp( section, strtrim( ln(2:end-1) ) );
            end
            
          else                      % --- within section

            if ln(1) == '[';
              break;                % --- section terminated
            end
              
            ln = regexp( ln, ':', 'split' );

            def = strtrim(char(ln(1) ));
      
            if size( ln, 2 ) > 1
              val = strtrim( char(ln(2)) );
            end;
      
            if num2read > 0         % --- specific variables to read
              for ii = 1:num2read

                if strcmp( def, char(vars(ii) ) )
                  def = strrep( def, ' ', '_' );
                  eval( [ 'out_vars.vars.' def ' = ''' val ''';' ] );
                  out_vars.nvars = out_vars.nvars + 1;
                end;
              end

              if out_vars.nvars == num2read
                fclose( input );
                return
              end;
              
            else                    % --- read all section variables

              def = strrep( def, ' ', '_' );
              
              if isfield( out_vars.vars, def )    % see if this is a concatenated field
                x = [];
                eval( [ 'x = size(out_vars.vars.' def ');' ] );
                if x(1) > 0
                  if x(1) == 1
                    eval( [ 'out_vars.vars.' def ' = {out_vars.vars.' def '};' ] );
                  end
                  eval( [ 'out_vars.vars.' def ' = [ out_vars.vars.' def '; {''' val '''}];' ] );
                end
              else
                eval( [ 'out_vars.vars.' def ' = ''' val ''';' ] );
                out_vars.nvars = out_vars.nvars + 1;
              end
                
            end                 
            
          end  % --- section determination
          
        end  % --- input line not commented out
        
      end  % --- input line length > 0

    end  % --- ?? feof() ??
    
    fclose( input );
    
  end  % --- input file opened

