# --
# Kernel/Language/de_ChangeWorkorderState.pm - the German translation for ChangeWorkorderState
# Copyright (C) 2014-2016 Perl-Services, http://www.perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_ChangeWorkorderState;

use strict;
use warnings;

use utf8;

our $VERSION = 0.01;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    # Kernel/Config/Files/ChangeWorkorderState.xml
    $Lang->{'En-/Disables debugging mode for ChangeWorkorderState.'} = '';
    $Lang->{'New state for change when "any" workorder is delayed.'} = '';
    $Lang->{'New state for change when "last" workorder is delayed.'} = '';
    $Lang->{'New state for workorder when it is delayed.'} = '';
    $Lang->{'New state for workorder when it is overdued.'} = '';
    $Lang->{'Workorders with those states are considered for state changes.'} = '';
    $Lang->{'Workorders with those types are considered for state changes.'} = '';
    $Lang->{'Ratio of remaining (planned) effort and remaining time that is used to check whether a workorder state should be changed.'} = '';
    $Lang->{'Defines which unit is used for time accounting.'} = '';
    $Lang->{'Change state for delayed workorders.'} = '';
    $Lang->{'Change Workorder States'} = '';
    $Lang->{'ITSM event module that updates the change state based on the workorder state.'} = '';
    $Lang->{'Workorders that state is changed to this state and trigger a change of the change state.'} = '';
    $Lang->{'New state for change when workorder state update triggers a change state update.'} = '';
    $Lang->{'Minute'} = 'Minute';
    $Lang->{'Hour'} = 'Stunde';
    $Lang->{'Day'} = 'Tag';
    $Lang->{'No'} = 'Nein';
    $Lang->{'Yes'} = 'Ja';

    return 1;
}

1;
