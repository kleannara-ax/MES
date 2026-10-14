using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.IO;

namespace SAMMI
{
    public class IniFile
    {
        [DllImport("kernel32")]
        private static extern long WritePrivateProfileString(string section, string key, string val, string filePath);
        [DllImport("kernel32")]
        private static extern int GetPrivateProfileString(string section, string key, string def, StringBuilder retVal, int size, string filePath);

        public static string DefaultDirectory = "C:\\Kleannara";
        public static string ConfigFolder= "Cfg";
        //ini파일 경로 지정
        public static string iniPathFile = DefaultDirectory + "\\" + ConfigFolder + "\\config.ini";

        public static void FolderCheck()
        {
            if (!Directory.Exists(DefaultDirectory))
            {
                Directory.CreateDirectory(DefaultDirectory);
            }

            if (!Directory.Exists(DefaultDirectory + "\\" + ConfigFolder))
            {
                Directory.CreateDirectory(DefaultDirectory + "\\" + ConfigFolder);
            }
        }


        public static void SetValue(string Section, string Key, string Value)
        {
            string path = iniPathFile;

            FolderCheck();

            WritePrivateProfileString(Section, Key, Value, path);
        }

        public static string GetValue(string Section, string Key, string Default)
        {
            string path = iniPathFile;

            FolderCheck();

            StringBuilder temp = new StringBuilder(255);
            int i = GetPrivateProfileString(Section, Key, Default, temp, 255, path);
            if (temp != null && temp.Length > 0) return temp.ToString();
            else return Default;
        }
    }
}
