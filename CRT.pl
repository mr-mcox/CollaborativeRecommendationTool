 #! /usr/bin/perl
# Collaborative Recommendation Tool: Match CMs with best collabs
# Written by Matthew Cox for use at the Teach For America summer institutes
#Revision 40 - 6/8/2013

use strict;
use Carp;
use feature qw(say switch);
use Spreadsheet::ParseExcel;
use Math::Vector::Real;
use List::Compare;

my $outfile_prefix = defined $ARGV[4] ? $ARGV[4] : "";

#Open the files - CM in first argument and Collab in second
open CM_FILE, "< $ARGV[0]" or croak "Can't open CM file $!";
open COLLAB_FILE, "< $ARGV[1]" or croak "Can't open Collab file $!";
open CM_COLLAB_OUTFILE, "> $ARGV[3]/" . $outfile_prefix . "placement_reccomendations_and_cm_level_scoring.xls" or croak "Can't open cm-collab out file $!";
open COLLAB_SCORE_OUTFILE, "> $ARGV[3]/" . $outfile_prefix . "collab_level_scoring.xls" or croak "Can't open collab score out file $!";
open PLACEMENT_ALIGNMENT_OUTFILE, "> $ARGV[3]/" . $outfile_prefix . "placement_advanced_scoring.xls" or croak "Can't open placement alignment out file $!";
open CM_PLACEMENT_ALIGNMENT_REPORT, "> $ARGV[3]/" . $outfile_prefix . "cm_placement_report_for_regions.xls" or croak "Can't open cm placeemnt alignment out file $!";


#Set up mappings
my %specific_subject_map = (
	'English-Language Arts'		=> 'ELA',
	'English-Other'				=> 'English',
	'English-Reading'			=> 'Reading',
	'English-Writing'			=> 'Writing',
	'English-AP'				=> 'AP English',
	'Foreign Language-French' 	=> 'French',
	'Foreign Language-Spanish'	=> 'Spanish',
	'Foreign Language-Other'	=> 'Foreign Language',
	'Math-Algebra1'				=> 'Algebra1',
	'Math-Algebra2'				=> 'Algebra2',
	'Math-General'				=> 'Math',
	'Math-Geometry'				=> 'Geometry',
	'Math-Calculus'				=> 'Algebra2',
	'Math-PreAlgebra'			=> 'Math',
	'Math-Remedial'				=> 'Math',
	'Math-Trigonometry'			=> 'Algebra2',
	'Math-AP'					=> 'Algebra2',
	'Math-Other'				=> 'Math',
	'Science-Biology'			=> 'Biology',
	'Science-Chemistry'			=> 'Chemistry',
	'Science-General'			=> 'Science',			
	'Science-Other'				=> 'Science',
	'Science-PhysicalScience'	=> 'PhysicalScience',
	'Science-Anatomy/Physiology'=> 'Biology',
	'Science-EarthScience'		=> 'PhysicalScience',
	'Science-Lab Skills'		=> 'Science',
	'Science-Physics'			=> 'Physics',
	'Science-LivingEnvironment'	=> 'Biology',
	'Science-AP Bio'			=> 'Biology',
	'Science-AP Chemistry'		=> 'Chemistry',
	'Social Studies- other'		=> 'Social Studies',
	'Social Studies-General'	=> 'Social Studies',
	'Social Studies-Government'	=> 'Government',
	'Social Studies-History'	=> 'History',
	'English-AP'				=> 'English',
	'Other-Arts'				=> 'Arts',
	'Other-Music'				=> 'Arts',
	'Other-Drama'				=> 'Arts',
	'Other-Business/Accounting' => 'Business',
	'Other-ComputerScience'		=> 'Computer',
	'Other-LibraryServices'		=> 'Library',
	'Other-PhysicalEducation'	=> 'PE',
	'Other-Other'				=> 'General'
	
);

my %general_subject_map = (
	'English-Language Arts'		=> 'English',
	'English-Other'				=> 'English',
	'English-Reading'			=> 'English',
	'English-Writing'			=> 'English',
	'English-AP'				=> 'English',
	'Foreign Language-French' 	=> 'French',
	'Foreign Language-Other'	=> 'Foreign Language',
	'Foreign Language-Spanish'	=> 'Spanish',
	'Math-Algebra1'				=> 'Math',
	'Math-Algebra2'				=> 'Math',
	'Math-General'				=> 'Math',
	'Math-Geometry'				=> 'Math',
	'Math-AP'					=> 'Math',
	'Math-Other'				=> 'Math',
	'Science-Biology'			=> 'Science',
	'Science-Chemistry'			=> 'Science',
	'Science-General'			=> 'Science',			
	'Science-Other'				=> 'Science',
	'Science-PhysicalScience'	=> 'Science',
	'Science-Anatomy/Physiology'=> 'Science',
	'Science-EarthScience'		=> 'Science',
	'Science-Lab Skills'		=> 'Science',
	'Science-Physics'			=> 'Science',
	'Science-LivingEnvironment'	=> 'Science',
	'Science-AP Bio'			=> 'Science',
	'Science-AP Chemistry'		=> 'Science',
	'Social Studies- other'		=> 'Social Studies',
	'Social Studies-General'	=> 'Social Studies',
	'Social Studies-Government'	=> 'Social Studies',
	'Social Studies-History'	=> 'Social Studies',
	'English-AP'				=> 'English',
	'Math-Calculus'				=> 'Math',
	'Math-PreAlgebra'			=> 'Math',
	'Math-Remedial'				=> 'Math',
	'Math-Trigonometry'			=> 'Math',
	'Other-Arts'				=> 'Arts',
	'Other-Music'				=> 'Arts',
	'Other-Drama'				=> 'Arts',
	'Other-Business/Accounting' => 'Other',
	'Other-ComputerScience'		=> 'Other',
	'Other-LibraryServices'		=> 'Other',
	'Other-PhysicalEducation'	=> 'Other',
	'Other-Other'				=> 'General',
	'General Ed'				=> 'General',
);

my %major_specific_subject_map = (
	'Theater' => 'Arts',
	'Fine Arts' => 'Arts',
	'Art History' => 'Arts',
	'Graphic Design' => 'Arts',
	'Music' => 'Arts',
	'Art' => 'Arts',
	'Dance' => 'Arts',
	'Photography' => 'Arts',
	'Interior Design' => 'Arts',
	'Performance Art' => 'Arts',
	'Zoology' => 'Biology',
	'Biology' => 'Biology',
	'Biomedical Engineering' => 'Biology',
	'Microbiology' => 'Biology',
	'Neuroscience' => 'Biology',
	'Biopsychology' => 'Biology',
	'Molecular Biology' => 'Biology',
	'Physiology' => 'Biology',
	'Human Biology' => 'Biology',
	'Pre-medicine' => 'Biology',
	'Environmental Engineering' => 'Biology',
	'Animal Science' => 'Biology',
	'Botany' => 'Biology',
	'Nutrition' => 'Biology',
	'Nursing' => 'Biology',
	'Biophysics' => 'Biology',
	'Ecology' => 'Biology',
	'Human Resource Management' => 'Business',
	'Finance' => 'Business',
	'Business' => 'Business',
	'Accounting' => 'Business',
	'International Business' => 'Business',
	'Biochemistry' => 'Chemisty',
	'Chemistry' => 'Chemisty',
	'Pharmacy' => 'Chemisty',
	'Computer Science' => 'Computer',
	'Computer Engineering' => 'Computer',
	'Management Information Systems' => 'Computer',
	'Computer Information Systems' => 'Computer',
	'English' => 'English',
	'Journalism' => 'English',
	'Communications' => 'English',
	'English Literature' => 'English',
	'Classics' => 'English',
	'Government' => 'Government',
	'Policy Studies' => 'Government',
	'Political Science' => 'Government',
	'Public Policy' => 'Government',
	'Mechanical Engineering' => 'Math',
	'Economics' => 'Math',
	'Mathematics' => 'Math',
	'Other Math' => 'Math',
	'Electrical Engineering' => 'Math',
	'Industrial Engineering' => 'Math',
	'Civil Engineering' => 'Math',
	'Statistics' => 'Math',
	'Engineering (general)' => 'Math',
	'Exercise Science' => 'PE',
	'Physical Education' => 'PE',
	'Earth Science' => 'Physical Science',
	'Geology' => 'Physical Science',
	'Astronomy' => 'Physical Science',
	'Physics' => 'Physics',
	'Psychology' => 'Science',
	'Materials Science' => 'Science',
	'Chemical Engineering' => 'Science',
	'Environmental Science' => 'Science',
	'Science' => 'Science',
	'Other Science' => 'Science',
	'Agricultural Science' => 'Science',
	'Cognitive Science' => 'Science',
	'Behavioral Science' => 'Science',
	'Natural Sciences' => 'Science',
	'Anthropology' => 'Social Studies',
	'Sociology' => 'Social Studies',
	'Geography' => 'Social Studies',
	'History' => 'Social Studies',
	'Social Studies' => 'Social Studies',
	'Social Science' => 'Social Studies',
	'Spanish' => 'Spanish',
	'Creative Writing' => 'Writing',
	'Writing' => 'Writing'
);

my %major_general_subject_map = (
	'Theater' => 'Arts',
	'Fine Arts' => 'Arts',
	'Art History' => 'Arts',
	'Graphic Design' => 'Arts',
	'Music' => 'Arts',
	'Art' => 'Arts',
	'Dance' => 'Arts',
	'Photography' => 'Arts',
	'Interior Design' => 'Arts',
	'Performance Art' => 'Arts',
	'Zoology' => 'Science',
	'Biology' => 'Science',
	'Biomedical Engineering' => 'Science',
	'Microbiology' => 'Science',
	'Neuroscience' => 'Science',
	'Biopsychology' => 'Science',
	'Molecular Biology' => 'Science',
	'Physiology' => 'Science',
	'Human Biology' => 'Science',
	'Pre-medicine' => 'Science',
	'Environmental Engineering' => 'Science',
	'Animal Science' => 'Science',
	'Botany' => 'Science',
	'Nutrition' => 'Science',
	'Nursing' => 'Science',
	'Biophysics' => 'Science',
	'Ecology' => 'Science',
	'Human Resource Management' => 'Math',
	'Finance' => 'Math',
	'Business' => 'Math',
	'Accounting' => 'Math',
	'International Business' => 'Math',
	'Biochemistry' => 'Science',
	'Chemistry' => 'Science',
	'Pharmacy' => 'Science',
	'Computer Science' => 'Math',
	'Computer Engineering' => 'Math',
	'Management Information Systems' => 'Math',
	'Computer Information Systems' => 'Math',
	'English' => 'English',
	'Journalism' => 'English',
	'Communications' => 'English',
	'English Literature' => 'English',
	'Classics' => 'English',
	'Government' => 'Social Stuides',
	'Policy Studies' => 'Social Stuides',
	'Political Science' => 'Social Stuides',
	'Public Policy' => 'Social Stuides',
	'Mechanical Engineering' => 'Math',
	'Economics' => 'Math',
	'Mathematics' => 'Math',
	'Other Math' => 'Math',
	'Electrical Engineering' => 'Math',
	'Industrial Engineering' => 'Math',
	'Civil Engineering' => 'Math',
	'Statistics' => 'Math',
	'Engineering (general)' => 'Math',
	'Exercise Science' => 'Other',
	'Physical Education' => 'Other',
	'Earth Science' => 'Science',
	'Geology' => 'Science',
	'Astronomy' => 'Science',
	'Physics' => 'Science',
	'Psychology' => 'Science',
	'Materials Science' => 'Science',
	'Chemical Engineering' => 'Science',
	'Environmental Science' => 'Science',
	'Science' => 'Science',
	'Other Science' => 'Science',
	'Agricultural Science' => 'Science',
	'Cognitive Science' => 'Science',
	'Behavioral Science' => 'Science',
	'Natural Sciences' => 'Science',
	'Anthropology' => 'Social Stuides',
	'Sociology' => 'Social Stuides',
	'Geography' => 'Social Stuides',
	'History' => 'Social Stuides',
	'Social Studies' => 'Social Stuides',
	'Social Science' => 'Social Stuides',
	'Spanish' => 'Spanish',
	'Creative Writing' => 'English',
	'Writing' => 'English'
);

##Import user variables
#Load files - put them into hash and fail if criteria not met

open USER_SETTINGS_FILE, "< $ARGV[2]" or croak "Can't open user settings file $!";

my %user_settings;
my $user_settings_line_number = 1;
while( <USER_SETTINGS_FILE> ){
	chomp;
	my $current_variable_name;
	my $current_line = $_;
	unless( $current_line =~ /^#/ || !($current_line =~ /\w+/) ){
		
		if ( $current_line =~ /(\w+)\s*=/){
			$current_variable_name = $1;
		}else{
			croak "Line $user_settings_line_number of the user settings file does not appear to have a variable. It should be in the format \'variable_name = number\' or \'variable_name = number, number\'";
		}
		if( $current_line =~ /=\s*([\d.-]+)\s*,\s*([\d.-]+)/ ){
			
			my @biweight_array = ($1, $2);
			$user_settings{$current_variable_name} = \@biweight_array;
			
			unless( $current_variable_name =~ /biweight/ ){
				croak "$current_variable_name has two numbers, but we only expect one. It should be in the format \'variable_name = number\'";
			}

		}elsif( $current_line =~ /=\s*([\d.-]+)/ ){
			
			$user_settings{$current_variable_name} = $1;

			if( $current_variable_name =~ /biweight/ ){
				croak "$current_variable_name has one number, but we  expect two. It should be in the format \'variable_name = number, number\'";
			}

		}else{
			croak "$current_variable_name doesn't appear to have a value associated with it. It should be in the format \'variable_name = number\' or \'variable_name = number, number\'";
		}
		
	}
	
	$user_settings_line_number++;
}

#Check that all variables are in user settings
my @expected_user_settings = ("number_of_swaps_to_attempt","worst_score_iterations","number_of_collabs_to_improve",
								"school_match_biweight", "exact_match_pk_k_biweight", "within_year_pk_k_biweight", "sped_placement_in_sped_biweight", "same_grade_level_biweight",
								"same_specific_subject_biweight", "same_general_subject_biweight", "math_science_biweight", "bilingual_placement_in_bilingual_classroom_biweight",
								"spanish_ability_in_bilingual_classroom_biweight", "spanish_ability_in_lower_grades_biweight", "cma_group_request_match_biweight", "collab_request_match_biweight", 
								"distance_from_grade_exponent", "non_hired_multiplier", "hired_unconfirmed_multiplier", "hired_confirmed_multiplier", "exact_match_critical_multiplier",
								"sufficient_num_cms_biweight", "at_least_one_span_ability_biweight", "grade_levels_multiplier", "collab_region_number_multiplier", "cma_group_region_number_multiplier", "school_region_number_multiplier", 
								"school_region_cluster_cm_weighted_multiplier", "collab_region_cluster_cm_weighted_multiplier", "cma_group_region_cluster_cm_weighted_multiplier",
								"collab_gender_balance_multiplier", "cma_group_gender_balance_multiplier", "collab_poc_threshold", "collab_poc_biweight", "cma_group_poc_threshold", "cma_group_poc_biweight", 
								"school_poc_threshold", "school_poc_biweight","percentage_of_max_value_for_matching_major" );
foreach my $current_setting (@expected_user_settings){
	unless (exists $user_settings{$current_setting} ){
		croak "variable \'$current_setting\' not found in user settings file. It is necessary to build collaboratives";
	}
}

#Assign run variables
my $number_of_swaps_to_attempt = $user_settings{"number_of_swaps_to_attempt"};
my $worst_score_iterations = $user_settings{"worst_score_iterations"};
my $number_of_collabs_to_improve = $user_settings{"number_of_collabs_to_improve"};

#Set weights - first for if requirement is met, second if it does not
my @school_match_biweight			= @{$user_settings{"school_match_biweight"}};
my @exact_match_pk_k_biweight		= @{$user_settings{"exact_match_pk_k_biweight"}};
my @within_year_pk_k_biweight		= @{$user_settings{"within_year_pk_k_biweight"}};
my @sped_placement_in_sped_biweight	= @{$user_settings{"sped_placement_in_sped_biweight"}};
my @same_grade_level_biweight		= @{$user_settings{"same_grade_level_biweight"}};
my @same_specific_subject_biweight	= @{$user_settings{"same_specific_subject_biweight"}};
my @same_general_subject_biweight	= @{$user_settings{"same_general_subject_biweight"}};
my @math_science_biweight			= @{$user_settings{"math_science_biweight"}};
my @bilingual_placement_in_bilingual_classroom_biweight = @{$user_settings{"bilingual_placement_in_bilingual_classroom_biweight"}};
my @spanish_ability_in_bilingual_classroom_biweight		= @{$user_settings{"spanish_ability_in_bilingual_classroom_biweight"}};
my @spanish_ability_in_lower_grades_biweight			= @{$user_settings{"spanish_ability_in_lower_grades_biweight"}};
my @cma_group_request_match_biweight	= @{$user_settings{"cma_group_request_match_biweight"}};
my @collab_request_match_biweight		= @{$user_settings{"collab_request_match_biweight"}};

my $distance_from_grade_exponent	= $user_settings{"distance_from_grade_exponent"};
my $non_hired_multiplier			= $user_settings{"non_hired_multiplier"};
my $hired_unconfirmed_multiplier	= $user_settings{"hired_unconfirmed_multiplier"};
my $hired_confirmed_multiplier		= $user_settings{"hired_confirmed_multiplier"};
my $exact_match_critical_multiplier	= $user_settings{"exact_match_critical_multiplier"};
my $percentage_of_max_value_for_matching_major	= $user_settings{"percentage_of_max_value_for_matching_major"};

#Set optional weights
my @subject_or_grade_level_biweight;
if( exists $user_settings{"subject_or_grade_level_biweight"} ){
	@subject_or_grade_level_biweight = @{$user_settings{"subject_or_grade_level_biweight"}};
}else{
	@subject_or_grade_level_biweight = (0,0);
}

#Set collab & cma group and multipliers
my @sufficient_num_cms_biweight = @{$user_settings{"sufficient_num_cms_biweight"}};
my @at_least_one_span_ability_biweight = @{$user_settings{"at_least_one_span_ability_biweight"}};
my $grade_levels_multiplier = $user_settings{"grade_levels_multiplier"};
my $collab_region_number_multiplier = $user_settings{"collab_region_number_multiplier"};
my $cma_group_region_number_multiplier = $user_settings{"cma_group_region_number_multiplier"};
my $school_region_number_multiplier = $user_settings{"school_region_number_multiplier"};
my $school_region_cluster_cm_weighted_multiplier = $user_settings{"school_region_cluster_cm_weighted_multiplier"};
my $collab_region_cluster_cm_weighted_multiplier = $user_settings{"collab_region_cluster_cm_weighted_multiplier"};
my $cma_group_region_cluster_cm_weighted_multiplier = $user_settings{"cma_group_region_cluster_cm_weighted_multiplier"};
my $collab_gender_balance_multiplier = $user_settings{"collab_gender_balance_multiplier"};
my $cma_group_gender_balance_multiplier = $user_settings{"cma_group_gender_balance_multiplier"};
my $collab_poc_threshold = $user_settings{"collab_poc_threshold"};
my @collab_poc_biweight = @{$user_settings{"collab_poc_biweight"}};
my $cma_group_poc_threshold = $user_settings{"cma_group_poc_threshold"};
my @cma_group_poc_biweight = @{$user_settings{"cma_group_poc_biweight"}};
my $school_poc_threshold = $user_settings{"school_poc_threshold"};
my @school_poc_biweight = @{$user_settings{"school_poc_biweight"}};

my $excel_parser = new Spreadsheet::ParseExcel;
my $cm_excel_file = $excel_parser->Parse($ARGV[0]) or die "Error: CM file doesn't seem to be an .xls file";
my $cm_data_worksheet = $cm_excel_file->Worksheet("Sheet0") or die "Error: Worksheet tab named 'Sheet0' not found in cm file";
my %cm_header_columns;
my ($cm_min_row, $cm_max_row) = $cm_data_worksheet->RowRange();
my ($cm_min_column, $cm_max_column) = $cm_data_worksheet->ColRange();
for (my $current_column = 0; $current_column <= $cm_max_column; $current_column++){
	if(defined $cm_data_worksheet->{Cells}[0][$current_column] && $cm_data_worksheet->{Cells}[0][$current_column]->Value ne "" ){
		$cm_header_columns{ $cm_data_worksheet->{Cells}[0][$current_column]->Value } = $current_column;
	}
}

my $collab_excel_file = $excel_parser->Parse($ARGV[1]) or die "Error: Collab file doesn't seem to be an .xls file";
my $collab_data_worksheet = $collab_excel_file->Worksheet("CollabGroups") or die "Error: Worksheet tab named 'CollabGroups' not found in collab file";
my %collab_header_columns;
my ($collab_min_row, $collab_max_row) = $collab_data_worksheet->RowRange();
my ($collab_min_column, $collab_max_column) = $collab_data_worksheet->ColRange();
for (my $current_column = 0; $current_column <= $collab_max_column; $current_column++){
	if(defined $collab_data_worksheet->{Cells}[0][$current_column] && $collab_data_worksheet->{Cells}[0][$current_column]->Value ne "" ){
		$collab_header_columns{ $collab_data_worksheet->{Cells}[0][$current_column]->Value } = $current_column;
	}
}

#Set headings for cm file
my $input_cm_first_name_column;
my $input_cm_last_name_column;
if( exists $cm_header_columns{"First Name"} ){
    $input_cm_first_name_column = $cm_header_columns{"First Name"};
}else{
    croak "Error: \"First Name\" column not found in CM input file - it's needed for this program to run\n";
} 
if( exists $cm_header_columns{"Last Name"} ){
    $input_cm_last_name_column = $cm_header_columns{"Last Name"};
}else{
    croak "Error: \"Last Name\" column not found in CM input file - it's needed for this program to run\n";
}
my $input_cm_school_column				= $cm_header_columns{"Placement School"} || croak "Error: \"Placement School\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_grade_column				= $cm_header_columns{"Placement Grade"} || croak "Error: \"Placement Grade\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_subj1_column				= $cm_header_columns{"Primary Subject"} || croak "Error: \"Primary Subject\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_subj2_column				= $cm_header_columns{"Subject Modifier"} || croak "Error: \"Subject Modifier\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_spanish_ability_column		= $cm_header_columns{"Bilingual Qualified"} || croak "Error: \"Bilingual Qualified\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_id_column					= $cm_header_columns{"ID"} || croak "Error: \"ID\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_ethnicity_column 			= $cm_header_columns{"Ethnicity"} || croak "Error: \"Ethnicity\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_gender_column 				= $cm_header_columns{"Gender"} || croak "Error: \"Gender\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_region_column 				= $cm_header_columns{"Placement Region"} || croak "Error: \"Placement Region\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_school_request_column		= $cm_header_columns{"School Request"} || print STDOUT "Warning: \"School Request\" column not found in CM input file (but its not needed for this program to run)\n";
my $input_cm_hired_column				= $cm_header_columns{"Placement Status"} || croak "Error: \"Placement Status\" column not found in CM input file - it's needed for this program to run\n";
my $input_cm_exact_match_critical		= $cm_header_columns{"Exact Match Critical"} || print STDOUT "Warning: \"Exact Match Critical\" column not found in CM input file (but its not needed for this program to run)\n";
my $input_cm_cma_request_column			= $cm_header_columns{"CMA Request"} || print STDOUT "Warning: \"CMA Request\" column not found in CM input file (but its not needed for this program to run)\n";
my $input_collab_request_column			= $cm_header_columns{"Collab Request"} || print STDOUT "Warning: \"Collab Request\" column not found in CM input file (but its not needed for this program to run)\n";
my $input_cm_major_column				= $cm_header_columns{"Major"} || croak "Error: \"Major\" column not found in CM input file - it's needed for this program to run\n";

unless( $input_cm_school_request_column > 1 ){
	undef $input_cm_school_request_column;
}
unless( $input_cm_exact_match_critical > 1 ){
	undef $input_cm_exact_match_critical;
}
unless( $input_cm_cma_request_column > 1 ){
	undef $input_cm_cma_request_column;
}
unless( $input_collab_request_column > 1 ){
	undef $input_collab_request_column;
}

#Set cm columns
my $cm_school_column					= 1;
my $cm_grade_column						= 2;
my $cm_has_sped_placement_column		= 3;
my $cm_grade_level_column				= 4;
my $cm_general_subject_column			= 5;
my $cm_specific_subject_column			= 6;
my $cm_major_column						= 7;
my $cm_bilingual_placement_column		= 8;
my $cm_spanish_ability_column			= 9;
my $cm_region_column					= 10;
my $cm_gender_column					= 11;
my $cm_ethnicity_column					= 12;

#Set headings for collab file
unless( defined $collab_header_columns{"Institute"}){
	"Error: \"Institute Name\" column not found in Collab input file - it's needed for this program to run";
}
my $input_collab_institute_column		= $collab_header_columns{"Institute Name"};
my $input_collab_number_column			= $collab_header_columns{"Collab ID"} || croak "Error: \"Collab ID\" column not found in Collab input file - it's needed for this program to run\n";
my $input_collab_school_column 			= $collab_header_columns{"Institute School Name"} || croak "Error: \"Institute School Name\" column not found in Collab input file - it's needed for this program to run\n";
my $input_collab_cma_column 			= $collab_header_columns{"CMA Name"} || croak "Error: \"CMA Name\" column not found in Collab input file - it's needed for this program to run\n";
my $input_collab_cma_capacity_column	= $collab_header_columns{"Capacity"} || croak "Error: \"Capacity\" column not found in Collab input file - it's needed for this program to run\n";
my $input_collab_subj1_column			= $collab_header_columns{"Primary Subject"} || croak "Error: \"Primary Subject\" column not found in Collab input file - it's needed for this program to run\n";
my $input_collab_subj2_column			= $collab_header_columns{"Secondary Subject"} || croak "Error: \"Secondary Subject\" column not found in Collab input file - it's needed for this program to run\n";
my $input_collab_grade_column			= $collab_header_columns{"Grade"} || croak "Error: \"Grade\" column not found in Collab input file - it's needed for this program to run\n";

#Set collab columns
my $collab_number_column				= 0;
my $collab_cma_column					= 1;
my $collab_capacity_column				= 2;
my $collab_school_column				= 3;
my $collab_grade_column					= 4;
my $collab_grade_level_column			= 5;
my $collab_sped_placement_column		= 6;
my $collab_general_subject_column		= 7;
my $collab_specific_subject_coumn		= 8;
my $collab_bilingual_classroom_column	= 9;

my @cm_collab_score_comments_keys = ( 'school_match', 'prek_k_match', 'prek_k_within_1', 'sped_placement_in_sped', 'grade_level_match', 'specific_subject_match', 'general_subject_match', 'math_science_match', 'bilingual_placement_in_bilingual_classroom', 'spanish_ability_in_bilingual_classroom' ,'spanish_ability_in_lower_grades', 'distance_from_target_grade', 'cma_group_request_match','collab_request_match' );
my @collab_cma_group_score_comments_keys = ( 'num_cms','sufficient_num_cms','at_least_one_billingual_cm','number_of_collab_grade_levels','number_of_collab_regions','number_of_cma_group_grade_levels','number_of_cma_group_regions', 'collab_ratio_male_female', 'cma_group_ratio_male_female', 'collab_number_of_poc', 'cma_group_number_of_poc', 'school_number_of_poc', 'number_of_school_regions', 'highest_collab_regional_cluster_representation','highest_cma_group_regional_cluster_representation','highest_school_regional_cluster_representation', 'cm_score_total' );

###Input Collab file
my $institute;
my %collab_characteristics;
my %collabs;
my %cmas;
my %schools;
my @collab_characteristics_keys = ( "collab_school","collab_capacity","collab_cma","collab_grade","collab_grade_level","collab_sped_placement","collab_general_subject","collab_specific_subject","collab_bilingual_classroom" );

#Parse lines of collab file and input variables
for (my $current_row = 1; $current_row <= $collab_max_row; $current_row++){
	my %current_collab;
	my @current_line;
	
	#Import data into current_line
	for (my $current_column = 0; $current_column <= $collab_max_column; $current_column++){
		if( defined $collab_data_worksheet->{Cells}[$current_row][$current_column] && $collab_data_worksheet->{Cells}[$current_row][$current_column]->Value ne "" ){
			$current_line[$current_column] = $collab_data_worksheet->{Cells}[$current_row][$current_column]->Value;
		}
	}
	
	#Set institute
	if(defined $institute){
		unless( $current_line[ $input_collab_institute_column ] eq $institute){
			croak "There is more than one institute listed in the collab file\n";
		}
	}else{
		$institute = $current_line[ $input_collab_institute_column ];
	}
	
	#Ensure that each Collab has an id
	if( $current_line[ $input_collab_number_column ] eq ""){
		croak "This line is missing a Collab ID: $_";
	}
	if( exists $collab_characteristics{ $current_line[ $input_collab_number_column ] } ){
		croak "There is a duplicate Collab ID for $current_line[ $input_collab_number_column ]";
	}
	$collabs{ $current_line[ $input_collab_number_column ] } = 1;
	
	#set collab school
	if( $current_line[ $input_collab_school_column ] eq ""){
		croak "Collab $current_line[ $input_collab_number_column ] is missing a school";
	}
	$current_collab{"collab_school"} = $current_line[ $input_collab_school_column ];
	$schools{$current_line[ $input_collab_school_column ]} = 1;
	
	#set collab capacity
	if( $current_line[ $input_collab_cma_capacity_column ] eq ""){
		croak "Collab $current_line[ $input_collab_number_column ] is missing a capacity";
	}
	$current_collab{"collab_capacity"} = $current_line[ $input_collab_cma_capacity_column ];
	
	#set collab cma
	if( $current_line[ $input_collab_cma_column ] eq ""){
		croak "Collab $current_line[ $input_collab_number_column ] is missing a cma";
	}
	$current_collab{ "collab_cma" } = $current_line[ $input_collab_cma_column ];
	$cmas{ $current_line[ $input_collab_cma_column ] } = 1;
	
	#set grade and school type
	my $collab_grade_input = $current_line[ $input_collab_grade_column ];
	my $collab_grade_level;
	my @collab_grades = ();
	
	
	if( $collab_grade_input =~ /^\d+$/ ){
		@collab_grades = ( $collab_grade_input );
		if ( $collab_grade_input <= 0 ){
			$collab_grade_level = "PreK/K";
		}
		if ( ($collab_grade_input >= 1) && ($collab_grade_input <= 2) ){
			$collab_grade_level = "lower elem";
		}
		if ( ($collab_grade_input >= 3) && ($collab_grade_input <= 5) ){
			$collab_grade_level = "upper elem";
		}
		if ( ($collab_grade_input >= 6) && ($collab_grade_input <= 8) ){
			$collab_grade_level = "middle";
		}
		if ( $collab_grade_input >= 9 ){
			$collab_grade_level = "high";
		}
	}else{
		given ( $collab_grade_input ) {

			when ("PK") { @collab_grades = ( -1 ); $collab_grade_level =  "PreK/K" }

			when ("K") {@collab_grades = ( 0 ); $collab_grade_level =  "PreK/K" }

			when ("True mix lower elementary") { @collab_grades = ( 1,2 ); $collab_grade_level =  "lower elem" }

			when ("True mix upper elementary") { @collab_grades = ( 3,4,5 ); $collab_grade_level =  "upper elem"  }

			when ("True mix middle school") { @collab_grades = ( 6,7,8 ); $collab_grade_level =  "middle" }

			when ("6-Middle School") { @collab_grades = ( 6 ); $collab_grade_level =  "middle" }

			when ("6-Elementary") { @collab_grades = ( 6 ); $collab_grade_level =  "upper elem" }

			when ("True mix high school") { @collab_grades = ( 9,10,11,12 ); $collab_grade_level =  "high" }

			default { croak "Grade of collab $current_line[ $input_collab_number_column ] is not correct: $collab_grade_input" }

		}
	}

	
	$current_collab{"collab_grade"} = \@collab_grades;
	$current_collab{"collab_grade_level"} = $collab_grade_level;
	
	#set sped placement
	if( $current_line[ $input_collab_subj2_column ] =~ "SPED" ){
		$current_collab{"collab_sped_placement"} = 1;
	}else{
		$current_collab{"collab_sped_placement"} = 0;
	}
	
	#Set general subject
	my @collab_general_subject;
	my $general_subject_set = 0;
	
	if( exists $general_subject_map{ $current_line[ $input_collab_subj1_column ] } ){
		push @collab_general_subject, $general_subject_map{ $current_line[ $input_collab_subj1_column ] };
		$general_subject_set = 1;
	}
	if( exists $general_subject_map{ $current_line[ $input_collab_subj2_column ] } ){
		push @collab_general_subject, $general_subject_map{ $current_line[ $input_collab_subj2_column ] };
		$general_subject_set = 1;
	}
	if( $general_subject_set == 0){
		push @collab_general_subject, "General";
		#carp "No matching subject found in columns, general subject set for collab $collab_number_column as general $collab_number_column: $current_line[ $input_collab_subj1_column ], $current_line[ $input_collab_subj2_column ]";
	}
	$current_collab{"collab_general_subject"} = \@collab_general_subject;
	
	#Set specific subject
	my @collab_specific_subject;
	my $specific_subject_set = 0;
	
	if( exists $specific_subject_map{ $current_line[ $input_collab_subj1_column ] } ){
		push @collab_specific_subject, $specific_subject_map{ $current_line[ $input_collab_subj1_column ] };
		$specific_subject_set = 1;
	}
	if( exists $specific_subject_map{ $current_line[ $input_collab_subj2_column ] } ){
		push @collab_specific_subject, $specific_subject_map{ $current_line[ $input_collab_subj2_column ] };
		$specific_subject_set = 1;
	}
	if( $specific_subject_set == 0){
		push @collab_specific_subject, "General";
		#carp "No matching subject found in columns, specific subject set for collab $collab_number_column as general: $current_line[ $input_collab_subj1_column ], $current_line[ $input_collab_subj2_column ]";
	}
	$current_collab{"collab_specific_subject"}  = \@collab_specific_subject;
	
	#Set bilinugal
	if( ( $current_line[ $input_collab_subj2_column ] =~ "ESL" ) || ( $current_line[ $input_collab_subj2_column ] =~ "Bilingual" ) ){
		$current_collab{"collab_bilingual_classroom"} = 1;
	}else{
		$current_collab{"collab_bilingual_classroom"} = 0;
	}	
	
	#Push current collab on to stack of collabs
	$collab_characteristics{ $current_line[ $input_collab_number_column ] } = \%current_collab;
	
}

#Translate institute into region name
if( $institute =~ /(.*) Institute/){
	$institute = $1;
}

given ( $institute ) {
	when ("LA") { $institute = "Los Angeles" }
	default {}
}

#variable to check that some CMs are in the institute region
my $cms_in_institute_region = 0;

###Input CM file
my %cm_demographs;
my @cm_demographs_keys = ( "cm_school","cm_grade","cm_has_sped_placement","cm_grade_level","cm_general_subject","cm_specific_subject","cm_bilingual_placement","cm_spanish_ability","cm_region","cm_hired", "cm_exact_match_critical", "cm_cma_group_request", "cm_school_request", "cm_collab_request", "cm_potential_collabs", "cm_gender", "cm_poc" );

#Parse lines of cm file and input variables
for (my $current_row = 1; $current_row <= $cm_max_row; $current_row++){
	my %current_cm;
	my @current_line;
	
	#Import data into current_line
	for (my $current_column = 0; $current_column <= $cm_max_column; $current_column++){
		if( defined $cm_data_worksheet->{Cells}[$current_row][$current_column] && $cm_data_worksheet->{Cells}[$current_row][$current_column]->Value ne "" ){
			$current_line[$current_column] = $cm_data_worksheet->{Cells}[$current_row][$current_column]->Value;
		}
	}
	
	#Ensure that each CM has an id
	if( $current_line[ $input_cm_id_column ] eq ""){
		croak "This line is missing a CM ID: $_";
	}
	if( exists $cm_demographs{ $current_line[ $input_cm_id_column ] } ){
		croak "There is a duplicate CM ID for $current_line[ $input_cm_id_column ]";
	}
	my $current_cm_id = $current_line[ $input_cm_id_column ];
	
	#Input CM name
	$current_cm{"cm_first_name"} = $current_line[ $input_cm_first_name_column ];
	$current_cm{"cm_last_name"} = $current_line[ $input_cm_last_name_column ];
	
	#Set cm school (if from institute region) - if school is listed in school request column, use that one
	my $school_input_string;
	if ( $current_line[ $input_cm_region_column ] eq $institute ) {
		$cms_in_institute_region++;
		$school_input_string = $current_line[ $input_cm_school_column];
	}
	if ( defined $input_cm_school_request_column && $current_line[ $input_cm_school_request_column ] ne "" ) {
		$school_input_string = $current_line[ $input_cm_school_request_column ];
		$current_cm{"cm_school_request"} = $current_line[ $input_cm_school_request_column ];
	}
	if( $school_input_string ne ""){
		my @cm_schools = split ";", $school_input_string;
		for( my $i = 0; $i <= $#cm_schools; $i++ ){
			$cm_schools[ $i ] = &strip_surrounding_white_space( $cm_schools[ $i ] );
		}
		for my $current_school ( @cm_schools ){
			unless( exists $schools{ $current_school } ){
				print STDOUT "Warning: CM $current_cm_id has a request of school \"$current_school\", which does not exist in the collab file\n";
			}
		}
		$current_cm{"cm_school"} = \@cm_schools;
	}
	if ( defined $input_cm_exact_match_critical && $current_line[ $input_cm_exact_match_critical ] ne "" ) {
		$current_cm{"cm_exact_match_critical"} = 1;
	}
	
	#Set cm cma group request column
	if ( defined $input_cm_cma_request_column && $current_line[ $input_cm_cma_request_column ] ne "" ) {
		$current_cm{"cm_cma_group_request"} = $current_line[ $input_cm_cma_request_column ];
		my @cm_potential_cma_groups = split ";", $current_cm{"cm_cma_group_request"};
		for( my $i = 0; $i <= $#cm_potential_cma_groups; $i++ ){
			$cm_potential_cma_groups[ $i ] = &strip_surrounding_white_space( $cm_potential_cma_groups[ $i ] );
		}
		for my $current_cma_group ( @cm_potential_cma_groups ){
			unless( exists $cmas{ $current_cma_group } ){
				print STDOUT "Warning: CM $current_cm_id has a request of cma group \"$current_cma_group\", which does not exist in the collab file\n";
			}
		}
		$current_cm{"cm_potential_cma_group_request"} = \@cm_potential_cma_groups;
	}
	
	#Set cm collab request column
	my $collab_input_string;
	if ( defined $input_collab_request_column && $current_line[ $input_collab_request_column ] ne "" ) {
		$collab_input_string = $current_line[ $input_collab_request_column ];
		$current_cm{"cm_collab_request"} = $collab_input_string;
		my @cm_potential_collabs = split ";", $collab_input_string;
		for( my $i = 0; $i <= $#cm_potential_collabs; $i++ ){
			$cm_potential_collabs[ $i ] = &strip_surrounding_white_space( $cm_potential_collabs[ $i ] );
		}
		for my $current_collab ( @cm_potential_collabs ){
			unless( exists $collabs{ $current_collab } ){
				print STDOUT "Warning: CM $current_cm_id has a request of collab \"$current_collab\", which does not exist in the collab file\n";
			}
		}
		$current_cm{"cm_potential_collabs"} = \@cm_potential_collabs;
	}
	
	#set cm grade levels and convert PK and K to integers
	my $cm_grade_input = $current_line[ $input_cm_grade_column ];
	my @cm_grades = ();
	my $cm_grade_level;
	
	if( $cm_grade_input =~ /^\d+$/ ){
		@cm_grades = ( $cm_grade_input );
		if ( $cm_grade_input <= 0 ){
			$cm_grade_level = "PreK/K";
		}
		if ( ($cm_grade_input >= 1) && ($cm_grade_input <= 2) ){
			$cm_grade_level = "lower elem";
		}
		if ( ($cm_grade_input >= 3) && ($cm_grade_input <= 5) ){
			$cm_grade_level = "upper elem";
		}
		if ( ($cm_grade_input >= 6) && ($cm_grade_input <= 8) ){
			$cm_grade_level = "middle";
		}
		if ( $cm_grade_input >= 9 ){
			$cm_grade_level = "high";
		}
	}else{
		given ( $cm_grade_input ) {

			when ("PK") { @cm_grades = ( -1 ); $cm_grade_level =  "PreK/K" }

			when ("K") {@cm_grades = ( 0 ); $cm_grade_level =  "PreK/K" }

			when ("True mix lower elementary") { @cm_grades = ( 1,2 ); $cm_grade_level =  "lower elem" }

			when ("True mix upper elementary") { @cm_grades = ( 3,4,5 ); $cm_grade_level =  "upper elem"  }

			when ("True mix middle school") { @cm_grades = ( 6,7,8 ); $cm_grade_level =  "middle" }

			when ("6-Middle School") { @cm_grades = ( 6 ); $cm_grade_level =  "middle" }

			when ("6-Elementary") { @cm_grades = ( 6 ); $cm_grade_level =  "upper elem" }

			when ("True mix high school") { @cm_grades = ( 9,10,11,12 ); $cm_grade_level =  "high" }

			default { croak "Grade of CM # $current_line[$input_cm_id_column] is not correct: $cm_grade_input" }
		}
	}

	
	
	$current_cm{"cm_grade"}  = \@cm_grades;
	$current_cm{ "cm_grade_level" } = $cm_grade_level;
	
	#set sped placement
	if( $current_line[ $input_cm_subj2_column ] =~ /SPED/  ){
		$current_cm{ "cm_has_sped_placement" } = 1;
	}else{
		$current_cm{ "cm_has_sped_placement" } = 0;
	}	
	
	#Set general subject
	my @cm_general_subject;
	my $general_subject_set = 0;
	
	if( exists $general_subject_map{ $current_line[ $input_cm_subj1_column ] } ){
		push @cm_general_subject, $general_subject_map{ $current_line[ $input_cm_subj1_column ] };
		$general_subject_set = 1;
	}
	if( exists $general_subject_map{ $current_line[ $input_cm_subj2_column ] } ){
		push @cm_general_subject, $general_subject_map{ $current_line[ $input_cm_subj2_column ] };
		$general_subject_set = 1;
	}
	if( $general_subject_set == 0){
		push @cm_general_subject, "General";
		#carp "No matching subject found in columns, general subject set for CM $current_line[ $input_cm_id_column ] as general: $current_line[ $input_cm_subj1_column ], $current_line[ $input_cm_subj2_column ]";
	}
	$current_cm{"cm_general_subject"} = \@cm_general_subject;
	
	#Set specific subject
	my @cm_specific_subject;
	my $specific_subject_set = 0;
	
	if( exists $specific_subject_map{ $current_line[ $input_cm_subj1_column ] } ){
		push @cm_specific_subject, $specific_subject_map{ $current_line[ $input_cm_subj1_column ] };
		$specific_subject_set = 1;
	}
	if( exists $specific_subject_map{ $current_line[ $input_cm_subj2_column ] } ){
		push @cm_specific_subject, $specific_subject_map{ $current_line[ $input_cm_subj2_column ] };
		$specific_subject_set = 1;
	}
	if( $specific_subject_set == 0){
		push @cm_specific_subject, "General";
		#carp "No matching subject found in columns, specific subject set for CM $current_line[ $input_cm_id_column ] as general: $current_line[ $input_cm_subj1_column ], $current_line[ $input_cm_subj2_column ]";
	}
	$current_cm{ "cm_specific_subject" } = \@cm_specific_subject;
	
	#Set CM Major
	$current_cm{ "cm_major" } = $current_line[ $input_cm_major_column ];
	
	#Set bilingual placement
	if( ($current_line[ $input_cm_subj2_column ] =~ /ESL/) || ($current_line[ $input_cm_subj2_column ] =~ /Bilingual/) ){
		$current_cm{"cm_bilingual_placement"} = 1;
	}else{
		$current_cm{"cm_bilingual_placement"} = 0;
	}

	#Set spanish ability
	if( $current_line[ $input_cm_spanish_ability_column ] eq "TRUE" ){
		$current_cm{"cm_spanish_ability"} = 1;
	}else{
		$current_cm{"cm_spanish_ability"} = 0;
	}
	
	#Set gender
	$current_cm{"cm_gender"} = $current_line[ $input_cm_gender_column ];
	
	#Set ethnicity and POC
	$current_cm{"cm_ethnicity"} = $current_line[ $input_cm_ethnicity_column ];
	if( defined $current_cm{"cm_ethnicity"} && ($current_cm{"cm_ethnicity"} =~ /\w{3,}/) && !($current_cm{"cm_ethnicity"} =~ /Caucasian/) ){
		$current_cm{"cm_poc"} = 1;
	}else{
		$current_cm{"cm_poc"} = 0;
	}
	
	#Set region
	$current_cm{"cm_region"} = $current_line[ $input_cm_region_column ];
	
	#Set hired status
	$current_cm{"cm_hired"} = $current_line[ $input_cm_hired_column ];
	
	#Put current cm into the hash
	$cm_demographs{ $current_line[ $input_cm_id_column ] } = \%current_cm;
}

#Warn if no CMs are in institute region
unless( $cms_in_institute_region > 0 ){
	print STDOUT "Warning: No CMs listed in institute region \'$institute\'\n";
}

#Ensure that there are enough collab spots for CMs and enough CMs for collab spots
my $min_collab_spots = 0;
my $max_collab_spots = 0;
my @cm_list = keys %cm_demographs;
my $number_of_cms = $#cm_list + 1;

foreach my $current_collab ( keys %collab_characteristics ){
	
	my $current_collab_capacity = $collab_characteristics{ $current_collab }->{'collab_capacity'};
	if( $current_collab_capacity > 3 ){
		$min_collab_spots += 3;
	}else{
		$min_collab_spots += $current_collab_capacity;
	}
	
	$max_collab_spots += $current_collab_capacity;
}

if( $number_of_cms < $min_collab_spots ){
	croak "We need at least $min_collab_spots CMs in collabs but there are only $number_of_cms CMs (max $max_collab_spots). Please reduce the number/size of collabs";
}
if( $number_of_cms > $max_collab_spots ){
	croak "We need at at least $number_of_cms spots for CMs in collabs, but there are only $max_collab_spots spots in collabs (min $min_collab_spots). Please add collabs or expand the size of some collabs";
}

print STDOUT "We need between $min_collab_spots and $max_collab_spots CMs to fill collabs and there are $number_of_cms CMs\n";

print STDOUT "Beginning computation of cm collab scores\n";

#Compute collab cm score for each combination of cm and collab
my %collab_cm_score;

foreach my $current_cm (keys %cm_demographs ){
	foreach my $current_collab (keys %collab_characteristics ){
		$collab_cm_score{ $current_collab }->{ $current_cm } = &score_cm_collab_combo( $current_cm, $current_collab );
	}
}

print STDOUT "Now beginning CM placements\n";

#Set all cms as not placed
my %cm_placed;
foreach my $current_cm (keys %cm_demographs ){
	$cm_placed{ $current_cm } = 0;
}
#set all collabs as not initialy placed or full
my @initially_placed_collabs = keys %collab_characteristics;
my @unfilled_collabs;

#Sort CMs within each collab based on score and collect the lists in the cm_sorted_collab hash
my %cm_sorted_collab;
my %num_cm_to_place;

my %present_cm_list;

foreach my $current_collab (keys %collab_characteristics ){
	%present_cm_list = %{$collab_cm_score{ $current_collab }};
	my @sorted_cm_list = sort by_present_cm_list_score_descending keys %present_cm_list;
	$cm_sorted_collab{ $current_collab } = \@sorted_cm_list;
	
	#Transform collab capacity to initial_num_to_place
	if( $collab_characteristics{ $current_collab }->{'collab_capacity'} >= 4){
		$num_cm_to_place{ $current_collab } = 3;
		#Put this collab into the unfilled_collabs array
		push @unfilled_collabs, $current_collab;
	}else{
		$num_cm_to_place{ $current_collab } = $collab_characteristics{ $current_collab }->{'collab_capacity'};
	} 
}

my %average_scores_for_top_cms;

#Hash that holds all collab assigments
my %cm_collab_assignment;

#Perform intial sort
@initially_placed_collabs = @{ &average_and_sort_collabs( \@initially_placed_collabs )  };

my $total_cms_placed = 0;

#While there are still collabs in the stack
while( $#initially_placed_collabs >= 0 ){
	
	my $num_intially_placed_cms = 0;
	foreach my $current_cm (keys %cm_placed ){
		if( $cm_placed{ $current_cm } ){
			$num_intially_placed_cms++;
		}
	}
	if( $#initially_placed_collabs % 10 == 0 ){
		print STDOUT "There are currently $#initially_placed_collabs collabs to place. $num_intially_placed_cms cms have been placed so far.\n";
	}
	$total_cms_placed = $num_intially_placed_cms;
	
	#Place cms from top collab
	my $collab_to_fill = $initially_placed_collabs[ 0 ];
	for (my $cm_index = 0; $cm_index < $num_cm_to_place{ $collab_to_fill } ; $cm_index++) {
		my $current_cm = $cm_sorted_collab{ $collab_to_fill }->[ $cm_index ];
		$cm_collab_assignment{ $current_cm } = $collab_to_fill;
		$cm_placed{ $current_cm } = 1;
	}
	#remove collab from lists
	shift @initially_placed_collabs;
	
	#if on last reference, exit
	if( $#initially_placed_collabs < 0){
		last;
	}	
	
	#recompute averages and resort
	@initially_placed_collabs = @{ &average_and_sort_collabs( \@initially_placed_collabs ) };
}

#Take unfilled collabs and set the number to place at the number of unfilled spots
foreach my $current_collab ( @unfilled_collabs ){
	$num_cm_to_place{ $current_collab } = $collab_characteristics{ $current_collab }->{'collab_capacity'} - 3;
}

#Place cms until run out of cms
@unfilled_collabs = @{ &average_and_sort_collabs( \@unfilled_collabs ) };

my $cms_are_all_placed = 0;

while( $#unfilled_collabs >= 0 ){
	if( ! $cms_are_all_placed ){
		##Place top cm
		my $collab_to_fill = $unfilled_collabs[ 0 ];
		my $current_cm = $cm_sorted_collab{ $collab_to_fill }->[ 0 ];
		#assign top cm in the collab;
		$cm_collab_assignment{ $current_cm } = $unfilled_collabs[ 0 ];
		#carp "placed $current_cm in $collab_to_fill";
		$cm_placed{ $current_cm } = 1;
		$total_cms_placed++;
		
		#Remove collab from list if filled
		$num_cm_to_place{ $collab_to_fill }--;
		if( $num_cm_to_place{ $collab_to_fill } <= 0 ){
			shift @unfilled_collabs;
		}
		
		#carp "The number of unfilled collabs is now $#unfilled_collabs";
		#Re-sort
		my $sort_and_average_return_value = &average_and_sort_collabs( \@unfilled_collabs );
		
		#Check if top collab has any spots left
		if( ($#{ $cm_sorted_collab{ $unfilled_collabs[0] } } < 0) || (ref $sort_and_average_return_value ne 'ARRAY') ){
			$cms_are_all_placed = 1;
			print STDOUT "CMs are all placed\n";
			last;
		}else{
			@unfilled_collabs = @{ $sort_and_average_return_value };
		}
	}
}

print STDOUT "After filling remaining collabs, $total_cms_placed cms have been placed so far.\n";

#for remainder of the collabs, place one blank cm
for (my $collab_index = 0; $collab_index < $#unfilled_collabs; $collab_index++) {
	my $current_collab = $unfilled_collabs[ $collab_index ];
	#Assign negative numbered cm (blank cm) to collab
	$cm_collab_assignment{ ( $collab_index + 1 ) * -1 } = $current_collab;
}

##Compute scores for collabs and CMAs
my %collab_makeup;
my %cma_group_makeup;
my %school_makeup;

foreach my $current_cm ( keys %cm_collab_assignment ){
	#if cm is not a blank cm
	if( $current_cm > 0){
		my $current_collab = $cm_collab_assignment{ $current_cm };
		my $current_cma = $collab_characteristics{ $current_collab }->{'collab_cma'};
		my $current_school = $collab_characteristics{ $current_collab }->{'collab_school'};
		
		$collab_makeup{ $current_collab }->{'num_cms'}++;
		$collab_makeup{ $current_collab }->{'grade_level'}->{ $cm_demographs{$current_cm}->{ 'cm_grade_level' } }++;
		$collab_makeup{ $current_collab }->{'spanish_ability'}->{ $cm_demographs{$current_cm}->{ 'cm_spanish_ability' } }++;
		$collab_makeup{ $current_collab }->{'region'}->{ $cm_demographs{$current_cm}->{ 'cm_region' } }++;
		$collab_makeup{ $current_collab }->{'cm_score_total'} += $collab_cm_score{ $current_collab }->{ $current_cm };
		$collab_makeup{ $current_collab }->{'gender'}->{ $cm_demographs{$current_cm}->{ 'cm_gender' } }++;
		$collab_makeup{ $current_collab }->{'poc'}->{ $cm_demographs{$current_cm}->{ 'cm_poc' } }++;
		$cma_group_makeup{ $current_cma }->{'grade_level'}->{ $cm_demographs{$current_cm}->{ 'cm_grade_level' } }++;
		$cma_group_makeup{ $current_cma }->{'region'}->{ $cm_demographs{$current_cm}->{ 'cm_region' } }++;
		$cma_group_makeup{ $current_cma }->{'gender'}->{ $cm_demographs{$current_cm}->{ 'cm_gender' } }++;
		$cma_group_makeup{ $current_cma }->{'poc'}->{ $cm_demographs{$current_cm}->{ 'cm_poc' } }++;
		$school_makeup{ $current_school }->{'poc'}->{ $cm_demographs{$current_cm}->{ 'cm_poc' } }++;
		$school_makeup{ $current_school }->{'region'}->{ $cm_demographs{$current_cm}->{ 'cm_region' } }++;
	}
}

#Create an array of all cms, including blank ones
my @full_placed_cms = keys %cm_collab_assignment;
my $swaps_made = 0;

for (my $swaps_attempted = 0; $swaps_attempted < $number_of_swaps_to_attempt; $swaps_attempted++) {
	
	if( $swaps_attempted % 50000 == 0 ){
		print "After $swaps_attempted swaps attempted there have been $swaps_made swaps made\n";
	}
	
	
	my $swap_cm1 = $full_placed_cms[ int( rand( $#full_placed_cms + 1 ) ) ];
	my $swap_cm2 = $full_placed_cms[ int( rand( $#full_placed_cms + 1 ) ) ];
	my $swap_collab1 = $cm_collab_assignment{ $swap_cm1 };
	my $swap_collab2 = $cm_collab_assignment{ $swap_cm2 };
		
	my %swap_collab1_makeup = %{$collab_makeup{ $swap_collab1 }};
	my %swap_cma_group1_makeup = %{$cma_group_makeup{ $collab_characteristics{ $swap_collab1 }->{'collab_cma'} }};
	my %swap_school1_makeup = %{$school_makeup{ $collab_characteristics{ $swap_collab1 }->{'collab_school'} }};
	my %swap_collab2_makeup = %{$collab_makeup{ $swap_collab2 }};
	my %swap_cma_group2_makeup = %{$cma_group_makeup{ $collab_characteristics{ $swap_collab2 }->{'collab_cma'} }};
	my %swap_school2_makeup = %{$school_makeup{ $collab_characteristics{ $swap_collab2 }->{'collab_school'} }};
	
	my %swap_collab1_makeup_temp = %swap_collab1_makeup;
	my %swap_cma_group1_makeup_temp = %swap_cma_group1_makeup;
	my %swap_school1_makeup_temp = %swap_school1_makeup;
	my %swap_collab2_makeup_temp = %swap_collab2_makeup;
	my %swap_cma_group2_makeup_temp = %swap_cma_group2_makeup;
	my %swap_school2_makeup_temp = %swap_school2_makeup;
	
	my $collab_original_ref = \%swap_collab1_makeup;
	my $collab_temp_ref = \%swap_collab1_makeup_temp;
	
	my $original_score_1 = &evaluate_collab_cma_group_score( $swap_collab1, \%swap_collab1_makeup, \%swap_cma_group1_makeup, \%swap_school1_makeup);
	my $original_score_2 = &evaluate_collab_cma_group_score( $swap_collab2, \%swap_collab2_makeup, \%swap_cma_group2_makeup, \%swap_school2_makeup);
	
	##Edit each temp makeup to reflect what the makeup would be if two cms were swapped
	#Remove the scores from the current temp
	#cm not blank
	
	if( $swap_cm1 > 0 ){
		$swap_collab1_makeup_temp{'num_cms'}--;
		$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
		$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }--;
		$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
		$swap_collab1_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab1 }->{ $swap_cm1 };
		$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
		$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
		$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
		$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
		$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
		$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
		$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
		$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
		
		$swap_collab2_makeup_temp{'num_cms'}++;
		$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
		$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }++;
		$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
		$swap_collab2_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab2 }->{ $swap_cm1 };
		$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
		$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
		$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
		$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
		$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
		$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
		$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
		$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
	}
	if( $swap_cm2 > 0 ){
		$swap_collab2_makeup_temp{'num_cms'}--;
		$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
		$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }--;
		$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
		$swap_collab2_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab2 }->{ $swap_cm2 };
		$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
		$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
		$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
		$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
		$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
		$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
		$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
		$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
		
		$swap_collab1_makeup_temp{'num_cms'}++;
		$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
		$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }++;
		$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
		$swap_collab1_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab1 }->{ $swap_cm2 };
		$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
		$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
		$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
		$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
		$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
		$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
		$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
		$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
	}
	
	
	my $temp_score_1 = &evaluate_collab_cma_group_score( $swap_collab1, \%swap_collab1_makeup_temp, \%swap_cma_group1_makeup_temp, \%swap_school1_makeup_temp);
	my $temp_score_2 = &evaluate_collab_cma_group_score( $swap_collab2, \%swap_collab2_makeup_temp, \%swap_cma_group2_makeup_temp, \%swap_school2_makeup_temp);
	
	my $original_sum_score = $original_score_1 + $original_score_2;
	my $swap_sum_score = $temp_score_1 + $temp_score_2;

	if( $swap_sum_score > $original_sum_score ){

		#Make swap
		$cm_collab_assignment{ $swap_cm1 } = $swap_collab2;
		$cm_collab_assignment{ $swap_cm2 } = $swap_collab1;
		
		#Set collab and group makeups to the temps already computed
		$collab_makeup{ $swap_collab1 } = \%swap_collab1_makeup_temp;
		$cma_group_makeup{ $swap_collab1 } = \%swap_cma_group1_makeup_temp;
		$school_makeup{ $collab_makeup{ $swap_collab1 }->{'collab_school'} } = \%swap_school1_makeup_temp;
		$collab_makeup{ $swap_collab2 } = \%swap_collab2_makeup_temp;
		$cma_group_makeup{ $swap_collab2 } = \%swap_cma_group2_makeup_temp;
		$school_makeup{ $collab_makeup{ $swap_collab2 }->{'collab_school'} } = \%swap_school2_makeup_temp;
		
		$swaps_made++;
	}else{
		#undo the damage
		if( $swap_cm1 > 0 ){
			$swap_collab1_makeup_temp{'num_cms'}++;
			$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
			$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }++;
			$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
			$swap_collab1_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab1 }->{ $swap_cm1 };
			$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
			$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
			$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
			$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
			$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
			$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
			$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
			$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;

			$swap_collab2_makeup_temp{'num_cms'}--;
			$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
			$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }--;
			$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
			$swap_collab2_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab2 }->{ $swap_cm1 };
			$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
			$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
			$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
			$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
			$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
			$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
			$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
			$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
			
		}
		if( $swap_cm2 > 0 ){
			$swap_collab2_makeup_temp{'num_cms'}++;
			$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
			$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }++;
			$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
			$swap_collab2_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab2 }->{ $swap_cm2 };
			$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
			$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
			$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
			$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
			$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
			$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
			$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
			$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;

			$swap_collab1_makeup_temp{'num_cms'}--;
			$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
			$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }--;
			$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
			$swap_collab1_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab1 }->{ $swap_cm2 };
			$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
			$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
			$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
			$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
			$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
			$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
			$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
			$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
		}
	}
}

print "There were $swaps_made swaps made\n";

my @collab_numbers = keys %collab_characteristics;
my %collab_scores;
foreach my $current_collab (@collab_numbers){
	$collab_scores{$current_collab} = &evaluate_collab_cma_group_score($current_collab, $collab_makeup{ $current_collab }, $cma_group_makeup{ $collab_characteristics{ $current_collab }->{'collab_cma'} }, $school_makeup{ $collab_characteristics{ $current_collab }->{'collab_school'} })
}

for( my $i = 0; $i < $worst_score_iterations; $i++){
	#Set threshold for scores
	my @sorted_scores = sort {$a <=> $b} values %collab_scores;
	my $score_threshold = 0;
	if( $number_of_collabs_to_improve > $#sorted_scores){
		$score_threshold = $sorted_scores[-1];
	}else{
		$score_threshold = $sorted_scores[$number_of_collabs_to_improve];
	}
	#carp "@sorted_scores";
	print STDOUT "Score threshold is $score_threshold for improvement iteration $i\n";
	
	foreach my $current_collab (@collab_numbers){
		if( $collab_scores{$current_collab} <= $score_threshold){
			
			#carp "Collab score is $collab_scores{$current_collab}";
			#Just so that we have something to swap
			my $best_cm_to_swap1 = $full_placed_cms[0];
			my $best_cm_to_swap2 = $full_placed_cms[0];
			my $score_increase = 0;
			
			for my $current_cm1 ( @full_placed_cms){
				if( $cm_collab_assignment{ $current_cm1 } == $current_collab){
					for my $current_cm2 ( @full_placed_cms){
						
						my $swap_cm1 = $current_cm1;
						my $swap_cm2 = $current_cm2;
						
						my $swap_collab1 = $cm_collab_assignment{ $swap_cm1 };
						my $swap_collab2 = $cm_collab_assignment{ $swap_cm2 };

						my %swap_collab1_makeup = %{$collab_makeup{ $swap_collab1 }};
						my %swap_cma_group1_makeup = %{$cma_group_makeup{ $collab_characteristics{ $swap_collab1 }->{'collab_cma'} }};
						my %swap_school1_makeup = %{$school_makeup{ $collab_characteristics{ $swap_collab1 }->{'collab_school'} }};
						my %swap_collab2_makeup = %{$collab_makeup{ $swap_collab2 }};
						my %swap_cma_group2_makeup = %{$cma_group_makeup{ $collab_characteristics{ $swap_collab2 }->{'collab_cma'} }};
						my %swap_school2_makeup = %{$school_makeup{ $collab_characteristics{ $swap_collab2 }->{'collab_school'} }};

						my %swap_collab1_makeup_temp = %swap_collab1_makeup;
						my %swap_cma_group1_makeup_temp = %swap_cma_group1_makeup;
						my %swap_school1_makeup_temp = %swap_school1_makeup;
						my %swap_collab2_makeup_temp = %swap_collab2_makeup;
						my %swap_cma_group2_makeup_temp = %swap_cma_group2_makeup;
						my %swap_school2_makeup_temp = %swap_school2_makeup;

						my $collab_original_ref = \%swap_collab1_makeup;
						my $collab_temp_ref = \%swap_collab1_makeup_temp;

						my $original_score_1 = &evaluate_collab_cma_group_score( $swap_collab1, \%swap_collab1_makeup, \%swap_cma_group1_makeup, \%swap_school1_makeup);
						my $original_score_2 = &evaluate_collab_cma_group_score( $swap_collab2, \%swap_collab2_makeup, \%swap_cma_group2_makeup, \%swap_school2_makeup);

						##Edit each temp makeup to reflect what the makeup would be if two cms were swapped
						#Remove the scores from the current temp
						#cm not blank

						if( $swap_cm1 > 0 ){
							$swap_collab1_makeup_temp{'num_cms'}--;
							$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
							$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }--;
							$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
							$swap_collab1_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab1 }->{ $swap_cm1 };
							$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
							$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
							$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
							$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
							$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
							$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
							$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
							$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;

							$swap_collab2_makeup_temp{'num_cms'}++;
							$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
							$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }++;
							$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
							$swap_collab2_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab2 }->{ $swap_cm1 };
							$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
							$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
							$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
							$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
							$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
							$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
							$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
							$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
						}
						if( $swap_cm2 > 0 ){
							$swap_collab2_makeup_temp{'num_cms'}--;
							$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
							$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }--;
							$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
							$swap_collab2_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab2 }->{ $swap_cm2 };
							$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
							$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
							$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
							$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
							$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
							$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
							$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
							$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;

							$swap_collab1_makeup_temp{'num_cms'}++;
							$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
							$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }++;
							$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
							$swap_collab1_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab1 }->{ $swap_cm2 };
							$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
							$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
							$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
							$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
							$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
							$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
							$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
							$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
						}

						my $temp_score_1 = &evaluate_collab_cma_group_score( $swap_collab1, \%swap_collab1_makeup_temp, \%swap_cma_group1_makeup_temp, \%swap_school1_makeup_temp);
						my $temp_score_2 = &evaluate_collab_cma_group_score( $swap_collab2, \%swap_collab2_makeup_temp, \%swap_cma_group2_makeup_temp, \%swap_school2_makeup_temp);

						my $original_sum_score = $original_score_1 + $original_score_2;
						my $swap_sum_score = $temp_score_1 + $temp_score_2;
						
						my $current_score_increase = ( $swap_sum_score - $original_sum_score );
						
						if( ( $swap_sum_score - $original_sum_score ) > $score_increase ){
							$best_cm_to_swap1 = $swap_cm1;
							$best_cm_to_swap2 = $swap_cm2;
							$score_increase = $swap_sum_score - $original_sum_score;
						}
						
						#undo the damage
						if( $swap_cm1 > 0 ){
							$swap_collab1_makeup_temp{'num_cms'}++;
							$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
							$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }++;
							$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
							$swap_collab1_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab1 }->{ $swap_cm1 };
							$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
							$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
							$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
							$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
							$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
							$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
							$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
							$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;

							$swap_collab2_makeup_temp{'num_cms'}--;
							$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
							$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }--;
							$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
							$swap_collab2_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab2 }->{ $swap_cm1 };
							$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
							$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
							$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
							$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
							$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
							$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
							$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
							$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;

						}
						if( $swap_cm2 > 0 ){
							$swap_collab2_makeup_temp{'num_cms'}++;
							$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
							$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }++;
							$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
							$swap_collab2_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab2 }->{ $swap_cm2 };
							$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
							$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
							$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
							$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
							$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
							$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
							$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
							$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;

							$swap_collab1_makeup_temp{'num_cms'}--;
							$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
							$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }--;
							$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
							$swap_collab1_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab1 }->{ $swap_cm2 };
							$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
							$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
							$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
							$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
							$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
							$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
							$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
							$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
						}
						
					}
				}
			}
		
			#Make best swap
			my $swap_cm1 = $best_cm_to_swap1;
			my $swap_cm2 = $best_cm_to_swap2;
			my $swap_collab1 = $cm_collab_assignment{ $swap_cm1 };
			my $swap_collab2 = $cm_collab_assignment{ $swap_cm2 };
			
			my %swap_collab1_makeup = %{$collab_makeup{ $swap_collab1 }};
			my %swap_cma_group1_makeup = %{$cma_group_makeup{ $collab_characteristics{ $swap_collab1 }->{'collab_cma'} }};
			my %swap_school1_makeup = %{$school_makeup{ $collab_characteristics{ $swap_collab1 }->{'collab_school'} }};
			my %swap_collab2_makeup = %{$collab_makeup{ $swap_collab2 }};
			my %swap_cma_group2_makeup = %{$cma_group_makeup{ $collab_characteristics{ $swap_collab2 }->{'collab_cma'} }};
			my %swap_school2_makeup = %{$school_makeup{ $collab_characteristics{ $swap_collab2 }->{'collab_school'} }};

			my %swap_collab1_makeup_temp = %swap_collab1_makeup;
			my %swap_cma_group1_makeup_temp = %swap_cma_group1_makeup;
			my %swap_school1_makeup_temp = %swap_school1_makeup;
			my %swap_collab2_makeup_temp = %swap_collab2_makeup;
			my %swap_cma_group2_makeup_temp = %swap_cma_group2_makeup;
			my %swap_school2_makeup_temp = %swap_school2_makeup;
			
			my $collab_original_ref = \%swap_collab1_makeup;
			my $collab_temp_ref = \%swap_collab1_makeup_temp;

			my $original_score_1 = &evaluate_collab_cma_group_score( $swap_collab1, \%swap_collab1_makeup, \%swap_cma_group1_makeup, \%swap_school1_makeup);
			my $original_score_2 = &evaluate_collab_cma_group_score( $swap_collab2, \%swap_collab2_makeup, \%swap_cma_group2_makeup, \%swap_school2_makeup);
			

			##Edit each temp makeup to reflect what the makeup would be if two cms were swapped
			#Remove the scores from the current temp
			#cm not blank

			if( $swap_cm1 > 0 ){
				$swap_collab1_makeup_temp{'num_cms'}--;
				$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
				$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }--;
				$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
				$swap_collab1_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab1 }->{ $swap_cm1 };
				$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
				$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
				$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }--;
				$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;
				$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }--;
				$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
				$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }--;
				$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }--;

				$swap_collab2_makeup_temp{'num_cms'}++;
				$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
				$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm1}}->{ 'cm_spanish_ability' }++;
				$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
				$swap_collab2_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab2 }->{ $swap_cm1 };
				$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
				$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
				$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm1}->{ 'cm_grade_level' } }++;
				$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
				$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm1}->{ 'cm_gender' } }++;
				$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
				$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm1}->{ 'cm_poc' } }++;
				$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm1}->{ 'cm_region' } }++;
			}
			if( $swap_cm2 > 0 ){
				$swap_collab2_makeup_temp{'num_cms'}--;
				$swap_collab2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
				$swap_collab2_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }--;
				$swap_collab2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
				$swap_collab2_makeup_temp{'cm_score_total'} -= $collab_cm_score{ $swap_collab2 }->{ $swap_cm2 };
				$swap_collab2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
				$swap_collab2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
				$swap_cma_group2_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }--;
				$swap_cma_group2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;
				$swap_cma_group2_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }--;
				$swap_cma_group2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
				$swap_school2_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }--;
				$swap_school2_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }--;

				$swap_collab1_makeup_temp{'num_cms'}++;
				$swap_collab1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
				$swap_collab1_makeup_temp{'spanish_ability'}->{ $cm_demographs{$swap_cm2}}->{ 'cm_spanish_ability' }++;
				$swap_collab1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
				$swap_collab1_makeup_temp{'cm_score_total'} += $collab_cm_score{ $swap_collab1 }->{ $swap_cm2 };
				$swap_collab1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
				$swap_collab1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
				$swap_cma_group1_makeup_temp{'grade_level'}->{ $cm_demographs{$swap_cm2}->{ 'cm_grade_level' } }++;
				$swap_cma_group1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
				$swap_cma_group1_makeup_temp{'gender'}->{ $cm_demographs{$swap_cm2}->{ 'cm_gender' } }++;
				$swap_cma_group1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
				$swap_school1_makeup_temp{'poc'}->{ $cm_demographs{$swap_cm2}->{ 'cm_poc' } }++;
				$swap_school1_makeup_temp{'region'}->{ $cm_demographs{$swap_cm2}->{ 'cm_region' } }++;
			}

			#Update collab scores
			$collab_scores{$swap_collab1} = &evaluate_collab_cma_group_score( $swap_collab1, \%swap_collab1_makeup_temp, \%swap_cma_group1_makeup_temp, \%swap_school1_makeup_temp);
			$collab_scores{$swap_collab2} = &evaluate_collab_cma_group_score( $swap_collab2, \%swap_collab2_makeup_temp, \%swap_cma_group2_makeup_temp, \%swap_school2_makeup_temp);
			
			#carp "Collab score is now $collab_scores{$swap_collab1}";
			
			#Make swap
			$cm_collab_assignment{ $swap_cm1 } = $swap_collab2;
			$cm_collab_assignment{ $swap_cm2 } = $swap_collab1;

			#Set collab and group makeups to the temps already computed
			$collab_makeup{ $swap_collab1 } = \%swap_collab1_makeup_temp;
			$cma_group_makeup{ $swap_collab1 } = \%swap_cma_group1_makeup_temp;
			$school_makeup{ $collab_makeup{ $swap_collab1 }->{'collab_school'} } = \%swap_school1_makeup_temp;
			$collab_makeup{ $swap_collab2 } = \%swap_collab2_makeup_temp;
			$cma_group_makeup{ $swap_collab2 } = \%swap_cma_group2_makeup_temp;
			$school_makeup{ $collab_makeup{ $swap_collab2 }->{'collab_school'} } = \%swap_school2_makeup_temp;
			
		}
	}
}



select CM_COLLAB_OUTFILE;

print "cm\tcollab\tcm_collab_score\t", 
"cm_hired\t",
"cm_exact_match_critical\t",
"flag_school_match\t",
"cm_school\t",
"collab_school\t",
"flag_sped_placement_in_sped\t",
"cm_has_sped_placement\t",
"collab_sped_placement\t",
"flag_prek_k_match\t",
"flag_prek_k_within_1\t",
"flag_distance_from_target_grade\t",
"cm_grade\t",
"collab_grade\t",
"flag_subject_or_grade_level_match\t",
"flag_grade_level_match\t",
"cm_grade_level\t",
"collab_grade_level\t",
"flag_math_science_match\t",
"flag_general_subject_match\t",
"cm_general_subject\t",
"collab_general_subject\t",
"flag_specific_subject_match\t",
"cm_specific_subject\t",
"collab_specific_subject\t",
"flag_major_general_subject_match\t",
"flag_major_specific_subject_match\t",
"cm_major\t",
"flag_bilingual_placement_in_bilingual_classroom\t",
"flag_spanish_ability_in_bilingual_classroom\t",
"flag_spanish_ability_in_lower_grades\t",
"cm_bilingual_placement\t",
"cm_spanish_ability\t",
"collab_bilingual_classroom\t",
"cm_region\t",
"collab_capacity\t",
"flag_cma_group_request_match\t",
"cma_group_request\t",
"collab_cma\t",
"flag_collab_request_match\t",
"collab_request\t",
"collab\t",
"\n";

my @list_of_cm_characteristics = keys %cm_demographs;
foreach my $current_cm ( keys %cm_collab_assignment ){
	my $current_collab = $cm_collab_assignment{ $current_cm };
	my %score_rationalle;
	print "$current_cm\t", $current_collab, "\t", $collab_cm_score{ $current_collab }->{ $current_cm }, "\t";
	&score_cm_collab_combo( $current_cm, $current_collab, \%score_rationalle );
	
	print "$cm_demographs{ $current_cm }->{'cm_hired'}\t";
	print "$cm_demographs{ $current_cm }->{'cm_exact_match_critical'}\t";
	
	print "$score_rationalle{ $current_cm }->{'school_match'}\t";
	my $item_to_print;
	if( defined $cm_demographs{ $current_cm }->{'cm_school'} ){
		$item_to_print = join ",", @{$cm_demographs{ $current_cm }->{'cm_school'}};
		print "$item_to_print\t";
	}else{
		print "\t";
	}
	print "$collab_characteristics{ $current_collab }->{ 'collab_school' }\t";
	
	print "$score_rationalle{ $current_cm }->{'sped_placement_in_sped'}\t";
	print "$cm_demographs{ $current_cm }->{'cm_has_sped_placement'}\t";
	print "$collab_characteristics{ $current_collab }->{ 'collab_sped_placement' }\t";
	
	print "$score_rationalle{ $current_cm }->{'prek_k_match'}\t";
	print "$score_rationalle{ $current_cm }->{'prek_k_within_1'}\t";
	print "$score_rationalle{ $current_cm }->{'distance_from_target_grade'}\t";
	$item_to_print = join ",", @{$cm_demographs{ $current_cm }->{'cm_grade'}};
	print "$item_to_print\t";
	$item_to_print = join ",", @{$collab_characteristics{ $current_collab }->{ 'collab_grade' }};
	print "$item_to_print\t";
	
	print "$score_rationalle{ $current_cm }->{'subject_or_grade_level_match'}\t";
	print "$score_rationalle{ $current_cm }->{'grade_level_match'}\t";
	print "$cm_demographs{ $current_cm }->{'cm_grade_level'}\t";
	print "$collab_characteristics{ $current_collab }->{ 'collab_grade_level' }\t";
	
	print "$score_rationalle{ $current_cm }->{'math_science_match'}\t";
	print "$score_rationalle{ $current_cm }->{'general_subject_match'}\t";
	$item_to_print = join ",", @{$cm_demographs{ $current_cm }->{'cm_general_subject'}};
	print "$item_to_print\t";
	$item_to_print = join ",", @{$collab_characteristics{ $current_collab }->{'collab_general_subject'}};
	print "$item_to_print\t";
	
	print "$score_rationalle{ $current_cm }->{'specific_subject_match'}\t";
	$item_to_print = join ",", @{$cm_demographs{ $current_cm }->{'cm_specific_subject'}};
	print "$item_to_print\t";
	$item_to_print = join ",", @{$collab_characteristics{ $current_collab }->{'collab_specific_subject'}};
	print "$item_to_print\t";
	
	print "$score_rationalle{ $current_cm }->{'major_general_subject_match'}\t";
	print "$score_rationalle{ $current_cm }->{'major_specific_subject_match'}\t";
	print "$cm_demographs{ $current_cm }->{'cm_major'}\t";
	
	print "$score_rationalle{ $current_cm }->{'bilingual_placement_in_bilingual_classroom'}\t";
	print "$score_rationalle{ $current_cm }->{'spanish_ability_in_bilingual_classroom'}\t";
	print "$score_rationalle{ $current_cm }->{'spanish_ability_in_lower_grades'}\t";
	print "$cm_demographs{ $current_cm }->{'cm_bilingual_placement'}\t";
	print "$cm_demographs{ $current_cm }->{'cm_spanish_ability'}\t";
	print "$collab_characteristics{ $current_collab }->{ 'collab_bilingual_classroom' }\t";
	
	print "$cm_demographs{ $current_cm }->{'cm_region'}\t";
	print "$collab_characteristics{ $current_collab }->{ 'collab_capacity' }\t";
	print "$score_rationalle{ $current_cm }->{ 'cma_group_request_match' }\t";
	print "$cm_demographs{ $current_cm }->{'cm_cma_group_request'}\t";
	print "$collab_characteristics{ $current_collab }->{ 'collab_cma' }\t";
	
	print "$score_rationalle{ $current_cm }->{ 'collab_request_match' }\t";
	print "$cm_demographs{ $current_cm }->{'cm_collab_request'}\t";
	print "$current_collab\t";
		
	print "\n";
}

close CM_COLLAB_OUTFILE;

select CM_PLACEMENT_ALIGNMENT_REPORT;

print "cm pid\tfirst name\tlast name\t",
"summary of mis-alignments\t",
"number ofalignment issues\t",
"placement alignment issues\t",
"region\t",
"hired status?\t",
"fall school\t",
"summer school\t",
"fall grade level\t",
"summer grade level\t",
"cm general subject\t",
"collab general subject\t",
"distance from fall grade\t",
"fall grade\t",
"summer grade\t",
"fall specific subject\t",
"summer specific subject\t",
"fall bilingual placement\t",
"summer bilingual classroom\t",
"cm has SPED placement\t",
"summer SPED classroom\t",
"cma group request\t",
"collab cma\t",
"\n";

my @region_report_rows;
my %major_mismatches_by_region;

foreach my $current_cm ( keys %cm_collab_assignment ){
    my $current_collab = $cm_collab_assignment{ $current_cm };
	my $current_collab_characterstics = $collab_characteristics{ $cm_collab_assignment{ $current_cm } };
	my %score_rationalle;
	my $cur_cm_demograph = $cm_demographs{ $current_cm };
	
	&score_cm_collab_combo( $current_cm, $current_collab, \%score_rationalle );
		my $cur_cm_score = $score_rationalle{ $current_cm };
		
	my @mismatches;
	
	if( $cur_cm_score->{'grade_level_match'} != 1 ){
	    push @mismatches, "Grade level for summer doesn't match grade level for fall";
	}
	if( $cur_cm_score->{'general_subject_match'} != 1 ){
	    push @mismatches, "Subject group for summer doesn't match subject group for fall";
	}
	if( $cur_cm_score->{'distance_from_target_grade'} < -4 ){
	    push @mismatches, "Grade level for summer more than 4 grades distant from what they'll be teaching in the fall";
	}
	if( $cur_cm_score->{'bilingual_placement_in_bilingual_classroom'} eq '0' ){
	    push @mismatches, "CM is teaching in a bilingual placement in the fall but is not teaching in a bilingual environment in the summer";
	}
	if( $cur_cm_score->{'sped_placement_in_sped'} eq '0' ){
	    push @mismatches, "CM is teaching in a SPED placement in the fall but is not teaching in a SPED environment in the summer";
	}
	if( $cur_cm_score->{'cma_group_request_match'} eq '0' ){
	    push @mismatches, "CMA group request not met";
	}
	if( $cur_cm_score->{'collab_request_match'} eq '0' ){
	    push @mismatches, "Collab group request not met";
	}
	if( $cur_cm_score->{'school_match'} eq '0' ){
	    push @mismatches, "School request not met";
	}
	
	my $number_of_mismatches = 0;
	if( $#mismatches >= 0 ){
	    $number_of_mismatches = $#mismatches + 1;
	}
	my $issues = join "; ", @mismatches;;
	my $mismatch_severity = "Placement matches";
	if( $cur_cm_score->{'grade_level_match'} != 1 || $cur_cm_score->{'general_subject_match'} != 1 ){
	    $mismatch_severity = "Primary mismatch in subject or grade";
	}elsif( $#mismatches >= 0  ){
	    $mismatch_severity = "Mismatches do not include subject or grade";
	}
	
	my $school_to_print;
	if( defined $cm_demographs{ $current_cm }->{'cm_school'} ){
		$school_to_print = join ",", @{$cm_demographs{ $current_cm }->{'cm_school'}};
	}
	
	my @grades_for_fall;
	foreach my $grade (@{$cur_cm_demograph->{'cm_grade'}} ){
	    if( $grade eq "0"){
	        $grade = "K";
	    }
	    if( $grade eq "-1"){
	        $grade = "PK";
	    }
	    push @grades_for_fall, $grade;
	}
	
	my @grades_for_summer;
	foreach my $grade (@{$current_collab_characterstics->{'collab_grade'}} ){
	    if( $grade eq "0"){
	        $grade = "K";
	    }
	    if( $grade eq "-1"){
	        $grade = "PK";
	    }
	    push @grades_for_summer, $grade;
	}
	
	my @current_report_row = (
	    $current_cm,$cur_cm_demograph->{'cm_first_name'},$cur_cm_demograph->{'cm_last_name'},
	    $mismatch_severity,
	    $number_of_mismatches,
	    $issues,
	    $cur_cm_demograph->{'cm_region'},
	    $cur_cm_demograph->{'cm_hired'},
	    $school_to_print,
	    $current_collab_characterstics->{'collab_school'},
	    $cur_cm_demograph->{'cm_grade_level'},
	    $current_collab_characterstics->{'collab_grade_level'},
	    join(",",@{$cur_cm_demograph->{'cm_general_subject'}}),
	    join(",",@{$current_collab_characterstics->{'collab_general_subject'}}),
	    $cur_cm_score->{'distance_from_target_grade'},
	    join(",",@grades_for_fall),
	    join(",",@grades_for_summer),
	    join(",",@{$cur_cm_demograph->{'cm_specific_subject'}}),
	    join(",",@{$current_collab_characterstics->{'collab_specific_subject'}}),
	    $cur_cm_demograph->{'cm_bilingual_placement'},
	    $current_collab_characterstics->{'collab_bilingual_classroom'},
	    $cur_cm_demograph->{'cm_has_sped_placement'},
	    $current_collab_characterstics->{'collab_sped_placement'},
	    $cur_cm_demograph->{'cm_cma_group_request'},
	    $current_collab_characterstics->{'collab_cma'},
	);
	push @region_report_rows, { 'row' => \@current_report_row, 'region' => $cur_cm_demograph->{'cm_region'}, 'num_mismatches' => $#mismatches + 1 };
	unless( exists $major_mismatches_by_region{ $cur_cm_demograph->{'cm_region'} } ){
	    $major_mismatches_by_region{ $cur_cm_demograph->{'cm_region'} } = {'total_cms' => 0, 'total_major_mismatches' => 0, 'mismatch_counts' => [], 'threshold_for_flagging' => undef}
	}
	$major_mismatches_by_region{ $cur_cm_demograph->{'cm_region'} }->{'total_cms'}++;
	if(  $#mismatches > 0 ){
	    $major_mismatches_by_region{ $cur_cm_demograph->{'cm_region'} }->{'total_major_mismatches'}++;
	    push @{ $major_mismatches_by_region{ $cur_cm_demograph->{'cm_region'} }->{'mismatch_counts'} }, $#mismatches + 1;
	}
}

#If greater than threshold of CMs have major mismatch, determine threshold to flag at
#foreach my $region ( keys( %major_mismatches_by_region ) ){
#    if( $major_mismatches_by_region{ $region }->{'total_major_mismatches'} / $major_mismatches_by_region{ $region }->{'total_cms'} > 0.05 && $major_mismatches_by_region{ $region }->{'total_major_mismatches'} > 10 ){
#        my @mismatch_counts = sort { $b <=> $a } @{ $major_mismatches_by_region{ $region }->{'mismatch_counts'} };
#        my $five_percent_cm = int( $major_mismatches_by_region{ $region }->{'total_cms'} * 0.05 ) - 1;
#        $major_mismatches_by_region{ $region }->{'threshold_for_flagging'} = $mismatch_counts[ $five_percent_cm ];
#    }
#}

foreach my $region_report_row ( @region_report_rows ){
    #my $threshold_for_region = $major_mismatches_by_region{ $region_report_row->{'region'} }->{'threshold_for_flagging'};
    #if (defined $threshold_for_region && $threshold_for_region > 0 && $region_report_row->{'num_mismatches'} > $threshold_for_region ){
    #    $region_report_row->{'row'}[3] = "Very Major - two or more mis-alignments and in top 5% for most mismatches in region";
    #}
    print join("\t", @{ $region_report_row->{'row'} }) . "\n";
}


close CM_PLACEMENT_ALIGNMENT_REPORT;

select COLLAB_SCORE_OUTFILE;
print "collab\tcma_group\tcm_collab_score\t",join ("\t", @collab_cma_group_score_comments_keys), "\t", join ("\t", @collab_characteristics_keys), "\n";
#Print out collab cma group comments
foreach my $current_collab ( keys %collab_makeup ){
	my $current_cma_group = $collab_characteristics{ $current_collab }->{'collab_cma'};
	my @current_cma_group_score_comments;
	
	my $current_collab_cma_score = &evaluate_collab_cma_group_score( $current_collab, $collab_makeup{ $current_collab }, $cma_group_makeup{$current_cma_group}, $school_makeup{ $collab_characteristics{ $current_collab }->{'collab_school'} }, \@current_cma_group_score_comments);
	print "$current_collab\t$current_cma_group\t$current_collab_cma_score\t";
	
	my %current_score_comments_hash = %{ $current_cma_group_score_comments[0] };
	foreach my $comment_type ( @collab_cma_group_score_comments_keys ){
		print "$current_score_comments_hash{ $comment_type }\t";
	}
	foreach my $current_characteristics_key ( @collab_characteristics_keys ){
		my $item_to_print = $collab_characteristics{ $current_collab }->{ $current_characteristics_key };
		if( ref $item_to_print eq 'ARRAY'){
			$item_to_print = join ",", @{$item_to_print};
		}
		print "$item_to_print\t";
	}
	print "\n";
}

close COLLAB_SCORE_OUTFILE;

#Produce alignment analysis
select PLACEMENT_ALIGNMENT_OUTFILE;
print "metric\tinstitute_region_alignment\tplacement_efficiency\tpercent_of_cms_meeting_criteria\n";
my @cm_characterics_to_evaluate = ("cm_grade","cm_has_sped_placement","cm_grade_level","cm_general_subject","cm_specific_subject","cm_bilingual_placement", "cma_group_same_region", "collab_group_same_region");
my @collab_characteristics_to_evaluate = ("collab_grade","collab_sped_placement","collab_grade_level","collab_general_subject","collab_specific_subject","collab_bilingual_classroom");
my %collab_cm_characteristics_map = (
	"collab_grade" => "cm_grade",
	"collab_sped_placement" => "cm_has_sped_placement",
	"collab_grade_level" => "cm_grade_level",
	"collab_general_subject" => "cm_general_subject",
	"collab_specific_subject" => "cm_specific_subject",
	"collab_bilingual_classroom" => "cm_bilingual_placement"
);
my %cm_collab_characteristics_map = reverse %collab_cm_characteristics_map;

my %placement_count;


#Create aggregation for all cm characteristics
foreach my $current_characteristic ( @cm_characterics_to_evaluate ){
	my %fall_placement_count;
	my %summer_placement_count;
	my %current_characteristic_count;
	foreach my $current_cm ( keys %cm_demographs ){
		if( $current_cm > 0 ){
			my @fall_placement_values;
			my @summer_placement_values;
			
			#Create aggregation for fall values
			if( ref $cm_demographs{ $current_cm}->{$current_characteristic} ){
				@fall_placement_values = @{ $cm_demographs{ $current_cm}->{$current_characteristic} };
			}else{
				@fall_placement_values = ( $cm_demographs{ $current_cm}->{$current_characteristic} );
			}
			foreach my $current_placement_value ( @fall_placement_values ){
				if( exists $fall_placement_count{ $current_placement_value }){
					$fall_placement_count{ $current_placement_value } += 1 / ( $#fall_placement_values + 1 );
				}else{
					$fall_placement_count{ $current_placement_value } = 1 / ( $#fall_placement_values + 1 );
				}
			}
			
			#Create aggregation for summer values
			if( ref $collab_characteristics{ $cm_collab_assignment{ $current_cm } }->{ $cm_collab_characteristics_map{ $current_characteristic } } ){
				@summer_placement_values = @{ $collab_characteristics{ $cm_collab_assignment{ $current_cm } }->{ $cm_collab_characteristics_map{ $current_characteristic } } };
			}else{
				@summer_placement_values = ( $collab_characteristics{ $cm_collab_assignment{ $current_cm } }->{ $cm_collab_characteristics_map{ $current_characteristic } } );
			}
			
			#Check whether the fall and summer placement values match before marking an alignment
			my $placement_values_match = 0;
			foreach my $current_summer_placement_value ( @summer_placement_values ){
				foreach my $current_fall_placement_value ( @fall_placement_values ){
					if( $current_summer_placement_value eq $current_fall_placement_value ){
						$placement_values_match = 1;
					}
				}
			}
			if( $placement_values_match ){
				foreach my $current_placement_value ( @fall_placement_values ){
					if( exists $summer_placement_count{ $current_placement_value }){
						$summer_placement_count{ $current_placement_value } += 1 / ( $#fall_placement_values + 1 );
					}else{
						$summer_placement_count{ $current_placement_value } = 1 / ( $#fall_placement_values + 1 );
					}
				}
			}
		}
	}
	$current_characteristic_count{"summer_actual"} = \%summer_placement_count;
	$current_characteristic_count{"fall"} = \%fall_placement_count;
	$placement_count{$current_characteristic} = \%current_characteristic_count;
}

#Create aggregation for all summer placements
foreach my $current_characteristic ( @collab_characteristics_to_evaluate ){
	my %summer_classroom_count;
	my %current_characteristic_count;
	foreach my $current_collab ( keys %collab_characteristics ){
		if( $current_collab > 0 ){
			my @summer_classroom_values;

			#Create aggregation for fall values
			if( ref $collab_characteristics{ $current_collab }->{$current_characteristic} ){
				@summer_classroom_values = @{ $collab_characteristics{ $current_collab }->{$current_characteristic} };
			}else{
				@summer_classroom_values = ( $collab_characteristics{ $current_collab }->{$current_characteristic} );
			}
			foreach my $current_placement_value ( @summer_classroom_values ){
				if( exists $summer_classroom_count{ $current_placement_value }){
					$summer_classroom_count{ $current_placement_value } += $collab_characteristics{ $current_collab }->{ "collab_capacity" } / ( $#summer_classroom_values + 1 );
				}else{
					$summer_classroom_count{ $current_placement_value } = $collab_characteristics{ $current_collab }->{ "collab_capacity" } / ( $#summer_classroom_values + 1 );
				}
			}
		}
	}
	$placement_count{ $collab_cm_characteristics_map{ $current_characteristic } }->{"summer_available"} = \%summer_classroom_count;
}

##Determine alignment characteristics for CM regions
#Create scores for institute and regional alignment
my %regional_cm_count;

foreach my $current_cm ( keys %cm_demographs ) {
	$regional_cm_count{ $cm_demographs{ $current_cm }->{'cm_region'} }++;
}

$placement_count{ 'cma_group_same_region' }->{"fall"} = \%regional_cm_count;
$placement_count{ 'collab_group_same_region' }->{"fall"} = \%regional_cm_count;

my %modified_regional_cm_count;

#Zero out cases where there couldn't be pairing
foreach my $current_region ( keys %modified_regional_cm_count ){
	if ( $modified_regional_cm_count{ $current_region } < 2 ){
		 $modified_regional_cm_count{ $current_region } = 0;
	}
}

$placement_count{ 'cma_group_same_region' }->{"summer_available"} = \%modified_regional_cm_count;
$placement_count{ 'collab_group_same_region' }->{"summer_available"} = \%modified_regional_cm_count;

#Set actual alignment
my %actual_summer_region_pair_in_cma_group_count;
my %actual_summer_region_pair_in_collab_group_count;

foreach my $current_cm ( keys %cm_demographs ) {
	if( $cma_group_makeup{ $collab_characteristics{ $cm_collab_assignment{ $current_cm } }->{'collab_cma'} }->{'region'}->{ $cm_demographs{ $current_cm }->{'cm_region'} } > 1 ){
		$actual_summer_region_pair_in_cma_group_count{ $cm_demographs{ $current_cm }->{'cm_region'} }++;
	}
	if( $collab_makeup{ $cm_collab_assignment{ $current_cm } }->{'region'}->{ $cm_demographs{ $current_cm }->{'cm_region'} } > 1 ){
		$actual_summer_region_pair_in_collab_group_count{ $cm_demographs{ $current_cm }->{'cm_region'} }++;
	}
}

$placement_count{ 'cma_group_same_region' }->{"summer_actual"} = \%actual_summer_region_pair_in_cma_group_count;
$placement_count{ 'collab_group_same_region' }->{"summer_actual"} = \%actual_summer_region_pair_in_collab_group_count;

#Compute analysis for each characteristic
foreach my $current_characteristic ( @cm_characterics_to_evaluate ){
	#Compute ideal placement
	my %ideal_placement;
	my %result_value = %{ &ideal_placement_from_hash( $placement_count{ $current_characteristic }->{"summer_available"}, $placement_count{ $current_characteristic }->{"fall"} ) };
	if( exists $result_value{"error"} ){
		die "Computing ideal placement failed: $result_value{'error_display'}";
	}else{
		%ideal_placement = %{$result_value{"ideal_placement"}};
	}

	#Compute similarity and efficiency
	%result_value = %{ &similarity_and_efficiency_from_hash( $placement_count{ $current_characteristic }->{"summer_available"}, $placement_count{ $current_characteristic }->{"fall"}, \%ideal_placement, $placement_count{ $current_characteristic }->{"summer_actual"} ) };

	if( exists $result_value{"error"} ){
		die "Computing similarity and efficiency failed: $result_value{'error_display'}";
	}

	print "$current_characteristic\t$result_value{ 'institute_region_alignment' }\t$result_value{ 'recommdendation_efficiency' }\t$result_value{ 'percent_of_cms_meeting_criteria' }\n";
}

select STDOUT;
print "Collab builder has successfully completed. Please open the output files for the suggested CM placements.\n";

sub ideal_placement_from_hash {
	my %placement_set_one = %{shift @_};
	my %placement_set_two = %{shift @_};
	my %ideal_placement;
	my %result_value;
	my %return_value;
	
	#Check that keys match for all
	unless( &align_hash_keys(\%placement_set_one, \%placement_set_two) ){
		$return_value{"error"} = "unable_to_align";
		$return_value{"error_display"} = "Unable to align hashes of keys when computing ideal placement";
		return \%return_value;
	}
	
	#For each key, populate ideal placement with minimum of two hashes;
	my @main_keys = keys %placement_set_one;
	
	foreach my $current_key ( @main_keys ){
		$placement_set_one{ $current_key } <= $placement_set_two{ $current_key } ? $ideal_placement{ $current_key } = $placement_set_one{ $current_key } : $ideal_placement{ $current_key } = $placement_set_two{ $current_key };
	}
	$return_value{"ideal_placement"} = \%ideal_placement;
	return \%return_value;
}

sub align_hash_keys {
	my @hashes_to_align = @_;
	if( $#hashes_to_align == 0 ){
		return 1;
	}
	#Check that all hashes to align are actual hashes
	foreach my $current_hash (@hashes_to_align){
		unless( ref $current_hash  eq "HASH" ){
			return 0;
		}
	}
	#align first two hashes
	my @key_set_one = keys %{$hashes_to_align[0]};
	my @key_set_two = keys %{$hashes_to_align[1]};
	my $list_comparison = List::Compare->new(\@key_set_one, \@key_set_two);
	my @total_keys = $list_comparison->get_union;
	#align remaining hashes
	for( my $i = 2; $i <= $#hashes_to_align; $i++){
		my @current_key_set = keys %{$hashes_to_align[$i]};
		$list_comparison = List::Compare->new(\@total_keys, \@current_key_set);
		@total_keys = $list_comparison->get_union;
	}
	#Fill values for any missing keys with 0
	foreach my $current_hash_ref (@hashes_to_align){
		foreach my $current_key (@total_keys){
			unless ( exists $current_hash_ref->{$current_key} ){
				$current_hash_ref->{$current_key} = 0;
			}
		}
	}
	return 1;
}

sub similarity_and_efficiency_from_hash {
	my %classroom_landscape = %{shift @_};
	my %placement_landscape = %{shift @_};
	my %ideal_summer_placement_landscape = %{shift @_};
	my %actual_summer_placement_landscape = %{shift @_};
	my %result_value;
	my %return_value;
	
	#Align keys for all
	unless( &align_hash_keys(\%classroom_landscape, \%placement_landscape, \%ideal_summer_placement_landscape, \%actual_summer_placement_landscape) ){
		$return_value{"error"} = "unable_to_align";
		$return_value{"error_display"} = "Unable to align hashes of keys when computing simlilarity_and_efficiency";
		return \%return_value;
	}
	
	my @main_keys = sort keys %classroom_landscape;
	
	#Create the vectors
	my $classroom_vector = V(map { $classroom_landscape{ $_ } } @main_keys);
	my $placement_vector = V(map { $placement_landscape{ $_ } } @main_keys);
	my $ideal_summer_placement_vector = V(map { $ideal_summer_placement_landscape{ $_ } } @main_keys);
	my $actual_summer_placement_vector = V(map { $actual_summer_placement_landscape{ $_ } } @main_keys);
	
	#Construct arrays for determining % met criteria
	my @placement_values = map { $placement_landscape{ $_ } } @main_keys;
	my @actual_summer_placement_values = map { $actual_summer_placement_landscape{ $_ } } @main_keys;
	
	
	#Compute values
	eval { $return_value{"institute_region_alignment"} = $classroom_vector->versor * $placement_vector->versor; };
	eval { $return_value{"recommdendation_efficiency"} = $ideal_summer_placement_vector->versor * $actual_summer_placement_vector->versor; };
	
	#Compute percent met criteria
	my $total_cms_considered;
	my $total_cms_meeting_criteria;
	foreach my $current_value ( @placement_values ){
		$total_cms_considered += $current_value;
	}
	foreach my $current_value ( @actual_summer_placement_values ){
		$total_cms_meeting_criteria += $current_value;
	}
	$return_value{"percent_of_cms_meeting_criteria"} = $total_cms_meeting_criteria / $total_cms_considered;
	
	return \%return_value;
}

sub score_cm_collab_combo {
	my $cm_collab_total_score = 0;
	
	my $current_cm = $_[0];
	my $current_collab = $_[1];
	my %current_comments;
	
	
	#Check whether schools match - if no school is listed for CM or school is not one of our placements, skip this entirely
	if( ( $cm_demographs{ $current_cm }->{ 'cm_school' } ne "" ) ){
		my $school_match_found = 0;
		for my $current_school ( @{ $cm_demographs{ $current_cm }->{ 'cm_school' } }){
			if( ($cm_demographs{ $current_cm }->{ 'cm_region' } eq $institute || ($cm_demographs{ $current_cm }->{ 'cm_school_request' } ne "") ) && ($current_school eq $collab_characteristics{ $current_collab }->{ 'collab_school' }) ){
				$cm_collab_total_score += $school_match_biweight[ 0 ];
				$current_comments{ 'school_match' } = "1";
				$school_match_found = 1;
				last;
			}
		}
		unless( $school_match_found ){
			$cm_collab_total_score += $school_match_biweight[ 1 ];
			$current_comments{ 'school_match' } = "0";
		}
	}
	
	#Check whether cma group request matches - if no cma group is listed for CM, skip this entirely
	if( ( $cm_demographs{ $current_cm }->{ 'cm_cma_group_request' } ne "" ) ){
		my $cma_match_found = 0;
		for my $current_potential_cma_group (@{ $cm_demographs{ $current_cm }->{ 'cm_potential_cma_group_request' } } ){
			if( $current_potential_cma_group eq $collab_characteristics{ $current_collab }->{ "collab_cma" } ){
				$cma_match_found = 1;
			}
		}
		if( $cma_match_found ){
			$cm_collab_total_score += $cma_group_request_match_biweight[ 0 ];
			$current_comments{ 'cma_group_request_match' } = "1";
		}else{
			$cm_collab_total_score += $cma_group_request_match_biweight[ 1 ];
			$current_comments{ 'cma_group_request_match' } = "0";
		}
	}
	
	#Check whether collab request matches - if no colab is listed for CM, skip this entirely
	if( ( $cm_demographs{ $current_cm }->{ 'cm_collab_request' } ne "" ) ){
		my $collab_match_found = 0;
		for my $current_potential_collab (@{ $cm_demographs{ $current_cm }->{ 'cm_potential_collabs' }}){
			if( $current_potential_collab eq $current_collab ){
				$cm_collab_total_score += $collab_request_match_biweight[ 0 ];
				$current_comments{ 'collab_request_match' } = "1";
				$collab_match_found = 1;
			}
		}
		unless( $collab_match_found ){
			$cm_collab_total_score += $collab_request_match_biweight[ 1 ];
			$current_comments{ 'collab_request_match' } = "0";
		}
	}
	
	#Check whether PK, K match - if CM does not have PK, K placement, then skip #Chicago 2010 - do not place K in PK
	if( ( $cm_demographs{ $current_cm }->{ 'cm_grade' }[0] < 1 ) && ( $#{$cm_demographs{ $current_cm }->{ 'cm_grade' }} >= 0 ) ){
		if( $collab_characteristics{ $current_collab }->{ 'collab_grade' }[ 0 ] == $cm_demographs{ $current_cm }->{ 'cm_grade' }[0] ){
			$cm_collab_total_score += $exact_match_pk_k_biweight[ 0 ];
			$current_comments{ 'prek_k_match' } = "1";
		}else{
			$cm_collab_total_score += $exact_match_pk_k_biweight[ 1 ];
			$current_comments{ 'prek_k_match' } = "0";
		}
	}
	
	#Check whether PK, K is within a year of placement - if CM does not have a PK/K placement, skip entirely #Chicago 2010 - do not place K in PK
	if( ( $cm_demographs{ $current_cm }->{ 'cm_grade' }[0] < 1 ) && ( $#{$cm_demographs{ $current_cm }->{ 'cm_grade' }} >= 0 ) ){
		if( abs( $collab_characteristics{ $current_collab }->{ 'collab_grade' }[ 0 ] - $cm_demographs{ $current_cm }->{ 'cm_grade' }[0] ) <= 1 ){
			$cm_collab_total_score += $within_year_pk_k_biweight[ 0 ];
			$current_comments{ 'prek_k_within_1' } = "1";
		}else{
			$cm_collab_total_score += $within_year_pk_k_biweight[ 1 ];
			$current_comments{ 'prek_k_within_1' } = "0";
		}
	}
	#Check whether sped placed CM is in sped school - if CM does not have a sped placement, then skip
	if( $cm_demographs{ $current_cm }->{ 'cm_has_sped_placement' } == 1 ){
		if( $collab_characteristics{ $current_collab }->{ 'collab_sped_placement' } == 1){
			$cm_collab_total_score += $sped_placement_in_sped_biweight[ 0 ];
			$current_comments{ 'sped_placement_in_sped' } = "1";
		}else{
			$cm_collab_total_score += $sped_placement_in_sped_biweight[ 1 ];
			$current_comments{ 'sped_placement_in_sped' } = "0";
		}
	}
	
	#Check whether school types match
	unless( $cm_demographs{ $current_cm }->{ 'cm_grade_level' } eq "" ){
		if( $cm_demographs{ $current_cm }->{ 'cm_grade_level' } eq $collab_characteristics{ $current_collab }->{ 'collab_grade_level' } ){
			$cm_collab_total_score += $same_grade_level_biweight[ 0 ];
			$current_comments{ 'grade_level_match' } = "1";
		}else{
			$cm_collab_total_score += $same_grade_level_biweight[ 1 ];
			$current_comments{ 'grade_level_match' } = "0";
		}
	}
	
	my $current_cm_hired_multiplier;
	if( $cm_demographs{ $current_cm }->{"cm_hired"} eq "Hired - grade/subject confirmed" ){
		$current_cm_hired_multiplier = $hired_confirmed_multiplier;
	}elsif( $cm_demographs{ $current_cm }->{"cm_hired"} eq "Hired - grade/subject not confirmed" ){
		$current_cm_hired_multiplier = $hired_unconfirmed_multiplier;
	}else{
		$current_cm_hired_multiplier = $non_hired_multiplier;
	}
	my $current_cm_major_hired_offset_multiplier = $current_cm_hired_multiplier / $current_cm_hired_multiplier;
		
	#Check whether specific subject matches
	my $specifc_subject_matches = 0;
	my $major_specifc_subject_matches = 0;
	my $current_cm_major_specific_subject = $major_specific_subject_map{ $cm_demographs{ $current_cm }->{ 'cm_major' } };
	foreach my $current_cm_subject ( @{ $cm_demographs{ $current_cm }->{ 'cm_specific_subject' } }){
		foreach my $current_collab_subject ( @{ $collab_characteristics{ $current_collab }->{ 'collab_specific_subject' } }){
			if( $current_cm_subject eq $current_collab_subject ){
				$specifc_subject_matches = 1;
			}
			if( $current_cm_major_specific_subject eq $current_collab_subject ){
				$major_specifc_subject_matches = 1;
			}
		}
	}
	
	my $specific_subject_score_addition;
	my $major_specific_subject_score_addition;
	if( $specifc_subject_matches ){
		$specific_subject_score_addition = $same_specific_subject_biweight[ 0 ];
		$current_comments{ 'specific_subject_match' } = "1";
	}else{
		$specific_subject_score_addition = $same_specific_subject_biweight[ 1 ];
		$current_comments{ 'specific_subject_match' } = "0";
	}
	if( $major_specifc_subject_matches ){
		$major_specific_subject_score_addition = $same_specific_subject_biweight[ 0 ] * $percentage_of_max_value_for_matching_major * $current_cm_major_hired_offset_multiplier;
		$current_comments{ 'major_specific_subject_match' } = "1";
	}else{
		$major_specific_subject_score_addition = $same_specific_subject_biweight[ 1 ] * $percentage_of_max_value_for_matching_major * $current_cm_major_hired_offset_multiplier;
		$current_comments{ 'major_specific_subject_match' } = "0";
	}
	if( $major_specific_subject_score_addition > 0 && $major_specific_subject_score_addition > $specific_subject_score_addition ){
		$cm_collab_total_score += $major_specific_subject_score_addition;
	}else{
		$cm_collab_total_score += $specific_subject_score_addition;
	}
	
	#Check whether general subject matches
	my $general_subject_matches = 0;
	my $major_general_subject_matches = 0;
	my $current_cm_major_general_subject = $major_general_subject_map{ $cm_demographs{ $current_cm }->{ 'cm_major' } };
	foreach my $current_cm_subject ( @{ $cm_demographs{ $current_cm }->{ 'cm_general_subject' } }){
		foreach my $current_collab_subject ( @{ $collab_characteristics{ $current_collab }->{ 'collab_general_subject' } }){
			if( $current_cm_subject eq $current_collab_subject || $current_cm_subject eq "General" || $current_collab_subject eq "General" ){
				$general_subject_matches = 1;
			}
			if( $current_cm_major_general_subject eq $current_collab_subject ){
				$major_general_subject_matches = 1;
			}
		}
	}

	my $general_subject_score_addition;
	my $major_general_subject_score_addition;
	if( $general_subject_matches ){
		$general_subject_score_addition = $same_general_subject_biweight[ 0 ];
		$current_comments{ 'general_subject_match' } = "1";
	}else{
		$general_subject_score_addition = $same_general_subject_biweight[ 1 ];
		$current_comments{ 'general_subject_match' } = "0";
	}
	if( $major_general_subject_matches ){
		$major_general_subject_score_addition = $same_general_subject_biweight[ 0 ] * $percentage_of_max_value_for_matching_major * $current_cm_major_hired_offset_multiplier;
		$current_comments{ 'major_general_subject_match' } = "1";
	}else{
		$major_general_subject_score_addition = $same_general_subject_biweight[ 1 ] * $percentage_of_max_value_for_matching_major * $current_cm_major_hired_offset_multiplier;
		$current_comments{ 'major_general_subject_match' } = "0";
	}
	if( $major_general_subject_score_addition > 0 && $major_general_subject_score_addition > $general_subject_score_addition ){
		$cm_collab_total_score += $major_general_subject_score_addition;
	}else{
		$cm_collab_total_score += $general_subject_score_addition;
	}
	
	#Check whether grade level or subject matches
	unless( $cm_demographs{ $current_cm }->{ 'cm_grade_level' } eq "" ){
		if( $cm_demographs{ $current_cm }->{ 'cm_grade_level' } eq $collab_characteristics{ $current_collab }->{ 'collab_grade_level' } || $general_subject_matches){
			$cm_collab_total_score += $subject_or_grade_level_biweight[ 0 ];
			$current_comments{ 'subject_or_grade_level_match' } = "1";
		}else{
			$cm_collab_total_score += $subject_or_grade_level_biweight[ 1 ];
			$current_comments{ 'subject_or_grade_level_match' } = "0";
		}
	}
		
	#If placement classroom is math or science, check whether cm is math or science. Otherwise, skip.
	my $math_science_collab_matches = 0;
	foreach my $current_collab_subject ( @{ $collab_characteristics{ $current_collab }->{ 'collab_general_subject' } }){
		if( ($current_collab_subject eq "Math") || ($current_collab_subject eq "Science")){
			$math_science_collab_matches = 1;
			last ;
		}
	}
	if( $math_science_collab_matches ){
		my $math_science_cm_matches = 0;
		foreach my $current_cm_subject ( @{ $cm_demographs{ $current_cm }->{ 'cm_general_subject' } }){
			if( ($current_cm_subject eq "Math") || ($current_cm_subject eq "Science")){
				$math_science_cm_matches = 1;
				last ;
			}
		}
		if( $math_science_cm_matches ){
			$cm_collab_total_score += $math_science_biweight[ 0 ];
			$current_comments{ 'math_science_match' } = "1";
		}else{
			$cm_collab_total_score += $math_science_biweight[ 1 ];
			$current_comments{ 'math_science_match' } = "0";
		}
	}
	
	#If bilingual classroom, check for bilinugal cm
	if( $cm_demographs{ $current_cm }->{ 'cm_bilingual_placement' } == 1) {
		if( $collab_characteristics{ $current_collab }->{ 'collab_bilingual_classroom' } == 1 ){
			$cm_collab_total_score += $bilingual_placement_in_bilingual_classroom_biweight[ 0 ];
			$current_comments{ 'bilingual_placement_in_bilingual_classroom' } = "1";
		}else{
			$cm_collab_total_score += $bilingual_placement_in_bilingual_classroom_biweight[ 1 ];
			$current_comments{ 'bilingual_placement_in_bilingual_classroom' } = "0";
		}
	}
	
	#If bilingual classroom, check for spanish ability
	if( $collab_characteristics{ $current_collab }->{ 'collab_bilingual_classroom' } == 1) {
		if( $cm_demographs{ $current_cm }->{ 'cm_spanish_ability' } == 1 ){
			$cm_collab_total_score += $spanish_ability_in_bilingual_classroom_biweight[ 0 ];
			$current_comments{ 'spanish_ability_in_bilingual_classroom' } = "1";
		}else{
			$cm_collab_total_score += $spanish_ability_in_bilingual_classroom_biweight[ 1 ];
			$current_comments{ 'spanish_ability_in_bilingual_classroom' } = "0";
		}
	}
	
	#If collab biligual and in prek, k check for spanish ability
	if( ( $collab_characteristics{ $current_collab }->{ 'collab_grade' }[ 0 ] <= 2 ) && ( $collab_characteristics{ $current_collab }->{ 'collab_bilingual_classroom' } == 1 ) ){
		if( $cm_demographs{ $current_cm }->{ 'cm_spanish_ability' } == 1 ){
			$cm_collab_total_score += $spanish_ability_in_lower_grades_biweight[ 0 ];
			$current_comments{ 'spanish_ability_in_lower_grades' } = "1";
		}else{
			$cm_collab_total_score += $spanish_ability_in_lower_grades_biweight[ 1 ];
			$current_comments{ 'spanish_ability_in_lower_grades' } = "0";
		}
	}
	
	#Apply grade multiplier
	#Compute max and min grades for CM
	#If collab grade falls within the range of max and min, do nothing
	#If collab is outside (above or below) the range, compute how many grades off and multiply by multiplier
	my @current_cm_grades = sort by_number @{ $cm_demographs{ $current_cm }->{ 'cm_grade' } };
	my @current_collab_grades = sort by_number @{ $collab_characteristics{ $current_collab }->{ 'collab_grade' } };
	my $current_cm_max_grade = $current_cm_grades[ -1 ];
	my $current_cm_min_grade = $current_cm_grades[ 0 ];
	my $current_collab_max_grade = $current_collab_grades[ -1 ];
	my $current_collab_min_grade = $current_collab_grades[ 0 ];
	unless( $#{$cm_demographs{ $current_cm }->{ 'cm_grade' }} < 0 ){
		if( $current_cm_max_grade < $current_collab_min_grade){
			$cm_collab_total_score -= ( abs( $current_cm_max_grade - $current_collab_min_grade ) ** $distance_from_grade_exponent );
			$current_comments{ 'distance_from_target_grade' } = ($current_cm_max_grade - $current_collab_min_grade);
		}
		if( $current_collab_max_grade < $current_cm_min_grade){
			$cm_collab_total_score -= ( abs( $current_collab_max_grade - $current_cm_min_grade ) ** $distance_from_grade_exponent );
			$current_comments{ 'distance_from_target_grade' } = ($current_collab_max_grade - $current_cm_min_grade);
		}
	}
	
	#Apply hired multiplier
	if( $cm_demographs{ $current_cm }->{"cm_hired"} eq "Hired - grade/subject confirmed" ){
		$cm_collab_total_score *= $hired_confirmed_multiplier;
	}elsif( $cm_demographs{ $current_cm }->{"cm_hired"} eq "Hired - grade/subject not confirmed" ){
		$cm_collab_total_score *= $hired_unconfirmed_multiplier;
	}else{
		$cm_collab_total_score *= $non_hired_multiplier;
	}
	
	#Apply exact match multiplier
	if( $cm_demographs{ $current_cm }->{"cm_exact_match_critical"} == 1 ){
		$cm_collab_total_score *= $exact_match_critical_multiplier;
	}
	
	#Report comments back for cm
	if( $#_ > 1 ){
		$_[2]->{ $current_cm } = \%current_comments;
	}
	
	return $cm_collab_total_score;
}

sub by_number { $a <=> $b }

sub by_present_cm_list_score_descending{ $present_cm_list{$b} <=> $present_cm_list{$a} }

sub by_average_scores_for_top_cms_descending{ $average_scores_for_top_cms{$b} <=> $average_scores_for_top_cms{$a} }

sub sort_collab_by_available_cm {
	#Take an array with a list of cms. Look at #cms to place. If top # cms are 
}

sub average_and_sort_collabs{
	#First argument: collabs to sort
	my $collab_list_ref = $_[0];
		
	foreach my $current_collab ( @{ $collab_list_ref } ){
			
		#Ensure that top cms are not placed
		my $top_cms_to_count = $num_cm_to_place{ $current_collab };
		my $counter_top_cms = 0;
		my $subtotal_score = 0;
		while( $counter_top_cms <= $top_cms_to_count ){
			#Check whether cm at current counter has been placed. If it has, then remove from list. If not, add that value to the subtotal and increment
			my $current_cm = $cm_sorted_collab{ $current_collab }->[ $counter_top_cms ];
			if( $cm_placed{ $current_cm } ){
				if( $#{$cm_sorted_collab{ $current_collab }} <= 0 ){
					#carp "We have run out of cms";
					my @cm_sorted_collab = @{ $cm_sorted_collab{ $current_collab } };
					splice( @cm_sorted_collab, $counter_top_cms, 1 );
					$cm_sorted_collab{ $current_collab } = \@cm_sorted_collab;
					last;
				}
				#print "Removing cm $current_cm at position $counter_top_cms\n";
				
				my @cm_sorted_collab = @{ $cm_sorted_collab{ $current_collab } };
				#print "Before splice @cm_sorted_collab[0..6]\n";
				splice( @cm_sorted_collab, $counter_top_cms, 1 );
				#print "After splice @cm_sorted_collab[0..6]\n";
				$cm_sorted_collab{ $current_collab } = \@cm_sorted_collab;	
			}else{
				$subtotal_score += $collab_cm_score{ $current_collab }->{ $current_cm };
				$counter_top_cms++;
			}
		}
		
		#Compute average score for top cms
		if( $top_cms_to_count != 0 ){
			$average_scores_for_top_cms{ $current_collab } = $subtotal_score / $top_cms_to_count;
		}else{
			croak "Collab $current_collab has no cms to place!";
			return -1;
		}
		
	}
	
	#Sort list
	my @sorted_collab_list = sort by_average_scores_for_top_cms_descending @{ $collab_list_ref };
	$collab_list_ref = \@sorted_collab_list;
	return $collab_list_ref;
}

sub evaluate_collab_cma_group_score{
	
	unless( defined $_[3] ){
		croak "Insufficient number of arguments in evaluate_collab_cma_group_score";
	}
	
	my $current_collab = $_[ 0 ];
	my %current_collab_makeup = %{ $_[1] };
	my %current_cma_group_makeup = %{ $_[2] };
	my %current_school_makeup = %{ $_[3] };
	my $collab_score_comments_ref;
	my %collab_score_comments;
	if( $#_ > 3 ){
		$collab_score_comments_ref = $_[4];
	}
	
	my $current_score;
	
	foreach my $test_keys ( %current_collab_makeup ){
		#print "Key: $test_keys\n";
	}
	
	#If insufficient cms
	my $collab_capacity = $collab_characteristics{ $current_collab }->{'collab_capacity'};
	my $required_cms_in_collab = $collab_capacity;
	if( $collab_capacity >= 4){
		$required_cms_in_collab -= 1;
	}
	if( $current_collab_makeup{'num_cms'} <  $required_cms_in_collab ){
		$current_score += $sufficient_num_cms_biweight[1];
		$collab_score_comments{'sufficient_num_cms'} = 0;
		$collab_score_comments{'num_cms'} = $current_collab_makeup{'num_cms'};
	}else{
		$current_score += $sufficient_num_cms_biweight[0];
		$collab_score_comments{'sufficient_num_cms'} = 1;
		$collab_score_comments{'num_cms'} = $current_collab_makeup{'num_cms'};
	}
	
	#If bilingual collab, check at least one biligual cm
	if( $collab_characteristics{ $current_collab }->{'collab_bilingual_classroom'} ){
		if( $current_collab_makeup{'spanish_ability'}->{"1"} > 0 ){
			$current_score += $at_least_one_span_ability_biweight[0];
			$collab_score_comments{'at_least_one_billingual_cm'} = "1";
		}else{
			$current_score += $at_least_one_span_ability_biweight[1];
			$collab_score_comments{'at_least_one_billingual_cm'} = "0";
		}
	}
	
	#Count up school types and multiply by multiplier
	my $grade_levels = 0;
	foreach my $current_grade_level ( keys %{ $current_collab_makeup{'grade_level'} }){
		if( $current_collab_makeup{'grade_level'}->{ $current_grade_level } > 0 ){
			$grade_levels++;
		}
	}
	$current_score += ( $grade_levels * $grade_levels_multiplier );
	$collab_score_comments{'number_of_collab_grade_levels'} = $grade_levels;
	
	#Count up regions types and multiply by multiplier
	my $region_report_line;
	my $collab_number_of_regions = 0;
	my $collab_total_cms = 0;
	foreach my $current_region ( keys %{ $current_collab_makeup{'region'} } ){
		if( $current_collab_makeup{'region'}->{ $current_region } > 0 ){
			$collab_number_of_regions++;
			$collab_total_cms += $current_collab_makeup{'region'}->{ $current_region };
		}
		#$region_report_line .= ", $current_region $current_collab_makeup{'region'}->{ $current_region }";
	}
	$current_score += ( ($collab_number_of_regions - 1) * $collab_region_number_multiplier );
	$collab_score_comments{'number_of_collab_regions'} = $collab_number_of_regions;
	
	#Set region cluster
	my $collab_region_cluster_vector_running_total;
	my $highest_collab_regional_cluster_representation;
	foreach my $current_region ( keys %{ $current_collab_makeup{'region'} }){
		if( $current_collab_makeup{'region'}->{ $current_region } > 0 ){
			my $percentage_from_region = $current_collab_makeup{'region'}->{ $current_region } / $collab_total_cms;
			$collab_region_cluster_vector_running_total += ( $percentage_from_region ) ** $collab_number_of_regions;
			if( $percentage_from_region > $highest_collab_regional_cluster_representation ){
				$highest_collab_regional_cluster_representation = $percentage_from_region;
			}
		}
	}
	
	if( $current_collab_makeup{'num_cms'} <= 0 || $collab_number_of_regions <= 0){
	    #link comments to ref
    	if( $#_ > 2){
    		$_[ 4 ]->[0] = \%collab_score_comments;
    	}
    	
	    return $current_score;
	}

	$current_score += $collab_region_cluster_cm_weighted_multiplier * ( $collab_region_cluster_vector_running_total ) ** (1/$collab_number_of_regions) * $collab_total_cms;
	$collab_score_comments{'highest_collab_regional_cluster_representation'} = $highest_collab_regional_cluster_representation;
	
	#Count up school types and multiply by multiplier
	my $cma_group_grade_levels = 0;
	foreach my $current_grade_level ( keys %{ $current_cma_group_makeup{'grade_level'} }){
		if( ($current_grade_level ne "") && ($current_cma_group_makeup{'grade_level'}->{ $current_grade_level } > 0) ){
			$cma_group_grade_levels++;
		}
	}
	$current_score += ( $cma_group_grade_levels * $grade_levels_multiplier );
	$collab_score_comments{'number_of_cma_group_grade_levels'} = $cma_group_grade_levels;
	
	#Count up regions types and multiply by multiplier
	my $cma_group_number_of_regions = 0;
	my $cma_group_total_cms = 0;
	foreach my $current_region ( keys %{ $current_cma_group_makeup{'region'} }){
		if( $current_cma_group_makeup{'region'}->{ $current_region } > 0 ){
			$cma_group_number_of_regions++;
			$cma_group_total_cms += $current_cma_group_makeup{'region'}->{ $current_region };
		}
	}
	$current_score += ( ( $cma_group_number_of_regions - 1 ) * $cma_group_region_number_multiplier );
	$collab_score_comments{'number_of_cma_group_regions'} = $cma_group_number_of_regions;
	
	#Set region cluster
	my $cma_group_region_cluster_vector_running_total;
	my $highest_cma_group_regional_cluster_representation;
	foreach my $current_region ( keys %{ $current_cma_group_makeup{'region'} }){
		if( $current_cma_group_makeup{'region'}->{ $current_region } > 0 ){
			my $percentage_from_region = $current_cma_group_makeup{'region'}->{ $current_region } / $cma_group_total_cms;
			$cma_group_region_cluster_vector_running_total += ( $percentage_from_region ) ** $cma_group_number_of_regions;
			if( $percentage_from_region > $highest_cma_group_regional_cluster_representation ){
				$highest_cma_group_regional_cluster_representation = $percentage_from_region;
			}
		}
	}

	$current_score += $cma_group_region_cluster_cm_weighted_multiplier * ( $cma_group_region_cluster_vector_running_total ) ** (1/$cma_group_number_of_regions) * $cma_group_total_cms;
	$collab_score_comments{'highest_cma_group_regional_cluster_representation'} = $highest_cma_group_regional_cluster_representation;
	
	#Determine collab group gender ratio and apply multiplier
	my $total_cms_in_collab_with_gender = $current_collab_makeup{'gender'}->{"MALE"} + $current_collab_makeup{'gender'}->{"FEMALE"};
	if( $total_cms_in_collab_with_gender > 0 ){
		my $collab_gender_score = ( $current_collab_makeup{'gender'}->{"MALE"} / $total_cms_in_collab_with_gender ) * ( $current_collab_makeup{'gender'}->{"FEMALE"} / $total_cms_in_collab_with_gender ) / .5 * $collab_gender_balance_multiplier;
		$current_score += $collab_gender_score;
		$collab_score_comments{'collab_ratio_male_female'} = $current_collab_makeup{'gender'}->{"MALE"} . " to " . $current_collab_makeup{'gender'}->{"FEMALE"};
	}else{
		$collab_score_comments{'collab_ratio_male_female'} = "No CMs with gender listed in this collab group";
	}
	
	#Determine cma group gender ratio and apply multiplier
	my $total_cms_in_cma_group_with_gender = $current_cma_group_makeup{'gender'}->{"MALE"} + $current_cma_group_makeup{'gender'}->{"FEMALE"};
	if( $total_cms_in_cma_group_with_gender > 0 ){
		my $cma_group_gender_score = ( $current_cma_group_makeup{'gender'}->{"MALE"} / $total_cms_in_cma_group_with_gender ) * ( $current_cma_group_makeup{'gender'}->{"FEMALE"} / $total_cms_in_cma_group_with_gender ) / .5 * $cma_group_gender_balance_multiplier;
		$current_score += $cma_group_gender_score;
		$collab_score_comments{'cma_group_ratio_male_female'} = $current_cma_group_makeup{'gender'}->{"MALE"} . " to " . $current_cma_group_makeup{'gender'}->{"FEMALE"};
	}else{
		$collab_score_comments{'cma_group_ratio_male_female'} = "No CMs with gender listed in this cma_group group";
	}
	
	#Determine number of poc's in collab and apply biweight as necessary
	my $number_of_poc_in_collab = $current_collab_makeup{'poc'}->{1};
	if( $number_of_poc_in_collab > 0 ){
		if( $number_of_poc_in_collab >= $collab_poc_threshold ){
			$current_score += $collab_poc_biweight[0];
			$collab_score_comments{'collab_number_of_poc'} = $number_of_poc_in_collab . " - score: $collab_poc_biweight[0]";
		}else{
			my $collab_poc_score = ($collab_poc_biweight[0] - $collab_poc_biweight[1]) * ( $number_of_poc_in_collab - 1 ) / ($collab_poc_threshold - 1) + $collab_poc_biweight[1];
			$current_score += $collab_poc_score; 
			$collab_score_comments{'collab_number_of_poc'} = $number_of_poc_in_collab;
		}
	}
	
	#Determine number of poc's in cma_group and apply biweight as necessary
	my $number_of_poc_in_cma_group = $current_cma_group_makeup{'poc'}->{1};
	if( $number_of_poc_in_cma_group > 0 ){
		if( $number_of_poc_in_cma_group >= $cma_group_poc_threshold ){
			$current_score += $cma_group_poc_biweight[0];
			$collab_score_comments{'cma_group_number_of_poc'} = $number_of_poc_in_cma_group . " - score: $cma_group_poc_biweight[0]";
		}else{
			my $cma_group_poc_score = ($cma_group_poc_biweight[0] - $cma_group_poc_biweight[1]) * ( $number_of_poc_in_cma_group - 1 ) / ($cma_group_poc_threshold - 1) + $cma_group_poc_biweight[1];
			$current_score += $cma_group_poc_score; 
			$collab_score_comments{'cma_group_number_of_poc'} = $number_of_poc_in_cma_group;
		}
	}
	
	#Determine number of poc's in school and apply biweight as necessary
	my $number_of_poc_in_school = $current_school_makeup{'poc'}->{1};
	if( $number_of_poc_in_school > 0 ){
		if( $number_of_poc_in_school >= $school_poc_threshold ){
			$current_score += $school_poc_biweight[0];
			$collab_score_comments{'school_number_of_poc'} = $number_of_poc_in_school . " - score: $school_poc_biweight[0]";
		}else{
			my $school_poc_score = ($school_poc_biweight[0] - $school_poc_biweight[1]) * ( $number_of_poc_in_school - 1 ) / ($school_poc_threshold - 1) + $school_poc_biweight[1];
			$current_score += $school_poc_score; 
			$collab_score_comments{'school_number_of_poc'} = $number_of_poc_in_school;
		}
	}
	
	#Count up regions types and multiply by multiplier
	my $school_number_of_regions = 0;
	my $school_total_cms = 0;
	foreach my $current_region ( keys %{ $current_school_makeup{'region'} }){
		if( $current_school_makeup{'region'}->{ $current_region } > 0 ){
			$school_number_of_regions++;
			$school_total_cms += $current_school_makeup{'region'}->{ $current_region };
		}
	}
	$current_score += ( ( $school_number_of_regions - 1 ) * $school_region_number_multiplier );
	$collab_score_comments{'number_of_school_regions'} = $school_number_of_regions;
	
	#Set region cluster
	my $school_region_cluster_vector_running_total;
	my $highest_school_regional_cluster_representation;
	foreach my $current_region ( keys %{ $current_school_makeup{'region'} }){
		if( $current_school_makeup{'region'}->{ $current_region } > 0 ){
			my $percentage_from_region = $current_school_makeup{'region'}->{ $current_region } / $school_total_cms;
			$school_region_cluster_vector_running_total += ( $percentage_from_region ) ** $school_number_of_regions;
			if( $percentage_from_region > $highest_school_regional_cluster_representation ){
				$highest_school_regional_cluster_representation = $percentage_from_region;
			}
		}
	}
	
	$current_score += $school_region_cluster_cm_weighted_multiplier * ( $school_region_cluster_vector_running_total ) ** (1/$school_number_of_regions) * $school_total_cms;
	$collab_score_comments{'highest_school_regional_cluster_representation'} = $highest_school_regional_cluster_representation;
	
	$current_score += $current_collab_makeup{'cm_score_total'};
	$collab_score_comments{'cm_score_total'} = $current_collab_makeup{'cm_score_total'};
	
		
	#link comments to ref
	if( $#_ > 2){
		$_[ 4 ]->[0] = \%collab_score_comments;
	}
	
	return $current_score;
}

sub strip_surrounding_white_space{
	if( $_[0] =~ /^\s*(.*)\s*$/ ){
		return $1;
	}else{
		return $_[0];
	}
}
