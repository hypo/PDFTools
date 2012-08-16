# PageComposer

Command line tool running under Mac OS X to generate the PDF or png.

## Usage

PageComposer consumes custom file format `*.pcd` either from `STDIN`:

    ./PageComposer < stdin.pcd

or a file:

    ./PageComposer file.pcd

You can also provide output file name with `-o` option instead of the path in pcd like this:

    ./PageComposer -o output.pdf file.pcd

## PCD Format

The PCD format specify a graphic context whose coordinate system places the origin at bottom left.

You can use quotation mark (") to specify string containing space or tab.
The following are legal string literals:

* `simplestring`
* `"string contains spaces"`
* `"string contains escaped \"quotation\", tab(\t) and backslash(\\)"`

### Produce blank PDF file:

    beginpdf [width] [height]  # in point (1/72 inche)
    endpdf file://[/path/to/output.pdf]

----

### Produce transparent PNG file:

    beginpdf [width] [height]
    endpng [dpi] [scale] file://[/path/to/output.png] 
    # Normally (dpi, scale) is (72, 1). You could scale up.

----

### Draw a image on PDF:

    beginpdf 720 720

    simpleimage [url_to_image] [x] [y] [w] [h]
    # The origin is at the left bottom.
    # Draw the image and strech to fill the rect define by (x, y, w, h)
    # image could be jpg/png/pdf.

    ## DPI limitation ##
    set MaxDPI [dpi]
    # Limit the max DPI. If the file is too large, it will scale down according to the MaxDPI specified.
    # Only applied to jpg/png.
    # Only affect the next draw image command.

    ## Content rotation ##
    set ContentRotation [clockwise|counter-clockwise|half]
    # Rotate the image first.
    # Currently only support jpg/png.
![rotate](https://github.com/hypo/PDFTools/raw/master/Documents/rotate_order.png)

    ## Rounded corner ##
    set radius [r]
    # Draw the next simpleimage with [r] point radius rounded corner.
    # Only affect the next draw image command.

    simpleimage image_a x_a y_a w_a h_a
    simpleimage image_b x_b y_b w_b h_b
    # Hence, image_a has r points radius rounded corner with MaxDPI limit.
    # image_b doesn't have rounded corner and no DPI limit.

    ## Crop source image ##
    image [url_to_image] [from_x] [from_y] [from_w] [from_h] [x] [y] [w] [h]
    # Crop image from rect (from_x, from_y, from_w, from_h) and draw to (x, y, w, h)
    # If from_x, from_y, from_w, from_h is of the form "[xX*][0-9\.]+", for example, x0.01, *0.5
    # Then the actual cropping rect will be 
    # from_x * image_width, from_y * image_height, from_w * image_width, from_h * image_height
    # Currently only support PNG and JPEG. PDF not yet support crop.
![coordinate](https://github.com/hypo/PDFTools/raw/master/Documents/coordinate.png)


    ## JPEG compression ##
    simpleimage_compress [url_to_image] [compress_ratio] [x] [y] [w] [h]
    # Only allows JPEG image.
    # The compress_ratio is between 0.0 ~ 1.0, where 0.0 results max compression, 1.0 results no compression.

    image_compress [url_to_image] [compress_ratio] [from_x] [from_y] [from_w] [from_h] [x] [y] [w] [h]
    # Crop image from rect (from_x, from_y, from_w, from_h) and draw to (x, y, w, h)
    # Currently only support PNG and JPEG. PDF not yet support crop.

    endpdf file:///path/to/output.pdf

----

### Fill a rect with color:

    beginpdf 720 720

    simplecolor [color_name] [x] [y] [w] [h]
    # color_name can be:
    # - 0xRRGGBB : range from 0x000000 to 0xFFFFFF
    # - CMYK:C,M,Y,K[,A] : each channel ranges from 0.0 to 1.0. Alpha could be omitted. 
    # - clear, none, transparent : clear color
    # - brown, cyan, darkgray, gray, green, lightgray, magenta, orange, purple, blue, red, yellow, white : to corresponding NSColor.
    # - 50k            : CMYK:0.00, 0.00, 0.00, 0.50
    # - cheese         : CMYK:0.00, 0.13, 0.90, 0.00
    # - grass          : CMYK:0.35, 0.00, 1.00, 0.00
    # - chestnut       : CMYK:0.00, 0.09, 0.50, 0.24
    # - darkgreen      : CMYK:0.32, 0.00, 1.00, 0.79
    # - olive          : CMYK:0.27, 0.00, 0.95, 0.55
    # - christmasred   : CMYK:0.00, 0.90, 0.86, 0.00
    # - hypo-black     : CMYK:0.10, 0.10, 0.10, 1.00
    # - hypo-lightgray : CMYK:0.10, 0.10, 0.10, 0.60
    # - hypo-ticketgray: CMYK:0.05, 0.05, 0.05, 0.30

    endpdf file:///path/to/output.pdf

----

### Draw a barcode:

    beginpdf 720 720
    barcode [x] [y] [w] [h] [string]
    # draw the Code39 barcode in rect

    endpdf file:///path/to/output.pdf

----

### Draw a string without wrapping:

    beginpdf 720 720
    simpletext [x] [y] [string]
    # Draw the string whose baseline begins at (x, y).
    # Notice: no attribute will be applied. Just plain text.
    endpdf file:///path/to/output.pdf

----

### Draw a string with options:

    beginpdf 720 720
    set FontSize 10 #pt
    set FontSizeCJK 10 #pt
    set Typeface "Font Name"
    set TypefaceCJK "CJK Font Name"
    set TextAlign [left|center|right]
    set TextVerticalAlign [top|center|middle|bottom|bottom-baseline:10]
    
    set BaselineOffset 0.5 #pt
    set BaselineOffsetCJK 0.5 #pt
    set Kerning #pt
    set KerningCJK 1 #pt
    set LineSpacing 1 #pt
    set Color 0x336699 #color string
    set LineHeight 12 #pt
    set Ligature [0|1] # either wants or not

    set ContentRotation [clockwise]

    set SymbolSubstitution "，。、；？！"
    set TypefaceSubstitution "STHeitiTC-Light"
    set FontSizeSubstitution 14pt
    # substitution the font of some punctuations for typography reason. 

    text [x] [y] [w] [h] [string]
    # Draw the string whose baseline begins at (x, y).
    # Those attributes will be reset with next call to text command.
    endpdf file:///path/to/output.pdf

Use bottom-baseline:x will align the baseline of the last line of text at x point on vertical direction.
![bottom-baseline](https://github.com/hypo/PDFTools/raw/master/Documents/baseline.png)
You can check the [baseline example](https://github.com/hypo/PDFTools/raw/master/Documents/baseline.pcd).
The behavior of bottom-baseline: alignment on vertical text is undefined.


----

### Check the size for horizontal text:
    
    text_checksize [x] [y] [w] [h] [string]
    # It has the same settings with `text` command. 
    # However, if the string is oversized, the program will exit with code 1.

----

### Draw a vertical text

    beginpdf 720 720
    set FontSize 10 #pt
    set FontSizeCJK 10 #pt
    set Typeface "Font Name"
    set TypefaceCJK "CJK Font Name"
    set TextAlign [left|center|right]
    set TextVerticalAlign [top|center|middle|bottom]
    set BaselineOffset 0.5 #pt
    set BaselineOffsetCJK 0.5 #pt
    set Kerning #pt
    set KerningCJK 1 #pt
    set LineSpacing 1 #pt
    set Color 0x336699 #color string
    set LineHeight 12 #pt
    set Ligature [0|1] # either wants or not

    set SymbolSubstitution "，。、；？！"
    set TypefaceSubstitution "STHeitiTC-Light"
    set FontSizeSubstitution 14pt
    # substitution the font of some punctuations for typography reason. 

    vtext [x] [y] [w] [h] [string]
    # Those attributes will be reset with next call to text command.
    endpdf file:///path/to/output.pdf

