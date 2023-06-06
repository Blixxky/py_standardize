# Define the target file extension
$targetExtension = "*.py"

# Define the output file
$outputFile = "formatted.txt"

# Install the required Python libraries
Write-Host "Installing required Python libraries..."

# Define the libraries to install
$libraries = @(
	"black",
    "flake8",
    "mypy",
    "pylint",
    "autoflake"
)

# Initialize the progress bar
$totalLibraries = $libraries.Count
$percentCompletePerLibrary = 100 / $totalLibraries

foreach ($library in $libraries) {
    # Update the progress bar for library installation
    $percentComplete = $percentCompletePerLibrary * ($libraries.IndexOf($library) + 1)
    Write-Progress -Activity "Installing $library" -PercentComplete $percentComplete
    # Install the library
    pip install $library -q  # Use -q flag to suppress output
}

$currentDirectory = $PWD.Path

# Retrieve .py files from the current directory
$files = Get-ChildItem -Path $currentDirectory -Recurse -Include $targetExtension -File
$totalFiles = $files.Count  # Calculate the total number of files
# Update the output file path to the script's working directory
$outputFile = Join-Path -Path $currentDirectory -ChildPath "formatted.txt"

# Initialize overall progress bar
$totalFiles = $files.Count
$currentFileIndex = 0
$overallProgress = 0

# Process each .py file
foreach ($file in $files) {
    $currentFileIndex++
    $fileName = $file.Name
    $filePath = if ($file.DirectoryName -ne $PWD.Path) { Join-Path -Path $file.DirectoryName -ChildPath $fileName } else { $fileName }

    # Change the current working directory to the directory of the file
    Set-Location -Path $file.DirectoryName

    # Update overall progress bar for each file
    $overallProgress = ($currentFileIndex / $totalFiles) * 100
    Write-Progress -Activity "Processing file $fileName" -PercentComplete $overallProgress -Status "Running commands" -CurrentOperation "Processing..."

    # Run each command and append output to the file
    Write-Host "Processing file $fileName"

    black $filePath --quiet --line-length 100 2>&1 | Tee-Object -FilePath $outputFile -Append
    Write-Host " - black completed"

    flake8 $filePath --max-line-length 100 2>&1 | Tee-Object -FilePath $outputFile -Append
    Write-Host " - flake8 completed"

    mypy $filePath 2>&1 | Tee-Object -FilePath $outputFile -Append
    Write-Host " - mypy completed"

    pylint $filePath 2>&1 | Tee-Object -FilePath $outputFile -Append
    Write-Host " - pylint completed"

    autoflake --remove-all-unused-imports --in-place $filePath 2>&1 | Tee-Object -FilePath $outputFile -Append
    Write-Host " - autoflake completed"

    # Change the current working directory back to the original directory
    Set-Location -Path $currentDirectory
}


(Get-Content -Path $outputFile) |
    Where-Object {
        $_ -notmatch '^Your code has been rated at|^-----+|^\*+' -and
        $_ -notmatch 'line too long' -and
        $_ -notmatch '^Found \d+ errors in \d+ files.*' -and
        $_.Trim() -ne ''
    } |
    Set-Content -Path "report_log_trimmed.txt"

# Delete the 'formatted.txt' file
Remove-Item -Path $outputFile
