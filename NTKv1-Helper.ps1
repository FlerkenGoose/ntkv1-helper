$head = 
@"
███╗   ██╗████████╗██╗  ██╗██╗   ██╗ ██╗      ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ 
████╗  ██║╚══██╔══╝██║ ██╔╝██║   ██║███║      ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗
██╔██╗ ██║   ██║   █████╔╝ ██║   ██║╚██║█████╗███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝
██║╚██╗██║   ██║   ██╔═██╗ ╚██╗ ██╔╝ ██║╚════╝██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗
██║ ╚████║   ██║   ██║  ██╗ ╚████╔╝  ██║      ██║  ██║███████╗███████╗██║     ███████╗██║  ██║
╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝  ╚═══╝   ╚═╝      ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝
------------------------------------------------------------
Simple alpha_value & rope_freq_base calculator
Useful for LLM load tools like ooga's text-generation-webui
------------------------------------------------------------
Author  : FlerkenGoose
Version : 1.0
Github  : https://github.com/flerkengoose                   
Ko-Fi   : httpsL//ko-fi.com/flerkengoose   
                           
"@
# Function to Get Manual Alpha_value if user already know's what this should be.
function Get-AlphaInput {
    param (
        [string]$prompt
    )
    
    while ($true) {
        $input = Read-Host -Prompt $prompt
        
        # Try to convert the input to an integer
        if ([int]::TryParse($input, [ref]$null)) {
            return [int]$input
        } elseif ([double]::TryParse($input, [ref]$null)) {
            return [double]$input           
        }else {
            Write-Host "Invalid input. Please enter a valid integer."
        }
    }
}

# Function to calculate the Alpha_value based on the context multiplier
function Calculate-AlphaValue {
    <# Example usage
    $contextMultiplier = 2.5
    $value = Get-Value -contextMultiplier $contextMultiplier
    Write-Output "The value for $($contextMultiplier)x context is $value"
    #>
    param (
        [double]$contextMultiplier
    )
    $m = 1.5
    $b = -0.5
    $value = ($m * $contextMultiplier) + $b
    return $value
}

# Function to calculate the the multiplier to be used by Calculate-AlphaValue based on users Original Context and New Context values.
Function Calculate-CtxMultiplier {
    <# Example usage
    $CtxMulti = (Calculate-CtxMultiplier -OriginalContext 4096 -NewContext 6144)
    #>
    param(
        [int]$OriginalConext,
        [int]$NewContext
    )
    $x = $OriginalConext
    $y = $NewContext

    [double]$Multiplier = $y / $x
    return [double]$Multiplier
}

# Function to calculate rope_freq_base
function Calculate-RopeFreqBase {
    param (
        [double]$alpha_value
    )
    $exponent = 64 / 63
    $rope_freq_base = 10000 * [math]::Pow($alpha_value, $exponent)
    return $rope_freq_base
}


Do{
    # Write Out Header
    Write-Host $head

    # Prompt for Alpha Value
    Do{
        $prompt_alpha = Read-Host "Calculate alpha_value OR manual input [calc|man|help]"
        If ($prompt_alpha -like 'calc') {
            $ctxMulti = (Calculate-CtxMultiplier -OriginalConext $(Read-Host -Prompt "Enter LLM's original/default context value") -NewContext $(Read-Host -Prompt "Enter your desired context value"))
            $alpha_value = (Calculate-AlphaValue -contextMultiplier $ctxMulti)
        }
        elseIf ($prompt_alpha -like 'man') {
            $alpha_value = Get-AlphaInput -prompt "Enter alpha_value (manual)"
        }
        elseif ($prompt_alpha -like 'help') {
            Write-Host "Positional embeddings alpha factor for NTK RoPE scaling.`r`nSelect 'calc' to calculate based on your LLM's original/default context and your desired context`r`nSelect 'man' if you want to manually enter an alpha_value" -ForegroundColor Gray
            Read-Host "Press Any Key to continue..."
        }
        else {
            Write-Host "Please ente a valid selection, 'calc' (for calculating alpha_value) | 'man' (for manually inputting an alpha_value)" -ForegroundColor Yellow
        }
        Clear-Host
        Write-Host $head
    }
    while ($alpha_value -eq $null)

    #Display Set Alpha_value
    Write-Host "Setting Alpha_value : $alpha_value" -ForegroundColor Yellow


    # Calculate rope_freq_base value
    $rope_freq_base = Calculate-RopeFreqBase -alpha_value $alpha_value
    Write-Host "---Final Values---" -ForegroundColor Magenta
    Write-Host "alpha_value    : $alpha_value"
    Write-Host "rope_freq_base : $rope_freq_base"
    Read-Host "Press Enter to copy 'alpha_value' to clipboard..."
    Set-Clipboard $alpha_value
    Read-Host "Press Enter to copy 'rope_freq_base' to clipboard..."
    Set-Clipboard $rope_freq_base
    $exit = Read-Host "Exit [Y/n]"
    Clear-Variable alpha_value,rope_freq_base,prompt_alpha
    Clear-Host
}
while($exit -like 'n')