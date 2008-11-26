#!/usr/bin/perl
$cmdline = "exiftags $ARGV[0] | grep -i Orientation";
# print $cmdline;
$rotation = `$cmdline`;

# if $rotation =~ /Top, Left-Hand/; # 1
print "-f horizontal" if $rotation =~ /Top, Right-Hand/;     # 2
print "-r 180" if $rotation =~ /Bottom, Right-Hand/;     # 3
print "-f horizontal -r 180" if $rotation =~ /Bottom, Left-Hand/; # 4
print "-f horizontal -r 270" if $rotation =~ /Left-Hand, Top/; # 5
print "-r 270" if $rotation =~ /Right-Hand, Top/; # 6
print "-f horizontal -r 90" if $rotation =~ /Right-Hand, Bottom/; # 7
print "-r 90" if $rotation =~ /Left-Hand, Bottom/; # 8
