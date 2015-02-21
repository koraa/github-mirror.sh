# Github Mirror

Github mirror is a short shell script that allows automatic
mirroring of all repos by a github user.

Experienced shell programmers might find the ls_users
subcommand and the mirror_one_repo useful for more complex
use cases.

## USAGE

   ```shell
    $ github-mirror.sh mirror [USER]...
   ```
and as a practical example, this is what I use:

   ```shell
   $ github-mirror.sh mirror koraa inexor-game premium-cola Shoctode soup
   ```

Take care to start it in the right directory, because it
always operates on relative paths. You can use braces, to
change directory in a sub shell, so the next time you see
your prompt you will still be in the same directory:

   ```shell
   $ (cd ~karo/git-infra/github-mirror/; github-mirror.sh mirror koraa inexor-game premium-cola Shoctode soup)
   ```

you should put it into your crontab file: Use `crontab -e`,
to open your crontab file, and then add your config, I am
using this:

  ```shell
  @hourly cd ~karo/git-infra/github-mirror/; ~karo/git-infra/github-mirror.git/github-mirror.sh mirror koraa inexor-game premium-cola Shoctode soup
  ```

If you need to filter the repositories you want to mirror
you can user mirror_one_repo and ls_repos to do that:

  ```shell
  $ cd ~karo/git-infra/github-mirror/
  $ github-mirror.sh ls_repos soup inexor-game karo \
      | grep "/awesome-.*"                          \
      | xargs -l1 -t github-mirror.sh mirror_one_repo
  ```

## Future directions

If someone requests it, I am going to add the possibility to
filter repos by regex.

## License

Copyright 2015 by Karolin Varner.

This is licensed under CC-0, but you can still buy me
a drink if you meet me.
