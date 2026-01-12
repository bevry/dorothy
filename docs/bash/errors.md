# Errors

## Naming and Numbering

In Bash, functions can return a number, commands can exit with a number, and processes can receive numbers.
These numbers represent an exit status, also known as exit codes, return codes, error codes, etc.
When scripting, an exit status of 0 is considered a success, in which execution will continue, and a non-zero exit status is considered a failure which will cause execution to stop unless manually discarded.

When returning any non-zero exit status, you should attempt to use a meaningful exit status, and note it's meaning like so:

```bash
return 2 # ENOENT 2 No such file or directory
```

To select an exit status, refer to the following sources:

### Dorothy

Dorothy commonly uses the following, sometimes with additional utility. Exit statuses 200-255 are non-conventional as such they permit our own usage:

```plain
EPERM 1 Operation not permitted
Includes usage of invalid conditions for the action.

ENOENT 2 No such file or directory

ESRCH 3 No such process
Includes usage for missing required dependency.

ENXIO 6 Device not configured
Includes usage for missing required dependency.

ENOEXEC 8 Exec format error
Includes usage for malfunctioning required dependency.

EBADF 9 Bad file descriptor
Includes usage for broken symlinks.

EACCES 13 Permission denied
Includes usage of access denied, where elevated access would resolve the issue.

EFAULT 14 Bad address
Includes usage for unknown/unexpected logic path.

EEXIST 17 File exists
Includes usage for when a path (file, directory, symlink) exists.
Includes usage for when a non-empty file was sought, but an empty file was found.

ENODEV 19 Operation not supported by device
Includes usage for missing required dependency.

NOTDIR 20 Not a directory

EISDIR 21 Is a directory

EINVAL 22 Invalid argument
Includes usage for help messages.

EFBIG 27 File too large
Includes usage for when a file is not empty.

ESPIPE 29 Illegal seek
Includes usage for unknown/unexpected logic path.

EDOM 33 Numerical argument out of domain
Includes usage for: index out of range, length out of range, needle not found, value not found, subset not found within superset, etc.

ENOPROTOOPT 42 Protocol not available
Includes usage for missing required dependency.

EPROTONOSUPPORT 43 Protocol not supported
Includes usage for a dependency not supporting a specific action.

ENOTSUP 45 Operation not supported

EPFNOSUPPORT 46 Protocol family not supported
Includes usage for system incompatibility.

ETIMEDOUT 60 Operation timed out

ENOTEMPTY 66 Directory not empty

EPROGUNAVAIL 74 RPC prog. not avail
Includes usage for missing required dependency.

EPROGMISMATCH 75 Program version wrong
Includes usage for when a dependency is installed with an unsupported configuration.

EPROCUNAVAIL 76 Bad procedure for program
Includes usage for unknown/unexpected logic path.

NOSYS 78 Function not implemented
Includes usage for unimplemented actions.

EFTYPE 79 Inappropriate file type or format
Includes usage for when a path is not of the sought format, such as wanting an empty file but found a directory.

ENOMSG 91 No message of desired type

ENOATTR 93 Attribute not found
Includes usage when a <path> is missing a required attribute, such as missing readable/writable/executable permissions when that specific attribute is sought.

EADDRINUSE 98 Address already in use
Incudes usage when trying to use an already existing path.

ENOTRECOVERABLE 104 State not recoverable
Includes usage for unknown/unexpected logic path.

ECANCELED 125 Operation cancelled

ECUSTOM 200 Not applicable <for reason>
Used to signal to the caller that the action was not performed, and might be fine because the action wasn't applicable, such as:
- Doing an operation on a utility, that is unnecessary, as the utility is already in the desired state.
- Doing an operation on a path, such a mount path, that is already in the desired state.

ECUSTOM 210 Processing complete, exit early

ECUSTOM 220 Expectation mismatch
ECUSTOM 221 Tests failed
ECUSTOM 222 Tests malformed
ECUSTOM 223 Tests broken
```

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

## Invocation and Capturing

In Bash, any invocation of a function within a conditional (`!`, `if`, `&&`, `||`) will invoke the function with `errexit` (aka `set -e`) disabled, which ignores non-zero exit statuses, which are used to indicate an error. This ignore error on conditional behaviour of bash unfortunately cannot be disabled; it is a legacy decision from bash's prior primary use as a login shell rather than as a scripting language.

We can see this in action via the following:

```bash
#!/usr/bin/env bash
function a_custom_failure {
    return 99
}
function a_function_which_failure_IS_NOT_the_last_command {
	printf '%s' 'before'
	a_custom_failure # this emits an error as its invocation results in an unhandled non-zero exit status
	printf '%s\n' ' and after failure' # the exit status that will be returned without errexit will be that of this last line
}
```

```bash
# Disable `errexit`, where non-zero exit statuses are ignored, desirable for login shells where a failed command does not crash the shell
set +e
a_function_which_failure_IS_NOT_the_last_command
# outputs:
# before and after failure
# exit status: 0
```

```bash
# Enable `errexit`, where unhandled non-zero statuses are thrown, desirable for scripting, and the behaviour once `bash.bash` is sourced.
set -e
a_function_which_failure_IS_NOT_the_last_command
# outputs:
# before
# crash exit status: 99
```

We can see the unexpected behaviour of conditional errexit disablement in action via the following examples:

```bash
set -e
a_function_which_failure_IS_NOT_the_last_command || :
# outputs:
# before and after failure

set -e
status=0
a_function_which_failure_IS_NOT_the_last_command || status=$?
printf '%s\n' "status=$status"
# outputs:
# before and after failure
# status=0

set -e
( a_function_which_failure_IS_NOT_the_last_command && printf '%s\n' 'invocation success' ) || printf '%s\n' "invocation failure: $?"
# outputs:
# before and after failure
# invocation success

set -e
a_function_which_failure_IS_NOT_the_last_command && printf '%s\n' 'invocation success'
# outputs:
# before and after failure
# invocation success

set -e
if a_function_which_failure_IS_NOT_the_last_command; then
	printf '%s\n' 'invocation success'
else
	printf '%s\n' 'invocation failure'
fi
# outputs:
# before and after failure
# invocation success

# and this:
set -e
if ! a_function_which_failure_IS_NOT_the_last_command; then
	printf '%s\n' 'invocation failure'
else
	printf '%s\n' 'invocation success'
fi
```

This problem also manifests in an inability to capture the correct exit status for such unsafe functions:

```bash
set -e
status=0 && a_function_which_failure_IS_NOT_the_last_command || status=$?
printf '%s\n' "status=$status"
# outputs:
# before and after failure
# status=0

set -e
status=0
stdout="$(a_function_which_failure_IS_NOT_the_last_command)" || status=$?
printf '%s\n' "stdout=[$stdout] status=$status"
# outputs:
# stdout=[before and after failure]
# status=0

set -e
status=0
stdout_line_1=''
IFS= read -r stdout_line_1 <<<"$(a_function_which_failure_IS_NOT_the_last_command)" || status=$?
printf '%s\n' "stdout=[$stdout_line_1] status=$status"
# outputs:
# stdout=[before and after failure]
# status=0

# this one deviates a little, as the process substitution is created before and within an earlier context than that of the conditional
# however, as we can see, the status now reflects the read failure, rather than the failure of the process substitution
set -e
status=0
stdout_line_1=''
IFS= read -r stdout_line_1 < <(a_function_which_failure_IS_NOT_the_last_command) || status=$?
printf '%s\n' "stdout=[$stdout_line_1] status=$status"
# outputs:
# stdout=[before]
# status=1

# this one supports reading multiple lines correctly, however the `while read || [[ -n $REPLY ]]` combination prevents even the read error from being captured
set -e
status=0
stdout=''
is_trailing='no'
while IFS= read -r || { is_trailing='yes' && [[ -n $REPLY ]]; }; do
    stdout+="$REPLY"
    if [[ $is_trailing == 'no' ]]; then
        stdout+=$'\n'
    fi
done < <(a_function_which_failure_IS_NOT_the_last_command) || status=$?
printf '%s\n' "stdout=[$stdout] status=$status"
# outputs:
# stdout=[before]
# status=0
```

This all happens because the conditional invocation of `a_function_which_failure_IS_NOT_the_last_command` prevents its invocation of `a_custom_failure` from emitting an unhandled non-zero exit status error, which causes it to continue as if it was successful, which makes it appear as it was successful because its last line `printf '%s\n' ' and after failure'` is successful.

To make our function safe for conditionals, we must ensure every and any line that could throw, including print statements that can throw if the destined file descriptor is closed (e.g. `>&-`), must be trailed by `|| return`. We can denote such safe for conditional functions, by a Dorothy convention of a double underscore prefix `__`. For our function, its safety function equivalent would be like so:

```bash
function __a_function_which_failure_IS_NOT_the_last_command {
	printf '%s' 'before' || return $?
	a_custom_failure || return $?
	printf '%s\n' 'and after failure' || return $?
}

set -e
status=0
stdout="$(__a_function_which_failure_IS_NOT_the_last_command)" || status=$?
printf '%s\n' "stdout=[$stdout] status=$status"
# outputs:
# stdout=[before] status=99
```

However, for any significant program, this becomes untenable, and it still prevents us from easily capturing the exit status while combining it with `read`, unless we do a variation:

```bash
function a_custom_failure {
    return 99
}
function get_csv_data {
	printf '%s' 'one,two,three'
	a_custom_failure
	printf '%s\n' 'four,five,six'
}
function __get_csv_data {
	printf '%s' 'one,two,three' || return $?
	a_custom_failure || return $?
	printf '%s\n' 'four,five,six' || return $?
}

# the failure in `get_csv_data` causes the read to fail, which causes an exit status of 1
set -e
status=0
IFS=, read -r i1 i2 i3 i4 i5 i6 < <(get_csv_data) || status=$?
printf '%s\n' "i1=[$i1] i2=[$i2] i3=[$i3] i4=[$i4] i5=[$i5] i6=[$i6] status=$status"
# outputs:
# i1=[one] i2=[two] i3=[three] i4=[] i5=[] i6=[] status=1
set -e
status=0
IFS=, read -r i1 i2 i3 i4 i5 i6 < <(__get_csv_data) || status=$?
printf '%s\n' "i1=[$i1] i2=[$i2] i3=[$i3] i4=[$i4] i5=[$i5] i6=[$i6] status=$status"
# outputs:
# i1=[one] i2=[two] i3=[three] i4=[] i5=[] i6=[] status=1

# the failure in `get_csv_data` is completely discarded, and the conditional has no effect on the behaviour
set -e
status=0
IFS=, read -r i1 i2 i3 i4 i5 i6 <<<"$(get_csv_data)" || status=$?
printf '%s\n' "i1=[$i1] i2=[$i2] i3=[$i3] i4=[$i4] i5=[$i5] i6=[$i6] status=$status"
# outputs:
# i1=[one] i2=[two] i3=[three] i4=[] i5=[] i6=[] status=0
set -e
status=0
IFS=, read -r i1 i2 i3 i4 i5 i6 <<<"$(__get_csv_data)" || status=$?
printf '%s\n' "i1=[$i1] i2=[$i2] i3=[$i3] i4=[$i4] i5=[$i5] i6=[$i6] status=$status"
# outputs:
# i1=[one] i2=[two] i3=[three] i4=[] i5=[] i6=[] status=0

# the failure in `get_csv_data` is disabled causing unexpected outputs, which causes the exit status to correct but unexpected
set -e
get_status=0
read_status=0
fodder_to_respect_exit_status="$(get_csv_data)" || get_status=$?
IFS=, read -r i1 i2 i3 i4 i5 i6 <<<"$fodder_to_respect_exit_status" || read_status=$?
printf '%s\n' "i1=[$i1] i2=[$i2] i3=[$i3] i4=[$i4] i5=[$i5] i6=[$i6] get_status=$get_status read_status=$read_status"
# outputs:
# i1=[one] i2=[two] i3=[threefour] i4=[five] i5=[six] i6=[] get_status=0 read_status=0
```

This variation works, only because it is a safety function:

```bash
# the failure in `__get_csv_data` is respected, and the exit status is captured correctly
set -e
get_status=0
read_status=0
fodder_to_respect_exit_status="$(__get_csv_data)" || get_status=$?
IFS=, read -r i1 i2 i3 i4 i5 i6 <<<"$fodder_to_respect_exit_status" || read_status=$?
printf '%s\n' "i1=[$i1] i2=[$i2] i3=[$i3] i4=[$i4] i5=[$i5] i6=[$i6] get_status=$get_status read_status=$read_status"
# outputs:
# i1=[one] i2=[two] i3=[three] i4=[] i5=[] i6=[] get_status=99 read_status=0
```

Fortunately, Dorothy's `bash.bash` enables `errexit` such that unhandled errors are thrown, and provides `__try` and `__do` to capture and handle the exit status of conditionals and substitutions, without altering their execution behaviour.

```bash
source "$DOROTHY/sources/bash.bash"

function a_custom_failure {
    return 99
}
function get_csv_data {
	printf '%s' 'one,two,three'
	a_custom_failure
	printf '%s\n' 'four,five,six'
}

__try {status} -- get_csv_data
printf '\n%s\n' "status=$status"
# outputs:
# one,two,three
# status=99

__do --redirect-status={status} -- get_csv_data
printf '\n%s\n' "status=$status"
# outputs:
# one,two,three
# status=99

__do --redirect-status={status} --redirect-stdout={stdout} -- get_csv_data
printf '%s\n' "stdout=[$stdout] status=$status"
# outputs:
# stdout=[one,two,three] status=99

# which we can read like so:
__do --redirect-status={get_status} --redirect-stdout={stdout} -- get_csv_data
read_status=0
IFS=, read -r i1 i2 i3 i4 i5 i6 <<<"$stdout" || read_status=$?
printf '%s\n' "i1=[$i1] i2=[$i2] i3=[$i3] i4=[$i4] i5=[$i5] i6=[$i6] get_status=$get_status read_status=$read_status"
# outputs:
# i1=[one] i2=[two] i3=[three] i4=[] i5=[] i6=[] get_status=99 read_status=0

# or read into an array (supporting all bash versions) like so:
__do --redirect-status={get_status} --redirect-stdout={stdout} -- get_csv_data
split_status=0
__split --target={arr} --delimiter=',' --stdin < <(__print_string "$stdout") || split_status=$?
echo-verbose -- "${arr[@]}"
printf '%s\n' "get_status=$get_status split_status=$split_status"
# outputs:
# [0] = [one]
# [1] = [two]
# [2] = [three]
# get_status=99 split_status=0

# here is an alternative that uses semaphores
split_status=0
semaphore_status_file="$(__get_semaphore)"
__split --target={arr} --delimiter=',' --stdin < <(__do --redirect-status="$semaphore_status_file" -- get_csv_data) || split_status=$?
__wait_for_semaphores "$semaphore_status_file"
echo-verbose -- "${arr[@]}"
printf '%s\n' "get_status=$(<"$semaphore_status_file") split_status=$split_status"
# outputs:
# [0] = [one]
# [1] = [two]
# [2] = [three]
# get_status=99 split_status=0
```

If you just want to throw a failure when splitting, you can do these:

```bash
# discards any trailing newline
fodder_to_respect_exit_status="$(get_csv_data)"
__split --source={fodder_to_respect_exit_status} --target={arr} --delimiter=','
echo-verbose -- "${arr[@]}"

# preserves trailing newline
__do --redirect-stdout={fodder_to_respect_exit_status} -- get_csv_data
__split --source={fodder_to_respect_exit_status} --target={arr} --delimiter=','
echo-verbose -- "${arr[@]}"

# recommended shorthand that preserves the trailing newline
__split --target={arr} --delimiter=',' --invoke -- get_csv_data
echo-verbose -- "${arr[@]}"
```

Note that these below variations do not work:

```bash
# this one is incorrect, as the exit status is discarded, as the command substitution is not just for the value of an assignment
__split --target={arr} --delimiter=',' -- "$(get_csv_data)"
echo-verbose -- "${arr[@]}"
# [0] = [one]
# [1] = [two]
# [2] = [three]

# this one is also incorrect, as the conditional disables the failure
get_and_split_status=0
__split --target={arr} --delimiter=',' -- "$(get_csv_data)" || get_and_split_status=$?
echo-verbose -- "${arr[@]}"
printf '%s\n' "get_and_split_status=$get_and_split_status"
# [0] = [one]
# [1] = [two]
# [2] = [threefour]
# [3] = [five]
# [4] = [six]
# get_and_split_status=0

# these failures seem to indicate that "$(...)" interpolation only reflects its exit status if it is solely being used as a value in a variable assignment, but if it is being used in a statement, then the exit status is discarded and the resulting exit status is that of the statement itself, which will be 0 unless the statement itself fails
```

In summary, here are various before and after examples:

```bash
#!/usr/bin/env bash
source "$DOROTHY/sources/bash.bash"

# capturing exit status
# BEFORE, ACCIDENTALLY DISABLES ERREXIT:
status=0 && any_command_or_function_including_unsafe_functions || status=$?
# AFTER, IF FUNCTION IS SAFE:
status=0 && __only_safe_functions || status=$?
# AFTER, FOR ALL FUNCTIONS USING TRY:
__try {status} -- any_command_or_function_including_unsafe_functions
# AFTER, FOR ALL FUNCTIONS USING DO:
__do --redirect-status={status} -- any_command_or_function_including_unsafe_functions

# ignoring exit status
# BEFORE, ACCIDENTALLY DISABLES ERREXIT:
any_command_or_function_including_unsafe_functions || :
# AFTER, IF FUNCTION IS SAFE:
__only_safe_functions || :
# AFTER, FOR ALL FUNCTIONS USING TRY:
__try -- any_command_or_function_including_unsafe_functions
# AFTER, FOR ALL FUNCTIONS USING DO:
__do --discard-status -- any_command_or_function_including_unsafe_functions

# acting upon success or failure
# BEFORE, ACCIDENTALLY DISABLES ERREXIT:
if any_command_or_function_including_unsafe_functions; then
	# ...
else
	# ...
fi
# AFTER, IF FUNCTION IS SAFE:
if __only_safe_functions; then
	# ...
else
	# ...
fi
# AFTER, FOR ALL FUNCTIONS USING TRY:
__try {status} -- any_command_or_function_including_unsafe_functions
if [[ "$status" -eq 0 ]]; then
	# ...
else
	# ...
fi
# AFTER, FOR ALL FUNCTIONS USING DO:
__do --redirect-status={status} -- any_command_or_function_including_unsafe_functions
if [[ "$status" -eq 0 ]]; then
	# ...
else
	# ...
fi

# negating exit status
# BEFORE, ACCIDENTALLY DISABLES ERREXIT:
! any_command_or_function_including_unsafe_functions
# AFTER, IF FUNCTION IS SAFE:
! __only_safe_functions
# AFTER, FOR ALL FUNCTIONS:
__try {status} -- any_command_or_function_including_unsafe_functions
[[ "$status" -ne 0 ]]

# discard exit status inside interpolation
# BEFORE, ACCIDENTALLY DISABLES ERREXIT:
result="$(any_command_or_function_including_unsafe_functions || :)"
# BEFORE, ACCIDENTALLY DISABLES ERREXIT AND DISCARDS VARIABLE ASSIGNMENT ERRORS TOO:
result="$(any_command_or_function_including_unsafe_functions)" || :
# AFTER, IF FUNCTION IS SAFE:
result="$(__only_safe_functions || :)"
# AFTER, FOR ALL FUNCTIONS:
__do --discard-status --redirect-stdout={result} -- any_command_or_function_including_unsafe_functions

# assigning to an array
# BEFORE, DISCARDS THE FORMER EXIT STATUS:
arr=()
arr=("$(echo a; exit 9;)" "$(echo b;)") || echo "$?" # outputs nothing as the failure was undetected
echo "$? ${PIPESTATUS[@]}" # outputs: 0 0
echo-verbose -- "${arr[@]}"
# outputs:
# 0 0
# [0] = [a]
# [1] = [b]
# AFTER, ENSURES EXIT STATUS IS RESPECTED:
arr=()
arr+=("$(echo a; exit 9;)") || echo "$?" # outputs: 9
arr+=("$(echo b;)") || echo "$?" # outputs nothing as there was no failure
echo-verbose -- "${arr[@]}"
# outputs:
# 9
# [0] = [a]
# [1] = [b]
# AFTER, ENSURES EXIT STATUS IS RESPECTED:
a=("$(echo a; exit 9;)") || echo "$?" # outputs: 9
b=("$(echo b;)") || echo "$?" # outputs nothing as there was no failure
arr=("$a" "$b") || echo "$?" # outputs nothing as there was no failure
echo-verbose -- "${arr[@]}"
# outputs:
# 9
# [0] = [a]
# [1] = [b]

# forward the output of one command to another, respecting exit status
# BEFORE, DISCARDS EXIT STATUS:
cat < <(any_command_or_function_including_unsafe_functions) # discards exit status
# AFTER, RESPECTS EXIT STATUS:
any_command_or_function_including_unsafe_functions | cat # respects exit status

# forward the output of one command to another, respecting exit status and side effects
# BEFORE, RESPECTS SIDE EFFECTS BUT DISCARDS EXIT STATUS:
side_effect=no
{ side_effect=yes; cat; } < <(any_command_or_function_including_unsafe_functions) # discards exit status
echo "side_effect=$side_effect" # outputs: side_effect=yes
# BEFORE, RESPECTS EXIT STATUS BUT DISCARDS SIDE EFFECTS:
side_effect=no
any_command_or_function_including_unsafe_functions | { side_effect=yes; cat; }  # respects exit status, but discards side effects
echo "side_effect=$side_effect"  # outputs: side_effect=no
# AFTER, ENSURES TRAILING NEWLINE:
side_effect=no
fodder_to_respect_exit_status="$(any_command_or_function_including_unsafe_functions)"
{ side_effect=yes; cat; } <<<"$fodder_to_respect_exit_status"
echo "side_effect=$side_effect" # outputs: side_effect=yes
# AFTER, PRESERVES TRAIL:
side_effect=no
__do --redirect-stdout={fodder_to_respect_exit_status} -- any_command_or_function_including_unsafe_functions
{ side_effect=yes; cat; } < <(__print_string "$fodder_to_respect_exit_status") # outputs: side_effect=yes

# split on a delimiter
# BEFORE, DISCARDS EXIT STATUS:
__split --target={arr} --delimiter=',' -- "$(any_command_or_function_including_unsafe_functions)"
# AFTER, DISCARDS TRAILING NEWLINES:
fodder_to_respect_exit_status="$(any_command_or_function_including_unsafe_functions)"
__split --source={fodder_to_respect_exit_status} --target={arr} --delimiter=','
# AFTER, ENSURES TRAILING NEWLINES:
fodder_to_respect_exit_status="$(any_command_or_function_including_unsafe_functions)"
__split --target={arr} --delimiter=',' --stdin <<<"$fodder_to_respect_exit_status"
# AFTER, PRESERVES TRAIL:
__do --redirect-stdout={fodder_to_respect_exit_status} -- any_command_or_function_including_unsafe_functions
__split --source={fodder_to_respect_exit_status} --target={arr} --delimiter=','"
```

You can find the implementation of `__do` and `__try` inside Dorothy's [`bash.bash`](https://github.com/bevry/dorothy/blob/master/sources/bash.bash), and find their tests within the [`dorothy-internals` command](https://github.com/bevry/dorothy/blob/master/commands/dorothy-internals).
