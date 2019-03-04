# matlab2PascalVOC
Converter to output Pascal VOC-style image annotations from MATLAB labelled image data. Derived from the Python equivalent `pascal-voc-writer` by Andrew Carter: https://github.com/AndrewCarterUK/pascal-voc-writer

## Usage
    annotation = Annotation(path, width, height, [depth], [database], [segmented])
    annotation.addObject(name, xmin, ymin, xmax, ymax, [pose], [truncated], [difficult])
    annotation.write(output_filepath)

You can also use the `write_pascal_voc.m` script - be sure to set the configuration parameters at the top of the file to match your setup (folder names, paths, file names etc).
