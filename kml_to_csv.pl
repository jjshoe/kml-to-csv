#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

use Getopt::Long;
use XML::XPath;
use XML::XPath::XMLParser;

my $help;

my $kml_file;
my $output_file;
my $xpath_to_loop;
my @xpath_to_values;
my @xpath_to_values_retain_xml;
my @names_for_values;
my @default_column_names;
my @default_column_values;

GetOptions
(
	'help|?' => \$help,
	'kml_file=s' => \$kml_file,
	'output_file=s' => \$output_file,
	'xpath_to_loop=s' => \$xpath_to_loop,
	'xpath_to_values=s{1,}' => \@xpath_to_values,
	'xpath_to_values_retain_xml=s{1,}' => \@xpath_to_values_retain_xml,
	'names_for_values=s{1,}' => \@names_for_values,
	'default_column_names=s{1,}' => \@default_column_names,
	'default_column_values=s{1,}' => \@default_column_values,
);

my $additional_data = "\tB5BAB6";

my $xp = XML::XPath->new(filename => $kml_file);
    
my $nodeset = $xp->find($xpath_to_loop); # find all paragraphs

open(my $output_fh, ">&STDOUT");

if ($output_file)
{
        $output_fh = open_file(file => $output_file, mode => '>');
}

print $output_fh join("\t", (@names_for_values, @default_column_names)) . "\n";

foreach my $node ($nodeset->get_nodelist) 
{
	my @values;
	my $counter = 0;

	foreach my $xpath_to_value (@xpath_to_values)
	{
		my $value;

		if ($xpath_to_values_retain_xml[$counter] == 1)
		{
			$value = $xp->findnodes_as_string($xpath_to_value, $node);
		}
		else
		{
			$value = $xp->findvalue($xpath_to_value, $node);
		}

		if ($value)
		{
			push(@values, $value);
		}
		else
		{
			print STDERR "Unable to find value for $xpath_to_value\nNear: " . join(" ", @values) . "\n";
		}

		$counter++;
	}

	print $output_fh join("\t", (@values, @default_column_values)) . "\n";
}

sub open_file
{
	my %in = @_;

	my $file = $in{'file'};
	my $mode = $in{'mode'};

	if ($mode eq '<' && ! -e $file)
	{
		print "$file not found\n";
		die;
	}
	elsif (open(my $file_fh, $mode, $file))
	{
		return $file_fh;
	}
	else
	{
		print "Unable to open: $file\nReason: $!\n";
		die;
	}
}

