Add-Type -AssemblyName PresentationFramework

# Function to determine if the system is using a dark theme
function Is-DarkTheme {
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes'
    $value = Get-ItemProperty -Path $key -Name 'AppsUseLightTheme' -ErrorAction SilentlyContinue
    return $value.AppsUseLightTheme -eq 0
}

# Define the URL for the XAML file
$xamlUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/xmal/inputXML.xaml"

# Fetch the XAML content
try {
    Write-Host "Fetching XAML from $xamlUrl..." -ForegroundColor Cyan
    $xamlContent = Invoke-RestMethod -Uri $xamlUrl -Method Get -ErrorAction Stop
    [xml]$xaml = $xamlContent
    Write-Host "XAML successfully loaded." -ForegroundColor Green
} catch {
    Write-Host "Failed to fetch or parse the XAML: ${_}" -ForegroundColor Red
    exit
}

# Create the WPF window from the XAML
$window = [Windows.Markup.XamlReader]::Load($xaml.CreateNavigator())

# Function to fetch and execute the script from the URL
function Run-ScriptFromUrl {
    param (
        [string]$Url
    )

    try {
        Write-Host "Fetching script from $Url..." -ForegroundColor Cyan
        $scriptContent = Invoke-RestMethod -Uri $Url -Method Get -ErrorAction Stop

        if ($scriptContent) {
            Write-Host "Executing script content..." -ForegroundColor Green
            Invoke-Expression $scriptContent
        } else {
            Write-Host "No script content received." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Failed to fetch or execute script: ${_}" -ForegroundColor Red
    }
}

# Define the URL for the JSON file containing script URLs
$jsonUrl = "https://raw.githubusercontent.com/KimDog-Studios/2025Utility/main/config/config.json"

# Fetch the JSON and parse it
try {
    Write-Host "Fetching URLs from JSON..." -ForegroundColor Cyan
    $urls = Invoke-RestMethod -Uri $jsonUrl -Method Get -ErrorAction Stop
    Write-Host "URLs successfully loaded." -ForegroundColor Green
} catch {
    Write-Host "Failed to fetch or parse the JSON: ${_}" -ForegroundColor Red
    exit
}

# Create a list of menu options and corresponding URLs
$menuOptions = @(
    @{ Name = "Optimize for Gaming"; URL = $urls.urls.WPFGamingOptimization.URL },
    @{ Name = "Remove Bloatware [Windows 11]"; URL = $urls.urls.WPFRemoveAppX.URL },
    @{ Name = "Apply Ultimate Performance Mode"; URL = $urls.urls.WPFUltimatePerformance.URL },
    @{ Name = "Apply Dark Mode to Windows"; URL = $urls.urls.InvokeDarkMode.URL },
    @{ Name = "Disable Mouse Acceleration"; URL = $urls.urls.InvokeMouseAcceleration.URL },
    @{ Name = "Enable Classic Right Click Menu"; URL = $urls.urls.WPFClassicRightClick.URL },
    @{ Name = "Set Windows Updates to Default"; URL = $urls.urls.InvokeSetWindowsUpdatesToDefault.URL },
    @{ Name = "Set Updates to Security [Recommended]"; URL = $urls.urls.InvokeSetWindowsUpdatesToSecurity.URL },
    @{ Name = "Disable Windows Updates [NOT Recommended]"; URL = $urls.urls.InvokeSetWindowsUpdatesToDisabled.URL },
    @{ Name = "Uninstall Microsoft Edge"; URL = $urls.urls.InvokeEnableWindowsFeedback.URL }
)

# Populate the StackPanel with buttons
$stackPanel = $window.FindName("ContentStackPanel")
foreach ($option in $menuOptions) {
    $button = New-Object System.Windows.Controls.Button
    $button.Content = $option.Name
    $button.Margin = "10"
    $button.Height = 50
    $button.Background = [System.Windows.Media.Brushes]::LightBlue
    $button.Foreground = [System.Windows.Media.Brushes]::Black
    $button.Add_Click({
        Run-ScriptFromUrl -Url $option.URL  # Execute the script
    })
    $stackPanel.Children.Add($button)
}

# Show the window
$window.ShowDialog() | Out-Null