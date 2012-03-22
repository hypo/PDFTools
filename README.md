# PageComposer

Command line tool running under Mac OS X to generate the PDF or png.

## Usage

PageComposer consumes custom file format `*.pcd` either from `STDIN`:

    ./PageComposer < stdin.pcd

or a file:

    ./PageComposer file.pcd

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
    # Draw the fullimage and strech to fill the rect define by (x, y, w, h)
    # image could be jpg/png/pdf.

    set radius [r]
    # Draw the next simpleimage with [r] point radius rounded corner.
    # Note that it will effect only the next simpleimage command.
    simpleimage image_a x_a y_a w_a h_a
    simpleimage image_b x_b y_b w_b h_b


    endpdf file:///path/to/output.pdf

----

### Draw a rounded corner image:

    beginpdf 720 720

    set radius [r]
    # Draw the next simpleimage with [r] point radius rounded corner.
    # Note that it will effect only the next simpleimage command.

    simpleimage image_a x_a y_a w_a h_a
    simpleimage image_b x_b y_b w_b h_b

    set radius [r_2]
    simpleimage image_c x_c y_c w_c h_c

    # Hence, image_a has r points radius rounded corner.
    # image_b doesn't have rounded corner.
    # image_c has r_2 points radius rounded corner.

    endpdf file:///path/to/output.pdf
  
----

### Compress and draw the image:

    beginpdf 720 720

    simpleimage_compress [url_to_image] [compress_ratio] [x] [y] [w] [h]
    # Only allows JPEG image.
    # The compress_ratio is between 0.0 ~ 1.0, where 0.0 results max compression, 1.0 results no compression.

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
    set FontSize
    set FontSizeCJK
    set Typeface
    set TypefaceCJK
    set TextAlign [left|center|right]
    set TextVerticalAlign [top|center|bottom]
    set Rotation
    set Kerning
    set KerningCJK
    set LineSpacing
    set Color
    set LineHeight
    set Ligature

    text [x] [y] [w] [h] [string]
    # Draw the string whose baseline begins at (x, y).
    # Notice: no attribute will be applied. Just plain text.
    endpdf file:///path/to/output.pdf

