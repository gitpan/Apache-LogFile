package Apache::LogFile;

use strict;
use vars qw($VERSION @ISA);
use Symbol ();
use DynaLoader ();

@ISA = qw(DynaLoader);

$VERSION = '0.11';

bootstrap Apache::LogFile $VERSION;

my %Handles = ();

sub new {
    my($class, $file, $name) = @_;

    #hmm, do we really need to do all this?
    my $thing = bless Symbol::gensym(), "IO::Handle";
    my $log = $class->_new($file);
    tie *$thing, $class, $log;

    if($name) {
	$Handles{$name} = $thing;
    }
    else {
	$Handles{$file} = $thing;
    }

    my ($package, $filename, $line) = caller;

    for (1,2) {
	if($INC{$filename}) {
	    mark_for_inc_delete($filename);
	    last;
	}
	else {
	    $filename = Apache->server_root_relative($filename);
	}
    }
    return $thing;
}

sub handle {
    my($self, $name) = @_;
    return $Handles{$name};
}

sub TIEHANDLE {
    my($class, $obj) = @_;
    return ref($obj) ? $obj : bless $obj, $class;
}

sub PRINTF {
    my $self = shift;
    my $fmt = shift;
    $self->print(sprintf($fmt, @_));
}

1;
__END__

=head1 NAME

Apache::LogFile - Interface to Apache's logging routines

=head1 SYNOPSIS

  #in a startup file
  use Apache::LogFile ();
  Apache::LogFile->new("|perl/mylogger.pl", "MyLogger");

  #in a request-time file 
  use Apache::LogFile ();
  my $fh = Apache::LogFile->handle("MyLogger");
  print $fh "a message to the log";

=head1 DESCRIPTION

The C<new> method should be called by a server startup script or module.
It will create a new log file or open a pipe to a program if the first
character of the filename is a C<|>.  
The last argument to C<new> is optional, it is simply a name that can be
used to retrive the filehandle via the C<handle> method.  
If this argument is not present, the filename will be used the handle key, 
which can also be retrived via the C<handle> method.
The C<new> method will return a reference to the filehandle if you wish
to store it elsewhere, e.g.:

 $MyLog::Pipe = Apache::LogFile->new("|perl/mylogger.pl");

 $MyLog::Append = Apache::LogFile->new("logs/my_log");

Filenames can be absolute or relative to B<ServerRoot>.

=head1 AUTHOR

Doug MacEachern

=head1 SEE ALSO

Apache(3), mod_perl(3)

=cut
