
#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "/Users/mattis/micromamba/bin/conda") {
    (& "/Users/mattis/micromamba/bin/conda" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion

