use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

use Apache::src ();

WriteMakefile(
    'NAME'	=> 'Apache::LogFile',
    'VERSION_FROM' => 'LogFile.pm', # finds $VERSION
    'INC'	=> Apache::src->new->inc,
    'dist'    => {
	COMPRESS=> 'gzip -9f', SUFFIX=>'gz',
	CI => qq(ci -u -m\\"See Changes file\\"),
    },
);
