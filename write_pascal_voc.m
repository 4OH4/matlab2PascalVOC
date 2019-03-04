% Rupert Thomas
% Feb 2019
% MIT License

% MATLAB interface to generate Pascal VOC-style labelled datasets.
% Requies "Annotation.m" and "pascal_voc_annotation_template.xml"
% These additional files are derived from work by Andrew Carter: 
% "pascal-voc-writer" (for Python)
% https://github.com/AndrewCarterUK/pascal-voc-writer

% The script expects to load a MATLAB (.mat) datafile, called `bounding_box_data.mat`, that contains a 
% table (also called `bounding_box_data`). The first column is `file_name`, which contains just the
% filename or relative path within the `images_folder`. The remaining columns are named with the class_index
% names, and contain bounding box data in the MATLAB ROI format as arrays: [x y w h].

root = 'C:\images';
dataset_folder = 'dataset1';
images_folder = 'all_images';
annotations_output_folder = 'annotations';
annotation_source_filename = 'bounding_box_data.mat';
annotation_table_name = 'bounding_box_data';

% addpath('matlab2PascalVOC')  % if this repository is contained within a subfolder, add it to the path

% Create annotations output directory, if it does not exist already
annotations_output_path = (fullfile(root, dataset_folder, annotations_output_folder));
if ~exist(annotations_output_path, 'dir')
    mkdir(annotations_output_path);
end

% Load the source data
load(fullfile(root, dataset_folder, annotation_source_filename), annotation_table_name)
classes = bounding_box_data.Properties.VariableNames(2:end);

%% Build the annotations, and write to file

for row_index = 1:height(bounding_box_data)
% parfor row_index = 1:height(bounding_box_data)  % if you have the Parallel Processing toolbox, use this instead
    
    file_path = bounding_box_data{row_index, 'file_name'}{1};
    img = imread(file_path);    
    [height, width, depth] = size(img);  % we need the image dimensions, so have to load each image as well
    [~, filename] = fileparts(file_path);
    
    % Build the annotation with basic information
    annotation = Annotation(file_path, width, height, depth);
    
    % Add each of the bounding boxes to the annotation file
    for class_index = 1:length(classes)
        class_label = classes{class_index};      
    
        %Get the ROI (set or sets) from the label data
        this_block= bounding_box_data{row_index,class_label};
        this_block = this_block{1}; % get out of cell form
        
        for annotation_index = 1:size(this_block,1)
            
            xmin = this_block(annotation_index, 1);
            ymin = this_block(annotation_index, 2);
            xmax = xmin + this_block(annotation_index, 3);
            ymax = ymin + this_block(annotation_index, 4);
            
            annotation = annotation.addObject(class_label, xmin, ymin, xmax, ymax);
            
        end
    end
    
    % Write the annotation record file
    annotation.write(fullfile(annotations_output_path, [filename, '.xml']));
end

