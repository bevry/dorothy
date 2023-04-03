# What to do if Dorothy is not loading

Installed Dorothy, opened a new terminal, but none of the Dorothy commands are available?

It could be that your terminal application is refusing to operate your shell as a login shell, which is how Dorothy (and many other applications) identify whether they should complete loading themselves. If Dorothy were to load itself on non-login shells then every bash command would also have to load Dorothy, yikes! By having Dorothy only load inside login shells, then we allow everything to work perfectly.

So what to do when your terminal isn't opening a login shell?

## Ubuntu

In the top menu bar, tap the terminal application title, and open preferences:

<img width="265" alt="CleanShot 2022-04-12 at 08 45 50@2x" src="https://user-images.githubusercontent.com/61148/162856280-afcc2668-791b-4891-b8dc-43a8aad1a7d5.png">

Navigate to the active profile, select command, and ensure that login shell is enabled:

<img width="836" alt="CleanShot 2022-04-12 at 08 46 56@2x" src="https://user-images.githubusercontent.com/61148/162856319-990705fc-1165-4774-8a48-a4325dd1381e.png">

Close the preferences and open a new terminal tab, now Dorothy should be loaded which you can verify by running `dorothy theme` to select a theme.
