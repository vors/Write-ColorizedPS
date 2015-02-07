function Get-TokensFromInput
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string] $inputString
    )

    $tokens = $null
    $errors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($inputString, [ref]$tokens, [ref]$errors)

    return $tokens
}

function Get-TokenColor
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [System.Management.Automation.Language.Token] $token
    )

    switch -wildcard ("$($token.Kind)")
    {
        "Comment" {
            return [ConsoleColor]::Yellow
        }

        "Parameter" {
            return [ConsoleColor]::DarkGray
        }

        "*Variable" {
            return [ConsoleColor]::Green
        }

        "*String*" {
            return [ConsoleColor]::DarkCyan
        }

        "Number" {
            return [ConsoleColor]::Magenta
        }
    }
    if ($token.TokenFlags -band [System.Management.Automation.Language.TokenFlags]::CommandName)
    {
        return [ConsoleColor]::Yellow
    }

    if ($token.TokenFlags -band [System.Management.Automation.Language.TokenFlags]::Keyword)
    {
        return [ConsoleColor]::Green
    }

    if ($token.TokenFlags -band (
            [System.Management.Automation.Language.TokenFlags]::BinaryOperator -bor
            [System.Management.Automation.Language.TokenFlags]::UnaryOperator -bor
            [System.Management.Automation.Language.TokenFlags]::AssignmentOperator
        ))
    {
        return [ConsoleColor]::DarkGray
    }

    if ($token.TokenFlags -band [System.Management.Automation.Language.TokenFlags]::TypeName)
    {
        return [ConsoleColor]::Gray
    }

    if ($token.TokenFlags -band [System.Management.Automation.Language.TokenFlags]::MemberName)
    {
        return [ConsoleColor]::Magenta
    }    

    return [ConsoleColor]::White
}

function Write-ColorizedPS
{
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [string] $inputString
    )

    $tokens = Get-TokensFromInput $inputString
    $lastColumn = 0
    $tokens | % {
        $skipCount = $_.Extent.StartColumnNumber - $lastColumn
        for ($i=0; $i -lt $skipCount; $i++) {
            Write-Host ' ' -NoNewline
        }
        Write-Host -NoNewline $_.Text -ForegroundColor (Get-TokenColor $_)
        $lastColumn = $_.Extent.EndColumnNumber
    }   
}

Export-ModuleMember -Function Write-ColorizedPS
