function data = cdose_read(pathname, options)
%{
    this function will create a struct with images for all c-dose folders in
    the path
    
INPUTS:
    pathname -              string to folder containg all the data folders
    
    name value pairs
    's_value' -         	takes a string; use 's0' for background frames of if custom mode, for cherenkov frames in
                            cherenkov mode use 's1'. Default is 's0'.
    
    'cam' -               	takes a string; 'cam0' or 'cam1' Default is
                          	'cam0'.
    
    'method' -            	takes a string; to read in with summed images, or
                         	averaged images, use 'sum', or 'mean'. Default is 'sum'.
    
    'names' -            	takes cell array of char vectors containing
                         	field names for output struct. Must match number of folders in
                          	pathname. default uses descriptions in the folders.
OUTPUTS:
    data -                  structure containing fields specified by 'names' with images.
                
    by Dan Alexander, 2020
%}
    arguments
        pathname char
        options.s_value char = 's0'
        options.cam char = 'cam0';
        options.method char = 'sum';
        options.names (1,:) cell = {};
    end
    
    data = struct();
    folders = dir(pathname);
    folders = folders(3:end); % first two entries are meaningless

    f = waitbar(0, 'Loading Data.....');
    pause(0.2)
    N = numel(folders);
    
    if isfield(options, 'names') == 1 
        firstletters = 0;
        for i=1:size(options.names, 2)
            temp = options.names{i};
            if ~isletter(temp(1))
                firstletters = firstletters + 1;
            end
        end
        if size(options.names, 2) ~= N
            disp('Error: not enough names')
            return
        elseif firstletters ~= 0
            disp('Error: names must all start with letters, no numbers/symbols allowed')
            return
        end
    end
    
    for i=1:N
        folder_contents = dir(fullfile(folders(i).folder, folders(i).name)); % check contents of this folder
        m = {folder_contents.name}; % make cell array of content names
        
        if sum(strcmp('settings.ini', m)) % check if folder has a settings.ini file
            info = ini2struct(fullfile(folders(i).folder, folders(i).name, 'settings.ini')); % get contents of settings.ini file
            desc = info.general.description; % get the description
            
            if isfield(options, 'names') == 1 
                name = options.names{i};
            elseif ~isletter(desc(1))
                name = ['f_', desc];
            else
                name = desc;
            end

            if strcmp(options.method,'mean')
                data.(name) = mean(read_dovi([fullfile(folders(i).folder, folders(i).name), '/meas_',options.s_value,'_',options.cam,'.dovi']), 3);
            elseif strcmp(options.method,'sum')
                data.(name) = sum(read_dovi([fullfile(folders(i).folder, folders(i).name), '/meas_',options.s_value,'_',options.cam,'.dovi']), 3);
            end
            

        end
        waitbar(i/N, f, 'Loading Data.....');

    end
    
    close(f)
end