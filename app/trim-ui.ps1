Add-Type -AssemblyName System.Windows.Forms

function ToggleUIState {
    $box.SuspendLayout()

    foreach ($key in $ui.Keys) {
        if ($key -notmatch '^(label|colon|group)') {
            $ui[$key].Enabled = -not $ui[$key].Enabled
        }
    }

    $box.Cursor = if ($box.Cursor -eq [System.Windows.Forms.Cursors]::WaitCursor) {
        [System.Windows.Forms.Cursors]::Default
    } else {
        [System.Windows.Forms.Cursors]::WaitCursor
    }

    $box.ResumeLayout($true)
    $box.Refresh()
}

$Env:Path = "$Env:LOCALAPPDATA\ffmpeg-trim-wrapper;" + $Env:Path
$inputPath = $args[0]

$box = New-Object System.Windows.Forms.Form -Property @{
    Text            = "Trim"
    Font            = New-Object System.Drawing.Font("Microsoft Sans Serif", 10)
    ClientSize      = New-Object System.Drawing.Size(246,228)
    ShowInTaskBar   = $false
    HelpButton      = $true
    MinimizeBox     = $false
    MaximizeBox     = $false
    TopMost         = $true
    StartPosition   = "CenterScreen"
    FormBorderStyle = "FixedDialog"
}

$box.Add_HelpButtonClicked({
    [System.Windows.Forms.MessageBox]::Show(
        "Enter start and stop time in HH:MM:SS format",
        "Help",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    )
})

# Control metadata definitions
$controls = @{
    labelA  = @{ Type = "Label"; Text = "Start"; Location = @{ X = 20; Y = 22 }; Width = 36 }
    labelB  = @{ Type = "Label"; Text = "Stop"; Location = @{ X = 20; Y = 57 }; Width = 36 }
    colonA  = @{ Type = "Label"; Text = ":"; Location = @{ X = 114; Y = 22 }; AutoSize = $true }
    colonB  = @{ Type = "Label"; Text = ":"; Location = @{ X = 174; Y = 22 }; AutoSize = $true }
    colonC  = @{ Type = "Label"; Text = ":"; Location = @{ X = 114; Y = 57 }; AutoSize = $true }
    colonD  = @{ Type = "Label"; Text = ":"; Location = @{ X = 174; Y = 57 }; AutoSize = $true }
    boxH    = @{ Type = "TextBox"; Text = "00"; TextAlign = "Center"; Location = @{ X = 70; Y = 20 }; Width = 36; TabIndex = 1 }
    boxM    = @{ Type = "TextBox"; Text = "00"; TextAlign = "Center"; Location = @{ X = 130; Y = 20 }; Width = 36; TabIndex = 2 }
    boxS    = @{ Type = "TextBox"; Text = "00"; TextAlign = "Center"; Location = @{ X = 190; Y = 20 }; Width = 36; TabIndex = 3 }
    boxH2   = @{ Type = "TextBox"; Text = "00"; TextAlign = "Center"; Location = @{ X = 70; Y = 55 }; Width = 36; TabIndex = 4 }
    boxM2   = @{ Type = "TextBox"; Text = "00"; TextAlign = "Center"; Location = @{ X = 130; Y = 55 }; Width = 36; TabIndex = 5 }
    boxS2   = @{ Type = "TextBox"; Text = "00"; TextAlign = "Center"; Location = @{ X = 190; Y = 55 }; Width = 36; TabIndex = 6 }
    groupO  = @{ Type = "GroupBox"; Text = "Output"; Location = @{ X = 20; Y = 95 }; Size = @{ Width = 206; Height = 70 }}
    radioA  = @{ Type = "RadioButton"; Text = "Overwrite original"; Location = @{ X = 10; Y = 20 }; AutoSize = $true; Parent = "groupO"}
    radioB  = @{ Type = "RadioButton"; Text = "Save as new file"; Location = @{ X = 10; Y = 40 }; AutoSize = $true; Parent = "groupO"; Checked = $true }
    buttonT = @{ Type = "Button"; Text = "Trim"; Location = @{ X = 164; Y = 186 }; Width = 60; TabIndex = 9 }
}

# Store instantiated controls for reference
$ui = @{}

# Instantiate controls
foreach ($name in $controls.Keys) {
    $cData = $controls[$name]
    $props = $cData.Clone()
    $props.Remove('Type')

    $ctrl = New-Object System.Windows.Forms.$($cData.Type) -Property $props
    
    if ($cData.Type -eq "TextBox") {
        $ctrl.Add_Enter({
            if ($this.Text -eq "00") { 
                $this.Text = ""
            }
        }.GetNewClosure())
        
        $ctrl.Add_LostFocus({
            if ($this.Text -eq "") { 
                $this.Text = "00"
                return
            }

            if ($this.Text.Length -eq 1) {
                $this.Text = "0" + $this.Text
            }
        }.GetNewClosure())

        $ctrl.Add_KeyPress({
            $key     = $_.KeyChar
            $newText = $this.Text + $key # might not be used :O

            if ($key -eq "`b") {
                return 
            }

            if (-not [char]::IsDigit($key)) { 
                $_.Handled = $true 
                return
            }

            if ($newText.Length -gt 2) {
                $_.Handled = $true
                return
            }

            if ([int]$newText -gt 59) {
                $_.Handled = $true
                return
            }
        }.GetNewClosure())
    } 
    $ui[$name] = $ctrl
}

# Second pass
foreach ($name in $ui.Keys) {
    $ctrl       = $ui[$name]
    $parentName = $controls[$name].Parent

    if ($parentName) {
        $ui[$parentName].Controls.Add($ctrl)
    } 
    else {
        $box.Controls.Add($ctrl)
    }
}

# Click event for Trim button
$ui.buttonT.Add_Click({
    ToggleUIState

    $start   = "$($ui.boxH.Text):$($ui.boxM.Text):$($ui.boxS.Text)"
    $stop    = "$($ui.boxH2.Text):$($ui.boxM2.Text):$($ui.boxS2.Text)"
    $tmpPath = Join-Path $env:TEMP "$(Get-Random)_$([IO.Path]::GetFileName($inputPath))"

    $tStart = [TimeSpan]::Parse($start)
    $tStop  = [TimeSpan]::Parse($stop)

    if ($tStop -le $tStart) {
        [System.Windows.Forms.MessageBox]::Show(
            "Stop must be after Start",
            "Invalid Time Range",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
            )
        ToggleUIState
        return
    }
    
    ffmpeg -y -ss $start -to $stop -i "$($inputPath)" -c copy $tmpPath

    if ($LASTEXITCODE -eq 0) {
        if ($ui.radioA.Checked) {
            Move-Item -Force $tmpPath $inputPath
        }
        else {
            $timestamp = Get-Date -Format "_HH.mm.s"

            $directory  = [IO.Path]::GetDirectoryName($inputPath)
            $basename   = [IO.Path]::GetFileNameWithoutExtension($inputPath)
            $extension  = [IO.Path]::GetExtension($inputPath)

            $newFilename     = "$basename$timestamp$extension"
            $destinationPath = Join-Path $directory $newFilename

            Move-Item -Force $tmpPath $destinationPath
        }

        [System.Windows.Forms.MessageBox]::Show(
            "Trim successful",
            "Done",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    } 
    else {
        Remove-Item -Force $tmpPath -ErrorAction SilentlyContinue
        
        [System.Windows.Forms.MessageBox]::Show(
            "Something went wrong. FFmpeg failed with code $($LASTEXITCODE)",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
    ToggleUIState
})

$box.ShowDialog()