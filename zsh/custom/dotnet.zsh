# .NET. Homebrew's formula puts `dotnet` on PATH itself, so on macOS only the
# global-tool directory needs adding. The Linux install is user-local under
# ~/.dotnet (see install/packages-linux.sh) because Ubuntu's feed stops at 8.0
# and Microsoft's conflicts with it — so add the SDK root there too, and set
# DOTNET_ROOT so global tools can find the runtime that shipped with it.
if [ -x "$HOME/.dotnet/dotnet" ]; then
  export DOTNET_ROOT="$HOME/.dotnet"
  export PATH="$HOME/.dotnet:$PATH"
fi

# Global tools (`dotnet tool install -g`, e.g. pwsh) land here on both.
[ -d "$HOME/.dotnet/tools" ] && export PATH="$PATH:$HOME/.dotnet/tools"
