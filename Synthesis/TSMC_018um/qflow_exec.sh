#!/bin/tcsh -f
#-------------------------------------------
# qflow exec script for project /home/arvin/Desktop/QFlow_test/phoeniX
#-------------------------------------------

# /usr/local/share/qflow/scripts/synthesize.sh /home/arvin/Desktop/QFlow_test/phoeniX phoeniX /home/arvin/Desktop/QFlow_test/phoeniX/source/phoeniX.v || exit 1
# /usr/local/share/qflow/scripts/placement.sh -d /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
# /usr/local/share/qflow/scripts/vesta.sh  /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
# /usr/local/share/qflow/scripts/router.sh /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
# /usr/local/share/qflow/scripts/vesta.sh  -d /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
# /usr/local/share/qflow/scripts/migrate.sh /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
# /usr/local/share/qflow/scripts/drc.sh /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
# /usr/local/share/qflow/scripts/lvs.sh /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
/usr/local/share/qflow/scripts/gdsii.sh /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
# /usr/local/share/qflow/scripts/cleanup.sh /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
# /usr/local/share/qflow/scripts/display.sh /home/arvin/Desktop/QFlow_test/phoeniX phoeniX || exit 1
