% ---  Copyright (C) <2010-2013>  Todd S. Woodward Ph.D
% ---                             University of British Columbia
% ---                             Department of Psychiatry
% ---    
% ---  This program is free software: you can redistribute it and/or modify
% ---  it under the terms of the GNU General Public License as published by
% ---  the Free Software Foundation, either version 3 of the License, or
% ---  (at your option) any later version.
% ---
% ---  This program is distributed in the hope that it will be useful,
% ---  but WITHOUT ANY WARRANTY; without even the implied warranty of
% ---  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% ---  GNU General Public License for more details.
% ---
% ---  Licensor makes no representations, conditions or warranties, either
% ---  express or implied, regarding the technology, program or any products.
% ---  
% ---  Without limitation, the licensor specifically disclaims any implied
% ---  warranty, condition or representation that the technology, program or
% ---  any products correspond with a particular description, are of
% ---  merchantable quality, are fit for a particular purpose, or are durable
% ---  for a reasonable period of time.
% ---  
% ---  Licensor is not liable for any loss, whether direct, consequential,
% ---  incidental or special, which the Licensee or other third parties
% ---  suffer arising from any defect, error or fault of the technology,
% ---  program or any products, or their failure to perform, even if licensor
% ---  is aware of the possibility of the defect, error, fault or failure.
% ---  
% ---  The Licensee acknowledges that it has been advised by licensor to
% ---  undertake its own due diligence regarding the technology, program or
% ---  any products.
% ---  
% ---  You should have received a copy of the GNU General Public License
% ---  along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ---

  clear classes  
  clear_java_path();    % --- remove all cpca encoded jar files in case of update
  
  update_java_path();   % --- load any missing java jar files on dynamic path
  clear java

  cpca_gui



