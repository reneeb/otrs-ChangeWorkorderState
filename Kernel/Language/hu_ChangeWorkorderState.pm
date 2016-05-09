# --
# Kernel/Language/hu_ChangeWorkorderState.pm - the Hungarian translation for ChangeWorkorderState
# Copyright (C) 2014-2016 Perl-Services, http://www.perl-services.de
# Copyright (C) 2016 Balázs Úr, http://www.otrs-megoldasok.hu
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::hu_ChangeWorkorderState;

use strict;
use warnings;

use utf8;

our $VERSION = 0.01;

sub Data {
    my $Self = shift;

    my $Lang = $Self->{Translation};

    return if ref $Lang ne 'HASH';

    # Kernel/Config/Files/ChangeWorkorderState.xml
    $Lang->{'En-/Disables debugging mode for ChangeWorkorderState.'} =
        'Engedélyezi vagy letiltja a ChangeWorkorderState hibakereső módját.';
    $Lang->{'New state for change when "any" workorder is delayed.'} =
        'A változás új állapota, amikor „bármely” munkamegrendelés késik.';
    $Lang->{'New state for change when "last" workorder is delayed.'} =
        'A változás új állapota, amikor az „utolsó” munkamegrendelés késik.';
    $Lang->{'New state for workorder when it is delayed.'} = 'A munkamegrendelés új állapota, amikor késik.';
    $Lang->{'New state for workorder when it is overdued.'} = 'A munkamegrendelés új állapota, amikor lejárt.';
    $Lang->{'Workorders with those states are considered for state changes.'} =
        'Az ilyen állapotú munkamegrendelések lesznek figyelembe véve az állapotváltozásoknál.';
    $Lang->{'Workorders with those types are considered for state changes.'} =
        'Az ilyen típusú munkamegrendelések lesznek figyelembe véve az állapotváltozásoknál.';
    $Lang->{'Ratio of remaining (planned) effort and remaining time that is used to check whether a workorder state should be changed.'} =
        'A hátralévő (tervezett) ráfordítás és a hátralévő idő aránya, amely annak ellenőrzéséhez használható, hogy egy munkamegrendelés állapotát meg kell-e változtatni.';
    $Lang->{'Defines which unit is used for time accounting.'} =
        'Meghatározza, hogy milyen egység legyen használva az időelszámolásnál.';
    $Lang->{'Change state for delayed workorders.'} = 'Változásállapot a késésben lévő munkamegrendeléseknél.';
    $Lang->{'Change Workorder States'} = 'Munkamegrendelés-állapotok megváltoztatása';
    $Lang->{'ITSM event module that updates the change state based on the workorder state.'} =
        'ITSM eseménymodul, amely frissíti a változás állapotát a munkamegrendelés állapota alapján.';
    $Lang->{'Workorders that state is changed to this state and trigger a change of the change state.'} =
        'Munkamegrendelések, amelyek állapota erre az állapotra lett megváltoztatva, és aktiválják a változásállapot megváltoztatását.';
    $Lang->{'New state for change when workorder state update triggers a change state update.'} =
        'A változás új állapota, amikor a munkamegrendelés állapotfrissítése aktivál egy változásállapot frissítést.';
    $Lang->{'Minute'} = 'Perc';
    $Lang->{'Hour'} = 'Óra';
    $Lang->{'Day'} = 'Nap';
    $Lang->{'No'} = 'Nem';
    $Lang->{'Yes'} = 'Igen';

    return 1;
}

1;
