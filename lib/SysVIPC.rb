require 'SysVIPC/SysVIPC'

# Document-class: SysVIPC
#
# = SysVIPC
#
# Ruby module for System V Inter-Process Communication:
# message queues, semaphores, and shared memory.
#
# Hosted as project sysvipc[http://rubyforge.org/projects/sysvipc/]
# on RubyForge[http://rubyforge.org/].
#
# Copyright (C) 2001, 2006, 2007  Daiki Ueno
# Copyright (C) 2006-2013 James Steven Jenkins
#
# == Usage Synopsis
# === Common Code
#
# All programs using this module must include
#
#     require 'SysVIPC'
#
# It may be convenient to add
#
#     include SysVIPC
#
# All IPC objects are identified by a key. SysVIPC includes a
# convenience function for mapping file names and integer IDs into a
# key:
#
#     key = ftok('/a/file/that/must/exist', 0)
#
# === Message Queues
#
# Get (create if necessary) a message queue:
#
#     mq = MessageQueue.new(key, IPC_CREAT | 0600)
#
# Send a message of type 0:
#
#     mq.send(0, 'message')
#
# Receive up to 100 bytes from the first message of type 0:
#
#     msg = mq.receive(0, 100)
#
# === Semaphores
#
# Get (create if necessary) a set of 5 semaphores:
#
#     sm = Semaphore.new(key, 5, IPC_CREAT | 0600)
#
# Initialize semaphores if newly created:
#
#     sm.setall(Array.new(5, 1)) if sm.pid(0) == 0
#
# Acquire semaphore 2 (waiting if necessary):
#
#     sm.op([Sembuf.new(2, -1)])
#
# Release semaphore 2:
#
#     sm.op([Sembuf.new(2, 1)])
#
# === Shared Memory
#
# Get (create if necessary) an 8192-byte shared memory region:
#
#     sh = SharedMemory.new(key, 8192, IPC_CREAT | 0660)
#
# Attach shared memory:
#
#     shmaddr = sh.attach
#
# Write data:
#
#     shmaddr.write('testing')
#
# Read 100 bytes of data:
#
#     data = shmaddr.read(100);
#
# Detach shared memory:
#
#     sh.detach(shmaddr)
#
# == Installation
#
# 1. <tt>ruby setup.rb config</tt>
# 2. <tt>ruby setup.rb setup</tt>
# 3. <tt>ruby setup.rb install</tt> (requires appropriate privilege)
#
# == Testing
#
# 1. <tt>./test_sysvipc_l</tt> (low-level interface)
# 2. <tt>./test_sysvipc_h</tt> (high-level interface)

module SysVIPC

  def check_result(res)                                      # :nodoc:
    raise SystemCallError.new(SysVIPC.errno), nil, caller if res == -1
  end

  class MessageQueue

    include SysVIPC

    private

    # Return a MessageQueue object encapsuating a message queue
    # associated with +key+. See msgget(2).

    def initialize(key, flags = 0)
      @msgid = msgget(key, flags)
      check_result(@msgid)
    end

    public

    attr_reader :msgid

    # Return the Msqid_ds object. See msgctl(2).

    def ipc_stat
      res, msqid_ds = msgctl(@msgid, IPC_STAT)
      check_result(res)
      msqid_ds
    end
    alias :msqid_ds :ipc_stat

    # Set the Msqid_ds object. See msgctl(2).

    def ipc_set(msqid_ds)
      unless Msqid_ds === msqid_ds
	raise ArgumentError,
	  "argument to ipc_set must be a Msqid_ds"
      end
      check_result(msgctl(@msgid, IPC_SET, msqid_ds))
    end
    alias :msqid_ds= :ipc_set

    # Remove. See msgctl(2).

    def ipc_rmid
      check_result(msgctl(@msgid, IPC_RMID, nil))
    end
    alias :rm :ipc_rmid

    # Send a message with type +type+ and text +text+. See msgsnd(2).

    def snd(type, text, flags = 0)
      check_result(msgsnd(@msgid, type, text, flags))
    end
    alias :send :snd

    # Receive a message of type +type+, limited to +len+ bytes or fewer.
    # See msgrcv(2).

    def rcv(type, size, flags = 0)
      res, mtype, mtext = msgrcv(@msgid, size, type, flags)
      check_result(res)
      mtext
    end
    alias :receive :rcv

  end

  class Sembuf

    include SysVIPC

    alias :orig_initialize :initialize

    # Create a new Sembuf object for semaphore number +sem_num+,
    # operation +sem_op+, and flags +sem_flg+. See semop(2).

    def initialize(sem_num, sem_op, sem_flg = 0)
      orig_initialize
      self.sem_num = sem_num
      self.sem_op = sem_op
      self.sem_flg = sem_flg
    end

  end

  class Semaphore

    include SysVIPC

    private

    # Return a Sempahore object encapsulating a
    # set of +nsems+ semaphores associated with +key+. See semget(2).

    def initialize(key, nsems, flags)
      @nsems = nsems
      @semid = semget(key, nsems, flags)
      check_result(@semid)
    end

    public

    attr_reader :semid

    # Set each value in the semaphore set to the corresponding value
    # in the Array +values+. See semctl(2).

    def setall(values)
      if values.length > @nsems
	raise ArgumentError,
	  "too many values (#{values.length}) for semaphore set (#{@nsems})"
      end
      check_result(semctl(@semid, 0, SETALL, values))
    end

    # Return an Array containing the value of each semaphore in the
    # set. See semctl(2).

    def getall
      res, array = semctl(@semid, 0, GETALL)
      check_result(res)
      array
    end

    # Set the value of semaphore +semnum+ to +val+. See semctl(2).

    def setval(semnum, val)
      check_result(semctl(@semid, semnum, SETVAL, val))
    end

    # Get the value of semaphore +semnum+. See semctl(2).

    def getval(semnum)
      semctl(@semid, semnum, GETVAL)
    end
    alias :val :getval

    # Get the process ID of the last semaphore operation. See
    # semctl(2).

    def getpid(semnum)
      semctl(@semid, semnum, GETPID)
    end
    alias :pid :getpid

    # Get the number of processes waiting for a semaphore to become
    # non-zero. See semctl(2).

    def getncnt(semnum)
      semctl(@semid, semnum, GETNCNT)
    end
    alias :ncnt :getncnt

    # Get the number of processes waiting for a semaphore to become
    # zero. See semctl(2).

    def getzcnt(semnum)
      semctl(@semid, semnum, GETZCNT)
    end
    alias :zcnt :getzcnt

    # Return the Semid_ds object. See semctl(2).

    def ipc_stat
      res, semid_ds = semctl(@semid, 0, IPC_STAT)
      check_result(res)
      semid_ds
    end
    alias :semid_ds :ipc_stat

    # Set the Semid_ds object. See semctl(2).

    def ipc_set(semid_ds)
      unless Semid_ds === semid_ds
	raise ArgumentError,
	  "argument to ipc_set must be a Semid_ds"
      end
      check_result(semctl(@semid, 0, IPC_SET, semid_ds))
    end
    alias :semid_ds= :ipc_set

    # Remove. See semctl(2).

    def ipc_rmid
      check_result(semctl(@semid, 0, IPC_RMID))
    end
    alias :rm :ipc_rmid

    # Perform a set of semaphore operations. The argument +array+ is
    # an Array of Sembuf objects. See semop(2).

    def op(array)
      check_result(semop(@semid, array, array.length))
    end

  end

  class SharedMemory
    
    include SysVIPC

    private

    # Return a SharedMemory object encapsulating a
    # shared memory segment of +size+ bytes associated with
    # +key+. See shmget(2).

    def initialize(key, size, flags = 0)
      @shmid = shmget(key, size, flags)
      check_result(@shmid)
    end

    public

    attr_reader :shmid

    # Return the Shmid_ds object. See shmctl(2).

    def ipc_stat
      res, shmid_ds = shmctl(@shmid, IPC_STAT)
      check_result(res)
      shmid_ds
    end
    alias :shmid_ds :ipc_stat

    # Set the Shmid_ds object. See shmctl(2).

    def ipc_set(shmid_ds)
      unless Shmid_ds === shmid_ds
	raise ArgumentError,
	  "argument to ipc_set must be a Shmid_ds"
      end
      check_result(shmctl(@shmid, IPC_SET, shmid_ds))
    end
    alias shmid_ds= :ipc_set

    # Remove. See shmctl(2).

    def ipc_rmid
      check_result(shmctl(@shmid, IPC_RMID, nil))
    end
    alias :rm :ipc_rmid

    # Attach to a shared memory address object and return it.
    # See shmat(2). If +shmaddr+ is nil, the shared memory is attached
    # at the first available address as selected by the system. See
    # shmat(2).

    def attach(shmaddr = nil, flags = 0)
      shmaddr = shmat(@shmid, shmaddr, flags)
      check_result(shmaddr)
      shmaddr
    end

    # Detach the +Shmaddr+ object +shmaddr+. See shmdt(2).

    def detach(shmaddr)
      check_result(shmdt(shmaddr))
    end

  end

  class Shmaddr

    include SysVIPC

    # Write the string +text+ to offset +offset+.

    def write(text, offset = 0)
      shmwrite(self, text, offset)
    end
    alias :<< :write

    # Read +len+ bytes at offset +offset+ and return them in a String.

    def read(len, offset = 0)
      shmread(self, len, offset)
    end

  end

end

require 'SysVIPC/version'
