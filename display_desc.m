
% This function displays the c-dose description for every data folder in the path
% Written by Dan Alexander, 2019

function display_desc(pathname) %path to study folder (should contain all the acquisition folders within)

    folders = dir(pathname);
    folders = folders(3:end); % first two entries are meaningless

    for i=1:numel(folders)
        folder_contents = dir(fullfile(folders(i).folder, folders(i).name)); % check contents of this folder
        m = {folder_contents.name}; % make cell array of content names
        if sum(strcmp('settings.ini', m)) % check if folder has a settings.ini file
            info = ini2struct(fullfile(folders(i).folder, folders(i).name, 'settings.ini')); % get contents of settings.ini file
            desc = info.general.description; % get the description
            disp([folders(i).name,':  ', desc]) % display folder and description
        end
    end
end