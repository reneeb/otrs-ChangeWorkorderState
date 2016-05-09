package Kernel::System::ITSMChange::ChangeWorkorderState;

use strict;
use warnings;

our @ObjectDependencies = qw(
    Kernel::Config
    Kernel::System::DB
    Kernel::System::Log
    Kernel::System::Main
    Kernel::System::Time
    Kernel::System::GeneralCatalog
    Kernel::System::ITSMChange
    Kernel::System::ITSMChange::ITSMWorkOrder
);

=item new()

=cut

sub new {
    my ($Class, %Param) = @_;

    my $Self = bless {}, $Class;

    return $Self;
}

=item WorkorderStateChange()

=cut

sub WorkorderStateChange {
    my ($Self, %Param) = @_;

    my $LogObject       = $Kernel::OM->Get('Kernel::System::Log');
    my $ConfigObject    = $Kernel::OM->Get('Kernel::Config');
    my $ChangeObject    = $Kernel::OM->Get('Kernel::System::ITSMChange');
    my $WorkorderObject = $Kernel::OM->Get('Kernel::System::ITSMChange::ITSMWorkOrder');

    for my $Needed ( qw/UserID/ ) {
        if ( !$Param{$Needed} ) {
            $LogObject->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
        }
    }

    my $ChangeNewStateOverdue    = $ConfigObject->Get('ChangeWorkorderState::ChangeNewStateOverdue');
    my $ChangeNewStateDelayed    = $ConfigObject->Get('ChangeWorkorderState::ChangeNewStateDelayed');
    my $WorkorderNewStateDelayed = $ConfigObject->Get('ChangeWorkorderStateDelayed::WorkorderNewStateDelayed') || 'delayed';
    my $WorkorderNewStateOverdue = $ConfigObject->Get('ChangeWorkorderStateOverdue::WorkorderNewStateOverdue') || 'overdue';

    my @Workorders = $Self->DelayedWorkordersGet();
    for my $Workorder ( @Workorders ) {
        my $State = $WorkorderNewStateDelayed;
        if ( $Workorder->{IsOverdue} ) {
            $State = $WorkorderNewStateOverdue;
        }

        $WorkorderObject->WorkOrderUpdate(
            WorkOrderID    => $Workorder->{WorkOrderID},
            WorkOrderState => $State,
            UserID         => $Param{UserID},
        );

        if ( $ChangeNewStateDelayed ) {
            $ChangeObject->ChangeUpdate(
                ChangeID    => $Workorder->{ChangeID},
                ChangeState => $ChangeNewStateDelayed,
                UserID      => $Param{UserID},
            );
        }

        if ( $Workorder->{IsLastWorkorder} && $ChangeNewStateOverdue ) {
            $ChangeObject->ChangeUpdate(
                ChangeID    => $Workorder->{ChangeID},
                ChangeState => $ChangeNewStateOverdue,
                UserID      => $Param{UserID},
            );
        }
    }
}

=item DelayedWorkordersGet()

Get a list of workorders that are delayed. Be default that are workorders which planned end time
is in the past.

If I<ChangeWorkorderState::EffortTimeRatio> is set, this calculation is done:

  given_ratio = ( (planned effort - accounted time) / (planned end time - current time) ) * 100

if C<given_ratio> is greater than the value configured in I<ChangeWorkorderState::EffortTimeRatio>,
the workorder will be in the list.

  my @DelayedWorkorders = $Object->DelayedWorkordersGet();

Each element in this list is a hash reference that looks like

  {
      WorkOrderID     => 123,
      ChangeID        => 1351,
      IsLastWorkorder => 13512,
      PlannedEffort   => 13,
      AccountedTime   => 2.3,
      PlannedEndTime  => '2016-05-02',
  }

=cut

sub DelayedWorkordersGet {
    my ($Self, %Param) = @_;

    my $LogObject            = $Kernel::OM->Get('Kernel::System::Log');
    my $MainObject           = $Kernel::OM->Get('Kernel::System::Main');
    my $ConfigObject         = $Kernel::OM->Get('Kernel::Config');
    my $DBObject             = $Kernel::OM->Get('Kernel::System::DB');
    my $TimeObject           = $Kernel::OM->Get('Kernel::System::Time');
    my $GeneralCatalogObject = $Kernel::OM->Get('Kernel::System::GeneralCatalog');

    my $DEBUG = $ConfigObject->Get('ChangeWorkorderState::Debug');

    my @States = @{ $ConfigObject->Get('ChangeWorkorderState::WorkorderStates') || [] };
    my @Types  = @{ $ConfigObject->Get('ChangeWorkorderType::WorkorderTypes') || [] };

    my $GCStates = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ChangeManagement::WorkOrder::State',
    ) || {};

    my %StateMap = reverse %{ $GCStates // {} };

    my $GCTypes = $GeneralCatalogObject->ItemList(
        Class => 'ITSM::ChangeManagement::WorkOrder::Type',
    ) || {};

    my %TypeMap = reverse %{ $GCTypes // {} };

    if ( $DEBUG ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => $MainObject->Dump( [ $GCStates, $GCTypes ] ),
        );
    }

    my @Where;
    my @Bind;
    if ( @States ) {
        my @StateIDs         = @StateMap{@States};
        my $StatePlaceholder = join ', ', ('?') x @StateIDs;

        push @Where, 'wo.workorder_state_id IN (' . $StatePlaceholder . ')';
        push @Bind, map{ \$_ }@StateIDs;
    }

    if ( @Types ) {
        my @TypeIDs         = @TypeMap{@Types};
        my $TypePlaceholder = join ', ', ('?') x @TypeIDs;

        push @Where, 'wo.workorder_type_id IN (' . $TypePlaceholder . ')';
        push @Bind, map{ \$_ }@TypeIDs;
    }

    my $Where = join ' OR ', @Where;

    my $SQL = qq~
        SELECT wo.id, wo.change_id, planned_end_time, planned_effort, accounted_time
        FROM change_workorder wo
        WHERE $Where
        ORDER BY change_id, planned_end_time ASC
    ~;

    if ( $DEBUG ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => $MainObject->Dump( [ $SQL, \@Bind ] ),
        );
    }

    return if !$DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my %LastWorkorderPerChange;
    my %Workorders;

    while ( my @Row = $DBObject->FetchrowArray() ) {
        $Workorders{ $Row[0] } = {
            WorkOrderID     => $Row[0],
            ChangeID        => $Row[1],
            IsLastWorkorder => 0,
            PlannedEffort   => $Row[3],
            AccountedTime   => $Row[4],
            PlannedEndTime  => $Row[2],
        };
    }

    if ( $DEBUG ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => $MainObject->Dump( [ \%LastWorkorderPerChange, \%Workorders ] ),
        );
    }

    for my $ChangeID ( keys %LastWorkorderPerChange ) {
        my $WorkorderID = $LastWorkorderPerChange{$ChangeID};
        $Workorders{$WorkorderID}->{IsLastWorkorder}++;
    }

    if ( $DEBUG ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => $MainObject->Dump( \%Workorders ),
        );
    }

    my $TargetRatio = $ConfigObject->Get('ChangeWorkorderState::EffortTimeRatio' );
    my $TimeUnit    = $ConfigObject->Get('ChangeWorkorderState::TimeUnit' );
  
    my $CalcType    = 'PlannedEndTime';

    if ( $TargetRatio ) {
        $CalcType = 'Ratio';
    }

    if ( $DEBUG ) {
        $LogObject->Log(
            Priority => 'debug',
            Message  => $CalcType . " " . ( $TargetRatio // '' ),
        );
    }

    WORKORDERID:
    for my $WorkorderID ( keys %Workorders ) {
        my $Workorder = $Workorders{$WorkorderID};

        my $CurrentTime    = $TimeObject->SystemTime();
        my $PlannedEndTime = $TimeObject->TimeStamp2SystemTime( String => $Workorder->{PlannedEndTime} );

        if ( $DEBUG ) {
            $LogObject->Log(
                Priority => 'debug',
                Message  => $MainObject->Dump( [ $CurrentTime, $PlannedEndTime ] ),
            );
        }

        my $IsDelayed = 0;
        my $IsOverdue = 0;

        if ( $CurrentTime >= $PlannedEndTime ) {
            $IsDelayed++;
            $IsOverdue++;
        }

        my $AvailableTime = $PlannedEndTime - $CurrentTime;

        my $GivenRatio = (
            ( ( $Workorder->{PlannedEffort} - $Workorder->{AccountedTime} ) * $TimeUnit )/
            $AvailableTime
        ) * 100;

        if ( $GivenRatio <= 0 || $GivenRation >= $TargetRatio )
            $IsDelayed++;

            if ( $DEBUG ) {
                $LogObject->Log(
                    Priority => 'debug',
                    Message  => "AvailableTime: $AvailableTime // "
                        . "AccountedTime: $Workorder->{AccountedTime} // "
                        . "GivenRatio: $GivenRatio",
                );
            }
        }

        if ( $DEBUG ) {
            $LogObject->Log(
                Priority => 'debug',
                Message  => "IsDelayed: $IsDelayed",
            );
        }

        if ( !$IsDelayed ) {
            delete $Workorders{$WorkorderID};
            next WORKORDERID;
        }

        $Workorders{$WorkorderID}->{IsDelayed} = 1;
        $Workorders{$WorkorderID}->{IsOverdue} = $IsOverdue;
    }

    return values %Workorders;
}

1;
