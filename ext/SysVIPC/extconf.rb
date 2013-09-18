require 'mkmf'

# SWIG includes string.h before everything else, which on some
# platforms includes features.h, which defines __USE_GNU if
# _GNU_SOURCE is defined, which it is not by default. Mkmf, in
# contrast, includes ruby.h in its configuration tests, which defines
# _GNU_SOURCE and then includes string.h, which causes __USE_GNU
# to be defined. The visibility of struct msgbuf is conditioned
# on __USE_GNU being defined, which means that the configuration tests
# and actual compilation are inconsistent. The following line forces
# _GNU_SOURCE to be defined on the command line.

with_cppflags('-D_GNU_SOURCE') { true }

ipc_headers = %w{ sys/types.h sys/ipc.h }
msg_headers = ipc_headers.dup << 'sys/msg.h'
sem_headers = ipc_headers.dup << 'sys/sem.h'
shm_headers = ipc_headers.dup << 'sys/shm.h'

# Definitions are provided if missing.

have_type('struct msgbuf', msg_headers)
have_type('union semun', sem_headers)

# Required functions. It's assumed that the entire msg* library is
# present if msgget is present, and likewise for sem and shm.

have_func('msgget', msg_headers) or missing('msgget')
have_func('semget', sem_headers) or missing('semget')
have_func('shmget', shm_headers) or missing('shmget')

create_makefile('SysVIPC')
