# OverTheWire — Bandit (Levels 0 → 12)

Walkthrough of the [OverTheWire **Bandit**](https://overthewire.org/wargames/bandit/) wargame —
Linux command-line fundamentals for security work. Solved on an Ubuntu VM over
`ssh bandit.labs.overthewire.org -p 2220`.

> Passwords in the screenshots may be stale — OverTheWire rotates them. This documents the *method*.

| Level | Concept | Key command |
|-------|---------|-------------|
| 0 → 1 | SSH login | `ssh bandit0@bandit.labs.overthewire.org -p 2220` |
| 1 → 2 | File named `-` | `cat ./-` |
| 2 → 3 | Spaces in filename | `cat -- "--spaces in this filename--"` |
| 3 → 4 | Hidden file | `ls -a` → `cat ...Hiding-From-You` |
| 4 → 5 | Human-readable file | `find . -type f \| xargs file` |
| 5 → 6 | Find by size | `find . -size 1033c ! -executable` |
| 6 → 7 | Find by owner/group | `find / -user bandit7 -group bandit6 -size 33c` |
| 7 → 8 | Text next to a word | `grep millionth data.txt` |
| 8 → 9 | Only unique line | `sort data.txt \| uniq -u` |
| 9 → 10 | Human-readable strings | `strings data.txt \| grep =` |
| 10 → 11 | Base64 | `base64 -d data.txt` |
| 11 → 12 | ROT13 | `cat data.txt \| tr 'A-Za-z' 'N-ZA-Mn-za-m'` |
| 12 → 13 | Repeated compression | `xxd -r`, then `gzip`/`bzip2`/`tar` in a loop |

---

### Level 0 → 1
Log in as `bandit0`; the welcome banner prints the password.

![Level 0 → 1](screenshots/level%200-1%20%28a%29.png)

### Level 1 → 2
`cat -` reads stdin, so prefix the path: `cat ./-`.

![Level 1 → 2](screenshots/level%201-2%20%28a%29.png)

### Level 2 → 3
Quote the awkward filename and end options with `--`.

![Level 2 → 3](screenshots/level%202-3%20%28a%29.png)

### Level 3 → 4
`ls -a` reveals the dotfile inside `inhere`.

![Level 3 → 4](screenshots/level%203-4%20%28a%29.png)

### Level 4 → 5
Only one `-fileNN` is ASCII text — find it with `file`.

![Level 4 → 5](screenshots/level%204-5%20%28a%29.png)

### Level 5 → 6
Find the file that's 1033 bytes and not executable.

![Level 5 → 6](screenshots/level%205-6%20%28a%29.png)

### Level 6 → 7
Search the whole filesystem by owner, group, and size.

![search](screenshots/level%206-7%20%28a%29.png)
![result](screenshots/level%206-7%20%28b%29.png)
![password](screenshots/level%206-7%20%28c%29.png)

### Level 7 → 8
Grep for the line next to `millionth`.

![Level 7 → 8](screenshots/level%207-8%20%28a%29.png)

### Level 8 → 9
The password is the only line that appears once.

![cat](screenshots/level%208-9%20%28a%29.png)
![sort](screenshots/level%208-9%20%28b%29.png)
![uniq -c](screenshots/level%208-9%20%28c%29.png)
![unique line](screenshots/level%208-9%20%28d%29.png)

### Level 9 → 10
Extract printable strings; the password follows several `=`.

![cat](screenshots/level%209-10%20%28a%29.png)
![strings](screenshots/level%209-10%20%28b%29.png)

### Level 10 → 11
Decode the base64 blob.

![Level 10 → 11](screenshots/level%2010-11%20%28a%29.png)

### Level 11 → 12
Undo ROT13 (here via CyberChef).

![cat](screenshots/level%2011-12%20%28a%29.png)
![ROT13](screenshots/level%2011-12%20%28b%29.png)

### Level 12 → 13
Reverse the hexdump with `xxd -r`, then peel each compression layer (gzip → bzip2 → tar → …)
until `file` reports ASCII text.

![hexdump](screenshots/level%2012-13%20%28a%29.png)
![decompress 1](screenshots/level%2012-13%20%28b%29.png)
![decompress 2](screenshots/level%2012-13%20%28c%29.png)
![password](screenshots/level%2012-13%20%28d%29.png)
