


function data = cdose_read(pathname, s_value, method, cam)
    % this function will create a struct with images for all c-dose folders in
    % the path
    
    % pathname -            string to folder containg all the data folders
    
    % s_value -             takes a string; use 's0' for background frames of if custom mode, for cherenkov frames in
    %                       cherenkov mode use 's1'

    % method -              takes a string; to read in with summed images, or averaged images, use 'sum', or 'mean'
    
    % cam -                 takes a string; 'cam0' or 'cam1'
    % by Dan Alexander, 2020
    
    data = struct();
    folders = dir(pathname);
    folders = folders(3:end); % first two entries are meaningless
    

    for i=1:numel(folders)
        folder_contents = dir(fullfile(folders(i).folder, folders(i).name)); % check contents of this folder
        m = {folder_contents.name}; % make cell array of content names
        if s_value == 's1' && sum(contains(m, 'meas_s1')) == 0 % means this folder is custom mode
            s_value_temp = 's0';
        else
            s_value_temp = s_value;
        end
        
        if sum(strcmp('settings.ini', m)) % check if folder has a settings.ini file
            info = ini2struct(fullfile(folders(i).folder, folders(i).name, 'settings.ini')); % get contents of settings.ini file
            desc = info.general.description; % get the description
            if ~isletter(desc(1))
                name = ['f_', desc];
            else
                name = desc;
            end
            
            if info.general.saveimage == '0'
                disp('Reading dovi...');
                if strcmp(method,'mean')
                    data.(name) = mean(read_dovi([fullfile(folders(i).folder, folders(i).name), '/meas_',s_value_temp,'_',cam,'.dovi']), 3);
                elseif strcmp(method,'sum')
                    data.(name) = sum(read_dovi([fullfile(folders(i).folder, folders(i).name), '/meas_',s_value_temp,'_',cam,'.dovi']), 3);
                end
            elseif info.general.saveimage == '1'
                data.(name) = double(imread([fullfile(folders(i).folder, folders(i).name), '/meas_',s_value_temp,'_',cam,'.png']));
            end
        end
        disp([num2str(100*i/numel(folders), '%.2f'), ' % complete']);
    end
    
    
    
    