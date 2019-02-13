% Rupert Thomas
% Feb 2019
% MIT License

% MATLAB interface to generate Pascal VOC-style labelled datasets.
% Heavily based upon "pascal-voc-writer" (for Python) by Andrew Carter
% https://github.com/AndrewCarterUK/pascal-voc-writer

% Usage:
% annotation = Annotation(path, width, height, [depth], [database], [segmented])
% annotation.addObject(name, xmin, ymin, xmax, ymax, [pose], [truncated], [difficult])
% annotation.write(output_filepath)

classdef Annotation
    % Pascal VOC-style annotation for a single image (containing multiple
    % marked objects)
    
    properties
        
        data
        objects = {};
        annotation_xml_filename = 'pascal_voc_annotation_template.xml';
        annotation_xml
        
    end
    
    methods
        function self = Annotation(path, width, height, depth, database, segmented)
            % Constructor - take in the base parameters, (not the object
            % bounding box definitions)
            
            self.data = containers.Map({'path', 'width', 'height'}, {path, width, height});
            
            [filepath, filename, ext] = fileparts(path);
            [~, parentFolderName] = fileparts(filepath) ;
            self.data('filename') = [filename ext];
            self.data('folder') = parentFolderName;
            
            % defaults
            if nargin>3
                self.data('depth') = depth;
            else
                self.data('depth') = 3;
            end
            if nargin>4
                self.data('database') = database;
            else
                self.data('database') = 'Unknown';
            end
            if nargin>5
                self.data('segmented') = segmented;
            else
                self.data('segmented') = 0;
            end
                        
        end
        
        function self = addObject(self, name, xmin, ymin, xmax, ymax, pose, truncated, difficult)
            % Add an object annotation
            this_object = containers.Map( ...
                {'name', 'xmin', 'ymin', 'xmax', 'ymax'}, ...
                {name, xmin, ymin, xmax , ymax});
            
            % defaults
            if nargin>6
                this_object('pose') = pose;
            else
                this_object('pose') = 'Unspecified';
            end
            if nargin>7
                this_object('truncated') = truncated;
            else
                this_object('truncated') = 0;
            end
            if nargin>8
                this_object('difficult') = difficult;
            else
                this_object('difficult') = 0;
            end
            
            self.objects = [self.objects; {this_object}];
            
        end
        
        function template = fill_template_with_data(~, template, data_map)            
            % replace the template elements with data
            
            k = keys(data_map);
            v = values(data_map);
            
            for i = 1:length(data_map)
                
                search_term = ['{{ ' k{i} ' }}'];
                if ~contains(template, search_term)
                    warning(['Could not find field: ', search_term]);
                end
                
                replace_val = v{i};
                if ~isa(replace_val, 'char'); replace_val = num2str(replace_val); end
                
                template = strrep(template, search_term, replace_val);
                
            end
            
        end
        
        function self = write(self, output_filepath)
            % Format the output, and write to file
            
            % Get the template
            self.annotation_xml = fileread(self.annotation_xml_filename);
            
            % replace the main template elements
            self.annotation_xml = self.fill_template_with_data(self.annotation_xml, self.data);
                        
            % extract the object node            
            object_node_search_term = '<object>.*</object>';            
            [startIndex,endIndex] = regexp(self.annotation_xml,object_node_search_term);
            
            object_node_template = self.annotation_xml(startIndex:endIndex);
            
            % build the object annotation
            object_xml = '';
            for object_idx = 1:length(self.objects)

                this_object_text = self.fill_template_with_data(object_node_template, self.objects{object_idx});

                object_xml = [object_xml, this_object_text newline];
    
            end
            
            self.annotation_xml = regexprep(self.annotation_xml, object_node_search_term, object_xml);
            
            fileID = fopen(output_filepath,'w');
            fprintf(fileID,'%s', self.annotation_xml);
            fclose(fileID);
            
        end
        
    end
end