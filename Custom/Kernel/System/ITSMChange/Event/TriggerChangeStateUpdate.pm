# --
# Kernel/System/ITSMChange/Event/TriggerChangeStateUpdate.pm
# Copyright (C) 2016 Perl-Services.de, http://perl-services.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::ITSMChange::Event::TriggerChangeStateUpdate;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::System::ITSMChange
    Kernel::System::ITSMChange::ITSMWorkOrder
    Kernel::System::Log
    Kernel::Config
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $LogObject       = $Kernel::OM->Get('Kernel::System::Log');
    my $ChangeObject    = $Kernel::OM->Get('Kernel::System::ITSMChange');
    my $WorkorderObject = $Kernel::OM->Get('Kernel::System::ITSMChange::WorkOrder');
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');

    # check needed stuff
    for my $Needed (qw(Data Event Config UserID)) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    # do not modify the original event, because we need this unmodified in later event modules
    my $Event = $Param{Event};

    # in history event handling we use Event name without the trailing 'Post'
    $Event =~ s{ Post \z }{}xms;

    return 1 if $Event !~ m{ \A WorkOrder }xms;

    my $TriggerState = $ConfigObject->Get('ChangeWorkorderState::TriggerState');

    return 1 if !$TriggerState;

    # if a State is given, then look up the ID
    my $TriggerStateID = $WorkorderObject->WorkOrderStateLookup(
        WorkOrderState => $TriggerState,
    );

    my $OldStateID = $Param{Data}->{OldWorkOrderData}->{WorkOrderStateID} // 0;
    my $NewStateID = $Param{Data}->{WorkOrderStateID}                     // 0;

    if ( $OldStateID != $NewStateID && $TriggerStateID == $NewStateID ) {
        my $ChangeNewState = $ConfigObject->Get('ChangeWorkorderState::ChangeNewState') // 'delayed';

        $ChangeObject->ChangeUpdate(
            ChangeID    => $Param{Data}->{ChangeID},
            ChangeState => $ChangeNewState,
            UserID      => $Param{UserID},
        );
    }

    return 1;
}

1;

