use lib 'inc';
use ExtUtils::MakeMaker;
use Inline::Module;

WriteMakefile(
        'NAME' => 'watchdog',

#       'VERSION_FROM' => 'variabless.pm',

        'PM' => { 'common/bypass_loop' => '$(INST_LIBDIR)/common/bypass_loop.pm',
                  'common/variables' => '$(INST_LIBDIR)/common/variables.pm',
                  'modules/bypass_state' => '$(INST_LIBDIR)/modules/bypass_state.pm',
                  'modules/check_drops' => '$(INST_LIBDIR)/modules/check_drops.pm',
                  'modules/filerefresh' => '$(INST_LIBDIR)/modules/filerefresh.pm',
                  'modules/logging' => '$(INST_LIBDIR)/modules/logging.pm',
                  'modules/mail_send' => '$(INST_LIBDIR)/modules/mail_send.pm',
                  'modules/process_check' => '$(INST_LIBDIR)/modules/process_check.pm',
                  'modules/stuck_check' => '$(INST_LIBDIR)/modules/stuck_check.pm',
                  'modules/wdlogstatus' => '$(INST_LIBDIR)/modules/wdlogstatus.pm',
                  'modules/zombie_check' => '$(INST_LIBDIR)/modules/zombie_check',
                  'scripts/bypass_off' => '$(INST_LIBDIR)/scripts/bypass_off.pm',
                  'scripts/bypass_on' => '$(INST_LIBDIR)/scripts/bypass_on.pm',
                  'scripts/restart' => '$(INST_LIBDIR)/scripts/restart',
                  'scripts/start' => '$(INST_LIBDIR)/scripts/start'},
);