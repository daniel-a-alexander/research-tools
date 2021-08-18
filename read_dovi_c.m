function data = read_dovi(file_name, zrange)

% Copyright DoseOptics LLC 2017
%
% Reads DOVI data format into Matlab
% @param file_name - File name/location of DOVI file (e.g. 'test.dovi')
% @param zrange - [Optional] Range of slices to load (e.g. [1 40])
% @param data - Output data in Matlab


data = [];

% check inputs
if (length(file_name) < 5)
    return;
end
if (exist(fullfile(pwd, file_name), 'file'))
    file_name = fullfile(pwd, file_name);
end

% load header (dovi)
fs = fopen(file_name);
contents = textscan(fs,'%s');
fclose(fs);
x = 800;
y = 600;
z = 1;
compressed = 0;
cmp_size = 0;
ucmp_size = 0;
scalar_bytes = 2;
block = 0;
for i=1:length(contents{1})
    if (length(contents{1}{i}) > 5)
        if (contents{1}{i}(1:5) == 'dims0')
            x = str2num(contents{1}{i}(7:end));
        end
        if (contents{1}{i}(1:5) == 'dims1')
            y = str2num(contents{1}{i}(7:end));
        end
        if (contents{1}{i}(1:5) == 'dims2')
            z = str2num(contents{1}{i}(7:end));
        end
        if (contents{1}{i}(1:5) == 'block')
            block = str2num(contents{1}{i}(7:end));
        end
        if (length(contents{1}{i}) > 11)
            if (contents{1}{i}(1:11) == 'compressed=')
                compressed = str2num(contents{1}{i}(12));
            end
        end
        if (length(contents{1}{i}) > 15)
            if (contents{1}{i}(1:15) == 'compressed_size')
                cmp_size = str2num(contents{1}{i}(17:end));
            end
        end
        if (length(contents{1}{i}) > 17)
            if (contents{1}{i}(1:17) == 'uncompressed_size')
                ucmp_size = str2num(contents{1}{i}(19:end));
            end
        end
        if (length(contents{1}{i}) > 12)
            if (contents{1}{i}(1:12) == 'scalar_bytes')
                scalar_bytes = str2num(contents{1}{i}(14:end));
            end
        end
    end
end
z=1;
compressed = false;
fn_new = [file_name(1:end-5) '_c.raw'];



% load data
if (~exist(fn_new, 'file'))
    return;
end
fs = fopen(fn_new);

data = fread(fs, [x,y], 'uint32');
fclose(fs);
data = uint32(reshape(data, x, y, 1));
data = permute(data, [2 1 3]);

% cleanup
% if (compressed)
%     delete(fn_new);
% end

