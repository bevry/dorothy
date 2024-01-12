# Exit Status and Bash

Dorothy handles exit status with several practices.

## Naming

We use exit status, as that is what the bash manual uses. Exit status is also known as: exit code, return code, error code, etc.

## Selection

The exit status should be selected from one of these standards.

### moreutil/errno

For exit statuses 1-106, `errno -l` from the `moreutil` package defines the following:

```plain
EPERM 1 Operation not permitted
ENOENT 2 No such file or directory
ESRCH 3 No such process
EINTR 4 Interrupted system call
EIO 5 Input/output error
ENXIO 6 Device not configured
E2BIG 7 Argument list too long
ENOEXEC 8 Exec format error
EBADF 9 Bad file descriptor
ECHILD 10 No child processes
EDEADLK 11 Resource deadlock avoided
ENOMEM 12 Cannot allocate memory
EACCES 13 Permission denied
EFAULT 14 Bad address
ENOTBLK 15 Block device required
EBUSY 16 Resource busy
EEXIST 17 File exists
EXDEV 18 Cross-device link
ENODEV 19 Operation not supported by device
ENOTDIR 20 Not a directory
EISDIR 21 Is a directory
EINVAL 22 Invalid argument
ENFILE 23 Too many open files in system
EMFILE 24 Too many open files
ENOTTY 25 Inappropriate ioctl for device
ETXTBSY 26 Text file busy
EFBIG 27 File too large
ENOSPC 28 No space left on device
ESPIPE 29 Illegal seek
EROFS 30 Read-only file system
EMLINK 31 Too many links
EPIPE 32 Broken pipe
EDOM 33 Numerical argument out of domain
ERANGE 34 Result too large
EAGAIN 35 Resource temporarily unavailable
EWOULDBLOCK 35 Resource temporarily unavailable
EINPROGRESS 36 Operation now in progress
EALREADY 37 Operation already in progress
ENOTSOCK 38 Socket operation on non-socket
EDESTADDRREQ 39 Destination address required
EMSGSIZE 40 Message too long
EPROTOTYPE 41 Protocol wrong type for socket
ENOPROTOOPT 42 Protocol not available
EPROTONOSUPPORT 43 Protocol not supported
ESOCKTNOSUPPORT 44 Socket type not supported
ENOTSUP 45 Operation not supported
EPFNOSUPPORT 46 Protocol family not supported
EAFNOSUPPORT 47 Address family not supported by protocol family
EADDRINUSE 48 Address already in use
EADDRNOTAVAIL 49 Can't assign requested address
ENETDOWN 50 Network is down
ENETUNREACH 51 Network is unreachable
ENETRESET 52 Network dropped connection on reset
ECONNABORTED 53 Software caused connection abort
ECONNRESET 54 Connection reset by peer
ENOBUFS 55 No buffer space available
EISCONN 56 Socket is already connected
ENOTCONN 57 Socket is not connected
ESHUTDOWN 58 Can't send after socket shutdown
ETOOMANYREFS 59 Too many references: can't splice
ETIMEDOUT 60 Operation timed out
ECONNREFUSED 61 Connection refused
ELOOP 62 Too many levels of symbolic links
ENAMETOOLONG 63 File name too long
EHOSTDOWN 64 Host is down
EHOSTUNREACH 65 No route to host
ENOTEMPTY 66 Directory not empty
EPROCLIM 67 Too many processes
EUSERS 68 Too many users
EDQUOT 69 Disc quota exceeded
ESTALE 70 Stale NFS file handle
EREMOTE 71 Too many levels of remote in path
EBADRPC 72 RPC struct is bad
ERPCMISMATCH 73 RPC version wrong
EPROGUNAVAIL 74 RPC prog. not avail
EPROGMISMATCH 75 Program version wrong
EPROCUNAVAIL 76 Bad procedure for program
ENOLCK 77 No locks available
ENOSYS 78 Function not implemented
EFTYPE 79 Inappropriate file type or format
EAUTH 80 Authentication error
ENEEDAUTH 81 Need authenticator
EPWROFF 82 Device power is off
EDEVERR 83 Device error
EOVERFLOW 84 Value too large to be stored in data type
EBADEXEC 85 Bad executable (or shared library)
EBADARCH 86 Bad CPU type in executable
ESHLIBVERS 87 Shared library version mismatch
EBADMACHO 88 Malformed Mach-o file
ECANCELED 89 Operation canceled
EIDRM 90 Identifier removed
ENOMSG 91 No message of desired type
EILSEQ 92 Illegal byte sequence
ENOATTR 93 Attribute not found
EBADMSG 94 Bad message
EMULTIHOP 95 EMULTIHOP (Reserved)
ENODATA 96 No message available on STREAM
ENOLINK 97 ENOLINK (Reserved)
ENOSR 98 No STREAM resources
ENOSTR 99 Not a STREAM
EPROTO 100 Protocol error
ETIME 101 STREAM ioctl timeout
EOPNOTSUPP 102 Operation not supported on socket
ENOPOLICY 103 Policy not found
ENOTRECOVERABLE 104 State not recoverable
EOWNERDEAD 105 Previous owner died
EQFULL 106 Interface output queue is full
ELAST 106 Interface output queue is full
```

### Signals

For exit statuses 128-199 these are signals sent by the `kill` command, which may or may not cause an exit status. If an exit status is returned, then it uses the formula 128 + signal number. Why 128? 128 is the signal used by `kill` to check if a process is with a given PID exists.

The [GNU `coreutils` specification](https://www.gnu.org/software/coreutils/manual/html_node/Signal-specifications.html) defines the following:

```plain
The following signal names and numbers are supported on all POSIX compliant systems:

1. SIGHUP: Hangup  [Exit Status: 128 + 1 = 129]
2. SIGINT: Terminal interrupt  [Exit Status: 128 + 2 = 130]
3. SIGQUIT: Terminal quit  [Exit Status: 128 + 3 = 131]
6. SIGABRT: Process abort  [Exit Status: 128 + 6 = 134]
9. SIGKILL: Kill (cannot be caught or ignored)  [Exit Status: 128 + 9 = 137]
14. SIGALRM: Alarm Clock  [Exit Status: 128 + 14 = 142]
15. SIGTERM: Termination  [Exit Status: 128 + 15 = 143]

Other supported signal names have system-dependent corresponding numbers. All systems conforming to POSIX 1003.1-2001 also support the following signals [exit statuses vary]:

SIGBUS: Access to an undefined portion of a memory object
SIGCHLD: Child process terminated, stopped, or continued
SIGCONT: Continue executing, if stopped
SIGFPE: Erroneous arithmetic operation
SIGILL: Illegal Instruction
SIGPIPE: Write on a pipe with no one to read it
SIGSEGV: Invalid memory reference
SIGSTOP: Stop executing (cannot be caught or ignored)
SIGTSTP: Terminal stop
SIGTTIN: Background process attempting read
SIGTTOU: Background process attempting write
SIGURG: High bandwidth data is available at a socket
SIGUSR1: User-defined signal 1
SIGUSR2: User-defined signal 2

POSIX 1003.1-2001 systems that support the XSI extension also support the following signals [exit statuses vary]:

SIGPOLL: Pollable event
SIGPROF: Profiling timer expired
SIGSYS: Bad system call
SIGTRAP: Trace/breakpoint trap
SIGVTALRM: Virtual timer expired
SIGXCPU: CPU time limit exceeded
SIGXFSZ: File size limit exceeded

POSIX 1003.1-2001 systems that support the XRT extension also support at least eight real-time signals called ‘RTMIN’, ‘RTMIN+1’, …, ‘RTMAX-1’, ‘RTMAX’.
```

On macOS Ventura, Bash Shell `trap -l` and Fish Shell `trap -l` define the following (with descriptions and exit status filled in by ChatGPT):

```plain
1. SIGHUP (Hangup signal. Sent to a process when its controlling terminal is closed.)  [Exit Status: 128 + 1 = 129]
2. SIGINT (Interrupt signal. Sent to interrupt the process and typically initiated by pressing Ctrl+C.)  [Exit Status: 128 + 2 = 130]
3. SIGQUIT (Quit signal. Similar to SIGINT but typically results in a core dump for debugging.)  [Exit Status: 128 + 3 = 131]
4. SIGILL (Illegal instruction signal. Sent to a process when it attempts to execute an illegal or privileged instruction.)  [Exit Status: 128 + 4 = 132]
5. SIGTRAP (Trap signal. Used for debugging traps, often used by debuggers to set breakpoints.)  [Exit Status: 128 + 5 = 133]
6. SIGABRT (Abort signal. Sent by the process to itself when it detects a critical error.)  [Exit Status: 128 + 6 = 134]
7. SIGEMT (EMT signal. Used on some architectures to indicate hardware exceptions.)  [Exit Status: 128 + 7 = 135]
8. SIGFPE (Floating-Point Exception signal. Sent to a process when it performs an illegal arithmetic operation.)  [Exit Status: 128 + 8 = 136]
9. SIGKILL (Kill signal. Sent to forcefully terminate a process. Cannot be caught or ignored.)  [Exit Status: 128 + 9 = 137]
10. SIGBUS (Bus Error signal. Sent to a process when it references an invalid memory address.)  [Exit Status: 128 + 10 = 138]
11. SIGSEGV (Segmentation Fault signal. Sent to a process when it accesses a memory segment that it doesn't have permission to access.)  [Exit Status: 128 + 11 = 139]
12. SIGSYS (Bad System Call signal. Sent to a process when it makes an invalid system call.)  [Exit Status: 128 + 12 = 140]
13. SIGPIPE (Pipe Broken signal. Sent when a process attempts to write to a pipe without a process reading from the other end.)  [Exit Status: 128 + 13 = 141]
14. SIGALRM (Alarm Clock signal. Sent when the timer set by the alarm system call expires.)  [Exit Status: 128 + 14 = 142]
15. SIGTERM (Termination signal. Sent to request a process to terminate gracefully.)  [Exit Status: 128 + 15 = 143]
16. SIGURG (Urgent data is available on a socket signal.)  [Exit Status: N/A]
17. SIGSTOP (Stop signal. Sent to pause a process, cannot be caught or ignored.)  [Exit Status: N/A]
18. SIGTSTP (Terminal Stop signal. Sent by pressing Ctrl+Z to pause a process.)  [Exit Status: N/A]
19. SIGCONT (Continue signal. Sent to resume a previously paused process.)  [Exit Status: N/A]
20. SIGCHLD (Child Status Change signal. Sent to the parent process when a child process terminates.)  [Exit Status: N/A]
21. SIGTTIN (Background Read from Control Terminal signal.)  [Exit Status: N/A]
22. SIGTTOU (Background Write to Control Terminal signal.)  [Exit Status: N/A]
23. SIGIO (I/O Available signal. Sent when I/O operations are possible on a file descriptor.)  [Exit Status: N/A]
24. SIGXCPU (CPU Time Limit Exceeded signal. Sent when a process exceeds its allotted CPU time.)  [Exit Status: 128 + 24 = 152]
25. SIGXFSZ (File Size Limit Exceeded signal. Sent when a process tries to create a file larger than the file size limit.)  [Exit Status: 128 + 25 = 153]
26. SIGVTALRM (Virtual Timer Expired signal.)  [Exit Status: N/A]
27. SIGPROF (Profiling Timer signal.)  [Exit Status: N/A]
28. SIGWINCH (Window Size Change signal. Sent to a process when the terminal window size changes.)  [Exit Status: N/A]
29. SIGINFO (Information Request signal. Sent to request status information from a process.)  [Exit Status: N/A]
30. SIGUSR1 (User-Defined signal 1.)  [Exit Status: N/A]
31. SIGUSR2 (User-Defined signal 2.)  [Exit Status: N/A]
```

On Ubuntu 22.04, Bash Shell `trap -l` defines the following (with descriptions and exit status filled in by ChatGPT):

```plain
1. SIGHUP (Hangup signal. Sent to a process when its controlling terminal is closed.) [Exit Status: 128 + 1 = 129]
2. SIGINT (Interrupt signal. Sent to interrupt the process and typically initiated by pressing Ctrl+C.) [Exit Status: 128 + 2 = 130]
3. SIGQUIT (Quit signal. Similar to SIGINT but typically results in a core dump for debugging.) [Exit Status: 128 + 3 = 131]
4. SIGILL (Illegal instruction signal. Sent to a process when it attempts to execute an illegal or privileged instruction.) [Exit Status: 128 + 4 = 132]
5. SIGTRAP (Trap signal. Used for debugging traps, often used by debuggers to set breakpoints.) [Exit Status: 128 + 5 = 133]
6. SIGABRT (Abort signal. Sent by the process to itself when it detects a critical error.) [Exit Status: 128 + 6 = 134]
7. SIGBUS (Bus Error signal. Sent to a process when it references an invalid memory address.) [Exit Status: 128 + 7 = 135]
8. SIGFPE (Floating-Point Exception signal. Sent to a process when it performs an illegal arithmetic operation.) [Exit Status: 128 + 8 = 136]
9. SIGKILL (Kill signal. Sent to forcefully terminate a process. Cannot be caught or ignored.) [Exit Status: 128 + 9 = 137]
10. SIGUSR1 (User-Defined signal 1.) [Exit Status: N/A]
11. SIGSEGV (Segmentation Fault signal. Sent to a process when it accesses a memory segment that it doesn't have permission to access.) [Exit Status: 128 + 11 = 139]
12. SIGUSR2 (User-Defined signal 2.) [Exit Status: N/A]
13. SIGPIPE (Pipe Broken signal. Sent when a process attempts to write to a pipe without a process reading from the other end.) [Exit Status: 128 + 13 = 141]
14. SIGALRM (Alarm Clock signal. Sent when the timer set by the alarm system call expires.) [Exit Status: 128 + 14 = 142]
15. SIGTERM (Termination signal. Sent to request a process to terminate gracefully.) [Exit Status: 128 + 15 = 143]
16. SIGSTKFLT (Stack Fault signal.) [Exit Status: N/A]
17. SIGCHLD (Child Status Change signal. Sent to the parent process when a child process terminates.) [Exit Status: N/A]
18. SIGCONT (Continue signal. Sent to resume a previously paused process.) [Exit Status: N/A]
19. SIGSTOP (Stop signal. Sent to pause a process, cannot be caught or ignored.) [Exit Status: N/A]
20. SIGTSTP (Terminal Stop signal. Sent by pressing Ctrl+Z to pause a process.) [Exit Status: N/A]
21. SIGTTIN (Background Read from Control Terminal signal.) [Exit Status: N/A]
22. SIGTTOU (Background Write to Control Terminal signal.) [Exit Status: N/A]
23. SIGURG (Urgent data is available on a socket signal.) [Exit Status: N/A]
24. SIGXCPU (CPU Time Limit Exceeded signal. Sent when a process exceeds its allotted CPU time.) [Exit Status: 128 + 24 = 152]
25. SIGXFSZ (File Size Limit Exceeded signal. Sent when a process tries to create a file larger than the file size limit.) [Exit Status: 128 + 25 = 153]
26. SIGVTALRM (Virtual Timer Expired signal.) [Exit Status: N/A]
27. SIGPROF (Profiling Timer signal.) [Exit Status: N/A]
28. SIGWINCH (Window Size Change signal. Sent to a process when the terminal window size changes.) [Exit Status: N/A]
29. SIGIO (I/O Available signal. Sent when I/O operations are possible on a file descriptor.) [Exit Status: N/A]
30. SIGPWR (Power Fail/Restart signal.) [Exit Status: N/A]
31. SIGSYS (Bad System Call signal. Sent to a process when it makes an invalid system call.) [Exit Status: 128 + 12 = 140]
34. SIGRTMIN (Real-Time signal 0.) [Exit Status: N/A]
35. SIGRTMIN+1 (Real-Time signal 1.) [Exit Status: N/A]
36. SIGRTMIN+2 (Real-Time signal 2.) [Exit Status: N/A]
37. SIGRTMIN+3 (Real-Time signal 3.) [Exit Status: N/A]
38. SIGRTMIN+4 (Real-Time signal 4.) [Exit Status: N/A]
39. SIGRTMIN+5 (Real-Time signal 5.) [Exit Status: N/A]
40. SIGRTMIN+6 (Real-Time signal 6.) [Exit Status: N/A]
41. SIGRTMIN+7 (Real-Time signal 7.) [Exit Status: N/A]
42. SIGRTMIN+8 (Real-Time signal 8.) [Exit Status: N/A]
43. SIGRTMIN+9 (Real-Time signal 9.) [Exit Status: N/A]
44. SIGRTMIN+10 (Real-Time signal 10.) [Exit Status: N/A]
45. SIGRTMIN+11 (Real-Time signal 11.) [Exit Status: N/A]
46. SIGRTMIN+12 (Real-Time signal 12.) [Exit Status: N/A]
47. SIGRTMIN+13 (Real-Time signal 13.) [Exit Status: N/A]
48. SIGRTMIN+14 (Real-Time signal 14.) [Exit Status: N/A]
49. SIGRTMIN+15 (Real-Time signal 15.) [Exit Status: N/A]
50. SIGRTMAX-14 (Real-Time signal 50.) [Exit Status: N/A]
51. SIGRTMAX-13 (Real-Time signal 51.) [Exit Status: N/A]
52. SIGRTMAX-12 (Real-Time signal 52.) [Exit Status: N/A]
53. SIGRTMAX-11 (Real-Time signal 53.) [Exit Status: N/A]
54. SIGRTMAX-10 (Real-Time signal 54.) [Exit Status: N/A]
55. SIGRTMAX-9 (Real-Time signal 55.) [Exit Status: N/A]
56. SIGRTMAX-8 (Real-Time signal 56.) [Exit Status: N/A]
57. SIGRTMAX-7 (Real-Time signal 57.) [Exit Status: N/A]
58. SIGRTMAX-6 (Real-Time signal 58.) [Exit Status: N/A]
59. SIGRTMAX-5 (Real-Time signal 59.) [Exit Status: N/A]
60. SIGRTMAX-4 (Real-Time signal 60.) [Exit Status: N/A]
61. SIGRTMAX-3 (Real-Time signal 61.) [Exit Status: N/A]
62. SIGRTMAX-2 (Real-Time signal 62.) [Exit Status: N/A]
63. SIGRTMAX-1 (Real-Time signal 63.) [Exit Status: N/A]
64. SIGRTMAX (Real-Time signal 64.) [Exit Status: N/A]
```

### dorothy

For exit statuses 200-255, these are non-conventional as such they permit our own usage, in which Dorothy has used the following:

```plain
ECUSTOM 200 Not applicable <for reason>
Used to signal the caller that the action was not performed, and might be fine because the action wasn't applicable.

ECUSTOM 210 Processing complete, exit early
```

## Capturing

Capturing exit statuses in bash is unfortunately complex, however Dorothy has made it simple and reliable, providing you are aware of the following.

### gotcha

```bash
#!/usr/bin/env bash

# our standard failure functions, these will be used by our examples
function a_function_which_failure_is_not_the_last_command {
	echo 'before faliure'
	false # emit an error to this function, as this returns a non-zero exit status
	echo 'after failure'
}
function a_function_which_failure_is_the_last_command {
	echo 'before faliure without after'
	false # emit an error to this function, as this returns a non-zero exit status
}


# select an example, either by modifying "1", or by saving this a script and using the first argument
example="${1:-"1"}"
case "$example" in
# these examples as expected
1)
	set +e # disable errors returning immediately, the default bash mode, desirable for the login shell
	a_function_which_failure_is_not_the_last_command
	# outputs:
	# before faliure
	# after failure
	;;
2)
	set -e # enable errors to return immediately, the default bash mode in dorothy enabled when we `source "$DOROTHY/sources/bash.bash"`, desirable for scripting
	a_function_which_failure_is_not_the_last_command
    # outputs:
	# before faliure
	;;

# however these don't
3)
	set -e
	a_function_which_failure_is_not_the_last_command && echo 'success'
	# outputs:
	# before faliure
	# after failure
	# success
	;;
4)
	set -e
	a_function_which_failure_is_not_the_last_command || echo 'failure'
    # outputs:
	# before faliure
	# after failure
	;;
5)
	set -e
	if a_function_which_failure_is_not_the_last_command; then
		echo 'success'
	else
		echo 'failure'
	fi
	# outputs:
	# before faliure
	# after failure
	# success
	;;

# even stranger, this one does work
6)
	set -e
	a_function_which_failure_is_the_last_command && echo 'success' || echo 'failure'
	echo 'ok'
	# outputs:
	# before faliure without after
	# failure
	# ok
	;;
esac
```

Why did the latter middle failure examples not fail? Why did the last which error is the last command of the function perform as expected?

The reason is because conditional invocation of a function disables `errexit` (aka `set -e`) for the duration of the function.

The reason the last example where the failure was the last command still failed correctly, is that with and without `errexit` enabled, a function will always return the last command's exit status, in which case as the last command of that function failed, the exit status of tha function will be the faliure exit status of the failing command.

The problem is that with errexit, conditional invocation is how we determine the exit status of a function, which unfortunately disabled errexit for the function.

```bash
#!/usr/bin/env bash

function a_function_which_failure_is_not_the_last_command {
	echo 'before faliure'
	false # emit an error to this function, as this returns a non-zero exit status
	echo 'after failure'
}
function a_function_which_failure_is_the_last_command {
	echo 'before faliure without after'
	false # emit an error to this function, as this returns a non-zero exit status
}

# without errexit
set +e
a_function_which_failure_is_not_the_last_command
echo "status=$?"
# outputs:
# before faliure
# after failure
# status=0
a_function_which_failure_is_the_last_command
echo "status=$?"
# outputs:
# before faliure without after
# status=1

# with errexit
set -e
status=0 && a_function_which_failure_is_not_the_last_command || status=$?
echo "status=$status"
# outputs:
# before faliure
# after failure
# status=0
status=0 && a_function_which_failure_is_the_last_command || status=$?
echo "status=$status"
# outputs:
# before faliure without after
# status=1
```

Official guidance from the bash community is to either abandon `errexit` and place `|| return` on every single line, or use `errexit` and implement a workaround for when invoking functions.

Dorothy has such a workaround, which is `eval_capture` and is provided to you when you `source "$DOROTHY/sources/bash.bash"` at the beginning of your command, and is used like so:

```bash
local status=0 stdout='' stderr='' output=''
eval_capture [--statusvar=status] [--stdoutvar=stdout] [--stderrvar=stderr] [--outputvar=output] [--] cmd ...
```

Which we can use in our previous example like so:

```bash
#!/usr/bin/env bash

source "$DOROTHY/sources/bash.bash"

function a_function_which_failure_is_not_the_last_command {
	echo 'before faliure'
	false # emit an error to this function, as this returns a non-zero exit status
	echo 'after failure'
}

# errexit is already enabled and eval_capture is already provided by sourcing bash.bash
status=0
eval_capture --statusvar=status a_function_which_failure_is_not_the_last_command
echo "status=$status"
# outputs:
# before failure
# status=1
```

And apply it throughout our Dorothy code like so:

```bash
# before
some_function || :

# after
eval_capture some_function
```

```bash
# before
local status
status=0 && some_function || status=$?

# after
local status
eval_capture --statusvar=status some_function
```

```bash
# before
if some_function; then
	# ...
else
	# ...
fi

# after
local status
eval_capture --statusvar=status some_function
if test "$status" -eq 0; then
	# ...
else
	# ...
fi
```

```bash
# before
local result
result="$(some_function || :)"

# after
local result
eval_capture --stdoutvar=result some_function
```

That's it, the power is yours!

For more information on this, refer to:

-   https://gist.github.com/balupton/21ded5cefc26dc20833e6ed606209e1b
-   https://github.com/bevry/dorothy/blob/master/sources/bash.bash

### a final gotcha

https://github.com/koalaman/shellcheck/wiki/SC2251
