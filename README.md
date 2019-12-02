# Scripts
Windows and Unix Batch/PS/Shell Scripting


### [Git wrapper](https://github.com/maxwroc/WinScripts/blob/master/batch/git-wrapper.bat)
Features:
* Extends git branch listings with numbers, allowing you to chose branch without need of typing the full name. 
* Shows current branch, highlighted in green, on the beginning of the command prompt.
* Prevents from unintentional branch creating based on current one (asks for confirmation)

#### How to install?
To initialize you just need to call wrapper with an "/init" param:

`git-wrapper /init`

It is convenient to create a shortcut to CMD.EXE with the following command:

`cmd.exe /k "[path_to_the_file]\git-wrapper.bat /init"`

**Note:** Once applied it replaces the "git" command (you can still use all git commands as before). It works like an extension for the regular git.exe. If you need you can always use Git binary directly by typing git.exe

**Note:** Colors work only on Windows 10

![git wrapper](https://github.com/maxwroc/WinScripts/blob/master/batch/git-wrapper.png)
