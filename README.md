[![license](https://img.shields.io/github/license/aladw/aurutils)](LICENSE)
[![aur](https://img.shields.io/aur/version/aurutils)](https://aur.archlinux.org/packages/aurutils)

## SYNOPSIS

__aurutils__ is a collection of scripts to automate usage of the [Arch
User Repository](https://wiki.archlinux.org/index.php/Arch_User_Repository), 
with different tasks such as package searching, update checks, or computing 
dependencies kept separate.

The chosen approach for managing packages is local pacman
repositories, rather than foreign (installed by `pacman -U`)
packages.
  
## INSTALLATION

Install one of the following packages:

* [`aurutils`](https://aur.archlinux.org/packages/aurutils) for the
release version _(recommended)_.
* [`aurutils-git`](https://aur.archlinux.org/packages/aurutils-git)
for the master branch.

Upgrade notices are posted to the 
[Arch forums](https://bbs.archlinux.org/viewtopic.php?id=210621).
[(RSS)](https://bbs.archlinux.org/extern.php?action=feed&tid=210621&type=atom)

## USAGE

Documentation is included as [man pages](https://wiki.archlinux.org/title/Man_page)
with groff typesetting. They provide a general overview of the various utilities
with several examples.
Detailed instructions on how to set up a local repository can be found in the
section `CREATING A LOCAL REPOSITORY` of the [`aur(1)`](man1/aur.1) man page.

## TROUBLESHOOTING

See [ISSUE_TEMPLATE.md](ISSUE_TEMPLATE.md). For informal discussion, see the
`#aurutils` channel on [Libera Chat](https://libera.chat/).
  
