using Microsoft.Win32;
using System.Text;
using System.Text.RegularExpressions;
using MyTrueGear;
using System.Diagnostics;
using System.Runtime.InteropServices;

class Program
{
    private static string steamAppID = "2050650";
    private static string inertFilePath = "\\reframework\\data\\TrueGear.log";
    private static string listenFilePath = null;

    private static bool first = true;
    private static int counter = 0;

    private static TrueGearMod _TrueGear = null;
    private static Thread runLogThread = null;

    private static string _SteamExe;
    public const string STEAM_OPENURL = "steam://rungameid/2050650";



    public static string SteamExePath()
    {
        return (string)Registry.GetValue(@"HKEY_CURRENT_USER\SOFTWARE\Valve\Steam", "SteamExe", null);
    }

    public static void Main()
    {
        string currentProcessName = Process.GetCurrentProcess().ProcessName;
        Process[] processes = Process.GetProcessesByName(currentProcessName);
        if (processes.Length > 1)
        {
            if (processes[0].UserProcessorTime.TotalMilliseconds > processes[1].UserProcessorTime.TotalMilliseconds)
            {
                processes[0].Kill();
            }
            else
            {
                processes[1].Kill();
            }
        }


        string appIDPath = FindSteamAppIDPatch(steamAppID);
        listenFilePath = appIDPath + inertFilePath;

        _TrueGear = new TrueGearMod();

        runLogThread = new Thread(runGetLog);
        runLogThread.Start();


        Thread.Sleep(500);
        _SteamExe = SteamExePath();
        if (_SteamExe != null) Process.Start(_SteamExe, STEAM_OPENURL);
    }

    private static Timer _timer;
    private static void GameEventCheck(string gameEvent)
    {
        string[] damage = gameEvent.Split(',');

        if (damage.Length != 1)
        {
            _TrueGear.PlayAngle(damage[0], float.Parse(damage[1]), float.Parse(damage[2]));
            Console.WriteLine($"Play :{damage[0]},{damage[1]},{damage[2]}");
        }
        else
        {
            if (damage[0] == "Healing")
            {
                if (_timer == null)
                {
                    _timer = new Timer(HealingTimerCallBack, null, 50, Timeout.Infinite);
                }
            }
            else if (damage[0] == "StopHealing")
            {
                Console.WriteLine($"into :StopHealing");
                canHealing = false;
            }
            else
            {
                _TrueGear.Play(damage[0]);
                Console.WriteLine($"Play :{damage[0]}");
            }
        }
    }

    private static bool canHealing = true;
    private static void HealingTimerCallBack(object o)
    {
        if (canHealing)
        {
            Console.WriteLine($"Play :Healing");
            _TrueGear.Play("Healing");
        }
        canHealing = true;
        _timer.Dispose();
        _timer = null;
    }


    public static void runGetLog()
    {
        try
        {
            while (true)
            {
                if (File.Exists(listenFilePath))
                {
                    if (first)
                    {
                        first = false;
                        counter = ReadLines(listenFilePath).Count();
                    }

                    int lineCount = ReadLines(listenFilePath).Count();
                    if (counter < lineCount && lineCount > 0)
                    {
                        var lines = Enumerable.ToList(ReadLines(listenFilePath).Skip(counter).Take(lineCount - counter));
                        for (int i = 0; i < lines.Count; i++)
                        {
                            if (lines[i].Contains("[TrueGear]"))
                            {
                                string line = lines[i].Substring(lines[i].LastIndexOf(':') + 1);
                                string trimmedInput = line.Trim('{', '}');

                                //Console.WriteLine("---------------------------------------");
                                //Console.WriteLine(trimmedInput);
                                GameEventCheck(trimmedInput);
                                //_TrueGear.Play(trimmedInput);
                            }
                        }
                        counter += lines.Count;
                    }
                    else if (counter == lineCount && lineCount > 0)
                    {
                        Thread.Sleep(50);
                    }
                    else
                    {
                        counter = 0;
                    }
                }
                else
                {
                    Console.WriteLine("未找到log文件 ：" + listenFilePath);
                    Thread.Sleep(10000);
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine("发生异常：" + ex.Message);
            Console.WriteLine("堆栈跟踪：" + ex.StackTrace);
        }
    }

    public static IEnumerable<string> ReadLines(string path)
    {
        using (var fs = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite, 0x1000, FileOptions.SequentialScan))
        using (var sr = new StreamReader(fs, Encoding.UTF8))
        {
            string line;
            while ((line = sr.ReadLine()) != null)
            {
                yield return line;
            }
        }
    }



    public static string FindSteamAppIDPatch(string appID)
    {
        string steamPath = GetSteamPath();
        if (steamPath != null)
        {
            string gamePath = GetGamePath(steamPath, appID);
            return gamePath;
        }
        else
        {
            Console.WriteLine("未找到游戏路径");
        }
        return null;
    }

    public static string GetSteamPath()
    {
        using (RegistryKey key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\WOW6432Node\Valve\Steam"))
        {
            if (key != null)
            {
                return key.GetValue("InstallPath") as string;
            }
        }
        return null;
    }

    public static string GetGamePath(string steamPath, string appId)
    {
        string libraryFoldersPath = Path.Combine(steamPath, "steamapps", "libraryfolders.vdf");
        List<string> libraryFolders = ParseVdf(libraryFoldersPath);

        string gamePath = FindGamePath(libraryFolders, appId);

        if (gamePath != null)
        {
            gamePath = gamePath.Replace("/", @"\");
            gamePath = gamePath.Replace(@"\\", @"\");
            return gamePath;
        }
        else
        {
            Console.WriteLine("未找到游戏路径");
        }

        return null;
    }

    public static List<string> ParseVdf(string filePath)
    {
        var libraryFolders = new List<string>();
        string fileContent = File.ReadAllText(filePath);

        var matches = Regex.Matches(fileContent, "\"path\"\\s*\"(.+?)\"");

        foreach (Match match in matches)
        {
            libraryFolders.Add(match.Groups[1].Value);
        }
        return libraryFolders;
    }

    public static string FindGamePath(List<string> libraryFolders, string appId)
    {
        foreach (var folder in libraryFolders)
        {
            string manifestPath = Path.Combine(folder, $"steamapps/appmanifest_{appId}.acf");
            if (File.Exists(manifestPath))
            {
                string installDir = ParseInstallDir(manifestPath);
                if (!string.IsNullOrEmpty(installDir))
                {
                    return Path.Combine(folder, "steamapps/common/", installDir);
                }
            }
        }

        return null;
    }

    public static string ParseInstallDir(string manifestPath)
    {
        string fileContent = File.ReadAllText(manifestPath);
        var match = Regex.Match(fileContent, "\"installdir\"\\s*\"(.+?)\"");

        if (match.Success)
        {
            return match.Groups[1].Value;
        }

        return null;
    }

}