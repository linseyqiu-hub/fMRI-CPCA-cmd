function calculate_alternate_PR_cmd(Zheader,scan_information, nd, rotation_parms)
% --- N/A pong set true internally


if nargin < 4  rotation_parms = struct( 'model', 'G' );  end

isRotation = isfield( rotation_parms, 'method' );

if ~isfield( rotation_parms, 'defaults' )
    rotation_parms.defaults = [];
end

if isRotation
    dcomponent_directory = fs_path( 'rotated', 'output', nd, 0,  rotation_parms  );
    in_file = fs_filename( 'mat', rotation_parms.model, rotation_parms.method, rotation_parms.defaults );
    Txt = [ upper( rotation_parms.method) ' rotation: ' num2str(nd) ' components . . .'] ;
else
    rotation_parms.defaults = [];
    rotation_parms.method = 'unrotated';
    dcomponent_directory = fs_path( 'unrotated', 'output', nd, 0,  rotation_parms );
    in_file = fs_filename( 'mat', rotation_parms.model, 'unrotated', rotation_parms );
    Txt = sprintf( 'Extracting %d components from GZ', nd );
end

component_directory = [ pwd filesep dcomponent_directory ];
in_file = [component_directory in_file];
eval ( ['load( ''' in_file ''', ''VR'' )' ] );

eval ( ['load( ''' Zheader.Model.path ''', ''Gheader'')' ] );

Sub = 'Calculating Alternate PR . . .';

altPR = struct('pos', [], 'neg', [], 'all', [] );
alternatePR = struct( 'component', [] );

for comp = 1:nd

    printf('Component %s positive\n', num2str(comp));

    component_PR = altPR;
    Zindex = find( VR(:,comp) > 0 );

    if ~isempty( Zindex )

        thisVR = VR(Zindex(:),comp);
        cl = struct( 'PR', [], 'avg', [], 'vox', size(Zindex, 1) );

        cl.PR = alt_pr_cmd(Zheader, scan_information, thisVR, Zindex, Gheader );
        cl.avg = mean(cl.PR,2);
        component_PR.pos = [component_PR.pos; cl];

    end % --- component has positive voxels

    printf('Component %s negative\n', num2str(comp));


    Zindex = find( VR(:,comp) < 0 );
    if ~isempty( Zindex )

        thisVR = VR(Zindex(:),comp);

        cl = struct( 'PR', [], 'avg', [], 'vox', size(Zindex, 1) );

        cl.PR = alt_pr_cmd(Zheader, scan_information, thisVR, Zindex, Gheader );
        cl.avg = mean(cl.PR,2);
        component_PR.neg = [component_PR.neg; cl];

    end % --- component has negative voxels


    thisVR = VR(:,comp);
    Zindex = 1:size(thisVR, 1 );

    cl = struct( 'PR', [], 'avg', [], 'vox', size(Zindex, 2) );

    cl.PR = alt_pr_cmd(Zheader, scan_information, thisVR, Zindex, Gheader );
    cl.avg = mean(cl.PR,2);
    component_PR.all = [component_PR.all; cl];

    alternatePR.component = [alternatePR.component; component_PR];

end  % --- each component

eval ( ['save( ''' in_file ''', ''alternatePR'', ''-append'' )' ] );

meth = 'rotated';
if ~isRotation
    meth = ['un' meth];
end

[hasdir plot_directory] = fs_create_path( meth, 'plots', nd, 0, rotation_parms );
plot_directory = [ pwd filesep plot_directory ];

PR = [];

for comp = 1:size(alternatePR.component, 1 )
    PR = [PR alternatePR.component(comp).all.PR(:) ];
end


disp( 'Producing plots . . .');

meth = strrep( meth, 'non_', 'un' );

theseParms = rotation_parms.defaults;
theseParms.defaults.var = 'HRF';
theseParms.defaults.component = 999;
theseParms.defaults.text = 'Alternate_PR';
out_file = fs_filename( 'txt', rotation_parms.model,rotation_parms.method, theseParms.defaults );

output_HRF_cmd(Zheader, scan_information, component_directory, out_file, PR, Gheader);

plot_HRF_cmd(Zheader, scan_information, plot_directory, PR, Gheader, theseParms );


function PR = alt_pr_cmd(Zheader, scan_information, thisVR, Zindex, Gheader )


PR = [];
%  nbins = Zheader.conditions.sp(1,2);
nbins = Gheader.bins;

% --- load in the individual subject GC & the subject G (normalized)
for subject = 1:Zheader.num_subjects

    subject_PR = struct( 'PR', [] );

    UR = [];
    GC = [];

    ftag = '';
    for RunNo = 1:Zheader.num_runs
        if iscellstr( scan_information.SubjDir(subject, RunNo ) )
            GCr = [];
            for column = 1:Zheader.partitions.count
                eval( [ 'load( ''' Gheader.GZheader.path_to_segs 'GC_S' num2str(subject) '.mat'', ''GC_R' num2str(RunNo) '_C' num2str(column) ftag ''');' ] );
                eval( [ 'GCr = [GCr GC_R' num2str(RunNo) '_C' num2str(column) ftag '];' ] );
                eval( [ 'clear GC_R' num2str(RunNo) '_C' num2str(column) ftag ] );
            end % --- each column

            GC = [GC; GCr(:,Zindex(:) )];

        end  % --- Run is encoded
    end  % --- each Run

    UR = [UR; transpose(thisVR'*GC')];

    eval( [ 'load( ''' Gheader.path_to_segs 'G_S' num2str(subject) '.mat'', ''Gnorm'');' ] );

    PRt = corrcoef( [Gnorm UR] );
    %    PR = [PR PRt(1:size(Gnorm,2),size(Gnorm,2)+1:end) ];
    PRc = [];
    er = 0;
    for cond = 1:size(Zheader.conditions.Names, 2 )

        if isRunEncoded_cmd(Zheader, scan_information,subject, RunNo, cond )
            sr = er + 1;
            er = sr + nbins - 1;
            PRc = [PRc; PRt(sr:er, size(Gnorm,2)+1:end)];
        else
            PRc = [PRc; zeros(nbins, 1 )];
        end

    end
    PR = [PR PRc ];

end % --- each subject


