function retrieve_subject_ZH_run( Hheader, SubjectNo, RunNo)
global  Zheader scan_information

if nargin < 3
    ftag = '';
end

Z = [];
H = load_H_matrix( Hheader, SubjectNo );
ZH = [];
if exist([Zheader.Z_Original filesep 'Hsegs'], 'dir') && ...
        exist([Zheader.Z_Original 'Hsegs' filesep 'ZH' filesep 'ZH_S' num2str(SubjectNo) '.mat'], 'file')
    load([Hheader.model(Hheader.Hindex).path_to_segs.ZH filesep 'ZH_S' num2str(SubjectNo) '.mat'], ['ZH_R' num2str(RunNo)])
    eval(['ZH = ZH_R' num2str(RunNo) ';']);
    assignin( 'caller', 'ZH', ZH);
else
    for FrequencyNo=1:max(scan_information.frequencies, 1)
        
        ftag = frequency_tag(FrequencyNo) ;
        
        %------------------------------------------------
        % load in the normalized Z/E segment
        %------------------------------------------------
        
        Zf = load_subject_run_Z( SubjectNo, RunNo, ftag );
        Z = [Z Zf];
        
    end	% --- each frequency range
    
    assignin( 'caller', 'ZH', Z * H );
end
