#!/usr/bin/perl
# --
# bin/ps.ChangeWorkorderState.pl
# Copyright (C) 2016 Perl-Services.de, http://perl-services.de
# --
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU AFFERO General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
# or see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;

use File::Basename;
use FindBin qw($RealBin);
use lib dirname($RealBin);
use lib dirname($RealBin) . '/Kernel/cpan-lib';
use lib dirname($RealBin) . '/Custom';

use Getopt::Long;

use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Time;
use Kernel::System::Log;
use Kernel::System::Main;
use Kernel::System::DB;
use Kernel::System::User;
use Kernel::System::ITSMChange::ChangeWorkorderState;

# common objects
my %CommonObject;
$CommonObject{ConfigObject} = Kernel::Config->new();
$CommonObject{EncodeObject} = Kernel::System::Encode->new(%CommonObject);
$CommonObject{LogObject}    = Kernel::System::Log->new(
    LogPrefix => 'OTRS-ps.ChangeWorkorderState.pl',
    %CommonObject,
);
$CommonObject{MainObject}        = Kernel::System::Main->new(%CommonObject);
$CommonObject{TimeObject}        = Kernel::System::Time->new(%CommonObject);
$CommonObject{DBObject}          = Kernel::System::DB->new(%CommonObject);
$CommonObject{UserObject}        = Kernel::System::User->new(%CommonObject);
$CommonObject{ChangeStateObject} = Kernel::System::ITSMChange::ChangeWorkorderState->new(%CommonObject);

$CommonObject{ChangeStateObject}->WorkorderStateChange( UserID => 1 );

exit;
