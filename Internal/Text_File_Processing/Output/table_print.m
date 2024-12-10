% function to print a table into a file
function table_print(f, table, max_coords)
        for c = 1:max_coords+2
           myrow = table{c,:}; 
           for j = 1:size(myrow,2)
              mytry = myrow{j};
              if ~isempty(mytry)
                  if (c == 1 || c == 2 || (mod(j,5)==1))
                    fprintf(f, [mytry '\t']);
                  else
                      fprintf(f, [num2str(mytry) '\t']);
                  end
              else
                  fprintf(f,'\t');
              end
           end
           fprintf(f, '\n');
        end

        fprintf(f,'\n\n');
     end