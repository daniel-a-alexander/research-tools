
function data = read_dovi_v2(filepath, varargin)
% Copyright DoseOptics LLC 2021

% INPUTS
% Required:
% filepath - File name/location of DOVI file (e.g. 'meas_cam0.dovi')

% Name-Value Pairs (optional):
% 'channel': 'chkv' (default) or 'bkgd' for cherenkov or background
% 'zrange': specify range of slices to load (e.g. [1 40])
% 'cumulative': 0 (default) reads in 8-bit video frames, 1 reads in 32-bit raw cumulative.


% OUTPUT
% data - Output data stored in a 16-bit (X x Y x Z) matrix for video, or
% 32-bit (X x Y) matrix for cumulative

    if (~exist(filepath, 'file'))
        error('dovi file not found')
    end
    
    options = struct();
    options.channel     = 'chkv';
    options.zrange      = 0;
    options.cumulative  = 0;
    optionNames = fieldnames(options);
    
    % count arguments
    nArgs = length(varargin);
    if round(nArgs/2)~=nArgs/2
       error('EXAMPLE needs propertyName/propertyValue pairs')
    end
    
    for pair = reshape(varargin,2,[]) % pair is {propName;propValue}
       inpName = lower(pair{1}); % make case insensitive
    
       if any(strcmp(inpName,optionNames))
          options.(inpName) = pair{2}; % overwrite options 
       else
          error('%s is not a recognized parameter name',inpName)
       end
    end
    
    if options.cumulative == 0
    
        mp4filepath = [filepath(1:end-5), '.mp4'];
        if (~exist(mp4filepath, 'file'))
            error('Video data file (mp4) not found')
        end
        v = VideoReader(mp4filepath); % prep video reader
    
        if options.zrange == 0
            temp = uint8(read(v)); % Read in all frames from sub
        elseif isequal(size(options.zrange),[1,2]) && isa(options.zrange, 'double')
            temp = uint8(read(v, options.zrange)); % Read in all frames from sub
        else
            error('zrange parameter must be a 1x2 double')
        end
    
        if strcmp(options.channel, 'chkv')
            data = squeeze(temp(:,:,2,:));
        elseif strcmp(options.channel, 'bkgd') || strcmp(options.channel, 'custom')
            data = squeeze(temp(:,:,3,:));
        else
            error('channel paramenter must be either ''chkv'', ''bkgd'', or ''custom''')
        end
    
    elseif options.cumulative == 1
    
        % load header (dovi)
        fs = fopen(filepath);
        contents = textscan(fs,'%s');
        fclose(fs);
        x = 800;
        y = 600;
        
        for i=1:length(contents{1})
            if (length(contents{1}{i}) > 5)
                if (contents{1}{i}(1:5) == 'dims0')
                    x = str2double(contents{1}{i}(7:end));
                end
                if (contents{1}{i}(1:5) == 'dims1')
                    y = str2double(contents{1}{i}(7:end));
                end
                if (contents{1}{i}(1:5) == 'dims2')
                    z = str2double(contents{1}{i}(7:end));
                end
            end
        end
    
        if strcmp(options.channel, 'chkv')
            fn_new = [filepath(1:end-5) '_s1_c.raw'];
        elseif strcmp(options.channel, 'bkgd')
            fn_new = [filepath(1:end-5) '_s0_c.raw'];
        else
            error('channel paramenter must be either ''chkv'' or ''bkgd''')
        end
        
        if (~exist(fn_new, 'file'))
            error('cumulative raw file not found')
        end
        fs = fopen(fn_new);
        data = fread(fs, [x,y], 'uint32');
        fclose(fs);
        data = uint32(reshape(data, x, y, 1));
        data = permute(data, [2 1 3]);
    
    else
        error('cumulative paramenter must be either 0 or 1')
    end

end