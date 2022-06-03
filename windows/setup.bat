rem neovim
mklink /D %HOMEPATH%\AppData\Local\nvim %HOMEPATH%\dotfiles\.config\nvim

rem cdb
setx _NT_SYMBOL_PATH "cache*c:\Symbols;srv*https://msdl.microsoft.com/download/symbols"
mkdir c:\Symbols

rem vcvarsall.bat
