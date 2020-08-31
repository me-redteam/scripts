function Get-ScreenShot
{
    [CmdletBinding(DefaultParameterSetName='OfWholeScreen')]
    param(    
    # If set, takes a screen capture of the current window
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true,
        ParameterSetName='OfWindow')]
    [Switch]$OfWindow,
    
    # The path for the screenshot.
    # If this isn't set, the screenshot will be automatically saved to a file in the current directory named ScreenCapture
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [string]
    $Path,
    
    # The image format used to store the screen capture
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [ValidateSet('PNG', 'JPEG', 'TIFF', 'GIF', 'BMP')]
    [string]
    $ImageFormat = 'JPEG',
    
    # The time before and after each screenshot
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Timespan]$ScreenshotTimer = "0:0:0.125"
    )


    begin {

        Add-Type -AssemblyName System.Drawing, System.Windows.Forms    
    }

    process {
        $Monitors = [System.Windows.Forms.Screen]::AllScreens
        
        $finalWidth = 0; 
        $finalHeight = 0;

        foreach ($Monitor in $Monitors)
        {
	        $DeviceName = (($Monitor.DeviceName).replace("\", "")).replace(".", "")
	        $Width = $Monitor.bounds.Width
            $finalWidth = $finalWidth + $Width; 
	        $Height = $Monitor.bounds.Height
            if ($Height -gt $finalHeight) {
                $finalHeight = $Height;
                
            }
            	        
        }

        #Write-Host "$finalWidth x $finalHeight"

        #region Codec Info
        $Codec = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | 
            Where-Object { $_.FormatDescription -eq $ImageFormat }

        $ep = New-Object Drawing.Imaging.EncoderParameters  
        if ($ImageFormat -eq 'JPEG') {
            $ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]100)  
        }
        #endregion Codec Info
        

        #region PreScreenshot timer
        if ($ScreenshotTimer -and $ScreenshotTimer.TotalMilliseconds) {
            Start-Sleep -Milliseconds $ScreenshotTimer.TotalMilliseconds
        }
        #endregion Prescreenshot Timer
        
        #region File name
        if (-not $Path) {
            $screenCapturePathBase = "$pwd\ScreenCapture"
        } else {
            $screenCapturePathBase = $Path
        }
        $c = 0
        while (Test-Path "${screenCapturePathBase}${c}.$ImageFormat") {
            $c++
        }
        #endregion   
        
            
            #region PostScreenshot timer
            if ($ScreenshotTimer -and $ScreenshotTimer.TotalMilliseconds) {
                Start-Sleep -Milliseconds $ScreenshotTimer.TotalMilliseconds
            }
            #endregion Postscreenshot Timer
            
            Get-Item -ErrorAction SilentlyContinue -Path "${screenCapturePathBase}${c}.$ImageFormat"
            
            $bounds = New-Object Drawing.Rectangle -Property @{
                    Width = $finalWidth
                    Height = $finalHeight
             }            
            
            $bitmap = New-Object Drawing.Bitmap $bounds.width, $bounds.height
            $graphics = [Drawing.Graphics]::FromImage($bitmap)
            $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)
            #region PostScreenshot timer
            if ($ScreenshotTimer -and $ScreenshotTimer.TotalMilliseconds) {
                Start-Sleep -Milliseconds $ScreenshotTimer.TotalMilliseconds
            }
            #endregion Postscreenshot Timer

            $bitmap.Save("${screenCapturePathBase}${c}.$ImageFormat", $Codec, $ep)                    
            $graphics.Dispose()
            $bitmap.Dispose()
            Get-Item -ErrorAction SilentlyContinue -Path "${screenCapturePathBase}${c}.$ImageFormat"
        }       
                
                
    
}

Get-ScreenShot 