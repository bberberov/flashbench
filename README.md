# `flashbench` - identify characteristics of flash media

This is the tool used to identify the properties of
SD cards and other media for the Linaro flash memory
survey at \[[1]\]. The latest version should be available
at \[[2]\]. Please also check out the article on lwn.net \[[3]\].

A short introduction to the most useful commands follows.

## Guess erase block and page sizes

`flashbench -a <device>`

This is a simple read-only test doing small reads
across boundaries of various sizes. Example:

```
$ sudo ./flashbench -a /dev/mmcblk0  --blocksize=1024
align 134217728 pre 735µs       on 1.08ms       post 780µs      diff 324µs
align 67108864  pre 736µs       on 1.05ms       post 763µs      diff 300µs
align 33554432  pre 722µs       on 1.04ms       post 763µs      diff 294µs
align 16777216  pre 727µs       on 1.05ms       post 772µs      diff 302µs
align 8388608   pre 724µs       on 1.04ms       post 768µs      diff 299µs
align 4194304   pre 741µs       on 1.08ms       post 788µs      diff 317µs
align 2097152   pre 745µs       on 950µs        post 811µs      diff 171µs
align 1048576   pre 745µs       on 945µs        post 807µs      diff 169µs
align 524288    pre 743µs       on 936µs        post 799µs      diff 165µs
align 262144    pre 746µs       on 948µs        post 809µs      diff 171µs
align 131072    pre 737µs       on 935µs        post 804µs      diff 165µs
align 65536     pre 735µs       on 925µs        post 796µs      diff 159µs
align 32768     pre 735µs       on 925µs        post 800µs      diff 157µs
align 16384     pre 745µs       on 911µs        post 781µs      diff 148µs
align 8192      pre 785µs       on 808µs        post 725µs      diff 53.3µs
align 4096      pre 784µs       on 788µs        post 779µs      diff 5.85µs
align 2048      pre 787µs       on 793µs        post 789µs      diff 4.65µs
```

This shows the access times to do two 1024 byte reads around
the boundaries of power-of-two aligned blocks. Reading at
the end of a 128 MB unit takes around 735 microseconds, reading	x
the last block of this unit together with the first block of
the next one takes about 1080 microseconds and reading the first
two blocks in a 128 MB unit takes around 780 microseconds.

The most interesting number here is the last one, the difference
between the second number and the average of the first and the third
is 324 microseconds. These numbers all stay roughly the same for
all units between 4 MB and 128 MB.

However, from 2 MB down to 16 KB, the last column has a much lower
value. This indicates that whatever the memory card does on a 4 MB
boundary does not happen at other boundaries. The educated guess
here is that 4 MB is the erase block size, also called the segment
or allocation unit size. This erase blocksize will need to be
used in other tests following this one.

Similarly, both 16 KB and 8 KB boundaries are special. The logical
explanation for this is that the card has 8 KB pages, but can use
multi-plane accesses to read two 8 KB pages simultaneously.

Some cards only show a clear pattern using accesses with certain
block sizes, other cards do not show any pattern, which means
that the numbers need to be determined differently.

Also, cards that were never fully written may show a different
behaviour because access times on pre-erased segments are different
from those that have been written.

## Create a scatter plot of access times

`flashbench -s <device> --scatter-order=<n> --scatter-span=<m> -o <file>`

Writes a scatter plot into a file that can be used as input
for a `gnuplot -p -e 'plot "file"'`

## Finding the number of open erase blocks

`flashbench --open-au <device> --open-au-nr=<nr> --erasesize=<size> [--random]`

Example:

```
$ sudo ./flashbench -O --erasesize=$[4 * 1024 * 1024] \
	--blocksize=$[256 * 1024] /dev/mmcblk0  --open-au-nr=2
4MiB    8.79M/s
2MiB    7.41M/s
1MiB    6.87M/s
512KiB  6.39M/s
256KiB  6.27M/s
```

```
$ sudo ./flashbench -O --erasesize=$[4 * 1024 * 1024] \
	--blocksize=$[256 * 1024] /dev/mmcblk0  --open-au-nr=3
4MiB    7.75M/s
2MiB    5.03M/s
1MiB    3.24M/s
512KiB  1.76M/s
256KiB  912K/s
```

In this case, trying 2 open AUs shows fast accesses for small
block sizes, but trying 3 open AUs is much slower, and degrades
further at smaller sizes.

Try varying numbers until hitting the cut-off point.
For cards that are fast when using `--random`, this will find
the cut-off more reliably.

Some cards can do more open segments in linear mode than they
can in random mode.

## References

[1]: https://web.archive.org/web/20181027222214/https://wiki.linaro.org/WorkingGroups/KernelArchived/Projects/FlashCardSurvey
[2]: https://git.linaro.org/people/arnd/flashbench.git
[3]: https://lwn.net/Articles/428584/

Feel free to reach the author by email for any questions
about the latest version, Arnd Bergmann <arnd.bergmann@linaro.org>,
or use the linaro-dev@lists.linaro.org mailing list for discussions.

If you use this tool to measure memory cards, USB sticks
or SSDs and get useful results, please share them
at flashbench-results@lists.linaro.org.
