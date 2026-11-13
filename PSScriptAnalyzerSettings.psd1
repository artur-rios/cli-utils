# PSScriptAnalyzer's settings for ci/lint.sh (the `lint` check): every default rule, except those below. Each one
# flags code that works as intended, and following it would change what the scripts do, so it is left off rather
# than "fixed":
#   PSAvoidUsingWriteHost                       the tools print progress for a person at a terminal, on purpose
#   PSAvoidUsingEmptyCatchBlock                 best-effort cleanup (temporary folders, jobs) that must not fail
#   PSUseShouldProcessForStateChangingFunctions New-TempPath only builds a path; -WhatIf/-Confirm would mean nothing
#   PSUseUsingScopeModifierInNewRunspaces       test-ktype passes the path to Start-Job with -ArgumentList already
@{
    ExcludeRules = @(
        'PSAvoidUsingWriteHost',
        'PSAvoidUsingEmptyCatchBlock',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseUsingScopeModifierInNewRunspaces'
    )
}
