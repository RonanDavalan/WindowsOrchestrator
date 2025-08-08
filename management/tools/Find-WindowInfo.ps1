# Ce script liste toutes les fenêtres visibles, leur titre, et le nom du processus qui les possède.
# On utilise un nom de classe unique pour éviter les conflits de session PowerShell.
$code = @"
using System;
using System.Text;
using System.Runtime.InteropServices;
public class FindWindowUser32 {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)] public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);
}
"@
Add-Type -TypeDefinition $code -Language CSharp
$callback = {
    param($hWnd, $lParam)
    if ([FindWindowUser32]::IsWindowVisible($hWnd)) {
        $sb = New-Object System.Text.StringBuilder 256
        [FindWindowUser32]::GetWindowText($hWnd, $sb, $sb.Capacity) | Out-Null
        $title = $sb.ToString()
        if ($title.Length -gt 0) {
            # On utilise un nom de variable qui n'est pas réservé par PowerShell
            $windowPid = 0
            [FindWindowUser32]::GetWindowThreadProcessId($hWnd, [ref]$windowPid) | Out-Null
            $process = Get-Process -Id $windowPid -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host ("Titre: '{0}'`t| Processus: {1} ({2})" -f $title, $process.ProcessName, $process.Id)
            }
        }
    }
    return $true
}
Write-Host "--- Liste des fenêtres visibles et de leurs processus propriétaires ---"
[FindWindowUser32]::EnumWindows($callback, [System.IntPtr]::Zero)

