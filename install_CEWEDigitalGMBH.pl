#! /usr/bin/perl -w

use strict;
use File::Path;
use File::Basename;
use Getopt::Long;

my $FILE_EULA = 'EULA.txt';
my $DOWNLOAD_SERVER = "http://dls.photoprintit.de/";
## JGE
my $KEYACCID = '8314';
my $CLIENTID = '38';
my $HPS_VER = '4.5.9';
my $VENDOR_NAME = 'DOMO';
my $APPLICATION_NAME = 'DOMO Fotolumea mea';
my $HAS_PHOTOFUN = 'true';
my $HAS_CANVAS = 'true';
my $HAS_POSTER = 'true';
my $HAS_PREMIUMFOTO = 'true';
my $HAS_BUDGETFOTO = 'true';
my $HAS_CALENDARS = 'true';
my $HAS_FOTOBOOKS = 'true';
my $HAS_THEME_DESIGN = 'true';
my $HAS_THEME_DMBABY = 'false';
my $HAS_THEME_ALB = 'true';
my $PROGRAM_NAME_FOTOSHOW = 'Vizualizare fotografii';
 
## /JGE
my $DESKTOP_ICON_NAME = 'DOMO Fotolumea mea.desktop';
my $DESKTOP_ICON_PATH = '/Resources/keyaccount/32.xpm';
my $SERVICES_XML_PATH = '/Resources/services.xml';
my $AFFILIATE_ID = '';

my $ANSWER_YES = 'ja';
my $ANSWER_NO = 'nein';
my $WELCOME = "Dieses Script ist Ihnen beim Installieren von '$APPLICATION_NAME' auf Ihrem Rechner behilflich und leitet Sie Schritt für Schritt durch den Installationsprozess.\n\n\n";
my $EULA_READ = "Bitte lesen Sie die EULA sorgfältig durch. Im Anschluss daran müssen Sie die EULA akzeptieren.\n\tInnerhalb der EULA können Sie mit den Pfeiltasten navigieren. Durch drücken der Taste 'q' verlassen Sie die EULA.\n\tWeiter mit [CR].";
my $EULA_ACCEPT = "\tAkzeptieren Sie die EULA? [$ANSWER_YES/".uc($ANSWER_NO)."] ";
my $EULA_NOTACCEPTED = "\tSie haben die EULA nicht akzeptiert.\n'$APPLICATION_NAME' kann leider nicht auf Ihrem Rechner installiert werden.\n\n\n";
my $INSTALL_DIR_QUESTION_FORMAT = "Wo soll '$APPLICATION_NAME' installiert werden? [%s] ";
my $DOWNLOAD_MSG = "\tWollen Sie die Installation fortsetzen und die benötigten Daten aus dem Internet herunter laden? [".uc($ANSWER_YES)."/".$ANSWER_NO."] ";
my $DOWNLOAD_MSG_FORMAT = "\tDownloading: '%s'\n";
my $UNPACK_MSG = "Die benötigten Dateien werden nun in das Installationsverzeichnis entpackt.\n";
my $FINISHED_MSG_FORMAT = "\nHerzlichen Glückwunsch!\nSie haben erfolgreich '$APPLICATION_NAME' auf Ihrem Rechner installiert.\nZum Starten führen Sie bitte die Datei '%s/$APPLICATION_NAME' aus.\n\nViel Spaß!\n";
my $DOWNLOAD_RETRY = "Soll erneut versucht werden die Datei herunter zu laden? [$ANSWER_YES/".uc($ANSWER_NO)."] ";
my $PACKAGE_SIZE_FORMAT = "\t\t%s %s\t%s (%s)\n";
my $TOTAL_DOWNLOAD_SIZE_FORMAT = "\tEs müssen noch insgesamt %.1fMb Daten aus dem Internet heruntergeladen werden.\n";
my $PRE_PACKAGELIST_MSG = "Für eine erfolgreiche Installation müssen noch die folgenden Pakete aus dem Internet herunter geladen werden.\n";
my @ANSWER_YES_LIST = ("j", "ja", "y", "yes");
my @ANSWER_NO_LIST = ("n", "nein", "no");

######################################################################################################################
# AB HIER SOLLTE NICHTS MEHR GEAENDERT WERDEN
######################################################################################################################
my $INSTALL_DIR_DEV = "$VENDOR_NAME/$APPLICATION_NAME";
my $INDEX_FILE_PATH_ON_SERVER = "/download/Data/$KEYACCID/hps/$CLIENTID-index-$HPS_VER.txt";
my $LOG_FILE_DIR = '.log';
my @REQUIRED_PROGRAMMS = ("unzip", "md5sum", "less", "wget");
my $DESKTOP_ICON_FORMAT = "[Desktop Entry]\n".
			  "Comment=\n".
			  "Comment[de]=\n".
			  "Encoding=UTF-8\n".
			  "Exec=\"%s/$APPLICATION_NAME\"\n".
			  "Icon=%s$DESKTOP_ICON_PATH\n".
			  "Name=$APPLICATION_NAME\n".
			  "Name[de]=$APPLICATION_NAME\n".
			  "StartupNotify=true\n".
			  "Terminal=false\n".
			  "TerminalOptions=\n".
			  "Type=Application\n";
my $SERVICES_XML_FORMAT = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>
<services>
<service name=\"a\">t856EvnDTL56xD5fHQnWrzqVk6Xj3we4xGYHfShPmkqXtCzbI21eqJ57eIHVViAg</service>
<service name=\"b\">SNCxjcl5y86nasXrdmtwTWWbBmFs3j21rZOVvoZT9HleOfGJR7FGgZiXsS623ctV</service>
<service name=\"c\">7iIwPfB9c6TIRuf9SPd7I1j25Pex9atTL9TDepMD6nkAyDliZhvIlJOC2tm9pcyQ</service>
<service name=\"d\">%s</service>
<service name=\"e\">EQBuKJf7pzVIbNXzz19PlwkVpERC5KfsWJbG4cazpn3PFC5Rtz4O3V87KcWfMgxK</service>
<service name=\"f\">8ksOkroMJFn1Es3zVJyzxJggNaXiMuLKBfPLBtCyek1bZBcTy29gaU7nm75ZYIxz</service>
<service name=\"g\">xHuXMWCLmtrwNIBvqVB9BAyPjNpEa9gNuybXU51bKsryDqc2UJxSQXM8yIhbIarq</service>
<service name=\"h\">sKTtqevc5EdBSwi3bZkngwl4NSolB8vFc7kPWeAEB4Y1ySgUIgcjJGxKlOll8c8e</service>
</services>\n";



######################################################################################################################
# Variablen
######################################################################################################################
my $indexContent;			# Enthält den Inhalt der Index-Datei
my @filesToDownload;			# Enthält die Dateinamen die heruntergeladen werden müssen
my @downloadedFiles;			# Enthält die Dateinamen der heruntergeladenen Dateien
my @filesToRemove;			# Enthält die Dateinamen der Dateien die am Ende des Scriptes gelöscht werden müssen.
my $fileName;				# Enthält den Namen der aktuell zu bearbeitenden Datei
my $update;
my $installDir="";
my $sourceDir="";
my $changeInstallDir=1;
my $verbose;
my $keepPackages=0;



######################################################################################################################
# Zeige einen kleinen Hilfetext an
######################################################################################################################
sub showHelp {
	print $WELCOME;
	print "Kommandozeilenoptionen:\n";
	print "   -h; --help\n";
	print "   -i; --installdir=<DIR>\tDas Verzeichnis in das '$APPLICATION_NAME' installiert werden soll.\n";
	print "   -k; --keepPackages\t\tDie heruntergeladenen Pakete werden nicht gelöscht und können für eine weitere Installation benutzt werden.\n";
	print "   -s; --source=<DIR>\t\tDas Verzeichnis in dem die Installationspakete liegen.\n";
#	print "   --update\t\tEine bestehende Installation wird geupdatet. Benötigt --installdir.\n";
	print "   -v; --verbose\t\tGibt Informationen beim Download aus.\n";
	print "\n";
	print "Das Script sucht im aktuellen oder in dem mit --source angegebenen Verzeichnis nach den Installationspaketen. Werden die Pakete dort nicht gefunden\nso werden sie aus dem Internet heruntergeladen\n";
	print "\n";
}



######################################################################################################################
# Parse Kommandozeilen Parameter
######################################################################################################################
sub getOptions {
	$update=0;
	$verbose=0;
	$installDir="";
	my $help=0;
	
	GetOptions("installdir=s" => \$installDir,
			"update" => \$update,
			"verbose" => \$verbose,
			"help" => \$help,
			"keepPackages" => \$keepPackages,
			"source=s" => \$sourceDir) || die "Es fehlen Angaben.";
	
	if($help == 1) {
		showHelp;
		exit 0;
	}
	
	
	if($update == 1) {
		if($installDir eq "") {
			print "Es ist kein Installationsverzeichniss angegeben.\n";
			exit 1;
		}
	}
	
	if($installDir ne "") {
		$changeInstallDir=0;
	}
}



######################################################################################################################
# Prüfe ob benötigte Programme da sind
######################################################################################################################
sub checkProgramms {
	foreach (@REQUIRED_PROGRAMMS) {
		my $status=system("which $_ > /dev/null 2>&1");
		
		if(0!=$status) {
			print "Zur korrekten Ausführung des Scriptes wird das Programm '$_' benötigt.\n";
			exit 1;
		}
	}
}



######################################################################################################################
# Zeigt die EULA an
######################################################################################################################
sub showEula {
	if($FILE_EULA ne "" && $update==0) {
		if(!open(EULA, "<", $FILE_EULA)) {
			print "Die Datei ".$FILE_EULA." kann nicht gefunden werden.\n";
			exit 1;
		}
		close EULA;
		print $EULA_READ;
		my $answer = <STDIN>;
		
		system("less $FILE_EULA");
		
		print $EULA_ACCEPT;
		chomp($answer = <STDIN>);
		$answer=lc($answer);
		
		my $found=0;
		foreach(@ANSWER_YES_LIST) {
			if($answer eq $_) {
				$found=1;
				last;
			}
		}
		
		if(0==$found) {
			print $EULA_NOTACCEPTED;
			exit;
		}
	}
}



######################################################################################################################
# Installationsverzeichniss erfragen
######################################################################################################################
sub getInstallDir {
	if($update == 0 && $changeInstallDir == 1) {
		if($> == 0) {
			# Root User
			$installDir="/opt/".$INSTALL_DIR_DEV;
		}
		else {
			# Normaler Benutzer
			$installDir=$ENV{"HOME"}."/".$INSTALL_DIR_DEV;
		}
		
		printf $INSTALL_DIR_QUESTION_FORMAT, $installDir;
		my $answer = <STDIN>;
		chomp($answer);
		
		if("" ne $answer) {
			$installDir=$answer;
		}
	}
}



######################################################################################################################
# Holt die Index-Datei
######################################################################################################################
sub getIndexFile {
	my $downloaded	= 0;
	my $answer	= 1;
	
	$fileName	= basename($INDEX_FILE_PATH_ON_SERVER);
	
	if( -e $sourceDir."/".$fileName) {
		$fileName=$sourceDir."/".$fileName;
	} elsif(! -e $fileName) {
		# Hole Indexdatei aus dem Netz.
		if(0==$verbose) {
			$answer = system("wget -q $DOWNLOAD_SERVER$INDEX_FILE_PATH_ON_SERVER");
		}
		else {
			$answer = system("wget $DOWNLOAD_SERVER$INDEX_FILE_PATH_ON_SERVER");
		}
		
		if($answer!=0) {
			print "Herunterladen der Datei: ", $DOWNLOAD_SERVER.$INDEX_FILE_PATH_ON_SERVER, " ist fehlgeschlagen\n";
			exit 1;
		}
		
		$downloaded=1;
	}
	
	if(!open(INDEX, "<", $fileName)) {
		print "Konnte die Indexdatei nicht öffnen";
		exit 1;
	}
	else {
		while(<INDEX>) {
			$indexContent.=$_;
		}
		
		close(INDEX);
		
		if(1==$downloaded && $keepPackages==0) {
			unlink($fileName);
		}
	}
}



######################################################################################################################
# Checkt Index-Datei und sucht die herunter zu ladenden Dateien zusammen
######################################################################################################################
sub checkIndexFile {
	my $totalSize		= 0;
	my $packageString	= "";
	
	foreach (split(/[\r\n]+/, $indexContent)) {
		chomp;
		if(/^(.*);(.*);(.*);(.*)$/) {
			my $filePath	= $1;
			my $required	= $2;
			my $what	= $3;
			my $system	= $4;
			
			if($system eq "l" || $system eq "a") {
				$fileName	= basename($filePath);
				
				if(! -e $installDir."/".$LOG_FILE_DIR."/".$fileName.".log") {
					# Die Datei ist noch nicht installiert.
					if( -e $sourceDir."/".$fileName) {
						# Die Datei liegt lokal vor, also brauchen wir sie nicht herunter zu laden
						push(@downloadedFiles, $sourceDir."/".$fileName);
					} elsif( -e $fileName ) {
						# Die Datei liegt lokal vor, also brauchen wir sie nicht herunter zu laden
						push(@downloadedFiles, $fileName);
					}
					else {
						# Die Datei muss aus dem Netz gezogen werden. Schreiben wir mal raus wie viel da herunter geladen werden muss.
						my $spider			= `export LANG=C;wget --spider $DOWNLOAD_SERVER/$filePath 2>&1`;
						my ($size, $dummy, $mb, $mime)	= $spider=~/Length:\s+([\d,]+)\s+(\(([\d\.]+[MK]?)\))?\s*(\[.*\])/;
						my $string			= sprintf $PACKAGE_SIZE_FORMAT, $what, $mime, $size, $mb;
						$packageString			.= $string;
						push(@filesToDownload, $_);
						$size=~s/,//g;
						$totalSize+=$size;
					}
				}
			}
		}
	}
	
	if(0!=(scalar @filesToDownload)) {
		print $PRE_PACKAGELIST_MSG;
		print $packageString;
		printf $TOTAL_DOWNLOAD_SIZE_FORMAT, $totalSize/(1024*1024);
	}
}



######################################################################################################################
# Roleback
######################################################################################################################
sub roleback {
	my ($fileName) = @_;
	$fileName =~ /^(.*)_.*$/;
	my $packageName=$1;
	
	if(opendir(LOG_FILE_DIR, $installDir."/".$LOG_FILE_DIR)) {
		my @allFiles=readdir(LOG_FILE_DIR);
		@allFiles=grep(!/^\./, @allFiles);
		
		close(LOG_FILE_DIR);
		
		foreach(@allFiles) {
			$_ =~ /^(.*)_.*$/;
			
			if($1 eq $packageName) {
				removePackage($_);
			}
		}
	}
}



######################################################################################################################
# Lösche Dateien aus einem Logfile und das Logfile selbst
######################################################################################################################
sub removePackage {
	my ($logFile) = @_;
	my @files;
	my @dirs;
	
	if(open(LOG_FILE, "<", $installDir."/".$LOG_FILE_DIR."/".$logFile)) {
		while(<LOG_FILE>) {
			if(/^\s*inflating:\s+(.*)/) {
				my $file=$1;
				$file =~ s/^\s+|\s+$//;
				push(@files, $file);
			}
			if(/^\s*creating:\s+(.*)\s*$/) {
				push(@dirs, $1);
			}
		}
		close LOG_FILE;
	}
	
	# Füge das Logfile zur Liste der zu löschenden Dateien hinzu.
	push (@files, $installDir."/".$LOG_FILE_DIR."/".$logFile);
	
	unlink(@files);
	
	@dirs = reverse @dirs;
	foreach(@dirs) {
		rmdir $_;
	}
}



######################################################################################################################
# Lädt alle Dateien aus der Index-Datei herunter
######################################################################################################################
sub downloadFiles {
	if(0!=(scalar @filesToDownload)) {
		if($update == 0) {
			my $answer;
			
			print $DOWNLOAD_MSG;
		
			chomp($answer = <STDIN>);
			$answer=lc($answer);
			
			foreach(@ANSWER_NO_LIST) {
				if($answer eq $_) {
					exit 1;
					last;
				}
			}
		}
		
		# Herunterladen der Dateien
		foreach (@filesToDownload) {
			chomp;
			$_ =~ /^(.*);.*;(.*);.*$/;
			my $filePath	= $1;
			my $what	= $2;
			my $error	= 0;
			my $retry	= 1;
			
			$fileName	= basename($filePath);
			
			printf $DOWNLOAD_MSG_FORMAT, $what;
			
			while(1==$retry) {
				my $result=1;
				
				if(0==$verbose) {
					$result=system("wget -q $DOWNLOAD_SERVER/$filePath -O $fileName");
				}
				else {
					$result=system("wget $DOWNLOAD_SERVER/$filePath -O $fileName");
				}
				
				if(0==$result) {
					# Extrahiere MD5 Summe
					$fileName =~ /^.*_(.*).zip$/;
					my $md5sum=$1;
					
					# Berechne MD5 Summe der Datei
					$result=`md5sum $fileName`;
					$result =~ /^(\w*)\s+.*$/;
					my $fileMd5sum=$1;
					
					if($md5sum ne $fileMd5sum) {
						print "Die Prüfsumme der heruntergeladenen Datei '$fileName' stimmt nicht!\n";
						$error=1;
					}
					else {
						push(@downloadedFiles, $fileName);
						push(@filesToRemove, $fileName);
						$retry=0;
					}
				}
				else {
					print "Beim Herunterladen ist ein Fehler aufgetreten.\n";
					$error=1;
				}
				
				if(0==$update && 1==$error) {
					my $answer;
					print $DOWNLOAD_RETRY;
					chomp($answer = <STDIN>);
					$answer=lc($answer);
					
					$retry=0;
					foreach(@ANSWER_YES_LIST) {
						if($answer eq $_) {
							$retry=1;
							$error=0;
							last;
						}
					}
				}
				elsif(1==$update && 1==$error) {
					# Wir haben keine Konsole und können keine Eingabe entgegen nehmen.
					# Deshalb brechen wir ab.
					$retry=0;
				}
			}
			
			if(1==$error) {
				print "Die Datei '$fileName' konnte nicht heruntergeladen werden.\n";
				unlink $fileName;
				exit 1;
			}
		}
	}
}



######################################################################################################################
# Prüfen und entpacken der Dateien
######################################################################################################################
sub unpackFiles {
	if(0!=(scalar @downloadedFiles)) {
		print $UNPACK_MSG;
		
		# Installationsverzeichniss anlegen
		eval { mkpath($installDir."/".$LOG_FILE_DIR) };
		
		if($@) {
			print "Das Installationsverzeichnis konnte nicht angelegt werden.";
			exit 1;
		}
		
		# Entpacken der Dateien
		foreach (@downloadedFiles) {
			$fileName	= $_;
			
			# Hier können wir eine evtl. installierte Vorgängerversion gelöscht werden.
			# Die md5 Summen aller Downloads stimmen, also sollten sich alle Pakete entpaken lassen
			roleback($fileName);
			
			my $result=0;
			my @unzipReturn;
			@unzipReturn=`unzip -o -d '$installDir' $fileName 2>&1`;
			
			foreach(@unzipReturn) {
				if(/^\s*error:/) {
					$result=1;
				}
				elsif(/cannot find/) {
					$result=1;
				}
			}
	
			if(open(OUT, ">", $installDir."/".$LOG_FILE_DIR."/".$fileName.".log")) {
				print OUT  @unzipReturn;
				close(OUT);
			}
			
			if(0!=$result) {
				print "Kann die Datei '$fileName' nicht entpacken!\n";
				exit 1;
			}
		}
	}
}



######################################################################################################################
# Desktop Icons erzeugen
######################################################################################################################
sub createDesktopIcons {
	
	if($>==0) {
		#Root User
		my $homeDir="/home/";
		if(opendir(HOME_DIR, $homeDir)) {
			my @allFiles=readdir(HOME_DIR);
			# Werfe alle Einträge mit einem Punkt am Anfang weg
			@allFiles=grep(!/^\./, @allFiles);
			
			foreach(@allFiles) {
				# Test ob es ein Verzeichnis ist
				if(opendir(SUB_DIR, $homeDir.$_)) {
					closedir(SUB_DIR);
					
					createDesktopIcon($homeDir.$_, $_);
				}
			}
			closedir(HOME_DIR);
		}
	}
	else {
		# Normaler Benutzer
		createDesktopIcon($ENV{"HOME"}, $ENV{"USER"});
	}
}



######################################################################################################################
# Desktop Icon erzeugen
######################################################################################################################
sub createDesktopIcon {
	my ($dir, $user) = @_;
	$dir.="/Desktop/";
	
	if(my ($login, $pass, $uid, $gid) = getpwnam($user)) {
		if(opendir(DIR, $dir)) {
			closedir(DIR);
			if(!open(ICON, ">", $dir.$DESKTOP_ICON_NAME)) {
				print "Kann Iconfile nicht öffnen.\n";
				exit 1;
			}
			else {
				printf ICON $DESKTOP_ICON_FORMAT, $installDir, $installDir;
				close(ICON);
			}
			
			chown $uid, $gid, $dir.$DESKTOP_ICON_NAME;
			chmod 0755, $dir.$DESKTOP_ICON_NAME;
		}
	}
}



######################################################################################################################
# Aufräumen + Abschließende Arbeiten
######################################################################################################################
sub cleanup {
	# Entferne Installationspakete
	if($keepPackages==0) {
		unlink(@filesToRemove);
	}
	
	# Erzeuge Symlinks für Libs
	if(opendir(INSTALL_DIR, $installDir)) {
		chdir($installDir);
		my @allFiles=readdir(INSTALL_DIR);
		
		# Werfe alle Einträge mit einem Punkt am Anfang weg
		@allFiles=grep(!/^\./, @allFiles);
		my @libFiles=grep(/\w+\.so\.\w*/, @allFiles);
		
		foreach(@libFiles) {
			my $fileName=$_;
			$fileName =~ /(.+\.so)\.(.*)/;
			my $baseFileName=$1;
			my $version=$2;
			
			my @v = split(/\./, $version);
			
			unlink($baseFileName);
			symlink($fileName, $baseFileName);
			foreach(@v) {
				$baseFileName.=".".$_;
				if($baseFileName ne $fileName) {
					unlink($baseFileName);
					symlink($fileName, $baseFileName);
				}
			}
		}
		
		# Ändere Dateirechte
		my @binarys;
		push(@binarys, $APPLICATION_NAME);
		push(@binarys, $PROGRAM_NAME_FOTOSHOW);
		push(@binarys, "assistant");
		chmod 0755, @binarys;
		
		closedir(INSTALL_DIR);
	}
	
	if($AFFILIATE_ID ne '') {
		if(open(SERVICESXML, ">", $installDir.$SERVICES_XML_PATH)) {
			printf SERVICESXML $SERVICES_XML_FORMAT, $AFFILIATE_ID;
			close(SERVICESXML);
		}
	}
		
	eval { mkpath($installDir."/hps") };
	
	if($>==0) {
		# Root User erlaube schreibenden Zugriff auf das "hps" Unterverzeichniss
		if(!$@) {
			chmod 0777, $installDir."/hps";
		}
	}
}



######################################################################################################################
# MAIN
######################################################################################################################
# Erzwinge eine Leerung der Puffer nach jeder print()-Operation
$| = 1;

system("clear");

getOptions();

print $WELCOME;

checkProgramms();

showEula();

getInstallDir();

getIndexFile();

checkIndexFile();

downloadFiles();

unpackFiles();

cleanup();

createDesktopIcons();

printf $FINISHED_MSG_FORMAT, $installDir;

